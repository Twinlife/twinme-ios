/*
 *  Copyright (c) 2014-2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Zhuoyu Ma (Zhuoyu.Ma@twinlife-systems.com)
 *   Shiyi Gu (Shiyi.Gu@twinlife-systems.com)
 *   Christian Jacquemot (Christian.Jacquemot@twinlife-systems.com)
 *   Leiqiang Zhong (Leiqiang.Zhong@twinlife-systems.com)
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 *   Stephane Carrez (Stephane.Carrez@twin.life)
 */

#import <PushKit/PushKit.h>

#import <CocoaLumberjack.h>
#import <DDASLLogger.h>

#import <WebRTC/RTCLogging.h>
#import <WebRTC/RTCSSLAdapter.h>

#import <Twinlife/TLManagementService.h>
#import <Twinlife/TLPeerConnectionService.h>
#import <Twinlife/TLJobService.h>
#import <Twinlife/TLAccountService.h>
#import <Twinlife/TLApplication.h>
#import <Twinlife/TLAssertion.h>

#import <Twinme/TLTwinmeContext.h>
#import <Twinme/TLPushNotificationContent.h>
#import <UserNotifications/UserNotifications.h>
#import <Utils/NSString+Utils.h>

#import <TwinmeCommon/ApplicationDelegate.h>

#import <TwinmeCommon/MainViewController.h>
#import <TwinmeCommon/TwinmeNavigationController.h>
#import "ShareViewController.h"
#import <TwinmeCommon/UIViewController+Utils.h>
#import "Configuration.h"
#import <TwinmeCommon/TwinmeApplication.h>
#import <TwinmeCommon/AdminService.h>
#import <TwinmeCommon/NotificationCenter.h>
#import <TwinmeCommon/CallService.h>
#import <TwinmeCommon/AccountMigrationService.h>
#import "ApplicationAssertion.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: ApplicationDelegate ()
//

@interface ApplicationDelegate () <PKPushRegistryDelegate>

@property (nonatomic, readonly) BOOL enableCallkit;
@property (nonatomic) BOOL inBackground;
@property (nonatomic) PKPushRegistry *voipRegistry;
@property (nonatomic) BOOL allowNotificationsStatus;

@end

//
// Implementation: ApplicationDelegate
//

#undef LOG_TAG
#define LOG_TAG @"ApplicationDelegate"

@implementation ApplicationDelegate

+ (void)initialize {
    
    [DDLog addLogger:[DDOSLogger sharedInstance]];
}

- (instancetype)init {
    DDLogVerbose(@"%@ init", LOG_TAG);
    
    self = [super init];
    
    if (self) {
        _twinmeApplication = [[TwinmeApplication alloc] init];
        _twinmeContext = [[TLTwinmeContext alloc] initWithTwinmeApplication:_twinmeApplication configuration:[[Configuration alloc] init]];
        _adminService = [[AdminService alloc] initWithTwinmeContext:_twinmeContext];
        _enableCallkit = ![[[NSLocale currentLocale] countryCode] containsString:@"CN"] && ![[[NSLocale currentLocale] countryCode] containsString:@"CHN"];
        
        _callService = [[CallService alloc] initWithTwinmeContext:_twinmeContext twinmeApplication:_twinmeApplication enableCallkit:_enableCallkit];
        _accountMigrationService = [[AccountMigrationService alloc] initWithTwinmeContext:_twinmeContext];
        [_twinmeApplication.notificationCenter initWithCallService:_callService accountMigrationService:_accountMigrationService];
        // Create the default space settings based on the user's current settings.
        TLSpaceSettings *settings = [_twinmeApplication defaultSpaceSettings];
        [_twinmeContext setDefaultSpaceSettings:settings oldDefaultName:TwinmeLocalizedString(@"application_default", nil)];
        _inBackground = YES;

        // Start very early the twinlife library (executes asynchronously).
        [_twinmeContext start];
    }
    return self;
}

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    DDLogVerbose(@"%@ application: %@ willFinishLaunchingWithOptions: %@", LOG_TAG, application, launchOptions);
    
    RTCInitializeSSL();
#if defined(NDEBUG)
    RTCSetMinDebugLogLevel(RTCLoggingSeverityWarning);
#endif

    if (@available(iOS 13.0, *)) {
        // Use the Apple remote notification for messages, must match NotificationService extension deployment.
        // This forces us to use CallKit after a PushKit message is received.
        [application registerForRemoteNotifications];
    }
    [self checkAllowNotifications];
    
    // Register for VoIP notifications
    self.voipRegistry = [[PKPushRegistry alloc] initWithQueue:dispatch_get_main_queue()];
    self.voipRegistry.delegate = self;
    self.voipRegistry.desiredPushTypes = [NSSet setWithObject:PKPushTypeVoIP];
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    DDLogVerbose(@"%@ application: %@ didFinishLaunchingWithOptions: %@", LOG_TAG, application, launchOptions);
    
    [self.window makeKeyAndVisible];
    
    // Preloads keyboard so there's no lag on initial keyboard appearance
    UITextField *lagFreeField = [[UITextField alloc] init];
    [self.window addSubview:lagFreeField];
    [lagFreeField becomeFirstResponder];
    [lagFreeField resignFirstResponder];
    [lagFreeField removeFromSuperview];
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    DDLogVerbose(@"%@ applicationDidEnterBackground: %@", LOG_TAG, application);
    
    self.inBackground = YES;
    [self.twinmeContext applicationDidEnterBackground:self];
    [self.callService applicationDidEnterBackground:application];
    [self.twinmeApplication.notificationCenter applicationDidEnterBackground:application];
    
    // When we enter in background, make sure the view receives the viewWillDisappear so that it
    // knows it is not visible.  Useful for the conversation view which must not mark as-read
    // the messages it receives while in background.
    [self.window.rootViewController beginAppearanceTransition:NO animated:NO];
    [self.window.rootViewController endAppearanceTransition];
}

- (void)checkAllowNotifications {
    DDLogVerbose(@"%@ checkAllowNotifications", LOG_TAG);

    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings *settings) {
        self.allowNotificationsStatus = settings.authorizationStatus == UNAuthorizationStatusAuthorized;

        DDLogVerbose(@"%@ allowNotifications: %d", LOG_TAG, self.allowNotificationsStatus);
    }];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    DDLogVerbose(@"%@ applicationWillEnterForeground: %@", LOG_TAG, application);

    [self checkAllowNotifications];
    [self.twinmeContext applicationDidBecomeActive:self];
    [self.callService applicationWillEnterForeground:application];
    self.inBackground = NO;
    
    // When we enter the foreground, make visible again the previous view so that viewWillAppear is triggered.
    [self.window.rootViewController beginAppearanceTransition:YES animated:NO];
    [self.window.rootViewController endAppearanceTransition];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    DDLogVerbose(@"%@ applicationDidBecomeActive: %@", LOG_TAG, application);
    
    if (self.inBackground) {
        [self.twinmeContext applicationDidBecomeActive:self];
        self.inBackground = NO;
    }
    
    // If the TwinmeLite account is migrated to Twinme+, the account is not reconnectable and we MUST not continue.
    // Redirect to the Splash screen that will display some message: the application must be uninstalled.
    if (![[self.twinmeContext getAccountService] isReconnectable]) {
        UIViewController *splashScreenViewController = [self.mainViewController.storyboard instantiateViewControllerWithIdentifier:@"SplashScreenViewController"];
        if ([self.mainViewController isInitialized]) {
            [self.mainViewController presentViewController:splashScreenViewController animated:YES completion:nil];
        }
    }
    
    [self.twinmeApplication.notificationCenter applicationDidBecomeActive:application];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    DDLogVerbose(@"%@ applicationWillTerminate: %@", LOG_TAG, application);
    
    [TLTwinlife dispose];
    RTCCleanupSSL();
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler {
    DDLogVerbose(@"%@ application: %@ continueUserActivity openURL: %@ sourceApplication: %@", LOG_TAG, application, userActivity.webpageURL, userActivity.activityType);
    
    if ([userActivity.activityType isEqualToString: NSUserActivityTypeBrowsingWeb]) {
        NSURL *url = userActivity.webpageURL;
        return [self.twinmeContext openURL:url options:nil];
    }
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
    DDLogVerbose(@"%@ application: %@ openURL: %@ options: %@", LOG_TAG, application, url, options);
    
    if (!url) {
        return NO;
    }

    // Always call the twinme context openURL to handle correct setup of twinlife framework.
    // In particular, we may need to reload some conversation operations for the conversation
    // scheduler in case some operation was created by the ShareExtension.
    BOOL result = [self.twinmeContext openURL:url options:options];
    if (result) {
        return result;
    }

    if ([url.scheme isEqualToString:@"file"]) {
        UIViewController *topViewController = self.mainViewController.navigationController.topViewController;
        
        if (topViewController.presentedViewController) {
            [topViewController.presentedViewController dismissViewControllerAnimated:NO completion:^{
            }];
        }
        
        if ([self.mainViewController isInitialized]) {
            ShareViewController *shareViewController = [self.mainViewController.storyboard instantiateViewControllerWithIdentifier:@"ShareViewController"];
            shareViewController.fileURL = url;
            
            TwinmeNavigationController *navigationController = [[TwinmeNavigationController alloc]initWithRootViewController:shareViewController];
            [self.mainViewController presentViewController:navigationController animated:YES completion:nil];
        } else {
            self.mainViewController.shareContentURL = url;
        }

        // This URL is recognized and we handle it.
        return YES;
    }

    // Special action triggered by the ShareExtension to redirect and display the conversation.
    if ([CONVERSATION_ACTION isEqualToString:url.host]) {
        [self.mainViewController onOpenURL:url];
        return YES;
    }

    return NO;
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    DDLogVerbose(@"%@ performFetchWithCompletionHandler %@", LOG_TAG, application);
    
    [[self.twinmeContext getJobService] didWakeupWithApplication:self kind:TLWakeupKindFetch fetchCompletionHandler:^(TLBaseServiceErrorCode errorCode) {
        completionHandler(UIBackgroundFetchResultNewData);
    }];
}

#pragma mark - TLApplication Delegate

- (UIBackgroundTaskIdentifier)beginBackgroundTaskWithExpirationHandler:(nonnull void (^)(void))block {
    DDLogVerbose(@"%@ beginBackgroundTaskWithExpirationHandler: %@", LOG_TAG, block);
    
    UIApplication *application = [UIApplication sharedApplication];
    return [application beginBackgroundTaskWithExpirationHandler:block];
}

- (void)endBackgroundTask:(UIBackgroundTaskIdentifier)backgroundTaskIdentifier {
    DDLogVerbose(@"%@ endBackgroundTask: %ld", LOG_TAG, (long)backgroundTaskIdentifier);
    
    UIApplication *application = [UIApplication sharedApplication];
    [application endBackgroundTask:backgroundTaskIdentifier];
}

- (NSTimeInterval)backgroundTimeRemaining {
    DDLogVerbose(@"%@ backgroundTimeRemaining", LOG_TAG);
    
    UIApplication *application = [UIApplication sharedApplication];
    return [application backgroundTimeRemaining];
}

- (void)setMinimumBackgroundFetchInterval:(NSTimeInterval)delay {
    DDLogVerbose(@"%@ setMinimumBackgroundFetchInterval: %f", LOG_TAG, delay);
    
    UIApplication *application = [UIApplication sharedApplication];
    [application setMinimumBackgroundFetchInterval:delay];
}

- (BOOL)allowNotifications {
    DDLogVerbose(@"%@ allowNotifications: %d", LOG_TAG, self.allowNotificationsStatus);

    return self.allowNotificationsStatus;
}

#pragma mark - Orientation

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    DDLogVerbose(@"%@ application: %@ supportedInterfaceOrientationsForWindow: %@", LOG_TAG, application, window);
    
    UIViewController *topViewController = [UIViewController topViewController];
    if ([topViewController hasLandscapeMode]) {
        return UIInterfaceOrientationMaskAll;
    }
    
    return UIInterfaceOrientationMaskPortrait;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    DDLogVerbose(@"%@ application: %@ didRegisterForRemoteNotificationsWithDeviceToken: %@", LOG_TAG, application, deviceToken);
    
    const char *bytes = [deviceToken bytes];
    NSMutableString *token = [NSMutableString string];
    for (NSUInteger i = 0; i < deviceToken.length; i++) {
        [token appendFormat:@"%02.2hhX", bytes[i]];
    }
    [self.twinmeContext setPushNotificationWithVariant:TL_MANAGEMENT_SERVICE_PUSH_NOTIFICATION_REMOTE_VARIANT token:token];
    
    // Callkit is disabled and we cannot use PushKit: invalidate the PushKit token but still set the VoIP variant.
    if (@available(iOS 13.0, *)) {
        if (!self.enableCallkit) {
            [self.twinmeContext setPushNotificationWithVariant:TL_MANAGEMENT_SERVICE_PUSH_NOTIFICATION_VOIP_VARIANT token:TL_MANAGEMENT_SERVICE_PUSH_NOTIFICATION_VOIP_DISABLED];
        }
    }
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    DDLogVerbose(@"%@ application: %@ didFailToRegisterForRemoteNotificationsWithError: %@", LOG_TAG, application, error);
    
    // Apple documentation recommend to disable the remote push notification when an error occurs.
    // According to their documentation, the didRegisterForRemoteNotificationsWithDeviceToken will be
    // called again if the error is recovered.
    // See https://developer.apple.com/library/archive/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/HandlingRemoteNotifications.html
    [self.twinmeContext setPushNotificationWithVariant:TL_MANAGEMENT_SERVICE_PUSH_NOTIFICATION_REMOTE_VARIANT token:TL_MANAGEMENT_SERVICE_PUSH_NOTIFICATION_APNS_ERROR];
    
    [self.twinmeContext assertionWithAssertPoint:[ApplicationAssertPoint REGISTER_FOR_REMOTE_FAILED], nil];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    DDLogVerbose(@"%@ application: %@ didReceiveRemoteNotification: %@", LOG_TAG, application, userInfo);
    
    [self.twinmeContext didReceiveIncomingPushWithPayload:userInfo application:self completionHandler:^(TLBaseServiceErrorCode status, TLPushNotificationContent *notificationContent) {
        if (!notificationContent) {
            completionHandler(UIBackgroundFetchResultFailed);
        }
    } terminateCompletionHandler:^(TLBaseServiceErrorCode status) {
        completionHandler(UIBackgroundFetchResultNoData);
    }];
}

#pragma mark - PKPushRegistryDelegate

- (void)pushRegistry:(PKPushRegistry *)registry didUpdatePushCredentials:(PKPushCredentials *)credentials forType:(NSString *)type {
    DDLogVerbose(@"%@ pushRegistry: %@ didUpdatePushCredentials: %@ forType: %@", LOG_TAG, registry, credentials, type);
    
    // Callkit is disabled and we cannot use PushKit: invalidate the PushKit token but still set the VoIP variant.
    if (@available(iOS 13.0, *)) {
        if (!self.enableCallkit) {
            [self.twinmeContext setPushNotificationWithVariant:TL_MANAGEMENT_SERVICE_PUSH_NOTIFICATION_VOIP_VARIANT token:TL_MANAGEMENT_SERVICE_PUSH_NOTIFICATION_VOIP_DISABLED];
            return;
        }
    }
    
    NSData *deviceToken = credentials.token;
    const char *bytes = [deviceToken bytes];
    NSMutableString *token = [NSMutableString string];
    for (NSUInteger i = 0; i < deviceToken.length; i++) {
        [token appendFormat:@"%02.2hhX", bytes[i]];
    }
    [self.twinmeContext setPushNotificationWithVariant:TL_MANAGEMENT_SERVICE_PUSH_NOTIFICATION_VOIP_VARIANT token:token];
}

// Timeout in seconds to resolve the PushKit notification content.
// Since iOS 18.x, it seems we have very limited amount of time.  Give 3 seconds to let the twinlife
// framework initialize.  If this fails, the notification content is not resolved, this will create
// a spurious CallKit notification but we won't crash.  Then, if we cannot another CallKit notification
// could be created to handle the real call.
#define PUSH_NOTIFICATION_TIMEOUT   (3 * NSEC_PER_SEC)

- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(PKPushType)type withCompletionHandler:(void(^)(void))completion {
    DDLogVerbose(@"%@ pushRegistry: %@ didReceiveIncomingPushWithPayload %@ forType: %@", LOG_TAG, registry, payload, type);

    // Find the receiver and wait to have the result so that we can return the information.
    // This synchronous behavior is necessary for PushKit to trigger the call to CallKit within
    // the pushRegistry() invocation.
    __block TLBaseServiceErrorCode status = TLBaseServiceErrorCodeTwinlifeOffline;
    __block TLPushNotificationContent *notificationContent = nil;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    [self.twinmeContext didReceiveIncomingPushWithPayload:payload.dictionaryPayload application:self completionHandler:^(TLBaseServiceErrorCode errorCode, TLPushNotificationContent *lNotificationContent) {
        status = errorCode;
        notificationContent = lNotificationContent;
        dispatch_semaphore_signal(semaphore);
    } terminateCompletionHandler:nil];

    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, PUSH_NOTIFICATION_TIMEOUT));

    BOOL iosPushKitCrashSyndrome;
    if (@available(iOS 13.0, *)) { // Must match NotificationService deployment version
        iosPushKitCrashSyndrome = YES;
    } else {
        iosPushKitCrashSyndrome = NO;
    }
    
    if (notificationContent) {
        NSUUID *peerConnectionId = notificationContent.sessionId;
        id<TLOriginator> originator = notificationContent.originator;
        if (peerConnectionId && originator) {
            switch (notificationContent.operation) {
                case TLPeerConnectionServiceNotificationOperationAudioCall:
                    [self.callService startCallWithPeerConnectionId:peerConnectionId originator:originator offer:[[TLOffer alloc] initWithAudio:YES video:NO videoBell:NO data:NO] inBackground:self.inBackground fromPushKit:YES];
                    iosPushKitCrashSyndrome = NO;
                    break;
                    
                case TLPeerConnectionServiceNotificationOperationVideoCall:
                    [self.callService startCallWithPeerConnectionId:peerConnectionId originator:originator offer:[[TLOffer alloc] initWithAudio:YES video:YES videoBell:NO data:NO] inBackground:self.inBackground fromPushKit:YES];
                    iosPushKitCrashSyndrome = NO;
                    break;
                    
                case TLPeerConnectionServiceNotificationOperationVideoBell:
                    [self.callService startCallWithPeerConnectionId:peerConnectionId originator:originator offer:[[TLOffer alloc] initWithAudio:YES video:YES videoBell:YES data:NO] inBackground:self.inBackground fromPushKit:YES];
                    iosPushKitCrashSyndrome = NO;
                    break;
                    
                default:
                    break;
            }
        }
    }
    
    if (iosPushKitCrashSyndrome) {
        // We are going to crash if we don't call PushKit: emit a transient CallKit call and terminates immediately.
        [self.callService onUnknownIncomingCall];
    }

    // The completion handler MUST be called AFTER the call to CallKit.
    completion();
}

- (void)registerNotification:(UIApplication *)application {
    DDLogVerbose(@"%@ registerNotification: %@", LOG_TAG, application);
    
    // If the new UNUserNotificationCenter can be used, setup to use it (even if we don't use the NotificationService extension).
    UNUserNotificationCenter *userNotificationCenter = [UNUserNotificationCenter currentNotificationCenter];
    
    userNotificationCenter.delegate = self.twinmeApplication.notificationCenter;
    [userNotificationCenter requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationsRequestAuthorizationFinish object:nil];
        if (error) {
            DDLogError(@"%@: application: cannot register notification: %@", LOG_TAG, error);
        }
        if (!granted) {
            DDLogError(@"%@ application: notification was not granted!", LOG_TAG);
        }
    }];
    
    if (@available(iOS 13.0, *)) {
        // Use the Apple remote notification for messages, must match NotificationService extension deployment.
        // This forces us to use CallKit after a PushKit message is received.
        [application registerForRemoteNotifications];
    }
}

#pragma mark - Private methods

- (void)initTwinmeContext {
    DDLogVerbose(@"%@ initTwinmeContext", LOG_TAG);
    
    _twinmeApplication = [[TwinmeApplication alloc] init];
    _twinmeContext = [[TLTwinmeContext alloc] initWithTwinmeApplication:self.twinmeApplication configuration:[[Configuration alloc] init]];
}

@end

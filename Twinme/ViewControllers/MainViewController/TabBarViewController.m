/*
 *  Copyright (c) 2020-2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Utils/NSString+Utils.h>

#import "TabBarViewController.h"

#import "EditProfileViewController.h"

#import "HistoryViewController.h"
#import "ContactsViewController.h"
#import "ConversationsViewController.h"
#import "NotificationViewController.h"
#import "SpacesViewController.h"
#import "UIGroupConversation.h"
#import "OnboardingSpaceViewController.h"
#import <TwinmeCommon/MainViewController.h>

#import <TwinmeCommon/ApplicationDelegate.h>
#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/TwinmeApplication.h>
#import <TwinmeCommon/TwinmeNavigationController.h>
#import <TwinmeCommon/Utils.h>

#import "UIView+Toast.h"
#import "UIColor+Hex.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static CGFloat DESIGN_TAB_ICON_INSET;

//
// Interface: TabBarViewController ()
//

@interface TabBarViewController ()<UITabBarControllerDelegate>

@property (nonatomic) SpacesViewController *spacesViewController;
@property (nonatomic) HistoryViewController *historyViewController;
@property (nonatomic) ContactsViewController *contactsViewController;
@property (nonatomic) ConversationsViewController *conversationsViewController;
@property (nonatomic) NotificationViewController *notificationsViewController;

@property (nonatomic) BOOL hasPendingNotifications;

@end

//
// Implementation: TabBarViewController
//

#undef LOG_TAG
#define LOG_TAG @"TabBarViewController"

@implementation TabBarViewController

#pragma mark - UIViewController

+ (void)initialize {
    DDLogVerbose(@"%@ initialize", LOG_TAG);
    
    DESIGN_TAB_ICON_INSET = 6.f;
}

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
    
    [self initViewsController];
}

- (BOOL)canBecomeFirstResponder {
    DDLogVerbose(@"%@ canBecomeFirstResponder", LOG_TAG);
    
    return YES;
}

- (void)viewDidAppear:(BOOL)animated {
    DDLogVerbose(@"%@ viewDidAppear: %@", LOG_TAG, animated ? @"YES" : @"NO");
    
    [super viewDidAppear:animated];
    
    [self becomeFirstResponder];
    
    [self updateColor];
}

- (void)viewWillDisappear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillDisappear: %@", LOG_TAG, animated ? @"YES" : @"NO");
    
    [super viewWillDisappear:animated];
}

- (NSUInteger)getSelectedIndex {
    
    return self.selectedIndex;
}

- (void)updateNotifications:(BOOL)hasPendingNotifications {
    DDLogVerbose(@"%@ updateNotifications: %@", LOG_TAG, hasPendingNotifications ? @"YES" : @"NO");
    
    self.hasPendingNotifications = hasPendingNotifications;
    
    UIImage *image = hasPendingNotifications ? [UIImage imageNamed:@"TabBarNotificationBadgeGrey"] : [UIImage imageNamed:@"TabBarNotificationGrey"];
    UIImage *selectedImage = hasPendingNotifications ? [self notificationBadgeImage] : [UIImage imageNamed:@"TabBarNotificationBlue"];
    
    self.notificationsViewController.tabBarItem.image = image;
    self.notificationsViewController.tabBarItem.selectedImage = selectedImage;
}

- (void)updateSpace {
    DDLogVerbose(@"%@ updateSpace", LOG_TAG);
    
    if (self.selectedIndex == 0) {
        [self.spacesViewController updateCurrentSpace];
    }
}

- (void)setCurrentSpace {
    DDLogVerbose(@"%@ setCurrentSpace", LOG_TAG);
    
    [self.spacesViewController updateCurrentSpace];
    [self.historyViewController updateCurrentSpace];
    [self.contactsViewController updateCurrentSpace];
    [self.conversationsViewController updateCurrentSpace];
    [self.notificationsViewController updateCurrentSpace];
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    DDLogVerbose(@"%@ tabBar: %@ didSelectItem: %@", LOG_TAG, tabBar, item);
    
    ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
    TwinmeApplication *twinmeApplication = [delegate twinmeApplication];
    [Utils hapticFeedback:UIImpactFeedbackStyleLight hapticFeedbackMode:twinmeApplication.hapticFeedbackMode];
    
    if (item.tag == 0) {
        MainViewController *mainViewController = delegate.mainViewController;
        if (mainViewController.space && [twinmeApplication showSpaceOnboarding]) {
            OnboardingSpaceViewController *onboardingSpaceViewController = [[UIStoryboard storyboardWithName:@"Space" bundle:nil] instantiateViewControllerWithIdentifier:@"OnboardingSpaceViewController"];
            [onboardingSpaceViewController showInView:mainViewController hideFirstPart:NO];
        }
        [twinmeApplication hideSpaceOnboarding];
    }
}


- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    DDLogVerbose(@"%@ tabBarController: %@ shouldSelectViewController: %@", LOG_TAG, tabBarController, viewController);

    UIViewController *fromViewController = tabBarController.selectedViewController;
    UIView *fromView = fromViewController.view;
    UIView *toView = viewController.view;
    
    if (fromView != toView) {
        [UIView transitionFromView:fromView
                            toView:toView
                          duration:0
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        completion:nil];
    }
    
    return YES;
}

#pragma mark - Private methods

- (void)initViewsController {
    DDLogVerbose(@"%@ initViewsController", LOG_TAG);
    
    self.delegate = self;
    
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName: Design.FONT_BOLD20} forState:UIControlStateNormal];
    [[UINavigationBar appearance] setShadowImage:[UIImage new]];
    [[UITextField appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setTintColor:Design.FONT_COLOR_DEFAULT];
    
    [self updateTabBarAppearance];
    
    UIEdgeInsets iconInset = UIEdgeInsetsMake(DESIGN_TAB_ICON_INSET, 0, -DESIGN_TAB_ICON_INSET, 0);
    self.spacesViewController = [[UIStoryboard storyboardWithName:@"Space" bundle:nil] instantiateViewControllerWithIdentifier:@"SpacesViewController"];
    self.spacesViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:nil image:[UIImage imageNamed:@"TabBarSpacesGrey"] tag:0];
    self.spacesViewController.tabBarItem.imageInsets = iconInset;
    self.spacesViewController.tabBarItem.accessibilityLabel = TwinmeLocalizedString(@"settings_space_view_controller_space_category_title", nil);
    
    TwinmeNavigationController *spacesNavigationController = [[TwinmeNavigationController alloc]initWithRootViewController:self.spacesViewController];
    
    self.historyViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"HistoryViewController"];
    self.historyViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:nil image:[UIImage imageNamed:@"TabBarCallGrey"] tag:1];
    self.historyViewController.tabBarItem.imageInsets = iconInset;
    self.historyViewController.tabBarItem.accessibilityLabel = TwinmeLocalizedString(@"history_view_controller_title", nil);
    
    TwinmeNavigationController *historyNavigationController = [[TwinmeNavigationController alloc]initWithRootViewController:self.historyViewController];
    
    self.contactsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ContactsViewController"];
    self.contactsViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:nil image:[UIImage imageNamed:@"TabBarContactsGrey"] tag:2];
    self.contactsViewController.tabBarItem.imageInsets = iconInset;
    self.contactsViewController.accessibilityLabel = TwinmeLocalizedString(@"contacts_view_controller_title", nil);
    
    TwinmeNavigationController *contactsNavigationController = [[TwinmeNavigationController alloc]initWithRootViewController:self.contactsViewController];
    
    self.conversationsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ConversationsViewController"];
    self.conversationsViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:nil image:[UIImage imageNamed:@"TabBarChatGrey"] tag:3];
    self.conversationsViewController.tabBarItem.imageInsets = iconInset;
    self.conversationsViewController.accessibilityLabel = TwinmeLocalizedString(@"conversations_view_controller_title", nil);
    
    TwinmeNavigationController *conversationsNavigationController = [[TwinmeNavigationController alloc]initWithRootViewController:self.conversationsViewController];
    
    self.notificationsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"NotificationViewController"];
    self.notificationsViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:nil image:[UIImage imageNamed:@"TabBarNotificationGrey"] tag:4];
    self.notificationsViewController.tabBarItem.imageInsets = iconInset;
    self.notificationsViewController.accessibilityLabel = TwinmeLocalizedString(@"application_notifications", nil);
    
    TwinmeNavigationController *notificationsNavigationController = [[TwinmeNavigationController alloc]initWithRootViewController:self.notificationsViewController];
    
    NSArray *viewControllers = [NSArray arrayWithObjects:spacesNavigationController, historyNavigationController, contactsNavigationController, conversationsNavigationController, notificationsNavigationController,  nil];
    
    [self setViewControllers:viewControllers animated:YES];
    
    ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
    TwinmeApplication *twinmeApplication = [delegate twinmeApplication];
    
    self.selectedIndex = twinmeApplication.defaultTab;
    
    [self updateColor];
}

- (UIImage *)tintImageWithColor:(UIImage *)image color:(UIColor *)color {
    DDLogVerbose(@"%@ tintImageWithColor: %@ color: %@", LOG_TAG, image, color);
    
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [color setFill];
    CGContextTranslateCTM(context, 0, image.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextClipToMask(context, CGRectMake(0, 0, image.size.width, image.size.height), [image CGImage]);
    CGContextFillRect(context, CGRectMake(0, 0, image.size.width, image.size.height));
    
    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return tintedImage;
}

- (UIImage *)notificationBadgeImage {
    DDLogVerbose(@"%@ notificationBadgeImage", LOG_TAG);
    
    UIImage *imageNotitification = [self tintImageWithColor:[UIImage imageNamed:@"TabBarNotification"] color:Design.MAIN_COLOR];
    UIImage *imageBadge = [UIImage imageNamed:@"TabBarNotificationBadge"];
    CGSize size = CGSizeMake(imageNotitification.size.width, imageNotitification.size.height);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, imageNotitification.scale);
    
    [imageNotitification drawInRect:CGRectMake(0, 0, size.width, size.height)];
    [imageBadge drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    [self updateTabBarAppearance];
    
    UIEdgeInsets iconInset = UIEdgeInsetsMake(DESIGN_TAB_ICON_INSET, 0, -DESIGN_TAB_ICON_INSET, 0);
    self.spacesViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:nil image:[UIImage imageNamed:@"TabBarSpacesGrey"] tag:0];
    self.spacesViewController.tabBarItem.imageInsets = iconInset;
    self.spacesViewController.tabBarItem.accessibilityLabel = TwinmeLocalizedString(@"settings_space_view_controller_space_category_title", nil);
    
    self.historyViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:nil image:[UIImage imageNamed:@"TabBarCallGrey"] tag:1];
    self.historyViewController.tabBarItem.imageInsets = iconInset;
    self.historyViewController.tabBarItem.accessibilityLabel = TwinmeLocalizedString(@"history_view_controller_title", nil);
    
    self.contactsViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:nil image:[UIImage imageNamed:@"TabBarContactsGrey"] tag:2];
    self.contactsViewController.tabBarItem.imageInsets = iconInset;
    self.contactsViewController.accessibilityLabel = TwinmeLocalizedString(@"contacts_view_controller_title", nil);
    
    self.conversationsViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:nil image:[UIImage imageNamed:@"TabBarChatGrey"] tag:3];
    self.conversationsViewController.tabBarItem.imageInsets = iconInset;
    self.conversationsViewController.accessibilityLabel = TwinmeLocalizedString(@"conversations_view_controller_title", nil);
    
    UIImage *image = self.hasPendingNotifications ? [UIImage imageNamed:@"TabBarNotificationBadgeGrey"] : [UIImage imageNamed:@"TabBarNotificationGrey"];
    UIImage *selectedImage = self.hasPendingNotifications ? [self notificationBadgeImage] : [UIImage imageNamed:@"TabBarNotificationBlue"];
    
    self.notificationsViewController.tabBarItem.image = image;
    self.notificationsViewController.tabBarItem.selectedImage = selectedImage;
    self.notificationsViewController.accessibilityLabel = TwinmeLocalizedString(@"application_notifications", nil);
    
    [[UITextField appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setTintColor:Design.FONT_COLOR_DEFAULT];
}

- (void)updateTabBarAppearance {
    DDLogVerbose(@"%@ updateTabBarAppearance", LOG_TAG);
    
    [self.tabBar setTintColor:Design.MAIN_COLOR];
    [self.tabBar setUnselectedItemTintColor:Design.UNSELECTED_TAB_COLOR];
    
    if (@available(iOS 15.0, *)) {
        UITabBarAppearance *tabBarAppearance = [self.tabBar standardAppearance];
        [tabBarAppearance configureWithOpaqueBackground];
        tabBarAppearance.backgroundColor = Design.WHITE_COLOR;
        
        UITabBarItemAppearance *tabBarItemAppearance = [tabBarAppearance compactInlineLayoutAppearance];
        tabBarItemAppearance.selected.iconColor = Design.MAIN_COLOR;
        tabBarItemAppearance.normal.iconColor = Design.UNSELECTED_TAB_COLOR;
        
        UITabBarItemAppearance *tabBarItemInlineAppearance = [tabBarAppearance inlineLayoutAppearance];
        tabBarItemInlineAppearance.selected.iconColor = Design.MAIN_COLOR;
        tabBarItemInlineAppearance.normal.iconColor = Design.UNSELECTED_TAB_COLOR;
        
        UITabBarItemAppearance *tabBarItemStackedAppearance = [tabBarAppearance stackedLayoutAppearance];
        tabBarItemStackedAppearance.selected.iconColor = Design.MAIN_COLOR;
        tabBarItemStackedAppearance.normal.iconColor = Design.UNSELECTED_TAB_COLOR;
        
        self.tabBar.standardAppearance = tabBarAppearance;
        self.tabBar.scrollEdgeAppearance = tabBarAppearance;
    }
    
    [self.tabBar setTranslucent:NO];
    
    self.tabBar.barTintColor = Design.WHITE_COLOR;
}

@end

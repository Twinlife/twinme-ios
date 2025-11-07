/*
 *  Copyright (c) 2018-2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 *   Stephane Carrez (Stephane.Carrez@twin.life)
 */

#import <CocoaLumberjack.h>

#import <TwinmeCommon/AbstractTwinmeViewController.h>
#import "ShowContactViewController.h"
#import "ShowGroupViewController.h"
#import "ShowRoomViewController.h"

#import <Twinme/TLSpace.h>
#import <Twinme/TLContact.h>

#import <TwinmeCommon/ApplicationDelegate.h>
#import <TwinmeCommon/MainViewController.h>
#import <TwinmeCommon/TwinmeNavigationController.h>
#import <TwinmeCommon/AbstractTwinmeService.h>

#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/Utils.h>

#import "LastVersionManager.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static CGFloat DESIGN_LEFT_BUTTON_WIDTH = 70.0;
static CGFloat DESIGN_LEFT_BUTTON_HEIGHT = 44.0;
static CGFloat DESIGN_AVATAR_HEIGHT = 36.0;
static CGFloat DESIGN_UPDATE_VERSION_HEIGHT = 12.0;
static CGFloat DESIGN_UPDATE_VERSION_MARGIN = 4.0;

//
// Interface: AbstractTwinmeViewController ()
//

@interface AbstractTwinmeViewController ()

@property (nonatomic) NSString *navigationBarTitle;

@property BOOL isAppear;

@end

//
// Implementation: AbstractTwinmeViewController
//

#undef LOG_TAG
#define LOG_TAG @"AbstractTwinmeViewController"

@implementation AbstractTwinmeViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _navigationBarTitle = @"";
        _isAppear = NO;
        
        ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
        _twinmeApplication = [delegate twinmeApplication];
        _twinmeContext = [delegate twinmeContext];
        
        [self setModalPresentationStyle:UIModalPresentationFullScreen];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    
    if (self.navigationBarTitle) {
        self.navigationItem.title = self.navigationBarTitle;
    }
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    [self updateFont];
    [self updateColor];
    [self updateInCall];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.navigationItem.title = @"";
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.isAppear = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if (self.isAppear && (self.isMovingFromParentViewController || self.isBeingDismissed)) {
        [self finish];
    }
    
    self.isAppear = NO;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    
    if (self.twinmeApplication.displayMode == DisplayModeSystem) {
        [Design setupColors];
    }
    
    [self updateColor];
    [self updateFont];
}

- (BOOL)adjustStatusBarAppearance {
    
    return NO;
}

- (BOOL)darkStatusBar {
    
    if ([self adjustStatusBarAppearance]) {
        BOOL darkMode = NO;
        DisplayMode displayMode = self.twinmeApplication.displayMode;
         switch (displayMode) {
             case DisplayModeSystem:
                 if (@available(iOS 13.0, *)) {
                     if ([UIScreen mainScreen].traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark){
                         darkMode = YES;
                     }
                 }
                 break;
                 
             case DisplayModeDark:
                 darkMode = YES;
                 break;
             default:
                 break;
         }
        
        return !darkMode;
    }
    
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    
    return UIStatusBarStyleLightContent;
}

- (BOOL)hidesBottomBarWhenPushed {
    
    return self.navigationController.viewControllers.count > 1;
}

- (void)updateFont {
    
}

- (void)updateColor {
    
}

- (void)updateInCall {
    
}

- (void)setNavigationTitle:(NSString *)title {
    
    self.navigationBarTitle = title;
    
    if (self.navigationBarTitle) {
        self.navigationItem.title = self.navigationBarTitle;
    }
}

- (TLSpace *)currentSpace {
    
    ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
    return delegate.mainViewController.space;
}

- (TLProfile *)defaultProfile {
    
    ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
    return delegate.mainViewController.profile;
}

- (BOOL)hasCurrentSpaceNotification {
    
    ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
    return [delegate.mainViewController hasCurrentSpaceNotification];
}

- (void)openSideMenu:(BOOL)animated {
    
    ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate.mainViewController openSideMenu:animated];
}

- (void)handleLeftAvatarTapGesture:(UITapGestureRecognizer *)sender {
    
    [self openSideMenu:YES];
}

- (void)setLeftBarButtonItem:(nonnull AbstractTwinmeService *)service profile:(nonnull TLProfile *)profile {
    DDLogVerbose(@"%@ setLeftBarButtonItem: %@", LOG_TAG, profile);

    [service getImageWithProfile:profile withBlock:^(UIImage *image) {
        [self setLeftBarButtonItem:image];
    }];
}

- (void)setLeftBarButtonItem:(UIImage *)avatar {
    
    CGFloat customLeftViewWidth = DESIGN_LEFT_BUTTON_WIDTH * Design.WIDTH_RATIO;
    UIView *customLeftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, customLeftViewWidth, DESIGN_LEFT_BUTTON_HEIGHT)];
    customLeftView.userInteractionEnabled = YES;
    UITapGestureRecognizer *leftAvatarGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleLeftAvatarTapGesture:)];
    [customLeftView addGestureRecognizer:leftAvatarGestureRecognizer];
    customLeftView.isAccessibilityElement = YES;
    
    UIImageView *avatarImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, DESIGN_AVATAR_HEIGHT, DESIGN_AVATAR_HEIGHT)];
    avatarImageView.clipsToBounds = YES;
    avatarImageView.userInteractionEnabled = YES;
    avatarImageView.layer.cornerRadius = DESIGN_AVATAR_HEIGHT * 0.5;
    avatarImageView.image = avatar;
    [customLeftView addSubview:avatarImageView];
    avatarImageView.center = CGPointMake(customLeftView.frame.size.width * 0.5, customLeftView.frame.size.height * 0.5);
    
    if ([self.twinmeApplication.lastVersionManager isNewVersionAvailable]) {
        UIView *updateVersionView = [[UIView alloc]initWithFrame:CGRectMake(customLeftViewWidth - DESIGN_UPDATE_VERSION_HEIGHT, DESIGN_UPDATE_VERSION_MARGIN, DESIGN_UPDATE_VERSION_HEIGHT, DESIGN_UPDATE_VERSION_HEIGHT)];
        updateVersionView.backgroundColor = Design.DELETE_COLOR_RED;
        updateVersionView.clipsToBounds = YES;
        updateVersionView.layer.cornerRadius = DESIGN_UPDATE_VERSION_HEIGHT * 0.5;
        [customLeftView addSubview:updateVersionView];
    }
    
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:customLeftView];
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
}

- (void)showContactWithContact:(nonnull TLContact *)contact popToRoot:(BOOL)popToRoot {
    DDLogVerbose(@"%@ showContactWithContact: %@", LOG_TAG, contact);
    
    UIViewController* viewController;
    if (contact.isTwinroom) {
        ShowRoomViewController *showRoomViewController = [[UIStoryboard storyboardWithName:@"Room" bundle:nil] instantiateViewControllerWithIdentifier:@"ShowRoomViewController"];
        [showRoomViewController initWithRoom:contact];
        viewController = showRoomViewController;
    } else {
        ShowContactViewController *showContactViewController = [[UIStoryboard storyboardWithName:@"Contact" bundle:nil] instantiateViewControllerWithIdentifier:@"ShowContactViewController"];
        [showContactViewController initWithContact:contact];
        viewController = showContactViewController;
    }
        
    if (self.navigationController && !popToRoot) {
        [self.navigationController pushViewController:viewController animated:YES];
    } else {
        ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
        MainViewController *mainViewController = delegate.mainViewController;
        TwinmeNavigationController *selectedNavigationController = mainViewController.selectedViewController;
        
        [CATransaction begin];
        [CATransaction setCompletionBlock:^{
            [selectedNavigationController pushViewController:viewController animated:YES];
        }];
        [selectedNavigationController popToRootViewControllerAnimated:YES];
        [CATransaction commit];
    }
}

- (void)showGroupWithGroup:(nonnull TLGroup *)group{
    DDLogVerbose(@"%@ showGroupWithGroup: %@", LOG_TAG, group);
    
    ShowGroupViewController *showGroupViewController = [[UIStoryboard storyboardWithName:@"Group" bundle:nil] instantiateViewControllerWithIdentifier:@"ShowGroupViewController"];
    [showGroupViewController initWithGroup:group];
    
    if (self.navigationController) {
        [self.navigationController pushViewController:showGroupViewController animated:YES];
    } else {
        ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
        MainViewController *mainViewController = delegate.mainViewController;
        TwinmeNavigationController *selectedNavigationController = mainViewController.selectedViewController;
        
        [CATransaction begin];
        [CATransaction setCompletionBlock:^{
            [selectedNavigationController pushViewController:showGroupViewController animated:YES];
        }];
        [selectedNavigationController popToRootViewControllerAnimated:YES];
        [CATransaction commit];
    }
}

- (void)hapticFeedBack:(UIImpactFeedbackStyle)style {
    DDLogVerbose(@"%@ hapticFeedBack: %ld", LOG_TAG, style);

    [Utils hapticFeedback:style hapticFeedbackMode:self.twinmeApplication.hapticFeedbackMode];
}

- (void)finish {
    
}

@end

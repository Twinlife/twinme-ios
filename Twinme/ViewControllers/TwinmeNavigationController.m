/*
 *  Copyright (c) 2019-2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <TwinmeCommon/TwinmeNavigationController.h>

#import <TwinmeCommon/Design.h>

#import <TwinmeCommon/ApplicationDelegate.h>
#import <TwinmeCommon/TwinmeApplication.h>

//
// Interface: TwinmeNavigationController ()
//

@interface TwinmeNavigationController () <UINavigationControllerDelegate, UINavigationBarDelegate>

@end

//
// Implementation: TwinmeNavigationController
//

@implementation TwinmeNavigationController

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    
    self = [super initWithRootViewController:rootViewController];
    
    self.interactivePopGestureRecognizer.enabled = YES;
    
    [self setModalPresentationStyle:UIModalPresentationFullScreen];
    
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setNavigationBarStyle];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self setNavigationBarStyle];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    
    return UIStatusBarStyleLightContent;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    
    ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
    TwinmeApplication *twinmeApplication = [delegate twinmeApplication];
    if (twinmeApplication.displayMode == DisplayModeSystem) {
        [Design setupColors];
    }
    [self setNavigationBarStyle];
}

- (void)setNavigationBarStyle {
    
    [self updateNavigationBar:Design.NAVIGATION_BAR_BACKGROUND_COLOR];
}

- (void)setNavigationBarStyle:(UIColor *)backgroundColor {
 
    [self updateNavigationBar:backgroundColor];
}

- (void)updateNavigationBar:(UIColor *)backgroundColor {
    
    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *navBarAppearance = [self.navigationBar standardAppearance];
        [navBarAppearance configureWithOpaqueBackground];
        navBarAppearance.titleTextAttributes = @{NSFontAttributeName: Design.FONT_BOLD34, NSForegroundColorAttributeName: [UIColor whiteColor]};
        navBarAppearance.largeTitleTextAttributes = @{NSFontAttributeName: Design.FONT_BOLD68, NSForegroundColorAttributeName: [UIColor whiteColor]};
        navBarAppearance.backgroundColor = backgroundColor;
        navBarAppearance.shadowColor = [UIColor clearColor];
        self.navigationBar.standardAppearance = navBarAppearance;
        self.navigationBar.scrollEdgeAppearance = navBarAppearance;
        self.navigationBar.compactAppearance = navBarAppearance;
        self.navigationBar.tintColor = [UIColor whiteColor];
    } else {
        self.navigationBar.translucent = NO;
        self.navigationBar.barTintColor = backgroundColor;
        self.navigationBar.tintColor = [UIColor whiteColor];
        self.navigationBar.backgroundColor = backgroundColor;
        [self.navigationBar setLargeTitleTextAttributes:@{NSFontAttributeName: Design.FONT_BOLD68, NSForegroundColorAttributeName: [UIColor whiteColor]}];
        
        [self.navigationBar setTitleTextAttributes:@{NSFontAttributeName: Design.FONT_BOLD34, NSForegroundColorAttributeName: [UIColor whiteColor]}];
    }
}

@end

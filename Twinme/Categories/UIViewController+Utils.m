/*
 *  Copyright (c) 2018-2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 *   Christian Jacquemot (Christian.Jacquemot@twinlife-systems.com)
 */

#import <CocoaLumberjack.h>

#import <TwinmeCommon/UIViewController+Utils.h>

#import <TwinmeCommon/MainViewController.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Implementation: UIViewController (Utils)
//

#undef LOG_TAG
#define LOG_TAG @"UIViewController+Utils"

@implementation UIViewController (Utils)

+ (UIWindow *)currentWindow {
    DDLogVerbose(@"%@ currentWindow", LOG_TAG);

    for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
        if (scene.activationState == UISceneActivationStateForegroundActive && [scene isKindOfClass:[UIWindowScene class]]) {
            UIWindowScene *windowScene = (UIWindowScene *)scene;
            for (UIWindow *window in windowScene.windows) {
                if (window.isKeyWindow) {
                    return window;
                }
            }
        }
    }

    for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
        if ([scene isKindOfClass:[UIWindowScene class]]) {
            UIWindowScene *windowScene = (UIWindowScene *)scene;
            if (windowScene.windows.count > 0) {
                return windowScene.windows.firstObject;
            }
        }
    }

    return nil;
}

+ (UIViewController *)topViewController {
    DDLogVerbose(@"%@ topViewController", LOG_TAG);
    
    UIViewController *viewController = [UIViewController currentWindow].rootViewController;
    
    if ([viewController isKindOfClass:[MainViewController class]]) {
        MainViewController *mainViewController = (MainViewController *)viewController;
        return [UIViewController topViewController:(UIViewController *)mainViewController.selectedViewController];
    } else {
        return [UIViewController topViewController:viewController];
    }
}

- (BOOL)hasLandscapeMode {
    DDLogVerbose(@"%@ hasLandscapeMode", LOG_TAG);
    
    return NO;
}

#pragma mark - Private methods

+ (UIViewController *)topViewController:(UIViewController *)viewController {
    DDLogVerbose(@"%@ topViewController: %@", LOG_TAG, viewController);
    
    if (viewController.presentedViewController) {
        return [UIViewController topViewController:viewController.presentedViewController];
    }
    
    if ([viewController isKindOfClass:[UISplitViewController class]]) {
        UISplitViewController *splitViewController = (UISplitViewController*)viewController;
        if (splitViewController.viewControllers.count > 0) {
            return [UIViewController topViewController:splitViewController.viewControllers.lastObject];
        }
        return viewController;
    }
    
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController*)viewController;
        if (navigationController.viewControllers.count > 0) {
            return [UIViewController topViewController:navigationController.topViewController];
        }
        return viewController;
    }
    
    if ([viewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarController = (UITabBarController*)viewController;
        if (tabBarController.viewControllers.count > 0) {
            return [UIViewController topViewController:tabBarController.selectedViewController];
        }
        return viewController;
    }
    
    return viewController;
}

@end

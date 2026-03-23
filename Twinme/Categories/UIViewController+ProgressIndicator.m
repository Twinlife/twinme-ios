/*
 *  Copyright (c) 2014-2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Zhuoyu Ma (Zhuoyu.Ma@twinlife-systems.com)
 *   Shiyi Gu (Shiyi.Gu@twinlife-systems.com)
 *   Christian Jacquemot (Christian.Jacquemot@twinlife-systems.com)
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <objc/runtime.h>

#import "UIViewController+ProgressIndicator.h"

#import <TwinmeCommon/ApplicationDelegate.h>
#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/TwinmeApplication.h>

#import <Twinme/TLTwinmeContext.h>

static const char IndicatorKey;

//
// Implementation: UIViewController (ProgressIndicator)
//

@implementation UIViewController (ProgressIndicator)

- (void)showProgressIndicator {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIActivityIndicatorView *indicatorView = objc_getAssociatedObject(self, &IndicatorKey);
        if (indicatorView) {
            return;
        }
        
        ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
        TwinmeApplication *twinmeApplication = [delegate twinmeApplication];
        
        if (@available(iOS 13.0, *)) {
            indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
        } else {
            indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        }
        
        if ([twinmeApplication darkModeEnable:[[delegate twinmeContext] defaultSpaceSettings]]) {
            indicatorView.color = [UIColor whiteColor];
        }
                
        objc_setAssociatedObject(self, &IndicatorKey, indicatorView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        indicatorView.center = self.view.center;
        [self.view addSubview:indicatorView];
        [indicatorView startAnimating];
    });
}

- (void)hideProgressIndicator {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIActivityIndicatorView *indicatorView = objc_getAssociatedObject(self, &IndicatorKey);
        objc_setAssociatedObject(self, &IndicatorKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [indicatorView stopAnimating];
        [indicatorView removeFromSuperview];
    });
}

@end

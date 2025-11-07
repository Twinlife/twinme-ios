/*
 *  Copyright (c) 2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <TwinmeCommon/AbstractTwinmeViewController.h>

//
// Protocol: SuccessAuthentifiedRelationDelegate
//

@protocol SuccessAuthentifiedRelationDelegate <NSObject>

- (void)closeSuccessAuthentifiedRelation;

@end

//
// Interface: SuccessAuthentifiedRelationViewController
//

@interface SuccessAuthentifiedRelationViewController : AbstractTwinmeViewController

@property (weak, nonatomic) id<SuccessAuthentifiedRelationDelegate> successAuthentifiedRelationDelegate;

- (void)initWithName:(NSString *)name avatar:(UIImage *)avatar;

- (void)showInView:(UIViewController *)view;

@end

/*
 *  Copyright (c) 2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <UIKit/UIKit.h>

#import <Twinme/TLSpace.h>

//
// Protocol: ShareExtensionSpaceDelegate
//

@protocol ShareExtensionSpaceDelegate <NSObject>

- (void)didSelectSpace:(TLSpace *)space;

@end

//
// Interface: ShareExtensionSpaceViewController
//

@interface ShareExtensionSpaceViewController : UIViewController

@property (weak, nonatomic) id<ShareExtensionSpaceDelegate> shareExtensionSpaceDelegate;

- (void)initWithSpaces:(NSMutableArray *)spaces;

@end

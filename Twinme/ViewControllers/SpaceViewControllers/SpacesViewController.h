/*
 *  Copyright (c) 2019-2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <TwinmeCommon/AbstractTwinmeViewController.h>

@class UISpace;

//
// Protocol: SpacesPickerDelegate
//

@protocol SpacesPickerDelegate <NSObject>

- (void)didSelectSpace:(TLSpace *)space;

@end

//
// Protocol: SpaceActionDelegate
//

@protocol SpaceActionDelegate <NSObject>

- (void)showSpace:(UISpace *)uiSpace;

- (void)activeSpace:(UISpace *)uiSpace;

@end

//
// Interface: SpacesViewController
//

@class TLContact;
@class TLGroup;

@interface SpacesViewController : AbstractTwinmeViewController

@property (weak, nonatomic) id<SpacesPickerDelegate> spacesPickerDelegate;
@property (nonatomic) BOOL pickerMode;

- (void)initWithContact:(TLContact *)contact;

- (void)initWithGroup:(TLGroup *)group;

@end

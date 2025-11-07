/*
 *  Copyright (c) 2020-2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <TwinmeCommon/Design.h>

//
// Interface: CustomAppearance
//

@class TLSpaceSettings;

@interface CustomAppearance : NSObject

- (instancetype)initWithSpaceSettings:(TLSpaceSettings *)spaceSettings;

- (TLSpaceSettings *)getSpaceSettings;

- (DisplayMode)getCurrentMode;

- (UIColor *)getMainColor;

- (UIColor *)getConversationBackgroundColor;

- (UIColor *)getConversationBackgroundDefaultColor;

- (UIColor *)getConversationBackgroundText;

- (UIColor *)getConversationBackgroundTextDefaultColor;

- (NSUUID *)getConversationBackgroundImageId;

- (NSUUID *)getConversationBackgroundImageId:(DisplayMode)mode;

- (UIColor *)getMessageBackgroundColor;

- (UIColor *)getMessageBackgroundDefaultColor;

- (UIColor *)getPeerMessageBackgroundColor;

- (UIColor *)getPeerMessageBackgroundDefaultColor;

- (UIColor *)getMessageBorderColor;

- (UIColor *)getMessageBorderDefaultColor;

- (UIColor *)getPeerMessageBorderColor;

- (UIColor *)getPeerMessageBorderDefaultColor;

- (UIColor *)getMessageTextColor;

- (UIColor *)getMessageTextDefaultColor;

- (UIColor *)getPeerMessageTextColor;

- (UIColor *)getPeerMessageTextDefaultColor;

- (void)setCurrentMode:(DisplayMode)mode;

- (void)setMainColor:(NSString *)color;

- (void)setDefaultMessageBackgroundColor:(UIColor *)color;

- (void)setConversationBackgroundColor:(UIColor *)color;

- (void)setConversationBackgroundImageId:(NSUUID *)imageId;

- (void)setConversationBackgroundText:(UIColor *)color;

- (void)setMessageBackgroundColor:(UIColor *)color;

- (void)setPeerMessageBackgroundColor:(UIColor *)color;

- (void)setMessageBorderColor:(UIColor *)color;

- (void)setPeerMessageBorderColor:(UIColor *)color;

- (void)setMessageTextColor:(UIColor *)color;

- (void)setPeerMessageTextColor:(UIColor *)color;

- (void)resetToDefaultValues;

- (UIImage *)createImageWithColor:(UIColor *)color;

@end

/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */


typedef enum {
    HelpItemTypeGettingStarted,
    HelpItemTypeFAQ,
    HelpItemTypeBlog,
    HelpItemTypeFeedback,
    HelpItemTypeWelcome,
    HelpItemTypeProfile,
    HelpItemTypeCertifiedRelation,
    HelpItemTypeQualityOfServices,
    HelpItemTypeAccountTransfer,
    HelpItemTypeAdditionalFunctions,
    HelpItemTypeSpaces,
    HelpItemTypeClickToCall,
    HelpItemTypeBackup,
    HelpItemTypeProxy
} HelpItemType;

//
// Interface: UIHelpItem
//

@interface UIHelpItem : NSObject

@property (nonatomic) HelpItemType helpItemType;
@property (nonatomic, nonnull) NSString *title;
@property (nonatomic, nullable) UIImage *icon;

- (nonnull instancetype)initWithType:(HelpItemType)helpItemType;

@end

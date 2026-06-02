/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */


typedef enum {
    HelpSectionTypeGeneral,
    HelpSectionTypeStandardServices,
    HelpSectionTypePremiumServices,
    HelpSectionTypeAdvancedServices
} HelpSectionType;

//
// Interface: UIHelpSection
//

@class UIHelpItem;

@interface UIHelpSection : NSObject

@property (nonatomic) HelpSectionType helpSectionType;
@property (nonatomic, nonnull) NSString *title;
@property (nonatomic, nonnull) NSMutableArray<UIHelpItem *> *items;

- (nonnull instancetype)initWithType:(HelpSectionType)helpSectionType;

@end

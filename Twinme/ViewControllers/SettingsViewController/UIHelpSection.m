/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "UIHelpSection.h"

#import "UIHelpItem.h"

#import <Utils/NSString+Utils.h>

//
// Interface: UIHelpSection ()
//

@interface UIHelpSection ()

@end

//
// Implementation: UIHelpSection
//

@implementation UIHelpSection

- (nonnull instancetype)initWithType:(HelpSectionType)helpSectionType {
    
    self = [super init];
    
    if (self) {
        _helpSectionType = helpSectionType;
        _items = [[NSMutableArray alloc]init];
        [self initInfo];
    }
    return self;
}

- (void)initInfo {
    
    switch (self.helpSectionType) {
        case HelpSectionTypeGeneral:
            self.title = @"";
            [self.items addObject:[[UIHelpItem alloc] initWithType:HelpItemTypeFAQ]];
            [self.items addObject:[[UIHelpItem alloc] initWithType:HelpItemTypeBlog]];
            [self.items addObject:[[UIHelpItem alloc] initWithType:HelpItemTypeFeedback]];
            break;
            
        case HelpSectionTypeStandardServices:
            self.title = NSLocalizedString(@"help_view_standard_services", @"");
            [self.items addObject:[[UIHelpItem alloc] initWithType:HelpItemTypeWelcome]];
            [self.items addObject:[[UIHelpItem alloc] initWithType:HelpItemTypeProfile]];
            [self.items addObject:[[UIHelpItem alloc] initWithType:HelpItemTypeCertifiedRelation]];
            [self.items addObject:[[UIHelpItem alloc] initWithType:HelpItemTypeQualityOfServices]];
            [self.items addObject:[[UIHelpItem alloc] initWithType:HelpItemTypeAccountTransfer]];
            break;
            
        case HelpSectionTypePremiumServices:
            self.title = NSLocalizedString(@"about_view_premium_services", @"");
            [self.items addObject:[[UIHelpItem alloc] initWithType:HelpItemTypeAdditionalFunctions]];
            [self.items addObject:[[UIHelpItem alloc] initWithType:HelpItemTypeSpaces]];
            [self.items addObject:[[UIHelpItem alloc] initWithType:HelpItemTypeClickToCall]];
            break;
            
        case HelpSectionTypeAdvancedServices:
            self.title = NSLocalizedString(@"help_view_advanced_functions", @"");
            [self.items addObject:[[UIHelpItem alloc] initWithType:HelpItemTypeBackup]];
            [self.items addObject:[[UIHelpItem alloc] initWithType:HelpItemTypeProxy]];
            break;
            
        default:
            self.title = @"";
            break;
    }
}

@end

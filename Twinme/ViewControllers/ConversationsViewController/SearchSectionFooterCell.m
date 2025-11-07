/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "SearchSectionFooterCell.h"

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: SearchSectionFooterCell
//

@interface SearchSectionFooterCell()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@end

//
// Implementation: SearchSectionFooterCell
//

#undef LOG_TAG
#define LOG_TAG @"SearchSectionFooterCell"

@implementation SearchSectionFooterCell

- (void)awakeFromNib {
    DDLogVerbose(@"%@ awakeFromNib", LOG_TAG);
    
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.contentView.backgroundColor = Design.WHITE_COLOR;
    
    self.separatorViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.separatorViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.separatorViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.separatorView.backgroundColor = Design.ITEM_BORDER_COLOR;
}

@end

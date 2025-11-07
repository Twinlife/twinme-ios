/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "SearchSectionCell.h"
#import "ConversationsViewController.h"
#import "UICustomTab.h"

#import <TwinmeCommon/Design.h>

#import <Utils/NSString+Utils.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: SearchSectionCell
//

@interface SearchSectionCell()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLeadingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *allLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *allLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *allLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *allViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *allViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *allView;

@property (nonatomic) UICustomTab *customTab;

@end

//
// Implementation: SearchSectionCell
//

#undef LOG_TAG
#define LOG_TAG @"SearchSectionCell"

@implementation SearchSectionCell

- (void)awakeFromNib {
    DDLogVerbose(@"%@ awakeFromNib", LOG_TAG);
    
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.contentView.backgroundColor = Design.WHITE_COLOR;
    
    self.titleWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.titleLeadingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.title.font = Design.FONT_BOLD34;
    self.title.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.allLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.allLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.allLabel.font = Design.FONT_BOLD34;
    self.allLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.allLabel.text = TwinmeLocalizedString(@"application_display", nil);
    
    if ([[UIApplication sharedApplication] userInterfaceLayoutDirection] == UIUserInterfaceLayoutDirectionRightToLeft) {
        self.allLabel.textAlignment = NSTextAlignmentLeft;
    }
    
    self.allViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.allViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleRightTapGesture:)];
    [self.allView addGestureRecognizer:tapGestureRecognizer];
}

- (void)bindWithSearchFilter:(UICustomTab *)customTab showAllAction:(BOOL)showAllAction {
    DDLogVerbose(@"%@ bindWithSearchFilter: %@", LOG_TAG, customTab);
    
    self.customTab = customTab;
    self.title.text = self.customTab.title;
    
    self.allLabel.hidden = !showAllAction;
    self.allView.hidden = !showAllAction;
        
    [self updateFont];
    [self updateColor];
}

- (void)handleRightTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleRightTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded && [self.searchSectionDelegate respondsToSelector:@selector(didTapAll:)]) {
        [self.searchSectionDelegate didTapAll:self.customTab.tag];
    }
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.title.font = Design.FONT_BOLD34;
    self.allLabel.font = Design.FONT_BOLD34;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.contentView.backgroundColor = Design.WHITE_COLOR;
    self.title.textColor = Design.FONT_COLOR_DEFAULT;
    self.allLabel.textColor = Design.FONT_COLOR_DEFAULT;
}

@end

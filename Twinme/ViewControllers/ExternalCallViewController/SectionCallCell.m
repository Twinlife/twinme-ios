/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "SectionCallCell.h"

#import <TwinmeCommon/Design.h>

#import <Utils/NSString+Utils.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: SectionCallCell
//

@interface SectionCallCell()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleBottomConstraint;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightTitleWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightTitleTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightTitleBottomConstraint;
@property (weak, nonatomic) IBOutlet UILabel *rightTitle;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *rightView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@end

//
// Implementation: SectionCallCell
//

#undef LOG_TAG
#define LOG_TAG @"SectionCallCell"

@implementation SectionCallCell

- (void)awakeFromNib {
    DDLogVerbose(@"%@ awakeFromNib", LOG_TAG);
    
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.contentView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    
    self.titleWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.titleLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.titleBottomConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.title.font = Design.FONT_BOLD26;
    self.title.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.rightTitleWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.rightTitleTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.rightTitleBottomConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.rightTitle.font = Design.FONT_BOLD26;
    self.rightTitle.textColor = Design.MAIN_COLOR;
    self.rightTitle.text = TwinmeLocalizedString(@"application_display", nil).uppercaseString
    ;
    
    if ([[UIApplication sharedApplication] userInterfaceLayoutDirection] == UIUserInterfaceLayoutDirectionRightToLeft) {
        self.rightTitle.textAlignment = NSTextAlignmentLeft;
    }
    
    self.rightViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.rightViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleRightTapGesture:)];
    [self.rightView addGestureRecognizer:tapGestureRecognizer];
    
    self.separatorViewHeightConstraint.constant = Design.SEPARATOR_HEIGHT;
    self.separatorView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
}

- (void)bindWithTitle:(NSString *)title hideSeparator:(BOOL)hideSeparator uppercaseString:(BOOL)uppercaseString showRightAction:(BOOL)showRightAction {
    DDLogVerbose(@"%@ bindWithTitle: %@", LOG_TAG, title);
    
    if (uppercaseString) {
        self.title.text = title.uppercaseString;
    } else {
        self.title.text = title;
    }
    
    self.rightTitle.hidden = !showRightAction;
    self.rightView.hidden = !showRightAction;
    
    self.separatorView.hidden = hideSeparator;
    
    [self updateFont];
    [self updateColor];
}

- (void)handleRightTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleRightTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded && [self.sectionCallDelegate respondsToSelector:@selector(didTapRight)]) {
        [self.sectionCallDelegate didTapRight];
    }
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.title.font = Design.FONT_BOLD26;
    self.rightTitle.font = Design.FONT_BOLD26;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.contentView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    self.title.textColor = Design.FONT_COLOR_DEFAULT;
    self.rightTitle.textColor = Design.MAIN_COLOR;
    self.separatorView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
}

@end

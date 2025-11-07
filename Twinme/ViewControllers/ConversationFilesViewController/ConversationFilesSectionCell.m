/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "ConversationFilesSectionCell.h"

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: ConversationFilesSectionCell
//

@interface ConversationFilesSectionCell()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleBottomConstraint;
@property (weak, nonatomic) IBOutlet UILabel *title;

@end

//
// Implementation: ConversationFilesSectionCell
//

#undef LOG_TAG
#define LOG_TAG @"ConversationFilesSectionCell"

@implementation ConversationFilesSectionCell

- (void)awakeFromNib {
    DDLogVerbose(@"%@ awakeFromNib", LOG_TAG);
    
    [super awakeFromNib];
        
    self.contentView.backgroundColor = Design.WHITE_COLOR;
    
    self.titleLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.titleTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.titleBottomConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.title.font = Design.FONT_BOLD26;
    self.title.textColor = Design.FONT_COLOR_DEFAULT;
}

- (void)bindWithTitle:(NSString *)title {
    DDLogVerbose(@"%@ bindWithTitle: %@", LOG_TAG, title);
    
    self.title.text = title;
    
    [self updateFont];
    [self updateColor];
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.title.font = Design.FONT_BOLD26;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.title.textColor = Design.FONT_COLOR_DEFAULT;
    self.contentView.backgroundColor = Design.WHITE_COLOR;
}

@end

/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "WordCompletionCell.h"

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: WordCompletionCell ()
//

@interface WordCompletionCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *wordLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *wordLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *wordLabel;

@end

//
// Implementation: WordCompletionCell
//

#undef LOG_TAG
#define LOG_TAG @"WordCompletionCell"

@implementation WordCompletionCell

- (void)awakeFromNib {
    DDLogVerbose(@"%@ awakeFromNib", LOG_TAG);
    
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = Design.WHITE_COLOR;
    
    self.wordLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.wordLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.wordLabel.font = [Design getBackupWordFont];;
    self.wordLabel.textColor = Design.FONT_COLOR_DEFAULT;
}

- (void)bindWithWord:(NSString *)word backgroundColor:(UIColor *)backgroundColor {
    DDLogVerbose(@"%@ bindWithWord: %@ backgroundColor: %@", LOG_TAG, word, backgroundColor);
    
    self.contentView.backgroundColor = backgroundColor;
    self.wordLabel.text = word.uppercaseString;
}


@end

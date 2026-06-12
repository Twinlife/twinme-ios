/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "UIPollResult.h"

#import <Twinlife/TLConversationService.h>

//
// Implementation: UIPollResult
//

@implementation UIPollResult

- (nonnull instancetype)initWithChoice:(nonnull TLChoice *)choice {
    self = [super init];
    
    if (self) {
        self.choice = choice;
        self.count = 0;
        self.isSelected = NO;
        self.voters = [[NSMutableArray alloc]init];
    }
    return self;
}

- (nonnull NSString *)getChoiceLabel {
    
    return self.choice.label;
}

- (void)calculateChoiceHeightWithMaxWidth:(CGFloat)maxWidth font:(nonnull UIFont *)font {
    
    if (maxWidth <= 0.0) {
        self.choiceHeight = ceil(font.lineHeight);
        return;
    }
    
    NSString *choiceLabel = [self getChoiceLabel];
    if (choiceLabel.length == 0) {
        self.choiceHeight = ceil(font.lineHeight);
        return;
    }
    
    CGSize constraintSize = CGSizeMake(maxWidth, CGFLOAT_MAX);
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    
    CGRect choiceLabelRect = [choiceLabel boundingRectWithSize:constraintSize
                                                       options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                    attributes:@{NSFontAttributeName: font, NSParagraphStyleAttributeName: paragraphStyle}
                                                       context:nil];
    self.choiceHeight = ceil(MAX(font.lineHeight, CGRectGetHeight(choiceLabelRect)));
}

@end

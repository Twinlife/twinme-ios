/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "UIMenuSelectValueItem.h"

#import <TwinmeCommon/Design.h>

//
// Implementation: UIMenuSelectValueItem
//

@implementation UIMenuSelectValueItem

- (nonnull instancetype)initWithTitle:(nonnull NSString *)title subTitle:(nullable NSString *)subTitle {
    
    self = [super init];
    
    if (self) {
        self.title = title;
        self.subTitle = subTitle;
    }
    return self;
    
}

- (void)calculateValueHeightWithMaxWidth:(CGFloat)maxWidth margin:(CGFloat)margin {
    
    if (maxWidth <= 0.0) {
        self.valueHeight = Design.SETTING_CELL_HEIGHT;
        return;
    }
    
    if (self.title.length == 0) {
        self.valueHeight = Design.SETTING_CELL_HEIGHT;
        return;
    }
    
    CGSize constraintSize = CGSizeMake(maxWidth, CGFLOAT_MAX);
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    
    NSMutableAttributedString *valueAttributedString = [[NSMutableAttributedString alloc] initWithString:self.title attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_REGULAR34, NSFontAttributeName, nil]];
    
    if (self.subTitle && ![self.subTitle isEqualToString:@""]) {
        [valueAttributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n"]];
        [valueAttributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:self.subTitle attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_REGULAR30, NSFontAttributeName, nil]]];
    }
    
    [valueAttributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, valueAttributedString.length)];
    
    CGRect valueLabelRect = [valueAttributedString boundingRectWithSize:constraintSize
                                                       options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                       context:nil];
    
    self.valueHeight = ceil(MAX(Design.SETTING_CELL_HEIGHT, CGRectGetHeight(valueLabelRect) + margin));
}

@end

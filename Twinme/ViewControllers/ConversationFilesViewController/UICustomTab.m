/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "UICustomTab.h"

#import <TwinmeCommon/Design.h>

static const CGFloat DESIGN_TAB_MARGIN_WIDTH = 16;
static const CGFloat DESIGN_TITLE_MARGIN_WIDTH = 28;
static const CGFloat DESIGN_TAB_MIN_WIDTH = 120;
static const CGFloat DESIGN_CELL_VIEW_HEIGHT = 68;

//
// Interface: UICustomTab ()
//

@interface UICustomTab ()

@end

//
// Implementation: UICustomTab
//

@implementation UICustomTab

- (nonnull instancetype)initWithTitle:(nonnull NSString *)title tag:(int)tag isSelected:(BOOL)isSelected {
    
    self = [super init];
    
    if (self) {
        _title = title;
        _tag = tag;
        _isSelected = isSelected;
        _width = [self getWidth];
        _height = DESIGN_CELL_VIEW_HEIGHT * Design.HEIGHT_RATIO;
    }
    return self;
}

- (CGFloat)getWidth {
    
    CGRect titleRect = [self.title boundingRectWithSize:CGSizeMake(MAXFLOAT, DESIGN_CELL_VIEW_HEIGHT * Design.HEIGHT_RATIO) options:NSStringDrawingUsesFontLeading attributes:@{
        NSFontAttributeName : Design.FONT_REGULAR34
    } context:nil];
    
    CGFloat tabWidth = titleRect.size.width + (DESIGN_TITLE_MARGIN_WIDTH * Design.WIDTH_RATIO);
    CGFloat tabMinWidth = DESIGN_TAB_MIN_WIDTH * Design.WIDTH_RATIO;
    
    if (tabWidth < tabMinWidth) {
        tabWidth = tabMinWidth;
    }
        
    return tabWidth + (DESIGN_TAB_MARGIN_WIDTH * Design.WIDTH_RATIO);
}

@end

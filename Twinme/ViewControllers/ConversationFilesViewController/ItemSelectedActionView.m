/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Utils/NSString+Utils.h>

#import "ItemSelectedActionView.h"

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static const CGFloat DESIGN_VIEW_HEIGHT = 148;

//
// Interface: ItemSelectedActionView ()
//

@interface ItemSelectedActionView()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shareItemViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *shareItemView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shareItemImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *shareItemImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *deleteItemViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *deleteItemView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *deleteItemImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *deleteItemImageView;
@property (weak, nonatomic) IBOutlet UILabel *selectedLabel;

@property int selectedItemsCount;

@end

//
// Implementation: ItemSelectedActionView
//

#undef LOG_TAG
#define LOG_TAG @"ItemSelectedActionView"

@implementation ItemSelectedActionView

#pragma mark - UIView

- (instancetype)init {
    DDLogVerbose(@"%@ init", LOG_TAG);
    
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"ItemSelectedActionView" owner:self options:nil];
    self = [objects objectAtIndex:0];
    
    self.frame = CGRectMake(0, 0, Design.DISPLAY_WIDTH, DESIGN_VIEW_HEIGHT * Design.HEIGHT_RATIO);
    
    if (self) {
        _selectedItemsCount = 0;
        [self initViews];
    }
    
    return self;
}

- (void)updateSelectedItems:(int)count {
    DDLogVerbose(@"%@ updateSelectedItems: %d", LOG_TAG, count);
    
    self.selectedItemsCount = count;
    
    NSString *title;
    
    if (count == 0) {
        title = @"";
    } else if (count == 1) {
        title = TwinmeLocalizedString(@"application_one_item_selected", nil);
    } else {
        title = [NSString stringWithFormat:TwinmeLocalizedString(@"application_items_selected", nil), count];
    }
    
    self.selectedLabel.text = title;
    
    if (count == 0) {
        self.shareItemView.alpha = 0.5f;
        self.deleteItemView.alpha = 0.5f;
    } else {
        self.shareItemView.alpha = 1.0f;
        self.deleteItemView.alpha = 1.0f;
    }
}

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.backgroundColor = Design.NAVIGATION_BAR_BACKGROUND_COLOR;
    
    self.shareItemViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.shareItemView.userInteractionEnabled = YES;
    self.shareItemView.isAccessibilityElement = YES;
    
    UITapGestureRecognizer *tapShareGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleShareViewTapGesture:)];
    [self.shareItemView addGestureRecognizer:tapShareGesture];
    
    self.shareItemImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.shareItemImageView.tintColor = [UIColor whiteColor];
    
    self.deleteItemViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.deleteItemView.userInteractionEnabled = YES;
    self.deleteItemView.isAccessibilityElement = YES;
    
    self.deleteItemImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.deleteItemImageView.tintColor = [UIColor whiteColor];
    
    UITapGestureRecognizer *tapDeleteGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleDeleteViewTapGesture:)];
    [self.deleteItemView addGestureRecognizer:tapDeleteGesture];
    
    self.selectedLabel.textColor = [UIColor whiteColor];
    self.selectedLabel.font = Design.FONT_MEDIUM34;
    self.selectedLabel.text = @"";
}

- (void)handleShareViewTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleShareViewTapGesture: %@", LOG_TAG, sender);
    
    if (self.selectedItemsCount > 0 && sender.state == UIGestureRecognizerStateEnded) {
        if ([self.itemSelectedActionViewDelegate respondsToSelector:@selector(didTapShareAction)]) {
            [self.itemSelectedActionViewDelegate didTapShareAction];
        }
    }
}

- (void)handleDeleteViewTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleDeleteViewTapGesture: %@", LOG_TAG, sender);
    
    if (self.selectedItemsCount > 0 && sender.state == UIGestureRecognizerStateEnded) {
        if ([self.itemSelectedActionViewDelegate respondsToSelector:@selector(didTapDeleteAction)]) {
            [self.itemSelectedActionViewDelegate didTapDeleteAction];
        }
    }
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.selectedLabel.font = Design.FONT_MEDIUM34;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.backgroundColor = Design.NAVIGATION_BAR_BACKGROUND_COLOR;
}

@end

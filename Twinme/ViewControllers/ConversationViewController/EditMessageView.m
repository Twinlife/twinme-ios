/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "EditMessageView.h"

#import <TwinmeCommon/Design.h>
#import <Utils/NSString+Utils.h>

static CGFloat DESIGN_EDIT_HEIGHT = 60;
static CGFloat DESIGN_EDIT_WIDTH = 300;
static CGFloat DESIGN_DEFAULT_LEADING = 10;

//
// Interface: EditMessageView
//

@interface EditMessageView ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *editViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *editViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *editViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *editViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *editView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *editImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *editImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *editLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *editLabel;

@end

//
// Implementation: EditMessageView
//

@implementation EditMessageView

#pragma mark - UIView

- (instancetype)init {
    
    self = [super init];
    if (self) {
        [self initViews];
    }
    return self;
}

- (void)updateLeading:(CGFloat)leading top:(CGFloat)top width:(CGFloat)width {
    
    self.editViewLeadingConstraint.constant = leading + (DESIGN_DEFAULT_LEADING * Design.WIDTH_RATIO);
    self.editViewTopConstraint.constant = top;
    self.editViewWidthConstraint.constant = width - (DESIGN_DEFAULT_LEADING * Design.WIDTH_RATIO * 2);
}

#pragma mark - Private methods

- (void)initViews {
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"EditMessageView" owner:self options:nil];
    UIView *view = [objects objectAtIndex:0];
    
    if ([[UIApplication sharedApplication] userInterfaceLayoutDirection] == UIUserInterfaceLayoutDirectionRightToLeft) {
        view.frame = CGRectMake(Design.DISPLAY_WIDTH - DESIGN_EDIT_WIDTH * Design.WIDTH_RATIO, 0, DESIGN_EDIT_WIDTH * Design.WIDTH_RATIO, DESIGN_EDIT_HEIGHT * Design.HEIGHT_RATIO);
    } else {
        view.frame = CGRectMake(0, 0, DESIGN_EDIT_WIDTH * Design.WIDTH_RATIO, DESIGN_EDIT_HEIGHT * Design.HEIGHT_RATIO);
    }
    
    [self addSubview:[objects objectAtIndex:0]];
          
    self.editViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.editViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.editViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    [self.editView setBackgroundColor:Design.TEXTFIELD_CONVERSATION_BACKGROUND_COLOR];
    
    self.editImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.editImageView.tintColor = Design.FONT_COLOR_DEFAULT;
    
    self.editLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.editLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.editLabel.font = Design.FONT_MEDIUM30;
    self.editLabel.text = TwinmeLocalizedString(@"application_edit", nil);
}

- (void)updateColor {
    
    [self.editView setBackgroundColor:Design.TEXTFIELD_CONVERSATION_BACKGROUND_COLOR];
    self.editImageView.tintColor = Design.FONT_COLOR_DEFAULT;
    self.editLabel.textColor = Design.FONT_COLOR_DEFAULT;
}

@end

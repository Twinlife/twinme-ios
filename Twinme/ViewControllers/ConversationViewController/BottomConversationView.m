/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */


#import "BottomConversationView.h"

#import <TwinmeCommon/ApplicationDelegate.h>
#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/TwinmeApplication.h>

static CGFloat DESIGN_TOOLBAR_HEIGHT = 20;
static CGFloat TOOLBAR_HEIGHT;

//
// Interface: BottomConversationView ()
//

@interface BottomConversationView ()

@property (weak, nonatomic) NSLayoutConstraint *toolbarViewHeightConstraint;

@end

//
// Implementation: BottomConversationView
//

#undef LOG_TAG
#define LOG_TAG @"BottomConversationView"

@implementation BottomConversationView

#pragma mark - UIView

- (instancetype)init {
    
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"BottomConversationView" owner:self options:nil];
    self = [objects objectAtIndex:0];
        
    if (self) {
        [self initViews];
    }
    
    return self;
}

- (void)updateToolbarHeight:(BOOL)keyboardHidden {
    
    if (keyboardHidden) {
        ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
        CGFloat safeAreaBottom = delegate.window.safeAreaInsets.bottom;
        
        if (safeAreaBottom > 0) {
            TOOLBAR_HEIGHT = safeAreaBottom;
        } else {
            TOOLBAR_HEIGHT = (DESIGN_TOOLBAR_HEIGHT * Design.HEIGHT_RATIO);
        }
        
        self.toolbarViewHeightConstraint.constant = TOOLBAR_HEIGHT;
    } else {
        TOOLBAR_HEIGHT = (DESIGN_TOOLBAR_HEIGHT * Design.HEIGHT_RATIO);
        self.toolbarViewHeightConstraint.constant = TOOLBAR_HEIGHT;
    }
}

#pragma mark - Private methods

- (void)initViews {
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.backgroundColor = Design.WHITE_COLOR;
    
    ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
    CGFloat safeAreaBottom = delegate.window.safeAreaInsets.bottom;
    
    if (safeAreaBottom > 0) {
        TOOLBAR_HEIGHT = safeAreaBottom;
    } else {
        TOOLBAR_HEIGHT = (DESIGN_TOOLBAR_HEIGHT * Design.HEIGHT_RATIO);
    }
    
    self.toolbarViewHeightConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:TOOLBAR_HEIGHT];
    
    [self addConstraint:self.toolbarViewHeightConstraint];
    
}

@end

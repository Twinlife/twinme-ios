/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinlife/TLConversationService.h>

#import "AnnotationCell.h"
#import "ItemCell.h"

#import "UIReaction.h"
#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static const int DESIGN_ICON_FORWARDED_HEIGHT = 28;
static const int DESIGN_ICON_HEIGHT = 44;

//
// Interface: AnnotationCell ()
//

@interface AnnotationCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *annotationViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *annotationViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *annotationViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIView *annotationView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *annotationImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *annotationImageViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *annotationImageView;

@property (nonatomic) TLDescriptorId *descriptorId;

@end

//
// Implementation: AnnotationCell
//

#undef LOG_TAG
#define LOG_TAG @"AnnotationCell"

@implementation AnnotationCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    
    self.annotationViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.annotationViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.annotationViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.annotationView.clipsToBounds = YES;
    self.annotationView.userInteractionEnabled = YES;
    self.annotationView.layer.cornerRadius = self.annotationViewHeightConstraint.constant * 0.5f;
    self.annotationView.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAnnotation:)];
    [self.annotationView addGestureRecognizer:tapGestureRecognizer];
    
    self.annotationImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.annotationImageViewWidthConstraint.constant *= Design.HEIGHT_RATIO;
}

- (void)bindWithAnnotation:(TLDescriptorAnnotation *)descriptorAnnotation descriptorId:(TLDescriptorId *)descriptorId isPeerItem:(BOOL)isPeerItem {
    DDLogVerbose(@"%@ bindWithAnnotation: %@", LOG_TAG, descriptorAnnotation);
           
    self.descriptorId = descriptorId;
    
    self.annotationImageViewHeightConstraint.constant = DESIGN_ICON_HEIGHT * Design.HEIGHT_RATIO;
    
    if (isPeerItem) {
        self.annotationViewLeadingConstraint.constant = 0;
    } else {
        self.annotationViewLeadingConstraint.constant = Design.ANNOTATION_CELL_WIDTH_NORMAL - self.annotationViewWidthConstraint.constant;
    }
    
    self.annotationImageView.tintColor = [UIColor clearColor];
    
    switch (descriptorAnnotation.value) {
        case ReactionTypeLike:
            self.annotationImageView.image = [UIImage imageNamed:@"ReactionLike"];
            break;
            
        case ReactionTypeUnlike:
            self.annotationImageView.image = [UIImage imageNamed:@"ReactionUnlike"];
            break;
            
        case ReactionTypeLove:
            self.annotationImageView.image = [UIImage imageNamed:@"ReactionLove"];
            break;
            
        case ReactionTypeCry:
            self.annotationImageView.image = [UIImage imageNamed:@"ReactionCry"];
            break;
            
        case ReactionTypeFire:
            self.annotationImageView.image = [UIImage imageNamed:@"ReactionFire"];
            break;
            
        case ReactionTypeHunger:
            self.annotationImageView.image = [UIImage imageNamed:@"ReactionHunger"];
            break;
            
        case ReactionTypeScreaming:
            self.annotationImageView.image = [UIImage imageNamed:@"ReactionScreaming"];
            break;
            
        case ReactionTypeSurprised:
            self.annotationImageView.image = [UIImage imageNamed:@"ReactionSurprised"];
            break;
            
        default:
            self.annotationImageView.image = [UIImage imageNamed:@"ReactionUnknown"];
            self.annotationImageView.tintColor = Design.BLACK_COLOR;
            break;
    }
    
    [self updateColor];
}

- (void)bindWithForwardedAnnotation:(BOOL)isPeerItem {
    DDLogVerbose(@"%@ bindWithForwardedAnnotation", LOG_TAG);

    self.annotationActionDelegate = nil;
    
    if (isPeerItem) {
        self.annotationViewLeadingConstraint.constant = 0;
    } else {
        self.annotationViewLeadingConstraint.constant = self.frame.size.width - self.annotationViewWidthConstraint.constant;
    }
    
    self.annotationImageViewHeightConstraint.constant = DESIGN_ICON_FORWARDED_HEIGHT * Design.HEIGHT_RATIO;
    self.annotationImageView.image = [UIImage imageNamed:@"ForwardIcon"];
    self.annotationImageView.tintColor = Design.BLACK_COLOR;
    
    [self updateColor];
}

- (void)bindWithUpdatedAnnotation:(BOOL)isPeerItem {
    DDLogVerbose(@"%@ bindWithUpdatedAnnotation", LOG_TAG);

    self.annotationActionDelegate = nil;
    
    if (isPeerItem) {
        self.annotationViewLeadingConstraint.constant = 0;
    } else {
        self.annotationViewLeadingConstraint.constant = self.frame.size.width - self.annotationViewWidthConstraint.constant;
    }
    
    self.annotationImageViewHeightConstraint.constant = DESIGN_ICON_FORWARDED_HEIGHT * Design.HEIGHT_RATIO;
    self.annotationImageView.image = [UIImage imageNamed:@"EditAnnotationIcon"];
    self.annotationImageView.tintColor = Design.BLACK_COLOR;
    
    [self updateColor];
}

- (void)tapAnnotation:(UITapGestureRecognizer *)tapGesture {
    DDLogVerbose(@"%@ tapAnnotation: %@", LOG_TAG, tapGesture);
    
    if ([self.annotationActionDelegate respondsToSelector:@selector(didTapAnnotation:)]) {
        [self.annotationActionDelegate didTapAnnotation:self.descriptorId];
    }
}

- (void)updateColor {
    
    self.backgroundColor = [UIColor clearColor];
    self.annotationView.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
}

@end

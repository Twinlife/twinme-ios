/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinlife/TLConversationService.h>

#import "AnnotationCountCell.h"
#import "ItemCell.h"

#import "UIReaction.h"
#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: AnnotationCountCell ()
//

@interface AnnotationCountCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *annotationViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *annotationViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *annotationViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIView *annotationView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *annotationImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *annotationImageViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *annotationImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *annotationImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *counterLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *counterLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *counterLabel;

@property (nonatomic) TLDescriptorId *descriptorId;

@end

//
// Implementation: AnnotationCountCell
//

#undef LOG_TAG
#define LOG_TAG @"AnnotationCountCell"

@implementation AnnotationCountCell

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
    self.annotationView.backgroundColor = Design.GREY_ITEM;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAnnotation:)];
    [self.annotationView addGestureRecognizer:tapGestureRecognizer];
    
    self.annotationImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.annotationImageViewWidthConstraint.constant *= Design.HEIGHT_RATIO;
    self.annotationImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.counterLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.counterLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.counterLabel.font = Design.FONT_MEDIUM24;
    self.counterLabel.textColor = Design.FONT_COLOR_DEFAULT;
}

- (void)bindWithAnnotation:(TLDescriptorAnnotation *)descriptorAnnotation descriptorId:(TLDescriptorId *)descriptorId isPeerItem:(BOOL)isPeerItem {
    DDLogVerbose(@"%@ bindWithAnnotation: %@", LOG_TAG, descriptorAnnotation);
            
    self.descriptorId = descriptorId;
    
    if (isPeerItem) {
        self.annotationViewLeadingConstraint.constant = 0;
    } else {
        self.annotationViewLeadingConstraint.constant = Design.ANNOTATION_CELL_WIDTH_LARGE - self.annotationViewWidthConstraint.constant;
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
    
    self.counterLabel.text = [NSString stringWithFormat:@"%d", descriptorAnnotation.count];
    
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
    self.annotationView.backgroundColor = Design.GREY_ITEM;
}

@end

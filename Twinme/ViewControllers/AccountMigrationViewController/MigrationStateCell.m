/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "MigrationStateCell.h"

#import "UIMigrationStateItem.h"

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static const CGFloat DESIGN_BORDER_WITH = 4.f;
static UIColor *DESIGN_STATE_COLOR;
static UIColor *DESIGN_BORDER_COLOR;


//
// Interface: MigrationStateCell ()
//

@interface MigrationStateCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *roundedViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *roundedViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *roundedView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *checkView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *joinTopViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *joinTopViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *joinTopView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *joinBottomViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *joinBottomViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *joinBottomView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelBottomConstraint;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (nonatomic) NSLayoutConstraint *minimumHeightConstraint;

@end

//
// Implementation: MigrationStateCell
//

#undef LOG_TAG
#define LOG_TAG @"MigrationStateCell"

@implementation MigrationStateCell

+ (void)initialize {
    DDLogVerbose(@"%@ initialize", LOG_TAG);
    
    DESIGN_STATE_COLOR = [UIColor colorWithRed:0.f green:1.f blue:204./255. alpha:1.0f];
    DESIGN_BORDER_COLOR = [UIColor colorWithRed:219./255. green:219./255. blue:219./255.f alpha:1.0f];
}

- (void)awakeFromNib {
    DDLogVerbose(@"%@ awakeFromNib", LOG_TAG);
    
    [super awakeFromNib];
        
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = Design.WHITE_COLOR;
    
    self.roundedViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.roundedViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.roundedView.clipsToBounds = YES;
    self.roundedView.layer.cornerRadius = self.roundedViewHeightConstraint.constant * 0.5f;
    self.roundedView.layer.borderColor = DESIGN_BORDER_COLOR.CGColor;
    self.roundedView.layer.borderWidth = DESIGN_BORDER_WITH;
    self.roundedView.backgroundColor = [UIColor clearColor];
    
    self.messageLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.messageLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.messageLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.messageLabelBottomConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.messageLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.messageLabel.font = Design.FONT_MEDIUM32;
    
    self.checkViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.checkView.hidden = YES;
    self.checkView.tintColor = [UIColor whiteColor];
    
    self.joinTopViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.joinTopViewWidthConstraint.constant = DESIGN_BORDER_WITH;
    self.joinTopView.backgroundColor = DESIGN_BORDER_COLOR;
    self.joinTopView.clipsToBounds = YES;
    self.joinTopView.layer.cornerRadius = self.joinTopViewWidthConstraint.constant * 0.5f;
    self.joinTopView.layer.maskedCorners = kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner;
    
    self.joinBottomViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.joinBottomViewWidthConstraint.constant = DESIGN_BORDER_WITH;
    self.joinBottomView.backgroundColor = DESIGN_BORDER_COLOR;
    self.joinBottomView.clipsToBounds = YES;
    self.joinBottomView.layer.cornerRadius = self.joinBottomViewWidthConstraint.constant * 0.5f;
    self.joinBottomView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
}

- (void)setMinimumHeight:(CGFloat)minimumHeight {
    DDLogVerbose(@"%@ setMinimumHeight: %f", LOG_TAG, minimumHeight);
    
    if (!self.minimumHeightConstraint) {
        self.minimumHeightConstraint = [self.contentView.heightAnchor constraintGreaterThanOrEqualToConstant:minimumHeight];
        self.minimumHeightConstraint.active = YES;
    } else {
        self.minimumHeightConstraint.constant = minimumHeight;
    }
}

- (void)bindWithItem:(nonnull UIMigrationStateItem *)migrationStateItem previousStateDone:(BOOL)previousStateDone {
    DDLogVerbose(@"%@ bindWithItem: %@", LOG_TAG, migrationStateItem);
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@""];
    [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:[migrationStateItem getTitle] attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_MEDIUM32, NSFontAttributeName, Design.FONT_COLOR_DEFAULT, NSForegroundColorAttributeName, nil]]];
    
    if ([migrationStateItem getInfo]) {
        [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n"]];
        
        if ([migrationStateItem getAttributedInfo]) {
            NSMutableAttributedString *attributedInfo = [[NSMutableAttributedString alloc] initWithAttributedString:[migrationStateItem getAttributedInfo]];
            [attributedInfo addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_MEDIUM32, NSFontAttributeName, Design.FONT_COLOR_GREY, NSForegroundColorAttributeName, nil] range:NSMakeRange(0, attributedInfo.length)];
            [attributedString appendAttributedString:attributedInfo];
        } else {
            [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:[migrationStateItem getInfo] attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_MEDIUM32, NSFontAttributeName, Design.FONT_COLOR_GREY, NSForegroundColorAttributeName, nil]]];
        }
    }
    self.messageLabel.attributedText = attributedString;
    
    if ([migrationStateItem getType] == MigrationStateItemTypeInit) {
        self.joinTopView.hidden = YES;
        self.joinBottomView.hidden = NO;
    } else if ([migrationStateItem getType] == MigrationStateItemTypeTerminated) {
        self.joinTopView.hidden = NO;
        self.joinBottomView.hidden = YES;
    } else {
        self.joinTopView.hidden = NO;
        self.joinBottomView.hidden = NO;
    }
        
    switch ([migrationStateItem getState]) {
        case MigrationStateItemStatePending:
            self.checkView.hidden = YES;
            self.roundedView.layer.borderColor = DESIGN_BORDER_COLOR.CGColor;
            self.roundedView.layer.backgroundColor = [UIColor clearColor].CGColor;
            break;
            
        case MigrationStateItemStateInProgress:
            self.checkView.hidden = YES;
            self.roundedView.layer.borderColor = DESIGN_STATE_COLOR.CGColor;
            self.roundedView.layer.backgroundColor = DESIGN_STATE_COLOR.CGColor;
            break;
            
        case MigrationStateItemStateDone:
            self.checkView.hidden = NO;
            self.roundedView.layer.borderColor = Design.MAIN_COLOR.CGColor;
            self.roundedView.layer.backgroundColor = Design.MAIN_COLOR.CGColor;
            break;
            
        default:
            break;
    }
    
    [self updateColor];
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.messageLabel.font = Design.FONT_MEDIUM32;
}

@end

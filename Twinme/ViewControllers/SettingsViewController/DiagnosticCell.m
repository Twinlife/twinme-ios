/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "DiagnosticCell.h"

#import <CocoaLumberjack.h>

#import "UIDiagnosticItem.h"
#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: DiagnosticCell
//

@interface DiagnosticCell()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stateImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stateImageViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *stateImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@end

#undef LOG_TAG
#define LOG_TAG @"DiagnosticCell"

//
// Implementation: DiagnosticCell
//

@implementation DiagnosticCell

- (void)awakeFromNib {
    DDLogVerbose(@"%@ awakeFromNib", LOG_TAG);
    
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = Design.WHITE_COLOR;
    self.titleLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.titleLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.titleLabel.font = Design.FONT_REGULAR32;
    self.titleLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.iconViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.iconViewHeightConstraint.constant *= Design.HEIGHT_RATIO;

    self.stateImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.stateImageViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.separatorViewHeightConstraint.constant = Design.SEPARATOR_HEIGHT;
    self.separatorView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
}

- (void)bind:(nonnull UIDiagnosticItem *)diagnosticItem {
    DDLogVerbose(@"%@ bind: %@", LOG_TAG, diagnosticItem);
    
    self.iconView.image = [diagnosticItem.icon imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.iconView.tintColor = Design.BLACK_COLOR;
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@""];
    [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:diagnosticItem.title attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_MEDIUM32, NSFontAttributeName, Design.FONT_COLOR_DEFAULT, NSForegroundColorAttributeName, nil]]];
    
    if (diagnosticItem.subTitle) {
        [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n"]];
        [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:diagnosticItem.subTitle attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_MEDIUM28, NSFontAttributeName, Design.FONT_COLOR_GREY, NSForegroundColorAttributeName, nil]]];
    }
    
    self.titleLabel.attributedText = attributedString;

    switch (diagnosticItem.diagnosticItemState) {
        case DiagnosticItemStateOK:
            self.stateImageView.image = [UIImage imageNamed:@"DiagnosticOKIcon"];
            self.stateImageView.tintColor = [UIColor greenColor];
            break;
            
        case DiagnosticItemStateKO:
            self.stateImageView.image = [UIImage imageNamed:@"DiagnosticKOIcon"];
            self.stateImageView.tintColor = [UIColor redColor];
            break;
            
        case DiagnosticItemStateUnknown:
            self.stateImageView.image = nil;
            break;
        
        default:
            break;
    }
}

@end

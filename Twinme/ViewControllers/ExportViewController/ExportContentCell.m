/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "ExportContentCell.h"

#import <TwinmeCommon/Design.h>

#import "UIExport.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: ExportContentCell ()
//

@interface ExportContentCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *exportTypeLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *exportTypeLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *exportTypeLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *exportTypeImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *exportTypeImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *exportTypeImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkMarkViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkMarkViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *checkMarkView;
@property (weak, nonatomic) IBOutlet UIImageView *checkMarkImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@end

//
// Implementation: ExportContentCell
//

#undef LOG_TAG
#define LOG_TAG @"ExportContentCell"

@implementation ExportContentCell

- (void)awakeFromNib {
    DDLogVerbose(@"%@ awakeFromNib", LOG_TAG);
    
    [super awakeFromNib];
        
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = Design.WHITE_COLOR;
    self.exportTypeLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.exportTypeLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
   
    self.exportTypeLabel.font = Design.FONT_REGULAR32;
    self.exportTypeLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.exportTypeImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.exportTypeImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.exportTypeImageView.tintColor = Design.UNSELECTED_TAB_COLOR;
    
    self.checkMarkViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.checkMarkViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    CALayer *checkMarkViewLayer = self.checkMarkView.layer;
    checkMarkViewLayer.cornerRadius = self.checkMarkViewHeightConstraint.constant * 0.5;
    checkMarkViewLayer.borderWidth = Design.CHECKMARK_BORDER_WIDTH;
    checkMarkViewLayer.borderColor = Design.CHECKMARK_BORDER_COLOR.CGColor;
    
    self.checkMarkImageView.tintColor = Design.MAIN_COLOR;
    
    self.separatorViewHeightConstraint.constant = Design.SEPARATOR_HEIGHT;
    self.separatorView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
}

- (void)bindWithExport:(UIExport *)uiExport {
    DDLogVerbose(@"%@ bindWithExport: %@", LOG_TAG, uiExport);
        
    self.exportTypeImageView.image = uiExport.exportImage;
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@""];
    [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:[uiExport getTitle] attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_REGULAR32, NSFontAttributeName, Design.FONT_COLOR_DEFAULT, NSForegroundColorAttributeName, nil]]];
    [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n"]];
    [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:[uiExport getInformation] attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_REGULAR32, NSFontAttributeName, Design.FONT_COLOR_GREY, NSForegroundColorAttributeName, nil]]];
    
    self.exportTypeLabel.attributedText = attributedString;
    
    if (uiExport.count == 0) {
        self.checkMarkView.alpha = 0.5f;
        self.exportTypeImageView.alpha = 0.5f;
        self.exportTypeLabel.alpha = 0.5f;
    } else {
        self.checkMarkView.alpha = 1.f;
        self.exportTypeImageView.alpha = 1.f;
        self.exportTypeLabel.alpha = 1.f;
    }
    
    if (uiExport.checked && uiExport.count != 0) {
        self.checkMarkImageView.hidden = NO;
    } else {
        self.checkMarkImageView.hidden = YES;
    }
    
    [self updateColor];
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.contentView.backgroundColor = Design.WHITE_COLOR;
    self.separatorView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
    self.checkMarkImageView.tintColor = Design.MAIN_COLOR;
}


@end

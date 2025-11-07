/*
 *  Copyright (c) 2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "ResetSettingsCell.h"

#import <Utils/NSString+Utils.h>

#import <TwinmeCommon/Design.h>

//
// Interface: ResetSettingsCell
//

@interface ResetSettingsCell()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *resetViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *resetViewWidthConstraint;
@property (nonatomic) IBOutlet UIView *resetView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *resetLabelWidthConstraint;
@property (nonatomic) IBOutlet UILabel *resetLabel;

@end

//
// Implementation: ResetSettingsCell
//

#undef LOG_TAG
#define LOG_TAG @"ResetSettingsCell"

@implementation ResetSettingsCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.contentView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    
    self.resetViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.resetViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.resetView.backgroundColor = Design.MAIN_COLOR;
    self.resetView.userInteractionEnabled = YES;
    self.resetView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.resetView.clipsToBounds = YES;
    
    self.resetLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.resetLabel.font = Design.FONT_REGULAR34;
    self.resetLabel.textColor = [UIColor whiteColor];
    self.resetLabel.text = TwinmeLocalizedString(@"space_appareance_view_controller_default_value", nil);
}

@end

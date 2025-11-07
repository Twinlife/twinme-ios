/*
 *  Copyright (c) 2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "CallNameCell.h"

#import "Item.h"


#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: CallNameCell ()
//

@interface CallNameCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelBottomConstraint;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

//
// Implementation: CallNameCell
//

#undef LOG_TAG
#define LOG_TAG @"CallNameCell"

@implementation CallNameCell

- (void)awakeFromNib {
    DDLogVerbose(@"%@ awakeFromNib", LOG_TAG);
    
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.nameLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.nameLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.nameLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.nameLabelBottomConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.nameLabel.font = Design.FONT_REGULAR28;
    self.nameLabel.numberOfLines = 1;
    self.nameLabel.textColor = [UIColor whiteColor];
}

- (void)prepareForReuse {
    DDLogVerbose(@"%@ prepareForReuse", LOG_TAG);
    
    [super prepareForReuse];
    
    self.nameLabel.text = nil;
}

- (void)dealloc {
    DDLogVerbose(@"%@ dealloc", LOG_TAG);
}

- (void)bindWithName:(NSString *)name {
    DDLogVerbose(@"%@ bindWithName: %@", LOG_TAG, name);
    
    self.nameLabel.text = name;
    [self setNeedsDisplay];
}


@end

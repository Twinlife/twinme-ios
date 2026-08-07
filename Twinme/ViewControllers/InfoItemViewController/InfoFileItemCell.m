/*
 *  Copyright (c) 2019-2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinme/TLOriginator.h>

#import "InfoFileItemCell.h"
#import "CallItem.h"
#import "PeerCallItem.h"

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: InfoFileItemCell ()
//

@interface InfoFileItemCell () <UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fileInfoLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fileInfoTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fileInfoTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fileInfoBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fileInfoHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *fileInfoLabel;

@end

//
// Implementation: InfoFileItemCell
//

#undef LOG_TAG
#define LOG_TAG @"InfoFileItemCell"

@implementation InfoFileItemCell

- (void)awakeFromNib {
    DDLogVerbose(@"%@ awakeFromNib", LOG_TAG);
    
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.contentView.backgroundColor = Design.WHITE_COLOR;
    
    self.iconViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.iconViewLeadingConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.fileInfoLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.fileInfoTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.fileInfoTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.fileInfoBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.fileInfoHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.fileInfoLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.fileInfoLabel.font = Design.FONT_REGULAR32;
    self.fileInfoLabel.adjustsFontSizeToFitWidth = YES;
}

- (void)prepareForReuse {
    
    [super prepareForReuse];
}

- (void)bindWithItem:(Item *)item originator:(id<TLOriginator>)originator {
    DDLogVerbose(@"%@ bindWithItem: %@ originator: %@", LOG_TAG, item, originator);
    
    if (item.type == ItemTypeCall) {
        CallItem *callItem = (CallItem *)item;
        NSString *iconName = callItem.callDescriptor.isVideo ? @"VideoCall" : @"AudioCall";
        self.iconView.image =[[UIImage imageNamed:iconName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.fileInfoLabel.text = [callItem getInformation:originator.name];
    } else if (item.type == ItemTypePeerCall) {
        PeerCallItem *peerCallItem = (PeerCallItem *)item;
        NSString *iconName = peerCallItem.peerCallDescriptor.isVideo ? @"VideoCall" : @"AudioCall";
        self.iconView.image =[[UIImage imageNamed:iconName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.fileInfoLabel.text = [peerCallItem getInformation:originator.name];
    } else if (item.type == ItemTypeLocation || item.type == ItemTypePeerLocation) {
        self.iconView.image = [[UIImage imageNamed:@"CallLocationIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.fileInfoLabel.text = [item getInformation];
    } else {
        self.iconView.image = [UIImage imageNamed:@"NotificationFileMessage"];
        self.fileInfoLabel.text = [item getInformation];
    }
    
    [self updateColor];
    [self updateFont];
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.fileInfoLabel.font = Design.FONT_REGULAR32;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.contentView.backgroundColor = Design.WHITE_COLOR;
    self.fileInfoLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.iconView.tintColor = Design.BLACK_COLOR;
}

@end

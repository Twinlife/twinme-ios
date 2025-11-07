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

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fileInfoLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fileInfoTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fileInfoTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fileInfoBottomConstraint;
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
    
    self.fileInfoLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.fileInfoTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.fileInfoTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.fileInfoBottomConstraint.constant *= Design.HEIGHT_RATIO;
    
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
        self.fileInfoLabel.text = [callItem getInformation:originator.name];
    } else if (item.type == ItemTypePeerCall) {
        PeerCallItem *peerCallItem = (PeerCallItem *)item;
        self.fileInfoLabel.text = [peerCallItem getInformation:originator.name];
    } else {
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
    
    self.fileInfoLabel.textColor = Design.FONT_COLOR_DEFAULT;
}

@end

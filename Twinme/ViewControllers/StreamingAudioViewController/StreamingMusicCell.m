/*
 *  Copyright (c) 2022 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <MediaPlayer/MediaPlayer.h>

#import <Utils/NSString+Utils.h>

#import "StreamingMusicCell.h"

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static const CGFloat DESIGN_ARTWORK_RADIUS = 6;

static UIColor *DESIGN_PLACEHOLDER_COLOR;

//
// Interface: StreamingMusicCell ()
//

@interface StreamingMusicCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *coverViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *coverViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *coverView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *coverPlaceholderViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *coverPlaceholderView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *musicLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *musicLabelBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *musicLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *musicLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *musicLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkMarkViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkMarkViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *checkMarkView;
@property (weak, nonatomic) IBOutlet UIImageView *checkMarkImageView;

@property (nonatomic) MPMediaItem *musicItem;

@end

//
// Implementation: StreamingMusicCell
//

#undef LOG_TAG
#define LOG_TAG @"StreamingMusicCell"

@implementation StreamingMusicCell

+ (void)initialize {
    DDLogVerbose(@"%@ initialize", LOG_TAG);
    
    DESIGN_PLACEHOLDER_COLOR = [UIColor colorWithRed:229./255. green:229./255. blue:229./255. alpha:1];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = Design.WHITE_COLOR;
    
    self.coverViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.coverViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.coverView.backgroundColor = DESIGN_PLACEHOLDER_COLOR;
    self.coverView.clipsToBounds = YES;
    self.coverView.layer.cornerRadius = DESIGN_ARTWORK_RADIUS;
    self.coverView.contentMode = UIViewContentModeScaleAspectFill;
    
    self.coverPlaceholderViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.coverPlaceholderView.hidden = YES;
    
    self.musicLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.musicLabelBottomConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.musicLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.musicLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    CGFloat checkMarkViewHeightConstraintConstant = self.checkMarkViewHeightConstraint.constant * Design.HEIGHT_RATIO;
    CGFloat roundedCheckMarkViewHeightConstraintConstant = ((int) (roundf(checkMarkViewHeightConstraintConstant / 2))) * 2;
         
    self.checkMarkViewHeightConstraint.constant = roundedCheckMarkViewHeightConstraintConstant;
    self.checkMarkViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    CALayer *checkMarkViewLayer = self.checkMarkView.layer;
    checkMarkViewLayer.cornerRadius = self.checkMarkViewHeightConstraint.constant * 0.5;
    checkMarkViewLayer.borderWidth = Design.CHECKMARK_BORDER_WIDTH;
    checkMarkViewLayer.borderColor = Design.CHECKMARK_BORDER_COLOR.CGColor;
    
    self.checkMarkView.clipsToBounds = YES;
    self.checkMarkImageView.tintColor = Design.MAIN_COLOR;
}

- (void)prepareForReuse {
    
    [super prepareForReuse];
}

- (void)bindWithItem:(MPMediaItem *)item checked:(BOOL)checked {
    DDLogVerbose(@"%@ bindWithItem: %@", LOG_TAG, item);
    
    NSMutableAttributedString *songAttributedString = [[NSMutableAttributedString alloc] initWithString:item.title attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_MEDIUM34, NSFontAttributeName, Design.FONT_COLOR_DEFAULT, NSForegroundColorAttributeName, nil]];
    
    if (item.artist && ![item.artist isEqual:@""]) {
        [songAttributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n"]];
        [songAttributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:item.artist attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_REGULAR24, NSFontAttributeName, Design.FONT_COLOR_GREY, NSForegroundColorAttributeName, nil]]];
    }
    
    if (item.albumTitle && ![item.albumTitle isEqual:@""]) {
        [songAttributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n"]];
        [songAttributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:item.albumTitle attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_REGULAR24, NSFontAttributeName, Design.FONT_COLOR_DEFAULT, NSForegroundColorAttributeName, nil]]];
    }
    
    self.musicLabel.attributedText = songAttributedString;
        
    UIImage *artworkImage;
    MPMediaItemArtwork *artwork = [item valueForProperty: MPMediaItemPropertyArtwork];
    artworkImage = [artwork imageWithSize:self.coverView.frame.size];
    if (artworkImage) {
        self.coverView.image = artworkImage;
        self.coverPlaceholderView.hidden = YES;
    } else {
        self.coverPlaceholderView.hidden = NO;
    }
    
    if (checked) {
        self.checkMarkImageView.hidden = NO;
    } else {
        self.checkMarkImageView.hidden = YES;
    }
    
    [self updateColor];
}

- (void)updateColor {
    
    self.contentView.backgroundColor = Design.WHITE_COLOR;
}

@end

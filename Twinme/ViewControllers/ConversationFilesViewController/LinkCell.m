/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "LinkCell.h"
#import "LinkItem.h"
#import "PeerLinkItem.h"

#import <TwinmeCommon/AsyncLinkLoader.h>

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static const CGFloat DESIGN_FILE_RADIUS = 6;

static UIColor *DESIGN_PLACEHOLDER_COLOR;

//
// Interface: LinkCell ()
//

@interface LinkCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *linkImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *linkImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *linkImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *placeholderImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *placeholderImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *linkLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *linkLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *linkLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkMarkViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkMarkViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *checkMarkView;
@property (weak, nonatomic) IBOutlet UIImageView *checkMarkImageView;

@property (nonatomic) AsyncLinkLoader *linkLoader;

@end

//
// Implementation: LinkCell
//

#undef LOG_TAG
#define LOG_TAG @"LinkCell"

@implementation LinkCell

+ (void)initialize {
    DDLogVerbose(@"%@ initialize", LOG_TAG);
    
    DESIGN_PLACEHOLDER_COLOR = [UIColor colorWithRed:229./255. green:229./255. blue:229./255. alpha:1];
}

- (void)awakeFromNib {
    DDLogVerbose(@"%@ awakeFromNib", LOG_TAG);
    
    [super awakeFromNib];
        
    self.isAccessibilityElement = YES;
    self.contentView.backgroundColor = Design.WHITE_COLOR;
    
    self.linkImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.linkImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
        
    self.linkImageView.backgroundColor = DESIGN_PLACEHOLDER_COLOR;
    self.linkImageView.clipsToBounds = YES;
    self.linkImageView.layer.cornerRadius = DESIGN_FILE_RADIUS;
    self.linkImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    self.placeholderImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.placeholderImageView.hidden = YES;
            
    self.linkLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.linkLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.linkLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.linkLabel.font = Design.FONT_MEDIUM34;
        
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
    DDLogVerbose(@"%@ prepareForReuse", LOG_TAG);
    
    [super prepareForReuse];
    
    if (self.linkLoader) {
        [self.linkLoader cancel];
        self.linkLoader = nil;
    }
}

- (void)bindWithItem:(Item *)item asyncManager:(AsyncManager *)asyncManager  isSelectable:(BOOL)isSelectable showPreview:(BOOL)showPreview {
    DDLogVerbose(@"%@ bind", LOG_TAG);
    
    TLObjectDescriptor *objectDescriptor;
    NSURL *url;
    if (item.isPeerItem) {
        PeerLinkItem *peerLinkItem = (PeerLinkItem *)item;
        objectDescriptor = peerLinkItem.objectDescriptor;
        url = peerLinkItem.url;
    } else {
        LinkItem *linkItem = (LinkItem *)item;
        objectDescriptor = linkItem.objectDescriptor;
        url = linkItem.url;
    }
    
    UIImage *image;
    NSString *title;
    
    if (showPreview) {
        // Use an async loader to get url metadata
        if (!self.linkLoader) {
            self.linkLoader = [[AsyncLinkLoader alloc] initWithItem:item objectDescriptor:objectDescriptor];
            if (!self.linkLoader.image && !self.linkLoader.title) {
                [asyncManager addItemWithAsyncLoader:self.linkLoader];
            }
        }
        
        image = self.linkLoader.image;
        title = self.linkLoader.title;
    }
    
    if (title) {
        self.linkLabel.text = title;
    } else {
        self.linkLabel.text = [NSString stringWithFormat:@"%@", url];
    }
    
    if (image) {
        self.linkImageView.image = image;
        self.placeholderImageView.hidden = YES;
    } else {
        self.linkImageView.image = nil;
        self.placeholderImageView.hidden = NO;
    }
        
    self.checkMarkView.hidden = !isSelectable;
    self.checkMarkImageView.hidden = !item.selected;
    
    [self updateColor];
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.contentView.backgroundColor = Design.WHITE_COLOR;
}

@end

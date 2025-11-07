/*
 *  Copyright (c) 2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "ReplyView.h"

#import "ConversationViewController.h"

#import <TwinmeCommon/Cache.h>
#import <Utils/NSString+Utils.h>

#import "Item.h"
#import "MessageItem.h"
#import "PeerMessageItem.h"
#import "LinkItem.h"
#import "PeerLinkItem.h"
#import "AudioItem.h"
#import "PeerAudioItem.h"
#import "FileItem.h"
#import "PeerFileItem.h"
#import "ImageItem.h"
#import "PeerImageItem.h"
#import "VideoItem.h"
#import "PeerVideoItem.h"
#import <TwinmeCommon/AsyncImageLoader.h>
#import <TwinmeCommon/AsyncVideoLoader.h>

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static const CGFloat DESIGN_REPLY_VIEW_HEIGHT = 120;
static UIColor *DESIGN_ITEM_COLOR;

//
// Interface: ReplyView ()
//

@interface ReplyView () <AsyncLoaderDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *replyTitleLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *replyTitleLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *replyTitleLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *replyTitleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *itemLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *itemLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *itemLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *itemLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *itemImageViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *itemImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *itemImageViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *itemImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *itemImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *closeImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *closeView;
@property (weak, nonatomic) IBOutlet UIView *overlayView;

@property (weak, nonatomic) Item *item;

@property (nonatomic) AsyncImageLoader *imageLoader;
@property (nonatomic) AsyncVideoLoader *videoLoader;
@property (nonatomic) AsyncManager *asyncLoaderManager;

@end

//
// Implementation: ReplyView
//

#undef LOG_TAG
#define LOG_TAG @"ReplyView"

@implementation ReplyView

#pragma mark - UIView

+ (void)initialize {
    DDLogVerbose(@"%@ initialize", LOG_TAG);
    
    DESIGN_ITEM_COLOR = [UIColor colorWithRed:110./255. green:110./255. blue:110./255. alpha:1];
}

- (instancetype)initWithContext:(TLTwinmeContext *)twinmeContext {
    DDLogVerbose(@"%@ initWithContext", LOG_TAG);
    
    self = [super init];
    
    self.frame = CGRectMake(0, 0, Design.DISPLAY_WIDTH, DESIGN_REPLY_VIEW_HEIGHT * Design.HEIGHT_RATIO);

    self.asyncLoaderManager = [[AsyncManager alloc]initWithTwinmeContext:twinmeContext delegate:self];
    
    if (self) {
        [self initViews];
    }
    return self;
}

#pragma mark - Async Loader

- (void)onLoadedWithItems:(nonnull NSMutableArray<id<NSObject>> *)items {
    DDLogVerbose(@"%@ onLoadedWithItems: %@", LOG_TAG, items);
    
    if (self.imageLoader) {
        self.itemImageView.image = self.imageLoader.image;
    }
    
    if (self.videoLoader) {
        self.itemImageView.image = self.videoLoader.image;
    }
    
    [items removeAllObjects];
}

- (void)showReply:(Item *)item contactName:(NSString *)contactName {
    DDLogVerbose(@"%@ showReply: %@ contactName: %@", LOG_TAG, item, contactName);
    
    if (self.imageLoader) {
        [self.imageLoader cancel];
        self.imageLoader = nil;
    }
    
    if (self.videoLoader) {
        [self.videoLoader cancel];
        self.videoLoader = nil;
    }
    
    self.replyTitleLabel.text = [NSString stringWithFormat:TwinmeLocalizedString(@"conversation_view_controller_reply_to", nil), contactName];
    
    switch (item.type) {
        case ItemTypeMessage: {
            MessageItem *messageItem = (MessageItem *)item;
            self.itemLabel.text = messageItem.content;
            self.itemLabel.hidden = NO;
            self.itemImageView.hidden = YES;
            break;
        }
            
        case ItemTypePeerMessage: {
            PeerMessageItem *peerMessageItem = (PeerMessageItem *)item;
            self.itemLabel.text = peerMessageItem.content;
            self.itemLabel.hidden = NO;
            self.itemImageView.hidden = YES;
            break;
        }
            
        case ItemTypeLink: {
            LinkItem *linkItem = (LinkItem *)item;
            self.itemLabel.text = linkItem.content;
            self.itemLabel.hidden = NO;
            self.itemImageView.hidden = YES;
            break;
        }
            
        case ItemTypePeerLink: {
            PeerLinkItem *peerLinkItem = (PeerLinkItem *)item;
            self.itemLabel.text = peerLinkItem.content;
            self.itemLabel.hidden = NO;
            self.itemImageView.hidden = YES;
            break;
        }
            
        case ItemTypeImage: {
            ImageItem *imageItem = (ImageItem *)item;
            self.imageLoader = [[AsyncImageLoader alloc] initWithItem:imageItem imageDescriptor:imageItem.imageDescriptor size:CGSizeMake(self.itemImageViewWidthConstraint.constant, self.itemImageViewHeightConstraint.constant)];
            
            if (!self.imageLoader.image) {
                [self.asyncLoaderManager addItemWithAsyncLoader:self.imageLoader];
            }
            
            self.itemImageView.image = self.imageLoader.image;
            self.itemLabel.hidden = YES;
            self.itemImageView.hidden = NO;
            break;
        }
            
        case ItemTypePeerImage: {
            PeerImageItem *imageItem = (PeerImageItem *)item;
            self.imageLoader = [[AsyncImageLoader alloc] initWithItem:imageItem imageDescriptor:imageItem.imageDescriptor size:CGSizeMake(self.itemImageViewWidthConstraint.constant, self.itemImageViewHeightConstraint.constant)];
            
            if (!self.imageLoader.image) {
                [self.asyncLoaderManager addItemWithAsyncLoader:self.imageLoader];
            }
            
            self.itemImageView.image = self.imageLoader.image;
            
            self.itemLabel.hidden = YES;
            self.itemImageView.hidden = NO;
            break;
        }
            
        case ItemTypeVideo: {
            VideoItem *videoItem = (VideoItem *)item;
            
            self.videoLoader = [[AsyncVideoLoader alloc] initWithItem:item videoDescriptor:videoItem.videoDescriptor size:CGSizeMake(self.itemImageViewWidthConstraint.constant, self.itemImageViewHeightConstraint.constant)];
            
            if (!self.videoLoader.image) {
                [self.asyncLoaderManager addItemWithAsyncLoader:self.videoLoader];
            }
            
            self.itemImageView.image = self.videoLoader.image;
            
            self.itemLabel.hidden = YES;
            self.itemImageView.hidden = NO;
            break;
        }
            
        case ItemTypePeerVideo: {
            PeerVideoItem *videoItem = (PeerVideoItem *)item;
            self.videoLoader = [[AsyncVideoLoader alloc] initWithItem:item videoDescriptor:videoItem.videoDescriptor size:CGSizeMake(self.itemImageViewWidthConstraint.constant, self.itemImageViewHeightConstraint.constant)];
            
            if (!self.videoLoader.image) {
                [self.asyncLoaderManager addItemWithAsyncLoader:self.videoLoader];
            }
            self.itemImageView.image = self.videoLoader.image;
            self.itemLabel.hidden = YES;
            self.itemImageView.hidden = NO;
            break;
        }
            
        case ItemTypeAudio:
        case ItemTypePeerAudio: {
            self.itemLabel.text = TwinmeLocalizedString(@"conversation_view_controller_audio_message", nil);
            self.itemLabel.hidden = NO;
            self.itemImageView.hidden = YES;
            break;
        }
            
        case ItemTypeLocation:
        case ItemTypePeerLocation: {
            self.itemLabel.text = TwinmeLocalizedString(@"application_location", nil);
            self.itemLabel.hidden = NO;
            self.itemImageView.hidden = YES;
            break;
        }
            
        case ItemTypeFile: {
            FileItem *fileItem = (FileItem *)item;
            self.itemLabel.text = fileItem.namedFileDescriptor.name;
            self.itemLabel.hidden = NO;
            self.itemImageView.hidden = YES;
            break;
        }
        case ItemTypePeerFile: {
            PeerFileItem *fileItem = (PeerFileItem *)item;
            self.itemLabel.text = fileItem.namedFileDescriptor.name;
            self.itemLabel.hidden = NO;
            self.itemImageView.hidden = YES;
            break;
        }
            
        default:
            break;
    }
    
    [self updateFont];
    [self updateColor];
}

- (void)showOverlayView {
    DDLogVerbose(@"%@ showOverlayView", LOG_TAG);
    
    self.overlayView.hidden = NO;
}

- (void)hideOverlayView {
    DDLogVerbose(@"%@ hideOverlayView", LOG_TAG);
 
    self.overlayView.hidden = YES;
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.userInteractionEnabled = YES;
    
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"ReplyView" owner:self options:nil];
    UIView *view = [objects objectAtIndex:0];
    view.frame = CGRectMake(0, 0, Design.DISPLAY_WIDTH, DESIGN_REPLY_VIEW_HEIGHT * Design.HEIGHT_RATIO);
    [self addSubview:[objects objectAtIndex:0]];
    
    [self setBackgroundColor:Design.LIGHT_GREY_BACKGROUND_COLOR];
    
    self.replyTitleLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.replyTitleLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.replyTitleLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.replyTitleLabel.font = Design.FONT_REGULAR24;
    self.replyTitleLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.itemLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.itemLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.itemLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.itemLabel.font = Design.FONT_REGULAR24;
    self.itemLabel.textColor = DESIGN_ITEM_COLOR;
    self.itemLabel.numberOfLines = 2;
    
    self.itemImageViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.itemImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.itemImageViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.itemImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.itemImageView.hidden = YES;
    
    self.closeImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.closeViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.closeViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.closeView.userInteractionEnabled = YES;
    self.closeView.isAccessibilityElement = YES;
    self.closeView.accessibilityLabel = TwinmeLocalizedString(@"application_cancel", nil);
    UITapGestureRecognizer *closetViewTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleCloseTapGesture:)];
    [self.closeView addGestureRecognizer:closetViewTapGesture];
    
    self.overlayView.backgroundColor = Design.BACKGROUND_COLOR_WHITE_OPACITY36;
    self.overlayView.hidden = YES;
}

- (void)handleCloseTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleCancelTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self.replyViewDelegate closeReplyView];
    }
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    if (self.imageLoader) {
        [self.imageLoader cancel];
        self.imageLoader = nil;
    }
    
    if (self.videoLoader) {
        [self.videoLoader cancel];
        self.videoLoader = nil;
    }
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.replyTitleLabel.font = Design.FONT_REGULAR24;
    self.itemLabel.font = Design.FONT_REGULAR24;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    [self setBackgroundColor:Design.LIGHT_GREY_BACKGROUND_COLOR];
    self.replyTitleLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.itemLabel.textColor = DESIGN_ITEM_COLOR;
}

@end


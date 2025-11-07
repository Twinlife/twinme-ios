/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#include <math.h>

#import <mach/mach.h>
#import <mach/mach_host.h>

#import <CocoaLumberjack.h>

#import <Photos/Photos.h>

#import <Twinlife/TLConversationService.h>

#import "FullScreenMediaViewController.h"

#import <Utils/NSString+Utils.h>

#import "FullScreenImageCell.h"
#import "FullScreenVideoCell.h"
#import "Item.h"
#import "ImageItem.h"
#import "PeerImageItem.h"
#import "PeerVideoItem.h"
#import "VideoItem.h"

#import <TwinmeCommon/AudioPlayerManager.h>
#import <TwinmeCommon/ConversationFilesService.h>
#import <TwinmeCommon/Design.h>

#import "DeviceAuthorization.h"
#import "UIView+Toast.h"
#import "DeleteConfirmView.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static NSString *FULL_SCREEN_IMAGE_CELL_IDENTIFIER = @"FullScreenImageCellIdentifier";
static NSString *FULL_SCREEN_VIDEO_CELL_IDENTIFIER = @"FullScreenVideoCellIdentifier";

//
// Interface: FullScreenMediaViewController ()
//

@interface FullScreenMediaViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, FullScreenMediaDelegate, ConversationFilesServiceDelegate, ConfirmViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *mediaCollectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *closeView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *closeImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *footerViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shareItemViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shareItemViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *shareItemView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shareItemImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *shareItemImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *saveItemViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *saveItemViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *saveItemView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *saveItemImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *saveItemImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *deleteItemViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *deleteItemViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *deleteItemView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *deleteItemImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *deleteItemImageView;

@property (nonatomic) ConversationFilesService *conversationFileService;
@property (nonatomic) NSUUID *conversationId;

@property (nonatomic) NSMutableArray *items;

@property (nonatomic) Item *currentItem;
@property (nonatomic) NSInteger currentItemIndex;
@property (nonatomic) int startIndex;
@property (nonatomic) BOOL initScroll;

@property (nonatomic) BOOL hideAction;
@property (nonatomic) AudioSessionManager *audioSessionManager;
@property (nonatomic) FullScreenVideoCell *videoItem;
@property (nonatomic) id<TLOriginator> originator;

@end

//
// Implementation: FullScreenMediaViewController
//

#undef LOG_TAG
#define LOG_TAG @"FullScreenMediaViewController"

@implementation FullScreenMediaViewController

#pragma mark - UIViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _hideAction = NO;
        _initScroll = NO;
        _conversationFileService = [[ConversationFilesService alloc] initWithTwinmeContext:self.twinmeContext delegate:self];
        _audioSessionManager = [[AudioSessionManager alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
        
    [self initViews];
}

- (void)viewWillAppear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillAppear", LOG_TAG);
    
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    DDLogVerbose(@"%@ viewDidAppear", LOG_TAG);
    
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillDisappear", LOG_TAG);
    
    [super viewWillDisappear:animated];
    
    if (self.videoItem) {
        [self.videoItem stopVideo];
    }
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLayoutSubviews {
    DDLogVerbose(@"%@ viewDidLayoutSubviews", LOG_TAG);
    
    [super viewDidLayoutSubviews];
    
    if (!self.initScroll) {
        self.initScroll = YES;
        if (self.startIndex != 0) {
            self.mediaCollectionView.pagingEnabled = NO;
            [self.mediaCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.startIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
            self.mediaCollectionView.pagingEnabled = YES;
            self.startIndex = 0;
        } else {
           [self.mediaCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        }
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    
    return UIStatusBarStyleLightContent;
}

- (void)initWithItems:(NSMutableArray *)items atIndex:(int)index conversationId:(NSUUID *)conversationId originator:(id<TLOriginator>)originator {
    DDLogVerbose(@"%@ initWithItems: %@ atIndex: %d", LOG_TAG, items, index);
    
    self.items = items;
    self.startIndex = index;
    self.conversationId = conversationId;
    self.originator = originator;
    [self.conversationFileService initWithConversationId:self.conversationId];
}

#pragma mark - UIViewController (Utils)

- (BOOL)hasLandscapeMode {
    DDLogVerbose(@"%@ hasLandscapeMode", LOG_TAG);
    
    return YES;
}

#pragma mark - ConversationFilesServiceDelegate

- (void)onGetConversation:(id<TLConversation>)conversation {
    DDLogVerbose(@"%@ onGetConversation: %@", LOG_TAG, conversation);
    
}

- (void)onGetDescriptors:(NSArray *)descriptors {
    DDLogVerbose(@"%@ onGetDescriptors: %@", LOG_TAG, descriptors);
        
}

- (void)onMarkDescriptorDeleted:(TLDescriptor *)descriptor {
    DDLogVerbose(@"%@ onMarkDescriptorDeleted: %@", LOG_TAG, descriptor);
    
    TLDescriptorId *descriptorId = descriptor.descriptorId;
    for (Item *item in self.items) {
        if ([item.descriptorId isEqual:descriptorId]) {
            [self.items removeObject:item];
            break;
        }
    }
    
    if (self.items.count == 0) {
        [self finish];
    } else {
        [self.mediaCollectionView reloadData];
    }
}

- (void)onDeleteDescriptors:(NSSet<TLDescriptorId *> *)descriptors {
    DDLogVerbose(@"%@ onDeleteDescriptors: %@", LOG_TAG, descriptors);
        
    int countDescriptor = 0;
    for (int i = 0; i < [self.items count]; i++) {
        Item *item = [self.items objectAtIndex:i];
        if ([descriptors containsObject:item.descriptorId]) {
            [self.items removeObject:item];
            i--;
            countDescriptor++;
            
            if (countDescriptor == [descriptors count]) {
                break;
            }
        }
    }
    
    if (self.items.count == 0) {
        [self finish];
    } else {
        [self.mediaCollectionView reloadData];
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    DDLogVerbose(@"%@ numberOfSectionsInCollectionView: %@", LOG_TAG, collectionView);
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ collectionView: %@ numberOfItemsInSection: %ld", LOG_TAG, collectionView, (long)section);
    
    return self.items.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ collectionView: %@ layout: %@ sizeForItemAtIndexPath: %@", LOG_TAG, collectionView, collectionViewLayout, indexPath);
    
    if (UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation])) {
        return CGSizeMake(Design.DISPLAY_HEIGHT, Design.DISPLAY_WIDTH);
    }
    
    return CGSizeMake(Design.DISPLAY_WIDTH, Design.DISPLAY_HEIGHT);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    DDLogVerbose(@"%@ collectionView: %@ layout: %@ minimumLineSpacingForSectionAtIndex: %ld", LOG_TAG, collectionView, collectionViewLayout, (long)section);
    
    return CGFLOAT_MIN;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ collectionView: %@ layout: %@ referenceSizeForHeaderInSection: %ld", LOG_TAG, collectionView, collectionViewLayout, (long)section);
    
    return CGSizeMake(0, 0);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ collectionView: %@ cellForItemAtIndexPath: %@", LOG_TAG, collectionView, indexPath);
            
    Item *item = [self.items objectAtIndex:indexPath.row];
    
    if (item.type == ItemTypeImage || item.type == ItemTypePeerImage) {
        FullScreenImageCell *fullScreenImageCell = [collectionView dequeueReusableCellWithReuseIdentifier:FULL_SCREEN_IMAGE_CELL_IDENTIFIER forIndexPath:indexPath];
        [fullScreenImageCell bindWithItem:item];
        return fullScreenImageCell;
    } else {
        FullScreenVideoCell *fullScreenVideoCell = [collectionView dequeueReusableCellWithReuseIdentifier:FULL_SCREEN_VIDEO_CELL_IDENTIFIER forIndexPath:indexPath];
        fullScreenVideoCell.fullScreenMediaDelegate = self;
        [fullScreenVideoCell bindWithItem:item];
        return fullScreenVideoCell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ collectionView: %@ didEndDisplayingCell: %@", LOG_TAG, collectionView, indexPath);
    
    if (indexPath.row < [self.items count]) {
        Item *item = [self.items objectAtIndex:indexPath.row];
        
        if (item.type == ItemTypeImage || item.type == ItemTypePeerImage) {
            if ([cell isKindOfClass:[FullScreenImageCell class]]) {
                FullScreenImageCell *fullScreenImageCell = (FullScreenImageCell *)cell;
                [fullScreenImageCell resetZoom];
            }
        } else if (item.type == ItemTypeVideo || item.type == ItemTypePeerVideo) {
            if ([cell isKindOfClass:[FullScreenVideoCell class]]) {
                FullScreenVideoCell *fullScreenVideoCell = (FullScreenVideoCell *)cell;
                [fullScreenVideoCell stopVideo];
            }
        }
    }
}

- (CGPoint)collectionView:(UICollectionView *)collectionView targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset {
    DDLogVerbose(@"%@ collectionView: %@ targetContentOffsetForProposedContentOffset: %f", LOG_TAG, collectionView, proposedContentOffset.x);
    
    if (self.currentItemIndex != -1) {
        UICollectionViewLayoutAttributes *attributes = [self.mediaCollectionView layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:self.currentItemIndex inSection:0]];
        
        return attributes.frame.origin;
    }
    
    return proposedContentOffset;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
            
    if (indexPath.row < [self.items count]) {
        Item *item = [self.items objectAtIndex:indexPath.row];
        
        BOOL copyAllowed = YES;
        
        switch (item.type) {
            case ItemTypePeerImage: {
                PeerImageItem *peerImageItem = (PeerImageItem *)item;
                copyAllowed = peerImageItem.imageDescriptor.copyAllowed && peerImageItem.imageDescriptor.expireTimeout == 0;
                }
                break;
                
            case ItemTypePeerVideo: {
                PeerVideoItem *peerVideoItem = (PeerVideoItem *)item;
                copyAllowed = peerVideoItem.videoDescriptor.copyAllowed && peerVideoItem.videoDescriptor.expireTimeout == 0;
                }
                break;
                
            default:
                break;
        }
        
        if (!copyAllowed) {
            self.shareItemView.alpha = 0.5f;
            self.saveItemView.alpha = 0.5f;
        } else {
            self.shareItemView.alpha = 1.f;
            self.saveItemView.alpha = 1.f;
        }
        
        if (item.type == ItemTypeVideo || item.type == ItemTypePeerVideo) {
            FullScreenVideoCell *fullScreenVideoCell = (FullScreenVideoCell *)cell;
            [fullScreenVideoCell playVideoWithAudioSession:self.audioSessionManager];
            // Record the video item so that we can stop it correctly if we leave the view.
            self.videoItem = fullScreenVideoCell;
        }
    }
}

- (void)didTapContent {
    DDLogVerbose(@"%@ didTapContent", LOG_TAG);
    
    if (self.hideAction) {
        self.hideAction = NO;
        self.footerView.hidden = NO;
        self.headerView.hidden = NO;
    } else {
        self.hideAction = YES;
        self.footerView.hidden = YES;
        self.headerView.hidden = YES;
    }
}

#pragma mark - ConfirmViewDelegate

- (void)didTapConfirm:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didTapConfirm: %@", LOG_TAG, abstractConfirmView);
    
    [self getVisibleItem];
    
    if (!self.currentItem) {
        return;
    }
    
    if (self.currentItem.isPeerItem) {
        [self.conversationFileService deleteDescriptorWithDescriptorId:self.currentItem.descriptorId];
    } else {
        [self.conversationFileService markDescriptorDeletedWithDescriptorId:self.currentItem.descriptorId];
    }
    
    [abstractConfirmView closeConfirmView];
}

- (void)didTapCancel:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didTapCancel: %@", LOG_TAG, abstractConfirmView);
    
    [abstractConfirmView closeConfirmView];
}

- (void)didClose:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didClose: %@", LOG_TAG, abstractConfirmView);
    
    [abstractConfirmView closeConfirmView];
}

- (void)didFinishCloseAnimation:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didFinishCloseAnimation: %@", LOG_TAG, abstractConfirmView);
    
    [abstractConfirmView removeFromSuperview];
}


- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    
    self.currentItemIndex = [self getCurrentIndex];
    
    [self getVisibleItem];
    
    if (!self.currentItem) {
        return;
    }
    
    NSArray *visibleCells = [self.mediaCollectionView visibleCells];
    for (UICollectionViewCell *cell in visibleCells) {
        if ([cell isKindOfClass:[FullScreenImageCell class]]) {
            FullScreenImageCell *fullScreenImageCell = (FullScreenImageCell *)cell;
            [fullScreenImageCell resetZoom];
        }
    }
    
    [self.mediaCollectionView.collectionViewLayout invalidateLayout];
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    self.mediaCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.mediaCollectionView.backgroundColor = [UIColor blackColor];
    self.mediaCollectionView.pagingEnabled = YES;
    self.mediaCollectionView.dataSource = self;
    self.mediaCollectionView.delegate = self;
    [self.mediaCollectionView registerNib:[UINib nibWithNibName:@"FullScreenImageCell" bundle:nil] forCellWithReuseIdentifier:FULL_SCREEN_IMAGE_CELL_IDENTIFIER];
    [self.mediaCollectionView registerNib:[UINib nibWithNibName:@"FullScreenVideoCell" bundle:nil] forCellWithReuseIdentifier:FULL_SCREEN_VIDEO_CELL_IDENTIFIER];
    
    UICollectionViewFlowLayout *viewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    [viewFlowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [viewFlowLayout setMinimumInteritemSpacing:0];
    [viewFlowLayout setMinimumLineSpacing:0];
    if (UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation])) {
        [viewFlowLayout setItemSize:CGSizeMake(Design.DISPLAY_HEIGHT, Design.DISPLAY_WIDTH)];
    } else {
        [viewFlowLayout setItemSize:CGSizeMake(Design.DISPLAY_WIDTH, Design.DISPLAY_HEIGHT)];
    }
    [self.mediaCollectionView setCollectionViewLayout:viewFlowLayout];
    [self.mediaCollectionView reloadData];
    
    UITapGestureRecognizer *tapMediaGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleMediaTapGesture:)];
    [self.mediaCollectionView addGestureRecognizer:tapMediaGesture];
        
    self.headerViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.headerView.backgroundColor = [UIColor blackColor];
    
    self.closeViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.closeViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.closeView.userInteractionEnabled = YES;
    self.closeView.isAccessibilityElement = YES;
    self.closeView.accessibilityLabel = TwinmeLocalizedString(@"application_cancel", nil);
    [self.closeView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCloseTapGesture:)]];
    
    self.closeImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.closeImageView.tintColor = [UIColor whiteColor];
    
    self.footerViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.footerView.backgroundColor = [UIColor blackColor];
    
    self.shareItemViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.shareItemViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.shareItemView.userInteractionEnabled = YES;
    self.shareItemView.isAccessibilityElement = YES;
    
    UITapGestureRecognizer *tapShareGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleShareViewTapGesture:)];
    [self.shareItemView addGestureRecognizer:tapShareGesture];
    
    self.shareItemImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.shareItemImageView.tintColor = [UIColor whiteColor];
    
    self.saveItemViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.saveItemViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.saveItemView.userInteractionEnabled = YES;
    self.saveItemView.isAccessibilityElement = YES;
    
    UITapGestureRecognizer *tapSaveGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleSaveViewTapGesture:)];
    [self.saveItemView addGestureRecognizer:tapSaveGesture];
    
    self.saveItemImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.saveItemImageView.tintColor = [UIColor whiteColor];
    
    self.deleteItemViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.deleteItemViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.deleteItemView.userInteractionEnabled = YES;
    self.deleteItemView.isAccessibilityElement = YES;
    
    self.deleteItemImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.deleteItemImageView.tintColor = [UIColor whiteColor];
    
    UITapGestureRecognizer *tapDeleteGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleDeleteViewTapGesture:)];
    [self.deleteItemView addGestureRecognizer:tapDeleteGesture];
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);

    if (self.conversationFileService) {
        [self.conversationFileService dispose];
        self.conversationFileService = nil;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)handleMediaTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleMediaTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        
        if (self.hideAction) {
            self.hideAction = NO;
            self.footerView.hidden = NO;
            self.headerView.hidden = NO;
        } else {
            self.hideAction = YES;
            self.footerView.hidden = YES;
            self.headerView.hidden = YES;
        }
    }
}

- (void)handleCloseTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleCloseTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self finish];
    }
}

- (void)handleDeleteViewTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleDeleteViewTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self.conversationFileService getImageWithImageId:self.originator.avatarId withBlock:^(UIImage *image) {
            [self openDeleteConfirmView:image];
        }];
    }
}

- (void)handleShareViewTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleShareTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self getVisibleItem];
        
        if (!self.currentItem) {
            return;
        }
        
        BOOL copyAllowed = YES;
        BOOL isAvailable = YES;
        NSURL *urlToShare;
        
        switch (self.currentItem.type) {
            case ItemTypeImage: {
                ImageItem *imageItem = (ImageItem *)self.currentItem;
                urlToShare = [imageItem.imageDescriptor getURL];
                isAvailable = imageItem.imageDescriptor.isAvailable;
                }
                break;
                
            case ItemTypePeerImage: {
                PeerImageItem *peerImageItem = (PeerImageItem *)self.currentItem;
                urlToShare = [peerImageItem.imageDescriptor getURL];
                copyAllowed = peerImageItem.imageDescriptor.copyAllowed && peerImageItem.imageDescriptor.expireTimeout == 0;
                isAvailable = peerImageItem.imageDescriptor.isAvailable;
                }
                break;
                
            case ItemTypeVideo: {
                VideoItem *videoItem = (VideoItem *)self.currentItem;
                urlToShare = [videoItem.videoDescriptor getURL];
                isAvailable = videoItem.videoDescriptor.isAvailable;
                }
                break;
                
            case ItemTypePeerVideo: {
                PeerVideoItem *peerVideoItem = (PeerVideoItem *)self.currentItem;
                urlToShare = [peerVideoItem.videoDescriptor getURL];
                copyAllowed = peerVideoItem.videoDescriptor.copyAllowed && peerVideoItem.videoDescriptor.expireTimeout == 0;
                isAvailable = peerVideoItem.videoDescriptor.isAvailable;
                }
                break;
                
            default:
                break;
        }
        
        if (!copyAllowed) {
            [[UIApplication sharedApplication].keyWindow makeToast:TwinmeLocalizedString(@"conversation_view_controller_menu_item_view_operation_not_allowed",nil)];
            return;
        } else if (!isAvailable) {
            return;
        }
        
        if (urlToShare) {
            NSMutableArray *activityItems = [NSMutableArray arrayWithObjects:urlToShare, nil];
            
            if (activityItems) {
                UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
                
                if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                    [self presentViewController:activityViewController animated:YES completion:nil];
                } else {
                    activityViewController.modalPresentationStyle = UIModalPresentationPopover;
                    activityViewController.popoverPresentationController.sourceView = self.view;
                    activityViewController.popoverPresentationController.sourceRect = CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/4, 0, 0);
                    activityViewController.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
                    [self presentViewController:activityViewController animated:YES completion:nil];
                }
            }
        }
    }
}

- (void)handleSaveViewTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleSaveViewTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self getVisibleItem];
        
        if (!self.currentItem) {
            return;
        }
        
        if ((self.currentItem.type == ItemTypeVideo || self.currentItem.type == ItemTypePeerVideo) && self.videoItem && ![self.videoItem isVideoFormatSupported]) {
            [[UIApplication sharedApplication].keyWindow makeToast:TwinmeLocalizedString(@"conversation_view_controller_unsupported_media",nil)];
            return;
        }
        
        BOOL copyAllowed = YES;
        BOOL isAvailable = YES;
        BOOL isVideo = NO;
        NSURL *urlToSave;
        
        switch (self.currentItem.type) {
            case ItemTypeImage: {
                ImageItem *imageItem = (ImageItem *)self.currentItem;
                urlToSave = [imageItem.imageDescriptor getURL];
                isAvailable = imageItem.imageDescriptor.isAvailable;
                }
                break;
                
            case ItemTypePeerImage: {
                PeerImageItem *peerImageItem = (PeerImageItem *)self.currentItem;
                urlToSave = [peerImageItem.imageDescriptor getURL];
                copyAllowed = peerImageItem.imageDescriptor.copyAllowed && peerImageItem.imageDescriptor.expireTimeout == 0;
                isAvailable = peerImageItem.imageDescriptor.isAvailable;
                }
                break;
                
            case ItemTypeVideo: {
                VideoItem *videoItem = (VideoItem *)self.currentItem;
                urlToSave = [videoItem.videoDescriptor getURL];
                isAvailable = videoItem.videoDescriptor.isAvailable;
                isVideo = YES;
                }
                break;
                
            case ItemTypePeerVideo: {
                PeerVideoItem *peerVideoItem = (PeerVideoItem *)self.currentItem;
                urlToSave = [peerVideoItem.videoDescriptor getURL];
                copyAllowed = peerVideoItem.videoDescriptor.copyAllowed && peerVideoItem.videoDescriptor.expireTimeout == 0;
                isAvailable = peerVideoItem.videoDescriptor.isAvailable;
                isVideo = YES;
                }
                break;
                
            default:
                break;
        }
        
        if (!copyAllowed) {
            [[UIApplication sharedApplication].keyWindow makeToast:TwinmeLocalizedString(@"conversation_view_controller_menu_item_view_operation_not_allowed",nil)];
            return;
        } else if (!isAvailable) {
            return;
        }
        
        PHAuthorizationStatus photoAuthorizationStatus = [DeviceAuthorization devicePhotoAuthorizationStatus];
        switch (photoAuthorizationStatus) {
            case PHAuthorizationStatusNotDetermined: {
                if (@available(iOS 14, *)) {
                    [PHPhotoLibrary requestAuthorizationForAccessLevel:PHAccessLevelAddOnly handler:^(PHAuthorizationStatus authorizationStatus) {
                        if ([DeviceAuthorization devicePhotoAuthorizationAccessGranted:authorizationStatus]) {
                            [self saveMediaInGallery:urlToSave isVideo:isVideo];
                        }
                    }];
                } else {
                    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus authorizationStatus) {
                        if ([DeviceAuthorization devicePhotoAuthorizationAccessGranted:authorizationStatus]) {
                            [self saveMediaInGallery:urlToSave isVideo:isVideo];
                        }
                    }];
                }
                break;
            }
                
            case PHAuthorizationStatusRestricted:
            case PHAuthorizationStatusDenied:
                [DeviceAuthorization showPhotoSettingsAlertInController:self];
                break;
                
            case PHAuthorizationStatusAuthorized:
            case PHAuthorizationStatusLimited:
                [self saveMediaInGallery:urlToSave isVideo:isVideo];
                break;
        }
    }
}

- (void)saveMediaInGallery:(NSURL *)urlToSave isVideo:(BOOL)isVideo {
    DDLogVerbose(@"%@ saveMediaInGallery", LOG_TAG);
        
    if (urlToSave) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title = %@", TwinmeLocalizedString(@"application_name", nil)];
        PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
        fetchOptions.predicate = predicate;
        PHFetchResult *result = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:fetchOptions];
        
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetCollectionChangeRequest *albumRequest;
            if (result.count == 0) {
                albumRequest = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:TwinmeLocalizedString(@"application_name", nil)];
            } else {
                albumRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:result.firstObject];
            }
            
            if (isVideo) {
                PHAssetChangeRequest *createVideoRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:urlToSave];
                [albumRequest addAssets:@[createVideoRequest.placeholderForCreatedAsset]];
            } else {
                PHAssetChangeRequest *createImageRequest = [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:urlToSave];
                [albumRequest addAssets:@[createImageRequest.placeholderForCreatedAsset]];
            }
        } completionHandler:^(BOOL success, NSError *error) {
            if (success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[UIApplication sharedApplication].keyWindow makeToast:TwinmeLocalizedString(@"conversation_view_controller_menu_item_view_save_message",nil)];
                    
                });
            }
        }];
    }
}

- (void)getVisibleItem {
    DDLogVerbose(@"%@ getVisibleItem", LOG_TAG);
    
    NSArray *indexPaths = self.mediaCollectionView.indexPathsForVisibleItems;
    
    if (indexPaths.count > 0) {
        NSIndexPath *first = [indexPaths firstObject];
        self.currentItem = [self.items objectAtIndex:first.row];
    }
}

- (NSInteger)getCurrentIndex {
    DDLogVerbose(@"%@ getCurrentIndex", LOG_TAG);
    
    NSArray *indexPaths = self.mediaCollectionView.indexPathsForVisibleItems;
    
    if (indexPaths.count > 0) {
        NSIndexPath *first = [indexPaths firstObject];
        return first.row;
    }
    
    return -1;
}

- (void)openDeleteConfirmView:(UIImage *)avatar {
    DDLogVerbose(@"%@ openDeleteConfirmView", LOG_TAG);
    
    [self getVisibleItem];
    
    if (!self.currentItem) {
        return;
    }
    
    BOOL copyAllowed = YES;
    
    switch (self.currentItem.type) {
        case ItemTypePeerImage: {
            PeerImageItem *peerImageItem = (PeerImageItem *)self.currentItem;
            copyAllowed = peerImageItem.imageDescriptor.copyAllowed && peerImageItem.imageDescriptor.expireTimeout == 0;
            }
            break;
            
        case ItemTypePeerVideo: {
            PeerVideoItem *peerVideoItem = (PeerVideoItem *)self.currentItem;
            copyAllowed = peerVideoItem.videoDescriptor.copyAllowed && peerVideoItem.videoDescriptor.expireTimeout == 0;
            }
            break;
            
        default:
            break;
    }
    
    NSString *message = TwinmeLocalizedString(@"cleanup_view_controller_delete_confirmation_message", nil);

    if (!copyAllowed) {
        message = TwinmeLocalizedString(@"application_operation_irreversible", nil);
    }

    DeleteConfirmView *deleteConfirmView = [[DeleteConfirmView alloc] init];
    deleteConfirmView.confirmViewDelegate = self;
    deleteConfirmView.deleteConfirmType = DeleteConfirmTypeFile;
    [deleteConfirmView initWithTitle:TwinmeLocalizedString(@"delete_account_view_controller_warning", nil) message:message avatar:avatar icon:[UIImage imageNamed:@"ActionBarDelete"]];
   
    [self.view addSubview:deleteConfirmView];
    [deleteConfirmView showConfirmView];
}

@end

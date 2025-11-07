/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinlife/TLConversationService.h>
#import <Twinme/TLOriginator.h>
#import <Twinme/TLMessage.h>

#import <Utils/NSString+Utils.h>

#import "ConversationFilesViewController.h"
#import "FilePreviewViewController.h"
#import "FullScreenMediaViewController.h"

#import "MediaCell.h"
#import "DocumentCell.h"
#import "LinkCell.h"
#import "ConversationFilesSectionCell.h"

#import "Item.h"
#import "ImageItem.h"
#import "VideoItem.h"
#import "PeerImageItem.h"
#import "PeerVideoItem.h"
#import "FileItem.h"
#import "PeerFileItem.h"
#import "LinkItem.h"
#import "PeerLinkItem.h"

#import "UICustomTab.h"
#import "UIFileSection.h"

#import "CustomTabView.h"
#import "DeleteConfirmView.h"
#import "ItemSelectedActionView.h"

#import <TwinmeCommon/AsyncManager.h>
#import <TwinmeCommon/ConversationFilesService.h>
#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static NSString *CONVERSATION_FILES_SECTION_CELL_IDENTIFIER = @"ConversationFilesSectionCellIdentifier";
static NSString *MEDIA_CELL_IDENTIFIER = @"MediaCellIdentifier";
static NSString *DOCUMENT_CELL_IDENTIFIER = @"DocumentCellIdentifier";
static NSString *LINK_CELL_IDENTIFIER = @"LinkCellIdentifier";

static CGFloat DESIGN_MEDIA_CELL_SIZE;
static CGFloat DESIGN_SAFE_AREA_HEIGHT_INSET = 0;
static CGFloat DESIGN_DOCUMENTS_CELL_HEIGHT = 252;
static CGFloat DESIGN_SECTION_CELL_HEIGHT = 80;

typedef enum {
    TLTypeFileImage,
    TLTypeFileVideo,
    TLTypeFileDocument,
    TLTypeFileLink
} TLTypeFile;

//
// Interface: ConversationFilesViewController ()
//

@interface ConversationFilesViewController ()<ConversationFilesServiceDelegate, UICollectionViewDelegate, UICollectionViewDataSource, AsyncLoaderDelegate, CustomTabViewDelegate, ItemSelectedActionViewDelegate, ConfirmViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *filesCollectionViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UICollectionView *filesCollectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noFilesImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noFilesImageViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noFilesImageViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *noFilesImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noFilesLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noFilesLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *noFilesLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *customTabViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *customTabContainerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *itemSelectedActionViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *itemSelectedActionContainerView;

@property (nonatomic) CustomTabView *customTabView;
@property (nonatomic) ItemSelectedActionView *itemSelectedActionView;
@property (nonatomic) UIBarButtonItem *selectBarButtonItem;

@property (nonatomic) TLTypeFile typeFile;
@property (nonatomic) ConversationFilesService *conversationFileService;
@property (nonatomic) id<TLOriginator> originator;
@property (nonatomic) NSUUID *conversationId;

@property (nonatomic) NSMutableArray<Item *> *items;
@property (nonatomic) NSMutableArray<Item *> *selectedItems;
@property (nonatomic) NSArray<UIFileSection *> *filesSection;
@property (nonatomic) NSIndexPath *lastIndexPath;

@property (nonatomic) BOOL isSelectMode;
@property (nonatomic) AsyncManager *asyncLoaderManager;

@end

#undef LOG_TAG
#define LOG_TAG @"ConversationFilesViewController"

@implementation ConversationFilesViewController

#pragma mark - UIViewController

+ (void)initialize {
    DDLogVerbose(@"%@ initialize", LOG_TAG);
    
    int mediaPerLine = 3;
    if (Design.DISPLAY_WIDTH > 320) {
        mediaPerLine = 4;
    }
    DESIGN_MEDIA_CELL_SIZE = Design.DISPLAY_WIDTH / mediaPerLine;
    
    UIWindow *window = UIApplication.sharedApplication.keyWindow;
    DESIGN_SAFE_AREA_HEIGHT_INSET = window.safeAreaInsets.bottom;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _conversationFileService = [[ConversationFilesService alloc] initWithTwinmeContext:self.twinmeContext delegate:self];
        _items = [[NSMutableArray alloc]init];
        _selectedItems = [[NSMutableArray alloc]init];
        _isSelectMode = NO;
        _asyncLoaderManager = [[AsyncManager alloc] initWithTwinmeContext:self.twinmeContext delegate:self];
    }
    return self;
}

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
    
    [self initViews];
}

- (void)viewWillAppear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillAppear: %@", LOG_TAG, animated ? @"YES" : @"NO");
    
    [super viewWillAppear:animated];
    
    if (self.originator && self.items.count == 0) {
        [self.conversationFileService initWithOriginator:self.originator];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillDisappear: %@", LOG_TAG, animated ? @"YES" : @"NO");
    
    [super viewWillDisappear:animated];
    
    [self.asyncLoaderManager clear];
}

- (void)viewDidLayoutSubviews {
    DDLogVerbose(@"%@ viewDidLayoutSubviews", LOG_TAG);
    
    [super viewDidLayoutSubviews];
    
    if (!self.customTabView) {
        [self initCustomTab];
    }
    
    if (!self.itemSelectedActionView) {
        [self initSelectedView];
    }
}

- (void)initWithOriginator:(id<TLOriginator>)originator {
    DDLogVerbose(@"%@ initWithOriginator: %@", LOG_TAG, originator);
    
    self.originator = originator;
}

#pragma mark - Async Loader

- (void)onLoadedWithItems:(nonnull NSMutableArray<id<NSObject>> *)items {
    DDLogVerbose(@"%@ onLoadedWithItems: %@", LOG_TAG, items);
        
    for (Item *item in items) {
        NSIndexPath *indexPath = [self indexPathForItem:item];
        if (indexPath) {
            switch (item.type) {
                case ItemTypeImage:
                case ItemTypePeerImage:
                case ItemTypeVideo:
                case ItemTypePeerVideo: {
                    MediaCell *mediaCell = (MediaCell *)[self.filesCollectionView cellForItemAtIndexPath:indexPath];
                    [mediaCell bindWithItem:item asyncManager:self.asyncLoaderManager size:DESIGN_MEDIA_CELL_SIZE isSelectable:self.isSelectMode];
                    break;
                }
                    
                case ItemTypeLink:
                case ItemTypePeerLink: {
                    LinkCell *linkCell = (LinkCell *)[self.filesCollectionView cellForItemAtIndexPath:indexPath];
                    BOOL showPreview = NO;
                    if (@available(iOS 13.0, *)) {
                        showPreview = self.twinmeApplication.visualizationLink;
                    }
                    [linkCell bindWithItem:item asyncManager:self.asyncLoaderManager isSelectable:self.isSelectMode showPreview:showPreview];
                    break;
                }
                
                default:
                    break;
            }
        }
    }
}

- (NSIndexPath *)indexPathForItem:(Item *)item {
    DDLogVerbose(@"%@ indexPathForItem: %@", LOG_TAG, item);
    
    int section = 0;
    for (UIFileSection *fileSection in self.filesSection) {
        int row = 0;
        for (Item *lItem in [fileSection getItems]) {
            if ([lItem.descriptorId isEqual:item.descriptorId]) {
                return [NSIndexPath indexPathForRow:row inSection:section];
            }
            row++;
        }
        section++;
    }
    
    return nil;
}

#pragma mark - ConversationFilesServiceDelegate

- (void)onGetConversation:(id<TLConversation>)conversation {
    DDLogVerbose(@"%@ onGetConversation: %@", LOG_TAG, conversation);
    
    self.conversationId = conversation.uuid;
}

- (void)onGetDescriptors:(NSArray *)descriptors {
    DDLogVerbose(@"%@ onGetDescriptors: %@", LOG_TAG, descriptors);
        
    for (TLDescriptor *descriptor in descriptors) {
        
        if (descriptor.deletedTimestamp == 0) {
            switch (descriptor.getType) {
                case TLDescriptorTypeObjectDescriptor: {
                    TLObjectDescriptor *objectDescriptor = (TLObjectDescriptor *)descriptor;
                    [self addObjectDescriptor:objectDescriptor];
                    break;
                }
                    
                case TLDescriptorTypeImageDescriptor: {
                    TLImageDescriptor *imageDescriptor = (TLImageDescriptor *)descriptor;
                    [self addImageDescriptor:imageDescriptor];
                    break;
                }
                    
                case TLDescriptorTypeVideoDescriptor: {
                    TLVideoDescriptor *videoDescriptor = (TLVideoDescriptor *)descriptor;
                    [self addVideoDescriptor:videoDescriptor];
                    break;
                }
                    
                case TLDescriptorTypeNamedFileDescriptor: {
                    TLNamedFileDescriptor *namedFileDescriptor = (TLNamedFileDescriptor *)descriptor;
                    if ([namedFileDescriptor isAvailable]) {
                        [self addNamedFileDescriptor:namedFileDescriptor];
                    }
                    break;
                }
                    
                default:
                    break;
            }
        }
    }
    
    [self reloadData];
}

- (void)onMarkDescriptorDeleted:(TLDescriptor *)descriptor {
    DDLogVerbose(@"%@ onMarkDescriptorDeleted: %@", LOG_TAG, descriptor);
    
    TLDescriptorId *descriptorId = descriptor.descriptorId;
    if (!self.isSelectMode) {
        for (Item *item in self.items) {
            if ([item.descriptorId isEqual:descriptorId]) {
                [self.items removeObject:item];
                break;
            }
        }
        
        [self reloadData];
    } else {
        for (Item *item in self.selectedItems) {
            if ([item.descriptorId isEqual:descriptorId]) {
                [self.items removeObject:item];
                [self.selectedItems removeObject:item];
                break;
            }
        }
        
        if (self.selectedItems.count == 0) {
            [self.itemSelectedActionView updateSelectedItems:0];
            [self reloadData];
        }
    }
}

- (void)onDeleteDescriptors:(NSSet<TLDescriptorId *> *)descriptors {
    DDLogVerbose(@"%@ onDeleteDescriptors: %@", LOG_TAG, descriptors);

    if (!self.isSelectMode) {
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
        
        [self reloadData];
    } else {
        int countDescriptor = 0;
        for (int i = 0; i < [self.selectedItems count]; i++) {
            Item *item = [self.selectedItems objectAtIndex:i];
            if ([descriptors containsObject:item.descriptorId]) {
                [self.items removeObject:item];
                [self.selectedItems removeObject:item];
                i--;
                countDescriptor++;
                
                if (countDescriptor == [descriptors count]) {
                    break;
                }
            }
        }
        
        if (self.selectedItems.count == 0) {
            [self.itemSelectedActionView updateSelectedItems:0];
            [self reloadData];
        }
    }
    
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    DDLogVerbose(@"%@ numberOfSectionsInCollectionView: %@", LOG_TAG, collectionView);
    
    if (!self.filesSection) {
        return 0;
    }
    
    return self.filesSection.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ collectionView: %@ numberOfItemsInSection: %ld", LOG_TAG, collectionView, (long)section);
    
    UIFileSection *fileSection = [self.filesSection objectAtIndex:section];
    return fileSection.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ collectionView: %@ layout: %@ sizeForItemAtIndexPath: %@", LOG_TAG, collectionView, collectionViewLayout, indexPath);
    
    if (self.typeFile == TLTypeFileImage || self.typeFile == TLTypeFileVideo) {
        return CGSizeMake(DESIGN_MEDIA_CELL_SIZE, DESIGN_MEDIA_CELL_SIZE);
        
    } else {
        return CGSizeMake(Design.DISPLAY_WIDTH, DESIGN_DOCUMENTS_CELL_HEIGHT * Design.HEIGHT_RATIO);
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ collectionView: %@ layout: %@ referenceSizeForHeaderInSection: %ld", LOG_TAG, collectionView, collectionViewLayout, (long)section);
    
    return CGSizeMake(Design.DISPLAY_WIDTH, DESIGN_SECTION_CELL_HEIGHT * Design.HEIGHT_RATIO);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ collectionView: %@ viewForSupplementaryElementOfKind: %@", LOG_TAG, collectionView, indexPath);
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        ConversationFilesSectionCell *conversationFilesSectionCell = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:CONVERSATION_FILES_SECTION_CELL_IDENTIFIER forIndexPath:indexPath];
        
        UIFileSection *fileSection = [self.filesSection objectAtIndex:indexPath.section];
        [conversationFilesSectionCell bindWithTitle:[fileSection getTitle]];
        return conversationFilesSectionCell;
    }
    
    return [[UICollectionViewCell alloc]init];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ collectionView: %@ cellForItemAtIndexPath: %@", LOG_TAG, collectionView, indexPath);
    
    if (self.lastIndexPath != nil && [self.lastIndexPath isEqual:indexPath] && ![self.conversationFileService isGetDescriptorDone]) {
        [self.conversationFileService getPreviousDescriptors];
    }
    
    UIFileSection *fileSection = [self.filesSection objectAtIndex:indexPath.section];
    Item *item = [[fileSection getItems] objectAtIndex:indexPath.row];
    
    if (self.typeFile == TLTypeFileImage || self.typeFile == TLTypeFileVideo) {
        MediaCell *mediaCell = [collectionView dequeueReusableCellWithReuseIdentifier:MEDIA_CELL_IDENTIFIER forIndexPath:indexPath];
        [mediaCell bindWithItem:item asyncManager:self.asyncLoaderManager size:DESIGN_MEDIA_CELL_SIZE isSelectable:self.isSelectMode];
        return mediaCell;
    } else if (self.typeFile == TLTypeFileDocument) {
        DocumentCell *documentCell = [collectionView dequeueReusableCellWithReuseIdentifier:DOCUMENT_CELL_IDENTIFIER forIndexPath:indexPath];
        [documentCell bindWithItem:item isSelectable:self.isSelectMode];
        return documentCell;
    } else {
        LinkCell *linkCell = [collectionView dequeueReusableCellWithReuseIdentifier:LINK_CELL_IDENTIFIER forIndexPath:indexPath];
        
        BOOL showPreview = NO;
        if (@available(iOS 13.0, *)) {
            showPreview = self.twinmeApplication.visualizationLink;
        }
        
        [linkCell bindWithItem:item asyncManager:self.asyncLoaderManager isSelectable:self.isSelectMode showPreview:showPreview];
        return linkCell;
    }
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ collectionView: %@ didSelectItemAtIndexPath: %@", LOG_TAG, collectionView, indexPath);
        
    UIFileSection *fileSection = [self.filesSection objectAtIndex:indexPath.section];
    Item *item = [[fileSection getItems]objectAtIndex:indexPath.row];
    
    if (!self.isSelectMode) {
        if (self.typeFile == TLTypeFileImage || self.typeFile == TLTypeFileVideo) {
            [self startFullScreenMediaViewController:item];
        } else if (self.typeFile == TLTypeFileDocument) {
            TLNamedFileDescriptor *namedFileDescriptor;
            if (item.isPeerItem) {
                PeerFileItem *peerFileItem = (PeerFileItem *)item;
                namedFileDescriptor = peerFileItem.namedFileDescriptor;
            } else {
                FileItem *fileItem = (FileItem *)item;
                namedFileDescriptor = fileItem.namedFileDescriptor;
            }
            FilePreviewViewController *filePreviewViewController = [[FilePreviewViewController alloc] init];
            filePreviewViewController.namedFileDescriptor = namedFileDescriptor;
            [self presentViewController:filePreviewViewController animated:YES completion:nil];
        } else if (self.typeFile == TLTypeFileLink) {
            NSURL *url;
            if (item.isPeerItem) {
                PeerLinkItem *peerLinkItem = (PeerLinkItem *)item;
                url = peerLinkItem.url;
            } else {
                LinkItem *linkItem = (LinkItem *)item;
                url = linkItem.url;
            }
            
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }
    } else {
        if (item.selected) {
            item.selected = NO;
            [self.selectedItems removeObject:item];
        } else {
            item.selected = YES;
            [self.selectedItems addObject:item];
        }
        
        [self.itemSelectedActionView updateSelectedItems:(int)self.selectedItems.count];
        [self.filesCollectionView reloadData];
    }
}

#pragma mark - CustomTabViewDelegate

- (void)didSelectTab:(UICustomTab *)uiCustomTab {
    DDLogVerbose(@"%@ didSelectTab: %@", LOG_TAG, uiCustomTab);
        
    switch (uiCustomTab.tag) {
        case TLTypeFileImage:
            self.typeFile = TLTypeFileImage;
            break;
            
        case TLTypeFileVideo:
            self.typeFile = TLTypeFileVideo;
            break;
            
        case TLTypeFileDocument:
            self.typeFile = TLTypeFileDocument;
            break;
            
        case TLTypeFileLink:
            self.typeFile = TLTypeFileLink;
            break;
            
        default:
            break;
    }
    
    [self reloadData];
}

#pragma mark - ItemSelectedActionViewDelegate

- (BOOL)isShareItem:(Item *)item {
    DDLogVerbose(@"%@ isShareItem", LOG_TAG);
    
    if ([item isClearLocalItem]) {
        return NO;
    } else if (item.state == ItemStateDeleted || (item.isPeerItem && (!item.copyAllowed || item.isEphemeralItem))) {
        return NO;
    } else if (!item.isAvailableItem) {
        return NO;
    }
    
    return YES;
}

- (void)didTapShareAction {
    DDLogVerbose(@"%@ didTapShareAction", LOG_TAG);
    
    NSMutableArray *activityItems = [[NSMutableArray alloc]init];
    
    for (Item *item in self.selectedItems) {
        if ([self isShareItem:item]) {
            switch (item.type) {
                case ItemTypeLink: {
                    LinkItem *linkItem = (LinkItem *)item;
                    [activityItems addObject:linkItem.content];
                    break;
                }
                    
                case ItemTypePeerLink: {
                    PeerLinkItem *peerLinkItem = (PeerLinkItem *)item;
                    [activityItems addObject:peerLinkItem.content];
                    break;
                }
                    
                case ItemTypeImage:
                case ItemTypePeerImage:
                case ItemTypeAudio:
                case ItemTypePeerAudio:
                case ItemTypeVideo:
                case ItemTypePeerVideo:
                case ItemTypeFile:
                case ItemTypePeerFile:
                    [activityItems addObject:[item getURL]];
                    break;
                    
                default:
                    break;
            }
        }
    }
    
    if (activityItems.count > 0) {
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

- (void)didTapDeleteAction {
    DDLogVerbose(@"%@ didTapDeleteAction", LOG_TAG);
    
    [self.conversationFileService getImageWithImageId:self.originator.avatarId withBlock:^(UIImage *image) {
        DeleteConfirmView *deleteConfirmView = [[DeleteConfirmView alloc] init];
        deleteConfirmView.confirmViewDelegate = self;
        deleteConfirmView.deleteConfirmType = DeleteConfirmTypeFile;
        [deleteConfirmView initWithTitle:TwinmeLocalizedString(@"delete_account_view_controller_warning", nil) message:TwinmeLocalizedString(@"cleanup_view_controller_delete_confirmation_message", nil) avatar:image icon:[UIImage imageNamed:@"ActionBarDelete"]];
       
        [self.navigationController.view addSubview:deleteConfirmView];
        [deleteConfirmView showConfirmView];
    }];
}

#pragma mark - ConfirmViewDelegate

- (void)didTapConfirm:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didTapConfirm: %@", LOG_TAG, abstractConfirmView);
    
    for (Item *item in self.selectedItems) {
        if (item.isPeerItem) {
            [self.conversationFileService deleteDescriptorWithDescriptorId:item.descriptorId];
        } else {
            [self.conversationFileService markDescriptorDeletedWithDescriptorId:item.descriptorId];
        }
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


#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.view.backgroundColor = Design.WHITE_COLOR;
        
    self.selectBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:TwinmeLocalizedString(@"application_select", nil) style:UIBarButtonItemStylePlain target:self action:@selector(handleSelectTapGesture:)];
    [self.selectBarButtonItem setTitleTextAttributes: @{NSFontAttributeName : Design.FONT_BOLD36, NSForegroundColorAttributeName: [UIColor whiteColor]} forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = self.selectBarButtonItem;
    
    [self setNavigationTitle:self.originator.name];
        
    self.filesCollectionView.backgroundColor = Design.WHITE_COLOR;
    self.filesCollectionView.dataSource = self;
    self.filesCollectionView.delegate = self;
    [self.filesCollectionView registerNib:[UINib nibWithNibName:@"ConversationFilesSectionCell" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:CONVERSATION_FILES_SECTION_CELL_IDENTIFIER];
    [self.filesCollectionView registerNib:[UINib nibWithNibName:@"MediaCell" bundle:nil] forCellWithReuseIdentifier:MEDIA_CELL_IDENTIFIER];
    [self.filesCollectionView registerNib:[UINib nibWithNibName:@"DocumentCell" bundle:nil] forCellWithReuseIdentifier:DOCUMENT_CELL_IDENTIFIER];
    [self.filesCollectionView registerNib:[UINib nibWithNibName:@"LinkCell" bundle:nil] forCellWithReuseIdentifier:LINK_CELL_IDENTIFIER];
    
    UICollectionViewFlowLayout *viewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    [viewFlowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [viewFlowLayout setMinimumInteritemSpacing:0];
    [viewFlowLayout setMinimumLineSpacing:0];
    [viewFlowLayout setItemSize:CGSizeMake(DESIGN_MEDIA_CELL_SIZE, DESIGN_MEDIA_CELL_SIZE)];
    [self.filesCollectionView setCollectionViewLayout:viewFlowLayout];
    [self.filesCollectionView reloadData];
    
    self.noFilesImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.noFilesImageViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.noFilesImageViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.noFilesImageView.hidden = YES;
    
    self.noFilesLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.noFilesLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.noFilesLabel.font = Design.FONT_MEDIUM28;
    self.noFilesLabel.textColor = Design.FONT_COLOR_DESCRIPTION;
    self.noFilesLabel.text = [NSString stringWithFormat: TwinmeLocalizedString(@"conversation_files_view_controller_no_files", nil), self.originator.name];
    self.noFilesLabel.hidden = YES;
    
    self.itemSelectedActionViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.itemSelectedActionViewHeightConstraint.constant += DESIGN_SAFE_AREA_HEIGHT_INSET;
    self.itemSelectedActionContainerView.backgroundColor = Design.NAVIGATION_BAR_BACKGROUND_COLOR;
    self.itemSelectedActionContainerView.hidden = YES;
    
    self.customTabViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
}

- (void)initCustomTab {
    DDLogVerbose(@"%@ initCustomTab", LOG_TAG);
    
    NSMutableArray *customTabs = [[NSMutableArray alloc]init];
    [customTabs addObject:[[UICustomTab alloc]initWithTitle:TwinmeLocalizedString(@"export_view_controller_images", nil) tag:TLTypeFileImage isSelected:YES]];
    [customTabs addObject:[[UICustomTab alloc]initWithTitle:TwinmeLocalizedString(@"export_view_controller_videos", nil) tag:TLTypeFileVideo isSelected:NO]];
    [customTabs addObject:[[UICustomTab alloc]initWithTitle:TwinmeLocalizedString(@"conversation_files_view_controller_documents", nil) tag:TLTypeFileDocument isSelected:NO]];
    [customTabs addObject:[[UICustomTab alloc]initWithTitle:TwinmeLocalizedString(@"conversation_files_view_controller_links", nil) tag:TLTypeFileLink isSelected:NO]];
    
    self.customTabView = [[CustomTabView alloc] initWithCustomTab:customTabs];
    self.customTabView.customTabViewDelegate = self;
    [self.customTabContainerView addSubview:self.customTabView];
}

- (void)initSelectedView {
    DDLogVerbose(@"%@ initSelectedView", LOG_TAG);
    
    self.itemSelectedActionView = [[ItemSelectedActionView alloc]init];
    self.itemSelectedActionView.itemSelectedActionViewDelegate = self;
    [self.itemSelectedActionContainerView addSubview:self.itemSelectedActionView];
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);

    [self.asyncLoaderManager stop];
    self.asyncLoaderManager = nil;
    
    if (self.conversationFileService) {
        [self.conversationFileService dispose];
        self.conversationFileService = nil;
    }
}

- (void)handleSelectTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleSelectTapGesture: %@", LOG_TAG, sender);
    
    if (self.isSelectMode) {
        self.isSelectMode = NO;
        self.itemSelectedActionContainerView.hidden = YES;
        self.selectBarButtonItem.title = TwinmeLocalizedString(@"application_select", nil);
        self.filesCollectionViewBottomConstraint.constant = 0;
        [self resetSelectedItems];
    } else {
        self.isSelectMode = YES;
        self.itemSelectedActionContainerView.hidden = NO;
        self.selectBarButtonItem.title = TwinmeLocalizedString(@"application_cancel", nil);
        self.filesCollectionViewBottomConstraint.constant = self.itemSelectedActionViewHeightConstraint.constant;
        [self.itemSelectedActionView updateSelectedItems:(int)self.selectedItems.count];
    }
    
    [self reloadData];
}

- (void)resetSelectedItems {
    DDLogVerbose(@"%@ resetSelectedItems", LOG_TAG);
    
    for (Item *item in self.selectedItems) {
        item.selected = NO;
    }
    
    [self.selectedItems removeAllObjects];
}

- (void)addObjectDescriptor:(TLObjectDescriptor *)objectDescriptor {
    DDLogVerbose(@"%@ addObjectDescriptor: %@", LOG_TAG, objectDescriptor);
    

        if ([self.conversationFileService isLocalDescriptor:objectDescriptor]) {
            NSError *error = nil;
            NSDataDetector *dataDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
            NSString *content = objectDescriptor.message;
            
            NSTextCheckingResult *firstMatch = [dataDetector firstMatchInString:content options:0 range:NSMakeRange(0, [content length])];
            if (firstMatch) {
                LinkItem *linkItem = [[LinkItem alloc] initWithObjectDescriptor:objectDescriptor replyToDescriptor:nil url:[firstMatch URL]];
                [self.items addObject:linkItem];
                return;
            }
        } else if ([self.conversationFileService isPeerDescriptor:objectDescriptor]) {
            NSError *error = nil;
            NSDataDetector *dataDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
            NSString *content = objectDescriptor.message;
            
            NSTextCheckingResult *firstMatch = [dataDetector firstMatchInString:content options:0 range:NSMakeRange(0, [content length])];
            if (firstMatch) {
                PeerLinkItem *peerLinkItem = [[PeerLinkItem alloc] initWithObjectDescriptor:objectDescriptor replyToDescriptor:nil url:[firstMatch URL]];
                [self.items addObject:peerLinkItem];
                return;
            }
        }
}

- (void)addImageDescriptor:(TLImageDescriptor *)imageDescriptor {
    DDLogVerbose(@"%@ addImageDescriptor: %@", LOG_TAG, imageDescriptor);
    
    if ([self.conversationFileService isLocalDescriptor:imageDescriptor]) {
        ImageItem *imageItem = [[ImageItem alloc] initWithImageDescriptor:imageDescriptor replyToDescriptor:nil];
        [self.items addObject:imageItem];
    } else if ([self.conversationFileService isPeerDescriptor:imageDescriptor]) {
        PeerImageItem *peerImageItem = [[PeerImageItem alloc] initWithImageDescriptor:imageDescriptor replyToDescriptor:nil];
        [self.items addObject:peerImageItem];
    }
}

- (void)addVideoDescriptor:(TLVideoDescriptor *)videoDescriptor {
    DDLogVerbose(@"%@ addVideoDescriptor: %@", LOG_TAG, videoDescriptor);
    
    if ([self.conversationFileService isLocalDescriptor:videoDescriptor]) {
        VideoItem *videoItem = [[VideoItem alloc] initWithVideoDescriptor:videoDescriptor replyToDescriptor:nil];
        [self.items addObject:videoItem];
    } else if ([self.conversationFileService isPeerDescriptor:videoDescriptor]) {
        PeerVideoItem *peerVideoItem = [[PeerVideoItem alloc] initWithVideoDescriptor:videoDescriptor replyToDescriptor:nil];
        [self.items addObject:peerVideoItem];
    }
}

- (void)addNamedFileDescriptor:(TLNamedFileDescriptor *)namedFileDescriptor {
    DDLogVerbose(@"%@ addNamedFileDescriptor: %@", LOG_TAG, namedFileDescriptor);
    
    if ([self.conversationFileService isLocalDescriptor:namedFileDescriptor]) {
        FileItem *fileItem = [[FileItem alloc] initWithNamedFileDescriptor:namedFileDescriptor replyToDescriptor:nil];
        [self.items addObject:fileItem];
    } else if ([self.conversationFileService isPeerDescriptor:namedFileDescriptor]) {
        PeerFileItem *peerFileItem = [[PeerFileItem alloc] initWithFileDescriptor:namedFileDescriptor replyToDescriptor:nil];
        [self.items addObject:peerFileItem];;
    }
}

- (BOOL)isSelectedType:(Item *)item {
    DDLogVerbose(@"%@ isSelectedType: %@", LOG_TAG, item);
    
    if (self.typeFile == TLTypeFileImage && (item.type == ItemTypeImage || item.type == ItemTypePeerImage)) {
        return YES;
    } else if (self.typeFile == TLTypeFileVideo && (item.type == ItemTypeVideo || item.type == ItemTypePeerVideo)) {
        return YES;
    } else if (self.typeFile == TLTypeFileLink && (item.type == ItemTypeLink || item.type == ItemTypePeerLink)) {
        return YES;
    } else if (self.typeFile == TLTypeFileDocument && (item.type == ItemTypeFile || item.type == ItemTypePeerFile)) {
        return YES;
    }
    
    return NO;
}

- (void)startFullScreenMediaViewController:(Item *)item {
    DDLogVerbose(@"%@ startFullScreenMediaViewController", LOG_TAG);
    
    int index = 0;
    int itemIndex = 0;
    NSMutableArray *medias = [[NSMutableArray alloc]init];
    for (UIFileSection *fileSection in self.filesSection) {
        for (Item *lItem in [fileSection getItems]) {
            [medias addObject:lItem];
            if ([lItem.descriptorId isEqual:item.descriptorId]) {
                itemIndex = index;
            }
            index++;
        }
    }
    
    FullScreenMediaViewController *fullscreenMediaViewController = (FullScreenMediaViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"FullScreenMediaViewController"];
    [fullscreenMediaViewController initWithItems:medias atIndex:itemIndex conversationId:self.conversationId originator:self.originator];
    [self presentViewController:fullscreenMediaViewController animated:YES completion:nil];
}

- (void)reloadData {
    DDLogVerbose(@"%@ reloadData", LOG_TAG);
    
    NSMutableDictionary *periodDictionnary = [[NSMutableDictionary alloc]init];
    
    for (Item *item in self.items) {
        if ([self isSelectedType:item] && ![item isClearLocalItem]) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"YYYY-MM"];
            NSString *periodKey = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:item.createdTimestamp / 1000]];
            if ([periodDictionnary objectForKey:periodKey]) {
                UIFileSection *fileSection = [periodDictionnary objectForKey:periodKey];
                [fileSection addItem:item];
            } else {
                UIFileSection *fileSection = [[UIFileSection alloc]initWithPeriod:periodKey];
                [fileSection addItem:item];
                [periodDictionnary setObject:fileSection forKey:periodKey];
            }
        }
    }
    
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:nil ascending:NO selector:@selector(caseInsensitiveCompare:)];
    NSArray *allKeys = [periodDictionnary.allKeys sortedArrayUsingDescriptors:@[sortDescriptor]];
    
    self.filesSection = [periodDictionnary objectsForKeys:allKeys notFoundMarker:[NSNull null]];
        
    if (self.filesSection.count == 0) {
        self.noFilesImageView.hidden = NO;
        self.noFilesLabel.hidden = NO;
        if (!self.isSelectMode) {
            self.selectBarButtonItem.enabled = NO;
        }
        self.lastIndexPath = nil;
    } else {
        self.noFilesImageView.hidden = YES;
        self.noFilesLabel.hidden = YES;
        self.selectBarButtonItem.enabled = YES;
        UIFileSection *lastSection = [self.filesSection lastObject];
        self.lastIndexPath = [NSIndexPath indexPathForRow:lastSection.count - 1 inSection:self.filesSection.count - 1];
    }
    
    [self.filesCollectionView reloadData];

    if (self.filesSection.count == 0 && ![self.conversationFileService isGetDescriptorDone]) {
        [self.conversationFileService getPreviousDescriptors];
    }
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.noFilesLabel.font = Design.FONT_MEDIUM28;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
 
    self.noFilesLabel.textColor = Design.FONT_COLOR_DESCRIPTION;
    self.itemSelectedActionContainerView.backgroundColor = Design.NAVIGATION_BAR_BACKGROUND_COLOR;
}

@end

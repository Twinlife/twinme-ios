/*
 *  Copyright (c) 2019-2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinme/TLContact.h>
#import <Twinme/TLGroup.h>
#import <Twinme/TLGroupMember.h>
#import <Twinlife/TLTwincodeOutboundService.h>
#import <TwinmeCommon/AbstractTwinmeService+Protected.h>

#import <Utils/NSString+Utils.h>

#import "InfoItemViewController.h"
#import "MessageSettingsViewController.h"

#import "Item.h"
#import "TimeItem.h"
#import "MessageItem.h"
#import "PeerMessageItem.h"
#import "LinkItem.h"
#import "PeerLinkItem.h"
#import "ImageItem.h"
#import "PeerImageItem.h"
#import "AudioItem.h"
#import "PeerAudioItem.h"
#import "VideoItem.h"
#import "PeerVideoItem.h"
#import "FileItem.h"
#import "PeerFileItem.h"
#import "PollItem.h"
#import "PeerPollItem.h"
#import "InvitationItem.h"
#import "PeerInvitationItem.h"
#import "CallItem.h"
#import "PeerCallItem.h"
#import "LocationItem.h"
#import "PeerLocationItem.h"
#import "InvitationContactItem.h"
#import "PeerInvitationContactItem.h"
#import "NameItem.h"
#import "ClearItem.h"
#import "PeerClearItem.h"
#import "InfoAnnotationItem.h"
#import "InfoCopyItem.h"
#import "InfoDateItem.h"
#import "InfoDeletedItem.h"
#import "InfoEphemeralItem.h"
#import "InfoFileItem.h"
#import "InfoSectionItem.h"

#import "TimeItemCell.h"
#import "MessageItemCell.h"
#import "PeerMessageItemCell.h"
#import "LinkItemCell.h"
#import "PeerLinkItemCell.h"
#import "ImageItemCell.h"
#import "PeerImageItemCell.h"
#import "AudioItemCell.h"
#import "PeerAudioItemCell.h"
#import "VideoItemCell.h"
#import "PeerVideoItemCell.h"
#import "FileItemCell.h"
#import "PeerFileItemCell.h"
#import "PollItemCell.h"
#import "PeerPollItemCell.h"
#import "InvitationItemCell.h"
#import "PeerInvitationItemCell.h"
#import "NameItemCell.h"
#import "InfoDateItemCell.h"
#import "InfoFileItemCell.h"
#import "InfoIconItemCell.h"
#import "CopyItemCell.h"
#import "CallItemCell.h"
#import "PeerCallItemCell.h"
#import "LocationItemCell.h"
#import "PeerLocationItemCell.h"
#import "LocationCoordinateItemCell.h"
#import "PeerLocationCoordinateItemCell.h"
#import "ClearItemCell.h"
#import "PeerClearItemCell.h"
#import "InvitationContactItemCell.h"
#import "PeerInvitationContactItemCell.h"
#import "AnnotationInfoCell.h"
#import "SettingsSectionHeaderCell.h"
#import "SettingsItemCell.h"

#import "SwitchView.h"
#import "UIAnnotation.h"
#import "UIReaction.h"

#import <TwinmeCommon/AsyncManager.h>
#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/InfoItemService.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static NSString *TIME_ITEM_CELL_IDENTIFIER = @"TimeItemCellIdentifier";
static NSString *MESSAGE_ITEM_CELL_IDENTIFIER = @"MessageItemCellIdentifier";
static NSString *PEER_MESSAGE_ITEM_CELL_IDENTIFIER = @"PeerMessageItemCellIdentifier";
static NSString *LINK_ITEM_CELL_IDENTIFIER = @"LinkItemCellIdentifier";
static NSString *PEER_LINK_ITEM_CELL_IDENTIFIER = @"PeerLinkItemCellIdentifier";
static NSString *IMAGE_ITEM_CELL_IDENTIFIER = @"ImageItemCellIdentifier";
static NSString *PEER_IMAGE_ITEM_CELL_IDENTIFIER = @"PeerImageItemCellIdentifier";
static NSString *AUDIO_ITEM_CELL_IDENTIFIER = @"AudioItemCellIdentifier";
static NSString *PEER_AUDIO_ITEM_CELL_IDENTIFIER = @"PeerAudioItemCellIdentifier";
static NSString *VIDEO_ITEM_CELL_IDENTIFIER = @"VideoItemCellIdentifier";
static NSString *PEER_VIDEO_ITEM_CELL_IDENTIFIER = @"PeerVideoItemCellIdentifier";
static NSString *FILE_ITEM_CELL_IDENTIFIER = @"FileItemCellIdentifier";
static NSString *PEER_FILE_ITEM_CELL_IDENTIFIER = @"PeerFileItemCellIdentifier";
static NSString *POLL_ITEM_CELL_IDENTIFIER = @"PollItemCellIdentifier";
static NSString *PEER_POLL_ITEM_CELL_IDENTIFIER = @"PeerPollItemCellIdentifier";
static NSString *INVITATION_ITEM_CELL_IDENTIFIER = @"InvitationItemCellIdentifier";
static NSString *PEER_INVITATION_ITEM_CELL_IDENTIFIER = @"PeerInvitationItemCellIdentifier";
static NSString *NAME_ITEM_CELL_IDENTIFIER = @"NameItemCellIdentifier";
static NSString *INFO_DATE_ITEM_CELL_IDENTIFIER = @"InfoDateItemCellIdentifier";
static NSString *COPY_ITEM_CELL_IDENTIFIER = @"CopyItemCellIdentifier";
static NSString *INFO_FILE_ITEM_CELL_IDENTIFIER = @"InfoFileItemCellIdentifier";
static NSString *INFO_ICON_ITEM_CELL_IDENTIFIER = @"InfoIconItemCellIdentifier";
static NSString *CALL_ITEM_CELL_IDENTIFIER = @"CallItemCellIdentifier";
static NSString *PEER_CALL_ITEM_CELL_IDENTIFIER = @"PeerCallItemCellIdentifier";
static NSString *INVITATION_CONTACT_ITEM_CELL_IDENTIFIER = @"InvitationContactItemCellIdentifier";
static NSString *PEER_INVITATION_CONTACT_ITEM_CELL_IDENTIFIER = @"PeerInvitationContactItemCellIdentifier";
static NSString *LOCATION_ITEM_CELL_IDENTIFIER = @"LocationItemCellIdentifier";
static NSString *PEER_LOCATION_ITEM_CELL_IDENTIFIER = @"PeerLocationItemCellIdentifier";
static NSString *LOCATION_COORDINATE_ITEM_CELL_IDENTIFIER = @"LocationCoordinateItemCellIdentifier";
static NSString *PEER_LOCATION_COORDINATE_ITEM_CELL_IDENTIFIER = @"PeerLocationCoordinateItemCellIdentifier";
static NSString *CLEAR_ITEM_CELL_IDENTIFIER = @"ClearItemCellIdentifier";
static NSString *PEER_CLEAR_ITEM_CELL_IDENTIFIER = @"PeerClearItemCellIdentifier";
static NSString *ANNOTATION_INFO_CELL_IDENTIFIER = @"AnnotationInfoCellIdentifier";
static NSString *HEADER_SETTINGS_CELL_IDENTIFIER = @"HeaderSettingsCellIdentifier";
static NSString *SETTINGS_CELL_IDENTIFIER = @"SettingsCellIdentifier";

static CGFloat DESIGN_LEADING_DEFAULT_VALUE = 26.f;

//
// Interface: InfoItemViewController ()
//

@interface InfoItemViewController () <UITableViewDelegate, UITableViewDataSource, AsyncLoaderDelegate, InfoItemServiceDelegate, SettingsActionDelegate>

@property (weak, nonatomic) IBOutlet UITableView *infoTableView;

@property (nonatomic) id<TLOriginator> contact;
@property (nonatomic) TLGroup *group;
@property (nonatomic) NSMutableDictionary *groupMembers;

@property (nonatomic) NSString *contactName;
@property (nonatomic) UIImage *contactAvatar;
@property (nonatomic) UIImage *identityAvatar;

@property (nonatomic) AsyncManager *asyncLoaderManager;
@property (nonatomic) InfoItemService *infoItemService;
@property (nonatomic) BOOL canUpdateCopy;

@property (nonatomic, nonnull) NSMutableArray *items;


@end

//
// Implementation: InfoItemViewController
//

#undef LOG_TAG
#define LOG_TAG @"InfoItemViewController"

@implementation InfoItemViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _infoItemService = [[InfoItemService alloc] initWithTwinmeContext:self.twinmeContext delegate:self];
        _asyncLoaderManager = [[AsyncManager alloc] initWithTwinmeContext:self.twinmeContext delegate:self];
        _canUpdateCopy = YES;
        _items = [[NSMutableArray alloc]init];
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
    
    [self.infoTableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    DDLogVerbose(@"%@ viewDidAppear: %@", LOG_TAG, animated ? @"YES" : @"NO");
    
    [super viewDidAppear:animated];
    
    if (self.infoTableView.contentSize.height - self.infoTableView.frame.size.height > 0) {
        [self.infoTableView setContentOffset:CGPointMake(0, self.infoTableView.contentSize.height - self.infoTableView.frame.size.height) animated:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillDisappear: %@", LOG_TAG, animated ? @"YES" : @"NO");
    
    [super viewWillDisappear:animated];
    
    [self.asyncLoaderManager clear];
}

- (void)viewDidDisappear:(BOOL)animated {
    DDLogVerbose(@"%@ viewDidDisappear: %@", LOG_TAG, animated ? @"YES" : @"NO");
    
    [self.asyncLoaderManager clear];
    [super viewDidDisappear:animated];
}

- (void)initWithContact:(nonnull id<TLOriginator>)contact andItem:(nonnull Item *)item groupMembers:(nullable NSMutableDictionary *)groupMembers {
    DDLogVerbose(@"%@ initWithContact: %@", LOG_TAG, contact);
    
    self.contact = contact;
    self.item = item;
    self.groupMembers = groupMembers;
    
    self.contactName = self.contact.name;
    if ([(NSObject*) contact class] == [TLGroupMember class]) {
        TLGroupMember *groupMember = (TLGroupMember *)contact;
        if ([groupMember.group isKindOfClass:[TLGroup class]]) {
            self.group = (TLGroup *)groupMember.group;

            if ([self.item isPeerItem] && [self.groupMembers objectForKey:self.item.peerTwincodeOutboundId]) {
                [self.infoItemService getImageWithGroupMember:[self.groupMembers objectForKey:self.item.peerTwincodeOutboundId] withBlock:^(UIImage *image) {
                    self.contactAvatar = image;
                    [self updateItems];
                }];
            } else {
                [self.infoItemService getImageWithGroup:self.group withBlock:^(UIImage *image) {
                    self.contactAvatar = image;
                    [self updateItems];
                }];
            }
            
            [self.infoItemService getIdentityImageWithGroup:self.group withBlock:^(UIImage *image) {
                self.identityAvatar = image;
                [self updateItems];
            }];

        } else {
            self.contact = groupMember.group;
            self.contactName = self.contact.name;
            [self.infoItemService getImageWithContact:(TLContact *)self.contact withBlock:^(UIImage *image) {
                self.contactAvatar = image;
                [self updateItems];
            }];
            [self.infoItemService getIdentityImageWithContact:(TLContact *)self.contact withBlock:^(UIImage *image) {
                self.identityAvatar = image;
                [self updateItems];
            }];
        }
    } else if ([contact isGroup]) {
        self.group = (TLGroup *)contact;
        
        if ([self.item isPeerItem] && [self.groupMembers objectForKey:self.item.peerTwincodeOutboundId]) {
            [self.infoItemService getImageWithGroupMember:[self.groupMembers objectForKey:self.item.peerTwincodeOutboundId] withBlock:^(UIImage *image) {
                self.contactAvatar = image;
                [self updateItems];
            }];
        } else {
            [self.infoItemService getImageWithGroup:self.group withBlock:^(UIImage *image) {
                self.contactAvatar = image;
                [self updateItems];
            }];
        }
       
        [self.infoItemService getIdentityImageWithGroup:self.group withBlock:^(UIImage *image) {
            self.identityAvatar = image;
            [self updateItems];
        }];
    } else {
        if (contact.peerTwincodeOutbound != nil && ![contact.peerTwincodeOutbound isSigned]) {
            self.canUpdateCopy = NO;
        }
        [self.infoItemService getImageWithContact:(TLContact *)contact withBlock:^(UIImage *image) {
            self.contactAvatar = image;
            [self updateItems];
        }];
        [self.infoItemService getIdentityImageWithContact:(TLContact *)contact withBlock:^(UIImage *image) {
            self.identityAvatar = image;
            [self updateItems];
        }];
    }
    
    [self.infoItemService initWithContact:contact];
    [self updateItems];
}

#pragma mark - Async Loader

- (void)onLoadedWithItems:(nonnull NSMutableArray<id<NSObject>> *)items {
    DDLogVerbose(@"%@ onLoadedWithItems: %@", LOG_TAG, items);
    
    if ([items containsObject:self.item]) {
        [items removeObject:self.item];
        ItemCell *itemCell = (ItemCell *)[self.infoTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        switch (self.item.type) {
            case ItemTypeAudio:
            case ItemTypePeerAudio:
            case ItemTypeFile:
            case ItemTypePeerFile:
            case ItemTypeLink:
            case ItemTypePeerLink:
            case ItemTypeMessage:
            case ItemTypePeerMessage:
            case ItemTypeImage:
            case ItemTypePeerImage:
            case ItemTypeVideo:
            case ItemTypePeerVideo: {
                [itemCell bindWithItem:self.item conversationViewController:self.conversationViewController asyncManager:self.asyncLoaderManager];
                break;
            }
                
            default:
                [itemCell bindWithItem:self.item conversationViewController:self.conversationViewController];
                break;
        }
        if (items.count == 0) {
            return;
        }
    }
}

#pragma mark - SettingsActionDelegate

- (void)switchChangeValue:(SwitchView *)updatedSwitch {
    DDLogVerbose(@"%@ switchChangeValue: %@", LOG_TAG, updatedSwitch);
 
    [self.item setCopyAllowed:updatedSwitch.isOn];
    [self.infoItemService updateDescriptor:self.item.descriptorId allowCopy:updatedSwitch.isOn];
}

#pragma mark - InfoItemServiceDelegate

- (void)onUpdateDescriptor:(TLDescriptor *)descriptor {
    DDLogVerbose(@"%@ onUpdateDescriptor: %@", LOG_TAG, descriptor);
    
    if ([descriptor.descriptorId isEqual:self.item.descriptorId]) {
        [self.item updateTimestampsWithDescriptor:descriptor];
        [self.infoTableView reloadData];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    DDLogVerbose(@"%@ numberOfSectionsInTableView: %@", LOG_TAG, tableView);
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ heightForHeaderInSection: %ld", LOG_TAG, tableView, (long)section);
    
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ heightForFooterInSection: %ld", LOG_TAG, tableView, (long)section);
    
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ heightForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    Item *item = [self.items objectAtIndex:indexPath.row];
    
    if (item.type == ItemTypeInfoFile || indexPath.row == 1) {
        return UITableViewAutomaticDimension;
    }
    
    return Design.SETTING_CELL_HEIGHT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ numberOfRowsInSection: %ld", LOG_TAG, tableView, (long)section);

    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ cellForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    Item *item = [self.items objectAtIndex:indexPath.row];
    
    self.item.replyAllowed = NO;
    switch (item.type) {
        case ItemTypeTime: {
            TimeItem *timeItem = [[TimeItem alloc]initWithTimestamp:item.sentTimestamp > 0 ? item.sentTimestamp:item.createdTimestamp];
            TimeItemCell *timeItemCell = (TimeItemCell *)[self.infoTableView dequeueReusableCellWithIdentifier:TIME_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
            [timeItemCell bindWithItem:timeItem conversationViewController:self.conversationViewController];
            timeItemCell.contentView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
            return timeItemCell;
        }
            
        case ItemTypeMessage: {
            MessageItem *messageItem = (MessageItem *)item;
            MessageItemCell *messageItemCell = (MessageItemCell *)[self.infoTableView dequeueReusableCellWithIdentifier:MESSAGE_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
            [messageItemCell bindWithItem:messageItem conversationViewController:self.conversationViewController asyncManager:self.asyncLoaderManager];
            messageItemCell.contentView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
            return messageItemCell;
        }
            
        case ItemTypePeerMessage: {
            PeerMessageItem *peerMessageItem = (PeerMessageItem *)item;
            PeerMessageItemCell *peerMessageItemCell = (PeerMessageItemCell *)[self.infoTableView dequeueReusableCellWithIdentifier:PEER_MESSAGE_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
            [peerMessageItemCell bindWithItem:peerMessageItem conversationViewController:self.conversationViewController asyncManager:self.asyncLoaderManager];
            peerMessageItemCell.contentView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
            return peerMessageItemCell;
        }
            
        case ItemTypeLink: {
            LinkItem *linkItem = (LinkItem *)item;
            LinkItemCell *linkItemCell = (LinkItemCell *)[self.infoTableView dequeueReusableCellWithIdentifier:LINK_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
            [linkItemCell bindWithItem:linkItem conversationViewController:self.conversationViewController asyncManager:self.asyncLoaderManager];
            linkItemCell.contentView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
            return linkItemCell;
        }
            
        case ItemTypePeerLink: {
            PeerLinkItem *peerLinkItem = (PeerLinkItem *)item;
            PeerLinkItemCell *peerLinkItemCell = (PeerLinkItemCell *)[self.infoTableView dequeueReusableCellWithIdentifier:PEER_LINK_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
            [peerLinkItemCell bindWithItem:peerLinkItem conversationViewController:self.conversationViewController asyncManager:self.asyncLoaderManager];
            peerLinkItemCell.contentView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
            return peerLinkItemCell;
        }
            
        case ItemTypeImage: {
            ImageItem *imageItem = (ImageItem *)item;
            ImageItemCell *imageItemCell = (ImageItemCell *)[self.infoTableView dequeueReusableCellWithIdentifier:IMAGE_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
            [imageItemCell bindWithItem:imageItem conversationViewController:self.conversationViewController asyncManager:self.asyncLoaderManager];
            imageItemCell.contentView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
            return imageItemCell;
        }
            
        case ItemTypePeerImage: {
            PeerImageItem *peerImageItem = (PeerImageItem *)item;
            PeerImageItemCell *peerImageItemCell = (PeerImageItemCell *)[self.infoTableView dequeueReusableCellWithIdentifier:PEER_IMAGE_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
            [peerImageItemCell bindWithItem:peerImageItem conversationViewController:self.conversationViewController asyncManager:self.asyncLoaderManager];
            peerImageItemCell.contentView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
            return peerImageItemCell;
        }
            
        case ItemTypeAudio: {
            AudioItem *audioItem = (AudioItem *)item;
            AudioItemCell *audioItemCell = (AudioItemCell *)[self.infoTableView dequeueReusableCellWithIdentifier:AUDIO_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
            [audioItemCell bindWithItem:audioItem conversationViewController:self.conversationViewController asyncManager:self.asyncLoaderManager];
            audioItemCell.contentView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
            return audioItemCell;
        }
            
        case ItemTypePeerAudio: {
            PeerAudioItem *peerAudioItem = (PeerAudioItem *)item;
            PeerAudioItemCell *peerAudioItemCell = (PeerAudioItemCell *)[self.infoTableView dequeueReusableCellWithIdentifier:PEER_AUDIO_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
            [peerAudioItemCell bindWithItem:peerAudioItem conversationViewController:self.conversationViewController asyncManager:self.asyncLoaderManager];
            peerAudioItemCell.contentView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
            return peerAudioItemCell;
        }
            
        case ItemTypeVideo: {
            VideoItem *videoItem = (VideoItem *)item;
            VideoItemCell *videoItemCell = (VideoItemCell *)[self.infoTableView dequeueReusableCellWithIdentifier:VIDEO_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
            [videoItemCell bindWithItem:videoItem conversationViewController:self.conversationViewController asyncManager:self.asyncLoaderManager];
            videoItemCell.contentView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
            return videoItemCell;
        }
            
        case ItemTypePeerVideo: {
            PeerVideoItem *peerVideoItem = (PeerVideoItem *)item;
            PeerVideoItemCell *peerVideoItemCell = (PeerVideoItemCell *)[self.infoTableView dequeueReusableCellWithIdentifier:PEER_VIDEO_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
            [peerVideoItemCell bindWithItem:peerVideoItem conversationViewController:self.conversationViewController asyncManager:self.asyncLoaderManager];
            peerVideoItemCell.contentView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
            return peerVideoItemCell;
        }
            
        case ItemTypeFile: {
            FileItem *fileItem = (FileItem *)item;
            FileItemCell *fileItemCell = (FileItemCell *)[self.infoTableView dequeueReusableCellWithIdentifier:FILE_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
            [fileItemCell bindWithItem:fileItem conversationViewController:self.conversationViewController asyncManager:self.asyncLoaderManager];
            fileItemCell.contentView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
            return fileItemCell;
        }
            
        case ItemTypePeerFile: {
            PeerFileItem *peerFileItem = (PeerFileItem *)item;
            PeerFileItemCell *peerFileItemCell = (PeerFileItemCell *)[self.infoTableView dequeueReusableCellWithIdentifier:PEER_FILE_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
            [peerFileItemCell bindWithItem:peerFileItem conversationViewController:self.conversationViewController asyncManager:self.asyncLoaderManager];
            peerFileItemCell.contentView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
            return peerFileItemCell;
        }
            
        case ItemTypePoll: {
            PollItem *pollItem = (PollItem *)item;
            PollItemCell *pollItemCell = (PollItemCell *)[self.infoTableView dequeueReusableCellWithIdentifier:POLL_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
            [pollItemCell bindWithItem:pollItem conversationViewController:self.conversationViewController];
            pollItemCell.contentView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
            return pollItemCell;
        }
            
        case ItemTypePeerPoll: {
            PeerPollItem *peerPollItem = (PeerPollItem *)item;
            PeerPollItemCell *peerPollItemCell = (PeerPollItemCell *)[self.infoTableView dequeueReusableCellWithIdentifier:PEER_POLL_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
            [peerPollItemCell bindWithItem:peerPollItem conversationViewController:self.conversationViewController];
            peerPollItemCell.contentView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
            return peerPollItemCell;
        }
            
        case ItemTypeLocation: {
            LocationItem *locationItem = (LocationItem *)self.item;
            
            if ([self.twinmeApplication visualizationMap]) {
                LocationItemCell *locationItemCell = (LocationItemCell *)[self.infoTableView dequeueReusableCellWithIdentifier:LOCATION_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
                [locationItemCell bindWithItem:locationItem conversationViewController:self.conversationViewController];
                locationItemCell.contentView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
                return locationItemCell;
            } else {
                LocationCoordinateItemCell *locationItemCell = (LocationCoordinateItemCell *)[self.infoTableView dequeueReusableCellWithIdentifier:LOCATION_COORDINATE_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
                [locationItemCell bindWithItem:locationItem conversationViewController:self.conversationViewController];
                locationItemCell.contentView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
                return locationItemCell;
            }
        }
            
        case ItemTypePeerLocation: {
            PeerLocationItem *peerLocationItem = (PeerLocationItem *)self.item;
            
            if ([self.twinmeApplication visualizationMap]) {
                PeerLocationItemCell *peerLocationItemCell = (PeerLocationItemCell *)[self.infoTableView dequeueReusableCellWithIdentifier:PEER_LOCATION_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
                [peerLocationItemCell bindWithItem:peerLocationItem conversationViewController:self.conversationViewController];
                peerLocationItemCell.contentView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
                return peerLocationItemCell;
            } else {
                PeerLocationCoordinateItemCell *peerLocationItemCell = (PeerLocationCoordinateItemCell *)[self.infoTableView dequeueReusableCellWithIdentifier:PEER_LOCATION_COORDINATE_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
                [peerLocationItemCell bindWithItem:peerLocationItem conversationViewController:self.conversationViewController];
                peerLocationItemCell.contentView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
                return peerLocationItemCell;
            }
            
        }
            
        case ItemTypeInvitation: {
            InvitationItem *invitationItem = (InvitationItem *)item;
            InvitationItemCell *invitationItemCell = (InvitationItemCell *)[self.infoTableView dequeueReusableCellWithIdentifier:INVITATION_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
            [invitationItemCell bindWithItem:invitationItem conversationViewController:self.conversationViewController];
            invitationItemCell.contentView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
            return invitationItemCell;
        }
            
        case ItemTypePeerInvitation: {
            PeerInvitationItem *peerInvitationItem = (PeerInvitationItem *)item;
            PeerInvitationItemCell *peerInvitationItemCell = (PeerInvitationItemCell *)[self.infoTableView dequeueReusableCellWithIdentifier:PEER_INVITATION_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
            [peerInvitationItemCell bindWithItem:peerInvitationItem conversationViewController:self.conversationViewController];
            peerInvitationItemCell.contentView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
            return peerInvitationItemCell;
        }
            
        case ItemTypeCall: {
            CallItem *callItem = (CallItem *)item;
            CallItemCell *callItemCell = (CallItemCell *)[self.infoTableView dequeueReusableCellWithIdentifier:CALL_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
            [callItemCell bindWithItem:callItem conversationViewController:self.conversationViewController];
            callItemCell.contentView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
            return callItemCell;
        }
            
        case ItemTypePeerCall: {
            PeerCallItem *peerCallItem = (PeerCallItem *)item;
            PeerCallItemCell *peerCallItemCell = (PeerCallItemCell *)[self.infoTableView dequeueReusableCellWithIdentifier:PEER_CALL_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
            [peerCallItemCell bindWithItem:peerCallItem conversationViewController:self.conversationViewController];
            peerCallItemCell.contentView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
            return peerCallItemCell;
        }
            
        case ItemTypeInvitationContact: {
            InvitationContactItem *invitationContactItem = (InvitationContactItem *)item;
            InvitationContactItemCell *invitationContactItemCell = (InvitationContactItemCell *)[self.infoTableView dequeueReusableCellWithIdentifier:INVITATION_CONTACT_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
            [invitationContactItemCell bindWithItem:invitationContactItem conversationViewController:self.conversationViewController];
            invitationContactItemCell.contentView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
            return invitationContactItemCell;
        }
            
        case ItemTypePeerInvitationContact: {
            PeerInvitationContactItem *peerInvitationContactItem = (PeerInvitationContactItem *)item;
            PeerInvitationContactItemCell *peerInvitationContactItemCell = (PeerInvitationContactItemCell *)[self.infoTableView dequeueReusableCellWithIdentifier:PEER_INVITATION_CONTACT_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
            [peerInvitationContactItemCell bindWithItem:peerInvitationContactItem conversationViewController:self.conversationViewController];
            peerInvitationContactItemCell.contentView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
            return peerInvitationContactItemCell;
        }
            
        case ItemTypeClear: {
            ClearItem *clearItem = (ClearItem *)item;
            ClearItemCell *clearItemCell = (ClearItemCell *)[self.infoTableView dequeueReusableCellWithIdentifier:CLEAR_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
            [clearItemCell bindWithItem:clearItem conversationViewController:self.conversationViewController];
            clearItemCell.contentView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
            return clearItemCell;
        }
            
        case ItemTypePeerClear: {
            PeerClearItem *peerClearItem = (PeerClearItem *)item;
            PeerClearItemCell *peerClearItemCell = (PeerClearItemCell *)[self.infoTableView dequeueReusableCellWithIdentifier:PEER_CLEAR_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
            [peerClearItemCell bindWithItem:peerClearItem conversationViewController:self.conversationViewController];
            peerClearItemCell.contentView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
            return peerClearItemCell;
        }
            
        case ItemTypeInfoDate: {
            InfoDateItem *infoDateItem = (InfoDateItem *)item;
            InfoDateItemCell *infoDateItemCell = (InfoDateItemCell *)[self.infoTableView dequeueReusableCellWithIdentifier:INFO_DATE_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
            [infoDateItemCell bindWithItem:self.item infoDateItem:infoDateItem conversationViewController:self.conversationViewController];
            return infoDateItemCell;
        }
            
        case ItemTypeInfoDeleted:
        case ItemTypeInfoEphemeral: {
            InfoIconItemCell *infoIconItemCell = (InfoIconItemCell *)[self.infoTableView dequeueReusableCellWithIdentifier:INFO_ICON_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
            [infoIconItemCell bindWithItem:self.item infoItemType:item.type == ItemTypeInfoDeleted ? InfoItemTypeDeleted : InfoItemTypeEphemeral conversationViewController:self.conversationViewController];
            return infoIconItemCell;
        }
            
        case ItemTypeInfoCopy: {
            
            if (self.canUpdateCopy && (self.item.type == ItemTypeMessage || self.item.type == ItemTypeImage || self.item.type == ItemTypeVideo || self.item.type == ItemTypeAudio || self.item.type == ItemTypeFile || self.item.type == ItemTypeLink || self.item.type == ItemTypeLocation)) {
                SettingsItemCell *cell = [tableView dequeueReusableCellWithIdentifier:SETTINGS_CELL_IDENTIFIER];
                if (!cell) {
                    cell = [[SettingsItemCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SETTINGS_CELL_IDENTIFIER];
                }
                
                cell.settingsActionDelegate = self;
                [cell bindWithTitle:TwinmeLocalizedString(@"conversation_view_send_menu_allow_copy", nil) subTitle:nil  icon:self.item.copyAllowed ? [UIImage imageNamed:@"SendOptionCopyAllowedIcon"]:[UIImage imageNamed:@"SendOptionCopyIcon"] stateSwitch:self.item.copyAllowed tagSwitch:0 hiddenSwitch:NO disableSwitch:NO backgroundColor:Design.WHITE_COLOR hiddenSeparator:NO];
                [cell updateMargins:DESIGN_LEADING_DEFAULT_VALUE * Design.WIDTH_RATIO];
                return cell;
            } else {
                CopyItemCell *copyItemCell = (CopyItemCell *)[self.infoTableView dequeueReusableCellWithIdentifier:COPY_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
                [copyItemCell bindWithItem:self.item];
                return copyItemCell;
            }
        }
            
        case ItemTypeInfoFile: {
            
            InfoFileItemCell *infoFileItemCell = (InfoFileItemCell *)[self.infoTableView dequeueReusableCellWithIdentifier:INFO_FILE_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
            [infoFileItemCell bindWithItem:self.item originator:[self.conversationViewController getOriginator]];
            return infoFileItemCell;
        }
            
        case ItemTypeInfoAnnotation: {
            AnnotationInfoCell *annotationInfoCell = [tableView dequeueReusableCellWithIdentifier:ANNOTATION_INFO_CELL_IDENTIFIER];
            if (!annotationInfoCell) {
                annotationInfoCell = [[AnnotationInfoCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ANNOTATION_INFO_CELL_IDENTIFIER];
            }
            
            InfoAnnotationItem *infoAnnotationItem = (InfoAnnotationItem *)item;
            
            BOOL hideSeparator = NO;
            if (indexPath.row + 1 != self.items.count) {
                Item *nextItem = [self.items objectAtIndex:indexPath.row + 1];
                hideSeparator = nextItem.type != item.type;
            } else if (indexPath.row + 1 == self.items.count) {
                hideSeparator = YES;
            }
            
            [annotationInfoCell bindWithAnnotation:infoAnnotationItem.annotation hideSeparator:hideSeparator backgroundColor:Design.WHITE_COLOR];
            return annotationInfoCell;
        }
            
        case ItemTypeInfoSection: {
            
            SettingsSectionHeaderCell *settingsSectionHeaderCell = (SettingsSectionHeaderCell *)[tableView dequeueReusableCellWithIdentifier:HEADER_SETTINGS_CELL_IDENTIFIER];
            if (!settingsSectionHeaderCell) {
                settingsSectionHeaderCell = [[SettingsSectionHeaderCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:HEADER_SETTINGS_CELL_IDENTIFIER];
            }
            
            InfoSectionItem *infoSectionItem = (InfoSectionItem *)item;

            [settingsSectionHeaderCell bindWithTitle:infoSectionItem.title backgroundColor:Design.LIGHT_GREY_BACKGROUND_COLOR hideSeparator:YES uppercaseString:YES];
            
            return settingsSectionHeaderCell;
        }
            
        default:
            break;
    }
    
    return [[UITableViewCell alloc]init];
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.view.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
        
    [self setNavigationTitle:TwinmeLocalizedString(@"conversation_view_menu_item_view_info_title", nil)];
    
    self.infoTableView.delegate = self;
    self.infoTableView.dataSource = self;
    [self.infoTableView setBackgroundColor:Design.LIGHT_GREY_BACKGROUND_COLOR];
    self.infoTableView.rowHeight = UITableViewAutomaticDimension;
    self.infoTableView.estimatedRowHeight = Design.SETTING_CELL_HEIGHT;
    self.infoTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.infoTableView registerNib:[UINib nibWithNibName:@"TimeItemCell" bundle:nil] forCellReuseIdentifier:TIME_ITEM_CELL_IDENTIFIER];
    [self.infoTableView registerNib:[UINib nibWithNibName:@"MessageItemCell" bundle:nil] forCellReuseIdentifier:MESSAGE_ITEM_CELL_IDENTIFIER];
    [self.infoTableView registerNib:[UINib nibWithNibName:@"PeerMessageItemCell" bundle:nil] forCellReuseIdentifier:PEER_MESSAGE_ITEM_CELL_IDENTIFIER];
    [self.infoTableView registerNib:[UINib nibWithNibName:@"LinkItemCell" bundle:nil] forCellReuseIdentifier:LINK_ITEM_CELL_IDENTIFIER];
    [self.infoTableView registerNib:[UINib nibWithNibName:@"PeerLinkItemCell" bundle:nil] forCellReuseIdentifier:PEER_LINK_ITEM_CELL_IDENTIFIER];
    [self.infoTableView registerNib:[UINib nibWithNibName:@"ImageItemCell" bundle:nil] forCellReuseIdentifier:IMAGE_ITEM_CELL_IDENTIFIER];
    [self.infoTableView registerNib:[UINib nibWithNibName:@"PeerImageItemCell" bundle:nil] forCellReuseIdentifier:PEER_IMAGE_ITEM_CELL_IDENTIFIER];
    [self.infoTableView registerNib:[UINib nibWithNibName:@"AudioItemCell" bundle:nil] forCellReuseIdentifier:AUDIO_ITEM_CELL_IDENTIFIER];
    [self.infoTableView registerNib:[UINib nibWithNibName:@"PeerAudioItemCell" bundle:nil] forCellReuseIdentifier:PEER_AUDIO_ITEM_CELL_IDENTIFIER];
    [self.infoTableView registerNib:[UINib nibWithNibName:@"VideoItemCell" bundle:nil] forCellReuseIdentifier:VIDEO_ITEM_CELL_IDENTIFIER];
    [self.infoTableView registerNib:[UINib nibWithNibName:@"PeerVideoItemCell" bundle:nil] forCellReuseIdentifier:PEER_VIDEO_ITEM_CELL_IDENTIFIER];
    [self.infoTableView registerNib:[UINib nibWithNibName:@"FileItemCell" bundle:nil] forCellReuseIdentifier:FILE_ITEM_CELL_IDENTIFIER];
    [self.infoTableView registerNib:[UINib nibWithNibName:@"PeerFileItemCell" bundle:nil] forCellReuseIdentifier:PEER_FILE_ITEM_CELL_IDENTIFIER];
    [self.infoTableView registerNib:[UINib nibWithNibName:@"InvitationItemCell" bundle:nil] forCellReuseIdentifier:INVITATION_ITEM_CELL_IDENTIFIER];
    [self.infoTableView registerNib:[UINib nibWithNibName:@"PeerInvitationItemCell" bundle:nil] forCellReuseIdentifier:PEER_INVITATION_ITEM_CELL_IDENTIFIER];
    [self.infoTableView registerNib:[UINib nibWithNibName:@"PollItemCell" bundle:nil] forCellReuseIdentifier:POLL_ITEM_CELL_IDENTIFIER];
    [self.infoTableView registerNib:[UINib nibWithNibName:@"PeerPollItemCell" bundle:nil] forCellReuseIdentifier:PEER_POLL_ITEM_CELL_IDENTIFIER];
    [self.infoTableView registerNib:[UINib nibWithNibName:@"CallItemCell" bundle:nil] forCellReuseIdentifier:CALL_ITEM_CELL_IDENTIFIER];
    [self.infoTableView registerNib:[UINib nibWithNibName:@"PeerCallItemCell" bundle:nil] forCellReuseIdentifier:PEER_CALL_ITEM_CELL_IDENTIFIER];
    [self.infoTableView registerNib:[UINib nibWithNibName:@"NameItemCell" bundle:nil] forCellReuseIdentifier:NAME_ITEM_CELL_IDENTIFIER];
    [self.infoTableView registerNib:[UINib nibWithNibName:@"InfoDateItemCell" bundle:nil] forCellReuseIdentifier:INFO_DATE_ITEM_CELL_IDENTIFIER];
    [self.infoTableView registerNib:[UINib nibWithNibName:@"InfoIconItemCell" bundle:nil] forCellReuseIdentifier:INFO_ICON_ITEM_CELL_IDENTIFIER];
    [self.infoTableView registerNib:[UINib nibWithNibName:@"CopyItemCell" bundle:nil] forCellReuseIdentifier:COPY_ITEM_CELL_IDENTIFIER];
    [self.infoTableView registerNib:[UINib nibWithNibName:@"InfoFileItemCell" bundle:nil] forCellReuseIdentifier:INFO_FILE_ITEM_CELL_IDENTIFIER];
    [self.infoTableView registerNib:[UINib nibWithNibName:@"InvitationContactItemCell" bundle:nil] forCellReuseIdentifier:INVITATION_CONTACT_ITEM_CELL_IDENTIFIER];
    [self.infoTableView registerNib:[UINib nibWithNibName:@"PeerInvitationContactItemCell" bundle:nil] forCellReuseIdentifier:PEER_INVITATION_CONTACT_ITEM_CELL_IDENTIFIER];
    [self.infoTableView registerNib:[UINib nibWithNibName:@"LocationItemCell" bundle:nil] forCellReuseIdentifier:LOCATION_ITEM_CELL_IDENTIFIER];
    [self.infoTableView registerNib:[UINib nibWithNibName:@"PeerLocationItemCell" bundle:nil] forCellReuseIdentifier:PEER_LOCATION_ITEM_CELL_IDENTIFIER];
    [self.infoTableView registerNib:[UINib nibWithNibName:@"LocationCoordinateItemCell" bundle:nil] forCellReuseIdentifier:LOCATION_COORDINATE_ITEM_CELL_IDENTIFIER];
    [self.infoTableView registerNib:[UINib nibWithNibName:@"PeerLocationCoordinateItemCell" bundle:nil] forCellReuseIdentifier:PEER_LOCATION_COORDINATE_ITEM_CELL_IDENTIFIER];
    [self.infoTableView registerNib:[UINib nibWithNibName:@"ClearItemCell" bundle:nil] forCellReuseIdentifier:CLEAR_ITEM_CELL_IDENTIFIER];
    [self.infoTableView registerNib:[UINib nibWithNibName:@"PeerClearItemCell" bundle:nil] forCellReuseIdentifier:PEER_CLEAR_ITEM_CELL_IDENTIFIER];
    [self.infoTableView registerNib:[UINib nibWithNibName:@"AnnotationInfoCell" bundle:nil] forCellReuseIdentifier:ANNOTATION_INFO_CELL_IDENTIFIER];
    [self.infoTableView registerNib:[UINib nibWithNibName:@"SettingsSectionHeaderCell" bundle:nil] forCellReuseIdentifier:HEADER_SETTINGS_CELL_IDENTIFIER];
    [self.infoTableView registerNib:[UINib nibWithNibName:@"SettingsItemCell" bundle:nil] forCellReuseIdentifier:SETTINGS_CELL_IDENTIFIER];
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    [self.asyncLoaderManager stop];
    self.asyncLoaderManager = nil;
    
    if (self.infoItemService) {
        [self.infoItemService dispose];
        self.infoItemService = nil;
    }
}

- (void)handleBackTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleBackTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)updateItems {
    DDLogVerbose(@"%@ updateItems", LOG_TAG);
    
    if (self.item && self.contactAvatar && self.identityAvatar && self.items.count == 0) {
        [self.items removeAllObjects];
        
        TimeItem *timeItem = [[TimeItem alloc]initWithTimestamp:self.item.sentTimestamp > 0 ? self.item.sentTimestamp:self.item.createdTimestamp];
        [self.items addObject:timeItem];
        [self.items addObject:self.item];
        
        switch (self.item.type) {
            case ItemTypeMessage:
            case ItemTypePeerMessage:
            case ItemTypeLink:
            case ItemTypePeerLink:
            case ItemTypePoll:
            case ItemTypePeerPoll:
                [self.items addObject:[[InfoSectionItem alloc] initWithTitle:TwinmeLocalizedString(@"navigation_view_settings", nil)]];
                [self.items addObject:[[InfoCopyItem alloc] init]];
                break;
                
            case ItemTypeImage:
            case ItemTypePeerImage:
            case ItemTypeVideo:
            case ItemTypePeerVideo:
            case ItemTypeAudio:
            case ItemTypePeerAudio:
            case ItemTypeFile:
            case ItemTypePeerFile:
                [self.items addObject:[[InfoSectionItem alloc] initWithTitle:TwinmeLocalizedString(@"navigation_view_settings", nil)]];
                [self.items addObject:[[InfoCopyItem alloc] init]];
                [self.items addObject:[[InfoFileItem alloc] init]];
                break;
                
                
            case ItemTypeLocation:
            case ItemTypePeerLocation:
                [self.items addObject:[[InfoSectionItem alloc] initWithTitle:TwinmeLocalizedString(@"info_item_view_location", nil)]];
                [self.items addObject:[[InfoCopyItem alloc] init]];
                [self.items addObject:[[InfoFileItem alloc] init]];
                break;
                
            case ItemTypePeerCall: {
                BOOL addFileItem = NO;
                if (self.item.type == ItemTypeCall) {
                    CallItem *callItem = (CallItem *)self.item;
                    addFileItem = [callItem showTerminateReason];
                } else {
                    PeerCallItem *peerCallItem = (PeerCallItem *)self.item;
                    addFileItem = [peerCallItem showTerminateReason];
                }
                
                if (addFileItem) {
                    [self.items addObject:[[InfoFileItem alloc] init]];
                }
                
                break;
            }
                
            default:
                break;
        }
        
        if (self.item.peerDeletedTimestamp > 0) {
            [self.items addObject:[[InfoDeletedItem alloc] init]];
        }
        
        if ([self.item isEphemeralItem] && self.item.readTimestamp > 0) {
            [self.items addObject:[[InfoEphemeralItem alloc] init]];
        }
        
        NSUInteger annotationStart = self.items.count > 0 ? self.items.count : 0;
        
        if (self.item.type != ItemTypeCall && self.item.type != ItemTypePeerCall) {
            
            if (!self.group) {
                if (self.item.readTimestamp > 0) {
                    [self.items addObject:[[InfoSectionItem alloc] initWithTitle:TwinmeLocalizedString(@"info_item_view_seen", nil)]];
                    [self.items addObject:[[InfoDateItem alloc] initWithType:InfoItemTypeSeen name:self.item.isPeerItem ? self.contact.identityName : self.contact.name image:self.item.isPeerItem ? self.identityAvatar : self.contactAvatar]];
                } else if (self.item.receivedTimestamp > 0) {
                    [self.items addObject:[[InfoSectionItem alloc] initWithTitle:TwinmeLocalizedString(@"info_item_view_received", nil)]];
                    [self.items addObject:[[InfoDateItem alloc] initWithType:InfoItemTypeReceived name:self.item.isPeerItem ? self.contact.identityName : self.contact.name image:self.item.isPeerItem ? self.identityAvatar : self.contactAvatar]];
                }
                
                if ([self.item isEditedtem]) {
                    [self.items addObject:[[InfoSectionItem alloc] initWithTitle:[NSString stringWithFormat:@"%@ :", TwinmeLocalizedString(@"info_item_view_updated", nil)]]];
                    [self.items addObject:[[InfoDateItem alloc] initWithType:InfoItemTypeUpdated name:self.item.isPeerItem ? self.contact.name : self.contact.identityName image:self.item.isPeerItem ? self.contactAvatar : self.identityAvatar]];
                }
            } else {
                if ([self.item isPeerItem]) {
                    TLGroupMember *member = [self.groupMembers objectForKey:self.item.peerTwincodeOutboundId];
                    NSString *memberName = member ? member.name : @"";

                    if (self.item.readTimestamp > 0) {
                        [self.items addObject:[[InfoSectionItem alloc] initWithTitle:TwinmeLocalizedString(@"info_item_view_seen", nil)]];
                        [self.items addObject:[[InfoDateItem alloc] initWithType:InfoItemTypeSeen name:self.group.identityName image:self.identityAvatar]];
                    } else {
                        [self.items addObject:[[InfoSectionItem alloc] initWithTitle:TwinmeLocalizedString(@"info_item_view_received", nil)]];
                        [self.items addObject:[[InfoDateItem alloc] initWithType:InfoItemTypeReceived name:self.group.identityName image:self.identityAvatar]];
                    }
                    
                    if ([self.item isEditedtem]) {
                        [self.items addObject:[[InfoSectionItem alloc] initWithTitle:[NSString stringWithFormat:@"%@ :", TwinmeLocalizedString(@"info_item_view_updated", nil)]]];
                        [self.items addObject:[[InfoDateItem alloc] initWithType:InfoItemTypeUpdated name:memberName image:self.contactAvatar]];
                    }
                } else {
                    if ([self.item isEditedtem]) {
                        [self.items addObject:[[InfoSectionItem alloc] initWithTitle:TwinmeLocalizedString(@"info_item_view_updated", nil)]];
                        [self.items addObject:[[InfoDateItem alloc] initWithType:InfoItemTypeUpdated name:self.group.identityName image:self.identityAvatar]];
                    }
                }
            }
            
            [self.items addObject:[[InfoSectionItem alloc] initWithTitle:TwinmeLocalizedString(@"info_item_view_sent", nil)]];
            
            if (!self.group) {
                [self.items addObject:[[InfoDateItem alloc] initWithType:InfoItemTypeSent name:self.item.isPeerItem ? self.contact.name : self.contact.identityName image:self.item.isPeerItem ? self.contactAvatar : self.identityAvatar]];
            } else {
                if ([self.item isPeerItem]) {
                    TLGroupMember *member = [self.groupMembers objectForKey:self.item.peerTwincodeOutboundId];
                    NSString *memberName = member ? member.name : @"";
                    [self.items addObject:[[InfoDateItem alloc] initWithType:InfoItemTypeSent name:memberName image:self.contactAvatar]];
                } else {
                    [self.items addObject:[[InfoDateItem alloc] initWithType:InfoItemTypeSent name:self.group.identityName image:self.identityAvatar]];
                }
            }
        }
        
        [self updateAnnotations:annotationStart];
    }
}

- (void)updateAnnotations:(NSUInteger)startIndex {
    DDLogVerbose(@"%@ updateAnnotations", LOG_TAG);

    [self.infoItemService listAnnotationsWithDescriptorId:self.item.descriptorId withBlock:^(NSDictionary<NSUUID *, NSArray<TLDescriptorAnnotationPair *> *>* annotations) {
        // This code block is run by TwinlifeExecutor, so we can call the blocking getImageWithTwincode() variant.
        NSMutableArray<UIAnnotation *> *uiAnnotationList = [[NSMutableArray alloc] initWithCapacity:annotations.count];
        
        for (NSUUID *uuid in annotations.allKeys) {
            NSArray<TLDescriptorAnnotationPair *> *descriptorAnnotations = [annotations objectForKey:uuid];
            
            for (TLDescriptorAnnotationPair *descriptorAnnotation in descriptorAnnotations) {
                if (descriptorAnnotation.annotation.type == TLDescriptorAnnotationTypeLike) {
                    UIReaction *uiReaction = [[UIReaction alloc]initWithDescriptorAnnotationValue:descriptorAnnotation.annotation.value];
                    NSString *name = descriptorAnnotation.twincodeOutbound.name;
                    UIImage *avatar = [self.infoItemService getImageWithTwincode:descriptorAnnotation.twincodeOutbound];
                    
                    UIAnnotation *uiAnnotation = [[UIAnnotation alloc]initWithType:TLDescriptorAnnotationTypeLike reaction:uiReaction name:name avatar:avatar value:-1];
                    [uiAnnotationList addObject:uiAnnotation];
                } else if (descriptorAnnotation.annotation.type == TLDescriptorAnnotationTypeReceived || descriptorAnnotation.annotation.type == TLDescriptorAnnotationTypeRead || descriptorAnnotation.annotation.type == TLDescriptorAnnotationTypeError) {
                    NSString *name = descriptorAnnotation.twincodeOutbound.name;
                    UIImage *avatar = [self.infoItemService getImageWithTwincode:descriptorAnnotation.twincodeOutbound];
                    
                    UIAnnotation *uiAnnotation = [[UIAnnotation alloc]initWithType:descriptorAnnotation.annotation.type reaction:nil name:name avatar:avatar value:descriptorAnnotation.annotation.value];
                    [uiAnnotationList addObject:uiAnnotation];
                }
            }
        }
        
        NSArray<UIAnnotation *> *sortedAnnotations = [uiAnnotationList sortedArrayUsingDescriptors:@[
            [NSSortDescriptor sortDescriptorWithKey:@"orderPriority" ascending:YES]
        ]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSMutableArray *uiAnnotations = [[NSMutableArray alloc] init];
            for (int i = 0; i < sortedAnnotations.count; i++) {
                UIAnnotation *uiAnnotation = [sortedAnnotations objectAtIndex:i];
                
                if (i == 0 || uiAnnotation.annotationType != [sortedAnnotations objectAtIndex:i-1].annotationType) {
                    NSString *title = @"";
                 
                    TLDescriptorAnnotationType annotationType = uiAnnotation.annotationType;
                    if (annotationType == TLDescriptorAnnotationTypeLike) {
                        title = TwinmeLocalizedString(@"info_item_view_reactions", nil);
                    } else if (annotationType == TLDescriptorAnnotationTypeReceived) {
                        title = TwinmeLocalizedString(@"info_item_view_received", nil);
                    } else if (annotationType == TLDescriptorAnnotationTypeRead) {
                        title = TwinmeLocalizedString(@"info_item_view_seen", nil);
                    } else if (annotationType == TLDescriptorAnnotationTypeError) {
                        title = TwinmeLocalizedString(@"info_item_view_not_delivered", nil);
                    }
                                        
                    [uiAnnotations addObject:[[InfoSectionItem alloc] initWithTitle:title]];
                }
                
                [uiAnnotations addObject:[[InfoAnnotationItem alloc] initWithAnnotation:uiAnnotation]];
            }
            
            if (uiAnnotations.count > 0) {
                NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(startIndex, uiAnnotations.count)];
                [self.items insertObjects:uiAnnotations atIndexes:indexes];
            }
            
            [self.infoTableView reloadData];
        });
    }];
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    [self.infoTableView reloadData];
}

@end

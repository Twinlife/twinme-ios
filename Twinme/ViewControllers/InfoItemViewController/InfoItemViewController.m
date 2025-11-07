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
#import "InvitationItemCell.h"
#import "PeerInvitationItemCell.h"
#import "NameItemCell.h"
#import "InfoDateItemCell.h"
#import "InfoFileItemCell.h"
#import "CopyItemCell.h"
#import "CallItemCell.h"
#import "PeerCallItemCell.h"
#import "LocationItemCell.h"
#import "PeerLocationItemCell.h"
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

static NSString *MESSAGE_ITEM_CELL_IDENTIFIER = @"MessageItemCellIdentifier";
static NSString *PEER_MESSAGE_ITEM_CELL_IDENTIFIER = @"PeerMessageItemCellIdentifier";
static NSString *LINK_ITEM_CELL_IDENTIFIER = @"LinkItemCellIdentifier";
static NSString *PEER_LINK_ITEM_CELL_IDENTIFIER = @"PeerLinkItemCellIdentifier";
static NSString *IMAGE_ITEM_CELL_IDENTIFIER = @"ImageItemCellIdentifier";
static NSString *PEER_IMAGE_ITEM_CELL_IDENTIFIER = @"PeerImageItemCellIdentifier";
static NSString *TIME_CELL_IDENTIFIER = @"TimeCellIdentifier";
static NSString *AUDIO_ITEM_CELL_IDENTIFIER = @"AudioItemCellIdentifier";
static NSString *PEER_AUDIO_ITEM_CELL_IDENTIFIER = @"PeerAudioItemCellIdentifier";
static NSString *VIDEO_ITEM_CELL_IDENTIFIER = @"VideoItemCellIdentifier";
static NSString *PEER_VIDEO_ITEM_CELL_IDENTIFIER = @"PeerVideoItemCellIdentifier";
static NSString *FILE_ITEM_CELL_IDENTIFIER = @"FileItemCellIdentifier";
static NSString *PEER_FILE_ITEM_CELL_IDENTIFIER = @"PeerFileItemCellIdentifier";
static NSString *INVITATION_ITEM_CELL_IDENTIFIER = @"InvitationItemCellIdentifier";
static NSString *PEER_INVITATION_ITEM_CELL_IDENTIFIER = @"PeerInvitationItemCellIdentifier";
static NSString *NAME_ITEM_CELL_IDENTIFIER = @"NameItemCellIdentifier";
static NSString *INFO_DATE_ITEM_CELL_IDENTIFIER = @"InfoDateItemCellIdentifier";
static NSString *COPY_ITEM_CELL_IDENTIFIER = @"CopyItemCellIdentifier";
static NSString *INFO_FILE_ITEM_CELL_IDENTIFIER = @"InfoFileItemCellIdentifier";
static NSString *CALL_ITEM_CELL_IDENTIFIER = @"CallItemCellIdentifier";
static NSString *PEER_CALL_ITEM_CELL_IDENTIFIER = @"PeerCallItemCellIdentifier";
static NSString *INVITATION_CONTACT_ITEM_CELL_IDENTIFIER = @"InvitationContactItemCellIdentifier";
static NSString *PEER_INVITATION_CONTACT_ITEM_CELL_IDENTIFIER = @"PeerInvitationContactItemCellIdentifier";
static NSString *LOCATION_ITEM_CELL_IDENTIFIER = @"LocationItemCellIdentifier";
static NSString *PEER_LOCATION_ITEM_CELL_IDENTIFIER = @"PeerLocationItemCellIdentifier";
static NSString *CLEAR_ITEM_CELL_IDENTIFIER = @"ClearItemCellIdentifier";
static NSString *PEER_CLEAR_ITEM_CELL_IDENTIFIER = @"PeerClearItemCellIdentifier";
static NSString *ANNOTATION_INFO_CELL_IDENTIFIER = @"AnnotationInfoCellIdentifier";
static NSString *HEADER_SETTINGS_CELL_IDENTIFIER = @"HeaderSettingsCellIdentifier";
static NSString *SETTINGS_CELL_IDENTIFIER = @"SettingsCellIdentifier";

static const int INFO_VIEW_SECTION_COUNT = 6;

static const int ITEM_VIEW_SECTION = 0;
static const int DATE_VIEW_SECTION = 1;
static const int EPHEMERAL_VIEW_SECTION = 2;
static const int COPY_VIEW_SECTION = 3;
static const int FILE_VIEW_SECTION = 4;
static const int ANNOTATIONS_SECTION = 5;

//
// Interface: InfoItemViewController ()
//

@interface InfoItemViewController () <UITableViewDelegate, UITableViewDataSource, AsyncLoaderDelegate, InfoItemServiceDelegate, SettingsActionDelegate>

@property (weak, nonatomic) IBOutlet UITableView *infoTableView;

@property (nonatomic) id<TLOriginator> contact;
@property (nonatomic) TLGroup *group;
@property (nonatomic) NSString *contactName;
@property (nonatomic) UIImage *contactAvatar;
@property (nonatomic) UIImage *identityAvatar;

@property (nonatomic) AsyncManager *asyncLoaderManager;
@property (nonatomic) NSMutableArray *annotationsArray;
@property (nonatomic) InfoItemService *infoItemService;
@property (nonatomic) BOOL canUpdateCopy;

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
        _annotationsArray = [[NSMutableArray alloc]init];
        _canUpdateCopy = YES;
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
    
    [self updateAnnotations];
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

- (void)initWithContact:(id<TLOriginator>)contact andItem:(Item *)item {
    DDLogVerbose(@"%@ initWithContact: %@", LOG_TAG, contact);
    
    self.contact = contact;
    self.item = item;
    self.contactName = self.contact.name;
    if ([(NSObject*) contact class] == [TLGroupMember class]) {
        TLGroupMember *groupMember = (TLGroupMember *)contact;
        if ([groupMember.group isKindOfClass:[TLGroup class]]) {
            self.group = (TLGroup *)groupMember.group;
            [self.infoItemService getImageWithGroup:self.group withBlock:^(UIImage *image) {
                self.contactAvatar = image;
            }];
            [self.infoItemService getIdentityImageWithGroup:self.group withBlock:^(UIImage *image) {
                self.identityAvatar = image;
            }];

        } else {
            self.contact = groupMember.group;
            self.contactName = self.contact.name;
            [self.infoItemService getImageWithContact:(TLContact *)self.contact withBlock:^(UIImage *image) {
                self.contactAvatar = image;
            }];
            [self.infoItemService getIdentityImageWithContact:(TLContact *)self.contact withBlock:^(UIImage *image) {
                self.identityAvatar = image;
            }];
        }
    } else if ([contact isGroup]) {
        self.group = (TLGroup *)contact;
        [self.infoItemService getImageWithGroup:self.group withBlock:^(UIImage *image) {
            self.contactAvatar = image;
        }];
        [self.infoItemService getIdentityImageWithGroup:self.group withBlock:^(UIImage *image) {
            self.identityAvatar = image;
        }];
    } else {
        if (contact.peerTwincodeOutbound != nil && ![contact.peerTwincodeOutbound isSigned]) {
            self.canUpdateCopy = NO;
        }
        [self.infoItemService getImageWithContact:(TLContact *)contact withBlock:^(UIImage *image) {
            self.contactAvatar = image;
        }];
        [self.infoItemService getIdentityImageWithContact:(TLContact *)contact withBlock:^(UIImage *image) {
            self.identityAvatar = image;
        }];
    }
    
    [self.infoItemService initWithContact:contact];
}

#pragma mark - Async Loader

- (void)onLoadedWithItems:(nonnull NSMutableArray<id<NSObject>> *)items {
    DDLogVerbose(@"%@ onLoadedWithItems: %@", LOG_TAG, items);
    
    if ([items containsObject:self.item]) {
        [items removeObject:self.item];
        ItemCell *itemCell = (ItemCell *)[self.infoTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:ITEM_VIEW_SECTION]];
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
    
    return INFO_VIEW_SECTION_COUNT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ heightForHeaderInSection: %ld", LOG_TAG, tableView, (long)section);
    
    if (section == ANNOTATIONS_SECTION && self.annotationsArray.count > 0) {
        
        return Design.SETTING_SECTION_HEIGHT;
    }
    
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ heightForFooterInSection: %ld", LOG_TAG, tableView, (long)section);
    
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ heightForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if (indexPath.section == ITEM_VIEW_SECTION || indexPath.section == FILE_VIEW_SECTION) {
        return UITableViewAutomaticDimension;
    }
    
    return Design.SETTING_CELL_HEIGHT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ numberOfRowsInSection: %ld", LOG_TAG, tableView, (long)section);
    
    NSInteger numberOfRowsInSection;
    switch (section) {
        case ITEM_VIEW_SECTION:
            numberOfRowsInSection = 2;
            break;
            
        case DATE_VIEW_SECTION:
            switch (self.item.type) {
                case ItemTypeCall:
                case ItemTypePeerCall:
                    numberOfRowsInSection = 0;
                    break;
                default:
                    numberOfRowsInSection = 3;
                    if (self.item.peerDeletedTimestamp > 0) {
                        numberOfRowsInSection++;
                    }
                    
                    if ([self.item isEditedtem]) {
                        numberOfRowsInSection++;
                    }
                    
                    break;
            }
            break;
            
        case COPY_VIEW_SECTION:
            switch (self.item.type) {
                case ItemTypeInvitation:
                case ItemTypePeerInvitation:
                case ItemTypeInvitationContact:
                case ItemTypePeerInvitationContact:
                case ItemTypeCall:
                case ItemTypePeerCall:
                case ItemTypeClear:
                case ItemTypePeerClear:
                    numberOfRowsInSection = 0;
                    break;
                default:
                    numberOfRowsInSection = 1;
                    break;
            }
            break;
            
        case EPHEMERAL_VIEW_SECTION:
            if (self.item.isEphemeralItem && self.item.readTimestamp > 0) {
                numberOfRowsInSection = 1;
            } else {
                numberOfRowsInSection = 0;
            }
            break;
            
        case FILE_VIEW_SECTION:
            switch (self.item.type) {
                case ItemTypeMessage:
                case ItemTypePeerMessage:
                case ItemTypeLink:
                case ItemTypePeerLink:
                case ItemTypeInvitation:
                case ItemTypePeerInvitation:
                case ItemTypeInvitationContact:
                case ItemTypePeerInvitationContact:
                case ItemTypeLocation:
                case ItemTypePeerLocation:
                case ItemTypeClear:
                case ItemTypePeerClear:
                    numberOfRowsInSection = 0;
                    break;
                case ItemTypeImage:
                case ItemTypePeerImage:
                case ItemTypeVideo:
                case ItemTypePeerVideo:
                case ItemTypeAudio:
                case ItemTypePeerAudio:
                case ItemTypeFile:
                case ItemTypePeerFile:
                case ItemTypeCall:
                case ItemTypePeerCall:
                    numberOfRowsInSection = 1;
                    break;
                default:
                    numberOfRowsInSection = 0;
                    break;
            }
            break;
            
        case ANNOTATIONS_SECTION:
            numberOfRowsInSection = self.annotationsArray.count;
            break;
            
        default:
            numberOfRowsInSection = 0;
            break;
    }
    return numberOfRowsInSection;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ viewForHeaderInSection: %ld", LOG_TAG, tableView, (long)section);
    
    SettingsSectionHeaderCell *settingsSectionHeaderCell = (SettingsSectionHeaderCell *)[tableView dequeueReusableCellWithIdentifier:HEADER_SETTINGS_CELL_IDENTIFIER];
    if (!settingsSectionHeaderCell) {
        settingsSectionHeaderCell = [[SettingsSectionHeaderCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:HEADER_SETTINGS_CELL_IDENTIFIER];
    }
    
    NSString *sectionName = @"";
    if (section == ANNOTATIONS_SECTION && self.annotationsArray.count > 0) {
        sectionName = TwinmeLocalizedString(@"info_item_view_controller_reactions", nil);
    }
    
    [settingsSectionHeaderCell bindWithTitle:sectionName backgroundColor:Design.LIGHT_GREY_BACKGROUND_COLOR hideSeparator:YES uppercaseString:YES];
    
    return settingsSectionHeaderCell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ cellForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    switch (indexPath.section) {
        case ITEM_VIEW_SECTION:
            if (indexPath.row == 0) {
                TimeItem *timeItem = [[TimeItem alloc]initWithTimestamp:self.item.sentTimestamp > 0 ? self.item.sentTimestamp:self.item.createdTimestamp];
                TimeItemCell *timeCell = [[TimeItemCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:TIME_CELL_IDENTIFIER topMargin:0 bottomMargin:0];
                [timeCell bindWithItem:timeItem conversationViewController:self.conversationViewController];
                timeCell.contentView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
                return timeCell;
            }
            
            self.item.replyAllowed = NO;
            switch (self.item.type) {
                case ItemTypeInfoPrivacy:
                case ItemTypeTime:
                case ItemTypeName:
                    break;
                    
                case ItemTypeMessage: {
                    MessageItem *messageItem = (MessageItem *)self.item;
                    MessageItemCell *messageItemCell = (MessageItemCell *)[self.infoTableView dequeueReusableCellWithIdentifier:MESSAGE_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
                    [messageItemCell bindWithItem:messageItem conversationViewController:self.conversationViewController asyncManager:self.asyncLoaderManager];
                    messageItemCell.contentView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
                    return messageItemCell;
                }
                    
                case ItemTypePeerMessage: {
                    PeerMessageItem *peerMessageItem = (PeerMessageItem *)self.item;
                    PeerMessageItemCell *peerMessageItemCell = (PeerMessageItemCell *)[self.infoTableView dequeueReusableCellWithIdentifier:PEER_MESSAGE_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
                    [peerMessageItemCell bindWithItem:peerMessageItem conversationViewController:self.conversationViewController asyncManager:self.asyncLoaderManager];
                    peerMessageItemCell.contentView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
                    return peerMessageItemCell;
                }
                    
                case ItemTypeLink: {
                    LinkItem *linkItem = (LinkItem *)self.item;
                    LinkItemCell *linkItemCell = (LinkItemCell *)[self.infoTableView dequeueReusableCellWithIdentifier:LINK_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
                    [linkItemCell bindWithItem:linkItem conversationViewController:self.conversationViewController asyncManager:self.asyncLoaderManager];
                    linkItemCell.contentView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
                    return linkItemCell;
                }
                    
                case ItemTypePeerLink: {
                    PeerLinkItem *peerLinkItem = (PeerLinkItem *)self.item;
                    PeerLinkItemCell *peerLinkItemCell = (PeerLinkItemCell *)[self.infoTableView dequeueReusableCellWithIdentifier:PEER_LINK_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
                    [peerLinkItemCell bindWithItem:peerLinkItem conversationViewController:self.conversationViewController asyncManager:self.asyncLoaderManager];
                    peerLinkItemCell.contentView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
                    return peerLinkItemCell;
                }
                    
                case ItemTypeImage: {
                    ImageItem *imageItem = (ImageItem *)self.item;
                    ImageItemCell *imageItemCell = (ImageItemCell *)[self.infoTableView dequeueReusableCellWithIdentifier:IMAGE_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
                    [imageItemCell bindWithItem:imageItem conversationViewController:self.conversationViewController asyncManager:self.asyncLoaderManager];
                    imageItemCell.contentView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
                    return imageItemCell;
                }
                    
                case ItemTypePeerImage: {
                    PeerImageItem *peerImageItem = (PeerImageItem *)self.item;
                    PeerImageItemCell *peerImageItemCell = (PeerImageItemCell *)[self.infoTableView dequeueReusableCellWithIdentifier:PEER_IMAGE_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
                    [peerImageItemCell bindWithItem:peerImageItem conversationViewController:self.conversationViewController asyncManager:self.asyncLoaderManager];
                    peerImageItemCell.contentView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
                    return peerImageItemCell;
                }
                    
                case ItemTypeAudio: {
                    AudioItem *audioItem = (AudioItem *)self.item;
                    AudioItemCell *audioItemCell = (AudioItemCell *)[self.infoTableView dequeueReusableCellWithIdentifier:AUDIO_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
                    [audioItemCell bindWithItem:audioItem conversationViewController:self.conversationViewController asyncManager:self.asyncLoaderManager];
                    audioItemCell.contentView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
                    return audioItemCell;
                }
                    
                case ItemTypePeerAudio: {
                    PeerAudioItem *peerAudioItem = (PeerAudioItem *)self.item;
                    PeerAudioItemCell *peerAudioItemCell = (PeerAudioItemCell *)[self.infoTableView dequeueReusableCellWithIdentifier:PEER_AUDIO_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
                    [peerAudioItemCell bindWithItem:peerAudioItem conversationViewController:self.conversationViewController asyncManager:self.asyncLoaderManager];
                    peerAudioItemCell.contentView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
                    return peerAudioItemCell;
                }
                    
                case ItemTypeVideo: {
                    VideoItem *videoItem = (VideoItem *)self.item;
                    VideoItemCell *videoItemCell = (VideoItemCell *)[self.infoTableView dequeueReusableCellWithIdentifier:VIDEO_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
                    [videoItemCell bindWithItem:videoItem conversationViewController:self.conversationViewController asyncManager:self.asyncLoaderManager];
                    videoItemCell.contentView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
                    return videoItemCell;
                }
                    
                case ItemTypePeerVideo: {
                    PeerVideoItem *peerVideoItem = (PeerVideoItem *)self.item;
                    PeerVideoItemCell *peerVideoItemCell = (PeerVideoItemCell *)[self.infoTableView dequeueReusableCellWithIdentifier:PEER_VIDEO_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
                    [peerVideoItemCell bindWithItem:peerVideoItem conversationViewController:self.conversationViewController asyncManager:self.asyncLoaderManager];
                    peerVideoItemCell.contentView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
                    return peerVideoItemCell;
                }
                    
                case ItemTypeFile: {
                    FileItem *fileItem = (FileItem *)self.item;
                    FileItemCell *fileItemCell = (FileItemCell *)[self.infoTableView dequeueReusableCellWithIdentifier:FILE_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
                    [fileItemCell bindWithItem:fileItem conversationViewController:self.conversationViewController asyncManager:self.asyncLoaderManager];
                    fileItemCell.contentView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
                    return fileItemCell;
                }
                    
                case ItemTypePeerFile: {
                    PeerFileItem *peerFileItem = (PeerFileItem *)self.item;
                    PeerFileItemCell *peerFileItemCell = (PeerFileItemCell *)[self.infoTableView dequeueReusableCellWithIdentifier:PEER_FILE_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
                    [peerFileItemCell bindWithItem:peerFileItem conversationViewController:self.conversationViewController asyncManager:self.asyncLoaderManager];
                    peerFileItemCell.contentView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
                    return peerFileItemCell;
                }
                    
                case ItemTypeInvitation: {
                    InvitationItem *invitationItem = (InvitationItem *)self.item;
                    InvitationItemCell *invitationItemCell = (InvitationItemCell *)[self.infoTableView dequeueReusableCellWithIdentifier:INVITATION_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
                    [invitationItemCell bindWithItem:invitationItem conversationViewController:self.conversationViewController];
                    invitationItemCell.contentView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
                    return invitationItemCell;
                }
                    
                case ItemTypePeerInvitation: {
                    PeerInvitationItem *peerInvitationItem = (PeerInvitationItem *)self.item;
                    PeerInvitationItemCell *peerInvitationItemCell = (PeerInvitationItemCell *)[self.infoTableView dequeueReusableCellWithIdentifier:PEER_INVITATION_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
                    [peerInvitationItemCell bindWithItem:peerInvitationItem conversationViewController:self.conversationViewController];
                    peerInvitationItemCell.contentView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
                    return peerInvitationItemCell;
                }
                    
                case ItemTypeCall: {
                    CallItem *callItem = (CallItem *)self.item;
                    CallItemCell *callItemCell = (CallItemCell *)[self.infoTableView dequeueReusableCellWithIdentifier:CALL_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
                    [callItemCell bindWithItem:callItem conversationViewController:self.conversationViewController];
                    callItemCell.contentView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
                    return callItemCell;
                }
                    
                case ItemTypePeerCall: {
                    PeerCallItem *peerCallItem = (PeerCallItem *)self.item;
                    PeerCallItemCell *peerCallItemCell = (PeerCallItemCell *)[self.infoTableView dequeueReusableCellWithIdentifier:PEER_CALL_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
                    [peerCallItemCell bindWithItem:peerCallItem conversationViewController:self.conversationViewController];
                    peerCallItemCell.contentView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
                    return peerCallItemCell;
                }
                    
                case ItemTypeInvitationContact: {
                    InvitationContactItem *invitationContactItem = (InvitationContactItem *)self.item;
                    InvitationContactItemCell *invitationContactItemCell = (InvitationContactItemCell *)[self.infoTableView dequeueReusableCellWithIdentifier:INVITATION_CONTACT_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
                    [invitationContactItemCell bindWithItem:invitationContactItem conversationViewController:self.conversationViewController];
                    invitationContactItemCell.contentView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
                    return invitationContactItemCell;
                }
                    
                case ItemTypePeerInvitationContact: {
                    PeerInvitationContactItem *peerInvitationContactItem = (PeerInvitationContactItem *)self.item;
                    PeerInvitationContactItemCell *peerInvitationContactItemCell = (PeerInvitationContactItemCell *)[self.infoTableView dequeueReusableCellWithIdentifier:PEER_INVITATION_CONTACT_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
                    [peerInvitationContactItemCell bindWithItem:peerInvitationContactItem conversationViewController:self.conversationViewController];
                    peerInvitationContactItemCell.contentView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
                    return peerInvitationContactItemCell;
                }
                    
                case ItemTypeLocation: {
                    LocationItem *locationItem = (LocationItem *)self.item;
                    LocationItemCell *locationItemCell = (LocationItemCell *)[self.infoTableView dequeueReusableCellWithIdentifier:LOCATION_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
                    [locationItemCell bindWithItem:locationItem conversationViewController:self.conversationViewController];
                    locationItemCell.contentView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
                    return locationItemCell;
                }
                    
                case ItemTypePeerLocation: {
                    PeerLocationItem *peerLocationItem = (PeerLocationItem *)self.item;
                    PeerLocationItemCell *peerLocationItemCell = (PeerLocationItemCell *)[self.infoTableView dequeueReusableCellWithIdentifier:PEER_LOCATION_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
                    [peerLocationItemCell bindWithItem:peerLocationItem conversationViewController:self.conversationViewController];
                    peerLocationItemCell.contentView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
                    return peerLocationItemCell;
                }

                case ItemTypeClear: {
                    ClearItem *clearItem = (ClearItem *)self.item;
                    ClearItemCell *clearItemCell = (ClearItemCell *)[self.infoTableView dequeueReusableCellWithIdentifier:CLEAR_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
                    [clearItemCell bindWithItem:clearItem conversationViewController:self.conversationViewController];
                    clearItemCell.contentView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
                    return clearItemCell;
                }
                    
                case ItemTypePeerClear: {
                    PeerClearItem *peerClearItem = (PeerClearItem *)self.item;
                    PeerClearItemCell *peerClearItemCell = (PeerClearItemCell *)[self.infoTableView dequeueReusableCellWithIdentifier:PEER_CLEAR_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
                    [peerClearItemCell bindWithItem:peerClearItem conversationViewController:self.conversationViewController];
                    peerClearItemCell.contentView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
                    return peerClearItemCell;
                }
            }
            
        case DATE_VIEW_SECTION: {
            InfoDateItemCell *infoDateItemCell = (InfoDateItemCell *)[self.infoTableView dequeueReusableCellWithIdentifier:INFO_DATE_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
            InfoItemType infoItemType;
            if (indexPath.row == 0) {
                infoItemType = InfoItemTypeSent;
            } else if (indexPath.row == 1) {
                infoItemType = InfoItemTypeReceived;
            } else if (indexPath.row == 2) {
                infoItemType = InfoItemTypeSeen;
            } else if (indexPath.row == 3) {
                infoItemType = InfoItemTypeUpdated;
            } else  {
                infoItemType = InfoItemTypeDeleted;
            }
            [infoDateItemCell bindWithItem:self.item infoItemType:infoItemType conversationViewController:self.conversationViewController];
            return infoDateItemCell;
        }
            
        case COPY_VIEW_SECTION: {
            if (self.canUpdateCopy && (self.item.type == ItemTypeMessage || self.item.type == ItemTypeImage || self.item.type == ItemTypeVideo || self.item.type == ItemTypeAudio || self.item.type == ItemTypeFile || self.item.type == ItemTypeLink)) {
                SettingsItemCell *cell = [tableView dequeueReusableCellWithIdentifier:SETTINGS_CELL_IDENTIFIER];
                if (!cell) {
                    cell = [[SettingsItemCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SETTINGS_CELL_IDENTIFIER];
                }
                
                cell.settingsActionDelegate = self;
            
                [cell bindWithTitle:TwinmeLocalizedString(@"conversation_view_controller_send_menu_allow_copy", nil) icon:self.item.copyAllowed ? [UIImage imageNamed:@"SendOptionCopyAllowedIcon"]:[UIImage imageNamed:@"SendOptionCopyIcon"] stateSwitch:self.item.copyAllowed tagSwitch:0 hiddenSwitch:NO disableSwitch:NO backgroundColor:Design.WHITE_COLOR hiddenSeparator:NO];
                
                return cell;
            } else {
                CopyItemCell *copyItemCell = (CopyItemCell *)[self.infoTableView dequeueReusableCellWithIdentifier:COPY_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
                [copyItemCell bindWithItem:self.item];
                return copyItemCell;
            }
        }
            
        case EPHEMERAL_VIEW_SECTION: {
            InfoDateItemCell *infoDateItemCell = (InfoDateItemCell *)[self.infoTableView dequeueReusableCellWithIdentifier:INFO_DATE_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
            [infoDateItemCell bindWithItem:self.item infoItemType:InfoItemTypeEphemeral conversationViewController:self.conversationViewController];
            return infoDateItemCell;
        }
            
        case FILE_VIEW_SECTION: {
            InfoFileItemCell *infoFileItemCell = (InfoFileItemCell *)[self.infoTableView dequeueReusableCellWithIdentifier:INFO_FILE_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
            [infoFileItemCell bindWithItem:self.item originator:[self.conversationViewController getOriginator]];
            return infoFileItemCell;
        }
            
        case ANNOTATIONS_SECTION: {
            AnnotationInfoCell *annotationInfoCell = [tableView dequeueReusableCellWithIdentifier:ANNOTATION_INFO_CELL_IDENTIFIER];
            if (!annotationInfoCell) {
                annotationInfoCell = [[AnnotationInfoCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ANNOTATION_INFO_CELL_IDENTIFIER];
            }
            
            UIAnnotation *uiAnnotation = [self.annotationsArray objectAtIndex:indexPath.row];
            BOOL hideSeparator = indexPath.row + 1 == self.annotationsArray.count ? YES : NO;
            [annotationInfoCell bindWithAnnotation:uiAnnotation hideSeparator:hideSeparator];
            return annotationInfoCell;
        }
    }
    return [[UITableViewCell alloc]init];
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.view.backgroundColor = Design.WHITE_COLOR;
        
    [self setNavigationTitle:TwinmeLocalizedString(@"conversation_view_controller_menu_item_view_info_title", nil)];
    
    self.infoTableView.delegate = self;
    self.infoTableView.dataSource = self;
    [self.infoTableView setBackgroundColor:Design.WHITE_COLOR];
    self.infoTableView.rowHeight = UITableViewAutomaticDimension;
    self.infoTableView.estimatedRowHeight = Design.SETTING_CELL_HEIGHT;
    self.infoTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.infoTableView registerNib:[UINib nibWithNibName:@"MessageItemCell" bundle:nil] forCellReuseIdentifier:MESSAGE_ITEM_CELL_IDENTIFIER];
    [self.infoTableView registerNib:[UINib nibWithNibName:@"PeerMessageItemCell" bundle:nil] forCellReuseIdentifier:PEER_MESSAGE_ITEM_CELL_IDENTIFIER];
    [self.infoTableView registerNib:[UINib nibWithNibName:@"LinkItemCell" bundle:nil] forCellReuseIdentifier:LINK_ITEM_CELL_IDENTIFIER];
    [self.infoTableView registerNib:[UINib nibWithNibName:@"PeerLinkItemCell" bundle:nil] forCellReuseIdentifier:PEER_LINK_ITEM_CELL_IDENTIFIER];
    [self.infoTableView registerNib:[UINib nibWithNibName:@"ImageItemCell" bundle:nil] forCellReuseIdentifier:IMAGE_ITEM_CELL_IDENTIFIER];
    [self.infoTableView registerNib:[UINib nibWithNibName:@"PeerImageItemCell" bundle:nil] forCellReuseIdentifier:PEER_IMAGE_ITEM_CELL_IDENTIFIER];
    [self.infoTableView registerNib:[UINib nibWithNibName:@"AudioItemCell" bundle:nil] forCellReuseIdentifier:AUDIO_ITEM_CELL_IDENTIFIER];
    [self.infoTableView registerNib:[UINib nibWithNibName:@"PeerAudioItemCell" bundle:nil] forCellReuseIdentifier:PEER_AUDIO_ITEM_CELL_IDENTIFIER];
    [self.infoTableView registerClass:[TimeItemCell class] forCellReuseIdentifier:TIME_CELL_IDENTIFIER];
    [self.infoTableView registerNib:[UINib nibWithNibName:@"VideoItemCell" bundle:nil] forCellReuseIdentifier:VIDEO_ITEM_CELL_IDENTIFIER];
    [self.infoTableView registerNib:[UINib nibWithNibName:@"PeerVideoItemCell" bundle:nil] forCellReuseIdentifier:PEER_VIDEO_ITEM_CELL_IDENTIFIER];
    [self.infoTableView registerNib:[UINib nibWithNibName:@"FileItemCell" bundle:nil] forCellReuseIdentifier:FILE_ITEM_CELL_IDENTIFIER];
    [self.infoTableView registerNib:[UINib nibWithNibName:@"PeerFileItemCell" bundle:nil] forCellReuseIdentifier:PEER_FILE_ITEM_CELL_IDENTIFIER];
    [self.infoTableView registerNib:[UINib nibWithNibName:@"InvitationItemCell" bundle:nil] forCellReuseIdentifier:INVITATION_ITEM_CELL_IDENTIFIER];
    [self.infoTableView registerNib:[UINib nibWithNibName:@"PeerInvitationItemCell" bundle:nil] forCellReuseIdentifier:PEER_INVITATION_ITEM_CELL_IDENTIFIER];
    [self.infoTableView registerNib:[UINib nibWithNibName:@"CallItemCell" bundle:nil] forCellReuseIdentifier:CALL_ITEM_CELL_IDENTIFIER];
    [self.infoTableView registerNib:[UINib nibWithNibName:@"PeerCallItemCell" bundle:nil] forCellReuseIdentifier:PEER_CALL_ITEM_CELL_IDENTIFIER];
    [self.infoTableView registerNib:[UINib nibWithNibName:@"NameItemCell" bundle:nil] forCellReuseIdentifier:NAME_ITEM_CELL_IDENTIFIER];
    [self.infoTableView registerNib:[UINib nibWithNibName:@"InfoDateItemCell" bundle:nil] forCellReuseIdentifier:INFO_DATE_ITEM_CELL_IDENTIFIER];
    [self.infoTableView registerNib:[UINib nibWithNibName:@"CopyItemCell" bundle:nil] forCellReuseIdentifier:COPY_ITEM_CELL_IDENTIFIER];
    [self.infoTableView registerNib:[UINib nibWithNibName:@"InfoFileItemCell" bundle:nil] forCellReuseIdentifier:INFO_FILE_ITEM_CELL_IDENTIFIER];
    [self.infoTableView registerNib:[UINib nibWithNibName:@"InvitationContactItemCell" bundle:nil] forCellReuseIdentifier:INVITATION_CONTACT_ITEM_CELL_IDENTIFIER];
    [self.infoTableView registerNib:[UINib nibWithNibName:@"PeerInvitationContactItemCell" bundle:nil] forCellReuseIdentifier:PEER_INVITATION_CONTACT_ITEM_CELL_IDENTIFIER];
    [self.infoTableView registerNib:[UINib nibWithNibName:@"LocationItemCell" bundle:nil] forCellReuseIdentifier:LOCATION_ITEM_CELL_IDENTIFIER];
    [self.infoTableView registerNib:[UINib nibWithNibName:@"PeerLocationItemCell" bundle:nil] forCellReuseIdentifier:PEER_LOCATION_ITEM_CELL_IDENTIFIER];
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

- (void)updateAnnotations {
    DDLogVerbose(@"%@ updateAnnotations", LOG_TAG);

    [self.infoItemService listAnnotationsWithDescriptorId:self.item.descriptorId withBlock:^(NSMutableDictionary<NSUUID *, TLDescriptorAnnotationPair *>* annotations) {
        // This code block is run by TwinlifeExecutor, so we can call the blocking getImageWithTwincode() variant.
        NSMutableArray<UIAnnotation *> *uiAnnotationList = [[NSMutableArray alloc] initWithCapacity:annotations.count];
        
        for (NSUUID *uuid in annotations.allKeys) {
            TLDescriptorAnnotationPair *descriptorAnnotation = [annotations objectForKey:uuid];
            if (descriptorAnnotation.annotation.type == TLDescriptorAnnotationTypeLike) {
                UIReaction *uiReaction = [[UIReaction alloc]initWithDescriptorAnnotationValue:descriptorAnnotation.annotation.value];
                NSString *name = descriptorAnnotation.twincodeOutbound.name;
                UIImage *avatar = [self.infoItemService getImageWithTwincode:descriptorAnnotation.twincodeOutbound];
                
                UIAnnotation *uiAnnotation = [[UIAnnotation alloc]initWithReaction:uiReaction name:name avatar:avatar];
                [uiAnnotationList addObject:uiAnnotation];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.annotationsArray = uiAnnotationList;
            [self.infoTableView reloadData];
        });
    }];
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    [self.infoTableView reloadData];
}

@end

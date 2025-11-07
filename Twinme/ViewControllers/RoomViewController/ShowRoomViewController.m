/*
 *  Copyright (c) 2020-2022 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 *   Stephane Carrez (Stephane.Carrez@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinlife/TLImageService.h>
#import <Twinlife/TLTwincodeOutboundService.h>

#import <Twinme/TLContact.h>
#import <Twinme/TLProfile.h>
#import <Twinme/TLSpace.h>
#import <Twinme/TLRoomCommand.h>

#import <Utils/NSString+Utils.h>

#import <TwinmeCommon/ShowRoomService.h>

#import "ShowRoomViewController.h"
#import "AdminRoomViewController.h"
#import "EditContactViewController.h"
#import "RoomMembersViewController.h"
#import "EditIdentityViewController.h"
#import "ConversationViewController.h"
#import "ConversationFilesViewController.h"
#import <TwinmeCommon/CallViewController.h>
#import "LastCallsViewController.h"
#import "SpacesViewController.h"
#import <TwinmeCommon/TwinmeNavigationController.h>
#import "AdminRoomViewController.h"
#import "TypeCleanupViewController.h"
#import "ExportViewController.h"

#import "ShowMemberCell.h"
#import "UIRoomMember.h"

#import "InsideBorderView.h"
#import <TwinmeCommon/Design.h>
#import "DeviceAuthorization.h"
#import "AlertMessageView.h"
#import "UIColor+Hex.h"
#import "UIView+Toast.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static NSString *MEMBER_CELL_IDENTIFIER = @"ShowMemberCellIdentifier";
static CGFloat DESIGN_COLLECTION_CELL_HEIGHT = 120;
static int MAX_ROOM_MEMBER = 5;

//
// Interface: ShowRoomViewController ()
//

@interface ShowRoomViewController ()<ShowRoomServiceDelegate, UICollectionViewDataSource, AlertMessageViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *chatView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *chatRoundedView;
@property (weak, nonatomic) IBOutlet UILabel *chatLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *videoViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *videoViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *videoViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *videoRoundedView;
@property (weak, nonatomic) IBOutlet UIView *videoView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *videoImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *videoLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *audioViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *audioViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *audioViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *audioViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *audioViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *audioRoundedView;
@property (weak, nonatomic) IBOutlet UIView *audioView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *audioImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *audioLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *membersLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *membersLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *membersLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *membersLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *membersViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *membersViewHeightConstraint;
@property (weak, nonatomic) IBOutlet InsideBorderView *membersView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *membersCollectionViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *membersCollectionViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UICollectionView *membersCollectionView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *memberIndicatorView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *adminViewHeightConstraint;
@property (weak, nonatomic) IBOutlet InsideBorderView *adminView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *adminLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *adminLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *adminLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *adminAccessoryViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *adminAccessoryViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *adminAccessoryView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *historyTitleLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *historyTitleLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *historyTitleLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *historyTitleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lastCallViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lastCallViewTopConstraint;
@property (weak, nonatomic) IBOutlet InsideBorderView *lastCallView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lastCallImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lastCallImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lastCallLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lastCallLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *lastCallLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lastCallAccessoryViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lastCallAccessoryViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *lastCallAccessoryView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spaceViewHeightConstraint;
@property (weak, nonatomic) IBOutlet InsideBorderView *spaceView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spaceImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spaceImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *spaceImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spaceAvatarViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spaceAvatarViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *spaceAvatarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spaceLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spaceLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *spaceLabel;
@property (weak, nonatomic) IBOutlet UILabel *spaceAvatarLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *conversationsTitleLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *conversationsTitleLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *conversationsTitleLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *conversationsTitleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *filesViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *filesViewTopConstraint;
@property (weak, nonatomic) IBOutlet InsideBorderView *filesView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *filesImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *filesImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *filesImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *filesLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *filesLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *filesLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *filesAccessoryViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *filesAccessoryViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *filesAccessoryView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *exportViewHeightConstraint;
@property (weak, nonatomic) IBOutlet InsideBorderView *exportView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *exportImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *exportImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *exportImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *exportLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *exportLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *exportLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *exportAccessoryViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *exportAccessoryViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *exportAccessoryView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cleanViewHeightConstraint;
@property (weak, nonatomic) IBOutlet InsideBorderView *cleanView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cleanImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cleanImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *cleanImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cleanLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cleanLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *cleanLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cleanAccessoryViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cleanAccessoryViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *cleanAccessoryView;

@property (nonatomic) TLContact *room;
@property (nonatomic) NSString *roomName;
@property (nonatomic) UIImage *roomAvatar;

@property (nonatomic) NSMutableArray *uiRoomMembers;
@property (nonatomic) int memberCount;

@property (nonatomic) ShowRoomService *showRoomService;

@end

#undef LOG_TAG
#define LOG_TAG @"ShowRoomViewController"

//
// Implementation: ShowRoomViewController
//

@implementation ShowRoomViewController

#pragma mark - UIViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _uiRoomMembers = [[NSMutableArray alloc]init];
        _showRoomService = [[ShowRoomService alloc] initWithTwinmeContext:self.twinmeContext delegate:self];
    }
    
    return self;
}

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
    
    [self initViews];
}

- (void)initWithRoom:(TLContact *)room {
    DDLogVerbose(@"%@ initWithRoom: %@", LOG_TAG, room);
    
    self.room = room;
    
    [self.showRoomService initWithRoom:room];
    
    self.roomName = self.room.name;
    
    if ([self.room hasPrivateIdentity]) {
        self.identityName = self.room.identityName;
        [self.showRoomService getIdentityImageWithContact:room withBlock:^(UIImage *image) {
            self.identityAvatar = image;
        }];
    } else {
        self.identityName = nil;
        self.identityAvatar = [TLContact ANONYMOUS_AVATAR];
    }
    
    if (self.room.hasPeer) {
        [self.showRoomService getImageWithContact:room withBlock:^(UIImage *image) {
            self.roomAvatar = image;
        }];
    } else {
        self.roomAvatar = [TLContact ANONYMOUS_AVATAR];
    }
    
    [self checkSpacePermission];
}

- (void)editTap {
    DDLogVerbose(@"%@ editTap", LOG_TAG);
    
    EditContactViewController *editContactViewController = [[UIStoryboard storyboardWithName:@"Contact" bundle:nil] instantiateViewControllerWithIdentifier:@"EditContactViewController"];
    editContactViewController.contact = self.room;
    [self.navigationController pushViewController:editContactViewController animated:YES];
}

- (void)identityTap {
    DDLogVerbose(@"%@ identityTap", LOG_TAG);
    
    EditIdentityViewController *editItentityViewController = [[UIStoryboard storyboardWithName:@"iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"EditIdentityViewController"];
    [editItentityViewController initWithContact:self.room];
    [self.navigationController pushViewController:editItentityViewController animated:YES];
}

- (BOOL)showNavigationBar {
    DDLogVerbose(@"%@ showNavigationBar", LOG_TAG);
    
    if (self.room) {
        return self.room.hasPeer;
    }
    
    return NO;
}

- (int)getActionViewHeight {
    DDLogVerbose(@"%@ getActionViewHeight", LOG_TAG);
    
    UIWindow *window = UIApplication.sharedApplication.keyWindow;
    CGFloat safeAreaInset = window.safeAreaInsets.bottom;
    
    return self.cleanView.frame.origin.y + self.cleanViewHeightConstraint.constant + safeAreaInset;
}

#pragma mark - ShowRoomServiceDelegate

- (void)onUpdateRoom:(TLContact *)room avatar:(nullable UIImage *)avatar {
    DDLogVerbose(@"%@ onUpdateRoom: %@", LOG_TAG, room);
    
    if (!self.room || ![room.uuid isEqual:self.room.uuid]) {
        return;
    }
    
    self.room = room;
    
    if (self.room.hasPeer) {
        self.roomName = self.room.name;
        if (avatar) {
            self.roomAvatar = avatar;
        } else {
            self.roomAvatar = [TLContact ANONYMOUS_AVATAR];
        }
        if ([self.room hasPrivateIdentity]) {
            self.identityName = self.room.identityName;
            [self.showRoomService getIdentityImageWithContact:self.room withBlock:^(UIImage *image) {
                self.identityAvatar = image;
            }];
        } else {
            self.identityName = nil;
            self.identityAvatar = [TLContact ANONYMOUS_AVATAR];
        }
    } else {
        self.scrollView.hidden = YES;
        self.fallbackView.hidden = NO;
        self.backClickableView.hidden = YES;
        self.navigationController.navigationBarHidden = NO;
        self.roomAvatar = [TLContact ANONYMOUS_AVATAR];
    }
    
    [self updateRoom];
    [self checkSpacePermission];
}

- (void)onDeleteRoom:(NSUUID *)roomId {
    DDLogVerbose(@"%@ onDeleteRoom: %@", LOG_TAG, roomId);
    
    if (!self.room || ![roomId isEqual:self.room.uuid]) {
        return;
    }
    
    [self finish];
}

- (void)onGetRoomMembers:(nonnull NSArray *)roomMembers memberCount:(int)memberCount {
    DDLogVerbose(@"%@ onGetRoomMembers: %@ memberCount: %d", LOG_TAG, roomMembers, memberCount);
    
    self.memberCount = memberCount;
    
    [self.memberIndicatorView stopAnimating];
    
    for (TLTwincodeOutbound *twincodeOutbound in roomMembers) {
        UIRoomMember *uiRoomMember = [[UIRoomMember alloc]initWithTwincodeOutbound:twincodeOutbound avatar:nil];
        [self.uiRoomMembers addObject:uiRoomMember];
    }
    
    [self.membersCollectionView reloadData];
}

- (void)onGetRoomMemberAvatar:(nonnull TLTwincodeOutbound *)twincodeOutbound avatar:(nonnull UIImage *)avatar {
    DDLogVerbose(@"%@ onGetRoomMemberAvatar: %@ avatar: %@", LOG_TAG, twincodeOutbound, avatar);
    
    for (UIRoomMember *uiRoomMember in self.uiRoomMembers) {
        if ([twincodeOutbound.uuid isEqual:uiRoomMember.twincodeOutbound.uuid]) {
            [uiRoomMember setTwincodeOutbound:twincodeOutbound avatar:avatar];
            break;
        }
    }
    
    [self.membersCollectionView reloadData];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    DDLogVerbose(@"%@ numberOfSectionsInCollectionView: %@", LOG_TAG, collectionView);
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ collectionView: %@ numberOfItemsInSection: %ld", LOG_TAG, collectionView, (long)section);
    
    if (self.uiRoomMembers.count <= MAX_ROOM_MEMBER) {
        return self.uiRoomMembers.count;
    }
    
    return MAX_ROOM_MEMBER + 1;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ collectionView: %@ layout: %@ sizeForItemAtIndexPath: %@", LOG_TAG, collectionView, collectionViewLayout, indexPath);
    
    CGFloat heightCell = MIN(DESIGN_COLLECTION_CELL_HEIGHT * Design.HEIGHT_RATIO, roundf((Design.DISPLAY_WIDTH - (self.membersCollectionViewLeadingConstraint.constant * 2)) / 6));
    return CGSizeMake(heightCell, heightCell);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    DDLogVerbose(@"%@ collectionView: %@ layout: %@ minimumLineSpacingForSectionAtIndex: %ld", LOG_TAG, collectionView, collectionViewLayout, (long)section);
    
    return 0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ collectionView: %@ layout: %@ referenceSizeForHeaderInSection: %ld", LOG_TAG, collectionView, collectionViewLayout, (long)section);
    
    return CGSizeMake(0, 0);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ collectionView: %@ cellForItemAtIndexPath: %@", LOG_TAG, collectionView, indexPath);
    
    ShowMemberCell *showRoomMemberCell = [collectionView dequeueReusableCellWithReuseIdentifier:MEMBER_CELL_IDENTIFIER forIndexPath:indexPath];
    
    if (indexPath.row < MAX_ROOM_MEMBER) {
        UIRoomMember *uiMember = self.uiRoomMembers[indexPath.row];
        [showRoomMemberCell bindWithName:uiMember.name avatar:uiMember.avatar memberCount:self.memberCount];
    } else {
        [showRoomMemberCell bindWithName:nil avatar:nil memberCount:self.memberCount - MAX_ROOM_MEMBER];
    }
    
    return showRoomMemberCell;
}

#pragma mark - AlertMessageViewDelegate

- (void)didCloseAlertMessage:(nonnull AlertMessageView *)alertMessageView {
    DDLogVerbose(@"%@ didCloseAlertMessage: %@", LOG_TAG, alertMessageView);
    
    [alertMessageView closeAlertView];
}

- (void)didFinishCloseAlertMessageAnimation:(nonnull AlertMessageView *)alertMessageView {
    DDLogVerbose(@"%@ didFinishCloseAlertMessageAnimation: %@", LOG_TAG, alertMessageView);
    
    [alertMessageView removeFromSuperview];
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    [super initViews];
    
    self.chatViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.chatViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.chatViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    UITapGestureRecognizer *chatViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleChatTapGesture:)];
    [self.chatView addGestureRecognizer:chatViewGestureRecognizer];
    
    self.chatRoundedView.backgroundColor = Design.CHAT_COLOR;
    self.chatRoundedView.layer.cornerRadius = self.chatViewWidthConstraint.constant * 0.5;
    
    self.chatImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.chatLabel.font = Design.FONT_REGULAR28;
    self.chatLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.chatLabel.text = TwinmeLocalizedString(@"show_contact_view_controller_chat", nil);
    
    self.videoViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.videoViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.videoViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    UITapGestureRecognizer *videoViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleVideoTapGesture:)];
    [self.videoView addGestureRecognizer:videoViewGestureRecognizer];
    [self.videoView setAccessibilityLabel:TwinmeLocalizedString(@"conversation_view_controller_video_call", nil)];
    
    self.videoRoundedView.backgroundColor = Design.VIDEO_CALL_COLOR;
    self.videoRoundedView.layer.cornerRadius = self.videoViewWidthConstraint.constant * 0.5;
    
    self.videoImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.videoLabel.font = Design.FONT_REGULAR28;
    self.videoLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.videoLabel.text = TwinmeLocalizedString(@"show_contact_view_controller_video", nil);
    
    self.audioViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.audioViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.audioViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.audioViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.audioViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    UITapGestureRecognizer *audioViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleAudioTapGesture:)];
    [self.audioView addGestureRecognizer:audioViewGestureRecognizer];
    
    self.audioRoundedView.backgroundColor = Design.AUDIO_CALL_COLOR;
    self.audioRoundedView.layer.cornerRadius = self.audioViewWidthConstraint.constant * 0.5;
    
    self.audioImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.audioLabel.font = Design.FONT_REGULAR28;
    self.audioLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.audioLabel.text = TwinmeLocalizedString(@"show_contact_view_controller_audio", nil);
    
    self.membersLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.membersLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.membersLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.membersLabel.font = Design.FONT_BOLD26;
    self.membersLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.membersLabel.text = TwinmeLocalizedString(@"show_room_view_controller_room_title", nil).uppercaseString;
    
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    
    self.membersViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.membersViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    [self.membersView setBorder:Design.SEPARATOR_COLOR_GREY borderWidth:Design.SEPARATOR_HEIGHT width:screenWidth  height:self.membersViewHeightConstraint.constant left:false right:false top:true bottom:true];
    
    self.membersView.userInteractionEnabled = true;
    self.membersView.backgroundColor = Design.WHITE_COLOR;
    
    UITapGestureRecognizer *membersViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleMembersTapGesture:)];
    [self.membersView addGestureRecognizer:membersViewGestureRecognizer];
    
    self.membersCollectionViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.membersCollectionViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    UICollectionViewFlowLayout* viewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    [viewFlowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [viewFlowLayout setMinimumInteritemSpacing:0];
    [viewFlowLayout setMinimumLineSpacing:0];
    CGFloat heightCell = MIN(DESIGN_COLLECTION_CELL_HEIGHT * Design.HEIGHT_RATIO, roundf((Design.DISPLAY_WIDTH - (self.membersCollectionViewLeadingConstraint.constant * 2)) / 6));
    [viewFlowLayout setItemSize:CGSizeMake(heightCell, heightCell)];
    
    [self.membersCollectionView setUserInteractionEnabled:NO];
    [self.membersCollectionView setCollectionViewLayout:viewFlowLayout];
    self.membersCollectionView.dataSource = self;
    self.membersCollectionView.backgroundColor = Design.WHITE_COLOR;
    [self.membersCollectionView registerNib:[UINib nibWithNibName:@"ShowMemberCell" bundle:nil] forCellWithReuseIdentifier:MEMBER_CELL_IDENTIFIER];
    
    self.memberIndicatorView.tintColor = Design.MAIN_COLOR;
    self.memberIndicatorView.hidesWhenStopped = YES;
    
    if (@available(iOS 13.0, *)) {
        self.memberIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleMedium;
    } else {
        self.memberIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    }
    
    [self.memberIndicatorView startAnimating];
    
    self.adminViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    UITapGestureRecognizer *adminViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleAdminTapGesture:)];
    [self.adminView addGestureRecognizer:adminViewGestureRecognizer];
    
    [self.adminView setBorder:Design.SEPARATOR_COLOR_GREY borderWidth:Design.SEPARATOR_HEIGHT width:Design.DISPLAY_WIDTH height:self.adminViewHeightConstraint.constant left:false right:false top:false bottom:true];
    
    self.adminLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.adminLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.adminLabel.text = TwinmeLocalizedString(@"show_room_view_controller_admin_title", nil);
    self.adminLabel.font = Design.FONT_REGULAR34;
    self.adminLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.adminAccessoryViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.adminAccessoryViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.adminAccessoryView.tintColor = Design.ACCESSORY_COLOR;
    self.adminAccessoryView.image = [self.adminAccessoryView.image imageFlippedForRightToLeftLayoutDirection];
    
    self.historyTitleLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.historyTitleLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.historyTitleLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.historyTitleLabel.font = Design.FONT_BOLD26;
    self.historyTitleLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.historyTitleLabel.text = TwinmeLocalizedString(@"show_contact_view_controller_history_title", nil).uppercaseString;
    
    self.lastCallAccessoryViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.lastCallAccessoryViewHeightConstraint.constant = Design.ACCESSORY_HEIGHT;
    self.lastCallAccessoryView.tintColor = Design.ACCESSORY_COLOR;
    self.lastCallAccessoryView.image = [self.lastCallAccessoryView.image imageFlippedForRightToLeftLayoutDirection];
    
    self.lastCallViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.lastCallViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    UITapGestureRecognizer *lastCallViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleLastCallsTapGesture:)];
    [self.lastCallView addGestureRecognizer:lastCallViewGestureRecognizer];
    
    [self.lastCallView setBorder:Design.SEPARATOR_COLOR_GREY borderWidth:Design.SEPARATOR_HEIGHT width:Design.DISPLAY_WIDTH height:self.lastCallViewHeightConstraint.constant left:false right:false top:true bottom:true];
    
    self.lastCallImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.lastCallImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.lastCallLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.lastCallLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.lastCallLabel.text = TwinmeLocalizedString(@"show_contact_view_controller_last_calls", nil);
    self.lastCallLabel.font = Design.FONT_REGULAR34;
    self.lastCallLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.spaceViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    UITapGestureRecognizer *spaceViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSpaceTapGesture:)];
    [self.spaceView addGestureRecognizer:spaceViewGestureRecognizer];
    
    [self.spaceView setBorder:Design.SEPARATOR_COLOR_GREY borderWidth:Design.SEPARATOR_HEIGHT width:Design.DISPLAY_WIDTH height:self.spaceViewHeightConstraint.constant left:false right:false top:true bottom:true];
    
    self.spaceImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.spaceImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.spaceImageView.tintColor = Design.UNSELECTED_TAB_COLOR;
    
    NSString *nameSpace = @"";
    NSString *nameProfile = @"";
    if (self.room.space.settings.name) {
        nameSpace = self.room.space.settings.name;
    }
    if (self.room.space.profile.name) {
        nameProfile = self.room.space.profile.name;
    }
    
    self.spaceLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.spaceLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@""];
    [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:nameSpace attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_REGULAR34, NSFontAttributeName, Design.FONT_COLOR_DEFAULT, NSForegroundColorAttributeName, nil]]];
    [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n"]];
    [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:nameProfile attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_REGULAR32, NSFontAttributeName, Design.FONT_COLOR_PROFILE_GREY, NSForegroundColorAttributeName, nil]]];
    self.spaceLabel.attributedText = attributedString;
    
    self.spaceAvatarLabel.font = Design.FONT_BOLD44;
    self.spaceAvatarLabel.textColor = [UIColor whiteColor];
    self.spaceAvatarLabel.hidden = YES;
    
    self.spaceAvatarViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.spaceAvatarViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.spaceAvatarView.clipsToBounds = YES;
    self.spaceAvatarView.layer.cornerRadius = Design.SPACE_RADIUS_RATIO * self.spaceAvatarViewHeightConstraint.constant;
    
    [self getImageWithService:self.showRoomService space:self.room.space withBlock:^(UIImage *image) {
        self.spaceAvatarView.image = image;
    }];

    self.conversationsTitleLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.conversationsTitleLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.conversationsTitleLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.conversationsTitleLabel.font = Design.FONT_BOLD26;
    self.conversationsTitleLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.conversationsTitleLabel.text = TwinmeLocalizedString(@"conversations_view_controller_title", nil).uppercaseString;
    
    self.filesViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.filesViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    UITapGestureRecognizer *filesViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleFilesTapGesture:)];
    [self.filesView addGestureRecognizer:filesViewGestureRecognizer];
    
    [self.filesView setBorder:Design.SEPARATOR_COLOR_GREY borderWidth:Design.SEPARATOR_HEIGHT width:Design.DISPLAY_WIDTH height:self.filesViewHeightConstraint.constant left:false right:false top:true bottom:true];
    
    self.filesImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.filesImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.filesImageView.tintColor = Design.UNSELECTED_TAB_COLOR;
    
    self.filesLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.filesLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.filesLabel.text = TwinmeLocalizedString(@"conversation_files_view_controller_title", nil);
    self.filesLabel.font = Design.FONT_REGULAR34;
    self.filesLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.filesAccessoryViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.filesAccessoryViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.filesAccessoryView.tintColor = Design.ACCESSORY_COLOR;
    self.filesAccessoryView.image = [self.filesAccessoryView.image imageFlippedForRightToLeftLayoutDirection];
    
    self.exportViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    UITapGestureRecognizer *exportViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleExportTapGesture:)];
    [self.exportView addGestureRecognizer:exportViewGestureRecognizer];
    
    [self.exportView setBorder:Design.SEPARATOR_COLOR_GREY borderWidth:Design.SEPARATOR_HEIGHT width:Design.DISPLAY_WIDTH height:self.exportViewHeightConstraint.constant left:false right:false top:true bottom:true];
    
    self.exportImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.exportImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.exportImageView.tintColor = Design.UNSELECTED_TAB_COLOR;
    
    self.exportLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.exportLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.exportLabel.text = TwinmeLocalizedString(@"show_contact_view_controller_export_contents", nil);
    self.exportLabel.font = Design.FONT_REGULAR34;
    self.exportLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.exportAccessoryViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.exportAccessoryViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.exportAccessoryView.tintColor = Design.ACCESSORY_COLOR;
    self.exportAccessoryView.image = [self.exportAccessoryView.image imageFlippedForRightToLeftLayoutDirection];
    
    self.cleanViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    UITapGestureRecognizer *cleanViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCleanTapGesture:)];
    [self.cleanView addGestureRecognizer:cleanViewGestureRecognizer];
    
    [self.cleanView setBorder:Design.SEPARATOR_COLOR_GREY borderWidth:Design.SEPARATOR_HEIGHT width:Design.DISPLAY_WIDTH height:self.cleanViewHeightConstraint.constant left:false right:false top:true bottom:true];
    
    self.cleanImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.cleanImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.cleanImageView.tintColor = Design.UNSELECTED_TAB_COLOR;
    
    self.cleanLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.cleanLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.cleanLabel.text = TwinmeLocalizedString(@"show_contact_view_controller_cleanup", nil);
    self.cleanLabel.font = Design.FONT_REGULAR34;
    self.cleanLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.cleanAccessoryViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.cleanAccessoryViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.cleanAccessoryView.tintColor = Design.ACCESSORY_COLOR;
    self.cleanAccessoryView.image = [self.cleanAccessoryView.image imageFlippedForRightToLeftLayoutDirection];
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    if (self.showRoomService) {
        [self.showRoomService dispose];
        self.showRoomService = nil;
    }
    
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleChatTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleChatTapGesture: %@", LOG_TAG, sender);
    
    if (self.room && sender.state == UIGestureRecognizerStateEnded) {
        self.navigationController.navigationBarHidden = NO;
        ConversationViewController *conversationViewController = (ConversationViewController *)[[UIStoryboard storyboardWithName:@"iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"ConversationViewController"];
        [conversationViewController initWithContact:self.room];
        [self.navigationController pushViewController:conversationViewController animated:YES];
    }
}

- (void)handleVideoTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleVideoTapGesture: %@", LOG_TAG, sender);
    
    if (self.room && sender.state == UIGestureRecognizerStateEnded && !self.twinmeApplication.inCall && self.room.capabilities.hasVideo) {
        [self startVideoCallWithPermissionCheck:NO];
    } else if (!self.room.capabilities.hasVideo) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication].keyWindow makeToast:TwinmeLocalizedString(@"application_not_authorized_operation",nil)];
        });
    }
}

- (void)startVideoCallWithPermissionCheck:(BOOL)videoBell {
    DDLogVerbose(@"%@ startVideoCallWithPermissionCheck: %d", LOG_TAG, videoBell);
    
    AVAuthorizationStatus cameraAuthorizationStatus = [DeviceAuthorization deviceCameraAuthorizationStatus];
    switch (cameraAuthorizationStatus) {
        case AVAuthorizationStatusNotDetermined: {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    AVAudioSessionRecordPermission audioSessionRecordPermission = [DeviceAuthorization deviceMicrophonePermissionStatus];
                    switch (audioSessionRecordPermission) {
                        case AVAudioSessionRecordPermissionUndetermined: {
                            [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
                                if (granted) {
                                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                                        [self startVideoCallViewController:videoBell];
                                    });
                                }
                            }];
                            break;
                        }
                            
                        case AVAudioSessionRecordPermissionDenied:
                            [DeviceAuthorization showMicrophoneCameraSettingsAlertInController:self];
                            break;
                            
                        case AVAudioSessionRecordPermissionGranted: {
                            dispatch_async(dispatch_get_main_queue(), ^(void) {
                                [self startVideoCallViewController:videoBell];
                            });
                            break;
                        }
                    }
                }
            }];
            break;
        }
            
        case AVAuthorizationStatusRestricted:
        case AVAuthorizationStatusDenied:
            [DeviceAuthorization showMicrophoneCameraSettingsAlertInController:self];
            break;
            
        case AVAuthorizationStatusAuthorized: {
            AVAudioSessionRecordPermission audioSessionRecordPermission = [DeviceAuthorization deviceMicrophonePermissionStatus];
            switch (audioSessionRecordPermission) {
                case AVAudioSessionRecordPermissionUndetermined: {
                    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
                        if (granted) {
                            dispatch_async(dispatch_get_main_queue(), ^(void) {
                                [self startVideoCallViewController:videoBell];
                            });
                        }
                    }];
                    break;
                }
                    
                case AVAudioSessionRecordPermissionDenied:
                    [DeviceAuthorization showMicrophoneCameraSettingsAlertInController:self];
                    break;
                    
                case AVAudioSessionRecordPermissionGranted: {
                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                        [self startVideoCallViewController:videoBell];
                    });
                    break;
                }
            }
            break;
        }
    }
}

- (void)startVideoCallViewController:(BOOL)videoBell {
    DDLogVerbose(@"%@ startVideoCallViewController: %d", LOG_TAG, videoBell);
    
    if (self.room) {
        CallViewController *callViewController = (CallViewController *)[[UIStoryboard storyboardWithName:@"Call" bundle:nil] instantiateViewControllerWithIdentifier:@"CallViewController"];
        [callViewController startCallWithOriginator:self.room videoBell:videoBell isVideoCall:YES isCertifyCall:NO];
        [self.navigationController pushViewController:callViewController animated:YES];
    }
}

- (void)handleAudioTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleAudioTapGesture: %@", LOG_TAG, sender);
    
    if (self.room && sender.state == UIGestureRecognizerStateEnded && !self.twinmeApplication.inCall && self.room.capabilities.hasAudio) {
        AVAudioSessionRecordPermission audioSessionRecordPermission = [DeviceAuthorization deviceMicrophonePermissionStatus];
        switch (audioSessionRecordPermission) {
            case AVAudioSessionRecordPermissionUndetermined: {
                [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
                    if (granted) {
                        dispatch_async(dispatch_get_main_queue(), ^(void) {
                            [self startAudioCallViewController];
                        });
                    }
                }];
                break;
            }
                
            case AVAudioSessionRecordPermissionDenied:
                [DeviceAuthorization showMicrophoneSettingsAlertInController:self];
                break;
                
            case AVAudioSessionRecordPermissionGranted: {
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    [self startAudioCallViewController];
                });
                break;
            }
        }
    } else if (!self.room.capabilities.hasAudio) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication].keyWindow makeToast:TwinmeLocalizedString(@"application_not_authorized_operation",nil)];
        });
    }
}

- (void)startAudioCallViewController {
    DDLogVerbose(@"%@ startAudioCallViewController", LOG_TAG);
    
    if (self.room) {
        CallViewController *callViewController = (CallViewController *)[[UIStoryboard storyboardWithName:@"Call" bundle:nil] instantiateViewControllerWithIdentifier:@"CallViewController"];
        [callViewController startCallWithOriginator:self.room videoBell:NO isVideoCall:NO isCertifyCall:NO];
        [self.navigationController pushViewController:callViewController animated:YES];
    }
}

- (void)handleAdminTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleAdminTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        self.navigationController.navigationBarHidden = NO;
        AdminRoomViewController *adminRoomViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AdminRoomViewController"];
        [adminRoomViewController initWithRoom:self.room];
        [self.navigationController pushViewController:adminRoomViewController animated:YES];
    }
}

- (void)handleConversationTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleConversationTapGesture: %@", LOG_TAG, sender);
    
    if (self.room && sender.state == UIGestureRecognizerStateEnded) {
        self.navigationController.navigationBarHidden = NO;
        ConversationViewController *conversationViewController = (ConversationViewController *)[[UIStoryboard storyboardWithName:@"iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"ConversationViewController"];
        [conversationViewController initWithContact:self.room];
        [self.navigationController pushViewController:conversationViewController animated:YES];
    }
}

- (void)handleMembersTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleMembersTapGesture", LOG_TAG);
    
    RoomMembersViewController *roomMembersViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RoomMembersViewController"];
    [roomMembersViewController initWithRoom:self.room];
    [self.navigationController pushViewController:roomMembersViewController animated:YES];
}

- (void)handleLastCallsTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleLastCallsTapGesture: %@", LOG_TAG, sender);
    
    if (self.room && sender.state == UIGestureRecognizerStateEnded) {
        self.navigationController.navigationBarHidden = NO;
        LastCallsViewController *lastCallsViewController = (LastCallsViewController *)[[UIStoryboard storyboardWithName:@"Contact" bundle:nil] instantiateViewControllerWithIdentifier:@"LastCallsViewController"];
        [lastCallsViewController initWithOriginator:self.room callReceiver:NO];
        [self.navigationController pushViewController:lastCallsViewController animated:YES];
    }
}

- (void)handleSpaceTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleSpaceTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        if (![self.room.space hasPermission:TLSpacePermissionTypeMoveContact]) {
            AlertMessageView *alertMessageView = [[AlertMessageView alloc] init];
            alertMessageView.alertMessageViewDelegate = self;
            [alertMessageView initWithTitle:TwinmeLocalizedString(@"delete_account_view_controller_warning", nil) message:TwinmeLocalizedString(@"spaces_view_controller_permission_not_allowed", nil)];
            [self.tabBarController.view addSubview:alertMessageView];
            [alertMessageView showAlertView];
        } else {
            SpacesViewController *spacesViewController = [[UIStoryboard storyboardWithName:@"Space" bundle:nil] instantiateViewControllerWithIdentifier:@"SpacesViewController"];
            [spacesViewController initWithContact:self.room];
            spacesViewController.pickerMode = YES;
            TwinmeNavigationController *navigationController = [[TwinmeNavigationController alloc] initWithRootViewController:spacesViewController];
            [self.navigationController presentViewController:navigationController animated:YES completion:nil];
            self.startModal = YES;
        }
    }
}
    
- (void)handleFilesTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleFilesTapGesture: %@", LOG_TAG, sender);
    
    if (self.room && sender.state == UIGestureRecognizerStateEnded) {
        self.navigationController.navigationBarHidden = NO;
        ConversationFilesViewController *conversationFilesViewController = (ConversationFilesViewController *)[[UIStoryboard storyboardWithName:@"iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"ConversationFilesViewController"];
        [conversationFilesViewController initWithOriginator:self.room];
        [self.navigationController pushViewController:conversationFilesViewController animated:YES];
    }
}

- (void)handleExportTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleExportTapGesture: %@", LOG_TAG, sender);
    
    if (self.room && sender.state == UIGestureRecognizerStateEnded) {
        self.navigationController.navigationBarHidden = NO;
        ExportViewController *exportViewController = (ExportViewController *)[[UIStoryboard storyboardWithName:@"iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"ExportViewController"];
        [exportViewController initExportWithContact:self.room];
        [self.navigationController pushViewController:exportViewController animated:YES];
    }
}

- (void)handleCleanTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleCleanTapGesture: %@", LOG_TAG, sender);
    
    if (self.room && sender.state == UIGestureRecognizerStateEnded) {
        self.navigationController.navigationBarHidden = NO;
        TypeCleanUpViewController *typeCleanupViewController = (TypeCleanUpViewController *)[[UIStoryboard storyboardWithName:@"iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"TypeCleanUpViewController"];
        [typeCleanupViewController initCleanUpWithContact:self.room];
        [self.navigationController pushViewController:typeCleanupViewController animated:YES];
    }
}

- (void)updateRoom {
    DDLogVerbose(@"%@ updateRoom", LOG_TAG);
    
    self.avatarView.image = self.roomAvatar;
    self.nameLabel.text =  self.roomName;
    self.identityLabel.text = self.identityName;
    [self.showRoomService getIdentityImageWithContact:self.room withBlock:^(UIImage *image) {
        self.identityAvatarView.image = image;
    }];
    
    if (self.room.space.avatarId) {
        [self.showRoomService getImageWithSpace:self.room.space withBlock:^(UIImage *image) {
            self.spaceAvatarView.image = image;
            self.spaceAvatarLabel.hidden = YES;
        }];
    } else {
        self.spaceAvatarView.image = nil;
        self.spaceAvatarLabel.hidden = NO;
        if (self.room.space.settings.style) {
            self.spaceAvatarView.backgroundColor = [UIColor colorWithHexString:self.room.space.settings.style alpha:1.0];
        } else {
            self.spaceAvatarView.backgroundColor = Design.MAIN_COLOR;
        }
        self.spaceAvatarLabel.text = [NSString firstCharacter:self.room.space.settings.name];
    }
    
    NSString *nameSpace = @"";
    NSString *nameProfile = @"";
    if (self.room.space.settings.name) {
        nameSpace = self.room.space.settings.name;
    }
    if (self.room.space.profile.name) {
        nameProfile = self.room.space.profile.name;
    }
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@""];
    [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:nameSpace attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_MEDIUM34, NSFontAttributeName, Design.FONT_COLOR_DEFAULT, NSForegroundColorAttributeName, nil]]];
    [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n"]];
    [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:nameProfile attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_MEDIUM32, NSFontAttributeName, Design.FONT_COLOR_PROFILE_GREY, NSForegroundColorAttributeName, nil]]];
    self.spaceLabel.attributedText = attributedString;
    
    if ([self.room.capabilities hasAdmin]) {
        self.adminView.hidden = NO;
        self.adminViewHeightConstraint.constant = DESIGN_COLLECTION_CELL_HEIGHT * Design.HEIGHT_RATIO;
    } else {
        self.adminView.hidden = YES;
        self.adminViewHeightConstraint.constant = 0;
    }
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    [super updateColor];
    
    self.membersLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.membersView.backgroundColor = Design.WHITE_COLOR;
    self.memberIndicatorView.tintColor = Design.MAIN_COLOR;
    [self.membersCollectionView reloadData];
    self.historyTitleLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.conversationsTitleLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.lastCallLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.adminLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.filesLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.exportLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.cleanLabel.textColor = Design.FONT_COLOR_DEFAULT;
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.membersLabel.font = Design.FONT_BOLD26;
    self.historyTitleLabel.font = Design.FONT_BOLD26;
    self.conversationsTitleLabel.font = Design.FONT_BOLD26;
    self.lastCallLabel.font = Design.FONT_REGULAR34;
    self.adminLabel.font = Design.FONT_REGULAR34;
    self.filesLabel.font = Design.FONT_REGULAR34;
    self.exportLabel.font = Design.FONT_REGULAR34;
    self.cleanLabel.font = Design.FONT_REGULAR34;
    self.spaceAvatarLabel.font = Design.FONT_BOLD44;
    
    NSString *nameSpace = @"";
    NSString *nameProfile = @"";
    if (self.room.space.settings.name) {
        nameSpace = self.room.space.settings.name;
    }
    if (self.room.space.profile.name) {
        nameProfile = self.room.space.profile.name;
    }
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@""];
    [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:nameSpace attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_MEDIUM34, NSFontAttributeName, Design.FONT_COLOR_DEFAULT, NSForegroundColorAttributeName, nil]]];
    [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n"]];
    [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:nameProfile attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_MEDIUM32, NSFontAttributeName, Design.FONT_COLOR_PROFILE_GREY, NSForegroundColorAttributeName, nil]]];
    self.spaceLabel.attributedText = attributedString;
}

- (void)checkSpacePermission {
    DDLogVerbose(@"%@ checkSpacePermission", LOG_TAG);
    
    if (![self.room.space hasPermission:TLSpacePermissionTypeMoveContact]) {
        self.spaceLabel.alpha = .5f;
    } else {
        self.spaceLabel.alpha = 1.f;
    }
    
    if (![self.room.space hasPermission:TLSpacePermissionTypeUpdateIdentity]) {
        self.identityView.alpha = .5f;
    } else {
        self.identityView.alpha = 1.f;
    }
}

- (void)updateInCall {
    DDLogVerbose(@"%@ updateInCall", LOG_TAG);
    
    BOOL inCall = self.twinmeApplication.inCall;
    if (!self.room.capabilities.hasAudio || inCall) {
        self.audioView.alpha = 0.5f;
    } else {
        self.audioView.alpha = 1.0f;
    }
    
    if (!self.room.capabilities.hasVideo || inCall) {
        self.videoView.alpha = 0.5f;
    } else {
        self.videoView.alpha = 1.0f;
    }
}

@end

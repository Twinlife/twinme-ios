/*
 *  Copyright (c) 2015-2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Chedi Baccari (Chedi.Baccari@twinlife-systems.com)
 *   Christian Jacquemot (Christian.Jacquemot@twinlife-systems.com)
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 *   Stephane Carrez (Stephane.Carrez@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Photos/Photos.h>
#import <PhotosUI/PhotosUI.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <MobileCoreServices/UTType.h>

#import <Twinlife/TLConversationService.h>
#import <Twinlife/TLConnectivityService.h>
#import <Twinlife/TLImageService.h>
#import <Twinlife/TLTwincodeOutboundService.h>

#import <Twinme/TLTwinmeAttributes.h>
#import <Twinme/TLTwinmeContext.h>
#import <Twinme/TLContact.h>
#import <Twinme/TLGroup.h>
#import <Twinme/TLGroupMember.h>
#import <Twinme/TLMessage.h>
#import <Twinme/TLSpace.h>
#import <Twinme/TLTyping.h>

#import <Utils/NSString+Utils.h>

#import "ConversationViewController.h"

#import "AcceptGroupInvitationViewController.h"
#import "AcceptInvitationSubscriptionViewController.h"
#import "InAppSubscriptionViewController.h"
#import "CoachMarkViewController.h"

#import "Constants.h"
#import "ApplicationAssertion.h"

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
#import "NameItem.h"
#import "CallItem.h"
#import "PeerCallItem.h"
#import "InvitationContactItem.h"
#import "PeerInvitationContactItem.h"
#import "LocationItem.h"
#import "PeerLocationItem.h"
#import "InfoPrivacyItem.h"
#import "ClearItem.h"
#import "PeerClearItem.h"

#import "TimeItemCell.h"
#import "InfoPrivacyCell.h"
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
#import "CallItemCell.h"
#import "PeerCallItemCell.h"
#import "InvitationContactItemCell.h"
#import "PeerInvitationContactItemCell.h"
#import "LocationItemCell.h"
#import "PeerLocationItemCell.h"
#import "ClearItemCell.h"
#import "PeerClearItemCell.h"
#import "SendButtonView.h"
#import "MenuConversationButtonView.h"
#import "AlertMessageView.h"
#import "TypingView.h"
#import "MenuItemView.h"
#import "MenuSendOptionsView.h"
#import "MenuReactionView.h"
#import "SwitchView.h"
#import "MenuSelectValueView.h"
#import "DecoratedLabel.h"
#import "ReplyView.h"
#import "MenuActionConversationView.h"
#import "VoiceMessageRecorderView.h"
#import "ItemSelectedActionView.h"
#import "AnnotationsView.h"
#import "PremiumFeatureConfirmView.h"
#import "BottomConversationView.h"
#import "ResetConversationConfirmView.h"
#import "MenuManageConversationView.h"

#import "FullScreenMediaViewController.h"
#import "FilePreviewViewController.h"
#import "ShowContactViewController.h"
#import "ShowGroupViewController.h"
#import "ShowRoomViewController.h"
#import "ShareViewController.h"
#import "InfoItemViewController.h"
#import "ConversationFilesViewController.h"
#import "ExportViewController.h"
#import "TypeCleanUpViewController.h"

#import "AcceptInvitationViewController.h"
#import "LocationViewController.h"
#import "PreviewLocationViewController.h"
#import "PreviewFilesViewController.h"

#import "UIAnnotation.h"
#import "UIActionConversation.h"
#import "UIContact.h"
#import "UIReaction.h"
#import "UIView+Toast.h"
#import "UIImage+Animated.h"
#import "DeviceAuthorization.h"
#import "UITimeout.h"
#import "CustomAppearance.h"
#import "SpaceSetting.h"
#import "UIColor+Hex.h"
#import <TwinmeCommon/CoachMark.h>
#import "UIPremiumFeature.h"
#import "DeleteConfirmView.h"
#import "CallAgainConfirmView.h"
#import "TextViewRightView.h"
#import "UIPreviewMedia.h"
#import "EditMessageView.h"
#import "DefaultConfirmView.h"

#import <TwinmeCommon/AbstractTwinmeService+Protected.h>
#import <TwinmeCommon/ApplicationDelegate.h>
#import <TwinmeCommon/AsyncManager.h>
#import <TwinmeCommon/AudioPlayerManager.h>
#import <TwinmeCommon/CallViewController.h>
#import <TwinmeCommon/CoachMark.h>
#import <TwinmeCommon/ConversationService.h>
#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/GroupInvitationService.h>
#import <TwinmeCommon/GroupService.h>
#import <TwinmeCommon/TwinmeApplication.h>
#import <TwinmeCommon/TwinmeNavigationController.h>
#import <TwinmeCommon/Utils.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

#define DELAY_COACH_MARK 0.5

static NSString *INFO_PRIVACY_ITEM_CELL_IDENTIFIER = @"InfoPrivacyCellIdentifier";
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
static NSString *TYPING_ITEM_VIEW_IDENTIFIER = @"TypingViewIdentifier";
static NSString *CALL_ITEM_CELL_IDENTIFIER = @"CallItemCellIdentifier";
static NSString *PEER_CALL_ITEM_CELL_IDENTIFIER = @"PeerCallItemCellIdentifier";
static NSString *INVITATION_CONTACT_ITEM_CELL_IDENTIFIER = @"InvitationContactItemCellIdentifier";
static NSString *PEER_INVITATION_CONTACT_ITEM_CELL_IDENTIFIER = @"PeerInvitationContactItemCellIdentifier";
static NSString *LOCATION_ITEM_CELL_IDENTIFIER = @"LocationItemCellIdentifier";
static NSString *PEER_LOCATION_ITEM_CELL_IDENTIFIER = @"PeerLocationItemCellIdentifier";
static NSString *CLEAR_ITEM_CELL_IDENTIFIER = @"ClearItemCellIdentifier";
static NSString *PEER_CLEAR_ITEM_CELL_IDENTIFIER = @"PeerClearItemCellIdentifier";

static UIColor *DESIGN_HEADER_COLOR;
static UIColor *DESIGN_FOOTER_COLOR;
static UIColor *DESIGN_SHADOW_COLOR;
static UIColor *DESIGN_BORDER_COLOR;

static const CGFloat DESIGN_SMALL_ROUND_CORNER_RADIUS = 8;
static const CGFloat DESIGN_LARGE_ROUND_CORNER_RADIUS = 38;
static const CGFloat DESIGN_TOP_MARGIN1 = 4;
static const CGFloat DESIGN_TOP_MARGIN2 = 18;
static const CGFloat DESIGN_BOTTOM_MARGIN1 = 4;
static const CGFloat DESIGN_BOTTOM_MARGIN2 = 18;
static const CGFloat DESIGN_BOTTOM_MARGIN3 = 50;
static const CGFloat DESIGN_WIDTH_INSET = 32;
static const CGFloat DESIGN_HEIGHT_INSET = 24;
// static const CGFloat DESIGN_LEFT_INSET = 8;
static const CGFloat DESIGN_SCROLL_INDICATOR_WIDTH = 146;
static const CGFloat DESIGN_SCROLL_INDICATOR_BOTTOM = 46;

static const CGFloat DESIGN_MIN_FONT = 10.0;
static const CGFloat DESIGN_MAX_FONT = 80.0;

static const int64_t DESIGN_MAX_DELTA_TIMESTAMP1 = 2 * 60 * 1000; // Between message groups
static const int64_t DESIGN_MAX_DELTA_TIMESTAMP2 = 60 * 60 * 1000; // Time indicator

static const CGFloat DESIGN_TYPING_VIEW_HEIGHT = 70;
static const CGFloat DESIGN_REPLY_VIEW_HEIGHT = 120;

// Make sure that TYPING_RESEND_DELAY < TYPING_TIME_DURATION < TYPING_PEER_TIMER_DURATION
static const int64_t TYPING_RESEND_DELAY = 8;
static const CGFloat TYPING_TIMER_DURATION = 10.0;
static const CGFloat TYPING_PEER_TIMER_DURATION = 12.0;

static CGFloat DESIGN_PROFILE_VIEW_WIDTH = 360;
static CGFloat DESIGN_GROUP_VIEW_WIDTH = 580;
static CGFloat DESIGN_PROFILE_MARGIN = 10;
static CGFloat DESIGN_AVATAR_VIEW_HEIGHT = 42;
static CGFloat DESIGN_EDIT_MESSAGE_VIEW_HEIGHT = 60;
static CGFloat DESIGN_EDIT_MESSAGE_VIEW_WIDTH = 300;

static CGFloat PROFILE_VIEW_WIDTH;
static CGFloat GROUP_VIEW_WIDTH;
static CGFloat PROFILE_MARGIN;
static CGFloat AVATAR_VIEW_HEIGHT;

//
// Interface: ConversationViewController ()
//

typedef enum {
    ModeDefault,
    ModeText,
    ModeAudioRecorder
} Mode;

@interface ConversationViewController () <ConversationServiceDelegate, UITextViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, AlertMessageViewDelegate, AVAudioRecorderDelegate, AudioActionDelegate, ImageActionDelegate, VideoActionDelegate, FileActionDelegate, DeleteActionDelegate, MenuActionDelegate, GroupActionDelegate, LocationActionDelegate, CallActionDelegate, TwincodeActionDelegate, LinkActionDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIDocumentPickerDelegate, UIDocumentInteractionControllerDelegate, GroupInvitationServiceDelegate, GroupServiceDelegate, SwitchViewDelegate, ReplyViewDelegate, SelectItemDelegate, MenuItemDelegate, ReplyItemDelegate, AsyncLoaderDelegate, PreviewViewDelegate, MenuSendOptionsDelegate, CoachMarkDelegate, MenuReactionDelegate, ItemSelectedActionViewDelegate, ReactionViewDelegate, AnnotationsViewDelegate, ConfirmViewDelegate, AcceptInvitationSubscriptionDelegate, MenuActionConversationDelegate, MenuManageConversationViewDelegate, UITableViewDataSourcePrefetching, PHPickerViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *safeAreaView;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *emptyConversationLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *emptyConversationLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *emptyConversationLabel;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundConversationImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollIndicatorViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollIndicatorViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollIndicatorViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *scrollIndicatorView;
@property (weak, nonatomic) IBOutlet UIView *scrollIndicatorOverlayView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollIndicatorImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollIndicatorImageViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *scrollIndicatorImageView;
@property (weak, nonatomic) IBOutlet UILabel *scrollIndicatorCountLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *itemSelectedActionViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *itemSelectedActionContainerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *zoomLevelViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *zoomLevelViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *zoomLevelView;
@property (weak, nonatomic) IBOutlet UILabel *zoomLevelLabel;

@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UILabel *subTitleLabel;
@property (nonatomic) UIImageView *avatarView;
@property (nonatomic) UIView *navigationBarOverlayView;
@property (nonatomic) UIView *headerOverlayView;
@property (nonatomic) UIView *footerOverlayView;
@property (nonatomic) UIView *overlayView;
@property (nonatomic) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic) UIBarButtonItem *audioCallBarButtonItem;
@property (nonatomic) UIBarButtonItem *videoCallBarButtonItem;
@property (nonatomic) UIBarButtonItem *cancelBarButtonItem;
@property (nonatomic) TextViewRightView *textViewRightView;

@property (nonatomic) MenuActionConversationView *menuActionConversationView;
@property (nonatomic) SendButtonView *sendButtonView;
@property (nonatomic) MenuConversationButtonView *menuButtonView;
@property (nonatomic) VoiceMessageRecorderView *voiceMessageRecorderView;
@property (nonatomic) TypingView *typingView;
@property (nonatomic) MenuItemView *menuItemView;
@property (nonatomic) MenuReactionView *menuReactionView;
@property (nonatomic) ReplyView *replyView;
@property (nonatomic) ItemSelectedActionView *itemSelectedActionView;
@property (nonatomic) EditMessageView * editMessageView;

@property (nonatomic) id<TLOriginator> contact;
@property (nonatomic) TLGroup *group;
@property (nonatomic) id<TLGroupConversation> groupConversation;
@property (nonatomic) NSMutableDictionary *groupMembers;
@property (nonatomic) NSString *contactName;
@property (nonatomic) UIImage *contactAvatar;
@property (nonatomic) UIImage *identityAvatar;
@property (nonatomic) NSMutableArray *items;
@property (nonatomic) InfoPrivacyItem *infoPrivacyItem;
@property (nonatomic) NSMutableArray<Item *> *selectedItems;
@property (nonatomic) NSUUID *conversationId;
@property (nonatomic) CustomAppearance *customAppearance;
@property (nonatomic) TLDescriptorId *descriptorId;

@property (nonatomic) Mode selectedMode;
@property (nonatomic) BOOL viewAppearing;
@property (nonatomic) BOOL needsRefresh;
@property (nonatomic) CGFloat keyboardHeight;
@property (nonatomic) CGFloat smallRadius;
@property (nonatomic) CGFloat largeRadius;
@property (nonatomic) CGFloat topMargin1;
@property (nonatomic) CGFloat topMargin2;
@property (nonatomic) CGFloat bottomMargin1;
@property (nonatomic) CGFloat bottomMargin2;
@property (nonatomic) CGFloat bottomMargin3;
@property (nonatomic) BOOL batchUpdate;
@property (nonatomic) Item *lastReadPeerItem;
@property (nonatomic) BOOL featureNotSupportedByPeerMessage;
@property (nonatomic) NSMutableOrderedSet<NSIndexPath *> *selectedMedias;
@property (nonatomic) NSMutableArray *filesPreview;
@property (nonatomic) NSMutableSet<NSIndexPath *> *selectedFiles;
@property (nonatomic) BOOL isTyping;
@property (nonatomic) BOOL isPeerTyping;
@property (nonatomic) NSMutableArray<id<TLOriginator>> *typingOriginators;
@property (nonatomic) NSMutableArray<UIImage *> *typingOriginatorImages;
@property (nonatomic) NSTimer *typingTimer;
@property (nonatomic) NSTimer *peerTypingTimer;
@property (nonatomic) int64_t typingSendTime;

@property (nonatomic) Item *editItem;
@property (nonatomic) Item *selectedItem;
@property (nonatomic) Item *replyItem;
@property (nonatomic) BOOL menuOpen;

@property (nonatomic) BOOL menuSendOptionsOpen;
@property (nonatomic) BOOL allowCopy;
@property (nonatomic) BOOL allowEphemeralMessage;
@property (nonatomic) int64_t expireTimeout;

@property id<NSObject> timeObserverToken;

@property TLCallDescriptor *callAgainDescriptor;

@property (nonatomic) TwinmeApplication *twinmeApplication;
@property (nonatomic) TLTwinmeContext *twinmeContext;
@property (nonatomic) ConversationService *conversationService;
@property (nonatomic) GroupInvitationService *groupInvitationService;
@property (nonatomic) GroupService *groupService;
@property (nonatomic) AsyncManager *asyncLoaderManager;

@property (nonatomic) BOOL openGroupFromInvitation;

@property (nonatomic) UIFont *messageFont;
@property (nonatomic) float scaleFont;
@property (nonatomic) float minScaleFont;
@property (nonatomic) float maxScaleFont;
@property (nonatomic) float minSizeFont;
@property (nonatomic) float maxSizeFont;

@property (nonatomic) BOOL isPastedString;

@property (nonatomic) int scrollIndicatorCount;

@property (nonatomic) BOOL selectItemMode;

@property (nonatomic) BOOL loadingDescriptors;
@property (nonatomic) BOOL allDescriptorsLoaded;
@property (nonatomic) long maxPrefetchIndex;
@property (nonatomic) long nbDescriptorsLoaded;

@property (nonatomic, readonly) TLDescriptorFilter descriptorFilter;

@property (nonatomic) int countMediaPicking;
@property (nonatomic) BOOL endMediaPicking;
@property (nonatomic) NSMutableArray *previewMediaPicking;
@property (nonatomic) BOOL errorMediaPicking;

@property (nonatomic) BOOL editingMessage;
@property (nonatomic) CGFloat textInputBarHeight;

@end

//
// Implementation: ConversationViewController
//

#undef LOG_TAG
#define LOG_TAG @"ConversationViewController"

@implementation ConversationViewController

+ (void)initialize {
    DDLogVerbose(@"%@ initialize", LOG_TAG);
    
    DESIGN_HEADER_COLOR = [UIColor colorWithWhite:1 alpha:200./255.];
    DESIGN_SHADOW_COLOR = [UIColor colorWithRed:210./255. green:210./255. blue:210./255. alpha:1];
    DESIGN_BORDER_COLOR = [UIColor colorWithRed:78./255. green:78./255. blue:78./255. alpha:1];
    
    PROFILE_VIEW_WIDTH = DESIGN_PROFILE_VIEW_WIDTH * Design.WIDTH_RATIO;
    GROUP_VIEW_WIDTH = DESIGN_GROUP_VIEW_WIDTH * Design.WIDTH_RATIO;
    PROFILE_MARGIN = DESIGN_PROFILE_MARGIN * Design.WIDTH_RATIO;
    AVATAR_VIEW_HEIGHT = DESIGN_AVATAR_VIEW_HEIGHT * Design.HEIGHT_RATIO;
}

#pragma mark - UIViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
        _twinmeApplication = [delegate twinmeApplication];
        _twinmeContext = [delegate twinmeContext];
        _conversationService = [[ConversationService alloc] initWithTwinmeContext:_twinmeContext delegate:self];
        _groupInvitationService = [[GroupInvitationService alloc] initWithTwinmeContext:_twinmeContext delegate:self];
        _groupService = [[GroupService alloc] initWithTwinmeContext:_twinmeContext delegate:self];
        _openGroupFromInvitation = NO;
        _errorMediaPicking = NO;
        _menuOpen = NO;
        _selectItemMode = NO;
        _menuSendOptionsOpen = NO;
        _editingMessage = NO;
        _messageFont = Design.FONT_REGULAR32;
        _scaleFont = 1.0;
        _allowEphemeralMessage = NO;
        _expireTimeout = 0;
        _scrollIndicatorCount = 0;
        _endMediaPicking = NO;
        _countMediaPicking = 0;
        _textInputBarHeight = 0;
        _previewMediaPicking = [[NSMutableArray alloc]init];
        
        _items = [[NSMutableArray alloc] init];
        _selectedItems = [[NSMutableArray alloc]init];
        _featureNotSupportedByPeerMessage = YES;
        
        _selectedMedias = [[NSMutableOrderedSet<NSIndexPath *> alloc] init];
        _infoPrivacyItem = [[InfoPrivacyItem alloc] init];
        
        _selectedFiles = [[NSMutableSet<NSIndexPath *> alloc] init];
        _filesPreview = [[NSMutableArray alloc] init];
        
        _needsRefresh = NO;
        _batchUpdate = NO;
        _isTyping = NO;
        _isPeerTyping = NO;
        _typingOriginators = [[NSMutableArray alloc] init];
        _typingOriginatorImages = [[NSMutableArray alloc] init];
        
        _asyncLoaderManager = [[AsyncManager alloc] initWithTwinmeContext:_twinmeContext delegate:self];
        _selectedMode = ModeDefault;
        
        _loadingDescriptors = NO;
        _allDescriptorsLoaded = NO;
        _maxPrefetchIndex = 0;
        _nbDescriptorsLoaded = 0;
        
        _descriptorFilter = ^BOOL(TLDescriptor *descriptor) {
            switch (descriptor.getType) {
                case TLDescriptorTypeAudioDescriptor:
                    return ((TLAudioDescriptor *)descriptor).isAvailable;
                case TLDescriptorTypeNamedFileDescriptor:
                    return ((TLNamedFileDescriptor *)descriptor).isAvailable;
                default:
                    return YES;
            }
        };
        
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [self registerClassForToolbarView:[BottomConversationView class]];
    [self registerClassForSendButtonView:[SendButtonView class]];
    [self registerClassForRecordButtonView:[MenuConversationButtonView class]];
    
    [super viewDidLoad];
    
    [self initViews];
}

- (void)viewWillAppear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillAppear: %@", LOG_TAG, animated ? @"YES" : @"NO");
    
    if (self.contact) {
        self.loadingDescriptors = YES;
        [self.conversationService initWithContact:self.contact callsMode:[self.twinmeApplication displayCallsMode] descriptorFilter:self.descriptorFilter maxDescriptors:(int)self.nbDescriptorsLoaded];
        self.nbDescriptorsLoaded = 0;
    } else {
        TL_ASSERT_NOT_NULL(self.twinmeContext, self.contact, [ApplicationAssertPoint INVALID_SUBJECT], nil);
    }
    
    // Mark the view as being in the "Appearing" state so that we mark as-read new messages.
    self.viewAppearing = YES;
    [super viewWillAppear:animated];
    
    [self.view bringSubviewToFront:self.headerView];
    [self.view bringSubviewToFront:self.safeAreaView];
    [self.view bringSubviewToFront:self.headerOverlayView];
    [self.view bringSubviewToFront:self.footerOverlayView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidChangeLanguage:) name:UITextInputCurrentInputModeDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectLinkWithInvitationURL:) name:SelectInvitationLink object:nil];
    
    [self setupTitleView];
    [self setupTextRightView];
    
    [self updateSendButton:YES];
    
    [self updateFont];
    [self updateColor];
    [self updateInCall];
    
    [self showCoachMark];
    
    if ([self.conversationService isGetDescriptorDone]) {
        [self reloadInfoPrivacy];
    }
    
    if (self.group) {
        [self.groupService getGroupWithGroupId:self.group.uuid];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    DDLogVerbose(@"%@ viewDidAppear: %@", LOG_TAG, animated ? @"YES" : @"NO");
    
    [super viewDidAppear:animated];
    
    [self.conversationService setActiveConversation];
    
    // Mark the view as being in the "Appearing" state so that we mark as-read new messages.
    self.viewAppearing = YES;
    self.keyboardHeight = [self.twinmeApplication getDefaultKeyboardHeight];
    if (self.keyboardHeight == 0) {
        // TBD to be improved
        self.keyboardHeight = DESIGN_IMAGE_VIEW_HEIGHT * Design.HEIGHT_RATIO;
    }
    
    [self setupOverlayView];
        
    if (self.needsRefresh) {
        [self reloadData];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillDisappear: %@", LOG_TAG, animated ? @"YES" : @"NO");
    
    // The view has left the "Appearing" state and we don't want to mark as-read new messages.
    self.viewAppearing = NO;
    self.needsRefresh = YES;
    [super viewWillDisappear:animated];
    
    [self.asyncLoaderManager clear];
    self.batchUpdate = YES;
    
    [self closeMenu];
    
    if (self.selectedMode == ModeAudioRecorder) {
        [self.voiceMessageRecorderView pauseRecording];
    } else {
        [self setSelectedMode:ModeDefault];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextInputCurrentInputModeDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SelectInvitationLink object:nil];
    
    if ([UIDevice currentDevice].proximityMonitoringEnabled) {
        [UIDevice currentDevice].proximityMonitoringEnabled = NO;
    }
    
    [AudioPlayerManager stopPlaying];
    
    if (self.isTyping) {
        self.isTyping = NO;
        TLTyping *typing = [[TLTyping alloc]initWithAction:TLTypingActionStop];
        [self.conversationService pushTyping:typing];
    }
    
    if (self.typingTimer) {
        [self.typingTimer invalidate];
        self.typingTimer = nil;
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    DDLogVerbose(@"%@ viewDidDisappear: %@", LOG_TAG, animated ? @"YES" : @"NO");
    
    // The view has left the "Appearing" state and we don't want to mark as-read new messages.
    self.viewAppearing = NO;
    [self.asyncLoaderManager clear];
    [super viewDidDisappear:animated];
    
    [self.conversationService resetActiveConversation];
    
    if (self.isMovingFromParentViewController) {
        [self finish];
    }
}

- (void)willMoveToParentViewController:(UIViewController *)parent {
    
    [super willMoveToParentViewController:parent];
    
    if (!parent) {
        [self removeSubViews];
    }
}

- (void)viewDidLayoutSubviews {
    DDLogVerbose(@"%@ viewDidLayoutSubviews", LOG_TAG);
    
    [super viewDidLayoutSubviews];
    
    if (!self.itemSelectedActionView) {
        [self setupSelectedView];
    }
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    DDLogVerbose(@"%@ traitCollectionDidChange: %@", LOG_TAG, previousTraitCollection);
    
    TLSpaceSettings *spaceSettings = self.space.settings;
    if ([self.space.settings getBooleanWithName:PROPERTY_DEFAULT_APPEARANCE_SETTINGS defaultValue:YES]) {
        spaceSettings = self.twinmeContext.defaultSpaceSettings;
    }
    
    if (self.space && [[spaceSettings getStringWithName:PROPERTY_DISPLAY_MODE defaultValue:[NSString stringWithFormat:@"%d", DisplayModeSystem]]intValue] == DisplayModeSystem) {
        [Design setupColors:DisplayModeSystem];
    }
    [self reloadData];
    [self updateColor];
}

#pragma mark - Setters/Getters

- (void)setSelectedMode:(Mode)mode {
    DDLogVerbose(@"%@ setSelectedMode: %u", LOG_TAG, mode);
    
    BOOL hideAudioRecorder = NO;
    
    if (self.selectedMode == ModeAudioRecorder) {
        mode = ModeDefault;
    }
    
    _selectedMode = mode;
    
    BOOL hideKeyboard = NO;
    if (self.selectedMode == ModeDefault || self.selectedMode == ModeAudioRecorder) {
        hideKeyboard = YES;
    }
    
    if (self.textInputbar.toolbarView && [self.textInputbar.toolbarView isKindOfClass:[BottomConversationView class]]) {
        BottomConversationView *bottomConversationView = (BottomConversationView *)self.textInputbar.toolbarView;
        [bottomConversationView updateToolbarHeight:hideKeyboard];
    }
    
    switch (_selectedMode) {
        case ModeDefault: {
            if (hideAudioRecorder || self.voiceMessageRecorderView) {
                [self.voiceMessageRecorderView removeFromSuperview];
            }
            
            if ([self.textView isFirstResponder]) {
                [self.textView resignFirstResponder];
            }
            
            break;
        }
            
        case ModeText:
            if (hideAudioRecorder) {
                [self.voiceMessageRecorderView removeFromSuperview];
            }
            break;
            
        case ModeAudioRecorder: {
            [self setupRecordSoundView];
            [self.view addSubview:self.voiceMessageRecorderView];
            break;
        }
    }
}

#pragma mark - Public methods

- (void)initWithContact:(id<TLOriginator>)contact {
    DDLogVerbose(@"%@ initWithContact: %@", LOG_TAG, contact);
    
    self.contact = contact;
    self.space = contact.space;
    self.contactName = self.contact.name;
    if ([(NSObject*) contact class] == [TLGroupMember class]) {
        TLGroupMember *groupMember = (TLGroupMember *)contact;
        if ([groupMember.group isKindOfClass:[TLGroup class]]) {
            self.group = (TLGroup *)groupMember.group;
            [self.conversationService getImageWithGroup:self.group withBlock:^(UIImage *image) {
                self.contactAvatar = image;
                [self updateNavigationBarAvatar];
            }];
            [self.conversationService getIdentityImageWithGroup:self.group withBlock:^(UIImage *image) {
                self.identityAvatar = image;
            }];
            self.space = self.group.space;
        } else {
            self.contact = groupMember.group;
            self.contactName = self.contact.name;
            [self.conversationService getImageWithContact:(TLContact *)self.contact withBlock:^(UIImage *image) {
                self.contactAvatar = image;
                [self updateNavigationBarAvatar];
            }];
            [self.conversationService getIdentityImageWithContact:(TLContact *)self.contact withBlock:^(UIImage *image) {
                self.identityAvatar = image;
            }];
            self.space = self.contact.space;
        }
    } else if ([contact isGroup]) {
        self.group = (TLGroup *)contact;
        self.space = self.group.space;
        [self.conversationService getImageWithGroup:self.group withBlock:^(UIImage *image) {
            self.contactAvatar = image;
            [self updateNavigationBarAvatar];
        }];
        [self.conversationService getIdentityImageWithGroup:self.group withBlock:^(UIImage *image) {
            self.identityAvatar = image;
        }];
    } else {
        [self.conversationService getImageWithContact:(TLContact *)contact withBlock:^(UIImage *image) {
            self.contactAvatar = image;
            [self updateNavigationBarAvatar];
        }];
        [self.conversationService getIdentityImageWithContact:(TLContact *)contact withBlock:^(UIImage *image) {
            self.identityAvatar = image;
        }];
    }
    
    if ([self.space.settings getBooleanWithName:PROPERTY_DEFAULT_APPEARANCE_SETTINGS defaultValue:YES]) {
        self.customAppearance = [[CustomAppearance alloc]initWithSpaceSettings:self.twinmeContext.defaultSpaceSettings];
    } else {
        self.customAppearance = [[CustomAppearance alloc]initWithSpaceSettings:self.space.settings];
    }

    if ([self.space.settings getBooleanWithName:PROPERTY_DEFAULT_MESSAGE_SETTINGS defaultValue:YES]) {
        self.allowEphemeralMessage = [self.twinmeContext.defaultSpaceSettings getBooleanWithName:PROPERTY_ALLOW_EPHEMERAL_MESSAGE defaultValue:NO];
        self.expireTimeout = [[self.twinmeContext.defaultSpaceSettings getStringWithName:PROPERTY_TIMEOUT_EPHEMERAL_MESSAGE defaultValue:[NSString stringWithFormat:@"%d", DEFAULT_TIMEOUT_MESSAGE]]integerValue];
    } else {
        self.allowEphemeralMessage = [self.space.settings getBooleanWithName:PROPERTY_ALLOW_EPHEMERAL_MESSAGE defaultValue:NO];
        self.expireTimeout = [[self.space.settings getStringWithName:PROPERTY_TIMEOUT_EPHEMERAL_MESSAGE defaultValue:[NSString stringWithFormat:@"%d", DEFAULT_TIMEOUT_MESSAGE]]integerValue];
    }
}

- (void)scrollToDescriptor:(TLDescriptorId *)descriptorId {
    DDLogVerbose(@"%@ scrollToDescriptor: %@", LOG_TAG, descriptorId);
    
    self.descriptorId = descriptorId;
}

- (CGFloat)getTopMarginWithMask:(int)mask item:(Item *)item {
    DDLogVerbose(@"%@ getTopMarginWithMask: %d item:%@", LOG_TAG, mask, item);
    
    if (self.group && item.isPeerItem && mask) {
        return self.topMargin1;
    }
    return mask ? self.topMargin2 : self.topMargin1;
}

- (CGFloat)getBottomMarginWithMask:(int)mask item:(Item *)item {
    DDLogVerbose(@"%@ getBottomMarginWithMask: %d item:%@", LOG_TAG, mask, item);
    
    if (item.forwarded || [item isEditedtem] || item.likeDescriptorAnnotations.count > 0) {
        return self.bottomMargin3;
    } else if (mask) {
        return self.bottomMargin2;
    } else {
        return self.bottomMargin1;
    }
}

- (CGFloat)getRadiusWithMask:(int)mask {
    DDLogVerbose(@"%@ getRadiusWithMask: %d", LOG_TAG, mask);
    
    return mask ? self.largeRadius : self.smallRadius;
}

- (BOOL)isViewAppearing {
    DDLogVerbose(@"%@ isViewAppearing", LOG_TAG);
    
    return self.viewAppearing;
}


- (Item *)getSelectedItem  {
    DDLogVerbose(@"%@ getSelectedItem", LOG_TAG);
    
    return self.selectedItem;
}

- (BOOL)isMenuOpen {
    DDLogVerbose(@"%@ isMenuOpen", LOG_TAG);
    
    return self.menuOpen;
}

- (BOOL)isSelectItemMode {
    DDLogVerbose(@"%@ isSelectItemMode", LOG_TAG);
    
    return self.selectItemMode;
}

- (UIImage *)getContactAvatarWithUUID:(NSUUID *)peerTwincodeOutboundId {
    DDLogVerbose(@"%@ getContactAvatarWithUUID: %@", LOG_TAG, peerTwincodeOutboundId);
    
    if (!peerTwincodeOutboundId || !self.groupMembers) {
        return self.contactAvatar;
    } else {
        TLGroupMember *member = self.groupMembers[peerTwincodeOutboundId];
        if (!member) {
            return self.contactAvatar;
        } else {
            return [self.conversationService getImageWithGroupMember:member];
        }
    }
}

- (UIImage *)getContactAvatarForMap:(NSUUID *)peerTwincodeOutboundId {
    DDLogVerbose(@"%@ getContactAvatarForMap", LOG_TAG);

    if (!peerTwincodeOutboundId) {
        return self.identityAvatar;
    } else {
        TLGroupMember *member = self.groupMembers[peerTwincodeOutboundId];
        if (!member) {
            return self.contactAvatar;
        } else {
            return [self.conversationService getImageWithGroupMember:member];
        }
    }
}

- (BOOL)isSameDayWithDate1:(NSDate*)date1 date2:(NSDate*)date2 {
    DDLogVerbose(@"%@ isSameDayWithDate1: %@ date2: %@", LOG_TAG, date1, date2);
    
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSCalendarUnit calendarUnit = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
    NSDateComponents* dateComponents1 = [calendar components:calendarUnit fromDate:date1];
    NSDateComponents* dateComponents2 = [calendar components:calendarUnit fromDate:date2];
    return [dateComponents1 day] == [dateComponents2 day] && [dateComponents1 month] == [dateComponents2 month] && [dateComponents1 year] == [dateComponents2 year];
}

- (void)pushFileWithPath:(NSString *)path type:(TLDescriptorType)type toBeDeleted:(BOOL)toBeDeleted allowCopy:(BOOL)allowCopy expireTimeout:(int64_t)timeout {
    DDLogVerbose(@"%@ pushFileWithPath: %@ type: %u toBeDeleted: %@ allowCopy: %@ expireTimeout: %lld", LOG_TAG, path, type, toBeDeleted ? @"YES" : @"NO", allowCopy ? @"YES" : @"NO", timeout);
    
    NSUUID *sendTo = nil;
    TLDescriptorId *replyTo = nil;
    
    if (self.replyItem) {
        replyTo = self.replyItem.descriptorId;
    }
    
    [self.conversationService pushFileWithPath:path type:type toBeDeleted:toBeDeleted copyAllowed:allowCopy expiredTimeout:timeout sendTo:sendTo replyTo:replyTo];
    self.nbDescriptorsLoaded++;
    
    self.replyItem = nil;
    
    if (self.replyView) {
        self.replyView.hidden = YES;
        [self setupTableHeaderView];
    }
    
    if (type == TLDescriptorTypeAudioDescriptor) {
        [self setSelectedMode:ModeDefault];
    }
}

- (void)pushGeolocationWithLatitudeDelta:(double)latitudeDelta longitudeDelta:(double)longitudeDelta location:(CLLocation *)userLocation expireTimeout:(int64_t)timeout {
    DDLogVerbose(@"%@ pushGeolocationWithLatitudeDelta: %f longitudeDelta: %f timeout: %lld", LOG_TAG, latitudeDelta, longitudeDelta, timeout);
    
    NSUUID *sendTo = nil;
    TLDescriptorId *replyTo = nil;
    
    if (self.replyItem) {
        sendTo = self.contact.uuid;
        replyTo = self.replyItem.descriptorId;
    }
    
    [self.conversationService pushGeolocationWithLatitude:userLocation.coordinate.latitude longitude:userLocation.coordinate.longitude altitude:userLocation.altitude latitudeDelta:latitudeDelta longitudeDelta:longitudeDelta expiredTimeout:timeout sendTo:sendTo replyTo:replyTo];
            
    self.replyItem = nil;
    
    if (self.replyView) {
        self.replyView.hidden = YES;
    }
}

- (UIFont *)getMessageFont {
    DDLogVerbose(@"%@ getMessageFont", LOG_TAG);
    
    return self.messageFont;
}

- (id<TLOriginator>)getOriginator {
    DDLogVerbose(@"%@ getOriginator", LOG_TAG);
    
    return self.contact;
}

- (CustomAppearance *)getCustomAppearance {
    DDLogVerbose(@"%@ getCustomAppearance", LOG_TAG);
    
    return self.customAppearance;
}
    
- (void)resetVoiceRecorder {
    DDLogVerbose(@"%@ resetVoiceRecorder", LOG_TAG);
    
    [self setSelectedMode:ModeDefault];
}

#pragma mark - ConversationServiceDelegate

- (void)showProgressIndicator {
    DDLogVerbose(@"%@ showProgressIndicator", LOG_TAG);
}

- (void)hideProgressIndicator {
    DDLogVerbose(@"%@ hideProgressIndicator", LOG_TAG);
}

- (void)onSetCurrentSpace:(nonnull TLSpace *)space {
    DDLogVerbose(@"%@ onSetCurrentSpace: %@", LOG_TAG, space);

}

- (void)onGetConversation:(id <TLConversation>)conversation {
    DDLogVerbose(@"%@ onGetConversation: %@", LOG_TAG, conversation);
    
    self.conversationId = [conversation uuid];
    if (self.navigationController.topViewController == self) {
        [self.conversationService setActiveConversation];
    }
    
    [self updateNavigationBarAvatar];
}

- (void)onResetConversation:(id <TLConversation>)conversation clearMode:(TLConversationServiceClearMode)clearMode {
    DDLogVerbose(@"%@ onResetConversation: %@ clearMode: %d", LOG_TAG, conversation, clearMode);
    
    if ([conversation.uuid isEqual:self.conversationId]) {
        if (clearMode == TLConversationServiceClearMedia) {
            [self.conversationService clearMediaAndFile];
        } else {
            self.emptyConversationLabel.hidden = NO;
            self.scrollIndicatorView.hidden = YES;
            [self updateScrollIndicator];
            [self.items removeAllObjects];
        }
        
        [self reloadData];
    }
}

- (void)onUpdateConversation:(id <TLConversation>)conversation {
    DDLogVerbose(@"%@ onUpdateConversation: %@", LOG_TAG, conversation);
    
    self.conversationId = [conversation uuid];
}

- (void)onGetGroupConversation:(id <TLGroupConversation>)group groupMembers:(NSMutableDictionary *)groupMembers {
    DDLogVerbose(@"%@ onGetGroupConversation: %@", LOG_TAG, group);
    
    self.groupMembers = groupMembers;
    
    self.groupConversation = group;
    
    if (self.groupMembers.count > 0) {
        self.titleLabel.text = self.group.name;
        self.subTitleLabel.text = [NSString stringWithFormat:TwinmeLocalizedString(@"conversation_view_controller_group_member_information %@", nil), [NSString convertWithLocale:[NSString stringWithFormat:@"%lu",(unsigned long)self.groupMembers.count + 1]]];
    } else {
        self.titleLabel.text = self.group.name;
        self.subTitleLabel.text = TwinmeLocalizedString(@"conversation_view_controller_group_one_member", nil);
    }
    
    if (self.titleLabel) {
        CGFloat customTitleViewWidth = PROFILE_VIEW_WIDTH;
        if (self.group) {
            customTitleViewWidth = GROUP_VIEW_WIDTH;
        }
        
        CGFloat profileViewWidth = AVATAR_VIEW_HEIGHT + PROFILE_MARGIN + self.titleLabel.intrinsicContentSize.width;
        if (profileViewWidth > customTitleViewWidth) {
            profileViewWidth = customTitleViewWidth;
        }
        self.navigationItem.titleView.frame = CGRectMake(0, 0, profileViewWidth, Design.STANDARD_NAVIGATION_BAR_HEIGHT);
    }
    
    if (![self.groupConversation hasPermissionWithPermission:TLPermissionTypeSendMessage]) {
        self.textView.editable = NO;
        self.sendButtonView.hidden = YES;
        self.textView.placeholder = TwinmeLocalizedString(@"conversation_view_controller_group_not_allowed_post_message", nil);
    } else {
        self.textView.editable = YES;
        self.sendButtonView.hidden = NO;
        self.textView.placeholder = TwinmeLocalizedString(@"conversation_view_controller_message", nil);
    }
    
    [self updateInCall];
}

- (void)onGetGroupMembers:(NSMutableDictionary *)groupMembers {
    DDLogVerbose(@"%@ onGetGroupMembers: %@", LOG_TAG, groupMembers);
    
    self.groupMembers = groupMembers;
}

- (void)onGetDescriptors:(NSArray *)descriptors {
    DDLogVerbose(@"%@ onGetDescriptors: %@", LOG_TAG, descriptors);
    
    if (self.needsRefresh) {
        self.needsRefresh = NO;
        [self.items removeAllObjects];
    }
    
    if (descriptors.count == 0) {
        self.allDescriptorsLoaded = YES;
    }
    
    if (descriptors.count == 0 && self.items.count == 0) {
        self.emptyConversationLabel.hidden = NO;
    } else {
        self.emptyConversationLabel.hidden = YES;
    }
    
    self.nbDescriptorsLoaded += descriptors.count;
    
    CGPoint lastScrollOffset = self.tableView.contentOffset;
    self.batchUpdate = YES;
    
    for (TLDescriptor *descriptor in descriptors) {
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
                
            case TLDescriptorTypeAudioDescriptor: {
                TLAudioDescriptor *audioDescriptor = (TLAudioDescriptor *)descriptor;
                [self addAudioDescriptor:audioDescriptor];
                break;
            }
                
            case TLDescriptorTypeVideoDescriptor: {
                TLVideoDescriptor *videoDescriptor = (TLVideoDescriptor *)descriptor;
                [self addVideoDescriptor:videoDescriptor];
                break;
            }
                
            case TLDescriptorTypeNamedFileDescriptor: {
                TLNamedFileDescriptor *namedFileDescriptor = (TLNamedFileDescriptor *)descriptor;
                [self addNamedFileDescriptor:namedFileDescriptor];
                break;
            }
                
            case TLDescriptorTypeInvitationDescriptor: {
                TLInvitationDescriptor *invitationDescriptor = (TLInvitationDescriptor *)descriptor;
                [self addInvitationDescriptor:invitationDescriptor];
                break;
            }
                
            case TLDescriptorTypeCallDescriptor: {
                TLCallDescriptor *callDescriptor = (TLCallDescriptor *)descriptor;
                [self addCallDescriptor:callDescriptor];
                break;
            }
                
            case TLDescriptorTypeTwincodeDescriptor: {
                TLTwincodeDescriptor *twincodeDescriptor = (TLTwincodeDescriptor *)descriptor;
                [self addTwincodeDescriptor:twincodeDescriptor];
                break;
            }
                
            case TLDescriptorTypeGeolocationDescriptor: {
                TLGeolocationDescriptor *geolocationDescriptor = (TLGeolocationDescriptor *)descriptor;
                [self addGeolocationDescriptor:geolocationDescriptor];
                break;
            }

            case TLDescriptorTypeClearDescriptor: {
                TLClearDescriptor *clearDescriptor = (TLClearDescriptor *)descriptor;
                [self addClearDescriptor:clearDescriptor];
                break;
            }
                
            default:
                break;
        }
    }
    
    self.batchUpdate = NO;
    [self reloadInfoPrivacy];
    [self.tableView reloadData];
    [self.tableView.layer removeAllAnimations];
    self.loadingDescriptors = NO;
    
    if (self.descriptorId) {
        NSInteger itemIndex = -1;
        for (NSInteger index = self.items.count - 1; index >= 0; index--) {
            Item *item = [self.items objectAtIndex:index];
            if ([item.descriptorId isEqual:self.descriptorId]) {
                itemIndex = index;
                break;
            }
        }
        
        if (itemIndex != -1) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSIndexPath *indexPath = [self itemIndexToIndexPath:itemIndex];
                if (indexPath.row < self.items.count) {
                    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:NO];
                }
            });
        } else {
            if (!self.allDescriptorsLoaded) {
                self.loadingDescriptors = YES;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self getPreviousDescriptors];
                });
            }
        }
    } else {
        [self.tableView setContentOffset:lastScrollOffset animated:NO];
    }
}

- (void)onPushDescriptor:(TLDescriptor *)descriptor {
    DDLogVerbose(@"%@ onPushDescriptor: %@", LOG_TAG, descriptor);
        
    NSUInteger countItem = self.items.count;
    
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
            
        case TLDescriptorTypeAudioDescriptor: {
            TLAudioDescriptor *audioDescriptor = (TLAudioDescriptor *)descriptor;
            [self addAudioDescriptor:audioDescriptor];
            break;
        }
            
        case TLDescriptorTypeVideoDescriptor: {
            TLVideoDescriptor *videoDescriptor = (TLVideoDescriptor *)descriptor;
            [self addVideoDescriptor:videoDescriptor];
            break;
        }
            
        case TLDescriptorTypeNamedFileDescriptor: {
            TLNamedFileDescriptor *namedFileDescriptor = (TLNamedFileDescriptor *)descriptor;
            [self addNamedFileDescriptor:namedFileDescriptor];
            break;
        }
            
        case TLDescriptorTypeInvitationDescriptor: {
            TLInvitationDescriptor *invitationDescriptor = (TLInvitationDescriptor *)descriptor;
            [self addInvitationDescriptor:invitationDescriptor];
            break;
        }
            
        case TLDescriptorTypeCallDescriptor: {
            TLCallDescriptor *callDescriptor = (TLCallDescriptor *)descriptor;
            [self addCallDescriptor:callDescriptor];
            break;
        }
            
        case TLDescriptorTypeTwincodeDescriptor: {
            TLTwincodeDescriptor *twincodeDescriptor = (TLTwincodeDescriptor *)descriptor;
            [self addTwincodeDescriptor:twincodeDescriptor];
            break;
        }
            
        case TLDescriptorTypeGeolocationDescriptor: {
            TLGeolocationDescriptor *geolocationDescriptor = (TLGeolocationDescriptor *)descriptor;
            [self addGeolocationDescriptor:geolocationDescriptor];
            break;
        }

        case TLDescriptorTypeClearDescriptor: {
            TLClearDescriptor *clearDescriptor = (TLClearDescriptor *)descriptor;
            [self addClearDescriptor:clearDescriptor];
            break;
        }
            
        default:
            break;
    }
    
    if (self.items.count > countItem) {
        self.nbDescriptorsLoaded++;
    }
    
    if (self.items.count > 0 && [self.tableView numberOfRowsInSection:0] > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSIndexPath *indexPath = [self itemIndexToIndexPath:self.items.count - 1];
            if (indexPath.row < self.items.count) {
                [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
            }
        });
    }
}

- (void)onPopDescriptor:(TLDescriptor *)descriptor {
    DDLogVerbose(@"%@ onPopDescriptor: %@", LOG_TAG, descriptor);
    
    NSUInteger countItem = self.items.count;
    
    switch (descriptor.getType) {
        case TLDescriptorTypeObjectDescriptor: {
            TLObjectDescriptor *objectDescriptor = (TLObjectDescriptor *)descriptor;
            [self addObjectDescriptor:objectDescriptor];
            break;
        }
            
        case TLDescriptorTypeImageDescriptor: {
            TLImageDescriptor *imageDescriptor= (TLImageDescriptor *)descriptor;
            [self addImageDescriptor:imageDescriptor];
            break;
        }
            
        case TLDescriptorTypeVideoDescriptor: {
            TLVideoDescriptor *videoDescriptor = (TLVideoDescriptor *)descriptor;
            [self addVideoDescriptor:videoDescriptor];
            break;
        }
            
        case TLDescriptorTypeNamedFileDescriptor: {
            TLNamedFileDescriptor *fileDescriptor = (TLNamedFileDescriptor *)descriptor;
            [self addNamedFileDescriptor:fileDescriptor];
            break;
        }
            
        case TLDescriptorTypeInvitationDescriptor: {
            TLInvitationDescriptor *invitationDescriptor = (TLInvitationDescriptor *)descriptor;
            [self addInvitationDescriptor:invitationDescriptor];
            break;
        }
            
        case TLDescriptorTypeTransientObjectDescriptor: {
            TLTransientObjectDescriptor *transientObjectDescriptor = (TLTransientObjectDescriptor *)descriptor;
            [self addTransientObjectDescriptor:transientObjectDescriptor];
            break;
        }
            
        case TLDescriptorTypeCallDescriptor: {
            TLCallDescriptor *callDescriptor = (TLCallDescriptor *)descriptor;
            [self addCallDescriptor:callDescriptor];
            break;
        }
            
        case TLDescriptorTypeTwincodeDescriptor: {
            TLTwincodeDescriptor *twincodeDescriptor = (TLTwincodeDescriptor *)descriptor;
            [self addTwincodeDescriptor:twincodeDescriptor];
            break;
        }
            
        case TLDescriptorTypeGeolocationDescriptor: {
            TLGeolocationDescriptor *geolocationDescriptor = (TLGeolocationDescriptor *)descriptor;
            [self addGeolocationDescriptor:geolocationDescriptor];
            break;
        }

        case TLDescriptorTypeClearDescriptor: {
            TLClearDescriptor *clearDescriptor = (TLClearDescriptor *)descriptor;
            [self addClearDescriptor:clearDescriptor];
            break;
        }
            
        default:
            break;
    }
    
    if (self.items.count > countItem) {
        self.nbDescriptorsLoaded++;
        if (!self.scrollIndicatorView.isHidden) {
            self.scrollIndicatorCount++;
            [self updateScrollIndicator];
        }
    }
}

- (void)onUpdateDescriptor:(TLDescriptor *)descriptor updateType:(TLConversationServiceUpdateType)updateType {
    DDLogVerbose(@"%@ onUpdateDescriptor: %@ updateType: %u", LOG_TAG, descriptor, updateType);
    
    NSUInteger countItem = self.items.count;
    
    switch (updateType) {
        case TLConversationServiceUpdateTypeContent:
            switch (descriptor.getType) {
                case TLDescriptorTypeImageDescriptor: {
                    NSInteger itemIndex = -1;
                    TLDescriptorId *descriptorId = descriptor.descriptorId;
                    for (NSInteger index = self.items.count - 1; index >= 0; index--) {
                        Item *item = [self.items objectAtIndex:index];
                        if ([item.descriptorId isEqual:descriptorId]) {
                            itemIndex = index;
                            break;
                        }
                    }
                    if (itemIndex == -1) {
                        TLImageDescriptor *imageDescriptor = (TLImageDescriptor *)descriptor;
                        [self addImageDescriptor:imageDescriptor];
                    } else if (!self.batchUpdate) {
                        Item *item = [self.items objectAtIndex:itemIndex];
                        ItemCell *itemCell = [self.tableView cellForRowAtIndexPath:[self itemIndexToIndexPath:itemIndex]];
                        if (itemCell && itemCell.item == item) {
                            if (item.type == ItemTypePeerImage) {
                                PeerImageItem *peerImageItem = (PeerImageItem *)item;
                                peerImageItem.imageDescriptor = (TLImageDescriptor *)descriptor;
                                [itemCell bindWithItem:peerImageItem conversationViewController:self asyncManager:self.asyncLoaderManager];
                            } else {
                                ImageItem *imageItem = (ImageItem *)item;
                                imageItem.imageDescriptor = (TLImageDescriptor *)descriptor;
                                [itemCell bindWithItem:imageItem conversationViewController:self asyncManager:self.asyncLoaderManager];
                            }
                        }
                    }
                    break;
                }
                    
                case TLDescriptorTypeVideoDescriptor: {
                    NSInteger itemIndex = -1;
                    TLDescriptorId *descriptorId = descriptor.descriptorId;
                    for (NSInteger index = self.items.count - 1; index >= 0; index--) {
                        Item *item = [self.items objectAtIndex:index];
                        if ([item.descriptorId isEqual:descriptorId]) {
                            itemIndex = index;
                            break;
                        }
                    }
                    if (itemIndex == -1) {
                        TLVideoDescriptor *videoDescriptor = (TLVideoDescriptor *)descriptor;
                        [self addVideoDescriptor:videoDescriptor];
                    } else if (!self.batchUpdate) {
                        Item *item = [self.items objectAtIndex:itemIndex];
                        ItemCell *itemCell = [self.tableView cellForRowAtIndexPath:[self itemIndexToIndexPath:itemIndex]];
                        if (itemCell && itemCell.item == item) {
                            if (item.type == ItemTypePeerVideo) {
                                PeerVideoItem *peerVideoItem = (PeerVideoItem *)item;
                                peerVideoItem.videoDescriptor = (TLVideoDescriptor *)descriptor;
                                [itemCell bindWithItem:peerVideoItem conversationViewController:self asyncManager:self.asyncLoaderManager];
                            } else {
                                VideoItem *videoItem = (VideoItem *)item;
                                videoItem.videoDescriptor = (TLVideoDescriptor *)descriptor;
                                [itemCell bindWithItem:videoItem conversationViewController:self asyncManager:self.asyncLoaderManager];
                            }
                        }
                    }
                    break;
                }
                    
                case TLDescriptorTypeAudioDescriptor: {
                    TLAudioDescriptor *audioDescriptor = (TLAudioDescriptor *)descriptor;
                    if (audioDescriptor.isAvailable) {
                        [self addAudioDescriptor:audioDescriptor];
                    }
                    break;
                }
                    
                case TLDescriptorTypeNamedFileDescriptor: {
                    NSInteger itemIndex = -1;
                    TLDescriptorId *descriptorId = descriptor.descriptorId;
                    for (NSInteger index = self.items.count - 1; index >= 0; index--) {
                        Item *item = [self.items objectAtIndex:index];
                        if ([item.descriptorId isEqual:descriptorId]) {
                            itemIndex = index;
                            break;
                        }
                    }
                    if (itemIndex == -1) {
                        TLNamedFileDescriptor *namedFileDescriptor = (TLNamedFileDescriptor *)descriptor;
                        [self addNamedFileDescriptor:namedFileDescriptor];
                    } else if (!self.batchUpdate) {
                        Item *item = [self.items objectAtIndex:itemIndex];
                        ItemCell *itemCell = [self.tableView cellForRowAtIndexPath:[self itemIndexToIndexPath:itemIndex]];
                        if (itemCell && itemCell.item == item) {
                            if (item.type == ItemTypePeerFile) {
                                PeerFileItem *peerFileItem = (PeerFileItem *)item;
                                peerFileItem.namedFileDescriptor = (TLNamedFileDescriptor *)descriptor;
                                [itemCell bindWithItem:peerFileItem conversationViewController:self asyncManager:self.asyncLoaderManager];
                            } else {
                                FileItem *fileItem = (FileItem *)item;
                                fileItem.namedFileDescriptor = (TLNamedFileDescriptor *)descriptor;
                                [itemCell bindWithItem:fileItem conversationViewController:self asyncManager:self.asyncLoaderManager];
                            }
                        }
                    }
                    
                    break;
                }
                    
                case TLDescriptorTypeInvitationDescriptor: {
                    TLInvitationDescriptor *invitationDescriptor = (TLInvitationDescriptor *)descriptor;
                    [self addInvitationDescriptor:invitationDescriptor];
                    break;
                }
                    
                case TLDescriptorTypeTwincodeDescriptor: {
                    TLTwincodeDescriptor *twincodeDescriptor = (TLTwincodeDescriptor *)descriptor;
                    [self addTwincodeDescriptor:twincodeDescriptor];
                    break;
                }
                    
                case TLDescriptorTypeClearDescriptor: {
                    TLClearDescriptor *clearDescriptor = (TLClearDescriptor *)descriptor;
                    [self addClearDescriptor:clearDescriptor];
                    break;
                }
                    
                case TLDescriptorTypeCallDescriptor: {
                    NSInteger itemIndex = -1;
                    TLDescriptorId *descriptorId = descriptor.descriptorId;
                    for (NSInteger index = self.items.count - 1; index >= 0; index--) {
                        Item *item = [self.items objectAtIndex:index];
                        if ([item.descriptorId isEqual:descriptorId]) {
                            itemIndex = index;
                            break;
                        }
                    }
                    if (itemIndex == -1) {
                        TLCallDescriptor *callDescriptor = (TLCallDescriptor *)descriptor;
                        [self addCallDescriptor:callDescriptor];
                    } else if (!self.batchUpdate) {
                        Item *item = [self.items objectAtIndex:itemIndex];
                        ItemCell *itemCell = [self.tableView cellForRowAtIndexPath:[self itemIndexToIndexPath:itemIndex]];
                        if (itemCell && itemCell.item == item) {
                            if (item.type == ItemTypePeerCall) {
                                PeerCallItem *peerCallItem = (PeerCallItem *)item;
                                peerCallItem.peerCallDescriptor = (TLCallDescriptor *)descriptor;
                                [itemCell bindWithItem:peerCallItem conversationViewController:self];
                            } else {
                                CallItem *callItem = (CallItem *)item;
                                callItem.callDescriptor = (TLCallDescriptor *)descriptor;
                                [itemCell bindWithItem:callItem conversationViewController:self];
                            }
                        }
                    }
                    break;
                }
                    
                case TLDescriptorTypeObjectDescriptor: {
                    NSInteger itemIndex = -1;
                    TLDescriptorId *descriptorId = descriptor.descriptorId;
                    for (NSInteger index = self.items.count - 1; index >= 0; index--) {
                        Item *item = [self.items objectAtIndex:index];
                        if ([item.descriptorId isEqual:descriptorId]) {
                            itemIndex = index;
                            break;
                        }
                    }
                    if (itemIndex == -1) {
                        TLObjectDescriptor *objectDescriptor = (TLObjectDescriptor *)descriptor;
                        [self addObjectDescriptor:objectDescriptor];
                    } else if (!self.batchUpdate) {
                        Item *item = [self.items objectAtIndex:itemIndex];
                        [item updateTimestampsWithDescriptor:descriptor];
                        
                        ItemCell *itemCell = [self.tableView cellForRowAtIndexPath:[self itemIndexToIndexPath:itemIndex]];
                        if (itemCell && itemCell.item == item) {
                            if (item.type == ItemTypePeerMessage) {
                                PeerMessageItem *peerMessageItem = (PeerMessageItem *)item;
                                peerMessageItem.content = [(TLObjectDescriptor *)descriptor message];
                                peerMessageItem.objectDescriptor = (TLObjectDescriptor *)descriptor;
                                [itemCell bindWithItem:peerMessageItem conversationViewController:self asyncManager:self.asyncLoaderManager];
                            } else {
                                MessageItem *messageItem = (MessageItem *)item;
                                messageItem.content = [(TLObjectDescriptor *)descriptor message];
                                messageItem.objectDescriptor = (TLObjectDescriptor *)descriptor;
                                [itemCell bindWithItem:messageItem conversationViewController:self asyncManager:self.asyncLoaderManager];
                            }
                        } else {
                            if (item.type == ItemTypePeerMessage) {
                                PeerMessageItem *peerMessageItem = (PeerMessageItem *)item;
                                peerMessageItem.content = [(TLObjectDescriptor *)descriptor message];
                                peerMessageItem.objectDescriptor = (TLObjectDescriptor *)descriptor;
                            } else {
                                MessageItem *messageItem = (MessageItem *)item;
                                messageItem.content = [(TLObjectDescriptor *)descriptor message];
                                messageItem.objectDescriptor = (TLObjectDescriptor *)descriptor;
                            }
                        }
                        
                        [self.tableView reloadRowsAtIndexPaths:@[[self itemIndexToIndexPath:itemIndex]] withRowAnimation:UITableViewRowAnimationNone];
                    }
                    break;
                }
                    
                case TLDescriptorTypeGeolocationDescriptor: {
                    TLGeolocationDescriptor *geolocationDescriptor = (TLGeolocationDescriptor *)descriptor;
                    NSInteger updatedItemIndex = -1;
                    for (NSInteger index = self.items.count - 1; index >= 0; index--) {
                        Item *item = [self.items objectAtIndex:index];
                        if ([item.descriptorId isEqual:geolocationDescriptor.descriptorId]) {
                            updatedItemIndex = index;
                            if (item.type == ItemTypeLocation) {
                                LocationItem *locationItem = (LocationItem *)item;
                                [(LocationItem *)item setGeolocationDescriptor:geolocationDescriptor];
                                ItemCell *itemCell = (ItemCell *)[self.tableView cellForRowAtIndexPath:[self itemIndexToIndexPath:updatedItemIndex]];
                                [itemCell bindWithItem:locationItem conversationViewController:self];
                            } else if (item .type == ItemTypePeerLocation) {
                                PeerLocationItem *peerLocationItem = (PeerLocationItem *)item;
                                [(PeerLocationItem *)item setGeolocationDescriptor:geolocationDescriptor];
                                ItemCell *itemCell = (ItemCell *)[self.tableView cellForRowAtIndexPath:[self itemIndexToIndexPath:updatedItemIndex]];
                                [itemCell bindWithItem:peerLocationItem conversationViewController:self];
                            }
                            
                            break;
                        }
                    }
                    
                    if (updatedItemIndex == -1) {
                        [self addGeolocationDescriptor:geolocationDescriptor];
                    }
                    break;
                }
                    
                default:
                    break;
            }
            break;
            
        case TLConversationServiceUpdateTypeTimestamps: {
            NSInteger lastReadPeerItemIndex = -1;
            NSInteger updatedItemIndex = -1;
            TLDescriptorId *descriptorId = descriptor.descriptorId;
            for (NSInteger index = self.items.count - 1; index >= 0; index--) {
                Item *item = [self.items objectAtIndex:index];
                if (item == self.lastReadPeerItem) {
                    lastReadPeerItemIndex = index;
                }
                if ([item.descriptorId isEqual:descriptorId]) {
                    updatedItemIndex = index;
                    break;
                }
            }
            if (updatedItemIndex == -1) {
                return;
            }
            
            Item *updatedItem = [self.items objectAtIndex:updatedItemIndex];
            if ([descriptor isExpired] || ([updatedItem isPeerItem] && descriptor.deletedTimestamp)) {
                [self deleteItemInternal:updatedItem];
                return;
            }
            
            [updatedItem updateTimestampsWithDescriptor:descriptor];
            if (self.batchUpdate) {
                return;
            }
            
            if (![updatedItem isPeerItem] && updatedItem.readTimestamp && updatedItem.readTimestamp != -1) {
                Item *lastReadPeerItem = self.lastReadPeerItem;
                int64_t lastReadPeerItemTimestamp = lastReadPeerItem ? lastReadPeerItem.timestamp : -1;
                if (updatedItem.timestamp < lastReadPeerItemTimestamp) {
                    [updatedItem resetState];
                } else if (updatedItem.timestamp > lastReadPeerItemTimestamp) {
                    self.lastReadPeerItem = updatedItem;
                    if (lastReadPeerItem) {
                        [lastReadPeerItem resetState];
                        if (lastReadPeerItemIndex == -1) {
                            for (NSInteger index = updatedItemIndex - 1; index >= 0; index--) {
                                Item *item = [self.items objectAtIndex:index];
                                if (item == lastReadPeerItem) {
                                    lastReadPeerItemIndex = index;
                                    break;
                                }
                            }
                        }
                    }
                }
            } else {
                lastReadPeerItemIndex = -1;
            }
            
            if (lastReadPeerItemIndex != -1) {
                Item *item = [self.items objectAtIndex:lastReadPeerItemIndex];
                ItemCell *itemCell = (ItemCell *)[self.tableView cellForRowAtIndexPath:[self itemIndexToIndexPath:lastReadPeerItemIndex]];
                // Make sure our item matches the cell (pointer equality is enougth).
                // (there is an inconsistency between self.items and cellForRowAtIndexPath/indexPathForRow).
                if (itemCell && itemCell.item == item) {
                    switch (item.type) {
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
                            [itemCell bindWithItem:item conversationViewController:self asyncManager:self.asyncLoaderManager];
                            break;
                        }
                            
                        default:
                            [itemCell bindWithItem:item conversationViewController:self];
                            break;
                    }
                }
            }
            if (updatedItemIndex != -1 && (updatedItemIndex != lastReadPeerItemIndex)) {
                Item *item = [self.items objectAtIndex:updatedItemIndex];
                ItemCell *itemCell = (ItemCell *)[self.tableView cellForRowAtIndexPath:[self itemIndexToIndexPath:updatedItemIndex]];
                // Make sure our item matches the cell (pointer equality is enougth).
                // (there is an inconsistency between self.items and cellForRowAtIndexPath/indexPathForRow).
                if (itemCell && itemCell.item == item) {
                    switch (itemCell.item.type) {
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
                            [itemCell bindWithItem:item conversationViewController:self asyncManager:self.asyncLoaderManager];
                            break;
                        }
                            
                        default:
                            [itemCell bindWithItem:item conversationViewController:self];
                            break;
                    }
                }
            }
            break;
        }
            
        case TLConversationServiceUpdateTypeLocalAnnotations:
        case TLConversationServiceUpdateTypePeerAnnotations:
        case TLConversationServiceUpdateTypeProtection:
        {
            NSInteger updatedItemIndex = -1;
            TLDescriptorId *descriptorId = descriptor.descriptorId;
            for (NSInteger index = self.items.count - 1; index >= 0; index--) {
                Item *item = [self.items objectAtIndex:index];
                if ([item.descriptorId isEqual:descriptorId]) {
                    updatedItemIndex = index;
                    break;
                }
            }
            
            if (updatedItemIndex == -1) {
                return;
            }
            
            Item *updatedItem = [self.items objectAtIndex:updatedItemIndex];
            [updatedItem updateAnnotationsWithDescriptor:descriptor];
            ItemCell *itemCell = (ItemCell *)[self.tableView cellForRowAtIndexPath:[self itemIndexToIndexPath:updatedItemIndex]];
            if (itemCell && itemCell.item == updatedItem) {
                switch (updatedItem.type) {
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
                        [itemCell bindWithItem:updatedItem conversationViewController:self asyncManager:self.asyncLoaderManager];
                        break;
                    }
                        
                    default:
                        [itemCell bindWithItem:updatedItem conversationViewController:self];
                        break;
                }
                [self.tableView reloadRowsAtIndexPaths:@[[self itemIndexToIndexPath:updatedItemIndex]] withRowAnimation:UITableViewRowAnimationNone];
            }
            
            break;
        }
    }
    
    if (self.items.count > countItem) {
        self.nbDescriptorsLoaded++;
    }
}

- (void)onMarkDescriptorRead:(TLDescriptor *)descriptor {
    DDLogVerbose(@"%@ onMarkDescriptorRead: %@", LOG_TAG, descriptor);
    
    TLDescriptorId *descriptorId = descriptor.descriptorId;
    for (NSInteger index = self.items.count - 1; index >= 0; index--) {
        Item *item = [self.items objectAtIndex:index];
        if ([item.descriptorId isEqual:descriptorId]) {
            [item updateTimestampsWithDescriptor:descriptor];
            
            if (!self.batchUpdate) {
                ItemCell *itemCell = (ItemCell *)[self.tableView cellForRowAtIndexPath:[self itemIndexToIndexPath:index]];
                // Make sure our item matches the cell.
                // (there is an inconsistency between self.items and cellForRowAtIndexPath/indexPathForRow).
                if (itemCell && itemCell.item == item) {
                    switch (itemCell.item.type) {
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
                            [itemCell bindWithItem:item conversationViewController:self asyncManager:self.asyncLoaderManager];
                            break;
                        }
                            
                        default:
                            [itemCell bindWithItem:item conversationViewController:self];
                            break;
                    }
                }
            }
            break;
        }
    }
}

- (void)onMarkDescriptorDeleted:(TLDescriptor *)descriptor {
    DDLogVerbose(@"%@ onMarkDescriptorDeleted: %@", LOG_TAG, descriptor);
    
    TLDescriptorId *descriptorId = descriptor.descriptorId;
    for (NSInteger index = self.items.count - 1; index >= 0; index--) {
        Item *item = [self.items objectAtIndex:index];
        if ([item.descriptorId isEqual:descriptorId]) {
            [item updateTimestampsWithDescriptor:descriptor];
            
            if (!self.batchUpdate) {
                ItemCell *itemCell = (ItemCell *)[self.tableView cellForRowAtIndexPath:[self itemIndexToIndexPath:index]];
                // Make sure our item matches the cell.
                // (there is an inconsistency between self.items and cellForRowAtIndexPath/indexPathForRow).
                if (itemCell && itemCell.item == item) {
                    switch (itemCell.item.type) {
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
                        case ItemTypePeerVideo:
                        case ItemTypeLocation:
                        case ItemTypePeerLocation:{
                            [itemCell bindWithItem:item conversationViewController:self asyncManager:self.asyncLoaderManager];
                            break;
                        }
                            
                        default:
                            [itemCell bindWithItem:item conversationViewController:self];
                            break;
                    }
                }
            }
            break;
        }
    }
}

- (void)onDeleteDescriptors:(NSSet<TLDescriptorId *> *)descriptors {
    DDLogVerbose(@"%@ onDeleteDescriptors: %@", LOG_TAG, descriptors);
    
    NSMutableSet *descriptorList = [[NSMutableSet alloc] initWithSet:descriptors];
    for (NSInteger index = self.items.count - 1; index >= 0; index--) {
        Item* item = [self.items objectAtIndex:index];
        TLDescriptorId *descriptorId = item.descriptorId;
        if (descriptorId && [descriptorList containsObject:descriptorId]) {
            [descriptorList removeObject:descriptorId];
            
            if (![item isPeerItem] && item.sentTimestamp > 0) {
                item.peerDeletedTimestamp =  [[NSDate date] timeIntervalSince1970] * 1000;
                
                if (item.type == ItemTypeCall) {
                    item.deletedTimestamp =  [[NSDate date] timeIntervalSince1970] * 1000;
                }
                
                [item updateState];
                ItemCell *itemCell = (ItemCell *)[self.tableView cellForRowAtIndexPath:[self itemIndexToIndexPath:index]];
                
                if (itemCell && [itemCell.item.descriptorId isEqual:item.descriptorId]) {
                    switch (item.type) {
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
                        case ItemTypePeerVideo:
                        case ItemTypeLocation:
                        case ItemTypePeerLocation:{
                            [itemCell bindWithItem:item conversationViewController:self asyncManager:self.asyncLoaderManager];
                            break;
                        }
                            
                        default:
                            [itemCell bindWithItem:item conversationViewController:self];
                            break;
                    }
                }
            } else {
                [self deleteItemInternal:item];
            }
            
            if (descriptorList.count == 0) {
                break;
            }
        }
    }
}

- (void)onGetConversationImage:(nonnull NSUUID *)imageId image:(nonnull UIImage *)image {
    DDLogVerbose(@"%@ onGetConversationImage: %@ image: %@", LOG_TAG, imageId, image);

    if ([[self.customAppearance getConversationBackgroundImageId] isEqual:imageId]) {
        self.backgroundConversationImageView.hidden = NO;
        self.backgroundConversationImageView.image = image;
    }
}

- (void)onErrorFeatureNotSupportedByPeer {
    DDLogVerbose(@"%@ onErrorFeatureNotSupportedByPeer", LOG_TAG);
    
    AlertMessageView *alertMessageView = [[AlertMessageView alloc] init];
    alertMessageView.alertMessageViewDelegate = self;
    [alertMessageView initWithTitle:TwinmeLocalizedString(@"delete_account_view_controller_warning", nil) message:TwinmeLocalizedString(@"conversation_view_controller_feature_not_supported_by_peer", nil)];
    [self.tabBarController.view addSubview:alertMessageView];
    [alertMessageView showAlertView];
}

#pragma mark - GroupInvitationServiceDelegate

- (void)onDeclinedInvitationWithInvitationDescriptor:(nonnull TLInvitationDescriptor *)invitationDescriptor {
    DDLogVerbose(@"%@ onDeclinedInvitationWithInvitationDescriptor: %@", LOG_TAG, invitationDescriptor);
    
    [self onUpdateDescriptor:invitationDescriptor updateType:TLConversationServiceUpdateTypeTimestamps];
}

- (void)onAcceptedInvitationWithInvitationDescriptor:(nonnull TLInvitationDescriptor *)invitationDescriptor groupId:(nonnull NSUUID *)groupId {
    DDLogVerbose(@"%@ onAcceptedInvitationWithInvitationDescriptor: %@ groupId: %@", LOG_TAG, invitationDescriptor, groupId);
    
    [self onUpdateDescriptor:invitationDescriptor updateType:TLConversationServiceUpdateTypeTimestamps];
}

#pragma mark - GroupServiceDelegate

- (void)onGetGroup:(TLGroup *)group groupMembers:(NSArray<TLGroupMember *> *)groupMembers conversation:(id<TLGroupConversation>)conversation {
    DDLogVerbose(@"%@ onGetGroup: %@ groupMembers:%@ conversation:%@", LOG_TAG, group, groupMembers,conversation);
    
    if (self.openGroupFromInvitation) {
        self.openGroupFromInvitation = NO;
        
        ConversationViewController *conversationViewController = (ConversationViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"ConversationViewController"];
        [conversationViewController initWithContact:group];
        [self.navigationController pushViewController:conversationViewController animated:YES];
    } else if (group) {
        self.group = group;
        self.space = self.group.space;
        if ([self.space.settings getBooleanWithName:PROPERTY_DEFAULT_APPEARANCE_SETTINGS defaultValue:YES]) {
            self.customAppearance = [[CustomAppearance alloc]initWithSpaceSettings:self.twinmeContext.defaultSpaceSettings];
        } else {
            self.customAppearance = [[CustomAppearance alloc]initWithSpaceSettings:self.space.settings];
        }
        [self.typingView setCustomAppearance:self.customAppearance];
        [self updateTableViewBackgroundColor];
        
        [self.conversationService getImageWithGroup:self.group withBlock:^(UIImage *image) {
            self.contactAvatar = image;
        }];
        
        self.contactName = self.group.name;
        
        if (groupMembers && groupMembers.count > 0) {
            [self.groupMembers removeAllObjects];
            for (TLGroupMember *member in groupMembers) {
                [self.groupMembers setObject:member forKey:member.uuid];
            }
        }
        
        if ([conversation groupMembersWithFilter:TLGroupMemberFilterTypeJoinedMembers].count > 0) {
            self.titleLabel.text = self.group.name;
            self.subTitleLabel.text = [NSString stringWithFormat:TwinmeLocalizedString(@"conversation_view_controller_group_member_information %@", nil), [NSString convertWithLocale:[NSString stringWithFormat:@"%lu",(unsigned long)[conversation groupMembersWithFilter:TLGroupMemberFilterTypeJoinedMembers].count + 1]]];
        } else {
            self.titleLabel.text = self.group.name;
            self.subTitleLabel.text = TwinmeLocalizedString(@"conversation_view_controller_group_one_member", nil);
        }
        
        if (self.titleLabel) {
            CGFloat customTitleViewWidth = PROFILE_VIEW_WIDTH;
            if (self.group) {
                customTitleViewWidth = GROUP_VIEW_WIDTH;
            }
            CGFloat profileViewWidth = AVATAR_VIEW_HEIGHT + PROFILE_MARGIN + self.titleLabel.intrinsicContentSize.width;
            if (profileViewWidth > customTitleViewWidth) {
                profileViewWidth = customTitleViewWidth;
            }
            self.navigationItem.titleView.frame = CGRectMake(0, 0, profileViewWidth, Design.STANDARD_NAVIGATION_BAR_HEIGHT);
        }
        
        if (![conversation hasPermissionWithPermission:TLPermissionTypeSendMessage]) {
            self.textView.editable = NO;
            self.sendButtonView.hidden = YES;
            self.textView.placeholder = TwinmeLocalizedString(@"conversation_view_controller_group_not_allowed_post_message", nil);
        } else {
            self.textView.editable = YES;
            self.sendButtonView.hidden = NO;
            self.textView.placeholder = TwinmeLocalizedString(@"conversation_view_controller_message", nil);
        }
    }
}

- (void)onLeaveGroup:(TLGroup *)group memberTwincodeId:(NSUUID *)memberTwincodeId {
    DDLogVerbose(@"%@ onLeaveGroup: %@ memberTwincodeId:%@", LOG_TAG, group, memberTwincodeId);
    
    if ([memberTwincodeId isEqual:group.twincodeOutboundId]) {
        [self finish];
    } else {
        [self.groupService getGroupWithGroupId:group.uuid];
    }
}

- (void)onGetCurrentSpace:(nonnull TLSpace *)space {
    DDLogVerbose(@"%@ onGetCurrentSpace: %@", LOG_TAG, space);
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    DDLogVerbose(@"%@ numberOfSectionsInTableView: %@", LOG_TAG, tableView);
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ numberOfRowsInSection: %ld", LOG_TAG, tableView, (long)section);
    
    return self.items.count;
}

- (void)tableView:(UITableView *)tableView prefetchRowsAtIndexPaths:(NSArray<NSIndexPath *> *) indexPaths {
    DDLogVerbose(@"%@ tableView: %@ prefetchRowsAtIndexPaths: %@", LOG_TAG, tableView, indexPaths);
    
    for (NSIndexPath *ip in indexPaths) {
        if (ip.row > self.maxPrefetchIndex) {
            self.maxPrefetchIndex = ip.row;
        }
    }
    
    if (!self.loadingDescriptors && !self.allDescriptorsLoaded) {
        if (self.maxPrefetchIndex > self.nbDescriptorsLoaded) {
            self.loadingDescriptors = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self getPreviousDescriptors];
            });
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ cellForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    NSUInteger index = [self.items count] - indexPath.row - 1;
    
    if (index == -1 || index >= self.items.count) {
        return [[UITableViewCell alloc]init];
    }
    
    Item *item = [self.items objectAtIndex:index];
    Item *nextItem = nil;
    if (index + 1 < self.items.count) {
        nextItem  = [self.items objectAtIndex:index + 1];
    }
    
    if ([item isPeerItem] && (!nextItem || ![nextItem isPeerItem] || ![nextItem isSamePeer:item])) {
        item.visibleAvatar = YES;
        
        Item *prevItem = nil;
        if (index - 1 >= 0) {
            prevItem  = [self.items objectAtIndex:index - 1];
        }
        if(prevItem && prevItem.type == ItemTypeName) {
            item.corners = ITEM_TOP_LEFT | ITEM_TOP_RIGHT | ITEM_BOTTOM_LEFT | ITEM_BOTTOM_RIGHT;
        } else if (nextItem && nextItem.type == ItemTypeName) {
            item.corners |= ITEM_BOTTOM_LEFT;
        }
    } else {
        item.visibleAvatar = NO;
    }
    
    item.mode = ItemModeNormal;
    
    switch (item.type) {
        case ItemTypeInfoPrivacy: {
            InfoPrivacyCell *infoPrivacyItemCell = (InfoPrivacyCell *)[self.tableView dequeueReusableCellWithIdentifier:INFO_PRIVACY_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
            [infoPrivacyItemCell updatePseudo:self.contact.name];
            infoPrivacyItemCell.transform = self.tableView.transform;
            infoPrivacyItemCell.menuActionDelegate = self;
            return infoPrivacyItemCell;
        }
            
        case ItemTypeTime: {
            TimeItem *timeItem = (TimeItem *)item;
            TimeItemCell *timeCell = [[TimeItemCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:TIME_CELL_IDENTIFIER topMargin:0 bottomMargin:0];
            [timeCell bindWithItem:timeItem conversationViewController:self];
            timeCell.transform = self.tableView.transform;
            timeCell.menuActionDelegate = self;
            return timeCell;
        }
            
        case ItemTypeMessage: {
            MessageItem *messageItem = (MessageItem *)item;
            MessageItemCell *messageItemCell = (MessageItemCell *)[self.tableView dequeueReusableCellWithIdentifier:MESSAGE_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
            [messageItemCell bindWithItem:messageItem conversationViewController:self asyncManager:self.asyncLoaderManager];
            messageItemCell.transform = self.tableView.transform;
            messageItemCell.deleteActionDelegate = self;
            messageItemCell.menuActionDelegate = self;
            messageItemCell.replyItemDelegate = self;
            messageItemCell.selectItemDelegate = self;
            messageItemCell.reactionViewDelegate = self;
            return messageItemCell;
        }
            
        case ItemTypePeerMessage: {
            PeerMessageItem *peerMessageItem = (PeerMessageItem *)item;
            PeerMessageItemCell *peerMessageItemCell = (PeerMessageItemCell *)[self.tableView dequeueReusableCellWithIdentifier:PEER_MESSAGE_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
            [peerMessageItemCell bindWithItem:peerMessageItem conversationViewController:self asyncManager:self.asyncLoaderManager];
            peerMessageItemCell.transform = self.tableView.transform;
            peerMessageItemCell.deleteActionDelegate = self;
            peerMessageItemCell.menuActionDelegate = self;
            peerMessageItemCell.replyItemDelegate = self;
            peerMessageItemCell.selectItemDelegate = self;
            peerMessageItemCell.reactionViewDelegate = self;
            return peerMessageItemCell;
        }
            
        case ItemTypeLink: {
            LinkItem *linkItem = (LinkItem *)item;
            LinkItemCell *linkItemCell = (LinkItemCell *)[self.tableView dequeueReusableCellWithIdentifier:LINK_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
            [linkItemCell bindWithItem:linkItem conversationViewController:self asyncManager:self.asyncLoaderManager];
            linkItemCell.transform = self.tableView.transform;
            linkItemCell.deleteActionDelegate = self;
            linkItemCell.menuActionDelegate = self;
            linkItemCell.replyItemDelegate = self;
            linkItemCell.linkActionDelegate = self;
            linkItemCell.selectItemDelegate = self;
            linkItemCell.reactionViewDelegate = self;
            return linkItemCell;
        }
            
        case ItemTypePeerLink: {
            PeerLinkItem *peerLinkItem = (PeerLinkItem *)item;
            PeerLinkItemCell *peerLinkItemCell = (PeerLinkItemCell *)[self.tableView dequeueReusableCellWithIdentifier:PEER_LINK_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
            [peerLinkItemCell bindWithItem:peerLinkItem conversationViewController:self asyncManager:self.asyncLoaderManager];
            peerLinkItemCell.transform = self.tableView.transform;
            peerLinkItemCell.deleteActionDelegate = self;
            peerLinkItemCell.menuActionDelegate = self;
            peerLinkItemCell.replyItemDelegate = self;
            peerLinkItemCell.linkActionDelegate = self;
            peerLinkItemCell.selectItemDelegate = self;
            peerLinkItemCell.reactionViewDelegate = self;
            return peerLinkItemCell;
        }
            
        case ItemTypeImage: {
            ImageItem *imageItem = (ImageItem *)item;
            ImageItemCell *imageItemCell = (ImageItemCell *)[self.tableView dequeueReusableCellWithIdentifier:IMAGE_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
            [imageItemCell bindWithItem:imageItem conversationViewController:self asyncManager:self.asyncLoaderManager];
            imageItemCell.transform = self.tableView.transform;
            imageItemCell.imageActionDelegate = self;
            imageItemCell.deleteActionDelegate = self;
            imageItemCell.menuActionDelegate = self;
            imageItemCell.replyItemDelegate = self;
            imageItemCell.selectItemDelegate = self;
            imageItemCell.reactionViewDelegate = self;
            return imageItemCell;
        }
            
        case ItemTypePeerImage: {
            PeerImageItem *peerImageItem = (PeerImageItem *)item;
            PeerImageItemCell *peerImageItemCell = (PeerImageItemCell *)[self.tableView dequeueReusableCellWithIdentifier:PEER_IMAGE_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
            [peerImageItemCell bindWithItem:peerImageItem conversationViewController:self asyncManager:self.asyncLoaderManager];
            peerImageItemCell.transform = self.tableView.transform;
            peerImageItemCell.imageActionDelegate = self;
            peerImageItemCell.deleteActionDelegate = self;
            peerImageItemCell.menuActionDelegate = self;
            peerImageItemCell.replyItemDelegate = self;
            peerImageItemCell.selectItemDelegate = self;
            peerImageItemCell.reactionViewDelegate = self;
            return peerImageItemCell;
        }
            
        case ItemTypeAudio: {
            AudioItem *audioItem = (AudioItem *)item;
            AudioItemCell *audioItemCell = (AudioItemCell *)[self.tableView dequeueReusableCellWithIdentifier:AUDIO_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
            [audioItemCell bindWithItem:audioItem conversationViewController:self asyncManager:self.asyncLoaderManager];
            audioItemCell.transform = self.tableView.transform;
            audioItemCell.deleteActionDelegate = self;
            audioItemCell.menuActionDelegate = self;
            audioItemCell.replyItemDelegate = self;
            audioItemCell.selectItemDelegate = self;
            audioItemCell.reactionViewDelegate = self;
            return audioItemCell;
        }
            
        case ItemTypePeerAudio: {
            PeerAudioItem *peerAudioItem = (PeerAudioItem *)item;
            PeerAudioItemCell *peerAudioItemCell = (PeerAudioItemCell *)[self.tableView dequeueReusableCellWithIdentifier:PEER_AUDIO_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
            [peerAudioItemCell bindWithItem:peerAudioItem conversationViewController:self asyncManager:self.asyncLoaderManager];
            peerAudioItemCell.transform = self.tableView.transform;
            peerAudioItemCell.deleteActionDelegate = self;
            peerAudioItemCell.menuActionDelegate = self;
            peerAudioItemCell.replyItemDelegate = self;
            peerAudioItemCell.selectItemDelegate = self;
            peerAudioItemCell.reactionViewDelegate = self;
            peerAudioItemCell.audioActionDelegate = self;
            return peerAudioItemCell;
        }
            
        case ItemTypeVideo: {
            VideoItem *videoItem = (VideoItem *)item;
            VideoItemCell *videoItemCell = (VideoItemCell *)[self.tableView dequeueReusableCellWithIdentifier:VIDEO_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
            [videoItemCell bindWithItem:videoItem conversationViewController:self asyncManager:self.asyncLoaderManager];
            videoItemCell.transform = self.tableView.transform;
            videoItemCell.videoActionDelegate = self;
            videoItemCell.deleteActionDelegate = self;
            videoItemCell.menuActionDelegate = self;
            videoItemCell.replyItemDelegate = self;
            videoItemCell.selectItemDelegate = self;
            videoItemCell.reactionViewDelegate = self;
            return videoItemCell;
        }
            
        case ItemTypePeerVideo: {
            PeerVideoItem *peerVideoItem = (PeerVideoItem *)item;
            PeerVideoItemCell *peerVideoItemCell = (PeerVideoItemCell *)[self.tableView dequeueReusableCellWithIdentifier:PEER_VIDEO_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
            [peerVideoItemCell bindWithItem:peerVideoItem conversationViewController:self asyncManager:self.asyncLoaderManager];
            peerVideoItemCell.transform = self.tableView.transform;
            peerVideoItemCell.videoActionDelegate = self;
            peerVideoItemCell.deleteActionDelegate = self;
            peerVideoItemCell.menuActionDelegate = self;
            peerVideoItemCell.replyItemDelegate = self;
            peerVideoItemCell.selectItemDelegate = self;
            peerVideoItemCell.reactionViewDelegate = self;
            return peerVideoItemCell;
        }
            
        case ItemTypeFile: {
            FileItem *fileItem = (FileItem *)item;
            FileItemCell *fileItemCell = (FileItemCell *)[self.tableView dequeueReusableCellWithIdentifier:FILE_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
            [fileItemCell bindWithItem:fileItem conversationViewController:self asyncManager:self.asyncLoaderManager];
            fileItemCell.transform = self.tableView.transform;
            fileItemCell.deleteActionDelegate = self;
            fileItemCell.fileActionDelegate = self;
            fileItemCell.menuActionDelegate = self;
            fileItemCell.replyItemDelegate = self;
            fileItemCell.selectItemDelegate = self;
            fileItemCell.reactionViewDelegate = self;
            return fileItemCell;
        }
            
        case ItemTypePeerFile: {
            PeerFileItem *peerFileItem = (PeerFileItem *)item;
            PeerFileItemCell *peerFileItemCell = (PeerFileItemCell *)[self.tableView dequeueReusableCellWithIdentifier:PEER_FILE_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
            [peerFileItemCell bindWithItem:peerFileItem conversationViewController:self asyncManager:self.asyncLoaderManager];
            peerFileItemCell.transform = self.tableView.transform;
            peerFileItemCell.fileActionDelegate = self;
            peerFileItemCell.deleteActionDelegate = self;
            peerFileItemCell.menuActionDelegate = self;
            peerFileItemCell.replyItemDelegate = self;
            peerFileItemCell.selectItemDelegate = self;
            peerFileItemCell.reactionViewDelegate = self;
            return peerFileItemCell;
        }
            
        case ItemTypeLocation: {
            LocationItem* locationItem = (LocationItem *)item;
            LocationItemCell *locationItemCell = (LocationItemCell *)[self.tableView dequeueReusableCellWithIdentifier:LOCATION_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
            [locationItemCell bindWithItem:locationItem conversationViewController:self];
            locationItemCell.transform = self.tableView.transform;
            locationItemCell.locationActionDelegate = self;
            locationItemCell.deleteActionDelegate = self;
            locationItemCell.menuActionDelegate = self;
            locationItemCell.replyItemDelegate = self;
            locationItemCell.selectItemDelegate = self;
            locationItemCell.reactionViewDelegate = self;
            return locationItemCell;
        }
            
        case ItemTypePeerLocation: {
            PeerLocationItem* peerLocationItem = (PeerLocationItem *)item;
            PeerLocationItemCell *peerLocationItemCell = (PeerLocationItemCell *)[self.tableView dequeueReusableCellWithIdentifier:PEER_LOCATION_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
            [peerLocationItemCell bindWithItem:peerLocationItem conversationViewController:self];
            peerLocationItemCell.transform = self.tableView.transform;
            peerLocationItemCell.locationActionDelegate = self;
            peerLocationItemCell.deleteActionDelegate = self;
            peerLocationItemCell.menuActionDelegate = self;
            peerLocationItemCell.replyItemDelegate = self;
            peerLocationItemCell.selectItemDelegate = self;
            peerLocationItemCell.reactionViewDelegate = self;
            return peerLocationItemCell;
        }
            
        case ItemTypeInvitation: {
            InvitationItem *invitationItem = (InvitationItem *)item;
            InvitationItemCell *invitationItemCell = (InvitationItemCell *)[self.tableView dequeueReusableCellWithIdentifier:INVITATION_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
            [invitationItemCell bindWithItem:invitationItem conversationViewController:self];
            invitationItemCell.transform = self.tableView.transform;
            invitationItemCell.deleteActionDelegate = self;
            invitationItemCell.groupActionDelegate = self;
            invitationItemCell.menuActionDelegate = self;
            invitationItemCell.selectItemDelegate = self;
            return invitationItemCell;
        }
            
        case ItemTypePeerInvitation: {
            PeerInvitationItem *peerInvitationItem = (PeerInvitationItem *)item;
            PeerInvitationItemCell *peerInvitationItemCell = (PeerInvitationItemCell *)[self.tableView dequeueReusableCellWithIdentifier:PEER_INVITATION_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
            [peerInvitationItemCell bindWithItem:peerInvitationItem conversationViewController:self];
            peerInvitationItemCell.transform = self.tableView.transform;
            peerInvitationItemCell.groupActionDelegate = self;
            peerInvitationItemCell.deleteActionDelegate = self;
            peerInvitationItemCell.menuActionDelegate = self;
            peerInvitationItemCell.selectItemDelegate = self;
            return peerInvitationItemCell;
        }
            
        case ItemTypeCall: {
            CallItem *callItem = (CallItem *)item;
            CallItemCell *callItemCell = (CallItemCell *)[self.tableView dequeueReusableCellWithIdentifier:CALL_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
            [callItemCell bindWithItem:callItem conversationViewController:self];
            callItemCell.transform = self.tableView.transform;
            callItemCell.deleteActionDelegate = self;
            callItemCell.callActionDelegate = self;
            callItemCell.menuActionDelegate = self;
            callItemCell.selectItemDelegate = self;
            return callItemCell;
        }
            
        case ItemTypePeerCall: {
            PeerCallItem *peerCallItem = (PeerCallItem *)item;
            PeerCallItemCell *peerCallItemCell = (PeerCallItemCell *)[self.tableView dequeueReusableCellWithIdentifier:PEER_CALL_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
            [peerCallItemCell bindWithItem:peerCallItem conversationViewController:self];
            peerCallItemCell.transform = self.tableView.transform;
            peerCallItemCell.callActionDelegate = self;
            peerCallItemCell.deleteActionDelegate = self;
            peerCallItemCell.menuActionDelegate = self;
            peerCallItemCell.selectItemDelegate = self;
            return peerCallItemCell;
        }
            
        case ItemTypeClear: {
            ClearItem *clearItem = (ClearItem *)item;
            ClearItemCell *clearItemCell = (ClearItemCell *)[self.tableView dequeueReusableCellWithIdentifier:CLEAR_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
            [clearItemCell bindWithItem:clearItem conversationViewController:self];
            clearItemCell.transform = self.tableView.transform;
            clearItemCell.deleteActionDelegate = self;
            clearItemCell.menuActionDelegate = self;
            clearItemCell.selectItemDelegate = self;
            return clearItemCell;
        }
            
        case ItemTypePeerClear: {
            PeerClearItem *peerClearItem = (PeerClearItem *)item;
            PeerClearItemCell *peerClearItemCell = (PeerClearItemCell *)[self.tableView dequeueReusableCellWithIdentifier:PEER_CLEAR_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
            [peerClearItemCell bindWithItem:peerClearItem conversationViewController:self];
            peerClearItemCell.transform = self.tableView.transform;
            peerClearItemCell.deleteActionDelegate = self;
            peerClearItemCell.menuActionDelegate = self;
            peerClearItemCell.selectItemDelegate = self;
            return peerClearItemCell;
        }
            
        case ItemTypeInvitationContact: {
            InvitationContactItem *invitationContactItem = (InvitationContactItem *)item;
            InvitationContactItemCell *invitationContactItemCell = (InvitationContactItemCell *)[self.tableView dequeueReusableCellWithIdentifier:INVITATION_CONTACT_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
            [invitationContactItemCell bindWithItem:invitationContactItem conversationViewController:self];
            invitationContactItemCell.transform = self.tableView.transform;
            invitationContactItemCell.deleteActionDelegate = self;
            invitationContactItemCell.menuActionDelegate = self;
            invitationContactItemCell.selectItemDelegate = self;
            return invitationContactItemCell;
        }
            
        case ItemTypePeerInvitationContact: {
            PeerInvitationContactItem *peerInvitationContactItem = (PeerInvitationContactItem *)item;
            PeerInvitationContactItemCell *peerInvitationContactItemCell = (PeerInvitationContactItemCell *)[self.tableView dequeueReusableCellWithIdentifier:PEER_INVITATION_CONTACT_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
            [peerInvitationContactItemCell bindWithItem:peerInvitationContactItem conversationViewController:self];
            peerInvitationContactItemCell.transform = self.tableView.transform;
            peerInvitationContactItemCell.twincodeActionDelegate = self;
            peerInvitationContactItemCell.deleteActionDelegate = self;
            peerInvitationContactItemCell.menuActionDelegate = self;
            peerInvitationContactItemCell.selectItemDelegate = self;
            return peerInvitationContactItemCell;
        }
            
        case ItemTypeName: {
            NameItem *nameItem = (NameItem *)item;
            NameItemCell *nameCell = (NameItemCell *)[self.tableView dequeueReusableCellWithIdentifier:NAME_ITEM_CELL_IDENTIFIER forIndexPath:indexPath];
            [nameCell bindWithItem:nameItem conversationViewController:self];
            nameCell.transform = self.tableView.transform;
            nameCell.menuActionDelegate = self;
            return nameCell;
        }
    }
    return [[UITableViewCell alloc]init];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ willDisplayCell: %@ forRowAtIndexPath: %@", LOG_TAG, tableView, cell, indexPath);
    
    // The view must be in the "Appearing" state to mark messages as read.
    if (self.items.count > 0 && self.viewAppearing) {
        NSUInteger index = [self.items count] - indexPath.row - 1;
        Item *item = [self.items objectAtIndex:index];
        
        switch (item.type) {
            case ItemTypePeerMessage:
            case ItemTypePeerLink:
            case ItemTypePeerImage:
            case ItemTypePeerInvitation:
            case ItemTypePeerInvitationContact:
            case ItemTypePeerLocation:
            case ItemTypePeerClear:
                if ([item needsUpdateReadTimestamp]) {
                    // Because willDisplayCell is called several times, mark the descriptor as read
                    // to avoid calling markDescriptorReadXXX again.  The final value will be set upon
                    // execution of the onMarkDescriptorReadXXX callback.
                    item.readTimestamp = 1;
                    [self.conversationService markDescriptorReadWithDescriptorId:item.descriptorId];
                }
                break;
                
            case ItemTypePeerCall:
            default:
                break;
        }
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    DDLogVerbose(@"%@ scrollViewDidScroll: %@", LOG_TAG, scrollView);
    
    [super scrollViewDidScroll:scrollView];
    
    if (self.selectItemMode || ![scrollView isEqual:self.tableView]) {
        return;
    }
    
    if ((scrollView.contentOffset.y > self.tableView.frame.size.height)) {
        if (self.scrollIndicatorView.hidden) {
            self.scrollIndicatorView.hidden = NO;
            [self updateScrollIndicator];
        }
    } else {
        self.scrollIndicatorCount = 0;
        [self updateScrollIndicator];
        self.scrollIndicatorView.hidden = YES;
    }
}

#pragma mark - SLKTextViewController

- (BOOL)forceTextInputbarAdjustmentForResponder:(UIResponder *)responder {
    DDLogVerbose(@"%@ forceTextInputbarAdjustmentForResponder: %@", LOG_TAG, responder);
    
    if ([responder isKindOfClass:[UIAlertController class]]) {
        return YES;
    }
    
    // On iOS 9, returning YES helps keeping the input view visible when the keyboard if presented from another app when using multi-tasking on iPad.
    return SLK_IS_IPAD;
}

- (void)didPressLeftButton:(UITapGestureRecognizer *)recognizer {
    DDLogVerbose(@"%@ didPressLeftButton", LOG_TAG);
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        [self hapticFeedback];
        
        [self setSelectedMode:ModeDefault];
        [self dismissKeyboard:YES];
        
        if (!self.menuActionConversationView) {
            TLSpaceSettings *spaceSettings = self.space.settings;
            if ([self.space.settings getBooleanWithName:PROPERTY_DEFAULT_MESSAGE_SETTINGS defaultValue:YES]) {
                spaceSettings = self.twinmeContext.defaultSpaceSettings;
            }
            self.menuActionConversationView = [[MenuActionConversationView alloc]initWithSpaceSettings:spaceSettings];
            self.menuActionConversationView.menuActionConversationDelegate = self;
            [self.navigationController.view addSubview:self.menuActionConversationView];
        }
        
        [self.menuActionConversationView openMenu];
    }
}

- (void)didCloseEditButton:(UITapGestureRecognizer *)recognizer {
    DDLogVerbose(@"%@ didPressLeftButton", LOG_TAG);
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        [self hapticFeedback];
        
        [self setSelectedMode:ModeDefault];
        [self dismissKeyboard:YES];
        
        self.editItem = nil;
        self.editingMessage = NO;
        self.editMessageView.hidden = YES;
        [self.menuButtonView editMode:self.editingMessage];
        [self.sendButtonView editMode:self.editingMessage];
        [self.textView slk_clearText:YES];
        
        [self updateSendButton:NO];
    }
}

- (void)didPressCameraButton:(UITapGestureRecognizer *)recognizer {
    DDLogVerbose(@"%@ didPressCameraButton", LOG_TAG);
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        [self hapticFeedback];
        [self dismissKeyboard:YES];
        [self openCamera];
    }
}

- (void)didPressRecordButton:(UITapGestureRecognizer *)recognizer {
    DDLogVerbose(@"%@ didPressRecordButton", LOG_TAG);
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        [self hapticFeedback];
        
        AVAudioSessionRecordPermission audioSessionRecordPermission = [DeviceAuthorization deviceMicrophonePermissionStatus];
        switch (audioSessionRecordPermission) {
            case AVAudioSessionRecordPermissionUndetermined: {
                [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
                    if (granted) {
                        dispatch_async(dispatch_get_main_queue(), ^(void) {
                            [self setSelectedMode:ModeAudioRecorder];
                            [self dismissKeyboard:YES];
                            [self.voiceMessageRecorderView startRecording];
                        });
                    }
                }];
                break;
            }
                
            case AVAudioSessionRecordPermissionDenied:
                [DeviceAuthorization showMicrophoneSettingsAlertInController:self];
                break;
                
            case AVAudioSessionRecordPermissionGranted:
                [self dismissKeyboard:YES];
                [self setSelectedMode:ModeAudioRecorder];
                [self.voiceMessageRecorderView startRecording];
                break;
        }
    }
}

- (void)didEditMessageButton:(UITapGestureRecognizer *)recognizer {
    DDLogVerbose(@"%@ didEditMessageButton", LOG_TAG);
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        [self hapticFeedback];
        
        if (self.editItem && [self.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0 ) {
            [self.conversationService updateDescriptorWithDescriptorId:self.editItem.descriptorId content:self.textView.text];
        }
        
        self.editItem = nil;
        self.editingMessage = NO;
        self.editMessageView.hidden = YES;
        [self.menuButtonView editMode:self.editingMessage];
        [self.sendButtonView editMode:self.editingMessage];
        
        if (self.shouldClearTextAtRightButtonPress) {
            // Clears the text and the undo manager
            [self.textView slk_clearText:YES];
            
            // Text is cleared, send a typing stop event.
            if (self.typingTimer) {
                [self typingFire:self.typingTimer];
            }
        }
        // Clears cache
        [self clearCachedText];
        
        [self updateSendButton:NO];
    }
}

- (void)didPressRightButton {
    DDLogVerbose(@"%@ didPressRightButton", LOG_TAG);
    
    [self hapticFeedback];
    
    TLSpaceSettings *spaceSettings = self.space.settings;
    if ([self.space.settings getBooleanWithName:PROPERTY_DEFAULT_MESSAGE_SETTINGS defaultValue:YES]) {
        spaceSettings = self.twinmeContext.defaultSpaceSettings;
    }

    BOOL sentSomething = NO;
    BOOL allowCopyText = spaceSettings.messageCopyAllowed;
    BOOL allowCopyFile = spaceSettings.fileCopyAllowed;
    BOOL allowEphemeral = [spaceSettings getBooleanWithName:PROPERTY_ALLOW_EPHEMERAL_MESSAGE defaultValue:NO];
    int64_t timeout = [[spaceSettings getStringWithName:PROPERTY_TIMEOUT_EPHEMERAL_MESSAGE defaultValue:[NSString stringWithFormat:@"%d", DEFAULT_TIMEOUT_MESSAGE]]integerValue];
    if (self.menuSendOptionsOpen) {
        allowCopyText = self.allowCopy;
        allowCopyFile = self.allowCopy;
        allowEphemeral = self.allowEphemeralMessage;
        timeout = self.expireTimeout;
    }
    
    if (!allowEphemeral) {
        timeout = 0;
    }
    
    NSUUID *sendTo = nil;
    TLDescriptorId *replyTo = nil;
    
    if (self.replyItem) {
        replyTo = self.replyItem.descriptorId;
    }
    
    if ([self.voiceMessageRecorderView isVoiceMessageToSend]) {
        [self.conversationService pushFileWithPath:self.voiceMessageRecorderView.url.path type:TLDescriptorTypeAudioDescriptor toBeDeleted:NO copyAllowed:allowCopyFile expiredTimeout:timeout sendTo:sendTo replyTo:replyTo];
        [self.voiceMessageRecorderView resetViews];
    }
    
    if ([self.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0 ) {
        sentSomething = YES;
        [self.conversationService pushMessage:self.textView.text copyAllowed:allowCopyText expiredTimeout:timeout sendTo:sendTo replyTo:replyTo];
    }
    
    // When we send something and we are not connected, report a toast message to explain the network delay.
    if (sentSomething && ![self.twinmeContext isConnected]) {
        NSString *message;
        if ([[self.twinmeContext getConnectivityService] isConnectedNetwork]) {
            message = TwinmeLocalizedString(@"application_network_status_connected_no_internet", nil);
        } else {
            message = TwinmeLocalizedString(@"application_network_status_no_internet", nil);
        }
        [[UIApplication sharedApplication].keyWindow makeToast:message];
    }
    
    if (self.shouldClearTextAtRightButtonPress) {
        // Clears the text and the undo manager
        [self.textView slk_clearText:YES];
        
        // Text is cleared, send a typing stop event.
        if (self.typingTimer) {
            [self typingFire:self.typingTimer];
        }
    }
    // Clears cache
    [self clearCachedText];
    
    [self.selectedMedias removeAllObjects];
    
    [self.selectedFiles removeAllObjects];
    
    [self.collectionView reloadData];
    
    [self updateSendButton:NO];
    [self closeMenu];
    
    self.replyItem = nil;
    
    if (self.replyView) {
        self.replyView.hidden = YES;
        [self setupTableHeaderView];
    }
}

- (NSString *)keyForTextCaching {
    NSString *key = [[NSBundle mainBundle] bundleIdentifier];
    
    if (self.contact) {
        key = [key stringByAppendingString:self.contact.uuid.UUIDString];
    }
    
    return key;
}

- (void)slk_willShowOrHideKeyboard:(NSNotification *)notification {
    DDLogVerbose(@"%@ slk_willShowOrHideKeyboard: %@", LOG_TAG, notification);
    
    [super slk_willShowOrHideKeyboard:notification];
    
    NSDictionary *info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    if (self.keyboardHeight != keyboardSize.height) {
        self.keyboardHeight = keyboardSize.height;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.selectedMode == ModeAudioRecorder) {
                [self setupRecordSoundView];
            }
        });
        [self.twinmeApplication setDefaultKeyboardHeight:self.keyboardHeight];
    }
        
    BOOL hideKeyboard = NO;
    if (self.selectedMode == ModeDefault || self.selectedMode == ModeAudioRecorder) {
        hideKeyboard = YES;
    }
        
    if (self.textInputbar.toolbarView && [self.textInputbar.toolbarView isKindOfClass:[BottomConversationView class]]) {
        BottomConversationView *bottomConversationView = (BottomConversationView *)self.textInputbar.toolbarView;
        [bottomConversationView updateToolbarHeight:hideKeyboard];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self textDidUpdate:NO];
        
        if (hideKeyboard) {
            if (self.items.count == 1) {
                self.emptyConversationLabel.hidden = NO;
            } else {
                self.emptyConversationLabel.hidden = YES;
            }
        } else {
            self.emptyConversationLabel.hidden = YES;
        }
        
        if (self.replyView) {
            CGRect replyViewFrame = self.replyView.frame;
            replyViewFrame.origin.y = self.textInputbar.frame.origin.y - self.replyView.frame.size.height;
            self.replyView.frame = replyViewFrame;
        }
        
        if (self.voiceMessageRecorderView) {
            CGRect replyViewFrame = self.voiceMessageRecorderView.frame;
            replyViewFrame.origin.y = self.textInputbar.frame.origin.y;
            self.voiceMessageRecorderView.frame = replyViewFrame;
        }
        
        if (!self.scrollIndicatorView.hidden) {
            [self updateScrollIndicator];
        }
        
        self.zoomLevelViewBottomConstraint.constant = self.view.frame.size.height - self.textInputbar.frame.origin.y;
        
        [self updateSendButton:YES];
    });
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification {
    DDLogVerbose(@"%@ keyboardWillChangeFrame: %@", LOG_TAG, notification);
    
    NSDictionary *info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    if (self.keyboardHeight != keyboardSize.height) {
        self.keyboardHeight = keyboardSize.height;
        [self.twinmeApplication setDefaultKeyboardHeight:self.keyboardHeight];
    }
}

- (void)didPasteStringContent:(NSString *)text {
    DDLogVerbose(@"%@ didPasteStringContent: %@", LOG_TAG, text);
    
    self.isPastedString = YES;
}

- (void)didPasteMediaContent:(NSDictionary *)userInfo {
    DDLogVerbose(@"%@ didPasteMediaContent: %@", LOG_TAG, userInfo);
    
    NSMutableArray *pasteMedia = [[NSMutableArray alloc]init];
    if ([[UIPasteboard generalPasteboard]hasImages] && [[UIPasteboard generalPasteboard]images].count > 1) {
        NSArray *images = [[UIPasteboard generalPasteboard]images];
        
        for (UIImage *image in images) {
            
            NSData *data = UIImageJPEGRepresentation(image, 1.0);
            NSString *fileName = [NSString stringWithFormat:@"%@_%@", [[NSProcessInfo processInfo] globallyUniqueString], @".jpg"];
            
            NSURL *url = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:fileName]];
                        
            [data writeToURL:url options:NSDataWritingAtomic error:nil];
            
            UIPreviewMedia *previewMedia = [[UIPreviewMedia alloc]initWithUrl:url path:url.path size:image.size isVideo:NO];
            [pasteMedia addObject:previewMedia];
        }
    } else {
        NSData *data = [userInfo objectForKey:SLKTextViewPastedItemData];
        SLKPastableMediaType type = [[userInfo objectForKey:SLKTextViewPastedItemMediaType] intValue];
        
        NSString *extension = @".jpg";
        BOOL isVideo = NO;
        if (type == SLKPastableMediaTypePNG) {
            extension = @".png";
        } else if (type == SLKPastableMediaTypeTIFF) {
            extension = @".tiff";
        } else if (type == SLKPastableMediaTypeGIF) {
            extension = @".gif";
        } else if (type == SLKPastableMediaTypeMOV) {
            extension = @".mov";
            isVideo = YES;
        }
        
        NSString *fileName = [NSString stringWithFormat:@"%@_%@", [[NSProcessInfo processInfo] globallyUniqueString], extension];
        NSURL *url = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:fileName]];
        [data writeToURL:url options:NSDataWritingAtomic error:nil];
        
        UIPreviewMedia *previewMedia = [[UIPreviewMedia alloc]initWithUrl:url path:url.path size:CGSizeZero isVideo:isVideo];
        [pasteMedia addObject:previewMedia];
    }
    
    [self dismissKeyboard:NO];
    [self setSelectedMode:ModeDefault];
        
    PreviewFilesViewController *previewFilesViewController = (PreviewFilesViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"PreviewFilesViewController"];
    previewFilesViewController.previewViewDelegate = self;

    BOOL certified = NO;
    if (!self.group && self.contact) {
        TLContact *contact = (TLContact *)self.contact;
        if (contact.certificationLevel == TLCertificationLevel4) {
            certified = YES;
        }
    }
    
    [previewFilesViewController initWithName:self.contactName avatar:self.contactAvatar certified:certified message:self.textView.text];
    [previewFilesViewController initWithPreviewMedia:pasteMedia errorPicking:self.errorMediaPicking];
    
    [self presentViewController:previewFilesViewController animated:YES completion:^{
    }];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    DDLogVerbose(@"%@ textViewDidBeginEditing: %@", LOG_TAG, textView);
    
    [self setSelectedMode:ModeText];
}

- (void)textViewDidChange:(UITextView *)textView {
    DDLogVerbose(@"%@ textViewDidChange", LOG_TAG);
    
    [self updateSendButton:NO];
    
    int64_t now = [[NSDate date] timeIntervalSince1970];
    NSString *text = self.textView.text;
    if (![text isEqualToString:@""] && (!self.isTyping || self.typingSendTime + TYPING_RESEND_DELAY < now)) {
        self.isTyping = YES;
        self.typingSendTime = now;
        TLTyping *typing = [[TLTyping alloc]initWithAction:TLTypingActionStart];
        [self.conversationService pushTyping:typing];
    } else if ([text isEqualToString:@""] && self.isTyping) {
        self.isTyping = NO;
        TLTyping *typing = [[TLTyping alloc]initWithAction:TLTypingActionStop];
        [self.conversationService pushTyping:typing];
        if (self.typingTimer) {
            [self.typingTimer invalidate];
            self.typingTimer = nil;
        }
    }
    
    // To the Emoji conversion but change the textView only if some conversion was made
    // otherwise it breaks entering text with pinyin keyboards.
    NSString *convertedText = [NSString convertEmoji:text];
    if (![text isEqual:convertedText]) {
        self.textView.text = convertedText;
    }
    
    if (![text isEqualToString:@""] && self.isTyping) {
        if (self.typingTimer) {
            [self.typingTimer invalidate];
        }
        self.typingTimer = [NSTimer scheduledTimerWithTimeInterval:TYPING_TIMER_DURATION target:self selector:@selector(typingFire:) userInfo:nil repeats:NO];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    DDLogVerbose(@"%@ textViewDidEndEditing: %@", LOG_TAG, textView);
    
    if (self.isTyping) {
        self.isTyping = NO;
        TLTyping *typing = [[TLTyping alloc]initWithAction:TLTypingActionStop];
        [self.conversationService pushTyping:typing];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    DDLogVerbose(@"%@ textView: %@ shouldChangeTextInRange: %lu-%lu replacementText: %@", LOG_TAG, textView, (unsigned long)range.location, (unsigned long)range.length, text);
    
    if (self.isPastedString) {
        self.isPastedString = NO;
        if ([self.selectedMedias count] == 0 && [self.selectedFiles count] == 0  && [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
            [self.sendButtonView setEnabled:NO];
        } else {
            [self.sendButtonView setEnabled:YES];
            self.textViewRightView.hidden = YES;
        }
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if (self.replyView) {
            CGRect replyViewFrame = self.replyView.frame;
            replyViewFrame.origin.y = self.textInputbar.frame.origin.y - self.replyView.frame.size.height;
            self.replyView.frame = replyViewFrame;
        }
    });
    
    return [super textView:textView shouldChangeTextInRange:range replacementText:text];
}

#pragma mark - Keyboard notifications

- (void)keyboardDidChangeLanguage:(NSNotification *)notification {
    DDLogVerbose(@"%@ keyboardDidChangeLanguage: %@", LOG_TAG, notification);
    
    NSDictionary *info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    if (self.keyboardHeight != keyboardSize.height && keyboardSize.height != 0) {
        self.keyboardHeight = keyboardSize.height;
        [self.twinmeApplication setDefaultKeyboardHeight:keyboardSize.height];
    }
}

#pragma mark - Invitation Link notifications

- (void)didSelectLinkWithInvitationURL:(NSNotification *)notification {
    DDLogVerbose(@"%@ didSelectLinkWithInvitationURL: %@", LOG_TAG, notification);
    
    NSURL *url = (NSURL *)notification.object;
    
    [self.conversationService parseUriWithUri:url withBlock:^(TLBaseServiceErrorCode errorCode, TLTwincodeURI *uri) {
        if (errorCode != TLBaseServiceErrorCodeSuccess) {
            return;
        }
        [self didCaptureUrl:url twincodeUri:uri];
    }];
}

- (void)didCaptureUrl:(nonnull NSURL *)url twincodeUri:(nonnull TLTwincodeURI *)twincodeUri {
    DDLogVerbose(@"%@ didCaptureUrl: %@ twincodeUri: %@", LOG_TAG, url, twincodeUri);
    
    if (twincodeUri.kind == TLTwincodeURIKindInvitation) {
        if (twincodeUri.twincodeOptions) {
            AcceptInvitationSubscriptionViewController *acceptInvitationSubscriptionViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AcceptInvitationSubscriptionViewController"];
            acceptInvitationSubscriptionViewController.acceptInvitationSubscriptionDelegate = self;
            [acceptInvitationSubscriptionViewController initWithPeerTwincodeOutboundId:twincodeUri.twincodeId activationCode:twincodeUri.twincodeOptions];
            [acceptInvitationSubscriptionViewController showInView:self.navigationController.view];
        } else {
            AcceptInvitationViewController *acceptInvitationViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AcceptInvitationViewController"];
            [acceptInvitationViewController initWithProfile:nil url:url descriptorId:nil originatorId:nil isGroup:NO notification:nil popToRootViewController:NO];
            [acceptInvitationViewController showInView:self.navigationController.view];
        }
    }
}

#pragma mark - AcceptInvitationSubscriptionDelegate Methods

- (void)invitationSubscriptionDidFinish:(TLBaseServiceErrorCode)errorCode  {
    DDLogVerbose(@"%@ invitationDidFinish: %u", LOG_TAG, errorCode);

    if (errorCode != TLBaseServiceErrorCodeSuccess) {
        NSString *errorMessage;
        if (errorCode == TLBaseServiceErrorCodeExpired) {
            errorMessage = TwinmeLocalizedString(@"in_app_subscription_view_controller_expired_code", nil);
        } else if (errorCode == TLBaseServiceErrorCodeLimitReached) {
            errorMessage = TwinmeLocalizedString(@"in_app_subscription_view_controller_used_code", nil);
        } else {
            errorMessage = TwinmeLocalizedString(@"in_app_subscription_view_controller_invalid_code", nil);
        }
        
        AlertMessageView *alertMessageView = [[AlertMessageView alloc] init];
        alertMessageView.alertMessageViewDelegate = self;
        [alertMessageView initWithTitle:TwinmeLocalizedString(@"delete_account_view_controller_warning", nil) message:errorMessage];
        [self.view addSubview:alertMessageView];
        [alertMessageView showAlertView];
    }
}

- (void)invitationSubscriptionDidCancel {
    DDLogVerbose(@"%@ invitationSubscriptionDidCancel", LOG_TAG);
    
}

#pragma mark - Toolbar

- (void)handleSendButtonViewLongPress:(UITapGestureRecognizer *)recognizer {
    DDLogVerbose(@"%@ handleSendButtonViewLongPress: %@", LOG_TAG, recognizer);
    
    [self openMenuSendOptions];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    DDLogVerbose(@"%@ gestureRecognizerShouldBegin: %@", LOG_TAG, gestureRecognizer);
    
    if (![gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        if (self.selectedMode != ModeAudioRecorder) {
            [self setSelectedMode:ModeDefault];
        }
    }
    
    return [super gestureRecognizerShouldBegin:gestureRecognizer];
}

#pragma mark - Async Loader

- (void)onLoadedWithItems:(nonnull NSMutableArray<id<NSObject>> *)items {
    DDLogVerbose(@"%@ onLoadedWithItems: %@", LOG_TAG, items);
    
    BOOL needsUpdate = NO;
    for (NSInteger index = self.items.count - 1; index >= 0; index--) {
        Item *item = [self.items objectAtIndex:index];
        
        if ([items containsObject:item]) {
            [items removeObject:item];
            
            ItemCell *itemCell = (ItemCell *)[self.tableView cellForRowAtIndexPath:[self itemIndexToIndexPath:index]];
            
            // Make sure our item matches the cell otherwise we could be updating a message cell with an image
            // (there is an inconsistency between self.items and cellForRowAtIndexPath/indexPathForRow).
            if (itemCell && itemCell.item == item) {
                switch (item.type) {
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
                        [itemCell bindWithItem:item conversationViewController:self asyncManager:self.asyncLoaderManager];
                        break;
                    }
                        
                    default:
                        [itemCell bindWithItem:item conversationViewController:self];
                        break;
                }
                
                if (item.type == ItemTypeLink || item.type == ItemTypePeerLink) {
                    needsUpdate = YES;
                }
            }
            if (items.count == 0) {
                if (needsUpdate) {
                    [self.tableView beginUpdates];
                    [self.tableView endUpdates];
                }
                return;
            }
        }
    }
}

#pragma mark - DocumentPickerDelegate

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray <NSURL *>*)urls {
    DDLogVerbose(@"%@ documentPicker: %@ didPickDocumentsAtURLs: %@", LOG_TAG, controller, urls);
    
    if (urls.count == 0) {
        return;
    }
    
    NSNumber *value = nil;
    NSURL *url = [urls firstObject];
    [url getResourceValue:&value forKey:NSURLIsPackageKey error:nil];
    if ([value boolValue]) {
        AlertMessageView *alertMessageView = [[AlertMessageView alloc] init];
        alertMessageView.alertMessageViewDelegate = self;
        [alertMessageView initWithTitle:TwinmeLocalizedString(@"delete_account_view_controller_warning", nil) message:TwinmeLocalizedString(@"conversation_view_controller_file_type_not_supported", nil)];
        [self.tabBarController.view addSubview:alertMessageView];
        [alertMessageView showAlertView];
        return;
    }
    
    if (controller.documentPickerMode == UIDocumentPickerModeImport) {
        PreviewFilesViewController *previewFileViewController = (PreviewFilesViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"PreviewFilesViewController"];
        previewFileViewController.previewViewDelegate = self;
        [previewFileViewController initWithPreviewFiles:urls];
        
        BOOL certified = NO;
        if (!self.group && self.contact) {
            TLContact *contact = (TLContact *)self.contact;
            if (contact.certificationLevel == TLCertificationLevel4) {
                certified = YES;
            }
        }
        
        [previewFileViewController initWithName:self.contactName avatar:self.contactAvatar certified:certified message:self.textView.text];
        
        [self presentViewController:previewFileViewController animated:YES completion:nil];
    } else if (controller.documentPickerMode == UIDocumentPickerModeExportToService) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication].keyWindow makeToast:TwinmeLocalizedString(@"conversation_view_controller_menu_item_view_save_message", nil)];
            [self closeMenu];
        });
    }
}

#pragma mark - DocumentInteractionControllerDelegate

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
    
    return self;
}

#pragma mark - ConfirmViewDelegate

- (void)didTapConfirm:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didTapConfirm: %@", LOG_TAG, abstractConfirmView);
    
    if ([abstractConfirmView isKindOfClass:[PremiumFeatureConfirmView class]]) {
        InAppSubscriptionViewController *inAppSubscriptionViewController = [[UIStoryboard storyboardWithName:@"iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"InAppSubscriptionViewController"];
        TwinmeNavigationController *navigationController = [[TwinmeNavigationController alloc]initWithRootViewController:inAppSubscriptionViewController];
        [self.navigationController presentViewController:navigationController animated:YES completion:nil];
    } else if ([abstractConfirmView isKindOfClass:[ResetConversationConfirmView class]]) {
        [self.conversationService resetConversation];
    } else if([abstractConfirmView isKindOfClass:[CallAgainConfirmView class]]) {
        if (self.callAgainDescriptor.isVideo) {
            [self handleVideoTapGesture:nil];
        } else {
            [self handleAudioTapGesture:nil];
        }
        [self setSelectedMode:ModeDefault];
    } else if([abstractConfirmView isKindOfClass:[DeleteConfirmView class]]) {
        [self deleteSelectedItems];
        [self handleCancelSelectModeTapGesture:nil];
    }
    
    [abstractConfirmView closeConfirmView];
}

- (void)didTapCancel:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didTapCancel: %@", LOG_TAG, abstractConfirmView);
    
    if([abstractConfirmView isKindOfClass:[DefaultConfirmView class]]) {
        [self.twinmeApplication setShowWarningEditMessageWithState:NO];
    } else if([abstractConfirmView isKindOfClass:[DeleteConfirmView class]]) {
        [self handleCancelSelectModeTapGesture:nil];
    }
     
    [abstractConfirmView closeConfirmView];
}

- (void)didClose:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didClose: %@", LOG_TAG, abstractConfirmView);
    
   if ([abstractConfirmView isKindOfClass:[DeleteConfirmView class]]) {
       [self handleCancelSelectModeTapGesture:nil];
   }
    
    [abstractConfirmView closeConfirmView];
}

- (void)didFinishCloseAnimation:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didFinishCloseAnimation: %@", LOG_TAG, abstractConfirmView);
    
    [abstractConfirmView removeFromSuperview];
}

#pragma mark - ReplyViewDelegate

- (void)closeReplyView {
    DDLogVerbose(@"%@ closeReplyView", LOG_TAG);
    
    self.replyView.hidden = YES;
    self.replyItem = nil;
    
    [self reloadData];
}

- (void)swipeToReplyToItem:(Item *)item {
    DDLogVerbose(@"%@ swipeToReplyToItem: %@", LOG_TAG, item);
    
    [Utils hapticFeedback:UIImpactFeedbackStyleHeavy hapticFeedbackMode:self.twinmeApplication.hapticFeedbackMode];
    
    self.selectedItem = item;
    [self.textView becomeFirstResponder];
    [self replyItemClick];
}

#pragma mark - ReplyItemDelegate

- (void)didSelectReplyTo:(TLDescriptorId *)replyTo{
    DDLogVerbose(@"%@ didSelectReplyTo: %@", LOG_TAG, replyTo);
    
    NSInteger selectItemIndex = -1;
    for (NSInteger index = self.items.count - 1; index >= 0; index--) {
        Item *item = [self.items objectAtIndex:index];
        if ([item.descriptorId isEqual:replyTo]) {
            selectItemIndex = index;
            break;
        }
    }
    
    if (selectItemIndex != -1) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSIndexPath *indexPath = [self itemIndexToIndexPath:selectItemIndex];
            if (indexPath.row < self.items.count) {
                [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
            }
        });
    }
}

#pragma mark - Record Sound

- (void)setupRecordSoundView {
    DDLogVerbose(@"%@ setupRecordSoundView", LOG_TAG);
    
    if (!self.voiceMessageRecorderView) {
        self.voiceMessageRecorderView = [[VoiceMessageRecorderView alloc] initWithFrame:CGRectMake(0, self.textInputbar.frame.origin.y, self.view.bounds.size.width, self.textInputbar.toolbarView.frame.size.height) conversationViewController:self];
        [self.view addSubview:self.voiceMessageRecorderView];
        
        CGFloat height = Design.FONT_REGULAR32.lineHeight + (DESIGN_HEIGHT_INSET * Design.HEIGHT_RATIO * 2);
        
        [self.voiceMessageRecorderView updateSendView:height trailing:(self.sendButtonView.frame.size.width - height) * 0.5f];
    }
    
    CGRect voiceRecorderViewFrame = self.voiceMessageRecorderView.frame;
    voiceRecorderViewFrame.origin.y = self.textInputbar.frame.origin.y;
    voiceRecorderViewFrame.size.height = self.textInputbar.toolbarView.frame.origin.y;
    self.voiceMessageRecorderView.frame = voiceRecorderViewFrame;
    
    [self.view bringSubviewToFront:self.voiceMessageRecorderView];
}

- (void)setupOverlayView {
    DDLogVerbose(@"%@ setupOverlayView", LOG_TAG);
    
    if (!self.headerOverlayView) {
        self.headerOverlayView = [UIView new];
        CGFloat headerOverlayHeight = self.headerView.frame.origin.y + self.headerView.frame.size.height;
        self.headerOverlayView.frame = CGRectMake(0, 0, Design.DISPLAY_WIDTH, headerOverlayHeight);
        self.headerOverlayView.backgroundColor = Design.BACKGROUND_COLOR_WHITE_OPACITY85;
        self.headerOverlayView.hidden = YES;
        self.headerOverlayView.userInteractionEnabled = YES;
        [self.view addSubview:self.headerOverlayView];
        
        UITapGestureRecognizer *tapHeaderOverlayGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(closeMenu)];
        [self.headerOverlayView addGestureRecognizer:tapHeaderOverlayGesture];
        
        UIWindow *window = UIApplication.sharedApplication.keyWindow;
        CGFloat safeAreaInset = Design.DISPLAY_HEIGHT - self.view.safeAreaLayoutGuide.layoutFrame.size.height - window.safeAreaInsets.bottom;
                
        self.navigationBarOverlayView = [UIView new];
        self.navigationBarOverlayView.frame = CGRectMake(0, 0, Design.DISPLAY_WIDTH, safeAreaInset);
        self.navigationBarOverlayView.backgroundColor = Design.BACKGROUND_COLOR_WHITE_OPACITY85;
        self.navigationBarOverlayView.hidden = YES;
        self.navigationBarOverlayView.userInteractionEnabled = YES;
        [self.navigationController.view addSubview:self.navigationBarOverlayView];
        
        UITapGestureRecognizer *tapNavBarOverlayGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(closeMenu)];
        [self.navigationBarOverlayView addGestureRecognizer:tapNavBarOverlayGesture];
        
        self.footerOverlayView = [UIView new];
        self.footerOverlayView.frame = CGRectMake(0, self.textInputbar.frame.origin.y, Design.DISPLAY_WIDTH, Design.DISPLAY_HEIGHT - self.textInputbar.frame.origin.y);
        self.footerOverlayView.backgroundColor = Design.BACKGROUND_COLOR_WHITE_OPACITY85;
        self.footerOverlayView.hidden = YES;
        self.footerOverlayView.userInteractionEnabled = YES;
        [self.view addSubview:self.footerOverlayView];
        
        UITapGestureRecognizer *tapFooterOverlayGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(closeMenu)];
        [self.footerOverlayView addGestureRecognizer:tapFooterOverlayGesture];
    }
}

- (void)setupTextRightView {
    DDLogVerbose(@"%@ setupTextRightView", LOG_TAG);
    
    if (!self.textViewRightView) {
        TLSpaceSettings *spaceSettings = self.space.settings;
        if ([self.space.settings getBooleanWithName:PROPERTY_DEFAULT_APPEARANCE_SETTINGS defaultValue:YES]) {
            spaceSettings = self.twinmeContext.defaultSpaceSettings;
        }
        
        CGFloat minHeight = (Design.FONT_REGULAR32.lineHeight + (DESIGN_HEIGHT_INSET * Design.HEIGHT_RATIO * 2));
        
        self.textViewRightView = [[TextViewRightView alloc]initWithFrame:CGRectMake(0, 0, minHeight * 2, minHeight)];
        self.textViewRightView.spaceSettings = spaceSettings;
        [self.textView addSubview:self.textViewRightView];
        
        UITapGestureRecognizer *cameraTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didPressCameraButton:)];
        [self.textViewRightView.cameraView addGestureRecognizer:cameraTapGestureRecognizer];
        self.textViewRightView.cameraView.accessibilityLabel = TwinmeLocalizedString(@"application_camera", nil);
        
        UITapGestureRecognizer *microTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didPressRecordButton:)];
        [self.textViewRightView.microView addGestureRecognizer:microTapGestureRecognizer];
        self.textViewRightView.microView.accessibilityLabel = TwinmeLocalizedString(@"conversation_view_controller_record_title", nil);
        
        [self updateSendButton:NO];
    }
}

- (void)setupTitleView {
    DDLogVerbose(@"%@ setupTitleView", LOG_TAG);
    
    if (!self.titleLabel) {
        CGFloat customTitleViewWidth = PROFILE_VIEW_WIDTH;
        CGFloat customTitleViewHeight = Design.STANDARD_NAVIGATION_BAR_HEIGHT;
        
        CGFloat titleLabelX = (customTitleViewHeight - Design.FONT_BOLD34.lineHeight) * 0.5;
        if (self.group) {
            titleLabelX = (customTitleViewHeight - Design.FONT_BOLD34.lineHeight - Design.FONT_REGULAR34.lineHeight) * 0.5;
            customTitleViewWidth = GROUP_VIEW_WIDTH;
        }
        
        UIView *customTitleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, customTitleViewWidth, customTitleViewHeight)];
        customTitleView.backgroundColor = [UIColor clearColor];
        
        self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(AVATAR_VIEW_HEIGHT + PROFILE_MARGIN, titleLabelX, customTitleViewWidth - AVATAR_VIEW_HEIGHT - PROFILE_MARGIN, Design.FONT_BOLD34.lineHeight)];
        self.titleLabel.semanticContentAttribute = UISemanticContentAttributeForceLeftToRight;
        
        self.titleLabel.textAlignment = NSTextAlignmentNatural;
        self.titleLabel.font = Design.FONT_BOLD34;
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.text = self.contactName;
        self.titleLabel.clipsToBounds = YES;
        self.titleLabel.numberOfLines = 1;
        
        self.subTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(AVATAR_VIEW_HEIGHT + PROFILE_MARGIN, titleLabelX + Design.FONT_BOLD34.lineHeight, customTitleViewWidth - AVATAR_VIEW_HEIGHT - PROFILE_MARGIN, Design.FONT_REGULAR34.lineHeight)];
        self.subTitleLabel.semanticContentAttribute = UISemanticContentAttributeForceLeftToRight;
        self.subTitleLabel.textAlignment = NSTextAlignmentNatural;
        self.subTitleLabel.font = Design.FONT_REGULAR24;
        self.subTitleLabel.textColor = [UIColor whiteColor];
        self.subTitleLabel.clipsToBounds = YES;
        self.subTitleLabel.numberOfLines = 1;
        
        self.avatarView = [[UIImageView alloc] initWithImage:self.contactAvatar];
        self.avatarView.semanticContentAttribute = UISemanticContentAttributeForceLeftToRight;
        self.avatarView.contentMode = UIViewContentModeScaleAspectFit;
        self.avatarView.frame = CGRectMake(0, (customTitleViewHeight - AVATAR_VIEW_HEIGHT) / 2 , AVATAR_VIEW_HEIGHT, AVATAR_VIEW_HEIGHT);
        
        self.avatarView.layer.cornerRadius = AVATAR_VIEW_HEIGHT / 2.0;
        self.avatarView.clipsToBounds = YES;
            
        if ([self.contactAvatar isEqual:[TLTwinmeAttributes DEFAULT_GROUP_AVATAR]]) {
            self.avatarView.backgroundColor = [UIColor whiteColor];
            self.avatarView.tintColor = [UIColor colorWithHexString:Design.DEFAULT_COLOR alpha:1.0];
        }
        
        CGFloat profileViewWidth = AVATAR_VIEW_HEIGHT + PROFILE_MARGIN + self.titleLabel.intrinsicContentSize.width;
        if (profileViewWidth > customTitleViewWidth) {
            profileViewWidth = customTitleViewWidth;
        }
        customTitleView.frame = CGRectMake(0, 0, profileViewWidth, customTitleViewHeight);
        [customTitleView addSubview:self.avatarView];
        [customTitleView addSubview:self.titleLabel];
        if (self.group) {
            [customTitleView addSubview:self.subTitleLabel];
        }
        
        if (!self.group && self.contact) {
            TLContact *contact = (TLContact *)self.contact;
            if (contact.certificationLevel == TLCertificationLevel4) {
                UIImageView *certifiedImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"AuthentifiedRelationWhiteIcon"]];
                certifiedImageView.frame = CGRectMake(AVATAR_VIEW_HEIGHT * 0.5, self.avatarView.center.y, AVATAR_VIEW_HEIGHT * 0.5, AVATAR_VIEW_HEIGHT * 0.5);
                [customTitleView addSubview:certifiedImageView];
            }
        }
        
        self.navigationItem.titleView = customTitleView;
        
        if (self.group) {
            self.titleLabel.text = self.group.name;
            self.subTitleLabel.text = TwinmeLocalizedString(@"conversation_view_controller_group_one_member", nil);
            self.navigationItem.rightBarButtonItems = nil;
        }
        
        self.cancelBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:TwinmeLocalizedString(@"application_cancel", nil) style:UIBarButtonItemStylePlain target:self action:@selector(handleCancelSelectModeTapGesture:)];
        [self.cancelBarButtonItem setTitleTextAttributes: @{NSFontAttributeName: Design.FONT_BOLD36, NSForegroundColorAttributeName: [UIColor whiteColor]} forState:UIControlStateNormal];
        [self.cancelBarButtonItem setTitleTextAttributes: @{NSFontAttributeName: Design.FONT_BOLD36, NSForegroundColorAttributeName: [UIColor colorWithWhite:1.0 alpha:0.5]} forState:UIControlStateDisabled];
        
        self.audioCallBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"AudioCallIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(handleAudioTapGesture:)];
        self.audioCallBarButtonItem.accessibilityLabel = TwinmeLocalizedString(@"conversation_view_controller_audio_call", nil);
        self.videoCallBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"VideoCallIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(handleVideoTapGesture:)];
        self.videoCallBarButtonItem.accessibilityLabel = TwinmeLocalizedString(@"conversation_view_controller_video_call", nil);
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.videoCallBarButtonItem, self.audioCallBarButtonItem, nil];
        
        UITapGestureRecognizer *titleGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTitleTapGesture:)];
        self.navigationItem.titleView.userInteractionEnabled = YES;
        [self.navigationItem.titleView addGestureRecognizer:titleGestureRecognizer];
    } else {

        if ([self.contactAvatar isEqual:[TLTwinmeAttributes DEFAULT_GROUP_AVATAR]]) {
            self.avatarView.backgroundColor = Design.GREY_ITEM;
        } else {
            self.avatarView.backgroundColor = [UIColor clearColor];
        }
        
        if (self.group) {
            self.titleLabel.text = self.group.name;
        } else {
            self.titleLabel.text = self.contactName;
        }
        
        [self updateNavigationBarAvatar];
    }
}

- (void)setupSelectedView {
    DDLogVerbose(@"%@ setupSelectedView", LOG_TAG);
    
    self.itemSelectedActionView = [[ItemSelectedActionView alloc]init];
    self.itemSelectedActionView.itemSelectedActionViewDelegate = self;
    [self.itemSelectedActionContainerView addSubview:self.itemSelectedActionView];
}

- (void)setupEditMessageView {
    DDLogVerbose(@"%@ setupEditMessageView", LOG_TAG);
    
    if (!self.editMessageView) {
        self.editMessageView = [[EditMessageView alloc] init];
        self.editMessageView.frame = CGRectMake(0, 0, DESIGN_EDIT_MESSAGE_VIEW_WIDTH * Design.WIDTH_RATIO + self.menuButtonView.frame.size.width, DESIGN_EDIT_MESSAGE_VIEW_HEIGHT * Design.HEIGHT_RATIO + self.textView.frame.origin.y);
        self.editMessageView.hidden = YES;
        [self.editMessageView updateLeading:self.menuButtonView.frame.size.width + (DESIGN_WIDTH_INSET * Design.WIDTH_RATIO) top:self.textView.frame.origin.y width:self.textView.frame.size.width - (DESIGN_WIDTH_INSET * Design.WIDTH_RATIO * 2)];
        [self.textInputbar addSubview:self.editMessageView];
    }
}

#pragma mark - DeleteActionDelegate

- (void)deleteItem:(Item *)item {
    DDLogVerbose(@"%@ deleteItem: %@", LOG_TAG, item);
    
    if (item && [self.items containsObject:item]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication].keyWindow makeToast:TwinmeLocalizedString(@"conversation_view_controller_delete_message",nil)];
        });
        
        [self deleteItemInternal:item];
        
        if (self.selectedItem.descriptorId == item.descriptorId && self.isMenuOpen) {
            [self closeMenu];
        }
    }
}

#pragma mark - AudioActionDelegate

- (void)readAudioDescriptor:(TLAudioDescriptor *)audioDescriptor {
    DDLogVerbose(@"%@ readAudioDescriptor: %@", LOG_TAG, audioDescriptor);
    
    for (Item *item in self.items) {
        if ([audioDescriptor.descriptorId isEqual:item.descriptorId]) {
            if ([item needsUpdateReadTimestamp]) {
                item.readTimestamp = 1;
                [self.conversationService markDescriptorReadWithDescriptorId:item.descriptorId];
            }
            break;
        }
    }
}

#pragma mark - ImageActionDelegate

- (void)fullscreenImageWithImageDescriptor:(TLImageDescriptor *)imageDescriptor thumbnail:(UIImage *)thumbnail isPeerItem:(BOOL)isPeerItem {
    DDLogVerbose(@"%@ fullscreenImageWithImageDescriptor: %@ thumbnail: %@ isPeerItem: %@", LOG_TAG, imageDescriptor, thumbnail, isPeerItem ? @"YES":@"NO");
    
    [self startFullScreenMediaViewController:imageDescriptor.descriptorId];
}

#pragma mark - VideoActionDelegate

- (void)fullscreenVideoWithVideoDescriptor:(TLVideoDescriptor *)videoDescriptor {
    DDLogVerbose(@"%@ fullscreenVideoWithVideoDescriptor: %@", LOG_TAG, videoDescriptor);
    
    [self startFullScreenMediaViewController:videoDescriptor.descriptorId];
}

#pragma mark - FileActionDelegate

- (void)openFileWithNamedFileDescriptor:(TLNamedFileDescriptor *)namedFileDescriptor {
    DDLogVerbose(@"%@ openFileWithNamedFileDescriptor: %@", LOG_TAG, namedFileDescriptor);
    
    for (Item *item in self.items) {
        if ([namedFileDescriptor.descriptorId isEqual:item.descriptorId]) {
            if ([item needsUpdateReadTimestamp]) {
                item.readTimestamp = 1;
                [self.conversationService markDescriptorReadWithDescriptorId:item.descriptorId];
            }
            break;
        }
    }
    
    FilePreviewViewController *filePreviewViewController = [[FilePreviewViewController alloc] init];
    filePreviewViewController.namedFileDescriptor = namedFileDescriptor;
    [self presentViewController:filePreviewViewController animated:YES completion:nil];
}

- (void)openFileWithNamedFileDescriptorNotFound {
    DDLogVerbose(@"%@ openFileWithNamedFileDescriptorNotFound", LOG_TAG);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication].keyWindow makeToast:TwinmeLocalizedString(@"conversation_view_controller_file_not_found", nil)];
    });
}

#pragma mark - LocationActionDelegate

- (void)fullscreenMapWithGeolocationDescriptor:(TLGeolocationDescriptor *)locationDescriptor avatar:(UIImage *)avatar {
    DDLogVerbose(@"%@ fullscreenMapWithGeolocationDescriptor: %@ avatar: %@", LOG_TAG, locationDescriptor, avatar);
    
    LocationViewController *locationViewController = (LocationViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"LocationViewController"];
    [locationViewController initWithAvatar:avatar descriptor:locationDescriptor];
    [self presentViewController:locationViewController animated:YES completion:nil];
}

- (void)saveMapWithPath:(NSString *)path geolocationDescriptor:(TLGeolocationDescriptor *)geolocationDescriptor {
    DDLogVerbose(@"%@ saveMapWithPath: %@ geolocationDescriptor: %@", LOG_TAG, path, geolocationDescriptor);
    
    if (self.viewAppearing) {
        [self.conversationService saveGeolocationMapWithPath:path descriptorId:geolocationDescriptor.descriptorId];
    }
}

#pragma mark - GroupActionDelegate

- (void)openGroupWithInvitationDescriptor:(TLInvitationDescriptor *)invitationDescriptor {
    DDLogVerbose(@"%@ openGroupWithInvitationDescriptor: %@", LOG_TAG, invitationDescriptor);
    
    if (invitationDescriptor.status == TLInvitationDescriptorStatusTypeJoined) {
        self.openGroupFromInvitation = YES;
        
        id<TLGroupConversation> conversation = [[self.twinmeContext getConversationService] getGroupConversationWithGroupTwincodeId:invitationDescriptor.groupTwincodeId];
        
        if (conversation && [conversation state] == TLGroupConversationStateJoined) {
            [self.groupService getGroupWithGroupId:conversation.contactId];
        }
    } else if ([self.conversationService isPeerDescriptor:invitationDescriptor]) {
        AcceptGroupInvitationViewController *acceptGroupInvitationViewController = (AcceptGroupInvitationViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"AcceptGroupInvitationViewController"];
        [acceptGroupInvitationViewController initWithInvitationId:invitationDescriptor.descriptorId contactId:self.contact.uuid];
        [acceptGroupInvitationViewController showInView:self.navigationController.view];
    }
}

#pragma mark - CallActionDelegate

- (void)recallWithCallDescriptor:(TLCallDescriptor *)callDescriptor {
    DDLogVerbose(@"%@ recallWithCallDescriptor: %@", LOG_TAG, callDescriptor);
    
    if (!self.twinmeApplication.inCall) {

        if ((callDescriptor.isVideo && !self.contact.capabilities.hasVideo) || (!callDescriptor.isVideo && !self.contact.capabilities.hasAudio)) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[UIApplication sharedApplication].keyWindow makeToast:TwinmeLocalizedString(@"application_not_authorized_operation_by_your_contact",nil)];
            });
        } else {
            self.callAgainDescriptor = callDescriptor;
            
            CallAgainConfirmView *callAgainConfirmView = [[CallAgainConfirmView alloc] init];
            callAgainConfirmView.confirmViewDelegate = self;
            
            NSString *message = TwinmeLocalizedString(@"conversation_view_controller_audio_call", nil);
            UIImage *icon = [UIImage imageNamed:@"AudioCall"];
            if (self.callAgainDescriptor.isVideo) {
                message = TwinmeLocalizedString(@"conversation_view_controller_video_call", nil);
                icon = [UIImage imageNamed:@"VideoCall"];
            }
            
            [callAgainConfirmView initWithTitle:self.contactName message:message avatar:self.contactAvatar icon:icon];
            
            [self.tabBarController.view addSubview:callAgainConfirmView];
            [callAgainConfirmView showConfirmView];
        }
    }
}

#pragma mark - TwincodeActionDelegate

- (void)openTwincodeDescriptor:(TLTwincodeDescriptor *)twincodeDescriptor {
    DDLogVerbose(@"%@ openTwincodeDescriptor: %@", LOG_TAG, twincodeDescriptor);
    
    AcceptInvitationViewController *acceptInvitationViewController = (AcceptInvitationViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"AcceptInvitationViewController"];
    if (self.group) {
        [acceptInvitationViewController initWithProfile:nil url:nil descriptorId:twincodeDescriptor.descriptorId  originatorId:self.group.uuid isGroup:YES notification:nil popToRootViewController:NO];
    } else {
        [acceptInvitationViewController initWithProfile:nil url:nil descriptorId:twincodeDescriptor.descriptorId  originatorId:self.contact.uuid isGroup:NO notification:nil popToRootViewController:NO];
    }
    [acceptInvitationViewController showInView:self.navigationController.view];
}

#pragma mark - LinkActionDelegate

- (void)openLinkWithURL:(NSURL *)url {
    DDLogVerbose(@"%@ openLinkWithURL: %@", LOG_TAG, url);
    
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
}

#pragma mark - MenuActionDelegate

- (void)openMenu:(Item *)item {
    DDLogVerbose(@"%@ openMenu: %@", LOG_TAG, item);
    
    if (self.menuOpen || item.state == ItemStateBothDeleted || self.selectItemMode) {
        return;
    }
        
    [Utils hapticFeedback:UIImpactFeedbackStyleHeavy hapticFeedbackMode:self.twinmeApplication.hapticFeedbackMode];
    
    NSInteger itemIndex = -1;
    for (NSInteger index = self.items.count - 1; index >= 0; index--) {
        Item *lItem = [self.items objectAtIndex:index];
        if ([lItem.descriptorId isEqual:item.descriptorId]) {
            itemIndex = index;
            break;
        }
    }
    
    if (itemIndex != -1) {
        [self setSelectedMode:ModeDefault];
        
        self.scrollView.scrollEnabled = NO;
        self.tableView.scrollEnabled = NO;
        
        self.selectedItem = item;
        
        MenuType menuType;
        
        BOOL addReaction = NO;
        
        switch (self.selectedItem.type) {
            case ItemTypeMessage:
            case ItemTypePeerMessage:
            case ItemTypeLink:
            case ItemTypePeerLink:
                menuType = MenuTypeText;
                addReaction = YES;
                break;
            case ItemTypeImage:
            case ItemTypePeerImage:
                menuType = MenuTypeImage;
                addReaction = YES;
                break;
            case ItemTypeAudio:
            case ItemTypePeerAudio:
                menuType = MenuTypeAudio;
                addReaction = YES;
                break;
            case ItemTypeVideo:
            case ItemTypePeerVideo:
                menuType = MenuTypeVideo;
                addReaction = YES;
                break;
            case ItemTypeFile:
            case ItemTypePeerFile:
                menuType = MenuTypeFile;
                addReaction = YES;
                break;
            case ItemTypeInvitation:
            case ItemTypePeerInvitation:
            case ItemTypeInvitationContact:
            case ItemTypePeerInvitationContact:
                menuType = MenuTypeInvitation;
                break;
            case ItemTypeCall:
            case ItemTypePeerCall:
                menuType = MenuTypeCall;
                break;

            case ItemTypeLocation:
            case ItemTypePeerLocation:
                menuType = MenuTypeLocation;
                addReaction = YES;
                break;

            case ItemTypeClear:
            case ItemTypePeerClear:
                menuType = MenuTypeCall;
                break;
            default:
                menuType = MenuTypeText;
                break;
        }
        
        if (self.selectedItem.state == ItemStateDeleted) {
            addReaction = NO;
        }
        
        [self.menuItemView openMenu:self.selectedItem menuType:menuType];
        self.menuItemView.hidden = NO;
        [self.view bringSubviewToFront:self.menuItemView];
        
        if (addReaction) {
            [self.menuReactionView openMenu:self.selectedItem.isPeerItem];
            self.menuReactionView.hidden = NO;
            [self.view bringSubviewToFront:self.menuReactionView];
        }
        
        self.navigationBarOverlayView.hidden = NO;
        self.headerOverlayView.hidden = NO;
        self.footerOverlayView.hidden = NO;
        CGFloat headerOverlayHeight = self.headerView.frame.origin.y + self.headerView.frame.size.height;
        self.headerOverlayView.frame = CGRectMake(0, 0, Design.DISPLAY_WIDTH, headerOverlayHeight);
        self.menuOpen = YES;
        
        [self.replyView showOverlayView];
        self.scrollIndicatorOverlayView.hidden = NO;
                
        CGRect rectItem = [self.tableView rectForRowAtIndexPath:[self itemIndexToIndexPath:itemIndex]];
        rectItem = CGRectOffset(rectItem, -self.tableView.contentOffset.x, -self.tableView.contentOffset.y);
        
        CGRect rectMenu = self.menuItemView.frame;
        CGFloat menuOriginY = self.textInputbar.frame.origin.y - rectItem.origin.y;
        
        BOOL initialPosition = YES;
        if (menuOriginY + self.menuItemView.frame.size.height > self.tableView.frame.size.height) {
            initialPosition = NO;
            menuOriginY = menuOriginY - rectItem.size.height - self.menuItemView.frame.size.height;
            if (menuOriginY < self.safeAreaView.frame.size.height) {
                menuOriginY = (self.tableView.frame.size.height - self.menuItemView.frame.size.height)  / 2;
            }
        }
        
        rectMenu.origin.y = menuOriginY;
        self.menuItemView.frame = rectMenu;
        
        CGRect rectMenuReaction = self.menuReactionView.frame;
        
        if (initialPosition) {
            menuOriginY = menuOriginY - rectItem.size.height - self.menuReactionView.frame.size.height;
            if (menuOriginY < self.safeAreaView.frame.size.height) {
                menuOriginY = (self.tableView.frame.size.height - self.menuReactionView.frame.size.height)  / 2;
            }
        } else {
            menuOriginY = self.textInputbar.frame.origin.y - rectItem.origin.y;
        }
        
        if (menuOriginY < (rectMenu.origin.y + rectMenu.size.height) && menuOriginY > rectMenu.origin.y) {
            menuOriginY = rectMenu.origin.y + rectMenu.size.height;
        } else if (menuOriginY > self.textInputbar.frame.origin.y) {
            menuOriginY = self.textInputbar.frame.origin.y + self.bottomMargin2;
        }
        
        rectMenuReaction.origin.y = menuOriginY;
        self.menuReactionView.frame = rectMenuReaction;
        
        for (UITableViewCell *cell in self.tableView.visibleCells) {
            if ([cell isKindOfClass:[TimeItemCell class]]) {
                TimeItemCell *itemCell = (TimeItemCell *)cell;
                [itemCell bindWithItem:itemCell.item conversationViewController:self];
            } else if ([cell isKindOfClass:[NameItemCell class]]) {
                NameItemCell *itemCell = (NameItemCell *)cell;
                [itemCell bindWithItem:itemCell.item conversationViewController:self];
            } else if ([cell isKindOfClass:[InfoPrivacyCell class]]) {
                InfoPrivacyCell *itemCell = (InfoPrivacyCell *)cell;
                [itemCell bindWithItem:itemCell.item conversationViewController:self];
            } else {
                ItemCell *itemCell = (ItemCell *)cell;
                switch (itemCell.item.type) {
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
                        [itemCell bindWithItem:itemCell.item conversationViewController:self asyncManager:self.asyncLoaderManager];
                        break;
                    }
                        
                    default:
                        [itemCell bindWithItem:itemCell.item conversationViewController:self];
                        break;
                }
            }
        }
    }
}

- (void)closeMenu {
    DDLogVerbose(@"%@ closeMenu", LOG_TAG);
    
    if (self.menuOpen) {
        self.menuReactionView.hidden = YES;
        self.menuItemView.hidden = YES;
        self.navigationBarOverlayView.hidden = YES;
        self.headerOverlayView.hidden = YES;
        self.footerOverlayView.hidden = YES;
        [self.replyView hideOverlayView];
        self.scrollIndicatorOverlayView.hidden = YES;
        self.menuOpen = NO;
        self.selectedItem = nil;
        [self updateTableViewBackgroundColor];
        
        for (UITableViewCell *cell in self.tableView.visibleCells) {
            if ([cell isKindOfClass:[TimeItemCell class]]) {
                TimeItemCell *itemCell = (TimeItemCell *)cell;
                [itemCell bindWithItem:itemCell.item conversationViewController:self];
            } else if ([cell isKindOfClass:[NameItemCell class]]) {
                NameItemCell *itemCell = (NameItemCell *)cell;
                [itemCell bindWithItem:itemCell.item conversationViewController:self];
            } else if ([cell isKindOfClass:[InfoPrivacyCell class]]) {
                InfoPrivacyCell *itemCell = (InfoPrivacyCell *)cell;
                [itemCell bindWithItem:itemCell.item conversationViewController:self];
            } else {
                ItemCell *itemCell = (ItemCell *)cell;
                switch (itemCell.item.type) {
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
                        [itemCell bindWithItem:itemCell.item conversationViewController:self asyncManager:self.asyncLoaderManager];
                        break;
                    }
                        
                    default:
                        [itemCell bindWithItem:itemCell.item conversationViewController:self];
                        break;
                }
            }
        }
        
        self.scrollView.scrollEnabled = YES;
        self.tableView.scrollEnabled = YES;
    }
}

#pragma mark - Menus

- (void)openMenuSendOptions {
    DDLogVerbose(@"%@ openMenuSendOptions", LOG_TAG);
    
    [self hapticFeedback];
    
    if (!self.menuSendOptionsOpen && (self.sendButtonView.isEnabled || (self.voiceMessageRecorderView && [self.voiceMessageRecorderView isVoiceMessageToSend]))) {
        if ([self.textView isFirstResponder]) {
            [self.textView resignFirstResponder];
        }
        
        MenuSendOptionsView *menuSendOptionsView = [[MenuSendOptionsView alloc] init];
        menuSendOptionsView.menuSendOptionsDelegate = self;
        [self.navigationController.view addSubview:menuSendOptionsView];
        
        self.menuSendOptionsOpen = YES;
        self.allowCopy = NO;
        
        TLSpaceSettings *spaceSettings = self.space.settings;
        if ([self.space.settings getBooleanWithName:PROPERTY_DEFAULT_MESSAGE_SETTINGS defaultValue:YES]) {
            spaceSettings = self.twinmeContext.defaultSpaceSettings;
        }
        
        BOOL allowCopyText = spaceSettings.messageCopyAllowed;
        BOOL allowCopyFile = spaceSettings.fileCopyAllowed;
        BOOL allowEphemeral = [spaceSettings getBooleanWithName:PROPERTY_ALLOW_EPHEMERAL_MESSAGE defaultValue:NO];
        
        BOOL isFileToSend = NO;
        BOOL isTextToSend = NO;
        
        if ([self.selectedMedias count] > 0 || [self.self.selectedFiles count] > 0 || (self.voiceMessageRecorderView && [self.voiceMessageRecorderView isVoiceMessageToSend])) {
            isFileToSend = YES;
        }
        if ([self.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0) {
            isTextToSend = YES;
        }
        
        if (isFileToSend && isTextToSend) {
            if (allowCopyText || allowCopyFile) {
                self.allowCopy = YES;
            }
        } else if (isFileToSend) {
            self.allowCopy = allowCopyFile;
        } else if (isTextToSend) {
            self.allowCopy = allowCopyText;
        }
        
        self.allowEphemeralMessage = allowEphemeral;
        
        int64_t timeout = [[spaceSettings getStringWithName:PROPERTY_TIMEOUT_EPHEMERAL_MESSAGE defaultValue:[NSString stringWithFormat:@"%d", DEFAULT_TIMEOUT_MESSAGE]] integerValue];
        self.expireTimeout = timeout;
        [menuSendOptionsView openMenu:self.allowCopy allowEphemeralMessage:allowEphemeral timeout:timeout];
    }
}

#pragma mark - ReactionActionDelegate

- (void)openAnnotationViewWithDescriptorId:(TLDescriptorId *)descriptorId {
    DDLogVerbose(@"%@ didTapReaction: %@", LOG_TAG, descriptorId);
    
    if (self.selectItemMode) {
        return;
    }
    
    [self.conversationService listAnnotationsWithDescriptorId:descriptorId withBlock:^(NSMutableDictionary<NSUUID *, TLDescriptorAnnotationPair *>* annotations) {
        NSMutableArray<UIAnnotation *> *uiAnnotationList = [[NSMutableArray alloc] initWithCapacity:annotations.count];
        
        for (NSUUID *uuid in annotations.allKeys) {
            TLDescriptorAnnotationPair *descriptorAnnotation = [annotations objectForKey:uuid];
            if (descriptorAnnotation.annotation.type == TLDescriptorAnnotationTypeLike) {
                UIReaction *uiReaction = [[UIReaction alloc]initWithDescriptorAnnotationValue:descriptorAnnotation.annotation.value];
                NSString *name = descriptorAnnotation.twincodeOutbound.name;
                UIImage *avatar = [self.conversationService getImageWithTwincode:descriptorAnnotation.twincodeOutbound];
                
                UIAnnotation *uiAnnotation = [[UIAnnotation alloc]initWithReaction:uiReaction name:name avatar:avatar];
                [uiAnnotationList addObject:uiAnnotation];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self openAnnotationsView:uiAnnotationList];
        });
    }];
}

- (void)openAnnotationsView:(NSMutableArray *)arrayAnnotations {
    DDLogVerbose(@"%@ openAnnotationsView", LOG_TAG);
    
    AnnotationsView *annotationsView = [[AnnotationsView alloc] init];
    annotationsView.annotationsViewDelegate = self;
    [self.navigationController.view addSubview:annotationsView];
    [annotationsView openMenu:arrayAnnotations];
}

#pragma mark - AnnotationsViewDelegate

- (void)cancelAnnotationView:(AnnotationsView *)annotationsView {
    DDLogVerbose(@"%@ cancelAnnotationView", LOG_TAG);
    
    [annotationsView removeFromSuperview];
}

#pragma mark - MenuItemDelegate

- (void)copyItemClick {
    DDLogVerbose(@"%@ copyItemClick", LOG_TAG);
    
    if (self.selectedItem) {
        if ([self.selectedItem isClearLocalItem]) {
            [[UIApplication sharedApplication].keyWindow makeToast:TwinmeLocalizedString(@"conversation_view_controller_local_cleanup", nil)];
            return;
        } else if (self.selectedItem.state == ItemStateDeleted || (self.selectedItem.isPeerItem && (!self.selectedItem.copyAllowed || self.selectedItem.isEphemeralItem))) {
            [[UIApplication sharedApplication].keyWindow makeToast:TwinmeLocalizedString(@"conversation_view_controller_menu_item_view_operation_not_allowed", nil)];
            return;
        } else if (!self.selectedItem.isAvailableItem) {
            return;
        }
        
        NSString *content = @"";
        if (self.selectedItem.type == ItemTypeMessage) {
            MessageItem *messageItem = (MessageItem *) self.selectedItem;
            content = messageItem.content;
        } else if(self.selectedItem.type == ItemTypePeerMessage) {
            PeerMessageItem *peerMessageItem = (PeerMessageItem *) self.selectedItem;
            content = peerMessageItem.content;
        } else if (self.selectedItem.type == ItemTypeLink) {
            LinkItem *linkItem = (LinkItem *) self.selectedItem;
            content = linkItem.content;
        } else if(self.selectedItem.type == ItemTypePeerLink) {
            PeerLinkItem *peerLinkItem = (PeerLinkItem *) self.selectedItem;
            content = peerLinkItem.content;
        }
        
        [[UIPasteboard generalPasteboard] setString:content];
        [self closeMenu];
        [[UIApplication sharedApplication].keyWindow makeToast:TwinmeLocalizedString(@"conversation_view_controller_menu_item_view_copy_message", nil)];
    }
}

- (void)editItemClick {
    DDLogVerbose(@"%@ editItemClick", LOG_TAG);
    
    if (self.selectedItem) {
        [self setupEditMessageView];
        
        if (self.replyItem) {
            [self closeReplyView];
        }
        
        self.editItem = self.selectedItem;
        
        NSString *content = @"";
        if (self.selectedItem.type == ItemTypeMessage) {
            MessageItem *messageItem = (MessageItem *) self.editItem;
            content = messageItem.content;
        } else if (self.selectedItem.type == ItemTypeLink) {
            LinkItem *linkItem = (LinkItem *) self.selectedItem;
            content = linkItem.content;
        }
        
        self.editingMessage = YES;
        self.editMessageView.hidden = NO;
        [self.menuButtonView editMode:self.editingMessage];
        [self.sendButtonView editMode:self.editingMessage];
        self.editMessageView.hidden = NO;
        self.textView.text = content;
        [self setSelectedMode:ModeText];
        [self.textView becomeFirstResponder];
        [self updateSendButton:NO];
        
        [self closeMenu];
    }
}

- (void)deleteItemClick {
    DDLogVerbose(@"%@ deleteItemClick", LOG_TAG);
    
    if (self.selectedItem) {
        if (self.selectedItem.isPeerItem) {
            [self.conversationService deleteDescriptorWithDescriptorId:self.selectedItem.descriptorId];
        } else {
            [self.conversationService markDescriptorDeletedWithDescriptorId:self.selectedItem.descriptorId];
        }
        [self closeMenu];
    }
}

- (void)infoItemClick {
    DDLogVerbose(@"%@ infoItemClick", LOG_TAG);
    
    if (self.selectedItem) {
        InfoItemViewController *infoItemViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"InfoItemViewController"];
        infoItemViewController.conversationViewController = self;
        [infoItemViewController initWithContact:self.contact andItem:self.selectedItem];
        [self.navigationController pushViewController:infoItemViewController animated:YES];
    }
}

- (void)forwardItemClick {
    DDLogVerbose(@"%@ forwardItemClick", LOG_TAG);
    
    if (self.selectedItem) {
        if ([self.selectedItem isClearLocalItem]) {
            [[UIApplication sharedApplication].keyWindow makeToast:TwinmeLocalizedString(@"conversation_view_controller_local_cleanup", nil)];
            return;
        } else if (self.selectedItem.state == ItemStateDeleted || (self.selectedItem.isPeerItem && (!self.selectedItem.copyAllowed || self.selectedItem.isEphemeralItem))) {
            [[UIApplication sharedApplication].keyWindow makeToast:TwinmeLocalizedString(@"conversation_view_controller_menu_item_view_operation_not_allowed", nil)];
            return;
        } else if (!self.selectedItem.isAvailableItem) {
            return;
        } else if (![self.selectedItem isFileItemExist]) {
            [[UIApplication sharedApplication].keyWindow makeToast:TwinmeLocalizedString(@"conversation_view_controller_file_not_found", nil)];
            return;
        }
        
        TLDescriptorType type;
        switch (self.selectedItem.type) {
            case ItemTypeAudio:
            case ItemTypePeerAudio:
                type = TLDescriptorTypeAudioDescriptor;
                break;
                
            case ItemTypeImage:
            case ItemTypePeerImage:
                type = TLDescriptorTypeImageDescriptor;
                break;
                
            case ItemTypeVideo:
            case ItemTypePeerVideo:
                type = TLDescriptorTypeVideoDescriptor;
                break;
                
            case ItemTypeFile:
            case ItemTypePeerFile:
                type = TLDescriptorTypeFileDescriptor;
                break;
                
            case ItemTypeMessage:
            case ItemTypePeerMessage:
            case ItemTypeLink:
            case ItemTypePeerLink:
            default:
                type = TLDescriptorTypeObjectDescriptor;
                break;
        }
        
        ShareViewController *shareViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ShareViewController"];
        shareViewController.descriptorId = self.selectedItem.descriptorId;
        shareViewController.descriptorType = type;
        shareViewController.item = self.selectedItem;
        shareViewController.conversationViewController = self;
        
        TwinmeNavigationController *navigationController = [[TwinmeNavigationController alloc]initWithRootViewController:shareViewController];
        [self presentViewController:navigationController animated:YES completion:nil];
    }
}

- (void)replyItemClick {
    DDLogVerbose(@"%@ replyItemClick", LOG_TAG);
    
    if (self.selectedItem && self.selectedItem.state != ItemStateDeleted ) {
        
        if (self.editingMessage) {
            self.editItem = nil;
            self.editingMessage = NO;
            self.editMessageView.hidden = YES;
            [self.menuButtonView editMode:self.editingMessage];
            [self.sendButtonView editMode:self.editingMessage];
            [self.textView slk_clearText:YES];
            [self updateSendButton:NO];
        }
        
        self.replyItem = self.selectedItem;
        if (!self.replyView) {
            self.replyView = [[ReplyView alloc]initWithContext:self.twinmeContext];
            self.replyView.replyViewDelegate = self;
            [self.view addSubview:self.replyView];
        }
        
        CGRect replyViewFrame = self.replyView.frame;
        replyViewFrame.origin.y = self.textInputbar.frame.origin.y - self.replyView.frame.size.height;
        self.replyView.frame = replyViewFrame;
        
        [self.view bringSubviewToFront:self.replyView];
        [self reloadData];
        self.replyView.hidden = NO;
        if (self.group) {
            if (self.replyItem.isPeerItem) {
                if (self.groupMembers && [self.groupMembers objectForKey:self.replyItem.peerTwincodeOutboundId]) {
                    TLGroupMember *member = [self.groupMembers objectForKey:self.replyItem.peerTwincodeOutboundId];
                    [self.replyView showReply:self.replyItem contactName:member.name];
                }
            } else {
                [self.replyView showReply:self.replyItem contactName:self.group.identityName];
            }
        } else if (self.replyItem.isPeerItem) {
            [self.replyView showReply:self.replyItem contactName:self.contactName];
        } else {
            [self.replyView showReply:self.replyItem contactName:self.contact.identityName];
        }
    }
    
    [self closeMenu];
}

- (void)saveItemClick {
    DDLogVerbose(@"%@ saveItemClick", LOG_TAG);
    
    if (self.selectedItem) {
        if ([self.selectedItem isClearLocalItem]) {
            [[UIApplication sharedApplication].keyWindow makeToast:TwinmeLocalizedString(@"conversation_view_controller_local_cleanup", nil)];
            return;
        } else if (self.selectedItem.state == ItemStateDeleted || (self.selectedItem.isPeerItem && (!self.selectedItem.copyAllowed || self.selectedItem.isEphemeralItem))) {
            [[UIApplication sharedApplication].keyWindow makeToast:TwinmeLocalizedString(@"conversation_view_controller_menu_item_view_operation_not_allowed", nil)];
            return;
        } else if (!self.selectedItem.isAvailableItem) {
            return;
        } else if (![self.selectedItem isFileItemExist]) {
            [[UIApplication sharedApplication].keyWindow makeToast:TwinmeLocalizedString(@"conversation_view_controller_file_not_found", nil)];
            return;
        }
        
        switch (self.selectedItem.type) {
            case ItemTypeImage:
            case ItemTypePeerImage:
            case ItemTypeVideo:
            case ItemTypePeerVideo: {
                [self saveMediaInGalleryWithPermissionCheck];
                break;
            }
                
            case ItemTypeAudio:
            case ItemTypePeerAudio:
            case ItemTypeFile:
            case ItemTypePeerFile: {
                [self saveFile];
                break;
            }
                
            default:
                [self closeMenu];
                break;
        }
    }
}

- (void)shareItemClick {
    DDLogVerbose(@"%@ shareItemClick", LOG_TAG);
    
    if (self.selectedItem) {
        NSMutableArray *activityItems;
        if ([self.selectedItem isClearLocalItem]) {
            [[UIApplication sharedApplication].keyWindow makeToast:TwinmeLocalizedString(@"conversation_view_controller_local_cleanup", nil)];
            return;
        } else if (self.selectedItem.state == ItemStateDeleted || (self.selectedItem.isPeerItem && (!self.selectedItem.copyAllowed || self.selectedItem.isEphemeralItem))) {
            [[UIApplication sharedApplication].keyWindow makeToast:TwinmeLocalizedString(@"conversation_view_controller_menu_item_view_operation_not_allowed", nil)];
            return;
        } else if (!self.selectedItem.isAvailableItem) {
            return;
        } else if (![self.selectedItem isFileItemExist]) {
            [[UIApplication sharedApplication].keyWindow makeToast:TwinmeLocalizedString(@"conversation_view_controller_file_not_found", nil)];
            return;
        }
        
        switch (self.selectedItem.type) {
            case ItemTypeMessage: {
                MessageItem *messageItem = (MessageItem *)self.selectedItem;
                activityItems = [NSMutableArray arrayWithObjects:messageItem.content, nil];
                break;
            }
                
            case ItemTypePeerMessage: {
                PeerMessageItem *peerMessageItem = (PeerMessageItem *)self.selectedItem;
                activityItems = [NSMutableArray arrayWithObjects:peerMessageItem.content, nil];
                break;
            }
                
            case ItemTypeLink: {
                LinkItem *linkItem = (LinkItem *)self.selectedItem;
                activityItems = [NSMutableArray arrayWithObjects:linkItem.content, nil];
                break;
            }
                
            case ItemTypePeerLink: {
                PeerLinkItem *peerLinkItem = (PeerLinkItem *)self.selectedItem;
                activityItems = [NSMutableArray arrayWithObjects:peerLinkItem.content, nil];
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
                activityItems = [NSMutableArray arrayWithObjects:[self.selectedItem getURL], nil];
                break;
                
            default:
                break;
        }
        
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
        
        [self closeMenu];
    }
}

- (void)selectMoreItemClick {
    DDLogVerbose(@"%@ selectMoreItemClick", LOG_TAG);
    
    if (self.selectedItem) {
        [self.selectedItem setSelected:YES];
        [self.selectedItems addObject:self.selectedItem];
    }
    
    [self closeMenu];
    
    self.selectItemMode = YES;
    self.itemSelectedActionContainerView.hidden = NO;
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObject:self.cancelBarButtonItem];
    
    if ([self.textView isFirstResponder]) {
        [self.textView resignFirstResponder];
    }
    
    [self setSelectedMode:ModeDefault];
    self.textInputBarHeight = self.textInputbar.frame.size.height;
    [self setTextInputbarHidden:YES animated:NO height:self.itemSelectedActionViewHeightConstraint.constant];
    self.sendButtonView.hidden = YES;
    self.menuButtonView.hidden = YES;
    self.scrollIndicatorView.hidden = YES;
    
    [self.itemSelectedActionView updateSelectedItems:(int)self.selectedItems.count];
    
    [self reloadData];
}

- (void)didPinchTableView:(UIPinchGestureRecognizer *)pinchGestureRecognizer {
    DDLogVerbose(@"%@ didPinchTableView: %@", LOG_TAG, pinchGestureRecognizer);
    
    if (self.menuOpen) {
        return;
    }
    
    [self.view bringSubviewToFront:self.zoomLevelView];
    [self.view bringSubviewToFront:self.zoomLevelLabel];
    
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        pinchGestureRecognizer.scale = self.scaleFont;
        [UIView animateWithDuration:0.3 delay:0. options: UIViewAnimationOptionCurveEaseIn animations:^{
            self.zoomLevelView.alpha = 1.0;
            self.zoomLevelLabel.alpha = 1.0;
        } completion:^(BOOL finished) {
            self.zoomLevelView.hidden = NO;
            self.zoomLevelLabel.hidden = NO;
        }];
    } else if (pinchGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        self.scaleFont = pinchGestureRecognizer.scale;
        if (self.scaleFont > self.maxScaleFont) {
            self.scaleFont = self.maxScaleFont;
        } else if (self.scaleFont < self.minScaleFont) {
            self.scaleFont = self.minScaleFont;
        }
        
        [UIView animateWithDuration:0.5 delay:0. options: UIViewAnimationOptionCurveEaseIn animations:^{
            self.zoomLevelView.alpha = 0.0;
            self.zoomLevelLabel.alpha = 0.0;
        } completion:^(BOOL finished) {
            self.zoomLevelView.hidden = YES;
            self.zoomLevelLabel.hidden = YES;
        }];
    }
    
    UIFont *initialFont = Design.FONT_REGULAR32;
    float size = initialFont.pointSize * pinchGestureRecognizer.scale;
    if (size > self.maxSizeFont) {
        size = self.maxSizeFont;
    } else if (size < self.minSizeFont) {
        size = self.minSizeFont;
    }
    
    CGFloat zoomPercent = (size / initialFont.pointSize) * 100;
    self.zoomLevelLabel.text = [NSString stringWithFormat:@"%.0f%%", zoomPercent];
    
    if (self.messageFont.pointSize != size) {
        self.messageFont = [UIFont systemFontOfSize:size];
        [self.tableView reloadData];
    }
}

#pragma mark - MenuReactionDelegate

- (void)selectReaction:(UIReaction *)uiReaction {
    DDLogVerbose(@"%@ selectReaction: %@", LOG_TAG, uiReaction);
    
    if (self.selectedItem) {
        [self.conversationService toggleAnnotationWithDescriptorId:self.selectedItem.descriptorId type:TLDescriptorAnnotationTypeLike value:uiReaction.reactionType];
    }
    
    [self closeMenu];
}

#pragma mark - PreviewViewDelegate

- (void)sendMediaCaption:(NSString *)text allowCopyText:(BOOL)allowCopyText expireTimeout:(int64_t)timeout {
    DDLogVerbose(@"%@ sendMediaCaption:%@ allowCopyText: %@", LOG_TAG, text, allowCopyText ? @"YES":@"NO");
    
    if (text && ![text isEqualToString:@""]) {
        [self.textView slk_clearText:YES];
        [self clearCachedText];
        [self.conversationService pushMessage:text copyAllowed:allowCopyText expiredTimeout:timeout sendTo:nil replyTo:nil];
    }
}

- (void)sendFile:(NSString *)filePath allowCopyFile:(BOOL)allowCopyFile expireTimeout:(int64_t)timeout {
    DDLogVerbose(@"%@ sendFile: %@ allowCopyFile: %@", LOG_TAG, filePath, allowCopyFile ? @"YES":@"NO");
    
    [self pushFileWithPath:filePath type:TLDescriptorTypeNamedFileDescriptor toBeDeleted:NO allowCopy:allowCopyFile expireTimeout:timeout];
    
    if (![self.twinmeContext isConnected]) {
        NSString *message;
        if ([[self.twinmeContext getConnectivityService] isConnectedNetwork]) {
            message = TwinmeLocalizedString(@"application_network_status_connected_no_internet", nil);
        } else {
            message = TwinmeLocalizedString(@"application_network_status_no_internet", nil);
        }
        [[UIApplication sharedApplication].keyWindow makeToast:message];
    }
}

- (void)sendImage:(NSString *)imagePath allowCopyFile:(BOOL)allowCopyFile expireTimeout:(int64_t)timeout {
    DDLogVerbose(@"%@ sendImage: %@ allowCopyFile: %@", LOG_TAG, imagePath, allowCopyFile ? @"YES":@"NO");
    
    [self pushFileWithPath:imagePath type:TLDescriptorTypeImageDescriptor toBeDeleted:YES allowCopy:allowCopyFile expireTimeout:timeout];
        
    if (![self.twinmeContext isConnected]) {
        NSString *message;
        if ([[self.twinmeContext getConnectivityService] isConnectedNetwork]) {
            message = TwinmeLocalizedString(@"application_network_status_connected_no_internet", nil);
        } else {
            message = TwinmeLocalizedString(@"application_network_status_no_internet", nil);
        }
        [[UIApplication sharedApplication].keyWindow makeToast:message];
    }
}

- (void)sendVideo:(NSString *)videoPath allowCopyFile:(BOOL)allowCopyFile expireTimeout:(int64_t)timeout {
    DDLogVerbose(@"%@ sendVideo: %@ allowCopyFile: %@", LOG_TAG, videoPath, allowCopyFile ? @"YES":@"NO");
    
    [self pushFileWithPath:videoPath type:TLDescriptorTypeVideoDescriptor toBeDeleted:YES allowCopy:allowCopyFile expireTimeout:timeout];
        
    if (![self.twinmeContext isConnected]) {
        NSString *message;
        if ([[self.twinmeContext getConnectivityService] isConnectedNetwork]) {
            message = TwinmeLocalizedString(@"application_network_status_connected_no_internet", nil);
        } else {
            message = TwinmeLocalizedString(@"application_network_status_no_internet", nil);
        }
        [[UIApplication sharedApplication].keyWindow makeToast:message];
    }
}

- (void)sendLocation:(double)latitudeDelta longitudeDelta:(double)longitudeDelta location:(CLLocation *)userLocation text:(NSString *)text allowCopyText:(BOOL)allowCopyText allowCopyFile:(BOOL)allowCopyFile expireTimeout:(int64_t)timeout {
    DDLogVerbose(@"%@ sendLocation: %f longitudeDelta: %f userLocation: %@ text: %@ allowCopyText: %@ allowCopyFile: %@ expireTimeout: %lld", LOG_TAG,  latitudeDelta, longitudeDelta, userLocation, text, allowCopyText ? @"YES":@"NO", allowCopyFile ? @"YES":@"NO", timeout);
    
    [self pushGeolocationWithLatitudeDelta:latitudeDelta longitudeDelta:longitudeDelta location:userLocation expireTimeout:timeout];
    
    if (text && ![text isEqualToString:@""]) {
        [self.textView slk_clearText:YES];
        [self clearCachedText];
        [self.conversationService pushMessage:text copyAllowed:allowCopyText expiredTimeout:timeout sendTo:nil replyTo:nil];
    }

    if (![self.twinmeContext isConnected]) {
        NSString *message;
        if ([[self.twinmeContext getConnectivityService] isConnectedNetwork]) {
            message = TwinmeLocalizedString(@"application_network_status_connected_no_internet", nil);
        } else {
            message = TwinmeLocalizedString(@"application_network_status_no_internet", nil);
        }
        [[UIApplication sharedApplication].keyWindow makeToast:message];
    }
}

#pragma mark - CoachMarkDelegate

- (void)didTapCoachMarkOverlay:(CoachMarkViewController *)coachMarkViewController {
    DDLogVerbose(@"%@ didTapCoachMarkOverlay: %@", LOG_TAG, coachMarkViewController);
    
    [coachMarkViewController closeView];
}

- (void)didTapCoachMarkFeature:(CoachMarkViewController *)coachMarkViewController {
    DDLogVerbose(@"%@ didTapCoachMarkFeature: %@", LOG_TAG, coachMarkViewController);
    
}

- (void)didLongPressCoachMarkFeature:(CoachMarkViewController *)coachMarkViewController {
    DDLogVerbose(@"%@ didLongPressCoachMarkFeature: %@", LOG_TAG, coachMarkViewController);
    
    [self.twinmeApplication hideCoachMark:[[coachMarkViewController getCoachMark] coachMarkTag]];
    [coachMarkViewController closeView];
    [self openMenuSendOptions];
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
                case ItemTypeMessage: {
                    MessageItem *messageItem = (MessageItem *)item;
                    [activityItems addObject:messageItem.content];
                    break;
                }
                    
                case ItemTypePeerMessage: {
                    PeerMessageItem *peerMessageItem = (PeerMessageItem *)item;
                    [activityItems addObject:peerMessageItem.content];
                    
                    break;
                }
                    
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
    
    [self handleCancelSelectModeTapGesture:nil];
}

- (void)didTapDeleteAction {
    DDLogVerbose(@"%@ didTapDeleteAction", LOG_TAG);
    
    DeleteConfirmView *deleteConfirmView = [[DeleteConfirmView alloc] init];
    deleteConfirmView.confirmViewDelegate = self;
    deleteConfirmView.deleteConfirmType = DeleteConfirmTypeFile;
    [deleteConfirmView initWithTitle:TwinmeLocalizedString(@"delete_account_view_controller_warning", nil) message:TwinmeLocalizedString(@"cleanup_view_controller_delete_confirmation_message", nil) avatar:self.contactAvatar icon:[UIImage imageNamed:@"ActionBarDelete"]];
    
    [self.navigationController.view addSubview:deleteConfirmView];
    [deleteConfirmView showConfirmView];
}

#pragma mark - ItemSelectDelegate

- (void)didSelectItem:(Item *)item {
    DDLogVerbose(@"%@ didSelectItem: %@", LOG_TAG, item);
    
    if (self.selectItemMode) {
        if (item.selected) {
            item.selected = NO;
            [self.selectedItems removeObject:item];
        } else {
            item.selected = YES;
            [self.selectedItems addObject:item];
        }
        
        [self.itemSelectedActionView updateSelectedItems:(int)self.selectedItems.count];
        [self reloadData];
    }
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

#pragma mark - MenuActionConversationDelegate

- (void)cancelMenuAction {
    DDLogVerbose(@"%@ cancelMenuAction", LOG_TAG);
    
    self.menuActionConversationView.hidden = YES;
}

- (void)didSelectAction:(UIActionConversation *)uiActionConversation {
    DDLogVerbose(@"%@ didSelectAction: %@", LOG_TAG, uiActionConversation);
    
    [self hapticFeedback];
    
    switch (uiActionConversation.conversationActionType) {
        case ConversationActionTypeCamera:
            [self openCamera];
            break;
            
        case ConversationActionTypeGallery:
            [self openGallery];
            break;
            
        case ConversationActionTypeFile:
            [self openFile];
            break;
            
        case ConversationActionTypeLocation:
            [self openLocation];
            break;

        case ConversationActionTypeMediasAndFiles:
            [self openMediasAndFiles];
            break;
            
        case ConversationActionTypeManageConversation:
            [self openManageConversation];
            break;
            
        case ConversationActionTypeReset:
            [self resetConversation];
            break;
            
        default:
            break;
    }
    
    [self cancelMenuAction];
}

#pragma mark - MenuSendOptionsDelegate

- (void)cancelMenuSendOptions:(MenuSendOptionsView *)menuSendOptionsView {
    DDLogVerbose(@"%@ cancelMenuSendOptions", LOG_TAG);
    
    [menuSendOptionsView removeFromSuperview];
    
    self.menuSendOptionsOpen = NO;
}

- (void)sendFromOptionsMenu:(MenuSendOptionsView *)menuSendOptionsView allowCopy:(BOOL)allowCopy allowEphemeral:(BOOL)allowEphemeral expireTimeout:(int64_t)expireTimeout {
    DDLogVerbose(@"%@ sendFromOptionsMenu: %@ allowEphemeral: %@ expireTimeout: %lld", LOG_TAG, allowCopy ? @"YES" : @"NO", allowEphemeral ? @"YES" : @"NO", expireTimeout);
    
    [menuSendOptionsView removeFromSuperview];
    
    self.allowCopy = allowCopy;
    self.allowEphemeralMessage = allowEphemeral;
    self.expireTimeout = expireTimeout;
    
    [self didPressRightButton];
    
    self.menuSendOptionsOpen = NO;
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)pickerController didFinishPickingMediaWithInfo:(NSDictionary *)info {
    DDLogVerbose(@"%@ imagePickerController: %@ didFinishPickingMediaWithInfo: %@", LOG_TAG, pickerController, info);
    
    [pickerController dismissViewControllerAnimated:YES completion:^{
        if (!info) {
            return;
        }
        self.countMediaPicking = 0;
        self.endMediaPicking = NO;
        self.errorMediaPicking = NO;
        [self.previewMediaPicking removeAllObjects];
        
        CFStringRef mediaType = (__bridge CFStringRef)([info objectForKey:@"UIImagePickerControllerMediaType"]);
        if (UTTypeConformsTo(mediaType, kUTTypeMovie)) {
            self.countMediaPicking++;
            NSURL *url = [info objectForKey:@"UIImagePickerControllerMediaURL"];
            AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:url options:nil];
            NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
            if ([compatiblePresets containsObject:AVAssetExportPresetHighestQuality]) {
                AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset presetName:AVAssetExportPresetHighestQuality];
                NSString *videoPath = [url.path stringByReplacingOccurrencesOfString:url.pathExtension withString:@"mp4"];
                NSURL *urlExport = [[NSURL alloc] initFileURLWithPath:videoPath];
                if ([[NSFileManager defaultManager]fileExistsAtPath:videoPath]) {
                    [[NSFileManager defaultManager]removeItemAtPath:videoPath error:nil];
                }
                exportSession.outputURL = urlExport;
                exportSession.outputFileType = AVFileTypeMPEG4;
                exportSession.shouldOptimizeForNetworkUse = YES;
                [exportSession exportAsynchronouslyWithCompletionHandler:^{
                    if ([exportSession status] == AVAssetExportSessionStatusCompleted) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self openPreviewVideo:urlExport];
                            [[NSFileManager defaultManager]removeItemAtPath:url.path error:nil];
                        });
                        
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self openPreviewVideo:url];
                        });
                    }
                }];
            } else {
                [self openPreviewVideo:url];
            }
        } else if (UTTypeConformsTo(mediaType, kUTTypeImage)) {
            UIImage *originalImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
            NSURL *urlImage = [info objectForKey:@"UIImagePickerControllerImageURL"];
            
            if ([info objectForKey:@"UIImagePickerControllerPHAsset"]) {
                self.countMediaPicking++;
                PHAsset *asset = [info objectForKey:@"UIImagePickerControllerPHAsset"];
                PHImageRequestOptions *imageRequestOptions = [[PHImageRequestOptions alloc] init];
                imageRequestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
                imageRequestOptions.networkAccessAllowed = YES;
                [[PHImageManager defaultManager] requestImageDataForAsset:asset options:imageRequestOptions resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                    
                    if (imageData) {
                        NSString *imgExtension = @".jpg";
                        if ([dataUTI isEqualToString:@"com.compuserve.gif"]) {
                            imgExtension = @".gif";
                        }
                        
                        UIImage *img = [[UIImage alloc] initWithData:imageData];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self openPreviewImage:img imageData:imageData imageExtension:imgExtension];
                        });
                    } else {
                        self.countMediaPicking--;
                    }
                }];
            } else if (originalImage && urlImage) {
                self.countMediaPicking++;
                NSString *imgExtension = @".jpg";
                if (urlImage && [UIImage isAnimatedImage:[urlImage absoluteString]]) {
                    imgExtension = @".gif";
                }
                
                [self openPreviewImage:originalImage imageData:[NSData dataWithContentsOfURL:urlImage] imageExtension:imgExtension];
            } else if (originalImage) {
                self.countMediaPicking++;
                [self openPreviewImage:originalImage imageData:nil imageExtension:@".jpg"];
            }
        }
        
        self.endMediaPicking = YES;
        [self startPreviewMediaActivity];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)pickerController {
    DDLogVerbose(@"%@ imagePickerControllerDidCancel: %@", LOG_TAG, pickerController);
    
    [pickerController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - PHPickerViewControllerDelegate

- (void)picker:(PHPickerViewController *)pickerController didFinishPicking:(NSArray<PHPickerResult *> *)results API_AVAILABLE(ios(14)){
    DDLogVerbose(@"%@ picker: %@", LOG_TAG, pickerController);
    
    [pickerController dismissViewControllerAnimated:YES completion:^{
        if (!results || results.count == 0) {
            return;
        }
        self.countMediaPicking = 0;
        self.endMediaPicking = NO;
        self.errorMediaPicking = NO;
        [self.previewMediaPicking removeAllObjects];
        
        for (PHPickerResult *result in results) {
            if ([result.itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeImage]) {
                
                self.countMediaPicking++;
                [result.itemProvider loadDataRepresentationForTypeIdentifier:(NSString *)kUTTypeImage
                                                           completionHandler:^(NSData * _Nullable data,
                                                                               NSError * _Nullable error) {
                    if (!error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, nil);
                            NSString *extension = @".jpg";
                            if (source) {
                                size_t count = CGImageSourceGetCount(source);
                                if (count > 1) {
                                    extension = @".gif";
                                }
                                CFRelease(source);
                            }
                            
                            UIImage *image = [UIImage imageWithData:data];
                            
                            [self openPreviewImage:image imageData:data imageExtension:extension];
                        });
                    } else {
                        self.errorMediaPicking = YES;
                        [self openPreviewImage:nil imageData:nil imageExtension:nil];
                    }
                }];
            } else if ([result.itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeMovie]) {
                
                self.countMediaPicking++;
                [result.itemProvider loadFileRepresentationForTypeIdentifier:(NSString *)kUTTypeMovie
                                                           completionHandler:^(NSURL * _Nullable url,
                                                                               NSError * _Nullable error) {
                    
                    if (!error) {
                        NSString *fileName = [NSString stringWithFormat:@"%@_.%@", [[NSProcessInfo processInfo] globallyUniqueString], url.pathExtension];
                        
                        NSURL *tmpUrl = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:fileName]];
                        [[NSFileManager defaultManager] copyItemAtURL:url toURL:tmpUrl error:nil];
                        
                        AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:tmpUrl options:nil];
                        NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
                        if ([compatiblePresets containsObject:AVAssetExportPresetHighestQuality]) {
                            AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset presetName:AVAssetExportPresetHighestQuality];
                            NSString *videoPath = [tmpUrl.path stringByReplacingOccurrencesOfString:tmpUrl.pathExtension withString:@"mp4"];
                            NSURL *urlExport = [[NSURL alloc] initFileURLWithPath:videoPath];
                            if ([[NSFileManager defaultManager]fileExistsAtPath:videoPath]) {
                                [[NSFileManager defaultManager]removeItemAtPath:videoPath error:nil];
                            }
                            exportSession.outputURL = urlExport;
                            exportSession.outputFileType = AVFileTypeMPEG4;
                            exportSession.shouldOptimizeForNetworkUse = YES;
                            [exportSession exportAsynchronouslyWithCompletionHandler:^{
                                if ([exportSession status] == AVAssetExportSessionStatusCompleted) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [self openPreviewVideo:urlExport];
                                        if (![urlExport.path isEqual:tmpUrl.path]) {
                                            [[NSFileManager defaultManager]removeItemAtPath:tmpUrl.path error:nil];
                                        }
                                    });
                                    
                                } else {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        self.errorMediaPicking = YES;
                                        [self openPreviewVideo:nil];
                                    });
                                }
                            }];
                        } else {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self openPreviewVideo:tmpUrl];
                            });
                        }
                    } else {
                        self.errorMediaPicking = YES;
                        [self openPreviewVideo:nil];
                    }
                }];
            }
        }
        
        self.endMediaPicking = YES;
        [self startPreviewMediaActivity];
    }];
}


#pragma mark - MenuManageConversationView

- (void)cancelMenuManageConversationView:(MenuManageConversationView *)menuManageConversationView {
    DDLogVerbose(@"%@ cancelMenuManageConversationView", LOG_TAG);
    
    [menuManageConversationView removeFromSuperview];
}

- (void)menuManageConversationViewDidSelectCleanup:(MenuManageConversationView *)menuManageConversationView {
    DDLogVerbose(@"%@ menuManageConversationViewDidSelectCleanup", LOG_TAG);
    
    [menuManageConversationView removeFromSuperview];
    
    TypeCleanUpViewController *typeCleanupViewController = (TypeCleanUpViewController *)[[UIStoryboard storyboardWithName:@"iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"TypeCleanUpViewController"];
    if (self.group) {
        [typeCleanupViewController initCleanUpWithGroup:self.group];
    } else {
        [typeCleanupViewController initCleanUpWithContact:self.contact];
    }
    [self.navigationController pushViewController:typeCleanupViewController animated:YES];
}

- (void)menuManageConversationViewDidSelectExport:(MenuManageConversationView *)menuManageConversationView {
    DDLogVerbose(@"%@ menuManageConversationViewDidSelectExport", LOG_TAG);
    
    [menuManageConversationView removeFromSuperview];
    
    ExportViewController *exportViewController = (ExportViewController *)[[UIStoryboard storyboardWithName:@"iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"ExportViewController"];
    if (self.group) {
        [exportViewController initExportWithGroup:self.group];
    } else {
        [exportViewController initExportWithContact:self.contact];
    }
    [self.navigationController pushViewController:exportViewController animated:YES];
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    [self.tableView registerNib:[UINib nibWithNibName:@"InfoPrivacyCell" bundle:nil] forCellReuseIdentifier:INFO_PRIVACY_ITEM_CELL_IDENTIFIER];
    
    self.navigationItem.title = @"";
    self.view.backgroundColor = Design.CONVERSATION_BACKGROUND_COLOR;
    
    self.smallRadius = DESIGN_SMALL_ROUND_CORNER_RADIUS * Design.HEIGHT_RATIO;
    self.largeRadius = DESIGN_LARGE_ROUND_CORNER_RADIUS * Design.HEIGHT_RATIO;
    self.topMargin1 = DESIGN_TOP_MARGIN1 * Design.HEIGHT_RATIO;
    self.topMargin2 = DESIGN_TOP_MARGIN2 * Design.HEIGHT_RATIO;
    self.bottomMargin1 = DESIGN_BOTTOM_MARGIN1 * Design.HEIGHT_RATIO;
    self.bottomMargin2 = DESIGN_BOTTOM_MARGIN2 * Design.HEIGHT_RATIO;
    self.bottomMargin3 = DESIGN_BOTTOM_MARGIN3 * Design.HEIGHT_RATIO;
    
    self.emptyConversationLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.emptyConversationLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.emptyConversationLabel.font = Design.FONT_REGULAR36;
    self.emptyConversationLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.emptyConversationLabel.text = TwinmeLocalizedString(@"conversation_view_controller_empty_message", nil);
    [self.view bringSubviewToFront:self.emptyConversationLabel];
    
    self.scrollIndicatorViewWidthConstraint.constant = self.scrollIndicatorImageViewHeightConstraint.constant + 2 * self.scrollIndicatorImageViewTrailingConstraint.constant;
    
    self.scrollIndicatorViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.scrollIndicatorViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.scrollIndicatorView.backgroundColor = Design.MAIN_COLOR;
    self.scrollIndicatorView.hidden = YES;
    self.scrollIndicatorView.clipsToBounds = YES;
    self.scrollIndicatorView.userInteractionEnabled = YES;
    
    if ([[UIApplication sharedApplication] userInterfaceLayoutDirection] == UIUserInterfaceLayoutDirectionRightToLeft) {
        self.scrollIndicatorView.layer.maskedCorners = kCALayerMinXMaxYCorner | kCALayerMinXMinYCorner;
    } else {
        self.scrollIndicatorView.layer.maskedCorners = kCALayerMaxXMaxYCorner | kCALayerMaxXMinYCorner;
    }
    
    self.scrollIndicatorView.layer.cornerRadius = self.scrollIndicatorViewHeightConstraint.constant * 0.5f;

    self.scrollIndicatorOverlayView.backgroundColor = Design.BACKGROUND_COLOR_WHITE_OPACITY85;
    self.scrollIndicatorOverlayView.hidden = YES;
    
    [self.view bringSubviewToFront:self.scrollIndicatorView];
    [self.view bringSubviewToFront:self.scrollIndicatorOverlayView];
    
    UITapGestureRecognizer *scrollIndicatorTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleScrollIndicatorTapGesture:)];
    [self.scrollIndicatorView addGestureRecognizer:scrollIndicatorTapGesture];
    
    self.scrollIndicatorImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.scrollIndicatorImageViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.scrollIndicatorCountLabel.textColor = [UIColor whiteColor];
    self.scrollIndicatorCountLabel.font = Design.FONT_MEDIUM42;
    self.scrollIndicatorCountLabel.text = @"";
    
    self.itemSelectedActionViewHeightConstraint.constant *= Design.HEIGHT_RATIO;

    UIWindow *window = UIApplication.sharedApplication.keyWindow;
    self.itemSelectedActionViewHeightConstraint.constant += window.safeAreaInsets.bottom;
    
    self.itemSelectedActionContainerView.backgroundColor = Design.NAVIGATION_BAR_BACKGROUND_COLOR;
    self.itemSelectedActionContainerView.hidden = YES;
    
    [self.view bringSubviewToFront:self.itemSelectedActionContainerView];
    
    [self.textView setDynamicTypeEnabled:NO];
    
    if (@available(iOS 18.0, *)) {
        self.textView.supportsAdaptiveImageGlyph = NO;
    }
    
    self.textView.font = Design.FONT_REGULAR32;
    self.textView.placeholder = TwinmeLocalizedString(@"conversation_view_controller_message", nil);
    self.textView.backgroundColor = Design.TEXTFIELD_CONVERSATION_BACKGROUND_COLOR;
    self.textView.textContainerInset = UIEdgeInsetsMake(DESIGN_HEIGHT_INSET * Design.HEIGHT_RATIO, DESIGN_WIDTH_INSET * Design.WIDTH_RATIO, DESIGN_HEIGHT_INSET * Design.HEIGHT_RATIO, DESIGN_WIDTH_INSET * Design.WIDTH_RATIO);
    self.textView.layer.borderColor = [UIColor clearColor].CGColor;
    self.textView.keyboardType = UIKeyboardTypeDefault;
    self.textView.pastableMediaTypes = SLKPastableMediaTypeAll;
    [self.textView registerMarkdownFormattingSymbol:@"*" withTitle:TwinmeLocalizedString(@"conversation_view_controller_format_menu_bold", nil)];
    [self.textView registerMarkdownFormattingSymbol:@"_" withTitle:TwinmeLocalizedString(@"conversation_view_controller_format_menu_italic", nil)];
    [self.textView registerMarkdownFormattingSymbol:@"~" withTitle:TwinmeLocalizedString(@"conversation_view_controller_format_menu_strikethrough", nil)];
    
    self.textView.layer.cornerRadius = (Design.FONT_REGULAR32.lineHeight + (DESIGN_HEIGHT_INSET * Design.HEIGHT_RATIO * 2)) * 0.5;
    self.textView.clipsToBounds = YES;
        
    self.bounces = YES;
    self.keyboardPanningEnabled = YES;
    self.shouldScrollToBottomAfterKeyboardShows = NO;
    self.inverted = YES;
    UIView * headerSpace = [[UIView alloc] initWithFrame:self.headerView.frame];
    self.tableView.tableFooterView = headerSpace;
    self.typingIndicatorView.canResignByTouch = YES;
    self.tableView.tableFooterView.backgroundColor = Design.WHITE_COLOR;
    self.tableView.tableHeaderView.backgroundColor = Design.WHITE_COLOR;
    
    self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    
    [self updateTableViewBackgroundColor];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 48;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //    [self.tableView registerNib:[UINib nibWithNibName:@"InfoPrivacyCell" bundle:nil] forCellReuseIdentifier:INFO_PRIVACY_ITEM_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"MessageItemCell" bundle:nil] forCellReuseIdentifier:MESSAGE_ITEM_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"PeerMessageItemCell" bundle:nil] forCellReuseIdentifier:PEER_MESSAGE_ITEM_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"LinkItemCell" bundle:nil] forCellReuseIdentifier:LINK_ITEM_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"PeerLinkItemCell" bundle:nil] forCellReuseIdentifier:PEER_LINK_ITEM_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"ImageItemCell" bundle:nil] forCellReuseIdentifier:IMAGE_ITEM_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"PeerImageItemCell" bundle:nil] forCellReuseIdentifier:PEER_IMAGE_ITEM_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"AudioItemCell" bundle:nil] forCellReuseIdentifier:AUDIO_ITEM_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"PeerAudioItemCell" bundle:nil] forCellReuseIdentifier:PEER_AUDIO_ITEM_CELL_IDENTIFIER];
    [self.tableView registerClass:[TimeItemCell class] forCellReuseIdentifier:TIME_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"VideoItemCell" bundle:nil] forCellReuseIdentifier:VIDEO_ITEM_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"PeerVideoItemCell" bundle:nil] forCellReuseIdentifier:PEER_VIDEO_ITEM_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"FileItemCell" bundle:nil] forCellReuseIdentifier:FILE_ITEM_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"PeerFileItemCell" bundle:nil] forCellReuseIdentifier:PEER_FILE_ITEM_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"InvitationItemCell" bundle:nil] forCellReuseIdentifier:INVITATION_ITEM_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"PeerInvitationItemCell" bundle:nil] forCellReuseIdentifier:PEER_INVITATION_ITEM_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"NameItemCell" bundle:nil] forCellReuseIdentifier:NAME_ITEM_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"CallItemCell" bundle:nil] forCellReuseIdentifier:CALL_ITEM_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"PeerCallItemCell" bundle:nil] forCellReuseIdentifier:PEER_CALL_ITEM_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"LocationItemCell" bundle:nil] forCellReuseIdentifier:LOCATION_ITEM_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"PeerLocationItemCell" bundle:nil] forCellReuseIdentifier:PEER_LOCATION_ITEM_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"InvitationContactItemCell" bundle:nil] forCellReuseIdentifier:INVITATION_CONTACT_ITEM_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"PeerInvitationContactItemCell" bundle:nil] forCellReuseIdentifier:PEER_INVITATION_CONTACT_ITEM_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"ClearItemCell" bundle:nil] forCellReuseIdentifier:CLEAR_ITEM_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"PeerClearItemCell" bundle:nil] forCellReuseIdentifier:PEER_CLEAR_ITEM_CELL_IDENTIFIER];
    
    UITapGestureRecognizer *tapTableViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeMenu)];
    [self.tableView addGestureRecognizer:tapTableViewGestureRecognizer];
    
    self.tableView.prefetchDataSource = self;
    
    self.sendButtonView = (SendButtonView *)self.textInputbar.sendButtonView;
    self.sendButtonView.isAccessibilityElement = YES;
    UITapGestureRecognizer *sendTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didPressRightButton)];
    [self.sendButtonView.sendView addGestureRecognizer:sendTapGestureRecognizer];
    
    UITapGestureRecognizer *editMessageTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didEditMessageButton:)];
    [self.sendButtonView.editView addGestureRecognizer:editMessageTapGestureRecognizer];
    
    self.sendButtonView.backgroundColor = [UIColor clearColor];
    self.sendButtonView.sendView.accessibilityLabel = TwinmeLocalizedString(@"feedback_view_controller_send", nil);
    
    UILongPressGestureRecognizer *longPressSendButtonViewGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleSendButtonViewLongPress:)];
    [self.sendButtonView.sendView addGestureRecognizer:longPressSendButtonViewGestureRecognizer];
    
    self.menuButtonView = (MenuConversationButtonView *)self.textInputbar.recordButtonView;
    self.menuButtonView.isAccessibilityElement = YES;
    UITapGestureRecognizer *menuTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didPressLeftButton:)];
    [self.menuButtonView.menuView addGestureRecognizer:menuTapGestureRecognizer];
    
    UITapGestureRecognizer *closeEditTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didCloseEditButton:)];
    [self.menuButtonView.closeView addGestureRecognizer:closeEditTapGestureRecognizer];
    
    self.menuButtonView.backgroundColor = [UIColor clearColor];
    
    self.menuItemView = [[MenuItemView alloc] init];
    self.menuItemView.hidden = YES;
    self.menuItemView.menuItemDelegate = self;
    [self.view addSubview:self.menuItemView];
    
    if (!self.group && self.contact && self.contact.peerTwincodeOutbound && ![self.contact.peerTwincodeOutbound isSigned]) {
        [self.menuItemView setEditMessage:NO];
    }
    
    self.menuReactionView = [[MenuReactionView alloc] init];
    self.menuReactionView.hidden = YES;
    self.menuReactionView.menuReactionDelegate = self;
    [self.view addSubview:self.menuReactionView];
    
    self.typingView = [[TypingView alloc] init];
    self.typingView.frame = CGRectMake(0, 0, Design.DISPLAY_WIDTH, DESIGN_TYPING_VIEW_HEIGHT * Design.HEIGHT_RATIO);
    self.typingView.transform = self.tableView.transform;
    [self.typingView setCustomAppearance:self.customAppearance];
    
    UIPinchGestureRecognizer *pinchFontGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(didPinchTableView:)];
    [self.tableView addGestureRecognizer:pinchFontGesture];
    
    UIFont *initialFont = Design.FONT_REGULAR32;
    
    self.minSizeFont = DESIGN_MIN_FONT * Design.HEIGHT_RATIO;
    self.maxSizeFont = DESIGN_MAX_FONT * Design.HEIGHT_RATIO;
    
    self.minScaleFont = self.minSizeFont / initialFont.pointSize;
    self.maxScaleFont = self.maxSizeFont / initialFont.pointSize;
    
    [self.textInputbar setBackgroundColor:Design.WHITE_COLOR];
    [self.textInputbar setContentInset:UIEdgeInsetsMake(5, 8, 5, 0)];
    
    self.overlayView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Design.DISPLAY_WIDTH, Design.DISPLAY_HEIGHT)];
    self.overlayView.backgroundColor = Design.OVERLAY_COLOR;
    self.overlayView.hidden = YES;
    
    if (@available(iOS 13.0, *)) {
        self.activityIndicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
        self.activityIndicatorView.color = [UIColor whiteColor];
    } else {
        self.activityIndicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    }
    self.activityIndicatorView.hidesWhenStopped = YES;
    
    [self.overlayView addSubview:self.activityIndicatorView];
    
    [self.activityIndicatorView setCenter:CGPointMake(Design.DISPLAY_WIDTH * 0.5, Design.DISPLAY_HEIGHT * 0.5)];
    [self.tabBarController.view addSubview:self.overlayView];
    
    self.zoomLevelViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.zoomLevelViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.zoomLevelView.clipsToBounds = YES;
    self.zoomLevelView.layer.cornerRadius = self.zoomLevelViewHeightConstraint.constant * 0.5f;
    self.zoomLevelView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.7];
    self.zoomLevelView.hidden = YES;
    
    self.zoomLevelLabel.font = Design.FONT_BOLD44;
    self.zoomLevelLabel.textColor = Design.ZOOM_COLOR;
    self.zoomLevelLabel.adjustsFontSizeToFitWidth = YES;
    self.zoomLevelLabel.hidden = YES;
}

- (void)reloadInfoPrivacy {
    DDLogVerbose(@"%@ reloadInfoPrivacy", LOG_TAG);
    
    if (self.infoPrivacyItem) {
        [self.items removeObject:self.infoPrivacyItem];
        [self.items insertObject:self.infoPrivacyItem atIndex:0];
    }
    
    UIFont *initialFont = Design.FONT_REGULAR32;
    
    self.minSizeFont = DESIGN_MIN_FONT * Design.HEIGHT_RATIO;
    self.maxSizeFont = DESIGN_MAX_FONT * Design.HEIGHT_RATIO;
    
    self.minScaleFont = self.minSizeFont / initialFont.pointSize;
    self.maxScaleFont = self.maxSizeFont / initialFont.pointSize;
}

- (void)reloadData {
    DDLogVerbose(@"%@ reloadData", LOG_TAG);
    
    if ([self.conversationService isGetDescriptorDone]) {
        [self reloadInfoPrivacy];
    }
    
    if (self.items.count == 1) {
        self.emptyConversationLabel.hidden = NO;
    } else {
        self.emptyConversationLabel.hidden = YES;
    }
    
    [self.tableView reloadData];
    
    [self setupTableHeaderView];
    [self updateScrollIndicator];
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    [self.asyncLoaderManager stop];
    self.asyncLoaderManager = nil;
    
    if (self.isTyping) {
        self.isTyping = NO;
        TLTyping *typing = [[TLTyping alloc]initWithAction:TLTypingActionStop];
        [self.conversationService pushTyping:typing];
    }
    if (self.typingTimer) {
        [self.typingTimer invalidate];
        self.typingTimer = nil;
    }
    
    if (self.peerTypingTimer) {
        [self.peerTypingTimer invalidate];
        self.peerTypingTimer = nil;
    }
    
    if (self.conversationService) {
        [self.conversationService resetActiveConversation];
        [self.conversationService dispose];
        self.conversationService = nil;
    }
    
    if (self.groupInvitationService) {
        [self.groupInvitationService dispose];
        self.groupInvitationService = nil;
    }
    
    if (self.groupService) {
        [self.groupService dispose];
        self.groupService = nil;
    }
    
    if (self.replyView) {
        [self.replyView finish];
    }
        
    if (self.viewAppearing) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)handleBackTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleBackTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self finish];
    }
}

- (void)handleScrollIndicatorTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleScrollIndicatorTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        if (self.isMenuOpen) {
            return;
        }
        
        [self hapticFeedback];
        self.scrollIndicatorCount = 0;
        if (self.items.count > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSIndexPath *indexPath = [self itemIndexToIndexPath:self.items.count - 1];
                if (indexPath.row < self.items.count) {
                    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
                }
            });
        }
    }
}

- (void)handleCancelSelectModeTapGesture:(UIButton *)sender {
    DDLogVerbose(@"%@ handleCancelSelectModeTapGesture: %@", LOG_TAG, sender);
    
    self.selectItemMode = NO;
    self.itemSelectedActionContainerView.hidden = YES;
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.videoCallBarButtonItem, self.audioCallBarButtonItem, nil];
    [self setTextInputbarHidden:NO animated:NO height:self.textInputBarHeight];
    [self updateSendButton:YES];
    self.sendButtonView.hidden = NO;
    self.menuButtonView.hidden = NO;
    [self resetSelectedItems];
    [self reloadData];
}

- (void)handleTitleTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleTitleTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        
        if (self.selectItemMode) {
            return;
        }
        
        if (!self.group) {
            TLContact *contact = (TLContact *)self.contact;
            if (contact.isTwinroom) {
                ShowRoomViewController *showRoomViewController = [[UIStoryboard storyboardWithName:@"Room" bundle:nil] instantiateViewControllerWithIdentifier:@"ShowRoomViewController"];
                [showRoomViewController initWithRoom:contact];
                [self.navigationController pushViewController:showRoomViewController animated:YES];
            } else {
                ShowContactViewController *showContactViewController = [[UIStoryboard storyboardWithName:@"Contact" bundle:nil] instantiateViewControllerWithIdentifier:@"ShowContactViewController"];
                [showContactViewController initWithContact:contact];
                [self.navigationController pushViewController:showContactViewController animated:YES];
            }
        } else {
            ShowGroupViewController *showGroupViewController = [[UIStoryboard storyboardWithName:@"Group" bundle:nil] instantiateViewControllerWithIdentifier:@"ShowGroupViewController"];
            [showGroupViewController initWithGroup:self.group];
            [self.navigationController pushViewController:showGroupViewController animated:YES];
        }
    }
}

- (void)handleAudioTapGesture:(UIButton *)sender {
    DDLogVerbose(@"%@ handleAudioTapGesture: %@", LOG_TAG, sender);
    
    if (!self.twinmeApplication.inCall) {
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
    }
}

- (void)startAudioCallViewController {
    DDLogVerbose(@"%@ startAudioCallViewController", LOG_TAG);
    
    ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];        
    if (self.group && ![delegate.twinmeApplication isSubscribedWithFeature:TLTwinmeApplicationFeatureGroupCall]) {
        PremiumFeatureConfirmView *premiumFeatureConfirmView = [[PremiumFeatureConfirmView alloc] init];
        premiumFeatureConfirmView.confirmViewDelegate = self;
        
        TLSpaceSettings *spaceSettings;
        if (self.space) {
            spaceSettings = self.space.settings;
            if ([self.space.settings getBooleanWithName:PROPERTY_DEFAULT_APPEARANCE_SETTINGS defaultValue:YES]) {
                spaceSettings = self.twinmeContext.defaultSpaceSettings;
            }
        } else {
            spaceSettings = self.twinmeContext.defaultSpaceSettings;
        }
        
        [premiumFeatureConfirmView initWithPremiumFeature:[[UIPremiumFeature alloc]initWithFeatureType:FeatureTypeGroupCall spaceSettings:spaceSettings] parentViewController:self.navigationController];
        [self.navigationController.view addSubview:premiumFeatureConfirmView];
        [premiumFeatureConfirmView showConfirmView];
        return;
    }
    
    CallViewController *callViewController = (CallViewController *)[[UIStoryboard storyboardWithName:@"Call" bundle:nil] instantiateViewControllerWithIdentifier:@"CallViewController"];
    if (self.group) {
        [callViewController startCallWithOriginator:self.group videoBell:NO isVideoCall:NO isCertifyCall:NO];
    } else {
        [callViewController startCallWithOriginator:self.contact videoBell:NO isVideoCall:NO isCertifyCall:NO];
    }
    
    [self.navigationController pushViewController:callViewController animated:YES];
}

- (void)handleVideoTapGesture:(UIButton *)sender {
    DDLogVerbose(@"%@ handleVideoTapGesture: %@", LOG_TAG, sender);
    
    if (!self.twinmeApplication.inCall) {
        [self startVideoCallWithPermissionCheck:NO];
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
    
    ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
    if (self.group && ![delegate.twinmeApplication isSubscribedWithFeature:TLTwinmeApplicationFeatureGroupCall]) {
        PremiumFeatureConfirmView *premiumFeatureConfirmView = [[PremiumFeatureConfirmView alloc] init];
        premiumFeatureConfirmView.confirmViewDelegate = self;
        
        TLSpaceSettings *spaceSettings;
        if (self.space) {
            spaceSettings = self.space.settings;
            if ([self.space.settings getBooleanWithName:PROPERTY_DEFAULT_APPEARANCE_SETTINGS defaultValue:YES]) {
                spaceSettings = self.twinmeContext.defaultSpaceSettings;
            }
        } else {
            spaceSettings = self.twinmeContext.defaultSpaceSettings;
        }
        
        [premiumFeatureConfirmView initWithPremiumFeature:[[UIPremiumFeature alloc]initWithFeatureType:FeatureTypeGroupCall spaceSettings:spaceSettings] parentViewController:self.navigationController];
        [self.navigationController.view addSubview:premiumFeatureConfirmView];
        [premiumFeatureConfirmView showConfirmView];
        return;
    }
    
    CallViewController *callViewController = (CallViewController *)[[UIStoryboard storyboardWithName:@"Call" bundle:nil] instantiateViewControllerWithIdentifier:@"CallViewController"];
    if (self.group) {
        [callViewController startCallWithOriginator:self.group videoBell:videoBell isVideoCall:YES isCertifyCall:NO];
    } else {
        [callViewController startCallWithOriginator:self.contact videoBell:videoBell isVideoCall:YES isCertifyCall:NO];
    }
    [self.navigationController pushViewController:callViewController animated:YES];
}

- (void)resetConversation {
    DDLogVerbose(@"%@ resetConversation", LOG_TAG);
    
    NSString *alertMessage = TwinmeLocalizedString(@"main_view_controller_reset_conversation_message", nil);
    if (self.group) {
        if (self.group.isOwner) {
            alertMessage = TwinmeLocalizedString(@"main_view_controller_reset_group_conversation_admin_message", nil);
        } else {
            alertMessage = TwinmeLocalizedString(@"main_view_controller_reset_group_conversation_message", nil);
        }
    }
    
    ResetConversationConfirmView *resetConversationConfirmView = [[ResetConversationConfirmView alloc] init];
    resetConversationConfirmView.confirmViewDelegate = self;
    [resetConversationConfirmView initWithTitle:TwinmeLocalizedString(@"delete_account_view_controller_warning", nil) message:alertMessage avatar:self.contactAvatar icon:[UIImage imageNamed:@"ActionBarDelete"]];
    [self.navigationController.view addSubview:resetConversationConfirmView];
    [resetConversationConfirmView showConfirmView];
}

- (void)getPreviousDescriptors {
    DDLogVerbose(@"%@ getPreviousDescriptors", LOG_TAG);
    
    [self.conversationService getPreviousDescriptors];
}

- (void)addObjectDescriptor:(TLObjectDescriptor *)objectDescriptor {
    DDLogVerbose(@"%@ addObjectDescriptor: %@", LOG_TAG, objectDescriptor);
    
    if ([self.conversationService isLocalDescriptor:objectDescriptor]) {
        if (self.twinmeApplication.visualizationLink) {
            if (@available(iOS 13, *)) {
                NSError *error = nil;
                NSDataDetector *dataDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
                NSString *content = objectDescriptor.message;
                
                NSTextCheckingResult *firstMatch = [dataDetector firstMatchInString:content options:0 range:NSMakeRange(0, [content length])];
                if (firstMatch) {
                    LinkItem *linkItem = [[LinkItem alloc] initWithObjectDescriptor:objectDescriptor replyToDescriptor:objectDescriptor.replyToDescriptor url:[firstMatch URL]];
                    [self addItem:linkItem];
                    return;
                }
            }
        }
        
        MessageItem *messageItem = [[MessageItem alloc] initWithObjectDescriptor:objectDescriptor replyToDescriptor:objectDescriptor.replyToDescriptor];
        [self addItem:messageItem];
    } else if ([self.conversationService isPeerDescriptor:objectDescriptor]) {
        if (self.twinmeApplication.visualizationLink) {
            if (@available(iOS 13, *)) {
                NSError *error = nil;
                NSDataDetector *dataDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
                NSString *content = objectDescriptor.message;
                
                NSTextCheckingResult *firstMatch = [dataDetector firstMatchInString:content options:0 range:NSMakeRange(0, [content length])];
                if (firstMatch) {
                    PeerLinkItem *peerLinkItem = [[PeerLinkItem alloc] initWithObjectDescriptor:objectDescriptor replyToDescriptor:objectDescriptor.replyToDescriptor url:[firstMatch URL]];
                    [self addItem:peerLinkItem];
                    return;
                }
            }
        }
        
        PeerMessageItem *peerMessageItem = [[PeerMessageItem alloc] initWithObjectDescriptor:objectDescriptor replyToDescriptor:objectDescriptor.replyToDescriptor];
        [self addItem:peerMessageItem];
    } else {
        [self.twinmeContext assertionWithAssertPoint:[ApplicationAssertPoint INVALID_DESCRIPTOR], [TLAssertValue initWithSubject:self.contact], [TLAssertValue initWithTwincodeId:objectDescriptor.descriptorId.twincodeOutboundId], [TLAssertValue initWithNumber:[objectDescriptor getType]], [TLAssertValue initWithTwincodeId:[self.conversationService debugGetTwincodeOutboundId]], [TLAssertValue initWithTwincodeId:[self.conversationService debugGetPeerTwincodeOutboundId]], nil];
    }
}

- (void)addImageDescriptor:(TLImageDescriptor *)imageDescriptor {
    DDLogVerbose(@"%@ addImageDescriptor: %@", LOG_TAG, imageDescriptor);
    
    if ([self.conversationService isLocalDescriptor:imageDescriptor]) {
        ImageItem *imageItem = [[ImageItem alloc] initWithImageDescriptor:imageDescriptor replyToDescriptor:imageDescriptor.replyToDescriptor];
        [self addItem:imageItem];
    } else if ([self.conversationService isPeerDescriptor:imageDescriptor]) {
        PeerImageItem *peerImageItem = [[PeerImageItem alloc] initWithImageDescriptor:imageDescriptor replyToDescriptor:imageDescriptor.replyToDescriptor];
        [self addItem:peerImageItem];
    } else {
        [self.twinmeContext assertionWithAssertPoint:[ApplicationAssertPoint INVALID_DESCRIPTOR], [TLAssertValue initWithSubject:self.contact], [TLAssertValue initWithTwincodeId:imageDescriptor.descriptorId.twincodeOutboundId], [TLAssertValue initWithNumber:[imageDescriptor getType]], [TLAssertValue initWithTwincodeId:[self.conversationService debugGetTwincodeOutboundId]], [TLAssertValue initWithTwincodeId:[self.conversationService debugGetPeerTwincodeOutboundId]], nil];
    }
}

- (void)addAudioDescriptor:(TLAudioDescriptor *)audioDescriptor {
    DDLogVerbose(@"%@ addAudioDescriptor: %@", LOG_TAG, audioDescriptor);
    
    if ([self.conversationService isLocalDescriptor:audioDescriptor]) {
        AudioItem *fileItem = [[AudioItem alloc] initWithAudioDescriptor:audioDescriptor replyToDescriptor:audioDescriptor.replyToDescriptor];
        [self addItem:fileItem];
    } else if ([self.conversationService isPeerDescriptor:audioDescriptor]) {
        PeerAudioItem *peerFileItem = [[PeerAudioItem alloc] initWithAudioDescriptor:audioDescriptor replyToDescriptor:audioDescriptor.replyToDescriptor];
        [self addItem:peerFileItem];
    } else {
        [self.twinmeContext assertionWithAssertPoint:[ApplicationAssertPoint INVALID_DESCRIPTOR], [TLAssertValue initWithSubject:self.contact], [TLAssertValue initWithTwincodeId:audioDescriptor.descriptorId.twincodeOutboundId], [TLAssertValue initWithNumber:[audioDescriptor getType]], [TLAssertValue initWithTwincodeId:[self.conversationService debugGetTwincodeOutboundId]], [TLAssertValue initWithTwincodeId:[self.conversationService debugGetPeerTwincodeOutboundId]], nil];
    }
}

- (void)addVideoDescriptor:(TLVideoDescriptor *)videoDescriptor {
    DDLogVerbose(@"%@ addVideoDescriptor: %@", LOG_TAG, videoDescriptor);
    
    if ([self.conversationService isLocalDescriptor:videoDescriptor]) {
        VideoItem *videoItem = [[VideoItem alloc] initWithVideoDescriptor:videoDescriptor replyToDescriptor:videoDescriptor.replyToDescriptor];
        [self addItem:videoItem];
    } else if ([self.conversationService isPeerDescriptor:videoDescriptor]) {
        PeerVideoItem *peerVideoItem = [[PeerVideoItem alloc] initWithVideoDescriptor:videoDescriptor replyToDescriptor:videoDescriptor.replyToDescriptor];
        [self addItem:peerVideoItem];
    } else {
        [self.twinmeContext assertionWithAssertPoint:[ApplicationAssertPoint INVALID_DESCRIPTOR], [TLAssertValue initWithSubject:self.contact], [TLAssertValue initWithTwincodeId:videoDescriptor.descriptorId.twincodeOutboundId], [TLAssertValue initWithNumber:[videoDescriptor getType]], [TLAssertValue initWithTwincodeId:[self.conversationService debugGetTwincodeOutboundId]], [TLAssertValue initWithTwincodeId:[self.conversationService debugGetPeerTwincodeOutboundId]], nil];
    }
}

- (void)addNamedFileDescriptor:(TLNamedFileDescriptor *)namedFileDescriptor {
    DDLogVerbose(@"%@ addNamedFileDescriptor: %@", LOG_TAG, namedFileDescriptor);
    
    if ([self.conversationService isLocalDescriptor:namedFileDescriptor]) {
        FileItem *fileItem = [[FileItem alloc] initWithNamedFileDescriptor:namedFileDescriptor replyToDescriptor:namedFileDescriptor.replyToDescriptor];
        [self addItem:fileItem];
    } else if ([self.conversationService isPeerDescriptor:namedFileDescriptor]) {
        PeerFileItem *peerFileItem = [[PeerFileItem alloc] initWithFileDescriptor:namedFileDescriptor replyToDescriptor:namedFileDescriptor.replyToDescriptor];
        [self addItem:peerFileItem];
    } else {
        [self.twinmeContext assertionWithAssertPoint:[ApplicationAssertPoint INVALID_DESCRIPTOR], [TLAssertValue initWithSubject:self.contact], [TLAssertValue initWithTwincodeId:namedFileDescriptor.descriptorId.twincodeOutboundId], [TLAssertValue initWithNumber:[namedFileDescriptor getType]], [TLAssertValue initWithTwincodeId:[self.conversationService debugGetTwincodeOutboundId]], [TLAssertValue initWithTwincodeId:[self.conversationService debugGetPeerTwincodeOutboundId]], nil];
    }
}

- (void)addInvitationDescriptor:(TLInvitationDescriptor *)invitationDescriptor {
    DDLogVerbose(@"%@ addInvitationDescriptor: %@", LOG_TAG, invitationDescriptor);
    
    if ([self.conversationService isLocalDescriptor:invitationDescriptor]) {
        InvitationItem *invitationItem = [[InvitationItem alloc] initWithInvitationDescriptor:invitationDescriptor conversationId:self.conversationId];
        [self addItem:invitationItem];
    } else if ([self.conversationService isPeerDescriptor:invitationDescriptor]) {
        PeerInvitationItem *peerInvitationItem = [[PeerInvitationItem alloc] initWithInvitationDescriptor:invitationDescriptor conversationId:self.conversationId];
        [self addItem:peerInvitationItem];
    } else {
        [self.twinmeContext assertionWithAssertPoint:[ApplicationAssertPoint INVALID_DESCRIPTOR], [TLAssertValue initWithSubject:self.contact], [TLAssertValue initWithTwincodeId:invitationDescriptor.descriptorId.twincodeOutboundId], [TLAssertValue initWithNumber:[invitationDescriptor getType]], [TLAssertValue initWithTwincodeId:[self.conversationService debugGetTwincodeOutboundId]], [TLAssertValue initWithTwincodeId:[self.conversationService debugGetPeerTwincodeOutboundId]], nil];
    }
}

- (void)addCallDescriptor:(TLCallDescriptor *)callDescriptor {
    DDLogVerbose(@"%@ addCallDescriptor: %@", LOG_TAG, callDescriptor);
    
    Item *item = callDescriptor.isIncoming ? [[PeerCallItem alloc] initWithCallDescriptor:callDescriptor] : [[CallItem alloc] initWithCallDescriptor:callDescriptor];
    [self addItem:item];
}

- (void)addTwincodeDescriptor:(TLTwincodeDescriptor *)twincodeDescriptor {
    DDLogVerbose(@"%@ addTwincodeDescriptor: %@", LOG_TAG, twincodeDescriptor);
    
    if ([self.conversationService isLocalDescriptor:twincodeDescriptor]) {
        InvitationContactItem *invitationItem = [[InvitationContactItem alloc] initWithTwincodeDescriptor:twincodeDescriptor];
        [self addItem:invitationItem];
    } else if ([self.conversationService isPeerDescriptor:twincodeDescriptor]) {
        PeerInvitationContactItem *peerInvitationItem = [[PeerInvitationContactItem alloc] initWithTwincodeDescriptor:twincodeDescriptor];
        [self addItem:peerInvitationItem];
    } else {
        [self.twinmeContext assertionWithAssertPoint:[ApplicationAssertPoint INVALID_DESCRIPTOR], [TLAssertValue initWithSubject:self.contact], [TLAssertValue initWithTwincodeId:twincodeDescriptor.descriptorId.twincodeOutboundId], [TLAssertValue initWithNumber:[twincodeDescriptor getType]], [TLAssertValue initWithTwincodeId:[self.conversationService debugGetTwincodeOutboundId]], [TLAssertValue initWithTwincodeId:[self.conversationService debugGetPeerTwincodeOutboundId]], nil];
    }
}

- (void)addGeolocationDescriptor:(TLGeolocationDescriptor *)geolocationDescriptor {
    DDLogVerbose(@"%@ addGeolocationDescriptor: %@", LOG_TAG, geolocationDescriptor);
    
    if ([self.conversationService isLocalDescriptor:geolocationDescriptor]) {
        TLDescriptor *replyToDescriptor;
        if (geolocationDescriptor.replyTo) {
            replyToDescriptor = [[self.twinmeContext getConversationService] getDescriptorWithDescriptorId:geolocationDescriptor.replyTo];
        }
        LocationItem *locationItem = [[LocationItem alloc] initWithGeolocationDescriptor:geolocationDescriptor replyToDescriptor:replyToDescriptor];
        [self addItem:locationItem];
    } else if ([self.conversationService isPeerDescriptor:geolocationDescriptor]) {
        TLDescriptor *replyToDescriptor;
        if (geolocationDescriptor.replyTo) {
            replyToDescriptor = [[self.twinmeContext getConversationService] getDescriptorWithDescriptorId:geolocationDescriptor.replyTo];
        }
        PeerLocationItem *peerLocationItem = [[PeerLocationItem alloc] initWithGeolocationDescriptor:geolocationDescriptor replyToDescriptor:replyToDescriptor];
        [self addItem:peerLocationItem];
    } else {
        [self.twinmeContext assertionWithAssertPoint:[ApplicationAssertPoint INVALID_DESCRIPTOR], [TLAssertValue initWithSubject:self.contact], [TLAssertValue initWithTwincodeId:geolocationDescriptor.descriptorId.twincodeOutboundId], [TLAssertValue initWithNumber:[geolocationDescriptor getType]], [TLAssertValue initWithTwincodeId:[self.conversationService debugGetTwincodeOutboundId]], [TLAssertValue initWithTwincodeId:[self.conversationService debugGetPeerTwincodeOutboundId]], nil];
    }
}

- (void)addClearDescriptor:(TLClearDescriptor *)clearDescriptor {
    DDLogVerbose(@"%@ addClearDescriptor: %@", LOG_TAG, clearDescriptor);
    
    if ([self.conversationService isLocalDescriptor:clearDescriptor]) {
        ClearItem *clearItem = [[ClearItem alloc] initWithClearDescriptor:clearDescriptor];
        [self addItem:clearItem];
    } else if ([self.conversationService isPeerDescriptor:clearDescriptor]) {
        PeerClearItem *peerClearItem = [[PeerClearItem alloc] initWithClearDescriptor:clearDescriptor];
        
        NSString *name = @"";
        if (self.group) {
            TLGroupMember *member = [self.groupMembers objectForKey:peerClearItem.peerTwincodeOutboundId];
            name = member.name;
        } else {
            name = self.contactName;
        }
        
        peerClearItem.name = name;
        [self addItem:peerClearItem];
    } else {
        [self.twinmeContext assertionWithAssertPoint:[ApplicationAssertPoint INVALID_DESCRIPTOR], [TLAssertValue initWithSubject:self.contact], [TLAssertValue initWithTwincodeId:clearDescriptor.descriptorId.twincodeOutboundId], [TLAssertValue initWithNumber:[clearDescriptor getType]], [TLAssertValue initWithTwincodeId:[self.conversationService debugGetTwincodeOutboundId]], [TLAssertValue initWithTwincodeId:[self.conversationService debugGetPeerTwincodeOutboundId]], nil];
    }
}

- (void)addTransientObjectDescriptor:(TLTransientObjectDescriptor *)transientObjectDescriptor {
    DDLogVerbose(@"%@ addTransientObjectDescriptor: %@", LOG_TAG, transientObjectDescriptor);
    
    NSObject *object = transientObjectDescriptor.object;
    
    if ([object isKindOfClass:[TLTyping class]]) {
        TLTyping *typing = (TLTyping *)object;
        NSUUID *twincodeOutboundId = transientObjectDescriptor.descriptorId.twincodeOutboundId;
        
        if (typing.action == TLTypingActionStart) {
            if (self.group) {
                if (self.groupMembers && [self.groupMembers objectForKey:twincodeOutboundId]) {
                    TLGroupMember *member = [self.groupMembers objectForKey:twincodeOutboundId];
                    if (![self.typingOriginators containsObject:member]) {
                        [self.typingOriginators addObject:member];
                    }
                }
            } else {
                if (![self.typingOriginators containsObject:self.contact]) {
                    [self.typingOriginators addObject:self.contact];
                }
            }
        } else {
            if (self.group) {
                if (self.groupMembers && [self.groupMembers objectForKey:twincodeOutboundId]) {
                    TLGroupMember *member = [self.groupMembers objectForKey:twincodeOutboundId];
                    if ([self.typingOriginators containsObject:member]) {
                        [self.typingOriginators removeObject:member];
                    }
                }
            } else {
                if ([self.typingOriginators containsObject:self.contact]) {
                    [self.typingOriginators removeObject:self.contact];
                }
            }
        }
        
        self.isPeerTyping = self.typingOriginators.count > 0;
        if (self.isPeerTyping) {
            self.isPeerTyping = YES;
            [self.conversationService getImagesWithOriginators:self.typingOriginators withBlock:^(NSMutableArray<UIImage *> *images) {
                self.typingOriginatorImages = images;
                [self.typingView setOriginators:self.typingOriginatorImages];
            }];
            
            if (self.peerTypingTimer) {
                [self.peerTypingTimer invalidate];
            }
            self.peerTypingTimer = [NSTimer scheduledTimerWithTimeInterval:TYPING_PEER_TIMER_DURATION target:self selector:@selector(peerTypingFire:) userInfo:nil repeats:NO];
        } else {
            self.isPeerTyping = NO;
            self.tableView.tableHeaderView = nil;
        }
        
        [self setupTableHeaderView];
    }
}

- (void)addItem:(Item *)item {
    DDLogVerbose(@"%@ addItem: %@", LOG_TAG, item);
    
    if (item.descriptorId.sequenceId != ITEM_DEFAULT_SEQUENCE_ID) {
        for (Item *lItem in self.items) {
            if ([lItem.descriptorId isEqual:item.descriptorId]) {
                return;
            }
        }
    }
    
    Item *lastReadPeerItem = nil;
    int64_t lastReadPeerItemTimestamp = self.lastReadPeerItem ? self.lastReadPeerItem.timestamp : -1;
    NSInteger itemIndex = -1;
    if (![item isPeerItem] && item.readTimestamp != 0 && item.readTimestamp != -1) {
        if (item.timestamp < lastReadPeerItemTimestamp) {
            [item resetState];
        } else if (item.timestamp > lastReadPeerItemTimestamp) {
            lastReadPeerItem = self.lastReadPeerItem;
            self.lastReadPeerItem = item;
        }
    }
    
    // Postpone item insertion
    for (NSInteger index = self.items.count - 1; index >= 0; index--) {
        Item *lItem = [self.items objectAtIndex:index];
        if ([lItem compareWithItem:item] != NSOrderedDescending) {
            itemIndex = index + 1;
            break;
        }
    }
    
    if (itemIndex == -1) {
        itemIndex = 0;
    }
    
    NSInteger previousItemIndex = -1;
    Item *previousItem = nil;
    if (itemIndex - 1 >= 0) {
        previousItemIndex = itemIndex - 1;
        previousItem = [self.items objectAtIndex:previousItemIndex];
    }
    
    NSInteger nextItemIndex = - 1;
    Item *nextItem = nil;
    if (itemIndex < self.items.count) {
        nextItemIndex = itemIndex;
        nextItem = [self.items objectAtIndex:nextItemIndex];
    }
    
    if (nextItem && nextItem.type == ItemTypeTime) {
        Item *nextNextItem = nil;
        if (itemIndex + 1 < self.items.count) {
            nextNextItem = [self.items objectAtIndex:itemIndex + 1];
            if (nextNextItem.timestamp - item.timestamp < DESIGN_MAX_DELTA_TIMESTAMP2) {
                nextItem = nextNextItem;
                if (self.batchUpdate) {
                    [self.items removeObjectAtIndex:itemIndex];
                } else {
                    [self.tableView beginUpdates];
                    [self.items removeObjectAtIndex:itemIndex];
                    NSIndexPath *indexPathToDelete = [self itemIndexToIndexPath:itemIndex];
                    [self.tableView deleteRowsAtIndexPaths:@[indexPathToDelete] withRowAnimation:UITableViewRowAnimationNone];
                    [self.tableView endUpdates];
                }
            }
        }
    }
    
    if (nextItem &&  nextItem.type == ItemTypeName) {
        Item *nextNextItem = nil;
        if (itemIndex + 1 < self.items.count) {
            nextNextItem = [self.items objectAtIndex:itemIndex + 1];
            if ([item isPeerItem] && [item isSamePeer:nextNextItem]) {
                nextItem = nextNextItem;
                if (self.batchUpdate) {
                    [self.items removeObjectAtIndex:itemIndex];
                } else {
                    [self.tableView beginUpdates];
                    [self.items removeObjectAtIndex:itemIndex];
                    NSIndexPath *indexPathToDelete = [self itemIndexToIndexPath:itemIndex];
                    [self.tableView deleteRowsAtIndexPaths:@[indexPathToDelete] withRowAnimation:UITableViewRowAnimationNone];
                    [self.tableView endUpdates];
                }
            }
        }
    }
    
    if (self.groupMembers) {
        if (nextItem && [nextItem isPeerItem] && ![item isPeerItem]) {
            if (self.groupMembers && [self.groupMembers objectForKey:nextItem.peerTwincodeOutboundId]) {
                TLGroupMember *member = [self.groupMembers objectForKey:nextItem.peerTwincodeOutboundId];
                NameItem *nameItem = [[NameItem alloc] initWithTimestamp:nextItem.timestamp name:member.name];
                if (self.batchUpdate) {
                    [self.items insertObject:nameItem atIndex:itemIndex];
                } else {
                    
                    [self.tableView beginUpdates];
                    [self.items insertObject:nameItem atIndex:itemIndex];
                    NSIndexPath *indexPath = [self itemIndexToIndexPath:itemIndex];
                    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
                    [self.tableView endUpdates];
                }
            }
        }
    }
    
    switch (item.type) {
        case ItemTypeMessage:
        case ItemTypeLink:
        case ItemTypeImage:
        case ItemTypeAudio:
        case ItemTypeVideo:
        case ItemTypeFile:
        case ItemTypeInvitation:
        case ItemTypeCall:
        case ItemTypeLocation:
        case ItemTypeInvitationContact: {
            if (previousItem) {
                switch (previousItem.type) {
                    case ItemTypeMessage:
                    case ItemTypeLink:
                    case ItemTypeImage:
                    case ItemTypeAudio:
                    case ItemTypeVideo:
                    case ItemTypeFile:
                    case ItemTypeInvitation:
                    case ItemTypeLocation:
                    case ItemTypeCall:
                    case ItemTypeInvitationContact: {
                        if (item.timestamp - previousItem.timestamp < DESIGN_MAX_DELTA_TIMESTAMP1) {
                            previousItem.corners &= ~ITEM_BOTTOM_RIGHT;
                            item.corners &= ~ITEM_TOP_RIGHT;
                        } else {
                            previousItem.corners |= ITEM_BOTTOM_RIGHT;
                        }
                        break;
                    }
                        
                    case ItemTypePeerMessage:
                    case ItemTypePeerLink:
                    case ItemTypePeerImage:
                    case ItemTypePeerAudio:
                    case ItemTypePeerVideo:
                    case ItemTypePeerFile:
                    case ItemTypePeerInvitation:
                    case ItemTypePeerCall:
                    case ItemTypePeerLocation:
                    case ItemTypePeerInvitationContact: {
                        previousItem.corners |= ITEM_BOTTOM_LEFT;
                        previousItem.visibleAvatar = YES;
                        item.corners |= ITEM_TOP_RIGHT;
                        break;
                    }
                        
                    default:
                        break;
                }
            }
            
            if (nextItem) {
                switch (nextItem.type) {
                    case ItemTypeMessage:
                    case ItemTypeLink:
                    case ItemTypeImage:
                    case ItemTypeAudio:
                    case ItemTypeVideo:
                    case ItemTypeFile:
                    case ItemTypeInvitation:
                    case ItemTypeCall:
                    case ItemTypeLocation:
                    case ItemTypeInvitationContact:
                        if (nextItem.timestamp - item.timestamp < DESIGN_MAX_DELTA_TIMESTAMP1) {
                            item.corners &= ~ITEM_BOTTOM_RIGHT;
                            nextItem.corners &= ~ITEM_TOP_RIGHT;
                        } else {
                            nextItem.corners |= ITEM_TOP_RIGHT;
                        }
                        break;
                        
                    case ItemTypePeerMessage:
                    case ItemTypePeerLink:
                    case ItemTypePeerImage:
                    case ItemTypePeerAudio:
                    case ItemTypePeerVideo:
                    case ItemTypePeerFile:
                    case ItemTypePeerInvitation:
                    case ItemTypePeerCall:
                    case ItemTypePeerLocation:
                    case ItemTypePeerInvitationContact: {
                        item.corners |= ITEM_BOTTOM_RIGHT;
                        nextItem.corners |= ITEM_TOP_LEFT;
                        break;
                    }
                        
                    default:
                        break;
                }
            }
            break;
        }
            
        case ItemTypePeerMessage:
        case ItemTypePeerLink:
        case ItemTypePeerImage:
        case ItemTypePeerAudio:
        case ItemTypePeerVideo:
        case ItemTypePeerFile:
        case ItemTypePeerInvitation:
        case ItemTypePeerLocation:
        case ItemTypePeerCall:
        case ItemTypePeerInvitationContact: {
            item.visibleAvatar = YES;
            if (previousItem) {
                switch (previousItem.type) {
                    case ItemTypeMessage:
                    case ItemTypeLink:
                    case ItemTypeImage:
                    case ItemTypeAudio:
                    case ItemTypeVideo:
                    case ItemTypeFile:
                    case ItemTypeInvitation:
                    case ItemTypeCall:
                    case ItemTypeLocation:
                    case ItemTypeInvitationContact: {
                        previousItem.corners |= ITEM_BOTTOM_RIGHT;
                        item.corners |= ITEM_TOP_LEFT;
                        break;
                    }
                        
                    case ItemTypePeerMessage:
                    case ItemTypePeerLink:
                    case ItemTypePeerImage:
                    case ItemTypePeerAudio:
                    case ItemTypePeerVideo:
                    case ItemTypePeerFile:
                    case ItemTypePeerInvitation:
                    case ItemTypePeerCall:
                    case ItemTypePeerLocation:
                    case ItemTypePeerInvitationContact:
                        if (item.timestamp - previousItem.timestamp < DESIGN_MAX_DELTA_TIMESTAMP1) {
                            previousItem.corners &= ~ITEM_BOTTOM_LEFT;
                            previousItem.visibleAvatar = NO;
                            item.corners &= ~ITEM_TOP_LEFT;
                        } else {
                            previousItem.corners |= ITEM_BOTTOM_LEFT;
                            previousItem.visibleAvatar = YES;
                        }
                        break;
                        
                    default:
                        break;
                }
            }
            if (nextItem) {
                switch (nextItem.type) {
                    case ItemTypeMessage:
                    case ItemTypeLink:
                    case ItemTypeImage:
                    case ItemTypeAudio:
                    case ItemTypeVideo:
                    case ItemTypeFile:
                    case ItemTypeInvitation:
                    case ItemTypeCall:
                    case ItemTypeLocation:
                    case ItemTypeInvitationContact: {
                        item.corners |= ITEM_BOTTOM_LEFT;
                        nextItem.corners |= ITEM_TOP_RIGHT;
                        break;
                    }
                        
                    case ItemTypePeerMessage:
                    case ItemTypePeerLink:
                    case ItemTypePeerImage:
                    case ItemTypePeerAudio:
                    case ItemTypePeerVideo:
                    case ItemTypePeerFile:
                    case ItemTypePeerInvitation:
                    case ItemTypePeerCall:
                    case ItemTypePeerLocation:
                    case ItemTypePeerInvitationContact:
                        if (nextItem.timestamp - item.timestamp < DESIGN_MAX_DELTA_TIMESTAMP1) {
                            item.corners &= ~ITEM_BOTTOM_LEFT;
                            item.visibleAvatar = NO;
                            nextItem.corners &= ~ITEM_TOP_LEFT;
                        } else {
                            item.visibleAvatar = NO;
                            nextItem.corners |= ITEM_TOP_LEFT;
                        }
                        break;
                        
                    default:
                        break;
                }
            }
            break;
        }
            
        default:
            break;
    }
    
    if (lastReadPeerItem) {
        for (NSInteger index = self.items.count - 1; index >= 0; index--) {
            Item *lItem = [self.items objectAtIndex:index];
            if (lItem == lastReadPeerItem) {
                [lItem resetState];
                break;
            }
        }
    }
    
    BOOL addTime = NO;
    
    if (previousItem) {
        Item *lastTimeItem = nil;
        for (NSInteger index = itemIndex-1; index >= 0; index--) {
            Item *lItem = [self.items objectAtIndex:index];
            if (lItem.type == ItemTypeTime) {
                lastTimeItem = lItem;
                break;
            }
        }
        addTime = item.type != ItemTypeTime && previousItem.type != ItemTypeTime &&
        item.timestamp - lastTimeItem.timestamp > DESIGN_MAX_DELTA_TIMESTAMP2;
    } else {
        addTime = YES;
    }
    
    if (addTime) {
        if (self.batchUpdate) {
            [self.items insertObject:[[TimeItem alloc]initWithTimestamp:item.timestamp] atIndex:itemIndex];
        } else {
            [self.tableView beginUpdates];
            [self.items insertObject:[[TimeItem alloc]initWithTimestamp:item.timestamp] atIndex:itemIndex];
            NSIndexPath *indexPath = [self itemIndexToIndexPath:itemIndex];
            [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
            [self.tableView endUpdates];
        }
        itemIndex++;
    }
    
    BOOL addName = NO;
    if ([item isPeerItem] && item.type != ItemTypePeerClear) {
        if (addTime || !previousItem || (previousItem && (![previousItem isPeerItem] || ![previousItem isSamePeer:item] || previousItem.type == ItemTypeInfoPrivacy))) {
            if (self.groupMembers && [self.groupMembers objectForKey:item.peerTwincodeOutboundId]) {
                addName = YES;
                if (!self.batchUpdate) {
                    item.corners = ITEM_TOP_LEFT | ITEM_TOP_RIGHT | ITEM_BOTTOM_LEFT | ITEM_BOTTOM_RIGHT;
                }
            }
        }
    }
    
    if (addName) {
        TLGroupMember *member = [self.groupMembers objectForKey:item.peerTwincodeOutboundId];
        NameItem *nameItem = [[NameItem alloc]initWithTimestamp:item.timestamp name:member.name];
        
        if (self.batchUpdate) {
            [self.items insertObject:nameItem atIndex:itemIndex];
        } else {
            [self.tableView beginUpdates];
            [self.items insertObject:nameItem atIndex:itemIndex];
            NSIndexPath *indexPath = [self itemIndexToIndexPath:itemIndex];
            [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
            [self.tableView endUpdates];
        }
        itemIndex++;
    }
    
    BOOL addNameAfter = NO;
    if (nextItem) {
        if ([nextItem isPeerItem] && ![nextItem isSamePeer:item]) {
            if (self.groupMembers && [self.groupMembers objectForKey:item.peerTwincodeOutboundId]) {
                addNameAfter = YES;
                if (!self.batchUpdate) {
                    item.corners = ITEM_TOP_LEFT | ITEM_TOP_RIGHT | ITEM_BOTTOM_LEFT | ITEM_BOTTOM_RIGHT;
                }
            }
        }
    }
    
    if (addNameAfter) {
        TLGroupMember *member = [self.groupMembers objectForKey:nextItem.peerTwincodeOutboundId];
        NameItem *nameItem = [[NameItem alloc]initWithTimestamp:nextItem.timestamp name:member.name];
        
        if (self.batchUpdate) {
            [self.items insertObject:nameItem atIndex:itemIndex];
        } else {
            [self.tableView beginUpdates];
            [self.items insertObject:nameItem atIndex:itemIndex];
            NSIndexPath *indexPath = [self itemIndexToIndexPath:itemIndex];
            [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
            [self.tableView endUpdates];
        }
    }
    
    if (self.batchUpdate) {
        [self.items insertObject:item atIndex:itemIndex];
    } else {
        [self.tableView beginUpdates];
        [self.items insertObject:item atIndex:itemIndex];
        NSIndexPath *indexPath = [self itemIndexToIndexPath:itemIndex];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        if (self.items.count > 1) {
            NSIndexPath *indexPathPrev = [self itemIndexToIndexPath:itemIndex-1];
            [self.tableView reloadRowsAtIndexPaths:@[indexPathPrev] withRowAnimation:UITableViewRowAnimationNone];
        }
        if (self.items.count > itemIndex + 1) {
            NSIndexPath *indexPathNext = [self itemIndexToIndexPath:itemIndex+1];
            [self.tableView reloadRowsAtIndexPaths:@[indexPathNext] withRowAnimation:UITableViewRowAnimationNone];
        }

        [self hapticFeedback];
    }
    
    if (self.items.count == 0) {
        self.emptyConversationLabel.hidden = NO;
    } else {
        self.emptyConversationLabel.hidden = YES;
    }
}

- (void)deleteItemInternal:(Item *)item {
    DDLogVerbose(@"%@ deleteItemInternal: %@", LOG_TAG, item);
    
    NSInteger itemIndex = -1;
    for (Item *lItem in self.items) {
        itemIndex ++;
        if ([item.descriptorId isEqual:lItem.descriptorId]) {
            break;
        }
    }
    if (itemIndex < 0) {
        return;
    }
    
    NSInteger previousItemIndex = -1;
    Item *previousItem = nil;
    if (itemIndex >= 1) {
        previousItemIndex = itemIndex - 1;
        previousItem = [self.items objectAtIndex:previousItemIndex];
    }
    
    NSInteger nextItemIndex = - 1;
    Item *nextItem = nil;
    if (itemIndex + 1 < self.items.count) {
        nextItemIndex = itemIndex + 1;
        nextItem = [self.items objectAtIndex:nextItemIndex];
    }
    
    if (previousItem) {
        switch (previousItem.type) {
            case ItemTypeTime: {
                if (nextItem) {
                    nextItem.corners = item.corners;
                }
                break;
            }
                
            case ItemTypeMessage:
            case ItemTypeLink:
            case ItemTypeImage:
            case ItemTypeAudio:
            case ItemTypeVideo:
            case ItemTypeFile:
            case ItemTypeInvitation:
            case ItemTypeCall:
            case ItemTypeInvitationContact: {
                if (!nextItem) {
                    previousItem.corners &= ~ITEM_BOTTOM_RIGHT;
                    [previousItem updateState];
                } else if (![previousItem isSamePeer:nextItem]) {
                    previousItem.corners |= ITEM_BOTTOM_RIGHT;
                    nextItem.corners |= ITEM_TOP_RIGHT;
                } if (nextItem.timestamp - previousItem.timestamp < DESIGN_MAX_DELTA_TIMESTAMP1) {
                    previousItem.corners &= ~ITEM_BOTTOM_RIGHT;
                    nextItem.corners &= ~ITEM_TOP_RIGHT;
                } else {
                    previousItem.corners |= ITEM_BOTTOM_RIGHT;
                }
                break;
            }
                
            case ItemTypePeerMessage:
            case ItemTypePeerLink:
            case ItemTypePeerImage:
            case ItemTypePeerAudio:
            case ItemTypePeerVideo:
            case ItemTypePeerFile:
            case ItemTypePeerInvitation:
            case ItemTypePeerCall:
            case ItemTypePeerInvitationContact: {
                if (!nextItem) {
                    previousItem.corners |= ITEM_BOTTOM_LEFT;
                    previousItem.visibleAvatar = YES;
                } else if (![previousItem isSamePeer:nextItem]) {
                    previousItem.corners |= ITEM_BOTTOM_LEFT;
                    previousItem.visibleAvatar = YES;
                    nextItem.corners |= ITEM_TOP_LEFT;
                } else if (nextItem.timestamp - previousItem.timestamp < DESIGN_MAX_DELTA_TIMESTAMP1) {
                    previousItem.corners &= ~ITEM_BOTTOM_LEFT;
                    previousItem.visibleAvatar = NO;
                    nextItem.corners &= ~ITEM_TOP_LEFT;
                } else {
                    previousItem.corners |= ITEM_BOTTOM_LEFT;
                    previousItem.visibleAvatar = NO;
                    nextItem.corners |= ITEM_TOP_RIGHT;
                }
                break;
            }
                
            default:
                break;
        }
    }
    
    if (nextItem) {
        switch (nextItem.type) {
            case ItemTypeMessage:
            case ItemTypeLink:
            case ItemTypeImage:
            case ItemTypeAudio:
            case ItemTypeVideo:
            case ItemTypeFile:
            case ItemTypeInvitation:
            case ItemTypeCall:
            case ItemTypeInvitationContact:
                if (!previousItem) {
                    nextItem.corners |= ITEM_TOP_RIGHT;
                } else if (![previousItem isSamePeer:nextItem]) {
                    previousItem.corners |= ITEM_BOTTOM_RIGHT;
                    nextItem.corners |= ITEM_TOP_RIGHT;
                } else if (nextItem.timestamp - previousItem.timestamp < DESIGN_MAX_DELTA_TIMESTAMP1) {
                    previousItem.corners &= ~ITEM_BOTTOM_RIGHT;
                    nextItem.corners &= ~ITEM_TOP_RIGHT;
                } else {
                    nextItem.corners |= ITEM_TOP_RIGHT;
                }
                break;
                
            case ItemTypePeerMessage:
            case ItemTypePeerLink:
            case ItemTypePeerImage:
            case ItemTypePeerAudio:
            case ItemTypePeerVideo:
            case ItemTypePeerFile:
            case ItemTypePeerInvitation:
            case ItemTypePeerCall:
            case ItemTypePeerInvitationContact: {
                nextItem.corners |= ITEM_BOTTOM_RIGHT;
                nextItem.corners |= ITEM_TOP_LEFT;
                break;
            }
                
            default:
                break;
        }
    }
    
    if (self.batchUpdate) {
        [self.items removeObjectAtIndex:itemIndex];
    } else {
        if (previousItem && previousItem.state != ItemStateBothDeleted) {
            NSIndexPath *previousIndexPath = [self itemIndexToIndexPath:previousItemIndex];
            [self.tableView reloadRowsAtIndexPaths:@[previousIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
        if (nextItem && nextItem.state != ItemStateBothDeleted) {
            NSIndexPath *nextIndexPath = [self itemIndexToIndexPath:nextItemIndex];
            [self.tableView reloadRowsAtIndexPaths:@[nextIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
        
        NSIndexPath *indexPath = [self itemIndexToIndexPath:itemIndex];
        [self.tableView beginUpdates];
        [self.items removeObjectAtIndex:itemIndex];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
    
    if (previousItem && previousItem.type == ItemTypeTime) {
        if (itemIndex < self.items.count) {
            nextItem = [self.items objectAtIndex:itemIndex];
            if (nextItem.type == ItemTypeTime) {
                if (self.batchUpdate) {
                    [self.items removeObjectAtIndex:previousItemIndex];
                } else {
                    NSIndexPath *previousIndexPath = [self itemIndexToIndexPath:previousItemIndex];
                    [self.tableView beginUpdates];
                    [self.items removeObjectAtIndex:previousItemIndex];
                    [self.tableView deleteRowsAtIndexPaths:@[previousIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                    [self.tableView endUpdates];
                }
            }
        } else if (itemIndex == self.items.count) {
            if (self.batchUpdate) {
                [self.items removeObjectAtIndex:previousItemIndex];
            } else {
                NSIndexPath *previousIndexPath = [self itemIndexToIndexPath:previousItemIndex];
                [self.tableView beginUpdates];
                [self.items removeObjectAtIndex:previousItemIndex];
                [self.tableView deleteRowsAtIndexPaths:@[previousIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                [self.tableView endUpdates];
            }
        }
    }
    
    if (previousItem && previousItem.type == ItemTypeName) {
        if (itemIndex < self.items.count) {
            nextItem = [self.items objectAtIndex:itemIndex];
            if (![nextItem isPeerItem] || ([nextItem isPeerItem] && ![nextItem isSamePeer:item])) {
                if (self.batchUpdate) {
                    [self.items removeObjectAtIndex:previousItemIndex];
                } else {
                    NSIndexPath *previousIndexPath = [self itemIndexToIndexPath:previousItemIndex];
                    [self.tableView beginUpdates];
                    [self.items removeObjectAtIndex:previousItemIndex];
                    [self.tableView deleteRowsAtIndexPaths:@[previousIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                    [self.tableView endUpdates];
                }
            }
        } else if (itemIndex == self.items.count) {
            if (self.batchUpdate) {
                [self.items removeObjectAtIndex:previousItemIndex];
            } else {
                NSIndexPath *previousIndexPath = [self itemIndexToIndexPath:previousItemIndex];
                [self.tableView beginUpdates];
                [self.items removeObjectAtIndex:previousItemIndex];
                [self.tableView deleteRowsAtIndexPaths:@[previousIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                [self.tableView endUpdates];
            }
        }
    }
    
    // If we have removed one of our message, we must scan our messages from the last sent
    // and call updateState() to make sure the avatar is displayed if necessary on the last
    // message that we have sent.
    if (![item isPeerItem]) {
        for (NSInteger index = self.items.count - 1; index >= 0; index--) {
            Item *lItem = [self.items objectAtIndex:index];
            if (![lItem isPeerItem]) {
                [lItem updateState];
                if (!self.batchUpdate) {
                    NSIndexPath *nextIndexPath = [self itemIndexToIndexPath:index];
                    [self.tableView reloadRowsAtIndexPaths:@[nextIndexPath] withRowAnimation:UITableViewRowAnimationNone];
                }
                break;
            }
        }
    }
    
    if (self.items.count == 1) {
        self.emptyConversationLabel.hidden = NO;
        self.scrollIndicatorView.hidden = YES;
        [self updateScrollIndicator];
    } else {
        self.emptyConversationLabel.hidden = YES;
    }
    
    [self setupTableHeaderView];
}

- (NSIndexPath *)itemIndexToIndexPath:(NSUInteger)itemIndex {
    DDLogVerbose(@"%@ itemIndexToIndexPath: %lu", LOG_TAG, (unsigned long)itemIndex);
    
    return [NSIndexPath indexPathForRow:self.items.count - itemIndex - 1 inSection:0];
}

- (BOOL)isImageAsset:(PHAsset *)asset {
    DDLogVerbose(@"%@ isImageFile: %@", LOG_TAG, asset);
    
    return asset.mediaType == PHAssetMediaTypeImage;
}

- (BOOL)isVideoAsset:(PHAsset *)asset {
    DDLogVerbose(@"%@ isVideoAsset: %@", LOG_TAG, asset);
    
    return asset.mediaType == PHAssetMediaTypeVideo;
}

- (BOOL)isImageFile:(NSString *)file {
    DDLogVerbose(@"%@ isImageFile: %@", LOG_TAG, file);
    
    CFStringRef fileType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef) [file pathExtension], NULL);
    BOOL result = UTTypeConformsTo(fileType, kUTTypeImage);
    CFRelease(fileType);
    return result;
}

- (BOOL)isVideoFile:(NSString *)file {
    DDLogVerbose(@"%@ isVideoFile: %@", LOG_TAG, file);
    
    CFStringRef fileType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef) [file pathExtension], NULL);
    BOOL result = UTTypeConformsTo(fileType, kUTTypeMovie);
    CFRelease(fileType);
    return result;
}

- (void)typingFire:(NSTimer *)timer {
    DDLogVerbose(@"%@ typingFire: %@", LOG_TAG, timer);
    
    self.isTyping = NO;
    TLTyping *typing = [[TLTyping alloc] initWithAction:TLTypingActionStop];
    [self.conversationService pushTyping:typing];
    
    if (self.typingTimer) {
        [self.typingTimer invalidate];
    }
}

- (void)peerTypingFire:(NSTimer *)timer {
    DDLogVerbose(@"%@ peerTypingFire: %@", LOG_TAG, timer);
    
    self.isPeerTyping = NO;
    [self setupTableHeaderView];
    
    if (self.peerTypingTimer) {
        [self.peerTypingTimer invalidate];
    }
}

- (void)saveMediaInGalleryWithPermissionCheck {
    DDLogVerbose(@"%@ saveMediaInGalleryWithPermissionCheck", LOG_TAG);
    
    PHAuthorizationStatus photoAuthorizationStatus = [DeviceAuthorization devicePhotoAuthorizationStatus];
    switch (photoAuthorizationStatus) {
        case PHAuthorizationStatusNotDetermined: {
            if (@available(iOS 14, *)) {
                [PHPhotoLibrary requestAuthorizationForAccessLevel:PHAccessLevelAddOnly handler:^(PHAuthorizationStatus authorizationStatus) {
                    if ([DeviceAuthorization devicePhotoAuthorizationAccessGranted:authorizationStatus]) {
                        [self saveMediaInGallery];
                    }
                }];
            } else {
                [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus authorizationStatus) {
                    if ([DeviceAuthorization devicePhotoAuthorizationAccessGranted:authorizationStatus]) {
                        [self saveMediaInGallery];
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
            [self saveMediaInGallery];
            break;
    }
}

- (void)saveMediaInGallery {
    DDLogVerbose(@"%@ saveMediaInGallery", LOG_TAG);
    
    NSURL *urlToSave = [self.selectedItem getURL];
    
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
            
            if (self.selectedItem.type == ItemTypeImage || self.selectedItem.type == ItemTypePeerImage) {
                PHAssetChangeRequest *createImageRequest = [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:urlToSave];
                [albumRequest addAssets:@[createImageRequest.placeholderForCreatedAsset]];
            } else if (self.selectedItem.type == ItemTypeVideo || self.selectedItem.type == ItemTypePeerVideo) {
                PHAssetChangeRequest *createVideoRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:urlToSave];
                [albumRequest addAssets:@[createVideoRequest.placeholderForCreatedAsset]];
            }
        } completionHandler:^(BOOL success, NSError *error) {
            if (success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[UIApplication sharedApplication].keyWindow makeToast:TwinmeLocalizedString(@"conversation_view_controller_menu_item_view_save_message", nil)];
                    [self closeMenu];
                });
            }
        }];
    }
}

- (void)saveFile {
    DDLogVerbose(@"%@ saveFile", LOG_TAG);
    
    NSURL *urlToSave = [self.selectedItem getURL];
    
    if (urlToSave) {
        UIDocumentPickerViewController *documentPickerViewController;
        
        if (@available(iOS 14.0, *)) {
            documentPickerViewController = [[UIDocumentPickerViewController alloc]initForExportingURLs:@[urlToSave] asCopy:YES];
        } else {
            documentPickerViewController = [[UIDocumentPickerViewController alloc]initWithURL:urlToSave inMode:UIDocumentPickerModeExportToService];
        }
        
        documentPickerViewController.delegate = self;
        documentPickerViewController.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:documentPickerViewController animated:YES completion:nil];
    }
}

- (void)openCamera {
    DDLogVerbose(@"%@ openCamera", LOG_TAG);
    
    AVAuthorizationStatus cameraAuthorizationStatus = [DeviceAuthorization deviceCameraAuthorizationStatus];
    switch (cameraAuthorizationStatus) {
        case AVAuthorizationStatusNotDetermined: {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIImagePickerController *mediaPicker = [[UIImagePickerController alloc] init];
                        mediaPicker.delegate = self;
                        mediaPicker.allowsEditing = NO;
                        mediaPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                        mediaPicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
                        mediaPicker.mediaTypes = [[NSArray alloc]initWithObjects:(NSString *)kUTTypeMovie, (NSString *)kUTTypeImage, nil];
                        [self presentViewController:mediaPicker animated:YES completion:nil];
                    });
                }
            }];
            break;
        }
            
        case AVAuthorizationStatusRestricted:
        case AVAuthorizationStatusDenied: {
            [DeviceAuthorization showCameraSettingsAlertInController:self];
            break;
        }
            
        case AVAuthorizationStatusAuthorized: {
            UIImagePickerController *mediaPicker = [[UIImagePickerController alloc] init];
            mediaPicker.delegate = self;
            mediaPicker.allowsEditing = NO;
            mediaPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            mediaPicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
            mediaPicker.mediaTypes = [[NSArray alloc]initWithObjects:(NSString *)kUTTypeMovie, (NSString *)kUTTypeImage, nil];
            [self presentViewController:mediaPicker animated:YES completion:nil];
            break;
        }
    }
}

- (void)openGallery {
    DDLogVerbose(@"%@ openGallery", LOG_TAG);
    
    if (@available(iOS 14, *)) {
        PHPickerConfiguration *config = [[PHPickerConfiguration alloc] init];
        config.selectionLimit = 10;
        
        PHPickerViewController *pickerViewController = [[PHPickerViewController alloc] initWithConfiguration:config];
        pickerViewController.delegate = self;
        [self presentViewController:pickerViewController animated:YES completion:nil];
    } else {
        UIImagePickerController *mediaPicker = [[UIImagePickerController alloc] init];
        mediaPicker.delegate = self;
        mediaPicker.modalPresentationStyle = UIModalPresentationFormSheet;
        mediaPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        mediaPicker.mediaTypes = [[NSArray alloc]initWithObjects:(NSString *)kUTTypeMovie, (NSString *)kUTTypeImage, nil];
        mediaPicker.videoQuality = UIImagePickerControllerQualityTypeHigh;
        [self presentViewController:mediaPicker animated:YES completion:nil];
    }
}

- (void)openFile {
    DDLogVerbose(@"%@ openFile", LOG_TAG);
    
    UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[(__bridge NSString*)(kUTTypeData),(__bridge NSString*)(kUTTypeContent)] inMode:UIDocumentPickerModeImport];
    documentPicker.delegate = self;
    documentPicker.allowsMultipleSelection = YES;
    documentPicker.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:documentPicker animated:YES completion:nil];
}

- (void)openLocation {
    DDLogVerbose(@"%@ openLocation", LOG_TAG);
    
    [self.conversationService getImageWithProfile:self.space.profile withBlock:^(UIImage *image) {
        PreviewLocationViewController *previewLocationViewController = (PreviewLocationViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"PreviewLocationViewController"];
        previewLocationViewController.previewViewDelegate = self;
        [previewLocationViewController initWithAvatar:image];
        
        BOOL certified = NO;
        if (!self.group && self.contact) {
            TLContact *contact = (TLContact *)self.contact;
            if (contact.certificationLevel == TLCertificationLevel4) {
                certified = YES;
            }
        }
        
        [previewLocationViewController initWithName:self.contactName avatar:self.contactAvatar certified:certified message:self.textView.text];
        
        [self presentViewController:previewLocationViewController animated:YES completion:nil];
    }];
}

- (void)openMediasAndFiles {
    DDLogVerbose(@"%@ openMediasAndFiles", LOG_TAG);
    
    ConversationFilesViewController *conversationFilesViewController = (ConversationFilesViewController *)[[UIStoryboard storyboardWithName:@"iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"ConversationFilesViewController"];
    [conversationFilesViewController initWithOriginator:self.contact];
    [self.navigationController pushViewController:conversationFilesViewController animated:YES];
}

- (void)openManageConversation {
    DDLogVerbose(@"%@ openManageConversation", LOG_TAG);
    
    MenuManageConversationView *menuManageConversationView = [[MenuManageConversationView alloc] init];
    menuManageConversationView.menuManageConversationViewDelegate = self;
    [self.navigationController.view addSubview:menuManageConversationView];
    [menuManageConversationView openMenu];
}

- (void)openPreviewImage:(UIImage *)image imageData:(NSData *)imageData imageExtension:(NSString *)imageExtension  {
    DDLogVerbose(@"%@ openPreviewImage: %@", LOG_TAG, image);
    
    if (image) {
        NSString *fileName = [NSString stringWithFormat:@"%@_%@", [[NSProcessInfo processInfo] globallyUniqueString], imageExtension];
        NSURL *url = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:fileName]];
        if (!imageData) {
            imageData = UIImageJPEGRepresentation(image, 1.0);
        }
        
        [imageData writeToURL:url options:NSDataWritingAtomic error:nil];
        
        UIPreviewMedia *previewMedia = [[UIPreviewMedia alloc]initWithUrl:url path:url.path size:image.size isVideo:NO];
        [self.previewMediaPicking addObject:previewMedia];
    }
    
    self.countMediaPicking--;
    
    [self startPreviewMediaActivity];
}

- (void)openPreviewVideo:(NSURL *)url {
    DDLogVerbose(@"%@ openPreviewVideo: %@", LOG_TAG, url);
    
    if (url) {
        UIPreviewMedia *previewMedia = [[UIPreviewMedia alloc]initWithUrl:url path:url.path size:CGSizeZero isVideo:YES];
        [self.previewMediaPicking addObject:previewMedia];
    }
    
    self.countMediaPicking--;
    
    [self startPreviewMediaActivity];
}

- (void)startPreviewMediaActivity {
    DDLogVerbose(@"%@ startPreviewMediaActivity", LOG_TAG);
        
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.endMediaPicking && self.countMediaPicking == 0) {
            self.overlayView.hidden = YES;
            if ([self.activityIndicatorView isAnimating]) {
                [self.activityIndicatorView stopAnimating];
            }
            
            PreviewFilesViewController *previewFilesViewController = (PreviewFilesViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"PreviewFilesViewController"];
            previewFilesViewController.previewViewDelegate = self;
            previewFilesViewController.startWithMedia = YES;
            
            BOOL certified = NO;
            if (!self.group && self.contact) {
                TLContact *contact = (TLContact *)self.contact;
                if (contact.certificationLevel == TLCertificationLevel4) {
                    certified = YES;
                }
            }
            [previewFilesViewController initWithName:self.contactName avatar:self.contactAvatar certified:certified message:self.textView.text];
            [previewFilesViewController initWithPreviewMedia:self.previewMediaPicking errorPicking:self.errorMediaPicking];
                           
            [self presentViewController:previewFilesViewController animated:YES completion:^{
                [self.previewMediaPicking removeAllObjects];
            }];
        } else {
            self.overlayView.hidden = NO;
            if (![self.activityIndicatorView isAnimating]) {
                [self.activityIndicatorView startAnimating];
            }
        }
    });
}

- (void)updateSendButton:(BOOL)forceUpdate {
    DDLogVerbose(@"%@ updateSendButton", LOG_TAG);
    
    CGFloat minHeight = (Design.FONT_REGULAR32.lineHeight + (DESIGN_HEIGHT_INSET * Design.HEIGHT_RATIO * 2));
    CGFloat textViewTopInset = DESIGN_HEIGHT_INSET * Design.HEIGHT_RATIO;
    if (self.editingMessage) {
        textViewTopInset += DESIGN_EDIT_MESSAGE_VIEW_HEIGHT * Design.HEIGHT_RATIO;
    }
    
    if (!self.editingMessage && [self.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
        [self.sendButtonView setEnabled:NO];
        self.textViewRightView.hidden = NO;
        
        if ([[UIApplication sharedApplication] userInterfaceLayoutDirection] == UIUserInterfaceLayoutDirectionLeftToRight) {
            self.textView.textContainerInset = UIEdgeInsetsMake(textViewTopInset, DESIGN_WIDTH_INSET * Design.WIDTH_RATIO, DESIGN_HEIGHT_INSET * Design.HEIGHT_RATIO, minHeight * 2);
        } else {
            self.textView.textContainerInset = UIEdgeInsetsMake(textViewTopInset, minHeight * 2, DESIGN_HEIGHT_INSET * Design.HEIGHT_RATIO, DESIGN_WIDTH_INSET * Design.WIDTH_RATIO);
        }
        
    } else {
        [self.sendButtonView setEnabled:YES];
        self.textViewRightView.hidden = YES;
        
        self.textView.textContainerInset = UIEdgeInsetsMake(textViewTopInset, DESIGN_WIDTH_INSET * Design.WIDTH_RATIO, DESIGN_HEIGHT_INSET * Design.HEIGHT_RATIO, DESIGN_WIDTH_INSET * Design.WIDTH_RATIO);
    }
    
    ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
    TwinmeApplication *twinmeApplication = [delegate twinmeApplication];
    TLSpaceSettings *spaceSettings = self.space.settings;
    if ([self.space.settings getBooleanWithName:PROPERTY_DEFAULT_APPEARANCE_SETTINGS defaultValue:YES]) {
        spaceSettings = self.twinmeContext.defaultSpaceSettings;
    }
    
    BOOL darkMode = [twinmeApplication darkModeEnable:spaceSettings];
    
    CGFloat topEdit = self.textView.frame.origin.y;

    if (darkMode) {
        topEdit += 1;
    }
    
    self.editMessageView.frame = CGRectMake(0, 0, DESIGN_EDIT_MESSAGE_VIEW_WIDTH * Design.WIDTH_RATIO + self.menuButtonView.frame.size.width, DESIGN_EDIT_MESSAGE_VIEW_HEIGHT * Design.HEIGHT_RATIO + topEdit);
    [self.editMessageView updateLeading:self.menuButtonView.frame.size.width + (DESIGN_WIDTH_INSET * Design.WIDTH_RATIO) top:topEdit width:self.textView.frame.size.width - (DESIGN_WIDTH_INSET * Design.WIDTH_RATIO * 2)];
    
    CGRect rect = self.textViewRightView.frame;
    if ([[UIApplication sharedApplication] userInterfaceLayoutDirection] == UIUserInterfaceLayoutDirectionLeftToRight) {
        rect.origin.x = self.textView.frame.size.width - minHeight * 2;
    }
    rect.origin.y = self.textView.frame.size.height - minHeight;
    self.textViewRightView.frame = rect;
    
    [self.textInputbar layoutIfNeeded];
}

- (void)setupTableHeaderView {
    DDLogVerbose(@"%@ setupTableHeaderView", LOG_TAG);
    
    if (self.isPeerTyping) {
        self.isPeerTyping = YES;
        if (self.replyItem) {
            CGFloat typingViewHeight = (DESIGN_TYPING_VIEW_HEIGHT * Design.HEIGHT_RATIO) + (DESIGN_REPLY_VIEW_HEIGHT * Design.HEIGHT_RATIO);
            self.typingView.frame = CGRectMake(0, 0, Design.DISPLAY_WIDTH, typingViewHeight);
        } else {
            self.typingView.frame = CGRectMake(0, 0, Design.DISPLAY_WIDTH, DESIGN_TYPING_VIEW_HEIGHT * Design.HEIGHT_RATIO);
        }
        self.tableView.tableHeaderView = self.typingView;
        [self.typingView setOriginators:self.typingOriginatorImages];
    } else {
        self.isPeerTyping = NO;
        if (self.replyItem) {
            UIView *tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Design.DISPLAY_WIDTH, DESIGN_REPLY_VIEW_HEIGHT * Design.HEIGHT_RATIO)];
            tableHeaderView.backgroundColor = [UIColor clearColor];
            self.tableView.tableHeaderView = tableHeaderView;
        } else {
            self.tableView.tableHeaderView = nil;
        }
    }
}

- (void)updateTableViewBackgroundColor {
    DDLogVerbose(@"%@ updateTableViewBackgroundColor", LOG_TAG);
    
    NSUUID *imageId = [self.customAppearance getConversationBackgroundImageId];
    if (imageId) {
        [self.conversationService getConversationImage:imageId defaultImage:[self.customAppearance createImageWithColor:Design.WHITE_COLOR] withBlock:^(UIImage *image) {
            self.backgroundConversationImageView.image = image;
            self.backgroundConversationImageView.hidden = NO;
        }];

        self.tableView.tableFooterView.backgroundColor = [UIColor clearColor];
        self.tableView.tableHeaderView.backgroundColor = [UIColor clearColor];
        self.tableView.backgroundColor = [UIColor clearColor];
    } else {
        self.backgroundConversationImageView.hidden = YES;
        self.tableView.tableFooterView.backgroundColor = [self.customAppearance getConversationBackgroundColor];
        self.tableView.tableHeaderView.backgroundColor = [self.customAppearance getConversationBackgroundColor];
        self.tableView.backgroundColor = [self.customAppearance getConversationBackgroundColor];
    }
}

- (void)hapticFeedback {
    DDLogVerbose(@"%@ hapticFeedback", LOG_TAG);
    
    [Utils hapticFeedback:UIImpactFeedbackStyleMedium hapticFeedbackMode:self.twinmeApplication.hapticFeedbackMode];
}

- (void)showCoachMark {
    DDLogVerbose(@"%@ showCoachMark", LOG_TAG);
    
    if ([self.twinmeApplication showCoachMark:TAG_COACH_MARK_CONVERSATION_EPHEMERAL]) {
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DELAY_COACH_MARK * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            CoachMarkViewController *coachMarkViewController = (CoachMarkViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"CoachMarkViewController"];
            CGRect clipRect = CGRectMake(self.sendButtonView.frame.origin.x, self.textInputbar.frame.origin.y + self.sendButtonView.frame.origin.y, self.sendButtonView.frame.size.height, self.sendButtonView.frame.size.height);
            CoachMark *coachMark = [[CoachMark alloc]initWithMessage:TwinmeLocalizedString(@"conversation_view_controller_ephemeral_coach_mark", nil) tag:TAG_COACH_MARK_CONVERSATION_EPHEMERAL alignLeft:NO onTop:YES featureRect:clipRect featureRadius:self.sendButtonView.frame.size.height * 0.5f];
            [coachMarkViewController initWithCoachMark:coachMark];
            coachMarkViewController.delegate = self;
            [coachMarkViewController showInView:self.navigationController];
        });
    }
}

- (void)startFullScreenMediaViewController:(TLDescriptorId *)descriptorId {
    DDLogVerbose(@"%@ startFullScreenMediaViewController", LOG_TAG);
    
    NSMutableArray *medias = [[NSMutableArray alloc]init];
    for (Item *item in self.items) {
        if (item.type == ItemTypeImage || item.type == ItemTypePeerImage || item.type == ItemTypeVideo || item.type == ItemTypePeerVideo) {
            [medias addObject:item];
        }
    }
    
    int index = 0;
    int itemIndex = 0;
    for (Item *item in medias) {
        if ([item.descriptorId isEqual:descriptorId]) {
            itemIndex = index;
            break;
        }
        index++;
    }
    
    if (medias.count > 0) {
        Item *item = [medias objectAtIndex:itemIndex];
        if ([item needsUpdateReadTimestamp] && item.isPeerItem) {
            item.readTimestamp = 1;
            [self.conversationService markDescriptorReadWithDescriptorId:item.descriptorId];
        }
    }
    
    FullScreenMediaViewController *fullscreenMediaViewController = (FullScreenMediaViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"FullScreenMediaViewController"];
    [fullscreenMediaViewController initWithItems:medias atIndex:itemIndex conversationId:self.conversationId originator:[self getOriginator]];
    [self presentViewController:fullscreenMediaViewController animated:YES completion:nil];
}

- (void)updateScrollIndicator {
    DDLogVerbose(@"%@ updateScrollIndicator", LOG_TAG);
    
    if (!self.replyItem) {
        self.scrollIndicatorViewBottomConstraint.constant = self.view.frame.size.height - self.textInputbar.frame.origin.y + (DESIGN_SCROLL_INDICATOR_BOTTOM * Design.HEIGHT_RATIO);
    } else {
        self.scrollIndicatorViewBottomConstraint.constant = self.view.frame.size.height - self.textInputbar.frame.origin.y + (DESIGN_SCROLL_INDICATOR_BOTTOM * Design.HEIGHT_RATIO) + self.replyView.frame.size.height;
    }
    
    self.scrollIndicatorCountLabel.text = [NSString stringWithFormat:@"%d", self.scrollIndicatorCount];
    
    if (self.scrollIndicatorCount == 0) {
        self.scrollIndicatorCountLabel.hidden = YES;
        self.scrollIndicatorViewWidthConstraint.constant = self.scrollIndicatorImageViewHeightConstraint.constant + (2 * self.scrollIndicatorImageViewTrailingConstraint.constant);
    } else {
        self.scrollIndicatorCountLabel.hidden = NO;
        self.scrollIndicatorViewWidthConstraint.constant = DESIGN_SCROLL_INDICATOR_WIDTH * Design.WIDTH_RATIO;
    }
}

- (void)resetSelectedItems {
    DDLogVerbose(@"%@ resetSelectedItems", LOG_TAG);
    
    for (Item *item in self.selectedItems) {
        item.selected = NO;
    }
    
    [self.selectedItems removeAllObjects];
}

- (void)deleteSelectedItems {
    DDLogVerbose(@"%@ deleteSelectedItems", LOG_TAG);
    
    for (Item *item in self.selectedItems) {
        if (item.isPeerItem) {
            [self.conversationService deleteDescriptorWithDescriptorId:item.descriptorId];
        } else {
            [self.conversationService markDescriptorDeletedWithDescriptorId:item.descriptorId];
        }
        
        item.selected = NO;
    }
    
    [self.itemSelectedActionView updateSelectedItems:0];
    [self reloadData];
}

- (void)removeSubViews {
    DDLogVerbose(@"%@ removeSubViews", LOG_TAG);
    
    NSArray *subviewClassToRemove = [self subviewClassToRemove];
    
    for (UIView *subView in [self.navigationController.view subviews]) {
        if ([subviewClassToRemove containsObject:[subView class]]) {
            [subView removeFromSuperview];
        }
    }
}

- (NSArray *)subviewClassToRemove {
    DDLogVerbose(@"%@ subviewClassToRemove", LOG_TAG);
    
    return @[[AnnotationsView class], [DefaultConfirmView class], [ResetConversationConfirmView class], [DeleteConfirmView class], [PremiumFeatureConfirmView class], [MenuSendOptionsView class], [MenuManageConversationView class], [MenuActionConversationView class], [AlertMessageView class]];
}

- (void)updateNavigationBarAvatar {
    DDLogVerbose(@"%@ updateNavigationBarAvatar", LOG_TAG);
    
    if (self.avatarView && self.contactAvatar) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.avatarView.image = self.contactAvatar;
        });
    }
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.titleLabel.font = Design.FONT_BOLD34;
    self.subTitleLabel.font = Design.FONT_REGULAR24;
    self.scrollIndicatorCountLabel.font = Design.FONT_MEDIUM42;
    self.zoomLevelLabel.font = Design.FONT_BOLD44;
    self.textView.font = Design.FONT_REGULAR32;
    
    [self.voiceMessageRecorderView updateFont];
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    if (self.customAppearance) {
        TLSpaceSettings *spaceSettings = self.space.settings;
        if ([self.space.settings getBooleanWithName:PROPERTY_DEFAULT_APPEARANCE_SETTINGS defaultValue:YES]) {
            spaceSettings = self.twinmeContext.defaultSpaceSettings;
        }
        
        if ([[spaceSettings getStringWithName:PROPERTY_DISPLAY_MODE defaultValue:[NSString stringWithFormat:@"%d", DisplayModeSystem]]intValue] == DisplayModeSystem) {
            [self.customAppearance setCurrentMode:DisplayModeSystem];
        }
    }
    
    self.view.backgroundColor = Design.CONVERSATION_BACKGROUND_COLOR;
    self.scrollIndicatorView.backgroundColor = Design.MAIN_COLOR;
    self.textView.textColor = Design.FONT_COLOR_DEFAULT;
    self.textView.backgroundColor = Design.TEXTFIELD_CONVERSATION_BACKGROUND_COLOR;
    
    self.tableView.tableFooterView.backgroundColor = Design.CONVERSATION_BACKGROUND_COLOR;
    self.tableView.tableHeaderView.backgroundColor = Design.CONVERSATION_BACKGROUND_COLOR;
    [self updateTableViewBackgroundColor];
    [self.textInputbar setBackgroundColor:Design.WHITE_COLOR];

    TLSpaceSettings *spaceSettings = self.space.settings;
    if ([self.space.settings getBooleanWithName:PROPERTY_DEFAULT_APPEARANCE_SETTINGS defaultValue:YES]) {
        spaceSettings = self.twinmeContext.defaultSpaceSettings;
    }
        
    if ([self.twinmeApplication darkModeEnable:spaceSettings]) {
        self.textView.layer.borderColor = DESIGN_BORDER_COLOR.CGColor;
        self.textView.layer.borderWidth = 1.0f;
        self.textView.keyboardAppearance = UIKeyboardAppearanceDark;
    } else {
        self.textView.layer.borderColor = [UIColor clearColor].CGColor;
        self.textView.layer.borderWidth = .0f;
        self.textView.keyboardAppearance = UIKeyboardAppearanceLight;
    }
    
    if (self.headerOverlayView) {
        self.navigationBarOverlayView.backgroundColor = Design.BACKGROUND_COLOR_WHITE_OPACITY85;
        self.headerOverlayView.backgroundColor = Design.BACKGROUND_COLOR_WHITE_OPACITY85;
        self.footerOverlayView.backgroundColor = Design.BACKGROUND_COLOR_WHITE_OPACITY85;
    }
    
    self.emptyConversationLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    [self.voiceMessageRecorderView updateColor];
    
    if (self.textViewRightView) {
        [self.textViewRightView updateColor];
    }
    
    if (self.editMessageView) {
        [self.editMessageView updateColor];
    }
}

- (void)updateInCall {
    DDLogVerbose(@"%@ updateInCall", LOG_TAG);
    
    BOOL hasAudio = YES;
    BOOL hasVideo = YES;
    if (self.group) {
        if (self.groupMembers.count + 1 > MAX_CALL_GROUP_PARTICIPANTS || self.groupMembers.count == 0) {
            hasAudio = NO;
            hasVideo = NO;
        } else {
            hasAudio = self.group.capabilities.hasAudio;
            hasVideo = self.group.capabilities.hasVideo;
        }
    } else  {
        TLContact *contact = (TLContact *)self.contact;
        if (![contact hasPrivatePeer]) {
            hasAudio = NO;
            hasVideo = NO;
        } else {
            hasAudio = contact.capabilities.hasAudio;
            hasVideo = contact.capabilities.hasVideo;
        }
    }
    
    if (hasAudio) {
        self.audioCallBarButtonItem.enabled = YES;
        self.audioCallBarButtonItem.tintColor = [UIColor whiteColor];
    } else {
        self.audioCallBarButtonItem.enabled = NO;
        self.audioCallBarButtonItem.tintColor = [UIColor clearColor];
    }
    
    if (hasVideo) {
        self.videoCallBarButtonItem.enabled = YES;
        self.videoCallBarButtonItem.tintColor = [UIColor whiteColor];
    } else {
        self.videoCallBarButtonItem.enabled = NO;
        self.videoCallBarButtonItem.tintColor = [UIColor clearColor];
    }
    
    if (self.twinmeApplication.inCall) {
        self.audioCallBarButtonItem.enabled = NO;
        self.videoCallBarButtonItem.enabled = NO;
    }
}

@end

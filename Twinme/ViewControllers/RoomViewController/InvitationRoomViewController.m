/*
 *  Copyright (c) 2021-2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinlife/TLTwinlife.h>
#import <Twinlife/TLTwincodeURI.h>

#import <Twinme/TLContact.h>

#import "InvitationRoomViewController.h"
#import "AddParticipantsViewController.h"
#import "ScanViewController.h"

#import <TwinmeCommon/InvitationRoomService.h>
#import <TwinmeCommon/Utils.h>

#import <Utils/NSString+Utils.h>

#import <TwinmeCommon/Design.h>
#import "DeviceAuthorization.h"
#import "UIView+Toast.h"

static CGFloat DESIGN_AVATAR_BORDER_WIDTH = 6;

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: InvitationRoomViewController ()
//

@interface InvitationRoomViewController ()<InvitationRoomServiceDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *roomViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *roomViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *roomViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *roomView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *qrcodeViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *qrcodeViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *qrcodeView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twincodeLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twincodeLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *twincodeLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inviteViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inviteViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inviteViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *inviteCodeView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inviteLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *inviteLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scanViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scanViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scanViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *scanView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scanLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *scanLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *socialViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *socialViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *socialViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *socialView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *socialLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *socialLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *socialSubLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *socialSubLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *socialSubLabel;

@property (nonatomic) TLContact *room;
@property (nonatomic, nullable) TLTwincodeURI *uri;

@property(nonatomic) InvitationRoomService *invitationRoomService;

@property BOOL saveQRCodeInGallery;

@end

//
// Implementation: InvitationRoomViewController
//

#undef LOG_TAG
#define LOG_TAG @"InvitationRoomViewController"

@implementation InvitationRoomViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _saveQRCodeInGallery = NO;
        
        _invitationRoomService = [[InvitationRoomService alloc] initWithTwinmeContext:self.twinmeContext delegate:self];
    }
    return self;
}


- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
    
    [self initViews];
}

- (void)viewWillAppear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillAppear: %@", LOG_TAG, animated ? @"YES":@"NO");
    
    [super viewWillAppear:animated];
    
    [self updateRoom];
}

- (void)initWithRoom:(TLContact *)room {
    DDLogVerbose(@"%@ initWithRoom: %@", LOG_TAG, room);
    
    self.room = room;
}

#pragma mark - InvitationRoomServiceDelegate delegate methods

- (void)onGetContacts:(nonnull NSArray<TLContact *> *)contacts {
    DDLogVerbose(@"%@ onGetContacts: %@", LOG_TAG, contacts);
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    [self.view setBackgroundColor:Design.LIGHT_GREY_BACKGROUND_COLOR];
    
    [self setNavigationTitle:TwinmeLocalizedString(@"show_room_view_controller_invite_participants", nil)];
    
    UIBarButtonItem *shareBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ShareItem"] style:UIBarButtonItemStylePlain target:self action:@selector(handleSocialTapGesture)];
    self.navigationItem.rightBarButtonItem = shareBarButtonItem;
    
    self.roomViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.roomViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.roomViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.roomView.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
    
    CALayer *roomViewLayer = self.roomView.layer;
    roomViewLayer.shadowOpacity = Design.SHADOW_OPACITY;
    roomViewLayer.shadowOffset = Design.SHADOW_OFFSET;
    roomViewLayer.shadowRadius = Design.SHADOW_RADIUS;
    roomViewLayer.shadowColor = Design.SHADOW_COLOR_DEFAULT.CGColor;
    roomViewLayer.cornerRadius = Design.CONTAINER_RADIUS;
    roomViewLayer.masksToBounds = NO;
    
    self.avatarViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.avatarViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.avatarView.clipsToBounds = YES;
    self.avatarView.layer.cornerRadius = self.avatarViewHeightConstraint.constant * 0.5;
    self.avatarView.layer.borderColor = Design.WHITE_COLOR.CGColor;
    self.avatarView.layer.borderWidth = DESIGN_AVATAR_BORDER_WIDTH;
    
    self.nameLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.nameLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    [self.nameLabel setFont:Design.FONT_REGULAR32];
    self.nameLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    self.qrcodeViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.qrcodeViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.qrcodeView.userInteractionEnabled = YES;
    UITapGestureRecognizer *qrCodeGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleQRCodeTapGesture:)];
    [self.qrcodeView addGestureRecognizer:qrCodeGestureRecognizer];
    
    self.twincodeLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.twincodeLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    [self.twincodeLabel setFont:Design.FONT_REGULAR30];
    self.twincodeLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.twincodeLabel.userInteractionEnabled = YES;
    [self.twincodeLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTwincodeLabelTapGesture:)]];
    
    self.messageLabelWidthConstraint.constant *= Design.MIN_RATIO;
    self.messageLabelTopConstraint.constant *= Design.MIN_RATIO;
    
    [self.messageLabel setFont:Design.FONT_REGULAR30];
    self.messageLabel.textColor = Design.FONT_COLOR_GREY;
    self.messageLabel.text = TwinmeLocalizedString(@"invitation_room_view_controller_message", nil);
    
    self.inviteViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.inviteViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.inviteViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.inviteCodeView.backgroundColor = Design.MAIN_COLOR;
    self.inviteCodeView.userInteractionEnabled = YES;
    self.inviteCodeView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.inviteCodeView.clipsToBounds = YES;
    [self.inviteCodeView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleInviteTapGesture:)]];
    
    self.inviteLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    [self.inviteLabel setFont:Design.FONT_BOLD28];
    self.inviteLabel.textColor = [UIColor whiteColor];
    self.inviteLabel.text = TwinmeLocalizedString(@"contacts_view_controller_invite_contact_title", nil);
    
    self.scanViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.scanViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.scanViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.scanView.backgroundColor = Design.BLACK_COLOR;
    self.scanView.userInteractionEnabled = YES;
    self.scanView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.scanView.clipsToBounds = YES;
    [self.scanView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleScanTapGesture:)]];
    
    self.scanLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    [self.scanLabel setFont:Design.FONT_BOLD28];
    self.scanLabel.textColor = Design.WHITE_COLOR;
    self.scanLabel.text = TwinmeLocalizedString(@"add_contact_view_controller_scan_title", nil);
    
    self.socialViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.socialViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.socialViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.socialView.backgroundColor = Design.MAIN_COLOR;
    self.socialView.userInteractionEnabled = YES;
    self.socialView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.socialView.clipsToBounds = YES;
    [self.socialView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSocialTapGesture)]];
    
    self.socialLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    [self.socialLabel setFont:Design.FONT_BOLD28];
    self.socialLabel.textColor = [UIColor whiteColor];
    self.socialLabel.text = TwinmeLocalizedString(@"add_contact_view_controller_social_title", nil);
    
    self.socialSubLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.socialSubLabelWidthConstraint.constant *= Design.HEIGHT_RATIO;
    
    [self.socialSubLabel setFont:Design.FONT_REGULAR24];
    self.socialSubLabel.textColor = Design.FONT_COLOR_GREY;
    self.socialSubLabel.text = TwinmeLocalizedString(@"add_contact_view_controller_social_subtitle", nil);
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    if (self.invitationRoomService) {
        [self.invitationRoomService dispose];
        self.invitationRoomService = nil;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleInviteTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleInviteTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        AddParticipantsViewController *addParticipantsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AddParticipantsViewController"];
        [addParticipantsViewController initWithRoom:self.room];
        [self.navigationController pushViewController:addParticipantsViewController animated:YES];
    }
}

- (void)handleSocialTapGesture {
    DDLogVerbose(@"%@ handleSocialTapGesture", LOG_TAG);
    
    // To avoid hyperlink injections in names, we replace '.' and ':' into special UTF-8 characters
    // that also visually correspond to '.' and ':'.  These two replacements allow to break
    // hyperlink recognition and forwarding.  Even cut&paste will not allow to follow such link.
    NSString *name = [self.room.name stringByReplacingOccurrencesOfString:@"." withString:@"\u2024"];
    name = [name stringByReplacingOccurrencesOfString:@":" withString:@"\u02d0"];
    NSString *message = [NSString stringWithFormat:TwinmeLocalizedString(@"add_contact_view_controller_invite_message %@ %@", nil), self.uri.uri, name];
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[message] applicationActivities:nil];
    activityViewController.excludedActivityTypes = @[UIActivityTypeAirDrop,
                                                     UIActivityTypePrint,
                                                     UIActivityTypeAssignToContact,
                                                     UIActivityTypeSaveToCameraRoll,
                                                     UIActivityTypeAddToReadingList,
                                                     UIActivityTypePostToFlickr,
                                                     UIActivityTypePostToVimeo];
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

- (void)handleQRCodeTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleQRCodeTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        
    }
}

- (void)handleScanTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleScanTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        ScanViewController *scanViewController = (ScanViewController *)[[UIStoryboard storyboardWithName:@"iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"ScanViewController"];
        [self.navigationController presentViewController:scanViewController animated:YES completion:nil];
    }
}

- (void)handleTwincodeLabelTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleTwincodeLabelTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self hapticFeedBack:UIImpactFeedbackStyleHeavy];
        
        [[UIPasteboard generalPasteboard] setString:self.uri.uri];
        [[UIApplication sharedApplication].keyWindow makeToast:TwinmeLocalizedString(@"conversation_view_controller_menu_item_view_copy_message",nil)];
    }
}

- (void)updateRoom {
    DDLogVerbose(@"%@ updateRoom", LOG_TAG);
    
    self.twincodeLabel.text = [self.room.publicPeerTwincodeOutboundId  UUIDString];
    self.qrcodeView.image = [Utils makeQRCodeWithUri:self.uri scale:10];
    self.nameLabel.text = self.room.name;
    [self.invitationRoomService getImageWithContact:self.room withBlock:^(UIImage *image) {
        self.avatarView.image = image;
    }];
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    [self.messageLabel setFont:Design.FONT_REGULAR30];
    [self.twincodeLabel setFont:Design.FONT_REGULAR30];
    [self.scanLabel setFont:Design.FONT_BOLD28];
    [self.inviteLabel setFont:Design.FONT_BOLD28];
    [self.socialLabel setFont:Design.FONT_BOLD28];
    [self.socialSubLabel setFont:Design.FONT_REGULAR24];
    [self.nameLabel setFont:Design.FONT_REGULAR32];
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    [self.view setBackgroundColor:Design.LIGHT_GREY_BACKGROUND_COLOR];
    self.socialView.backgroundColor = Design.MAIN_COLOR;
    self.inviteCodeView.backgroundColor = Design.MAIN_COLOR;
    self.twincodeLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.messageLabel.textColor = Design.FONT_COLOR_GREY;
    self.nameLabel.textColor = Design.FONT_COLOR_DEFAULT;
}

@end

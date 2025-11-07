/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinme/TLInvitation.h>

#import <Utils/NSString+Utils.h>

#import "InvitationCodeViewController.h"
#import "InvitationCodeCell.h"
#import "AddInvitationCodeCell.h"
#import "SectionCallCell.h"

#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/InvitationCodeService.h>

#import "AlertMessageView.h"
#import "CellActionView.h"
#import "DefaultConfirmView.h"
#import "InvitationCodeShareView.h"
#import "UIInvitationCode.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static NSString *SECTION_CELL_IDENTIFIER = @"SectionCallCellIdentifier";
static NSString *ADD_INVITATION_CODE_CELL_IDENTIFIER = @"AddInvitationCodeCellIdentifier";
static NSString *INVITATION_CODE_CELL_IDENTIFIER = @"InvitationCodeCellIdentifier";

static const int CONTACTS_VIEW_SECTION_COUNT = 2;

//
// Interface: InvitationCodeViewController
//

@interface InvitationCodeViewController () <UITableViewDataSource, UITableViewDelegate, ConfirmViewDelegate, InvitationCodeServiceDelegate, AlertMessageViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *invitationCodeTableView;

@property (nonatomic) UIView *overlayView;
@property (nonatomic) UIActivityIndicatorView *activityIndicatorView;

@property (nonatomic) NSMutableArray *invitationCode;
@property (nonatomic) BOOL showOnboardingView;

@property (nonatomic) UIInvitationCode *uiInvitationCode;
@property (nonatomic) InvitationCodeService *invitationCodeService;

@end

//
// Implementation: InvitationCodeViewController
//

#undef LOG_TAG
#define LOG_TAG @"InvitationCodeViewController"

@implementation InvitationCodeViewController

#pragma mark - UIViewController

+ (void)initialize {
    DDLogVerbose(@"%@ initialize", LOG_TAG);
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _invitationCode = [[NSMutableArray alloc] init];
        _showOnboardingView = NO;
        
        _invitationCodeService = [[InvitationCodeService alloc] initWithTwinmeContext:self.twinmeContext delegate:self];
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
    
    if ([self.invitationCode count] == 0) {
        [self.invitationCodeService getInvitations];
    }
    
    if (!self.showOnboardingView && [self.twinmeApplication startOnboarding:OnboardingTypeMiniCode]) {
        self.showOnboardingView = YES;
        
        [self showOnboarding:NO];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillDisappear: %d", LOG_TAG, animated);
    
    [super viewWillDisappear:animated];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    DDLogVerbose(@"%@ numberOfSectionsInTableView: %@", LOG_TAG, tableView);
    
    return CONTACTS_VIEW_SECTION_COUNT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ numberOfRowsInSection: %ld", LOG_TAG, tableView, (long)section);
    
    if (section == 0) {
        return 1;
    }
    
    return self.invitationCode.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ heightForHeaderInSection: %ld", LOG_TAG, tableView, (long)section);
            
    if (section == 1 && self.invitationCode.count > 0) {
        return Design.SETTING_SECTION_HEIGHT;
    }
    
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ heightForFooterInSection: %ld", LOG_TAG, tableView, (long)section);
    
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ viewForHeaderInSection: %ld", LOG_TAG, tableView, (long)section);
    
    SectionCallCell *sectionCallCell = (SectionCallCell *)[tableView dequeueReusableCellWithIdentifier:SECTION_CELL_IDENTIFIER];
    if (!sectionCallCell) {
        sectionCallCell = [[SectionCallCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SECTION_CELL_IDENTIFIER];
    }
        
    NSString *sectionName = @"";
    if (section == 1) {
        sectionName = TwinmeLocalizedString(@"invitation_code_view_controller_history", nil);
    }
    
    [sectionCallCell bindWithTitle:sectionName hideSeparator:NO uppercaseString:YES showRightAction:NO];
    
    return sectionCallCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
    
    if (indexPath.section == 1) {
        return Design.CELL_HEIGHT;
    }
    
    return UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ cellForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if (indexPath.section == 0) {
        AddInvitationCodeCell *addInvitationCodeCell = (AddInvitationCodeCell *)[tableView dequeueReusableCellWithIdentifier:ADD_INVITATION_CODE_CELL_IDENTIFIER];
        if (!addInvitationCodeCell) {
            addInvitationCodeCell = [[AddInvitationCodeCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ADD_INVITATION_CODE_CELL_IDENTIFIER];
        }
        
        [addInvitationCodeCell bindWithTitle:TwinmeLocalizedString(@"invitation_code_view_controller_create_code", nil) subTitle:TwinmeLocalizedString(@"invitation_code_view_controller_create_code_subtitle", nil)];
        
        return addInvitationCodeCell;
    } else {
        InvitationCodeCell *invitationCodeCell = (InvitationCodeCell *)[tableView dequeueReusableCellWithIdentifier:INVITATION_CODE_CELL_IDENTIFIER];
        if (!invitationCodeCell) {
            invitationCodeCell = [[InvitationCodeCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:INVITATION_CODE_CELL_IDENTIFIER];
        }
        
        UIInvitationCode *invitationCode = [self.invitationCode objectAtIndex:indexPath.row];
        BOOL hideSeparator = indexPath.row + 1 == [self.invitationCode count] ? YES : NO;
        [invitationCodeCell bindWithInvitation:invitationCode hideSeparator:hideSeparator];
        
        return invitationCodeCell;
    }
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ trailingSwipeActionsConfigurationForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if (indexPath.section == 0) {
        return nil;
    }
    
    UIInvitationCode *invitationCode = [self.invitationCode objectAtIndex:indexPath.row];
    UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:TwinmeLocalizedString(@"application_remove", nil) handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        
        [self deleteInvitationCode:invitationCode];
    }];
    
    CellActionView *deleteActionView = [[CellActionView alloc]initWithTitle:TwinmeLocalizedString(@"application_remove", nil) icon:@"ToolbarTrash" backgroundColor:[UIColor clearColor] iconWidth:32 iconHeight:38 iconTopMargin:28];
    deleteAction.image = [deleteActionView imageFromView];
    deleteAction.backgroundColor = Design.DELETE_COLOR_RED;
    
    UISwipeActionsConfiguration *swipeActionConfiguration = [UISwipeActionsConfiguration configurationWithActions:@[deleteAction]];
    swipeActionConfiguration.performsFirstActionWithFullSwipe = NO;
    return swipeActionConfiguration;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ didSelectRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if (indexPath.section == 0) {
        self.overlayView.hidden = NO;
        [self.activityIndicatorView startAnimating];

        [self requestInvitationCode];
    }
}

#pragma mark - InvitationCodeServiceDelegate

- (void)onCreateInvitationWithCodeWithInvitation:(nullable TLInvitation *)invitation {
    DDLogVerbose(@"%@ onCreateInvitationWithCodeWithInvitation: %@", LOG_TAG, invitation);
    
    self.uiInvitationCode = [self addInvitation:invitation];
    
    self.overlayView.hidden = YES;
    if ([self.activityIndicatorView isAnimating]) {
        [self.activityIndicatorView stopAnimating];
    }
    
    if (self.uiInvitationCode) {
        [self showInvitationCodeShareView:self.uiInvitationCode];
    }
}

- (void)onGetInvitationCodeWithTwincodeOutbound:(nullable TLTwincodeOutbound *)twincodeOutbound avatar:(nullable UIImage *)avatar publicKey:(nullable NSString *)publicKey {
    DDLogVerbose(@"%@ onGetInvitationCodeWithTwincodeOutbound: %@ publicKey: %@", LOG_TAG, twincodeOutbound, publicKey);
}

- (void)onGetInvitationsWithInvitations:(nullable NSArray<TLInvitation *> *)invitations {
    DDLogVerbose(@"%@ onGetInvitationsWithInvitations: %@", LOG_TAG, invitations);
    
    for (TLInvitation *invitation in invitations) {
        UIInvitationCode *uiInvitationCode = [self addInvitation:invitation];
        if (uiInvitationCode) {
            [self.invitationCode insertObject:uiInvitationCode atIndex:0];
        }
    }
    
    [self.invitationCodeTableView reloadData];
}

- (void)onGetInvitationCodeNotFound {
    DDLogVerbose(@"%@ onGetInvitationCodeNotFound", LOG_TAG);
    
}

- (void)onGetLocalInvitationCode {
    DDLogVerbose(@"%@ onGetLocalInvitationCode", LOG_TAG);
}

- (void)onGetDefaultProfileWithProfile:(nonnull TLProfile *)profile {
    DDLogVerbose(@"%@ onGetDefaultProfileWithProfile: %@", LOG_TAG, profile);
}

- (void)onGetDefaultProfileNotFound {
    DDLogVerbose(@"%@ onGetDefaultProfileNotFound", LOG_TAG);
}

- (void)onDeleteInvitationWithInvitationId:(nonnull NSUUID *)invitationId {
    DDLogVerbose(@"%@ onDeleteInvitationWithInvitationId: %@", LOG_TAG, invitationId);
    
    for (UIInvitationCode *invitation in self.invitationCode) {
        if ([invitation.invitation.uuid isEqual:invitationId]) {
            [self.invitationCode removeObject:invitation];
            break;
        }
    }
    
    [self.invitationCodeTableView reloadData];
}

- (void)onGetTwincodeNotFound {
    DDLogVerbose(@"%@ onGetDefaultProfileNotFound", LOG_TAG);
}

- (void)onGetTwincodeWithTwincode:(nonnull TLTwincodeOutbound *)twincode avatar:(nullable UIImage *)avatar {
    DDLogVerbose(@"%@ onGetTwincodeWithTwincode: %@ avatar: %@", LOG_TAG, twincode, avatar);
}

- (void)onCreateContact:(TLContact *)contact {
    DDLogVerbose(@"%@ onCreateContact: %@", LOG_TAG, contact);
}

- (void)onInvitationCodeError:(TLBaseServiceErrorCode)errorCode {
    DDLogVerbose(@"%@ onInvitationCodeError: %u", LOG_TAG, errorCode);
    
    self.overlayView.hidden = YES;
    if ([self.activityIndicatorView isAnimating]) {
        [self.activityIndicatorView stopAnimating];
    }
}

- (void)onLimitInvitationCodeReach {
    DDLogVerbose(@"%@ onLimitInvitationCodeReach", LOG_TAG);
 
    self.overlayView.hidden = YES;
    if ([self.activityIndicatorView isAnimating]) {
        [self.activityIndicatorView stopAnimating];
    }
    
    AlertMessageView *alertMessageView = [[AlertMessageView alloc] init];
    alertMessageView.alertMessageViewDelegate = self;
    [alertMessageView initWithTitle:TwinmeLocalizedString(@"delete_account_view_controller_warning", nil) message:TwinmeLocalizedString(@"invitation_code_view_controller_limit_message", nil)];
    [self.tabBarController.view addSubview:alertMessageView];
    [alertMessageView showAlertView];
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

#pragma mark - ConfirmViewDelegate

- (void)didTapConfirm:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didTapConfirm: %@", LOG_TAG, abstractConfirmView);

    [abstractConfirmView closeConfirmView];
    
    if ([abstractConfirmView isKindOfClass:[InvitationCodeShareView class]] && self.uiInvitationCode) {
        [self.invitationCode insertObject:self.uiInvitationCode atIndex:0];
        [self.invitationCodeTableView reloadData];
        self.uiInvitationCode = nil;
   }
}

- (void)didTapCancel:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didTapCancel: %@", LOG_TAG, abstractConfirmView);
    
    [abstractConfirmView closeConfirmView];
    
    if ([abstractConfirmView isKindOfClass:[DefaultConfirmView class]]) {
        [self.twinmeApplication setShowOnboardingType:OnboardingTypeMiniCode state:NO];
    } else if ([abstractConfirmView isKindOfClass:[InvitationCodeShareView class]] && self.uiInvitationCode) {
        [self.invitationCodeService deleteInvitationWithInvitation:self.uiInvitationCode.invitation];
        self.uiInvitationCode = nil;
    }
}

- (void)didClose:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didClose: %@", LOG_TAG, abstractConfirmView);
    
    [abstractConfirmView closeConfirmView];
    
    if ([abstractConfirmView isKindOfClass:[InvitationCodeShareView class]] && self.uiInvitationCode) {
       [self.invitationCodeService deleteInvitationWithInvitation:self.uiInvitationCode.invitation];
       self.uiInvitationCode = nil;
   }
}

- (void)didFinishCloseAnimation:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didFinishCloseAnimation: %@", LOG_TAG, abstractConfirmView);
    
    [abstractConfirmView removeFromSuperview];
}

#pragma mark - Private Methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.definesPresentationContext = YES;
    self.view.backgroundColor = Design.WHITE_COLOR;
    
    [self setNavigationTitle:TwinmeLocalizedString(@"add_contact_view_controller_invitation_code_title", nil).capitalizedString];
    
    UIBarButtonItem *infoBarButtonItem =  [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"OnboardingInfoIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(handleInfoTapGesture:)];
    infoBarButtonItem.tintColor = [UIColor whiteColor];
    infoBarButtonItem.accessibilityLabel = TwinmeLocalizedString(@"conversation_view_controller_menu_item_view_info_title", nil);
    self.navigationItem.rightBarButtonItem = infoBarButtonItem;
    
    self.invitationCodeTableView.backgroundColor = Design.WHITE_COLOR;
    self.invitationCodeTableView.delegate = self;
    self.invitationCodeTableView.dataSource = self;
    self.invitationCodeTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    self.invitationCodeTableView.rowHeight = UITableViewAutomaticDimension;
    self.invitationCodeTableView.estimatedRowHeight = Design.CELL_HEIGHT;
    self.invitationCodeTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.invitationCodeTableView registerNib:[UINib nibWithNibName:@"SectionCallCell" bundle:nil] forCellReuseIdentifier:SECTION_CELL_IDENTIFIER];
    [self.invitationCodeTableView registerNib:[UINib nibWithNibName:@"AddInvitationCodeCell" bundle:nil] forCellReuseIdentifier:ADD_INVITATION_CODE_CELL_IDENTIFIER];
    [self.invitationCodeTableView registerNib:[UINib nibWithNibName:@"InvitationCodeCell" bundle:nil] forCellReuseIdentifier:INVITATION_CODE_CELL_IDENTIFIER];
    self.invitationCodeTableView.sectionHeaderHeight = CGFLOAT_MIN;
    self.invitationCodeTableView.sectionFooterHeight = CGFLOAT_MIN;
    
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
    [self.navigationController.view addSubview:self.overlayView];
}

- (IBAction)handleInfoTapGesture:(id)sender {
    DDLogVerbose(@"%@ handleInfoTapGesture: %@", LOG_TAG, sender);
    
    [self hapticFeedBack:UIImpactFeedbackStyleHeavy];
    
    [self showOnboarding:YES];
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    [self.invitationCodeService dispose];
}

- (void)requestInvitationCode {
    DDLogVerbose(@"%@ requestInvitationCode", LOG_TAG);
    
    [self.invitationCodeService createInvitationWithCode:[self.twinmeApplication isSubscribedWithFeature:TLTwinmeApplicationFeatureGroupCall]];
}

- (void)deleteInvitationCode:(UIInvitationCode *)invitationCode {
    DDLogVerbose(@"%@ deleteInvitationCode: %@", LOG_TAG, invitationCode);
    
    [self.invitationCodeService deleteInvitationWithInvitation:invitationCode.invitation];
}

- (void)showOnboarding:(BOOL)fromInfo {
    DDLogVerbose(@"%@ showOnboarding", LOG_TAG);
    
    DefaultConfirmView *defaultConfirmView = [[DefaultConfirmView alloc] init];
    defaultConfirmView.confirmViewDelegate = self;
    
    NSMutableString *message = [[NSMutableString alloc] initWithString: TwinmeLocalizedString(@"invitation_code_view_controller_onboarding_message", nil)];
    [message appendString:@"\n\n"];
    [message appendString:TwinmeLocalizedString(@"invitation_code_view_controller_success_message", nil)];
    
    [defaultConfirmView initWithTitle:nil message:message image:[UIImage imageNamed:@"OnboardingMiniCode"] avatar:nil action:fromInfo ? TwinmeLocalizedString(@"application_ok", nil) : TwinmeLocalizedString(@"welcome_view_controller_next", nil) actionColor:nil cancel:TwinmeLocalizedString(@"application_do_not_display", nil)];
    [defaultConfirmView useLargeImage];
    
    if (fromInfo) {
        [defaultConfirmView hideCancelAction];
    }
    
    [self.navigationController.view addSubview:defaultConfirmView];
    [defaultConfirmView showConfirmView];
}

- (UIInvitationCode *)addInvitation:(TLInvitation *)invitation {
    DDLogVerbose(@"%@ addInvitation: %@", LOG_TAG, invitation);
    
    if (invitation && invitation.invitationCode) {
        long expirationDate = (invitation.creationDate / 1000) + (60L * 60 * invitation.invitationCode.validityPeriod);
        UIInvitationCode *invitationCode = [[UIInvitationCode alloc]initWithTitle:invitation code:invitation.invitationCode.code expirationDate:expirationDate];
        return invitationCode;
    }
    
    return nil;
}

- (void)showInvitationCodeShareView:(UIInvitationCode *)invitationCode {
    DDLogVerbose(@"%@ showInvitationCodeShareView: %@", LOG_TAG, invitationCode);
    
    InvitationCodeShareView *invitationCodeShareView = [[InvitationCodeShareView alloc] init];
    invitationCodeShareView.confirmViewDelegate = self;
    
    NSMutableString *message = [[NSMutableString alloc] initWithString: TwinmeLocalizedString(@"invitation_code_view_controller_onboarding_message", nil)];
    [message appendString:@"\n\n"];
    [message appendString:TwinmeLocalizedString(@"invitation_code_view_controller_success_message", nil)];
    
    [invitationCodeShareView initWithTitle:invitationCode.code message:message avatar:nil icon:[UIImage imageNamed:@"ActionBarAddContact"]];
    [self.navigationController.view addSubview:invitationCodeShareView];
    [invitationCodeShareView showConfirmView];
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    [self.invitationCodeTableView reloadData];
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);

    self.view.backgroundColor = Design.WHITE_COLOR;
    self.invitationCodeTableView.backgroundColor = Design.WHITE_COLOR;
}

@end

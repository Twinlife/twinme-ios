/*
 *  Copyright (c) 2019-2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 *   Stephane Carrez (Stephane.Carrez@twin.life)
 *   Romain Kolb (romain.kolb@skyrock.com)
 */

#import <CocoaLumberjack.h>

#import <Twinlife/TLConversationService.h>

#import <Twinme/TLContact.h>
#import <Twinme/TLSchedule.h>
#import <Twinme/TLGroup.h>
#import <Twinme/TLCallReceiver.h>
#import <Twinme/TLSpace.h>

#import <Utils/NSString+Utils.h>

#import "HistoryViewController.h"
#import "NotificationViewController.h"
#import "InAppSubscriptionViewController.h"
#import "OnboardingExternalCallViewController.h"
#import "ShowExternalCallViewController.h"
#import "InvitationExternalCallViewController.h"
#import "TemplateExternalCallViewController.h"

#import "CallCell.h"
#import "AddExternalCallCell.h"
#import "SectionCallCell.h"
#import "CellActionView.h"
#import "CallAgainConfirmView.h"
#import "DeleteConfirmView.h"
#import "ContactCell.h"
#import "AlertMessageView.h"

#import "DeviceAuthorization.h"
#import "UIContact.h"
#import "UICall.h"
#import "UICallReceiver.h"
#import "UIPremiumFeature.h"
#import "SpaceSetting.h"
#import "PremiumFeatureConfirmView.h"
#import "UIViewController+ProgressIndicator.h"
#import "UIView+Toast.h"
#import "UIPremiumFeature.h"

#import <TwinmeCommon/ApplicationDelegate.h>
#import <TwinmeCommon/CallsService.h>
#import <TwinmeCommon/CallViewController.h>
#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/MainViewController.h>
#import <TwinmeCommon/TwinmeNavigationController.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static CGFloat DESIGN_NO_CALL_MARGIN_TOP = 160.0;

static NSString *SECTION_CALL_CELL_IDENTIFIER = @"SectionCallCellIdentifier";
static NSString *ADD_EXTERNAL_CALL_CELL_IDENTIFIER = @"AddExternalCallCellIdentifier";
static NSString *CALL_CELL_IDENTIFIER = @"CallCellIdentifier";
static NSString *CONTACT_CELL_IDENTIFIER = @"ContactCellIdentifier";


static const int HISTORY_VIEW_SECTION_COUNT = 3;

static const int CREATE_EXTERNAL_CALL_SECTION = 0;
static const int EXTERNAL_CALL_SECTION = 1;
static const int LAST_CALLS_SECTION = 2;

static const int NB_CALL_RECEIVER = 3;

//
// Interface: HistoryViewController
//

@interface HistoryViewController () <UITableViewDataSource, UITableViewDelegate, CallsServiceDelegate, SectionCallDelegate, ConfirmViewDelegate, AlertMessageViewDelegate, OnboardingExternalCallDelegate>

@property (weak, nonatomic) IBOutlet UITableView *callsTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noCallImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noCallImageViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noCallImageViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *noCallImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noCallTitleLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noCallTitleLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *noCallTitleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noCallLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noCallLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *noCallLabel;
@property (nonatomic) UISegmentedControl *segmentedControl;
@property (nonatomic) UIBarButtonItem *resetCallsBarButtonItem;

@property (nonatomic) NSMutableDictionary<NSUUID*, UIContact*> *uiContacts;
@property (nonatomic) NSMutableArray<TLCallDescriptor *> *allCalls;
@property (nonatomic) NSArray<TLCallDescriptor *> *filteredCalls;
@property (nonatomic) NSMutableArray<UICall *> *uiCalls;
@property (nonatomic) NSMutableArray<UICallReceiver *> *uiCallReceivers;
@property (nonatomic) CallsService *callsService;
@property (nonatomic) id<TLOriginator> callOriginator;
@property (nonatomic) TLCallDescriptor *callDescriptor;
@property (nonatomic) TLCallReceiver *callReceiverToDelete;

@property (nonatomic) BOOL onlyMissedCalls;
@property (nonatomic) BOOL resetAllCalls;
@property (nonatomic) BOOL displayAllCallReceiver;
@property (nonatomic) int nbCallReceivers;
@property (nonatomic) BOOL refreshTableScheduled;

- (void)deleteOriginator:(nonnull id<TLOriginator>)originator;

@end

//
// Implementation: HistoryViewController
//

#undef LOG_TAG
#define LOG_TAG @"HistoryViewController"

@implementation HistoryViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _onlyMissedCalls = NO;
        _resetAllCalls = NO;
        _displayAllCallReceiver = NO;
        _nbCallReceivers = NO;
        _uiCalls = [[NSMutableArray alloc] init];
        _uiCallReceivers = [[NSMutableArray alloc] init];
        _allCalls = [[NSMutableArray alloc] init];
        _filteredCalls = [[NSArray alloc] init];
        _uiContacts = [[NSMutableDictionary alloc]init];
        _callsService = [[CallsService alloc] initWithTwinmeContext:self.twinmeContext delegate:self originator:nil];
    }
    
    return self;
}

- (void)encodeWithCoder:(nonnull NSCoder *)coder { 
    DDLogVerbose(@"%@ encodeWithCoder: %@", LOG_TAG, coder);
}

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
    
    [self initViews];
}

- (void)viewWillAppear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillAppear: %d", LOG_TAG, animated);
    
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setPrefersLargeTitles:YES];
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAutomatic;
    
    [self reloadData];
    [self updateCurrentSpace];
}

- (void)viewWillDisappear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillDisappear: %d", LOG_TAG, animated);
    
    [super viewWillDisappear:animated];
    
    [self.navigationController.navigationBar setPrefersLargeTitles:NO];
}

- (BOOL)hidesBottomBarWhenPushed {
    DDLogVerbose(@"%@ hidesBottomBarWhenPushed", LOG_TAG);
    
    return NO;
}

#pragma mark - CallsServiceDelegate

- (void)onSetCurrentSpace:(nonnull TLSpace *)space {
    DDLogVerbose(@"%@ onSetCurrentSpace: %@", LOG_TAG, space);
        
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.callsTableView scrollsToTop];
    });
    
    [self.uiContacts removeAllObjects];
    [self.allCalls removeAllObjects];
    [self.uiCallReceivers removeAllObjects];
    self.filteredCalls = [[NSArray alloc]init];
    [self reloadData];
    [self setLeftBarButtonItem:self.callsService profile:space.profile];
    
    TLSpaceSettings *spaceSettings = space.settings;
    if ([space.settings getBooleanWithName:PROPERTY_DEFAULT_APPEARANCE_SETTINGS defaultValue:YES]) {
        spaceSettings = self.twinmeContext.defaultSpaceSettings;
    }
    
    if (![Design.MAIN_STYLE isEqualToString:spaceSettings.style]) {
        [Design setMainColor:spaceSettings.style];
    }
    
    TwinmeNavigationController *navigationController = (TwinmeNavigationController *) self.navigationController;
    [navigationController setNavigationBarStyle];
}

- (void)onGetSpace:(nonnull TLSpace *)space avatar:(nullable UIImage *)avatar {
    DDLogVerbose(@"%@ onGetSpace: %@", LOG_TAG, space);
    
    [self setLeftBarButtonItem:self.callsService profile:space.profile];
}

- (void)onUpdateSpace:(nonnull TLSpace *)space {
    DDLogVerbose(@"%@ onUpdateSpace: %@", LOG_TAG, space);
    
    [self setLeftBarButtonItem:self.callsService profile:space.profile];
    
    TwinmeNavigationController *navigationController = (TwinmeNavigationController *) self.navigationController;
    [navigationController setNavigationBarStyle];
}

- (void)onGetDescriptors:(nonnull NSArray<TLCallDescriptor *> *)descriptors {
    DDLogVerbose(@"%@ onGetDescriptors: %@", LOG_TAG, descriptors);
    
    for (TLCallDescriptor *descriptor in descriptors) {
        if (![self.allCalls containsObject:descriptor]) {
            [self.allCalls addObject:descriptor];
        }
    }
    
    if (self.resetAllCalls) {
        NSInteger count = self.allCalls.count;
        if (count == 0) {
            self.resetAllCalls = NO;
            self.resetCallsBarButtonItem.enabled = NO;
            [self hideProgressIndicator];
            [self updateCalls];
        } else {
            for (NSInteger i = 0; i < count; i++) {
                TLCallDescriptor *callDescriptor = self.allCalls[i];
                [self.callsService deleteCallDescriptor:callDescriptor];
            }
        }
    } else {
        [self updateCalls];
    }
}

- (void)onAddDescriptor:(nonnull TLCallDescriptor *)descriptor {
    DDLogVerbose(@"%@ onAddDescriptor: %@", LOG_TAG, descriptor);
    
    if (![self.allCalls containsObject:descriptor]) {
        [self.allCalls insertObject:descriptor atIndex:0];
    }
    
    [self updateCalls];
}

- (void)onUpdateDescriptor:(nonnull TLCallDescriptor *)descriptor {
    DDLogVerbose(@"%@ onAddDescriptor: %@", LOG_TAG, descriptor);
    
    BOOL isUpdated = NO;
    NSInteger count = self.allCalls.count;
    for (int i = 0; i < count; i++) {
        TLCallDescriptor *lDescriptor = [self.allCalls objectAtIndex:i];
        if ([lDescriptor isEqualDescriptor:descriptor]) {
            [self.allCalls replaceObjectAtIndex:i withObject:descriptor];
            isUpdated = YES;
            break;
        }
    }
    
    if (!isUpdated) {
        [self.allCalls insertObject:descriptor atIndex:0];
    }
    
    [self updateCalls];
}

- (void)onDeleteDescriptors:(nonnull NSSet<TLDescriptorId *> *)descriptors {
    DDLogVerbose(@"%@ onDeleteDescriptors: %@", LOG_TAG, descriptors);
    
    NSMutableSet *descriptorList = [[NSMutableSet alloc] initWithSet:descriptors];
    for (TLCallDescriptor *lDescriptor in self.allCalls) {
        TLDescriptorId *descriptorId = lDescriptor.descriptorId;
        if ([descriptorList containsObject:descriptorId]) {
            [descriptorList removeObject:descriptorId];
            [self.allCalls removeObject:lDescriptor];
            if (descriptorList.count == 0) {
                break;
            }
        }
    }
    
    if (self.resetAllCalls && self.allCalls.count == 0) {
        if ([self.callsService isGetDescriptorsDone]) {
            self.resetAllCalls = NO;
            self.resetCallsBarButtonItem.enabled = NO;
            [self hideProgressIndicator];
            [self updateCalls];
        } else {
            [self getPreviousDescriptors];
        }
    } else if (!self.resetAllCalls) {
        [self updateCalls];
    }
}

- (void)onCreateOriginator:(nonnull id<TLOriginator>)originator avatar:(nonnull UIImage *)avatar {
    DDLogVerbose(@"%@ onCreateContact: %@", LOG_TAG, originator);
    
    UIContact *uiContact = [[UIContact alloc] initWithContact:originator avatar:avatar];
    [self.uiContacts setObject:uiContact forKey:originator.uuid];
    [self.uiContacts setObject:uiContact forKey:originator.twincodeOutboundId];
}

- (void)onUpdateOriginator:(nonnull TLContact *)contact avatar:(nonnull UIImage *)avatar {
    DDLogVerbose(@"%@ onUpdateContact: %@", LOG_TAG, contact);
    
    UIContact *uiContact = self.uiContacts[contact.uuid];
    if (uiContact) {
        if (contact.hasPeer) {
            [uiContact setContact:contact avatar:avatar];
        } else {
            [self deleteOriginator:contact];
        }
        [self updateCalls];
    }
}

- (void)onDeleteOriginator:(id<TLOriginator>)originator {
    DDLogVerbose(@"%@ onDeleteContact: %@", LOG_TAG, originator);
    
    UIContact *uiContact = self.uiContacts[originator.uuid];
    if (uiContact) {
        [self deleteOriginator:originator];
    }
}

- (void)onResetConversation:(id<TLConversation>)conversation clearMode:(TLConversationServiceClearMode)clearMode {
    DDLogVerbose(@"%@ onResetConversation: %@ clearMode: %d", LOG_TAG, conversation, clearMode);
    
    if (clearMode == TLConversationServiceClearMedia) {
        return;
    }
    for (int i = 0; i < [self.allCalls count]; i++) {
        TLCallDescriptor *descriptor = [self.allCalls objectAtIndex:i];
        if ([descriptor isTwincodeOutbound:conversation.twincodeOutboundId] || [descriptor isTwincodeOutbound:conversation.peerTwincodeOutboundId]) {
            [self.allCalls removeObject:descriptor];
            i--;
        }
    }
    
    [self updateCalls];
}

- (void)onGetOriginators:(nonnull NSArray<id<TLOriginator>> *)originators {
    DDLogVerbose(@"%@ onGetOriginators: %@", LOG_TAG, originators);
    
    for (id<TLOriginator> originator in originators) {
        UIContact *uiContact = [[UIContact alloc] initWithContact:originator];
        [self.uiContacts setObject:uiContact forKey:originator.uuid];
        [self.uiContacts setObject:uiContact forKey:originator.twincodeOutboundId];
        
        if (originator.isGroup) {
            [self.callsService getImageWithGroup:originator withBlock:^(UIImage *image) {
                [uiContact updateAvatar:image];
                [self refreshTable];
            }];
        } else {
            [self.callsService getImageWithContact:originator withBlock:^(UIImage *image) {
                [uiContact updateAvatar:image];
                [self refreshTable];
            }];
        }
    }
}

- (void)onGetCallReceivers:(NSArray<TLCallReceiver *> *)callReceivers {
    DDLogVerbose(@"%@ onGetCallReceivers: %@", LOG_TAG, callReceivers);
    
    for (TLCallReceiver *callReceiver in callReceivers) {
        UIContact *uiContact = [[UIContact alloc] initWithContact:callReceiver];
        [self.uiContacts setObject:uiContact forKey:callReceiver.uuid];
        [self.uiContacts setObject:uiContact forKey:callReceiver.twincodeOutboundId];
        [self updateUICallReceiver:callReceiver avatar:nil];
    }

    [self updateCalls];
}

- (void)onCreateCallReceiver:(nonnull TLCallReceiver *)callReceiver {
    DDLogVerbose(@"%@ onCreateCallReceiver: %@", LOG_TAG, callReceiver);
    
    UIContact *uiContact = [[UIContact alloc] initWithContact:callReceiver];
    [self.uiContacts setObject:uiContact forKey:callReceiver.uuid];
    [self.uiContacts setObject:uiContact forKey:callReceiver.twincodeOutboundId];
    [self updateUICallReceiver:callReceiver avatar:nil];
        
    [self updateCalls];
}

- (void)onUpdateCallReceiver:(nonnull TLCallReceiver *)callReceiver {
    DDLogVerbose(@"%@ onUpdateCallReceiver: %@", LOG_TAG, callReceiver);
    
    for (UICallReceiver *uiCallReceiver in self.uiCallReceivers) {
        if ([uiCallReceiver.callReceiver.uuid isEqual:callReceiver.uuid]) {
            UIContact *uiContact = [[UIContact alloc] initWithContact:callReceiver];
            [self.uiContacts setObject:uiContact forKey:callReceiver.uuid];
            [self.uiContacts setObject:uiContact forKey:callReceiver.twincodeOutboundId];
            
            [self updateUICallReceiver:callReceiver avatar:nil];
            break;
        }
    }
    
    [self updateCalls];
}

- (void)onDeleteCallReceiver:(nonnull NSUUID *)callReceiverId {
    DDLogVerbose(@"%@ onDeleteCallReceiver: %@", LOG_TAG, callReceiverId);
        
    if ([callReceiverId isEqual:self.callReceiverToDelete.uuid]) {
        self.callReceiverToDelete = nil;
    }
        
    for (UICallReceiver *uiCallReceiver in self.uiCallReceivers) {
        if ([callReceiverId isEqual:uiCallReceiver.callReceiver.uuid]) {
            [self.uiContacts removeObjectForKey:uiCallReceiver.callReceiver.uuid];
            [self.uiContacts removeObjectForKey:uiCallReceiver.callReceiver.twincodeOutboundId];
            [self.uiCallReceivers removeObject:uiCallReceiver];
            break;
        }
    }
    
    [self updateCalls];
}

- (void)onGetGroupMembers:(nonnull NSMutableArray<id<TLGroupMemberConversation>> *)members {
    DDLogVerbose(@"%@ onGetGroupMembers: %@", LOG_TAG, members);
    
    if (members.count + 1 > MAX_CALL_GROUP_PARTICIPANTS) {
        AlertMessageView *alertMessageView = [[AlertMessageView alloc] init];
        alertMessageView.alertMessageViewDelegate = self;
        [alertMessageView initWithTitle:TwinmeLocalizedString(@"delete_account_view_controller_warning", nil) message:[NSString stringWithFormat:TwinmeLocalizedString(@"call_view_controller_max_participant_message", nil), MAX_CALL_GROUP_PARTICIPANTS]];
        [self.tabBarController.view addSubview:alertMessageView];
        [alertMessageView showAlertView];
        
        return;
    }
    
    [self callAgain];
}

- (void)onGetCountCallReceivers:(int)countCallReceivers {
    DDLogVerbose(@"%@ onGetCountCallReceivers: %d", LOG_TAG, countCallReceivers);
    
    if ([self.twinmeApplication startOnboarding:OnboardingTypeExternalCall]) {
        OnboardingExternalCallViewController *onboardingExternalCallViewController = [[UIStoryboard storyboardWithName:@"ExternalCall" bundle:nil] instantiateViewControllerWithIdentifier:@"OnboardingExternalCallViewController"];
        onboardingExternalCallViewController.onboardingExternalCallDelegate = self;
        ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
        MainViewController *mainViewController = delegate.mainViewController;
        onboardingExternalCallViewController.createExternalCallEnable = [self.twinmeApplication isSubscribedWithFeature:TLTwinmeApplicationFeatureGroupCall] || countCallReceivers < 2;
        [onboardingExternalCallViewController showInView:mainViewController];
    } else if (countCallReceivers >= 2 && ![self.twinmeApplication isSubscribedWithFeature:TLTwinmeApplicationFeatureGroupCall]) {
        ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
        MainViewController *mainViewController = delegate.mainViewController;
        PremiumFeatureConfirmView *premiumFeatureConfirmView = [[PremiumFeatureConfirmView alloc] init];
        premiumFeatureConfirmView.confirmViewDelegate = self;
        [premiumFeatureConfirmView initWithPremiumFeature:[[UIPremiumFeature alloc]initWithFeatureType:FeatureTypeClickToCall spaceSettings:self.currentSpaceSettings] parentViewController:mainViewController];
        [mainViewController.view addSubview:premiumFeatureConfirmView];
        [premiumFeatureConfirmView showConfirmView];
    } else {
        TemplateExternalCallViewController *templateExternalCallViewController = [[UIStoryboard storyboardWithName:@"ExternalCall" bundle:nil] instantiateViewControllerWithIdentifier:@"TemplateExternalCallViewController"];
        [self.navigationController pushViewController:templateExternalCallViewController animated:YES];
    }
}

- (void)showProgressIndicator {
    DDLogVerbose(@"%@ showProgressIndicator", LOG_TAG);
    [super showProgressIndicator];
}

- (void)hideProgressIndicator {
    DDLogVerbose(@"%@ hideProgressIndicator", LOG_TAG);
    [super hideProgressIndicator];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    DDLogVerbose(@"%@ numberOfSectionsInTableView: %@", LOG_TAG, tableView);
    
    if (!self.currentSpace.profile) {
        return 0;
    }
    
    return HISTORY_VIEW_SECTION_COUNT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ numberOfRowsInSection: %ld", LOG_TAG, tableView, (long)section);
    
    if (section == CREATE_EXTERNAL_CALL_SECTION) {
        return 1;
    } else if (section == EXTERNAL_CALL_SECTION) {
        return self.nbCallReceivers;
    }
    
    return self.uiCalls.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
    
    return Design.CELL_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ heightForHeaderInSection: %ld", LOG_TAG, tableView, (long)section);
        
    if (section == CREATE_EXTERNAL_CALL_SECTION) {
        return CGFLOAT_MIN;
    } else if (section == EXTERNAL_CALL_SECTION && self.nbCallReceivers > 0) {
        return Design.CELL_HEIGHT;
    } else if (section == LAST_CALLS_SECTION && self.filteredCalls.count > 0) {
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
    
    SectionCallCell *sectionCallCell = (SectionCallCell *)[tableView dequeueReusableCellWithIdentifier:SECTION_CALL_CELL_IDENTIFIER];
    if (!sectionCallCell) {
        sectionCallCell = [[SectionCallCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SECTION_CALL_CELL_IDENTIFIER];
    }
    
    sectionCallCell.sectionCallDelegate = self;
        
    NSString *sectionName = @"";
    BOOL showRightAction = NO;
    switch (section) {
        case EXTERNAL_CALL_SECTION:
            sectionName = TwinmeLocalizedString(@"premium_services_view_controller_click_to_call_title", nil);
            if (self.displayAllCallReceiver || self.uiCallReceivers.count <= NB_CALL_RECEIVER) {
                showRightAction = NO;
            } else {
                showRightAction = YES;
            }
            
            break;
                
        case LAST_CALLS_SECTION:
            sectionName = TwinmeLocalizedString(@"show_contact_view_controller_history_title", nil);
            break;
            
        default:
            sectionName = @"";
            break;
    }
    
    [sectionCallCell bindWithTitle:sectionName hideSeparator:NO uppercaseString:YES showRightAction:showRightAction];
    
    return sectionCallCell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ cellForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if (indexPath.section == CREATE_EXTERNAL_CALL_SECTION) {
        AddExternalCallCell *addExternalCallCell = (AddExternalCallCell *)[tableView dequeueReusableCellWithIdentifier:ADD_EXTERNAL_CALL_CELL_IDENTIFIER];
        if (!addExternalCallCell) {
            addExternalCallCell = [[AddExternalCallCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ADD_EXTERNAL_CALL_CELL_IDENTIFIER];
        }
        
        [addExternalCallCell bindWithTitle:TwinmeLocalizedString(@"history_view_controller_create_link", nil) subTitle:TwinmeLocalizedString(@"show_call_view_controller_code_information", nil)];
        
        return addExternalCallCell;
    } else if (indexPath.section == EXTERNAL_CALL_SECTION) {
        ContactCell *contactCell = (ContactCell *)[tableView dequeueReusableCellWithIdentifier:CONTACT_CELL_IDENTIFIER];
        if (!contactCell) {
            contactCell = [[ContactCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CONTACT_CELL_IDENTIFIER];
        }
        
        if (indexPath.row < self.uiCallReceivers.count) {
            UICallReceiver *uiCallReceiver = self.uiCallReceivers[indexPath.row];
            BOOL hideSchedule = YES;
            
            if (uiCallReceiver.callReceiver.capabilities && uiCallReceiver.callReceiver.capabilities.schedule) {
                hideSchedule = !uiCallReceiver.callReceiver.capabilities.schedule.enabled;
            }
            BOOL hideSeparator = indexPath.row + 1 == self.nbCallReceivers ? YES : NO;

            [contactCell bindWithName:uiCallReceiver.name avatar:uiCallReceiver.avatar hideSeparator:hideSeparator hideSchedule:hideSchedule];
        }
        
        return contactCell;
    } else {
        if (indexPath.row == [self.uiCalls count] - 1 && ![self.callsService isGetDescriptorsDone]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self getPreviousDescriptors];
            });
        }
        
        CallCell *callCell = (CallCell *)[tableView dequeueReusableCellWithIdentifier:CALL_CELL_IDENTIFIER];
        if (!callCell) {
            callCell = [[CallCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CALL_CELL_IDENTIFIER];
        }
        
        if (indexPath.row < self.uiCalls.count) {
            UICall *uiCall = [self.uiCalls objectAtIndex:indexPath.row];
            
            BOOL hideSeparator = indexPath.row + 1 == self.uiCalls.count ? YES : NO;
            [callCell bindWithCall:uiCall hideSeparator:hideSeparator];
       }
    
        return callCell;
    }
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == CREATE_EXTERNAL_CALL_SECTION) {
        return nil;
    }
    
    // Get the UI call now since the list could change while contextualActionWithStyle executes.
    UICall *uiCall = nil;
    UICallReceiver *uiCallReceiver = nil;
    if (indexPath.section == LAST_CALLS_SECTION){
        uiCall = [self.uiCalls objectAtIndex:indexPath.row];
    } else {
        uiCallReceiver = [self.uiCallReceivers objectAtIndex:indexPath.row];
    }
    
    UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:TwinmeLocalizedString(@"application_remove", nil) handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        
        if (uiCall) {
            [self handleDeleteHistory:uiCall];
        } else {
            [self handleDeleteCallReceiver:uiCallReceiver];
        }
    }];
    
    CellActionView *deleteActionView = [[CellActionView alloc]initWithTitle:TwinmeLocalizedString(@"application_remove", nil) icon:@"ToolbarTrash" backgroundColor:[UIColor clearColor] iconWidth:32 iconHeight:38 iconTopMargin:28];
    deleteAction.image = [deleteActionView imageFromView];
    deleteAction.backgroundColor = Design.DELETE_COLOR_RED;
    
    UIContextualAction *shareAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:TwinmeLocalizedString(@"application_remove", nil) handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
            [self handleShareCallReceiver:uiCallReceiver];
        }];
        
    CellActionView *shareActionView = [[CellActionView alloc]initWithTitle:TwinmeLocalizedString(@"share_view_controller_title", nil) icon:@"QRCode" backgroundColor:[UIColor clearColor] iconWidth:38 iconHeight:38 iconTopMargin:28];
    shareAction.image = [shareActionView imageFromView];
    shareAction.backgroundColor = Design.MAIN_COLOR;
    
    if (indexPath.section == LAST_CALLS_SECTION) {
        UISwipeActionsConfiguration *swipeActionConfiguration = [UISwipeActionsConfiguration configurationWithActions:@[deleteAction]];
        swipeActionConfiguration.performsFirstActionWithFullSwipe = NO;
        return swipeActionConfiguration;
    } else {
        UISwipeActionsConfiguration *swipeActionConfiguration = [UISwipeActionsConfiguration configurationWithActions:@[shareAction, deleteAction]];
        swipeActionConfiguration.performsFirstActionWithFullSwipe = NO;
        return swipeActionConfiguration;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ didSelectRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if (indexPath.section == LAST_CALLS_SECTION) {
        if (!self.twinmeApplication.inCall) {
            UICall *uiCall = [self.uiCalls objectAtIndex:indexPath.row];
            self.callDescriptor = [uiCall getLastCallDescriptor];
            
            if([(NSObject *)uiCall.uiContact.contact class] != [TLCallReceiver class]){
                
                self.callOriginator = uiCall.uiContact.contact;
                
                if (self.callOriginator.isGroup) {
                    [self.callsService getGroupMembers:self.callOriginator];
                } else {
                    [self callAgain];
                }
            }
        }
    } else if (indexPath.section == EXTERNAL_CALL_SECTION) {
        UICallReceiver *uiCallReceiver = [self.uiCallReceivers objectAtIndex:indexPath.row];
        ShowExternalCallViewController *showExternalCallViewController = [[UIStoryboard storyboardWithName:@"ExternalCall" bundle:nil] instantiateViewControllerWithIdentifier:@"ShowExternalCallViewController"];
        [showExternalCallViewController initWithCallReceiver:uiCallReceiver.callReceiver];
        [self.navigationController pushViewController:showExternalCallViewController animated:YES];
    } else if (indexPath.section == CREATE_EXTERNAL_CALL_SECTION) {
        [self.callsService countCallReceivers];
    }
}

#pragma mark - SectionCallDelegate

 - (void)didTapRight {
    DDLogVerbose(@"%@ didTapRight", LOG_TAG);
    
    self.displayAllCallReceiver = YES;
    
    [self reloadData];
}

#pragma mark - ConfirmViewDelegate

- (void)didTapConfirm:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didTapConfirm: %@", LOG_TAG, abstractConfirmView);
    
    if ([abstractConfirmView isKindOfClass:[PremiumFeatureConfirmView class]]) {
        InAppSubscriptionViewController *inAppSubscriptionViewController = [[UIStoryboard storyboardWithName:@"iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"InAppSubscriptionViewController"];
        TwinmeNavigationController *navigationController = [[TwinmeNavigationController alloc]initWithRootViewController:inAppSubscriptionViewController];
        [self.navigationController presentViewController:navigationController animated:YES completion:nil];
    } else if ([abstractConfirmView isKindOfClass:[DeleteConfirmView class]]) {
        DeleteConfirmView *deleteConfirmView = (DeleteConfirmView *)abstractConfirmView;
        if (deleteConfirmView.deleteConfirmType == DeleteConfirmTypeHistory) {
            self.resetAllCalls = YES;
            self.resetCallsBarButtonItem.enabled = NO;
            [self showProgressIndicator];
            
            NSInteger count = self.allCalls.count;
            for (NSInteger i = 0; i < count; i++) {
                TLCallDescriptor *callDescriptor = self.allCalls[i];
                [self.callsService deleteCallDescriptor:callDescriptor];
            }
        } else if (deleteConfirmView.deleteConfirmType == DeleteConfirmTypeOriginator && self.callReceiverToDelete) {
            [self.callsService deleteCallReceiverWithCallReceiver:self.callReceiverToDelete];
        }
    } else if ([abstractConfirmView isKindOfClass:[CallAgainConfirmView class]]) {
        if (self.callOriginator) {
            if (self.callDescriptor.isVideo) {
                [self startVideoCallWithPermissionCheck:NO];
            } else {
                [self startAudioCallWithPermissionCheck];
            }
        }
        
        self.callDescriptor = nil;
    }
    
    [abstractConfirmView closeConfirmView];
}

- (void)didTapCancel:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didTapCancel: %@", LOG_TAG, abstractConfirmView);
    
    self.callReceiverToDelete = nil;
    self.callDescriptor = nil;
    [abstractConfirmView closeConfirmView];
}

- (void)didClose:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didClose: %@", LOG_TAG, abstractConfirmView);
    
    self.callReceiverToDelete = nil;
    self.callDescriptor = nil;
    [abstractConfirmView closeConfirmView];
}

- (void)didFinishCloseAnimation:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didFinishCloseAnimation: %@", LOG_TAG, abstractConfirmView);
    
    [abstractConfirmView removeFromSuperview];
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

#pragma mark - OnboardingExternalCallDelegate

- (void)didTouchCreateExernalCall {
    DDLogVerbose(@"%@ didTouchCreateExernalCall", LOG_TAG);
    
    PremiumFeatureConfirmView *premiumFeatureConfirmView = [[PremiumFeatureConfirmView alloc] init];
    premiumFeatureConfirmView.confirmViewDelegate = self;
    [premiumFeatureConfirmView initWithPremiumFeature:[[UIPremiumFeature alloc]initWithFeatureType:FeatureTypeClickToCall spaceSettings:self.currentSpaceSettings] parentViewController:self.tabBarController];
    [self.tabBarController.view addSubview:premiumFeatureConfirmView];
    [premiumFeatureConfirmView showConfirmView];
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.view.backgroundColor = Design.WHITE_COLOR;
    
    [self setNavigationTitle:TwinmeLocalizedString(@"history_view_controller_title", nil).capitalizedString];
    
    self.resetCallsBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"ActionBarDelete"] style:UIBarButtonItemStylePlain target:self action:@selector(handleResetTapGesture:)];
    self.resetCallsBarButtonItem.accessibilityLabel = TwinmeLocalizedString(@"history_view_controller_reset_title", nil);
    self.resetCallsBarButtonItem.enabled = NO;
    self.navigationItem.rightBarButtonItem = self.resetCallsBarButtonItem;
    
    self.segmentedControl = [[UISegmentedControl alloc]initWithItems:@[TwinmeLocalizedString(@"history_view_controller_all_call_segmented_control", nil), TwinmeLocalizedString(@"history_view_controller_missed_call_segmented_control", nil)]];
    [self.segmentedControl setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: Design.FONT_REGULAR32, NSFontAttributeName, [UIColor whiteColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    [self.segmentedControl setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: Design.FONT_REGULAR32, NSFontAttributeName, Design.MAIN_COLOR, NSForegroundColorAttributeName, nil] forState:UIControlStateSelected];
    self.segmentedControl.selectedSegmentIndex = 0;
    self.segmentedControl.tintColor = [UIColor whiteColor];
    
    if (@available(iOS 13.0, *)) {
        self.segmentedControl.selectedSegmentTintColor = [UIColor whiteColor];
    }
    
    [self.segmentedControl addTarget:self action:@selector(segmentedControlValueDidChange:) forControlEvents:UIControlEventValueChanged];
    
    self.navigationItem.titleView = self.segmentedControl;
    
    self.callsTableView.delegate = self;
    self.callsTableView.dataSource = self;
    self.callsTableView.backgroundColor = Design.WHITE_COLOR;
    self.callsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.callsTableView registerNib:[UINib nibWithNibName:@"SectionCallCell" bundle:nil] forCellReuseIdentifier:SECTION_CALL_CELL_IDENTIFIER];
    [self.callsTableView registerNib:[UINib nibWithNibName:@"AddExternalCallCell" bundle:nil] forCellReuseIdentifier:ADD_EXTERNAL_CALL_CELL_IDENTIFIER];
    [self.callsTableView registerNib:[UINib nibWithNibName:@"CallCell" bundle:nil] forCellReuseIdentifier:CALL_CELL_IDENTIFIER];
    [self.callsTableView registerNib:[UINib nibWithNibName:@"ContactCell" bundle:nil] forCellReuseIdentifier:CONTACT_CELL_IDENTIFIER];
    self.callsTableView.tableFooterView = [[UIView alloc] init];
    
    self.noCallImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.noCallImageViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.noCallImageViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.noCallImageView.hidden = YES;
    
    self.noCallTitleLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.noCallTitleLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.noCallTitleLabel.font = Design.FONT_MEDIUM34;
    self.noCallTitleLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.noCallTitleLabel.text = TwinmeLocalizedString(@"history_view_controller_no_call_title", nil);
    self.noCallTitleLabel.hidden = YES;
    
    self.noCallLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.noCallLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.noCallLabel.font = Design.FONT_MEDIUM28;
    self.noCallLabel.textColor = Design.FONT_COLOR_DESCRIPTION;
    self.noCallLabel.text = TwinmeLocalizedString(@"history_view_controller_no_call_message", nil);
    self.noCallLabel.hidden = YES;
}

- (IBAction)handleNotificationTapGesture:(id)sender {
    DDLogVerbose(@"%@ handleNotificationTapGesture: %@", LOG_TAG, sender);
    
    NotificationViewController *notificationViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"NotificationViewController"];
    [self.navigationController pushViewController:notificationViewController animated:YES];
}

- (IBAction)segmentedControlValueDidChange:(id)sender {
    DDLogVerbose(@"%@ segmentedControlValueDidChange: %@", LOG_TAG, sender);
    
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        self.onlyMissedCalls = NO;
    } else {
        self.onlyMissedCalls = YES;
    }
    
    [self updateCalls];
}

- (void)handleDeleteHistory:(UICall *)uiCall {
    DDLogVerbose(@"%@ handleDeleteHistory: %@", LOG_TAG, uiCall);
    
    if (uiCall) {
        NSInteger count = uiCall.callDescriptors.count;
        for (NSInteger i = 0; i < count; i++) {
            TLCallDescriptor *callDescriptor = uiCall.callDescriptors[i];
            [self.callsService deleteCallDescriptor:callDescriptor];
        }
    }
}

- (void)handleDeleteCallReceiver:(UICallReceiver *)uiCallReceiver {
    DDLogVerbose(@"%@ handleDeleteCallReceiver: %@", LOG_TAG, uiCallReceiver);
    
    if (uiCallReceiver) {
        [self.callsTableView setEditing:NO];
        self.callReceiverToDelete = uiCallReceiver.callReceiver;
        
        NSString *message = [NSString stringWithFormat:@"%@\n%@", TwinmeLocalizedString(@"edit_external_call_view_controller_message", nil), TwinmeLocalizedString(@"edit_external_call_view_controller_confirm_message", nil)];
        
        DeleteConfirmView *deleteConfirmView = [[DeleteConfirmView alloc] init];
        deleteConfirmView.confirmViewDelegate = self;
        deleteConfirmView.deleteConfirmType = DeleteConfirmTypeOriginator;
        [deleteConfirmView initWithTitle:TwinmeLocalizedString(@"delete_account_view_controller_warning", nil) message:message avatar:uiCallReceiver.avatar icon:[UIImage imageNamed:@"ActionBarDelete"]];
        [self.tabBarController.view addSubview:deleteConfirmView];
        [deleteConfirmView showConfirmView];
    }
}

 - (void)handleShareCallReceiver:(UICallReceiver *)uiCallReceiver {
    DDLogVerbose(@"%@ handleShareCallReceiver: %@", LOG_TAG, uiCallReceiver);
    
    if (uiCallReceiver) {
        InvitationExternalCallViewController *invitationExternalCallViewController = [[UIStoryboard storyboardWithName:@"ExternalCall" bundle:nil] instantiateViewControllerWithIdentifier:@"InvitationExternalCallViewController"];
        [invitationExternalCallViewController initWithCallReceiver:uiCallReceiver.callReceiver];
        [self.navigationController pushViewController:invitationExternalCallViewController animated:YES];
    }
}

- (void)getPreviousDescriptors {
    DDLogVerbose(@"%@ getPreviousDescriptors", LOG_TAG);
    
    [self.callsService getPreviousDescriptors];
}

- (void)updateCalls {
    DDLogVerbose(@"%@ updateCalls", LOG_TAG);
    
    self.filteredCalls = [self.allCalls filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(TLCallDescriptor *callDescriptor, NSDictionary *bindings) {
        return [self showCall:callDescriptor];
    }]];
    
    [self.uiCalls removeAllObjects];
    
    if (self.filteredCalls.count > 0) {
        TLCallDescriptor *callDescriptor = [self.filteredCalls objectAtIndex:0];
        if (self.filteredCalls.count == 1) {
            UIContact *uiContact = [self.uiContacts objectForKey:callDescriptor.descriptorId.twincodeOutboundId];
            UICall *uiCall = [[UICall alloc]initWithCall:[NSArray arrayWithObject:callDescriptor] uiContact:uiContact];
            [self.uiCalls addObject:uiCall];
        } else {
            NSMutableArray *callsDescriptors = [[NSMutableArray alloc]init];
            [callsDescriptors addObject:callDescriptor];
            for (int i = 1; i < self.filteredCalls.count; i++) {
                TLCallDescriptor *cd = [self.filteredCalls objectAtIndex:i];
                
                if ([self sameCall:callDescriptor callDescriptor2:cd]) {
                    [callsDescriptors addObject:cd];
                } else {
                    UIContact *uiContact = [self.uiContacts objectForKey:callDescriptor.descriptorId.twincodeOutboundId];
                    UICall *uiCall = [[UICall alloc]initWithCall:[NSArray arrayWithArray:callsDescriptors] uiContact:uiContact];
                    [self.uiCalls addObject:uiCall];
                    [callsDescriptors removeAllObjects];
                    [callsDescriptors addObject:cd];
                }
                
                if (i + 1 == self.filteredCalls.count) {
                    UIContact *uiContact = [self.uiContacts objectForKey:cd.descriptorId.twincodeOutboundId];
                    UICall *uiCall = [[UICall alloc]initWithCall:[NSArray arrayWithArray:callsDescriptors] uiContact:uiContact];
                    [self.uiCalls addObject:uiCall];
                } else {
                    callDescriptor = cd;
                }
            }
        }
    }
    
    [self reloadData];
    
    self.resetCallsBarButtonItem.enabled = self.allCalls.count > 0 && self.currentSpace.profile ? YES : NO;
    
    if (self.uiCalls.count == 0 && ![self.callsService isGetDescriptorsDone]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self getPreviousDescriptors];
        });
    }
}

- (BOOL)sameCall:(TLCallDescriptor *)callDescriptor1 callDescriptor2:(TLCallDescriptor *)callDescriptor2 {
    DDLogVerbose(@"%@ sameCall: %@ callDescriptor2: %@", LOG_TAG, callDescriptor1, callDescriptor2);
    
    return [callDescriptor2 isTwincodeOutbound:callDescriptor1.descriptorId.twincodeOutboundId] && callDescriptor2.isVideo == callDescriptor1.isVideo && [self isMissedCall:callDescriptor2] == [self isMissedCall:callDescriptor1];
}

- (BOOL)isMissedCall:(TLCallDescriptor *)callDescriptor {
    DDLogVerbose(@"%@ isMissedCall: %@", LOG_TAG, callDescriptor);
    
    return !callDescriptor.isAccepted && callDescriptor.isIncoming;
}

- (BOOL)showCall:(TLCallDescriptor *)callDescriptor {
    DDLogVerbose(@"%@ showCall: %@", LOG_TAG, callDescriptor);
    
    UIContact *uiContact = [self.uiContacts objectForKey:callDescriptor.descriptorId.twincodeOutboundId];
    if (!uiContact) {
        return NO;
    }
    
    if ((self.onlyMissedCalls && !callDescriptor.isAccepted && callDescriptor.isIncoming) || !self.onlyMissedCalls) {
        return YES;
    }
    
    return NO;
}

- (void)updateUICallReceiver:(TLCallReceiver *)callReceiver avatar:(UIImage *)avatar {
    DDLogVerbose(@"%@ updateUICallReceiver: %@ avatar: %@", LOG_TAG, callReceiver, avatar);
    
    UICallReceiver *uiCallReceiver = nil;
    for (UICallReceiver *lUICallRecevier in self.uiCallReceivers) {
        if ([lUICallRecevier.callReceiver.uuid isEqual:callReceiver.uuid]) {
            uiCallReceiver = lUICallRecevier;
            break;
        }
    }
    
    if (uiCallReceiver)  {
        [uiCallReceiver updateCallReceiver:callReceiver];
    } else {
        uiCallReceiver = [[UICallReceiver alloc] initWithCallReceiver:callReceiver ];
        [self.uiCallReceivers addObject:uiCallReceiver];
    }
        
    void (^setAvatar)(UIImage *) = ^(UIImage *image) {
        uiCallReceiver.avatar = image;
        UIContact *uiContact = [self.uiContacts objectForKey:callReceiver.uuid];
        if (uiContact) {
            uiContact.avatar = image;
        }
        [self refreshTable];
    };
    
    if (avatar) {
        setAvatar(avatar);
    } else {
        [self.callsService getImageWithCallReceiver:callReceiver withBlock:setAvatar];
    }
    
}

- (void)startAudioCallWithPermissionCheck {
    DDLogVerbose(@"%@ startAudioCallWithPermissionCheck", LOG_TAG);
    
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

- (void)startAudioCallViewController {
    DDLogVerbose(@"%@ startAudioCallViewController", LOG_TAG);
    
    CallViewController *callViewController = (CallViewController *)[[UIStoryboard storyboardWithName:@"Call" bundle:nil] instantiateViewControllerWithIdentifier:@"CallViewController"];
    [callViewController startCallWithOriginator:self.callOriginator videoBell:NO isVideoCall:NO isCertifyCall:NO];
    [self.navigationController pushViewController:callViewController animated:YES];
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
    
    CallViewController *callViewController = (CallViewController *)[[UIStoryboard storyboardWithName:@"Call" bundle:nil] instantiateViewControllerWithIdentifier:@"CallViewController"];
    [callViewController startCallWithOriginator:self.callOriginator videoBell:videoBell isVideoCall:YES isCertifyCall:NO];
    [self.navigationController pushViewController:callViewController animated:YES];
}

- (void)handleResetTapGesture:(UIButton *)sender {
    DDLogVerbose(@"%@ handleResetTapGesture: %@", LOG_TAG, sender);
    
    if (self.allCalls.count > 0) {
        [self.callsService getImageWithProfile:self.currentSpace.profile withBlock:^(UIImage *image) {
            DeleteConfirmView *deleteConfirmView = [[DeleteConfirmView alloc] init];
            deleteConfirmView.confirmViewDelegate = self;
            deleteConfirmView.deleteConfirmType = DeleteConfirmTypeHistory;
            NSString *message = [NSString stringWithFormat:@"%@\n\n%@", TwinmeLocalizedString(@"application_operation_irreversible", nil), TwinmeLocalizedString(@"history_view_controller_reset", nil)];
            [deleteConfirmView initWithTitle:TwinmeLocalizedString(@"delete_account_view_controller_warning", nil) message:message avatar:image icon:[UIImage imageNamed:@"ActionBarDelete"]];
            [deleteConfirmView setConfirmTitle:TwinmeLocalizedString(@"history_view_controller_reset_title", nil)];
            
            [self.tabBarController.view addSubview:deleteConfirmView];
            [deleteConfirmView showConfirmView];
        }];
    }
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    [self.segmentedControl setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: Design.FONT_REGULAR32, NSFontAttributeName, [UIColor whiteColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    [self.segmentedControl setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: Design.FONT_REGULAR32, NSFontAttributeName, Design.MAIN_COLOR, NSForegroundColorAttributeName, nil] forState:UIControlStateSelected];
    
    self.noCallTitleLabel.font = Design.FONT_MEDIUM34;
    self.noCallLabel.font = Design.FONT_MEDIUM28;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.noCallLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.view.backgroundColor = Design.WHITE_COLOR;
    self.noCallTitleLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.noCallLabel.textColor = Design.FONT_COLOR_DESCRIPTION;
    self.callsTableView.backgroundColor = Design.WHITE_COLOR;
        
    [self.segmentedControl setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: Design.FONT_REGULAR32, NSFontAttributeName, [UIColor whiteColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    [self.segmentedControl setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: Design.FONT_REGULAR32, NSFontAttributeName, Design.MAIN_COLOR, NSForegroundColorAttributeName, nil] forState:UIControlStateSelected];
}

- (void)deleteOriginator:(nonnull id<TLOriginator>)originator {
    DDLogVerbose(@"%@ deleteContact: %@", LOG_TAG, originator);
    
    if (originator.uuid) {
        [self.uiContacts removeObjectForKey:originator.uuid];
    }
    
    if (originator.twincodeOutboundId) {
        [self.uiContacts removeObjectForKey:originator.twincodeOutboundId];
    }
    
    if (originator.peerTwincodeOutboundId) {
        [self.uiContacts removeObjectForKey:originator.peerTwincodeOutboundId];
    }
    
    [self updateCalls];
}

- (void)callAgain {
    DDLogVerbose(@"%@ callAgain", LOG_TAG);
    
    ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
    if (self.callOriginator.isGroup && ![delegate.twinmeApplication isSubscribedWithFeature:TLTwinmeApplicationFeatureGroupCall]) {
        PremiumFeatureConfirmView *premiumFeatureConfirmView = [[PremiumFeatureConfirmView alloc] init];
        premiumFeatureConfirmView.confirmViewDelegate = self;
        [premiumFeatureConfirmView initWithPremiumFeature:[[UIPremiumFeature alloc]initWithFeatureType:FeatureTypeGroupCall spaceSettings:[self currentSpaceSettings]] parentViewController:self.tabBarController];
        [self.tabBarController.view addSubview:premiumFeatureConfirmView];
        [premiumFeatureConfirmView showConfirmView];
    } else if ((!self.callDescriptor.isVideo && self.callOriginator.capabilities.hasAudio) || (self.callDescriptor.isVideo && self.callOriginator.capabilities.hasVideo)) {
        
        if (self.callOriginator.isGroup) {
            [self.callsService getImageWithGroup:self.callOriginator withBlock:^(UIImage *image) {
                [self showCallAgainConfirmView:image];
            }];
        } else {
            [self.callsService getImageWithContact:self.callOriginator withBlock:^(UIImage *image) {
                [self showCallAgainConfirmView:image];
            }];
        }
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication].keyWindow makeToast:TwinmeLocalizedString(@"application_not_authorized_operation_by_your_contact",nil)];
        });
    }
}

- (void)showCallAgainConfirmView:(UIImage *)avatar {
    DDLogVerbose(@"%@ callAgain", LOG_TAG);
    
    CallAgainConfirmView *callAgainConfirmView = [[CallAgainConfirmView alloc] init];
    callAgainConfirmView.confirmViewDelegate = self;
    
    NSString *message = TwinmeLocalizedString(@"conversation_view_controller_audio_call", nil);
    UIImage *icon = [UIImage imageNamed:@"AudioCall"];
    if (self.callDescriptor.isVideo) {
        message = TwinmeLocalizedString(@"conversation_view_controller_video_call", nil);
        icon = [UIImage imageNamed:@"VideoCall"];
    }
    
    [callAgainConfirmView initWithTitle:self.callOriginator.name message:message avatar:avatar icon:icon];
    
    [self.tabBarController.view addSubview:callAgainConfirmView];
    [callAgainConfirmView showConfirmView];
}

- (void)reloadData {
    DDLogVerbose(@"%@ reloadData", LOG_TAG);

    if (self.displayAllCallReceiver || self.uiCallReceivers.count <= NB_CALL_RECEIVER) {
            self.nbCallReceivers = (int) self.uiCallReceivers.count;
        } else {
            self.nbCallReceivers = NB_CALL_RECEIVER;
        }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.callsTableView reloadData];
        
        if (self.filteredCalls.count == 0 && self.uiCallReceivers.count == 0) {
            self.noCallImageView.hidden = NO;
            self.noCallTitleLabel.hidden = NO;
            self.noCallLabel.hidden = NO;
            self.view.backgroundColor = Design.WHITE_COLOR;
            if (!self.currentSpace.profile) {
                self.noCallImageViewTopConstraint.constant = (DESIGN_NO_CALL_MARGIN_TOP * Design.HEIGHT_RATIO);
            } else {
                self.noCallImageViewTopConstraint.constant = (DESIGN_NO_CALL_MARGIN_TOP * Design.HEIGHT_RATIO) + Design.SETTING_SECTION_HEIGHT;
            }
        } else if (!self.currentSpace.profile) {
            self.noCallImageViewTopConstraint.constant = (DESIGN_NO_CALL_MARGIN_TOP * Design.HEIGHT_RATIO);
            self.noCallImageView.hidden = NO;
            self.noCallTitleLabel.hidden = NO;
            self.noCallLabel.hidden = NO;
            self.view.backgroundColor = Design.WHITE_COLOR;
        } else {
            self.noCallImageView.hidden = YES;
            self.noCallTitleLabel.hidden = YES;
            self.noCallLabel.hidden = YES;
            self.view.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
        }
    });
}

- (void)updateCurrentSpace {
    DDLogVerbose(@"%@ updateCurrentSpace", LOG_TAG);
    
    [self setLeftBarButtonItem:self.callsService profile:self.currentSpace.profile];
    
    [self updateColor];
}

- (void)refreshTable {
    DDLogVerbose(@"%@ refreshTable", LOG_TAG);

    // Schedule only one table reload for possibly several asynchronous fetch of images.
    if (!self.refreshTableScheduled) {
        self.refreshTableScheduled = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.refreshTableScheduled = NO;
            [self.callsTableView reloadData];
        });
    }
}

@end

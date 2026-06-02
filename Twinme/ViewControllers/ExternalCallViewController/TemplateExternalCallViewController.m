/*
 *  Copyright (c) 2023-2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinme/TLProfile.h>
#import <Twinme/TLSpace.h>

#import <Utils/NSString+Utils.h>

#import "TemplateExternalCallViewController.h"

#import "CreateExternalCallViewController.h"

#import "TemplateExternalCallCell.h"
#import "SettingsSectionHeaderCell.h"

#import "UITemplateExternalCall.h"

#import <TwinmeCommon/AbstractTwinmeService.h>
#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/MainViewController.h>
#import <TwinmeCommon/TwinmeNavigationController.h>


#import "OnboardingConfirmView.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static NSString *HEADER_SETTINGS_CELL_IDENTIFIER = @"HeaderSettingsCellIdentifier";
static NSString *TEMPLATE_EXTERNAL_CALL_CELL_IDENTIFIER = @"TemplateExternalCallCellIdentifier";


typedef enum {
    SECTION_CONFERENCE,
    SECTION_DIRECT,
    SECTION_DEFAULT,
    SECTION_COUNT
} TemplateExternalCallSection;

//
// Interface: TemplateExternalCallViewController ()
//

@interface TemplateExternalCallViewController () <UITableViewDataSource, UITableViewDelegate, SettingsSectionHeaderDelegate, BottomSheetViewDelegate, AbstractTwinmeDelegate>

@property (weak, nonatomic) IBOutlet UITableView *templatesTableView;

@property (nonatomic) NSMutableArray *uiTemplateConference;
@property (nonatomic) NSMutableArray *uiTemplateDirect;
@property (nonatomic) NSMutableArray *uiTemplateDefault;

@property (nonatomic, nullable) AbstractTwinmeService *twinmeService;

@end

//
// Implementation: TemplateExternalCallViewController
//

#undef LOG_TAG
#define LOG_TAG @"TemplateExternalCallViewController"

@implementation TemplateExternalCallViewController

#pragma mark - UIViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _uiTemplateConference = [[NSMutableArray alloc] init];
        _uiTemplateDirect = [[NSMutableArray alloc] init];
        _uiTemplateDefault = [[NSMutableArray alloc] init];
        _twinmeService = [[AbstractTwinmeService alloc] initWithTwinmeContext:self.twinmeContext tag:LOG_TAG delegate:self];
    }
    return self;
}

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
    
    [self initTemplates];
    [self initViews];
}

- (BOOL)hidesBottomBarWhenPushed {
    DDLogVerbose(@"%@ hidesBottomBarWhenPushed", LOG_TAG);
    
    return YES;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    DDLogVerbose(@"%@ numberOfSectionsInTableView: %@", LOG_TAG, tableView);
    
    return SECTION_COUNT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ numberOfRowsInSection: %ld", LOG_TAG, tableView, (long)section);
    
    if (section == SECTION_CONFERENCE) {
        return self.uiTemplateConference.count;
    } else if (section == SECTION_DIRECT) {
        return self.uiTemplateDirect.count;
    }
    return self.uiTemplateDefault.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ viewForHeaderInSection: %ld", LOG_TAG, tableView, (long)section);
    
    SettingsSectionHeaderCell *settingsSectionHeaderCell = (SettingsSectionHeaderCell *)[tableView dequeueReusableCellWithIdentifier:HEADER_SETTINGS_CELL_IDENTIFIER];
    if (!settingsSectionHeaderCell) {
        settingsSectionHeaderCell = [[SettingsSectionHeaderCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:HEADER_SETTINGS_CELL_IDENTIFIER];
    }
    
    NSString *sectionName = @"";
    NSString *badgeTitle = nil;

    switch (section) {
        case SECTION_CONFERENCE:
            sectionName = TwinmeLocalizedString(@"create_external_call_view_conference_call_title", nil);
            badgeTitle = TwinmeLocalizedString(@"application_new", nil);
            settingsSectionHeaderCell.delegate = self;
            break;
            
        case SECTION_DIRECT:
            sectionName = TwinmeLocalizedString(@"create_external_call_view_direct_call_title", nil);
            break;
            
        case SECTION_DEFAULT:
            sectionName = TwinmeLocalizedString(@"application_default", nil).uppercaseString;
            break;
            
        default:
            sectionName = @"";
            break;
    }
    
    [settingsSectionHeaderCell bindWithTitle:sectionName backgroundColor:Design.LIGHT_GREY_BACKGROUND_COLOR hideSeparator:YES uppercaseString:YES  badgeTitle:badgeTitle];
    
    return settingsSectionHeaderCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ heightForHeaderInSection: %ld", LOG_TAG, tableView, (long)section);
    
    return Design.SETTING_SECTION_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ heightForFooterInSection: %ld", LOG_TAG, tableView, (long)section);
    
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
    
    return UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ cellForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    TemplateExternalCallCell *templateExternalCallCell = (TemplateExternalCallCell *)[tableView dequeueReusableCellWithIdentifier:TEMPLATE_EXTERNAL_CALL_CELL_IDENTIFIER];
    if (!templateExternalCallCell) {
        templateExternalCallCell = [[TemplateExternalCallCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:TEMPLATE_EXTERNAL_CALL_CELL_IDENTIFIER];
    }
    
    UITemplateExternalCall *uiTemplateExternalCall;
    BOOL hideSeparator = NO;
    if (indexPath.section == SECTION_CONFERENCE) {
        uiTemplateExternalCall = [self.uiTemplateConference objectAtIndex:indexPath.row];
        hideSeparator = indexPath.row + 1 == self.uiTemplateConference.count ? YES : NO;
    } else if (indexPath.section == SECTION_DIRECT) {
        uiTemplateExternalCall = [self.uiTemplateDirect objectAtIndex:indexPath.row];
        hideSeparator = indexPath.row + 1 == self.uiTemplateDirect.count ? YES : NO;
    } else {
        uiTemplateExternalCall = [self.uiTemplateDefault objectAtIndex:indexPath.row];
        hideSeparator = indexPath.row + 1 == self.uiTemplateDefault.count ? YES : NO;
    }
    
    [templateExternalCallCell bindWithTemplate:uiTemplateExternalCall hideSeparator:hideSeparator];
    
    return templateExternalCallCell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ didSelectRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    UITemplateExternalCall *uiTemplateExternalCall;
    
    if (indexPath.section == SECTION_CONFERENCE) {
        uiTemplateExternalCall = [self.uiTemplateConference objectAtIndex:indexPath.row];
    } else if (indexPath.section == SECTION_DIRECT) {
        uiTemplateExternalCall = [self.uiTemplateDirect objectAtIndex:indexPath.row];
    } else {
        uiTemplateExternalCall = [self.uiTemplateDefault objectAtIndex:indexPath.row];
    }
    
    CreateExternalCallViewController *createExternalCallViewController = (CreateExternalCallViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"CreateExternalCallViewController"];
    [createExternalCallViewController initWithTemplate:uiTemplateExternalCall];
    [self.navigationController pushViewController:createExternalCallViewController animated:YES];
}

#pragma mark - SettingsSectionHeaderDelegate

- (void)didTapSectionBadge {
    DDLogVerbose(@"%@ didTapSectionBadge", LOG_TAG);
    
    [self showOnboarding];
}

#pragma mark - BottomSheetViewDelegate

- (void)didTapConfirm:(nonnull AbstractBottomSheetView *)abstractBottomSheetView {
    DDLogVerbose(@"%@ didTapConfirm: %@", LOG_TAG, abstractBottomSheetView);
    
    [abstractBottomSheetView closeConfirmView];
}

- (void)didTapCancel:(nonnull AbstractBottomSheetView *)abstractBottomSheetView {
    DDLogVerbose(@"%@ didTapCancel: %@", LOG_TAG, abstractBottomSheetView);
    
    [abstractBottomSheetView closeConfirmView];
}

- (void)didClose:(nonnull AbstractBottomSheetView *)abstractBottomSheetView {
    DDLogVerbose(@"%@ didClose: %@", LOG_TAG, abstractBottomSheetView);
    
    [abstractBottomSheetView closeConfirmView];
}

- (void)didFinishCloseAnimation:(nonnull AbstractBottomSheetView *)abstractBottomSheetView {
    DDLogVerbose(@"%@ didFinishCloseAnimation: %@", LOG_TAG, abstractBottomSheetView);
    
    [abstractBottomSheetView removeFromSuperview];
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.definesPresentationContext = YES;
    self.view.backgroundColor = Design.WHITE_COLOR;
    
    [self setNavigationTitle:TwinmeLocalizedString(@"template_space_view_template_title", nil).capitalizedString];
    
    self.templatesTableView.delegate = self;
    self.templatesTableView.dataSource = self;
    self.templatesTableView.backgroundColor = Design.WHITE_COLOR;
    self.templatesTableView.rowHeight = UITableViewAutomaticDimension;
    self.templatesTableView.estimatedRowHeight =  Design.CELL_HEIGHT;
    self.templatesTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.templatesTableView registerNib:[UINib nibWithNibName:@"TemplateExternalCallCell" bundle:nil] forCellReuseIdentifier:TEMPLATE_EXTERNAL_CALL_CELL_IDENTIFIER];
    [self.templatesTableView registerNib:[UINib nibWithNibName:@"SettingsSectionHeaderCell" bundle:nil] forCellReuseIdentifier:HEADER_SETTINGS_CELL_IDENTIFIER];
}

- (void)initTemplates {
    DDLogVerbose(@"%@ initTemplates", LOG_TAG);
    
    [self.uiTemplateConference addObject:[[UITemplateExternalCall alloc]initWithTemplateType:TemplateExternalCallTypeMeeting]];
    
    [self.uiTemplateDirect addObject:[[UITemplateExternalCall alloc]initWithTemplateType:TemplateExternalCallTypeClassifiedAd]];
    [self.uiTemplateDirect addObject:[[UITemplateExternalCall alloc]initWithTemplateType:TemplateExternalCallTypeHelp]];
    [self.uiTemplateDirect addObject:[[UITemplateExternalCall alloc]initWithTemplateType:TemplateExternalCallTypeVideoBell]];
    [self.uiTemplateDirect addObject:[[UITemplateExternalCall alloc]initWithTemplateType:TemplateExternalCallTypeJob]];
    
    UITemplateExternalCall *profileTemplate = [[UITemplateExternalCall alloc]initWithTemplateType:TemplateExternalCallTypeProfile];
    [self.uiTemplateDirect addObject:profileTemplate];
    
    [self.twinmeService getImageWithProfile:self.currentSpace.profile withBlock:^(UIImage *image) {
        [profileTemplate updateName:self.defaultProfile.name image:image];
        [self.templatesTableView reloadData];
    }];
   
    [self.uiTemplateDefault addObject:[[UITemplateExternalCall alloc]initWithTemplateType:TemplateExternalCallTypeOther]];
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    [super finish];
    
    if (self.twinmeService) {
        [self.twinmeService dispose];
        self.twinmeService = nil;
    }
}

- (void)showOnboarding {
    DDLogVerbose(@"%@ showOnboarding", LOG_TAG);
    
    OnboardingConfirmView *onboardingConfirmView = [[OnboardingConfirmView alloc] init];
    onboardingConfirmView.bottomSheetViewDelegate = self;
    [onboardingConfirmView initWithTitle:TwinmeLocalizedString(@"create_external_call_view_conference_call_title", nil) message: TwinmeLocalizedString(@"create_external_call_view_onboarding_part_1_message_1", nil) image:[UIImage imageNamed:@"OnboardingClickToCall"] action:TwinmeLocalizedString(@"application_ok", nil) actionColor:nil cancel:nil];
    [onboardingConfirmView hideCancelAction];
    
    [self.navigationController.view addSubview:onboardingConfirmView];
    [onboardingConfirmView showConfirmView];
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.view.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    self.templatesTableView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;

    [self.templatesTableView reloadData];
}

@end

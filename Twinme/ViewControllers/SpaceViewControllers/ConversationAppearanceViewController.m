/*
 *  Copyright (c) 2020-2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinme/TLSpace.h>
#import <Twinme/UIImage+Resize.h>

#import "ConversationAppearanceViewController.h"
#import "EditSpaceViewController.h"

#import <TwinmeCommon/SpaceAppearanceService.h>

#import "SettingsSectionHeaderCell.h"
#import "AppearanceColorCell.h"
#import "PreviewAppearanceCell.h"
#import "SubSectionCell.h"
#import "ResetSettingsCell.h"
#import "MenuSelectColorView.h"
#import "SettingsInformationCell.h"

#import "DeviceAuthorization.h"
#import "CustomAppearance.h"
#import "MenuPhotoView.h"

#import <Utils/NSString+Utils.h>
#import "UIColor+Hex.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static const int APPEARANCE_SECTION_COUNT = 2;

static const int INFO_SECTION = 0;
static const int CONVERSATIONS_SECTION = 1;

static const int PREVIEW_APPEARANCE_TITLE_ROW = 0;
static const int PREVIEW_APPEARANCE_ROW = 1;
static const int BACKGROUND_APPEARANCE_TITLE_ROW = 2;
static const int BACKGROUND_APPEARANCE_INFO_ROW = 3;
static const int BACKGROUND_COLOR_ROW = 4;
static const int BACKGROUND_TEXT_ROW = 5;
static const int ITEM_APPEARANCE_TITLE_ROW = 6;
static const int ITEM_BACKGROUND_COLOR_ROW = 7;
static const int PEER_ITEM_BACKGROUND_COLOR_ROW = 8;
static const int ITEM_BORDER_COLOR_ROW = 9;
static const int PEER_ITEM_BORDER_COLOR_ROW = 10;
static const int ITEM_TEXT_COLOR_ROW = 11;
static const int PEER_ITEM_TEXT_COLOR_ROW = 12;

static NSString *SUB_SECTION_CELL_IDENTIFIER = @"SubSectionCellIdentifier";
static NSString *PREVIEW_APPEARANCE_CELL_IDENTIFIER = @"PreviewAppearanceCellIdentifier";
static NSString *APPEARANCE_COLOR_CELL_IDENTIFIER = @"AppearanceColorCellIdentifier";
static NSString *HEADER_SETTINGS_CELL_IDENTIFIER = @"HeaderSettingsCellIdentifier";
static NSString *RESET_SETTINGS_CELL_IDENTIFIER = @"ResetSettingsCellIdentifier";
static NSString *SETTINGS_INFORMATION_CELL_IDENTIFIER = @"SettingsInformationCellIdentifier";

static CGFloat DESIGN_SUBSECTION_HEIGHT = 120;
static CGFloat DESIGN_RESET_HEIGHT = 160;

//
// Interface: ConversationAppearanceViewController  ()
//

@interface ConversationAppearanceViewController ()<MenuSelectColorDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, SpaceAppearanceServiceDelegate, MenuPhotoViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) MenuSelectColorView *menuSelectColorView;

@property (nonatomic) NSIndexPath *selectedIndexPath;

@property (nonatomic) TLSpace *space;
@property (nonatomic) SpaceAppearanceService *spaceAppearanceService;

@property (nonatomic) CustomAppearance *customAppearance;
@property (nonatomic) DisplayMode displayMode;

@property (nonatomic) UIImage *conversationBackgroundLightImage;
@property (nonatomic) UIImage *conversationBackgroundDarkImage;

@property (nonatomic) UIBarButtonItem *saveBarButtonItem;
@property (nonatomic) BOOL canSave;
@property (nonatomic) BOOL updateDefaultSettings;
@property (nonatomic) BOOL updatedLightImage;
@property (nonatomic) BOOL updatedDarkImage;
@property (nonatomic) BOOL updatedConversationBackgroundLightColor;
@property (nonatomic) BOOL updatedConversationBackgroundDarkColor;

@property (nonatomic) NSUUID *lightImageId;
@property (nonatomic) NSUUID *darkImageId;

@property (nonatomic) BOOL keyboardHidden;

@end

//
// Implementation: ConversationAppearanceViewController
//

#undef LOG_TAG
#define LOG_TAG @"ConversationAppearanceViewController "

@implementation ConversationAppearanceViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _updateDefaultSettings = NO;
        _displayMode = self.twinmeApplication.displayMode;
        _updatedLightImage = NO;
        _updatedDarkImage = NO;
        _updatedConversationBackgroundLightColor = NO;
        _updatedConversationBackgroundDarkColor = NO;
        _keyboardHidden = YES;
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillDisappear: %@", LOG_TAG, animated ? @"YES" : @"NO");
    
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    DDLogVerbose(@"%@ keyboardWillShow: %@", LOG_TAG, notification);
    
    if (!self.keyboardHidden) {
        return;
    }
    
    self.keyboardHidden = NO;
    NSDictionary *info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    if ([self.twinmeApplication getDefaultKeyboardHeight] != keyboardSize.height) {
        [self.twinmeApplication setDefaultKeyboardHeight:keyboardSize.height];
    }
    
    if (self.menuSelectColorView) {
        [self.menuSelectColorView updateKeyboard:keyboardSize.height];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    DDLogVerbose(@"%@ keyboardWillHide: %@", LOG_TAG, notification);
    
    self.keyboardHidden = YES;
    
    if (self.menuSelectColorView) {
        [self.menuSelectColorView updateKeyboard:0];
    }
}

- (void)initWithSpace:(TLSpace *)space {
    DDLogVerbose(@"%@ initWithSpace: %@", LOG_TAG, space);
    
    self.space = space;
    self.customAppearance = [[CustomAppearance alloc]initWithSpaceSettings:self.space.settings];
    self.displayMode = [self.customAppearance getCurrentMode];
    
    self.spaceAppearanceService = [[SpaceAppearanceService alloc]initWithTwinmeContext:self.twinmeContext delegate:self space:self.space];
    
    self.lightImageId = [self.customAppearance getConversationBackgroundImageId:DisplayModeLight];
    self.darkImageId = [self.customAppearance getConversationBackgroundImageId:DisplayModeDark];
    
    if (self.lightImageId) {
        [self.spaceAppearanceService getConversationImage:self.lightImageId defaultImage:[self.customAppearance createImageWithColor:Design.WHITE_COLOR] withBlock:^(UIImage *image) {
            self.conversationBackgroundLightImage = image;
            [self.tableView reloadData];
        }];
    }
    
    if (self.darkImageId) {
        [self.spaceAppearanceService getConversationImage:self.darkImageId defaultImage:[self.customAppearance createImageWithColor:Design.BLACK_COLOR] withBlock:^(UIImage *image) {
            self.conversationBackgroundDarkImage = image;
            [self.tableView reloadData];
        }];
    }
}

- (void)initWithCustomAppearance:(CustomAppearance *)customAppearance conversationBackgroundLightImage:(UIImage *)conversationBackgroundLightImage conversationBackgroundDarkImage:(UIImage *)conversationBackgroundDarkImage {
    DDLogVerbose(@"%@ initWithCustomAppearance: %@", LOG_TAG, customAppearance);
    
    self.customAppearance = customAppearance;
    [self.customAppearance setCurrentMode:self.twinmeApplication.displayMode];
    self.displayMode = [self.customAppearance getCurrentMode];
    self.conversationBackgroundLightImage = conversationBackgroundLightImage;
    self.conversationBackgroundDarkImage = conversationBackgroundDarkImage;
}

- (void)initWithDefaultSpaceSettings {
    DDLogVerbose(@"%@ initWithDefaultSpaceSettings", LOG_TAG);
    
    self.updateDefaultSettings = YES;
    self.customAppearance = [[CustomAppearance alloc]initWithSpaceSettings:self.twinmeContext.defaultSpaceSettings];
    self.displayMode = [self.customAppearance getCurrentMode];
    
    self.spaceAppearanceService = [[SpaceAppearanceService alloc]initWithTwinmeContext:self.twinmeContext delegate:self space:nil];
    self.lightImageId = [self.customAppearance getConversationBackgroundImageId:DisplayModeLight];
    self.darkImageId = [self.customAppearance getConversationBackgroundImageId:DisplayModeDark];
    
    if (self.lightImageId) {
        [self.spaceAppearanceService getConversationImage:self.lightImageId defaultImage:[self.customAppearance createImageWithColor:Design.WHITE_COLOR] withBlock:^(UIImage *image) {
            self.conversationBackgroundLightImage = image;
            [self.tableView reloadData];
        }];
    }
    
    if (self.darkImageId) {
        [self.spaceAppearanceService getConversationImage:self.darkImageId defaultImage:[self.customAppearance createImageWithColor:Design.BLACK_COLOR] withBlock:^(UIImage *image) {
            self.conversationBackgroundDarkImage = image;
            [self.tableView reloadData];
        }];
    }
}

#pragma mark - SpaceAppearanceServiceDelegate

- (void)onUpdateSpace:(nonnull TLSpace *)space {
    DDLogVerbose(@"%@ onUpdateSpace: %@", LOG_TAG, space);
    
    [self finish];
}

- (void)onUpdateSpaceDefaultSettings:(TLSpaceSettings *)spaceSettings {
    DDLogVerbose(@"%@ onUpdateSpaceDefaultSettings: %@", LOG_TAG, spaceSettings);
    
    [self finish];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)pickerController didFinishPickingMediaWithInfo:(NSDictionary *)info {
    DDLogVerbose(@"%@ imagePickerController: %@ didFinishPickingMediaWithInfo: %@", LOG_TAG, pickerController, info);
    
    [pickerController dismissViewControllerAnimated:YES completion:^{
        self.canSave = YES;
        self.saveBarButtonItem.enabled = YES;
        
        if (self.displayMode == DisplayModeLight) {
            self.updatedLightImage = YES;
            self.updatedConversationBackgroundLightColor = NO;
            self.conversationBackgroundLightImage = info[UIImagePickerControllerOriginalImage];
        } else {
            self.updatedDarkImage = YES;
            self.updatedConversationBackgroundDarkColor = NO;
            self.conversationBackgroundDarkImage = info[UIImagePickerControllerOriginalImage];
        }
        
        [self.tableView reloadData];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)pickerController {
    DDLogVerbose(@"%@ imagePickerControllerDidCancel: %@", LOG_TAG, pickerController);
    
    [pickerController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    DDLogVerbose(@"%@ numberOfSectionsInTableView: %@", LOG_TAG, tableView);
    
    return APPEARANCE_SECTION_COUNT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
    DDLogVerbose(@"%@ tableView: %@ heightForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if (indexPath.section == INFO_SECTION) {
        return  UITableViewAutomaticDimension;
    } else if (indexPath.section == CONVERSATIONS_SECTION) {
        if (indexPath.row == PREVIEW_APPEARANCE_TITLE_ROW || indexPath.row == BACKGROUND_APPEARANCE_TITLE_ROW || indexPath.row == ITEM_APPEARANCE_TITLE_ROW) {
            return round(DESIGN_SUBSECTION_HEIGHT * Design.HEIGHT_RATIO);
        } else if (indexPath.row == PREVIEW_APPEARANCE_ROW || indexPath.row == BACKGROUND_APPEARANCE_INFO_ROW) {
            return  UITableViewAutomaticDimension;
        }
    }
    
    return Design.SETTING_CELL_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ heightForHeaderInSection: %ld", LOG_TAG, tableView, (long)section);
    
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ heightForFooterInSection: %ld", LOG_TAG, tableView, (long)section);
    
    if (section == CONVERSATIONS_SECTION) {
        return DESIGN_RESET_HEIGHT * Design.HEIGHT_RATIO;
    }
    return CGFLOAT_MIN;;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ viewForFooterInSection: %ld", LOG_TAG, tableView, (long)section);
    
    if (section == CONVERSATIONS_SECTION) {
        ResetSettingsCell *resetAppearanceCell = (ResetSettingsCell *)[tableView dequeueReusableCellWithIdentifier:RESET_SETTINGS_CELL_IDENTIFIER];
        if (!resetAppearanceCell) {
            resetAppearanceCell = [[ResetSettingsCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:RESET_SETTINGS_CELL_IDENTIFIER];
        }
        
        UITapGestureRecognizer *resetViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleResetTapGesture:)];
        [resetAppearanceCell.contentView addGestureRecognizer:resetViewGestureRecognizer];
        
        return resetAppearanceCell;
    }
    
    return [[UIView alloc]init];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ numberOfRowsInSection: %ld", LOG_TAG, tableView, (long)section);
    
    NSInteger numberOfRowsInSection;
    switch (section) {
        case INFO_SECTION:
            numberOfRowsInSection = 1;
            break;
            
        case CONVERSATIONS_SECTION:
            numberOfRowsInSection = PEER_ITEM_TEXT_COLOR_ROW + 1;
            break;
            
        default:
            numberOfRowsInSection = 0;
            break;
    }
    return numberOfRowsInSection;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ cellForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if (indexPath.section == INFO_SECTION) {
        SettingsInformationCell *cell = [tableView dequeueReusableCellWithIdentifier:SETTINGS_INFORMATION_CELL_IDENTIFIER];
        if (!cell) {
            cell = [[SettingsInformationCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SETTINGS_INFORMATION_CELL_IDENTIFIER];
        }
        
        NSString *text = TwinmeLocalizedString(@"settings_view_controller_default_value_message", nil);
        if (self.space) {
            text = TwinmeLocalizedString(@"settings_space_view_controller_default_value_message", nil);
        }
        [cell bindWithText:text];
        
        return cell;
    } else if (indexPath.section == CONVERSATIONS_SECTION) {
        
        if (indexPath.row == PREVIEW_APPEARANCE_TITLE_ROW || indexPath.row == BACKGROUND_APPEARANCE_TITLE_ROW || indexPath.row == ITEM_APPEARANCE_TITLE_ROW) {
            SubSectionCell *cell = [tableView dequeueReusableCellWithIdentifier:SUB_SECTION_CELL_IDENTIFIER];
            if (!cell) {
                cell = [[SubSectionCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:APPEARANCE_COLOR_CELL_IDENTIFIER];
            }
            
            BOOL hideSeparator = indexPath.row == BACKGROUND_APPEARANCE_TITLE_ROW;            
            [cell bindWithTitle:[self getTitle:indexPath.row].uppercaseString hideSeparator:hideSeparator];
            
            return cell;
        } else if (indexPath.row == PREVIEW_APPEARANCE_ROW) {
            PreviewAppearanceCell *cell = [tableView dequeueReusableCellWithIdentifier:PREVIEW_APPEARANCE_CELL_IDENTIFIER];
            if (!cell) {
                cell = [[PreviewAppearanceCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:PREVIEW_APPEARANCE_CELL_IDENTIFIER];
            }
            
            if (self.displayMode == DisplayModeLight) {
                [cell bindWithAppearance:self.customAppearance conversationBackgroundImage:self.conversationBackgroundLightImage];
            } else {
                [cell bindWithAppearance:self.customAppearance conversationBackgroundImage:self.conversationBackgroundDarkImage];
            }
            
            return cell;
        } else if (indexPath.row == BACKGROUND_APPEARANCE_INFO_ROW) {
            SettingsInformationCell *cell = [tableView dequeueReusableCellWithIdentifier:SETTINGS_INFORMATION_CELL_IDENTIFIER];
            if (!cell) {
                cell = [[SettingsInformationCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SETTINGS_INFORMATION_CELL_IDENTIFIER];
            }
            
            [cell bindWithText:TwinmeLocalizedString(@"space_appearance_view_controller_background_message", nil)];
            
            return cell;
        } else {
            AppearanceColorCell *cell = [tableView dequeueReusableCellWithIdentifier:APPEARANCE_COLOR_CELL_IDENTIFIER];
            if (!cell) {
                cell = [[AppearanceColorCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:APPEARANCE_COLOR_CELL_IDENTIFIER];
            }
            
            if (indexPath.row == BACKGROUND_COLOR_ROW) {
                if (self.displayMode == DisplayModeLight && self.conversationBackgroundLightImage) {
                    [cell bindWithColor:nil nameColor:[self getTitle:indexPath.row] image:self.conversationBackgroundLightImage];
                } else if (self.displayMode == DisplayModeDark && self.conversationBackgroundDarkImage) {
                    [cell bindWithColor:nil nameColor:[self getTitle:indexPath.row] image:self.conversationBackgroundDarkImage];
                } else {
                    [cell bindWithColor:[self getColor:indexPath.row] nameColor:[self getTitle:indexPath.row] image:nil];
                }
            } else {
                [cell bindWithColor:[self getColor:indexPath.row] nameColor:[self getTitle:indexPath.row] image:nil];
            }
            
            return cell;
        }
    }
    
    return [[UITableViewCell alloc]init];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ didSelectRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if ([self isSelectableRow:indexPath]) {
        self.selectedIndexPath = indexPath;
        
        if (indexPath.row == BACKGROUND_COLOR_ROW) {
            [self openMenuPhoto];
        } else if (indexPath.row != PREVIEW_APPEARANCE_TITLE_ROW || indexPath.row != BACKGROUND_APPEARANCE_TITLE_ROW || indexPath.row != ITEM_APPEARANCE_TITLE_ROW || indexPath.row != PREVIEW_APPEARANCE_ROW) {
            [self openMenuColor:[self getColor:indexPath.row] title:[self getTitle:indexPath.row] defaultColor:[self getDefaultColor:indexPath.row]];
        }
    }
}

#pragma mark - MenuSelectColorDelegate

- (void)cancelMenuSelectColor:(MenuSelectColorView *)menuSelectColorView {
    DDLogVerbose(@"%@ cancelMenuSelectColor", LOG_TAG);
    
    [menuSelectColorView removeFromSuperview];
    self.menuSelectColorView = nil;
}

- (void)selectColor:(MenuSelectColorView *)menuSelectColorView color:(NSString *)color {
    DDLogVerbose(@"%@ selectColor", LOG_TAG);
    
    [menuSelectColorView removeFromSuperview];
    self.menuSelectColorView = nil;
    
    self.canSave = YES;
    self.saveBarButtonItem.enabled = YES;
    [self updateAppearance:[UIColor colorWithHexString:color alpha:1.0]];
}

- (void)resetColor:(MenuSelectColorView *)menuSelectColorView {
    DDLogVerbose(@"%@ resetColor", LOG_TAG);
    
    [menuSelectColorView removeFromSuperview];
    self.menuSelectColorView = nil;
    
    self.canSave = YES;
    self.saveBarButtonItem.enabled = YES;
    [self updateAppearance:nil];
}

#pragma mark - MenuPhotoViewDelegate

- (void)menuPhotoDidSelectCamera:(MenuPhotoView *)menuPhotoView {
    DDLogVerbose(@"%@ menuPhotoDidSelectCamera", LOG_TAG);
    
    [menuPhotoView removeFromSuperview];
    [self takePhoto];
}

- (void)menuPhotoDidSelectGallery:(MenuPhotoView *)menuPhotoView {
    DDLogVerbose(@"%@ menuPhotoDidSelectGallery", LOG_TAG);
    
    [menuPhotoView removeFromSuperview];
    [self selectPhoto];
}

- (void)menuPhotoDidSelectColor:(MenuPhotoView *)menuPhotoView {
    DDLogVerbose(@"%@ menuPhotoDidSelectGallery", LOG_TAG);
    
    [menuPhotoView removeFromSuperview];
    [self openMenuColor:[self getColor:BACKGROUND_COLOR_ROW] title:[self getTitle:BACKGROUND_COLOR_ROW] defaultColor:[self getDefaultColor:BACKGROUND_COLOR_ROW]];
}

- (void)cancelMenuPhoto:(MenuPhotoView *)menuPhotoView {
    DDLogVerbose(@"%@ menuPhotoDidSelectCamera", LOG_TAG);
 
    [menuPhotoView removeFromSuperview];
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.view.backgroundColor = Design.WHITE_COLOR;
    
    [self setNavigationTitle:TwinmeLocalizedString(@"application_appearance", nil)];
    
    self.saveBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:TwinmeLocalizedString(@"application_save", nil) style:UIBarButtonItemStylePlain target:self action:@selector(handleSaveTapGesture:)];
    [self.saveBarButtonItem setTitleTextAttributes: @{NSFontAttributeName : Design.FONT_BOLD36, NSForegroundColorAttributeName: [UIColor whiteColor]} forState:UIControlStateNormal];
    [self.saveBarButtonItem setTitleTextAttributes: @{NSFontAttributeName : Design.FONT_BOLD36, NSForegroundColorAttributeName: [UIColor colorWithWhite:1.0 alpha:0.5]} forState:UIControlStateDisabled];
    self.saveBarButtonItem.enabled = NO;
    self.navigationItem.rightBarButtonItem = self.saveBarButtonItem;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.estimatedRowHeight = Design.SETTING_CELL_HEIGHT;
    [self.tableView registerNib:[UINib nibWithNibName:@"SubSectionCell" bundle:nil] forCellReuseIdentifier:SUB_SECTION_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"PreviewAppearanceCell" bundle:nil] forCellReuseIdentifier:PREVIEW_APPEARANCE_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"AppearanceColorCell" bundle:nil] forCellReuseIdentifier:APPEARANCE_COLOR_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsSectionHeaderCell" bundle:nil] forCellReuseIdentifier:HEADER_SETTINGS_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"ResetSettingsCell" bundle:nil] forCellReuseIdentifier:RESET_SETTINGS_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsInformationCell" bundle:nil] forCellReuseIdentifier:SETTINGS_INFORMATION_CELL_IDENTIFIER];
    self.tableView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
}

- (void)handleResetTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleResetTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self hapticFeedBack:UIImpactFeedbackStyleMedium];
        
        self.conversationBackgroundLightImage = nil;
        self.conversationBackgroundDarkImage = nil;
        self.updatedConversationBackgroundLightColor = YES;
        self.updatedConversationBackgroundDarkColor = YES;
        
        self.canSave = YES;
        self.saveBarButtonItem.enabled = YES;
        
        [self.customAppearance resetToDefaultValues];
        [self.tableView reloadData];
    }
}

- (void)handleSaveTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleSaveTapGesture: %@", LOG_TAG, sender);
    
    if (!self.canSave) {
        return;
    }
    
    if (self.space || self.updateDefaultSettings) {
        UIImage *updateLightImage = nil;
        UIImage *updateLightLargeImage = nil;
        UIImage *updateDarkImage = nil;
        UIImage *updateDarkLargeImage = nil;
        
        if (self.updatedLightImage) {
            updateLightLargeImage = self.conversationBackgroundLightImage;
            updateLightImage = [self.conversationBackgroundLightImage resizeImage];
        }
        
        if (self.updatedDarkImage) {
            updateDarkLargeImage = self.conversationBackgroundDarkImage;
            updateDarkImage = [self.conversationBackgroundDarkImage resizeImage];
        }
        
        [self.spaceAppearanceService updateSpace:[self.customAppearance getSpaceSettings] conversationBackgroundLightImage:updateLightImage conversationBackgroundLightLargeImage:updateLightLargeImage conversationBackgroundDarkImage:updateDarkImage conversationBackgroundDarkLargeImage:updateDarkLargeImage updateConversationBackgroundLightColor:self.updatedConversationBackgroundLightColor updateConversationBackgroundDarkColor:self.updatedConversationBackgroundDarkColor];
    } else {
        [self.spaceAppearanceDelegate saveAppearance:self customAppearance:self.customAppearance conversationBackgroundLightImage:self.conversationBackgroundLightImage conversationBackgroundDarkImage:self.conversationBackgroundDarkImage];
        [self finish];
    }
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    if (self.spaceAppearanceService) {
        [self.spaceAppearanceService dispose];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSString *)getTitle:(NSInteger)row {
    DDLogVerbose(@"%@ getTitle: %ld", LOG_TAG, (long)row);
    
    NSString *title = @"";
    
    switch (row) {
        case PREVIEW_APPEARANCE_TITLE_ROW:
            title = TwinmeLocalizedString(@"space_appearance_view_controller_preview_title", nil);
            break;
            
        case BACKGROUND_APPEARANCE_TITLE_ROW:
            title = TwinmeLocalizedString(@"space_appearance_view_controller_background_title", nil);
            break;
            
        case BACKGROUND_COLOR_ROW:
            title = TwinmeLocalizedString(@"application_color", nil);
            break;
            
        case BACKGROUND_TEXT_ROW:
            title = TwinmeLocalizedString(@"space_appareance_view_controller_background_text_title", nil);
            break;
            
        case ITEM_APPEARANCE_TITLE_ROW:
            title = TwinmeLocalizedString(@"space_appearance_view_controller_container_title", nil);
            break;
            
        case ITEM_BACKGROUND_COLOR_ROW:
            title = TwinmeLocalizedString(@"space_appearance_view_controller_container_background_message", nil);
            break;
            
        case PEER_ITEM_BACKGROUND_COLOR_ROW:
            title = TwinmeLocalizedString(@"space_appearance_view_controller_container_background_peer_message", nil);
            break;
            
        case ITEM_BORDER_COLOR_ROW:
            title = TwinmeLocalizedString(@"space_appearance_view_controller_container_border_message", nil);
            break;
            
        case PEER_ITEM_BORDER_COLOR_ROW:
            title = TwinmeLocalizedString(@"space_appearance_view_controller_container_border_peer_message", nil);
            break;
            
        case ITEM_TEXT_COLOR_ROW:
            title = TwinmeLocalizedString(@"space_appearance_view_controller_container_text_message", nil);
            break;
            
        case PEER_ITEM_TEXT_COLOR_ROW:
            title = TwinmeLocalizedString(@"space_appearance_view_controller_container_text_peer_message", nil);
            break;
            
        default:
            break;
    }
    
    return title;
}

- (UIColor *)getColor:(NSInteger)row {
    DDLogVerbose(@"%@ getColor: %ld", LOG_TAG, (long)row);
    
    UIColor *color = [UIColor clearColor];
    
    switch (row) {
        case BACKGROUND_COLOR_ROW:
            color = [self.customAppearance getConversationBackgroundColor];
            break;
            
        case BACKGROUND_TEXT_ROW:
            color = [self.customAppearance getConversationBackgroundText];
            break;
            
        case ITEM_BACKGROUND_COLOR_ROW:
            color = [self.customAppearance getMessageBackgroundColor];
            break;
            
        case PEER_ITEM_BACKGROUND_COLOR_ROW:
            color = [self.customAppearance getPeerMessageBackgroundColor];
            break;
            
        case ITEM_BORDER_COLOR_ROW:
            color = [self.customAppearance getMessageBorderColor];
            break;
            
        case PEER_ITEM_BORDER_COLOR_ROW:
            color = [self.customAppearance getPeerMessageBorderColor];
            break;
            
        case ITEM_TEXT_COLOR_ROW:
            color = [self.customAppearance getMessageTextColor];
            break;
            
        case PEER_ITEM_TEXT_COLOR_ROW:
            color = [self.customAppearance getPeerMessageTextColor];
            break;
            
        default:
            break;
    }
    
    return color;
}

- (UIColor *)getDefaultColor:(NSInteger)row {
    DDLogVerbose(@"%@ getDefaultColor: %ld", LOG_TAG, (long)row);
    
    UIColor *color = [UIColor clearColor];
    
    switch (row) {
        case BACKGROUND_COLOR_ROW:
            color = [self.customAppearance getConversationBackgroundDefaultColor];
            break;
            
        case BACKGROUND_TEXT_ROW:
            color = [self.customAppearance getConversationBackgroundTextDefaultColor];
            break;
            
        case ITEM_BACKGROUND_COLOR_ROW:
            color = [self.customAppearance getMessageBackgroundDefaultColor];
            break;
            
        case PEER_ITEM_BACKGROUND_COLOR_ROW:
            color = [self.customAppearance getPeerMessageBackgroundDefaultColor];
            break;
            
        case ITEM_BORDER_COLOR_ROW:
            color = [self.customAppearance getMessageBorderDefaultColor];
            break;
            
        case PEER_ITEM_BORDER_COLOR_ROW:
            color = [self.customAppearance getPeerMessageBorderDefaultColor];
            break;
            
        case ITEM_TEXT_COLOR_ROW:
            color = [self.customAppearance getMessageTextDefaultColor];
            break;
            
        case PEER_ITEM_TEXT_COLOR_ROW:
            color = [self.customAppearance getPeerMessageTextDefaultColor];
            break;
            
        default:
            break;
    }
    
    return color;
}


- (void)updateAppearance:(UIColor *)color {
    DDLogVerbose(@"%@ updateAppearanceColor", LOG_TAG);
    
    if (!self.selectedIndexPath) {
        return;
    }
    switch (self.selectedIndexPath.row) {
        case BACKGROUND_COLOR_ROW:
            if (self.displayMode == DisplayModeDark) {
                self.conversationBackgroundDarkImage = nil;
                self.updatedConversationBackgroundDarkColor = YES;
            } else {
                self.conversationBackgroundLightImage = nil;
                self.updatedConversationBackgroundLightColor = YES;
            }
            [self.customAppearance setConversationBackgroundColor:color];
            break;
            
        case BACKGROUND_TEXT_ROW:
            [self.customAppearance setConversationBackgroundText:color];
            break;
            
        case ITEM_BACKGROUND_COLOR_ROW:
            [self.customAppearance setMessageBackgroundColor:color];
            break;
            
        case PEER_ITEM_BACKGROUND_COLOR_ROW:
            [self.customAppearance setPeerMessageBackgroundColor:color];
            break;
            
        case ITEM_BORDER_COLOR_ROW:
            [self.customAppearance setMessageBorderColor:color];
            break;
            
        case PEER_ITEM_BORDER_COLOR_ROW:
            [self.customAppearance setPeerMessageBorderColor:color];
            break;
            
        case ITEM_TEXT_COLOR_ROW:
            [self.customAppearance setMessageTextColor:color];
            break;
            
        case PEER_ITEM_TEXT_COLOR_ROW:
            [self.customAppearance setPeerMessageTextColor:color];
            break;
            
        default:
            break;
    }
    
    [self.tableView reloadData];
}

- (void)openMenuColor:(UIColor *)color title:(NSString *)title defaultColor:(UIColor *)defaultColor {
    DDLogVerbose(@"%@ openMenuColor: %@", LOG_TAG, color);
    
    if (!self.menuSelectColorView) {
        self.menuSelectColorView = [[MenuSelectColorView alloc]init];
        self.menuSelectColorView.menuSelectColorDelegate = self;
        [self.tabBarController.view addSubview:self.menuSelectColorView];
        [self.menuSelectColorView openMenu:color title:title defaultColor:[UIColor hexStringWithColor:defaultColor] spaceSettings:self.currentSpaceSettings];
    }
}

- (void)openMenuPhoto {
    DDLogVerbose(@"%@ openMenuPhoto", LOG_TAG);
        
    MenuPhotoView *menuPhotoView = [[MenuPhotoView alloc]init];
    menuPhotoView.menuPhotoViewDelegate = self;
    menuPhotoView.showSelectColor = YES;
    [self.tabBarController.view addSubview:menuPhotoView];
    [menuPhotoView openMenu:YES];
}

- (void)takePhoto {
    DDLogVerbose(@"%@ takePhoto", LOG_TAG);
    
    AVAuthorizationStatus cameraAuthorizationStatus = [DeviceAuthorization deviceCameraAuthorizationStatus];
    switch (cameraAuthorizationStatus) {
        case AVAuthorizationStatusNotDetermined: {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                        picker.delegate = self;
                        picker.allowsEditing = NO;
                        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                        picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
                        [self presentViewController:picker animated:YES completion:nil];
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
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = NO;
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
            [self presentViewController:picker animated:YES completion:nil];
            break;
        }
    }
}

- (void)selectPhoto {
    DDLogVerbose(@"%@ selectPhoto", LOG_TAG);
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        CGSize size = self.view.bounds.size;
        picker.modalPresentationStyle = UIModalPresentationPopover;
        picker.popoverPresentationController.sourceView = self.view;
        picker.popoverPresentationController.sourceRect = CGRectMake(size.width * 0.5, size.height * 0.2, size.width * 0.6, size.height * 0.7);
        picker.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
        [self presentViewController:picker animated:YES completion:nil];
    } else {
        [self presentViewController:picker animated:YES completion:nil];
    }
}

- (BOOL)isSelectableRow:(NSIndexPath *)indexPath {
    
    if (indexPath.section == INFO_SECTION || (indexPath.section == CONVERSATIONS_SECTION && (indexPath.row < BACKGROUND_COLOR_ROW || indexPath.row == ITEM_APPEARANCE_TITLE_ROW))) {
        return NO;
    }
    
    return YES;
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    [self.tableView reloadData];
}

@end

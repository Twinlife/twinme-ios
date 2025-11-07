/*
 *  Copyright (c) 2022 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinme/TLProfile.h>

#import <Utils/NSString+Utils.h>

#import "MenuPropagatingProfileView.h"
#import "SelectValueCell.h"
#import "MessageSettingsViewController.h"

#import "ColorCell.h"

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static NSString *SELECT_VALUE_CELL_IDENTIFIER = @"SelectValueCellIdentifier";

static const CGFloat MIN_HEIGHT = 132;

//
// Interface: MenuPropagatingProfileView ()
//

@interface MenuPropagatingProfileView ()<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *confirmViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *confirmViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *confirmViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *confirmView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *confirmLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *confirmLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *cancelView;
@property (weak, nonatomic) IBOutlet UILabel *cancelLabel;

@property (nonatomic) int count;
@property (nonatomic) int selectedValue;

@property (nonatomic) TLProfileUpdateMode profileUpdateMode;

@end

//
// Implementation: MenuPropagatingProfileView
//

#undef LOG_TAG
#define LOG_TAG @"MenuPropagatingProfileView"

@implementation MenuPropagatingProfileView

#pragma mark - UIView

- (instancetype)init {
    DDLogVerbose(@"%@ init", LOG_TAG);
    
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"MenuPropagatingProfileView" owner:self options:nil];
    self = [objects objectAtIndex:0];
    
    self.frame = CGRectMake(0, 0, Design.DISPLAY_WIDTH, Design.DISPLAY_HEIGHT);
    self.count = 3;
    
    if (self) {
        [self initViews];
    }
    return self;
}

- (void)openMenu {
    DDLogVerbose(@"%@ openMenu", LOG_TAG);
    
    self.tableViewHeightConstraint.constant = Design.SETTING_CELL_HEIGHT * self.count;
    
    ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
    TwinmeApplication *twinmeApplication = [delegate twinmeApplication];
    self.profileUpdateMode = twinmeApplication.profileUpdateMode;
    [self reloadData];
    
    [super openMenu];
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ heightForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    return Design.SETTING_CELL_HEIGHT;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    DDLogVerbose(@"%@ numberOfSectionsInTableView: %@", LOG_TAG, tableView);
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ numberOfRowsInSection: %ld", LOG_TAG, tableView, (long)section);
    
    return self.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ cellForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    SelectValueCell *cell = [tableView dequeueReusableCellWithIdentifier:SELECT_VALUE_CELL_IDENTIFIER];
    if (!cell) {
        cell = [[SelectValueCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SELECT_VALUE_CELL_IDENTIFIER];
    }
    
    NSString *title;
    NSString *subtitle = @"";
    
    BOOL checked = self.profileUpdateMode == indexPath.row;

    if (indexPath.row == TLProfileUpdateModeAll) {
        title = TwinmeLocalizedString(@"edit_profile_view_controller_propagating_all_contacts", nil);
    } else if (indexPath.row == TLProfileUpdateModeDefault) {
        title = TwinmeLocalizedString(@"edit_profile_view_controller_propagating_except_contacts", nil);
    } else {
        title = TwinmeLocalizedString(@"edit_profile_view_controller_propagating_no_contact", nil);
    }
        
    [cell bindWithTitle:title subTitle:subtitle checked:checked hideBorder:NO hideSeparator:YES];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ didSelectRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if (indexPath.row == TLProfileUpdateModeAll) {
        self.profileUpdateMode = TLProfileUpdateModeAll;
    } else if (indexPath.row == TLProfileUpdateModeDefault) {
        self.profileUpdateMode = TLProfileUpdateModeDefault;
    } else {
        self.profileUpdateMode = TLProfileUpdateModeNone;
    }

    [self.tableView reloadData];
}

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    [super initViews];
    
    NSMutableAttributedString *attributedTitle = [[NSMutableAttributedString alloc] initWithString:TwinmeLocalizedString(@"edit_profile_view_controller_propagating_message", nil) attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_BOLD36, NSFontAttributeName, Design.FONT_COLOR_DEFAULT, NSForegroundColorAttributeName, nil]];
    [attributedTitle appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n\n"]];
    [attributedTitle appendAttributedString:[[NSMutableAttributedString alloc] initWithString:TwinmeLocalizedString(@"edit_profile_view_controller_propagating_ask_message", nil) attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_MEDIUM34, NSFontAttributeName, Design.FONT_COLOR_GREY, NSForegroundColorAttributeName, nil]]];
    
    self.titleLabel.attributedText = attributedTitle;
    
    self.tableViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.tableView.scrollEnabled = NO;
    self.tableView.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"SelectValueCell" bundle:nil] forCellReuseIdentifier:SELECT_VALUE_CELL_IDENTIFIER];
    
    self.confirmViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.confirmViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.confirmViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.confirmView.backgroundColor = Design.MAIN_COLOR;
    self.confirmView.userInteractionEnabled = YES;
    self.confirmView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.confirmView.clipsToBounds = YES;
    self.confirmView.isAccessibilityElement = YES;
    [self.confirmView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleConfirmTapGesture:)]];
    
    self.confirmLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.confirmLabel.font = Design.FONT_BOLD36;
    self.confirmLabel.textColor = [UIColor whiteColor];
    self.confirmLabel.text = TwinmeLocalizedString(@"edit_profile_view_controller_propagating_profile", nil);
    
    self.cancelViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    UITapGestureRecognizer *cancelViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCancelTapGesture:)];
    [self.cancelView addGestureRecognizer:cancelViewGestureRecognizer];
    
    UIWindow *window = UIApplication.sharedApplication.keyWindow;
    CGFloat safeAreaInset = window.safeAreaInsets.bottom;
    self.cancelViewBottomConstraint.constant = window.safeAreaInsets.bottom;
    
    self.cancelLabel.font = Design.FONT_BOLD34;
    self.cancelLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.cancelLabel.text = TwinmeLocalizedString(@"application_cancel", nil);
}

- (void)reloadData {
    DDLogVerbose(@"%@ reloadData", LOG_TAG);
    
    [self.tableView reloadData];
    self.tableView.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
}

#pragma mark - Private methods

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    if ([self.menuPropagatingProfileDelegate respondsToSelector:@selector(cancelMenuPropagatingProfileView:)]) {
        [self.menuPropagatingProfileDelegate cancelMenuPropagatingProfileView:self];
    }
}

#pragma mark - Private methods

- (void)handleCancelTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleCancelTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        
        if ([self.menuPropagatingProfileDelegate respondsToSelector:@selector(cancelMenuPropagatingProfileView:)]) {
            [self.menuPropagatingProfileDelegate cancelMenuPropagatingProfileView:self];
        }
    }
}

- (void)handleConfirmTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleConfirmTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        
        if ([self.menuPropagatingProfileDelegate respondsToSelector:@selector(saveProfileWithUpdateMode:profileUpdateMode:)]) {
            [self.menuPropagatingProfileDelegate saveProfileWithUpdateMode:self profileUpdateMode:self.profileUpdateMode];
        }
    }
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.confirmLabel.font = Design.FONT_BOLD36;
    self.cancelLabel.font = Design.FONT_BOLD34;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    [super updateColor];
    
    self.cancelLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.confirmView.backgroundColor = Design.MAIN_COLOR;
    
    NSMutableAttributedString *attributedTitle = [[NSMutableAttributedString alloc] initWithString:TwinmeLocalizedString(@"edit_profile_view_controller_propagating_message", nil) attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_BOLD36, NSFontAttributeName, Design.FONT_COLOR_DEFAULT, NSForegroundColorAttributeName, nil]];
    [attributedTitle appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n\n"]];
    [attributedTitle appendAttributedString:[[NSMutableAttributedString alloc] initWithString:TwinmeLocalizedString(@"edit_profile_view_controller_propagating_ask_message", nil) attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_MEDIUM34, NSFontAttributeName, Design.FONT_COLOR_GREY, NSForegroundColorAttributeName, nil]]];
    
    self.titleLabel.attributedText = attributedTitle;
}

@end


/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Utils/NSString+Utils.h>

#import "MenuBackupView.h"
#import "MenuIconCell.h"
#import "BackupInfoCell.h"

#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/UIViewController+Utils.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static float DESIGN_INFO_CELL_HEIGHT = 190;

static NSString *MENU_ICON_CELL_IDENTIFIER = @"MenuIconCellIdentifier";
static NSString *BACKUP_INFO_CELL_IDENTIFIER = @"BackupInfoCellIdentifier";

//
// Interface: MenuBackupView ()
//

@interface MenuBackupView ()<CAAnimationDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) int count;
@property (nonatomic) int selectedValue;

@end

//
// Implementation: MenuBackupView
//

#undef LOG_TAG
#define LOG_TAG @"MenuBackupView"

@implementation MenuBackupView

#pragma mark - UIView

- (instancetype)init {
    DDLogVerbose(@"%@ init", LOG_TAG);
    
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"MenuBackupView" owner:self options:nil];
    self = [objects objectAtIndex:0];
    
    self.frame = CGRectMake(0, 0, Design.DISPLAY_WIDTH, Design.DISPLAY_HEIGHT);
    self.count = 3;
    
    if (self) {
        [self initViews];
    }
    return self;
}

- (void)openMenu:(nonnull NSURL *)backupURL {
    DDLogVerbose(@"%@ openMenu", LOG_TAG);
         
    self.backupURL = backupURL;
    [self openMenu];
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ heightForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if (indexPath.row == 0) {
        return roundf(DESIGN_INFO_CELL_HEIGHT * Design.HEIGHT_RATIO);
    }
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
    
    if (indexPath.row == 0) {
        BackupInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:BACKUP_INFO_CELL_IDENTIFIER];
        if (!cell) {
            cell = [[BackupInfoCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:BACKUP_INFO_CELL_IDENTIFIER];
        }
        
        NSString *fileName = self.backupURL.lastPathComponent;
        [cell bindWithTitle:fileName];
        return cell;
    } else {
        MenuIconCell *cell = [tableView dequeueReusableCellWithIdentifier:MENU_ICON_CELL_IDENTIFIER];
        if (!cell) {
            cell = [[MenuIconCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:MENU_ICON_CELL_IDENTIFIER];
        }
        
        NSString *title = @"";
        NSString *icon = @"";
        BOOL hideSeparator = NO;
        
        if (indexPath.row == 1) {
            title = TwinmeLocalizedStringFromTable(@"application_backup_verify", @"LocalizableBackup", nil);
            icon = @"BackupVerifyIcon";
        } else {
            title = TwinmeLocalizedStringFromTable(@"application_backup_restore", @"LocalizableBackup", nil);
            icon = @"RestoreIcon";
            hideSeparator = YES;
        }
        
        [cell bindWithTitle:title icon:icon hideSeparator:hideSeparator];
            
        return cell;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ didSelectRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if (indexPath.row == 1) {
        if ([self.menuBackupViewDelegate respondsToSelector:@selector(menuBackupDidSelectVerify:backupURL:)]) {
            [self.menuBackupViewDelegate menuBackupDidSelectVerify:self backupURL:self.backupURL];
        }
    } else if (indexPath.row == 2) {
        if ([self.menuBackupViewDelegate respondsToSelector:@selector(menuBackupDidSelectRestore:backupURL:)]) {
            [self.menuBackupViewDelegate menuBackupDidSelectRestore:self backupURL:self.backupURL];
        }
    }
}

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    [super initViews];
        
    CGFloat safeAreaInset;
    UIWindow *window = [UIViewController currentWindow];
    if (window) {
        safeAreaInset = window.safeAreaInsets.bottom;
    } else {
        safeAreaInset = self.safeAreaInsets.bottom;
    }
    
    self.tableViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.tableViewBottomConstraint.constant = safeAreaInset;
    self.tableViewHeightConstraint.constant = Design.SETTING_CELL_HEIGHT * 2 + roundf(DESIGN_INFO_CELL_HEIGHT * Design.HEIGHT_RATIO);
    
    self.tableView.scrollEnabled = NO;
    self.tableView.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"MenuIconCell" bundle:nil] forCellReuseIdentifier:MENU_ICON_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"BackupInfoCell" bundle:nil] forCellReuseIdentifier:BACKUP_INFO_CELL_IDENTIFIER];
}

- (void)reloadData {
    DDLogVerbose(@"%@ reloadData", LOG_TAG);
    
    [self.tableView reloadData];
    self.tableView.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
}

#pragma mark - Private methods

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    if ([self.menuBackupViewDelegate respondsToSelector:@selector(menuBackupDidClose:)]) {
        [self.menuBackupViewDelegate menuBackupDidClose:self];
    }
}

@end


/*
 *  Copyright (c) 2022 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Utils/NSString+Utils.h>

#import "MenuPhotoView.h"
#import "MenuIconCell.h"

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static NSString *MENU_ICON_CELL_IDENTIFIER = @"MenuIconCellIdentifier";

//
// Interface: MenuPhotoView ()
//

@interface MenuPhotoView ()<CAAnimationDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) int count;
@property (nonatomic) int selectedValue;

@end

//
// Implementation: MenuPhotoView
//

#undef LOG_TAG
#define LOG_TAG @"MenuPhotoView"

@implementation MenuPhotoView

#pragma mark - UIView

- (instancetype)init {
    DDLogVerbose(@"%@ init", LOG_TAG);
    
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"MenuPhotoView" owner:self options:nil];
    self = [objects objectAtIndex:0];
    
    self.frame = CGRectMake(0, 0, Design.DISPLAY_WIDTH, Design.DISPLAY_HEIGHT);
    self.count = 2;
    self.showSelectColor = NO;
    
    if (self) {
        [self initViews];
    }
    return self;
}

- (void)openMenu:(BOOL)hideTitle {
    DDLogVerbose(@"%@ openMenu", LOG_TAG);
    
    self.titleLabel.hidden = hideTitle;
    
    if (self.showSelectColor) {
        self.count = 3;
        self.tableViewHeightConstraint.constant = Design.SETTING_CELL_HEIGHT * self.count;
    }
    
    if (hideTitle) {
        self.tableViewTopConstraint.constant = 0;
        self.titleLabelTopConstraint.constant = 0;
    }
    
    [self openMenu];
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
    
    MenuIconCell *cell = [tableView dequeueReusableCellWithIdentifier:MENU_ICON_CELL_IDENTIFIER];
    if (!cell) {
        cell = [[MenuIconCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:MENU_ICON_CELL_IDENTIFIER];
    }
    
    NSString *title = @"";
    NSString *icon = @"";
    BOOL hideSeparator = NO;
    
    if (indexPath.row == 0) {
        title = TwinmeLocalizedString(@"application_camera", nil);
        icon = @"GreyCamera";
    } else if (indexPath.row == 1) {
        title = TwinmeLocalizedString(@"application_photo_gallery", nil);
        icon = @"FromGallery";
        hideSeparator = !self.showSelectColor;
    }  else {
        title = TwinmeLocalizedString(@"application_color", nil);
        icon = @"ColorIcon";
        hideSeparator = YES;
    }
    
    [cell bindWithTitle:title icon:icon hideSeparator:hideSeparator];
        
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ didSelectRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if (indexPath.row == 0) {
        if ([self.menuPhotoViewDelegate respondsToSelector:@selector(menuPhotoDidSelectCamera:)]) {
            [self.menuPhotoViewDelegate menuPhotoDidSelectCamera:self];
        }
    } else if (indexPath.row == 1) {
        if ([self.menuPhotoViewDelegate respondsToSelector:@selector(menuPhotoDidSelectGallery:)]) {
            [self.menuPhotoViewDelegate menuPhotoDidSelectGallery:self];
        }
    } else {
        if ([self.menuPhotoViewDelegate respondsToSelector:@selector(menuPhotoDidSelectColor:)]) {
            [self.menuPhotoViewDelegate menuPhotoDidSelectColor:self];
        }
    }
}

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    [super initViews];
    
    self.titleLabel.text = TwinmeLocalizedString(@"application_profile_avatar_not_defined", nil);
    
    UIWindow *window = UIApplication.sharedApplication.keyWindow;
    CGFloat safeAreaInset = window.safeAreaInsets.bottom;
    
    self.tableViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.tableViewBottomConstraint.constant = safeAreaInset;
    self.tableViewHeightConstraint.constant = Design.SETTING_CELL_HEIGHT * self.count;

    self.tableView.scrollEnabled = NO;
    self.tableView.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"MenuIconCell" bundle:nil] forCellReuseIdentifier:MENU_ICON_CELL_IDENTIFIER];
}

- (void)reloadData {
    DDLogVerbose(@"%@ reloadData", LOG_TAG);
    
    [self.tableView reloadData];
    self.tableView.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
}

#pragma mark - Private methods

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    if ([self.menuPhotoViewDelegate respondsToSelector:@selector(cancelMenuPhoto:)]) {
        [self.menuPhotoViewDelegate cancelMenuPhoto:self];
    }
}

@end


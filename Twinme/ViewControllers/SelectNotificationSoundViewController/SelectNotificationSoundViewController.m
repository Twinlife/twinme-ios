/*
 *  Copyright (c) 2016-2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Chedi Baccari (Chedi.Baccari@twinlife-systems.com)
 *   Christian Jacquemot (Christian.Jacquemot@twinlife-systems.com)
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Utils/NSString+Utils.h>

#import "SelectNotificationSoundViewController.h"
#import "NotificationSoundCell.h"
#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/NotificationSound.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static NSString *NOTIFICATION_SOUND_CELL_IDENTIFIER = @"NotificationSoundCellIdentifier";

static CGFloat DESIGN_CELL_HEIGHT = 120;

//
// Interface: SelectNotificationSoundViewController ()
//

@interface SelectNotificationSoundViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) NSArray<NotificationSoundSetting *> *notificationSounds;
@property (nonatomic) NSIndexPath *selectedIndexPath;
@property (nonatomic) NotificationSound* notificationSound;

@end

//
// Implementation: SelectNotificationSoundViewController
//

#undef LOG_TAG
#define LOG_TAG @"SelectNotificationSoundViewController"

@implementation SelectNotificationSoundViewController

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
    
    [self initViews];
}

- (void)viewWillDisappear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillDisappear", LOG_TAG);
    
    [super viewWillDisappear:animated];
    
    if (self.notificationSound) {
        [self.notificationSound dispose];
        self.notificationSound = nil;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    DDLogVerbose(@"%@ viewDidAppear", LOG_TAG);
    
    [super viewDidAppear:animated];
}

#pragma mark - Setters/Getters

- (void)setNotificationSoundType:(NotificationSoundType)notificationSoundType {
    DDLogVerbose(@"%@ setContact: %u", LOG_TAG, notificationSoundType);
    
    _notificationSoundType = notificationSoundType;
    
    self.notificationSounds = [NotificationSound getNotificationSoundsWithType:_notificationSoundType];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    DDLogVerbose(@"%@ numberOfSectionsInTableView: %@", LOG_TAG, tableView);
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ numberOfRowsInSection: %ld", LOG_TAG, tableView, (long)section);
    
    return self.notificationSounds.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
    
    return round(DESIGN_CELL_HEIGHT * Design.HEIGHT_RATIO);
}

#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ cellForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    NotificationSoundCell *cell = [tableView dequeueReusableCellWithIdentifier:NOTIFICATION_SOUND_CELL_IDENTIFIER forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[NotificationSoundCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:NOTIFICATION_SOUND_CELL_IDENTIFIER];
    }
    
    NotificationSoundSetting* selectedNotificationSound = [self.twinmeApplication getNotificationSoundWithType:self.notificationSoundType];
    NotificationSoundSetting* notificationSound = [self.notificationSounds objectAtIndex:indexPath.row];
    
    [cell bindWithName:notificationSound.soundName];
    
    if ([notificationSound isEqual:selectedNotificationSound]) {
        self.selectedIndexPath = indexPath;
        [cell setChecked:YES];
    } else {
        [cell setChecked:NO];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ didSelectRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if (self.notificationSound) {
        [self.notificationSound dispose];
    }
    self.selectedIndexPath = indexPath;
    self.notificationSound = [[NotificationSound alloc] initWithSettings:[self.notificationSounds objectAtIndex:self.selectedIndexPath.row]];
    [self.twinmeApplication setNotificationSoundWithType:self.notificationSoundType notificationSound:self.notificationSound];
    [self.notificationSound playWithLoop:NO];
    
    [self.tableView reloadData];
    
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ didDeselectRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if (self.notificationSound) {
        [self.notificationSound dispose];
        self.notificationSound = nil;
    }
    
    if ([indexPath isEqual:self.selectedIndexPath]) {
        self.notificationSound = [[NotificationSound alloc] initWithSettings:[self.notificationSounds objectAtIndex:self.selectedIndexPath.row]];
        [self.notificationSound playWithLoop:NO];
    }
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.view.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    
    [self setNavigationTitle:TwinmeLocalizedString(@"select_notification_sound_view_controller_title", nil)];
    
    self.tableView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"NotificationSoundCell" bundle:nil] forCellReuseIdentifier:NOTIFICATION_SOUND_CELL_IDENTIFIER];
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    [self.tableView reloadData];
}

@end

/*
 *  Copyright (c) 2018-2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <MediaPlayer/MediaPlayer.h>

#import <Utils/NSString+Utils.h>

#import "StreamingAudioViewController.h"
#import "TwinmeSearchController.h"

#import "StreamingMusicCell.h"

#import <TwinmeCommon/Design.h>
#import "DeviceAuthorization.h"
#import <TwinmeCommon/CallService.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static CGFloat DESIGN_MUSIC_CELL_HEIGHT = 252;

static NSString *STREAMING_MUSIC_CELL_IDENTIFIER = @"StreamingMusicCellIdentifier";

@interface StreamingAudioViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UISearchBarDelegate>

@property (nonatomic, readonly, nonnull) CallService *callService;

@property (weak, nonatomic) IBOutlet UITableView *songsTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noMusicImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noMusicImageViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noMusicImageViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *noMusicImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noMusicTitleLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noMusicTitleLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *noMusicTitleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noMusicLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noMusicLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *noMusicLabel;

@property (nonatomic) UIBarButtonItem *cancelBarButtonItem;
@property (nonatomic) UIBarButtonItem *shareBarButtonItem;
@property (nonatomic) TwinmeSearchController *searchController;

@property (nonatomic) NSMutableArray *songs;
@property (nonatomic) NSArray *filteredSongs;

@property (nonatomic) MPMediaItem *selectedItem;

@end

//
// Implementation: StreamingAudioViewController
//

#undef LOG_TAG
#define LOG_TAG @"StreamingAudioViewController"

@implementation StreamingAudioViewController

#pragma mark - UIViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _songs = [[NSMutableArray alloc] init];
        _filteredSongs = [[NSArray alloc] init];

        ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
        _callService = delegate.callService;
    }
    return self;
}

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
    
    [self initViews];
    
    [self requestMediaLibary];
}

#pragma mark - UIViewController (Utils)

- (BOOL)hasLandscapeMode {
    DDLogVerbose(@"%@ hasLandscapeMode", LOG_TAG);
    
    return YES;
}

#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    DDLogVerbose(@"%@ textFieldShouldReturn: %@", LOG_TAG, textField);
    
    [textField resignFirstResponder];
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    DDLogVerbose(@"%@ textFieldDidEndEditing: %@", LOG_TAG, textField);
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    DDLogVerbose(@"%@ searchBar: %@ textDidChange: %@", LOG_TAG, searchBar, searchText);
    
    if (![searchText isEqualToString:@""]) {
        [self searchSongs:searchText];
    } else {
        [self resetFilteredSongs];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    DDLogVerbose(@"%@ searchBarCancelButtonClicked: %@", LOG_TAG, searchBar);
    
    [self resetFilteredSongs];
}

- (void)getAllSongs {
    DDLogVerbose(@"%@ getAllSongs", LOG_TAG);
    
    MPMediaQuery *mediaQuery = [MPMediaQuery songsQuery];
    [mediaQuery addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:[NSNumber numberWithBool:NO] forProperty:MPMediaItemPropertyIsCloudItem]];
    [mediaQuery addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:[NSNumber numberWithBool:NO] forProperty:MPMediaItemPropertyHasProtectedAsset]];
    
    self.songs = [[NSMutableArray alloc] initWithArray:[mediaQuery items]];
    [self resetFilteredSongs];
}

- (void)searchSongs:(NSString *)text {
    DDLogVerbose(@"%@ searchSongs: %@", LOG_TAG, text);
    
    NSPredicate *predicateTitle = [NSPredicate predicateWithFormat:@"title contains[c] %@", text];
    NSPredicate *predicateAlbum = [NSPredicate predicateWithFormat:@"albumTitle contains[c] %@", text];
    NSPredicate *predicateArtist = [NSPredicate predicateWithFormat:@"artist contains[c] %@", text];
    NSPredicate *predicate = [NSCompoundPredicate orPredicateWithSubpredicates:@[predicateTitle, predicateAlbum, predicateArtist]];
    
    self.filteredSongs = [self.songs filteredArrayUsingPredicate:predicate];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self reloadData];
    });
}

- (void)resetFilteredSongs {
    DDLogVerbose(@"%@ resetFilteredSongs", LOG_TAG);
    
    self.filteredSongs = [NSArray arrayWithArray:self.songs];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self reloadData];
    });
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    DDLogVerbose(@"%@ numberOfSectionsInTableView: %@", LOG_TAG, tableView);
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ numberOfRowsInSection: %ld", LOG_TAG, tableView, (long)section);
    
    return self.filteredSongs.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return DESIGN_MUSIC_CELL_HEIGHT * Design.HEIGHT_RATIO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ cellForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    StreamingMusicCell *streamingMusicCell = (StreamingMusicCell *)[tableView dequeueReusableCellWithIdentifier:STREAMING_MUSIC_CELL_IDENTIFIER];
    if (!streamingMusicCell) {
        streamingMusicCell = [[StreamingMusicCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:STREAMING_MUSIC_CELL_IDENTIFIER];
    }
    
    MPMediaItem *item = [self.filteredSongs objectAtIndex:indexPath.row];
    BOOL checked = [self.selectedItem isEqual:item];
    [streamingMusicCell bindWithItem:item checked:checked];
    return streamingMusicCell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ didSelectRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    self.selectedItem = [self.filteredSongs objectAtIndex:indexPath.row];
    
    [self.songsTableView reloadData];
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.definesPresentationContext = YES;
    self.view.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    
    [self setNavigationTitle:TwinmeLocalizedString(@"streaming_audio_view_controller_title", nil)];
            
    self.cancelBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:TwinmeLocalizedString(@"application_cancel", nil) style:UIBarButtonItemStylePlain target:self action:@selector(handleCancelTapGesture:)];
    [self.cancelBarButtonItem setTitleTextAttributes: @{NSFontAttributeName: Design.FONT_BOLD36, NSForegroundColorAttributeName: [UIColor whiteColor]} forState:UIControlStateNormal];
    [self.cancelBarButtonItem setTitleTextAttributes: @{NSFontAttributeName: Design.FONT_BOLD36, NSForegroundColorAttributeName: [UIColor colorWithWhite:1.0 alpha:0.5]} forState:UIControlStateDisabled];
    self.navigationItem.leftBarButtonItem = self.cancelBarButtonItem;
    
    self.shareBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:TwinmeLocalizedString(@"application_ok", nil) style:UIBarButtonItemStylePlain target:self action:@selector(handleShareTapGesture:)];
    [self.shareBarButtonItem setTitleTextAttributes: @{NSFontAttributeName: Design.FONT_BOLD36, NSForegroundColorAttributeName: [UIColor whiteColor]} forState:UIControlStateNormal];
    [self.shareBarButtonItem setTitleTextAttributes: @{NSFontAttributeName: Design.FONT_BOLD36, NSForegroundColorAttributeName: [UIColor colorWithWhite:1.0 alpha:0.5]} forState:UIControlStateDisabled];
    self.navigationItem.rightBarButtonItem = self.shareBarButtonItem;
    
    self.navigationItem.hidesSearchBarWhenScrolling = NO;
    
    self.searchController = [[TwinmeSearchController alloc] initWithSearchResultsController:nil];
    self.searchController.obscuresBackgroundDuringPresentation = NO;
    self.searchController.searchBar.placeholder = TwinmeLocalizedString(@"application_search_hint", nil);
    
    UISearchBar *contactSearchBar = self.searchController.searchBar;
    contactSearchBar.barStyle = UIBarStyleDefault;
    contactSearchBar.searchBarStyle = UISearchBarStyleProminent;
    contactSearchBar.translucent = NO;
    contactSearchBar.barTintColor = Design.NAVIGATION_BAR_BACKGROUND_COLOR;
    contactSearchBar.tintColor = [UIColor whiteColor];
    contactSearchBar.placeholder = TwinmeLocalizedString(@"application_search_hint", nil);
    contactSearchBar.backgroundImage = [UIImage new];
    contactSearchBar.backgroundColor = Design.NAVIGATION_BAR_BACKGROUND_COLOR;
    contactSearchBar.delegate = self;
    
    if (@available(iOS 13.0, *)) {
        self.searchController.searchBar.backgroundColor = [UIColor clearColor];
        self.searchController.searchBar.searchTextField.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
        self.searchController.searchBar.searchTextField.tintColor = [UIColor darkGrayColor];
        self.searchController.searchBar.translucent = NO;
        self.navigationItem.searchController = self.searchController;
    } else {
        self.songsTableView.tableHeaderView = self.searchController.searchBar;
    }
    
    self.songsTableView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    self.songsTableView.delegate = self;
    self.songsTableView.dataSource = self;
    
    [self.songsTableView registerNib:[UINib nibWithNibName:@"StreamingMusicCell" bundle:nil] forCellReuseIdentifier:STREAMING_MUSIC_CELL_IDENTIFIER];
    
    self.noMusicImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.noMusicImageViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.noMusicImageViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.noMusicImageView.hidden = YES;
    
    self.noMusicTitleLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.noMusicTitleLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.noMusicTitleLabel.font = Design.FONT_MEDIUM34;
    self.noMusicTitleLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.noMusicTitleLabel.text = TwinmeLocalizedString(@"streaming_audio_view_controller_no_music_title", nil);
    self.noMusicTitleLabel.hidden = YES;
    
    self.noMusicLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.noMusicLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.noMusicLabel.font = Design.FONT_MEDIUM28;
    self.noMusicLabel.textColor = Design.FONT_COLOR_DESCRIPTION;
    self.noMusicLabel.text = TwinmeLocalizedString(@"streaming_audio_view_controller_no_music_message", nil);
    self.noMusicLabel.hidden = YES;
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)handleCancelTapGesture:(UIButton *)sender {
    DDLogVerbose(@"%@ handlecancelTapGesture: %@", LOG_TAG, sender);
    
    [self finish];
}

- (void)handleShareTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleSaveTapGesture: %@", LOG_TAG, sender);
    
    if (self.selectedItem) {
        [self.callService startStreamingWithMediaItem:self.selectedItem];
    }

    [self finish];
}

- (void)requestMediaLibary {
    DDLogVerbose(@"%@ requestMediaLibary", LOG_TAG);
    
    MPMediaLibraryAuthorizationStatus mediaLibraryAuthorizationStatus = [DeviceAuthorization deviceMediaLibraryAuthorizationStatus];
    switch (mediaLibraryAuthorizationStatus) {
        case MPMediaLibraryAuthorizationStatusNotDetermined: {
            [MPMediaLibrary requestAuthorization:^(MPMediaLibraryAuthorizationStatus authorizationStatus) {
                if (authorizationStatus == MPMediaLibraryAuthorizationStatusAuthorized) {
                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                        if (self.songs.count == 0) {
                            [self getAllSongs];
                        }
                    });
                }
            }];
            break;
        }
            
        case MPMediaLibraryAuthorizationStatusDenied:
        case MPMediaLibraryAuthorizationStatusRestricted:
            [DeviceAuthorization showMediaSettingsAlertInController:self];
            break;
            
        case MPMediaLibraryAuthorizationStatusAuthorized: {
            if (self.songs.count == 0) {
                [self getAllSongs];
            }
            
            break;
        }
    }
}

- (void)reloadData {
    DDLogVerbose(@"%@ reloadData", LOG_TAG);
    
    if (!self.filteredSongs || self.filteredSongs.count == 0) {
        self.noMusicImageView.hidden = NO;
        self.noMusicLabel.hidden = NO;
        self.noMusicTitleLabel.hidden = NO;
    } else {
        self.noMusicImageView.hidden = YES;
        self.noMusicLabel.hidden = YES;
        self.noMusicTitleLabel.hidden = YES;
    }
    
    [self.songsTableView reloadData];
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    [self.cancelBarButtonItem setTitleTextAttributes:@{NSFontAttributeName:Design.FONT_BOLD36, NSForegroundColorAttributeName: [UIColor whiteColor]} forState:UIControlStateNormal];
    [self.cancelBarButtonItem setTitleTextAttributes:@{NSFontAttributeName:Design.FONT_BOLD36, NSForegroundColorAttributeName: [UIColor colorWithWhite:1.0 alpha:0.5]} forState:UIControlStateDisabled];
    
    [self.shareBarButtonItem setTitleTextAttributes:@{NSFontAttributeName:Design.FONT_BOLD36, NSForegroundColorAttributeName: [UIColor whiteColor]} forState:UIControlStateNormal];
    [self.shareBarButtonItem setTitleTextAttributes:@{NSFontAttributeName:Design.FONT_BOLD36, NSForegroundColorAttributeName: [UIColor colorWithWhite:1.0 alpha:0.5]} forState:UIControlStateDisabled];
    
    self.noMusicTitleLabel.font = Design.FONT_MEDIUM34;
    self.noMusicLabel.font = Design.FONT_MEDIUM28;
    
    [self.songsTableView reloadData];
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.searchController.searchBar.barTintColor = Design.NAVIGATION_BAR_BACKGROUND_COLOR;
    self.view.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    self.songsTableView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    
    self.noMusicTitleLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.noMusicLabel.textColor = Design.FONT_COLOR_DESCRIPTION;
    
    if (@available(iOS 13.0, *)) {
        self.searchController.searchBar.backgroundColor = [UIColor clearColor];
        self.searchController.searchBar.searchTextField.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
        self.searchController.searchBar.searchTextField.tintColor = Design.FONT_COLOR_DEFAULT;
        self.searchController.searchBar.searchTextField.textColor = Design.FONT_COLOR_DEFAULT;
        
        UIImageView *glassIconImageView = (UIImageView *)self.searchController.searchBar.searchTextField.leftView;
        glassIconImageView.image = glassIconImageView.image = [glassIconImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        glassIconImageView.tintColor = Design.PLACEHOLDER_COLOR;
    } else {
        self.searchController.searchBar.backgroundColor = Design.NAVIGATION_BAR_BACKGROUND_COLOR;
    }
}

@end

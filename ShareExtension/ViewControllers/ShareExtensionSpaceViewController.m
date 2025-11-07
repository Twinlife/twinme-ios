/*
 *  Copyright (c) 2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "ShareExtensionSpaceViewController.h"

#import <Twinlife/TLTwinlife.h>
#import <Twinme/TLTwinmeAttributes.h>
#import <Twinme/TLSpace.h>
#import <Twinme/TLTwinmeApplication.h>
#import <Twinme/TLTwinmeContext.h>

#import <Utils/NSString+Utils.h>

#import "ShareExtensionSpaceCell.h"
#import "ShareExtensionSpace.h"

#import "DesignExtension.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static NSString *SPACE_CELL_IDENTIFIER = @"ShareExtensionSpaceCellIdentifier";

static CGFloat DESIGN_CELL_HEIGHT = 144;

//
// Interface: ShareExtensionSpaceViewController
//

@interface ShareExtensionSpaceViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *spacesTableView;

@property (nonatomic) NSMutableArray *uiSpaces;

@end

//
// Implementation: ShareExtensionSpaceViewController
//

#undef LOG_TAG
#define LOG_TAG @"ShareExtensionSpaceViewController"

@implementation ShareExtensionSpaceViewController

#pragma mark - UIViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
    
    [self initViews];
}

- (void)initWithSpaces:(NSMutableArray *)spaces {
    DDLogVerbose(@"%@ initWithSpaces: %@", LOG_TAG, spaces);
    
    self.uiSpaces = spaces;
    
    [self.spacesTableView reloadData];
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    DDLogVerbose(@"%@ searchBar: %@ textDidChange: %@", LOG_TAG, searchBar, searchText);
    
    [self.uiSpaces removeAllObjects];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    DDLogVerbose(@"%@ searchBarCancelButtonClicked: %@", LOG_TAG, searchBar);
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    DDLogVerbose(@"%@ numberOfSectionsInTableView: %@", LOG_TAG, tableView);
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ numberOfRowsInSection: %ld", LOG_TAG, tableView, (long)section);
    
    return self.uiSpaces.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
    
    return DesignExtension.HEIGHT_RATIO * DESIGN_CELL_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ cellForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    ShareExtensionSpaceCell *selectSpaceCell = (ShareExtensionSpaceCell *)[tableView dequeueReusableCellWithIdentifier:SPACE_CELL_IDENTIFIER];
    if (!selectSpaceCell) {
        selectSpaceCell = [[ShareExtensionSpaceCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SPACE_CELL_IDENTIFIER];
    }
    
    ShareExtensionSpace *shareExtensionSpace = [self.uiSpaces objectAtIndex:indexPath.row];
    BOOL hideSeparator = indexPath.row + 1 == self.uiSpaces.count ? YES : NO;
    
    [selectSpaceCell bindWithSpace:shareExtensionSpace.space avatar:shareExtensionSpace.avatarSpace currentSpace:shareExtensionSpace.isCurrentSpace hideSeparator:hideSeparator];
    
    return selectSpaceCell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ didSelectRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    ShareExtensionSpace *shareExtensionSpace = [self.uiSpaces objectAtIndex:indexPath.row];
    [self.shareExtensionSpaceDelegate didSelectSpace:shareExtensionSpace.space];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    UIColor *backgroundColor = DesignExtension.NAVIGATION_BACKGROUND_COLOR;
    
    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *navBarAppearance = [self.navigationController.navigationBar standardAppearance];
        [navBarAppearance configureWithOpaqueBackground];
        navBarAppearance.titleTextAttributes = @{NSFontAttributeName: DesignExtension.FONT_BOLD34, NSForegroundColorAttributeName: [UIColor whiteColor]};
        navBarAppearance.largeTitleTextAttributes = @{NSFontAttributeName: DesignExtension.FONT_BOLD68, NSForegroundColorAttributeName: [UIColor whiteColor]};
        navBarAppearance.backgroundColor = backgroundColor;
        self.navigationController.navigationBar.standardAppearance = navBarAppearance;
        self.navigationController.navigationBar.scrollEdgeAppearance = navBarAppearance;
        self.navigationController.navigationBar.compactAppearance = navBarAppearance;
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    } else {
        self.navigationController.navigationBar.translucent = NO;
        self.navigationController.navigationBar.barTintColor = backgroundColor;
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        self.navigationController.navigationBar.backgroundColor = backgroundColor;
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName: DesignExtension.FONT_REGULAR34, NSForegroundColorAttributeName: [UIColor whiteColor]}];
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName: DesignExtension.FONT_BOLD34, NSForegroundColorAttributeName: [UIColor whiteColor]}];
    }
    
    self.navigationItem.title = TwinmeLocalizedString(@"spaces_view_controller_title", nil).capitalizedString;
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.hidesSearchBarWhenScrolling = NO;
    
    self.spacesTableView.backgroundColor = DesignExtension.LIGHT_GREY_BACKGROUND_COLOR;
    self.spacesTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.spacesTableView.tableFooterView = nil;
    self.spacesTableView.delegate = self;
    self.spacesTableView.dataSource = self;
    self.spacesTableView.sectionHeaderHeight = 0;
    self.spacesTableView.sectionFooterHeight = 0;
    
    [self.spacesTableView registerNib:[UINib nibWithNibName:@"ShareExtensionSpaceCell" bundle:nil] forCellReuseIdentifier:SPACE_CELL_IDENTIFIER];
}

@end

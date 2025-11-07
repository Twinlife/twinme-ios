/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Utils/NSString+Utils.h>

#import "TemplateSpaceViewController.h"

#import "EditSpaceViewController.h"

#import "TemplateSpaceCell.h"

#import <TwinmeCommon/Design.h>
#import "UISpace.h"
#import "UITemplateSpace.h"
#import <TwinmeCommon/MainViewController.h>
#import <TwinmeCommon/TwinmeNavigationController.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static NSString *TEMPLATE_SPACE_CELL_IDENTIFIER = @"TemplateSpaceCellIdentifier";

static const int SPACES_VIEW_SECTION_COUNT = 1;

//
// Interface: SpacesViewController ()
//

@interface TemplateSpaceViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *spacesTableView;

@property (nonatomic) NSMutableArray *uiTemplateSpaces;

@end

//
// Implementation: TemplateSpaceViewController
//

#undef LOG_TAG
#define LOG_TAG @"TemplateSpaceViewController"

@implementation TemplateSpaceViewController

#pragma mark - UIViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _uiTemplateSpaces = [[NSMutableArray alloc] init];
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
    
    return SPACES_VIEW_SECTION_COUNT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ numberOfRowsInSection: %ld", LOG_TAG, tableView, (long)section);
    
    return self.uiTemplateSpaces.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
    
    return Design.CELL_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ cellForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    TemplateSpaceCell *spaceCell = (TemplateSpaceCell *)[tableView dequeueReusableCellWithIdentifier:TEMPLATE_SPACE_CELL_IDENTIFIER];
    if (!spaceCell) {
        spaceCell = [[TemplateSpaceCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:TEMPLATE_SPACE_CELL_IDENTIFIER];
    }
    
    UITemplateSpace *uiTemplateSpace = [self.uiTemplateSpaces objectAtIndex:indexPath.row];
    BOOL hideSeparator = indexPath.row + 1 == self.uiTemplateSpaces.count ? YES : NO;
    [spaceCell bindWithSpace:uiTemplateSpace hideSeparator:hideSeparator];
    
    return spaceCell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ didSelectRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    UITemplateSpace *uiTemplateSpace = [self.uiTemplateSpaces objectAtIndex:indexPath.row];
    EditSpaceViewController *editSpaceViewController = (EditSpaceViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"EditSpaceViewController"];
    [editSpaceViewController initWithTemplateSpace:uiTemplateSpace];
    [self.navigationController pushViewController:editSpaceViewController animated:YES];
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.definesPresentationContext = YES;
    self.view.backgroundColor = Design.WHITE_COLOR;
    
    [self setNavigationTitle:TwinmeLocalizedString(@"template_space_view_controller_template_title", nil).capitalizedString];
    
    self.spacesTableView.delegate = self;
    self.spacesTableView.dataSource = self;
    self.spacesTableView.backgroundColor = Design.WHITE_COLOR;
    self.spacesTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.spacesTableView registerNib:[UINib nibWithNibName:@"TemplateSpaceCell" bundle:nil] forCellReuseIdentifier:TEMPLATE_SPACE_CELL_IDENTIFIER];
}

- (void)initTemplates {
    DDLogVerbose(@"%@ initTemplates", LOG_TAG);
    
    self.uiTemplateSpaces = [[NSMutableArray alloc]init];
    [self.uiTemplateSpaces addObject:[[UITemplateSpace alloc]initWithTemplateType:TemplateTypeFamily1]];
    [self.uiTemplateSpaces addObject:[[UITemplateSpace alloc]initWithTemplateType:TemplateTypeFamily2]];
    [self.uiTemplateSpaces addObject:[[UITemplateSpace alloc]initWithTemplateType:TemplateTypeFriends1]];
    [self.uiTemplateSpaces addObject:[[UITemplateSpace alloc]initWithTemplateType:TemplateTypeFriends2]];
    [self.uiTemplateSpaces addObject:[[UITemplateSpace alloc]initWithTemplateType:TemplateTypeBusiness1]];
    [self.uiTemplateSpaces addObject:[[UITemplateSpace alloc]initWithTemplateType:TemplateTypeBusiness2]];
    [self.uiTemplateSpaces addObject:[[UITemplateSpace alloc]initWithTemplateType:TemplateTypeOther]];
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.view.backgroundColor = Design.WHITE_COLOR;
    self.spacesTableView.backgroundColor = Design.WHITE_COLOR;

    [self.spacesTableView reloadData];
}

@end

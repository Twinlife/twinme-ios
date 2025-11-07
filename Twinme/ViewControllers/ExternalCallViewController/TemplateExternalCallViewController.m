/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Utils/NSString+Utils.h>

#import "TemplateExternalCallViewController.h"

#import "CreateExternalCallViewController.h"

#import "TemplateExternalCallCell.h"

#import <TwinmeCommon/Design.h>
#import "UITemplateExternalCall.h"
#import <TwinmeCommon/MainViewController.h>
#import <TwinmeCommon/TwinmeNavigationController.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static NSString *TEMPLATE_EXTERNAL_CALL_CELL_IDENTIFIER = @"TemplateExternalCallCellIdentifier";

//
// Interface: TemplateExternalCallViewController ()
//

@interface TemplateExternalCallViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *templatesTableView;

@property (nonatomic) NSMutableArray *uiTemplateExternalCalls;

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
        _uiTemplateExternalCalls = [[NSMutableArray alloc] init];
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
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ numberOfRowsInSection: %ld", LOG_TAG, tableView, (long)section);
    
    return self.uiTemplateExternalCalls.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
    
    return Design.CELL_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ cellForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    TemplateExternalCallCell *templateExternalCallCell = (TemplateExternalCallCell *)[tableView dequeueReusableCellWithIdentifier:TEMPLATE_EXTERNAL_CALL_CELL_IDENTIFIER];
    if (!templateExternalCallCell) {
        templateExternalCallCell = [[TemplateExternalCallCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:TEMPLATE_EXTERNAL_CALL_CELL_IDENTIFIER];
    }
    
    UITemplateExternalCall *uiTemplateExternalCall = [self.uiTemplateExternalCalls objectAtIndex:indexPath.row];
    BOOL hideSeparator = indexPath.row + 1 == self.uiTemplateExternalCalls.count ? YES : NO;
    [templateExternalCallCell bindWithTemplate:uiTemplateExternalCall hideSeparator:hideSeparator];
    
    return templateExternalCallCell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ didSelectRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    UITemplateExternalCall *uiTemplateExternalCall = [self.uiTemplateExternalCalls objectAtIndex:indexPath.row];
    CreateExternalCallViewController *createExternalCallViewController = (CreateExternalCallViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"CreateExternalCallViewController"];
    [createExternalCallViewController initWithTemplate:uiTemplateExternalCall];
    [self.navigationController pushViewController:createExternalCallViewController animated:YES];
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.definesPresentationContext = YES;
    self.view.backgroundColor = Design.WHITE_COLOR;
    
    [self setNavigationTitle:TwinmeLocalizedString(@"template_space_view_controller_template_title", nil).capitalizedString];
    
    self.templatesTableView.delegate = self;
    self.templatesTableView.dataSource = self;
    self.templatesTableView.backgroundColor = Design.WHITE_COLOR;
    self.templatesTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.templatesTableView registerNib:[UINib nibWithNibName:@"TemplateExternalCallCell" bundle:nil] forCellReuseIdentifier:TEMPLATE_EXTERNAL_CALL_CELL_IDENTIFIER];
}

- (void)initTemplates {
    DDLogVerbose(@"%@ initTemplates", LOG_TAG);
    
    self.uiTemplateExternalCalls = [[NSMutableArray alloc]init];
    [self.uiTemplateExternalCalls addObject:[[UITemplateExternalCall alloc]initWithTemplateType:TemplateExternalCallTypeMeeting]];
    [self.uiTemplateExternalCalls addObject:[[UITemplateExternalCall alloc]initWithTemplateType:TemplateExternalCallTypeClassifiedAd]];
    [self.uiTemplateExternalCalls addObject:[[UITemplateExternalCall alloc]initWithTemplateType:TemplateExternalCallTypeHelp]];
    [self.uiTemplateExternalCalls addObject:[[UITemplateExternalCall alloc]initWithTemplateType:TemplateExternalCallTypeVideoBell]];
    [self.uiTemplateExternalCalls addObject:[[UITemplateExternalCall alloc]initWithTemplateType:TemplateExternalCallTypeOther]];
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.view.backgroundColor = Design.WHITE_COLOR;
    self.templatesTableView.backgroundColor = Design.WHITE_COLOR;

    [self.templatesTableView reloadData];
}

@end

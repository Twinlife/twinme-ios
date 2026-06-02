/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinlife/TLConversationService.h>

#import <Utils/NSString+Utils.h>

#import "PollResultView.h"
#import "PollResultItem.h"
#import "UIAnnotation.h"
#import "UIPollResult.h"
#import "UIPollResultVoter.h"
#import "SettingsSectionHeaderCell.h"
#import "AnnotationInfoCell.h"

#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/UIViewController+Utils.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static NSString *HEADER_SETTINGS_CELL_IDENTIFIER = @"HeaderSettingsCellIdentifier";
static NSString *ANNOTATION_INFO_CELL_IDENTIFIER = @"AnnotationInfoCellIdentifier";

//
// Interface: PollResultView ()
//

@interface PollResultView ()<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) int selectedValue;

@property (nonatomic) NSMutableArray *results;

@end

//
// Implementation: PollResultView
//

#undef LOG_TAG
#define LOG_TAG @"PollResultView"

@implementation PollResultView

#pragma mark - UIView

- (instancetype)init {
    DDLogVerbose(@"%@ init", LOG_TAG);
    
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"PollResultView" owner:self options:nil];
    self = [objects objectAtIndex:0];
    
    self.frame = CGRectMake(0, 0, Design.DISPLAY_WIDTH, Design.DISPLAY_HEIGHT);
    
    if (self) {
        [self initViews];
    }
    return self;
}

- (void)openMenu:(NSString *)title results:(NSMutableArray *)results {
    DDLogVerbose(@"%@ openMenu", LOG_TAG);
    
    self.titleLabel.text = title;
    self.results = [self getPollResultItems:results];
    
    self.tableViewHeightConstraint.constant = Design.SETTING_CELL_HEIGHT * self.results.count;
    
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
    
    return self.results.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ cellForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    PollResultItem *item = [self.results objectAtIndex:indexPath.row];
    
    if (item.pollResultItemType == PollResultItemTypeChoice) {
        SettingsSectionHeaderCell *settingsSectionHeaderCell = (SettingsSectionHeaderCell *)[tableView dequeueReusableCellWithIdentifier:HEADER_SETTINGS_CELL_IDENTIFIER];
        if (!settingsSectionHeaderCell) {
            settingsSectionHeaderCell = [[SettingsSectionHeaderCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:HEADER_SETTINGS_CELL_IDENTIFIER];
        }
        
        [settingsSectionHeaderCell bindWithTitle:item.title backgroundColor:Design.POPUP_BACKGROUND_COLOR hideSeparator:YES uppercaseString:NO];
        
        return settingsSectionHeaderCell;
    } else {
        AnnotationInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:ANNOTATION_INFO_CELL_IDENTIFIER];
        if (!cell) {
            cell = [[AnnotationInfoCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ANNOTATION_INFO_CELL_IDENTIFIER];
        }
        
        UIAnnotation *uiAnnotation = [[UIAnnotation alloc]initWithType:TLDescriptorAnnotationTypePoll reaction:nil name:item.title avatar:item.avatar value:-1];
        BOOL hideSeparator = indexPath.row + 1 == self.results.count ? YES : NO;
        [cell bindWithAnnotation:uiAnnotation hideSeparator:hideSeparator backgroundColor:Design.POPUP_BACKGROUND_COLOR];
                
        return cell;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ didSelectRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);

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
    
    self.tableView.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"AnnotationInfoCell" bundle:nil] forCellReuseIdentifier:ANNOTATION_INFO_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsSectionHeaderCell" bundle:nil] forCellReuseIdentifier:HEADER_SETTINGS_CELL_IDENTIFIER];
}

- (void)reloadData {
    DDLogVerbose(@"%@ reloadData", LOG_TAG);
    
    [self.tableView reloadData];
    self.tableView.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
}

#pragma mark - Private methods

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    if ([self.pollResultViewDelegate respondsToSelector:@selector(cancelPollResultView:)]) {
        [self.pollResultViewDelegate cancelPollResultView:self];
    }
}

- (NSMutableArray *)getPollResultItems:(NSMutableArray *)pollResults {
    DDLogVerbose(@"%@ getPollResultItems", LOG_TAG);
    
    NSMutableArray<PollResultItem *> *items = [[NSMutableArray alloc] init];
    
    NSArray<UIPollResult *> *sortedResults = [pollResults sortedArrayUsingDescriptors:@[
        [NSSortDescriptor sortDescriptorWithKey:@"count" ascending:NO]
    ]];
    
    for (UIPollResult *pollResult in sortedResults) {
        NSString *title = [NSString stringWithFormat:@"%@ (%d)", [pollResult getChoiceLabel], pollResult.count];
        PollResultItem *pollChoiceItem = [[PollResultItem alloc] initWithType:PollResultItemTypeChoice title:title avatar:nil];
        [items addObject:pollChoiceItem];
        
        for (UIPollResultVoter *voter in pollResult.voters) {
            if (voter.name != nil) {
                PollResultItem *pollVoterItem = [[PollResultItem alloc] initWithType:PollResultItemTypeVoter title:voter.name avatar:voter.avatar];
                [items addObject:pollVoterItem];
            }
        }
    }
    
    return items;
}

@end

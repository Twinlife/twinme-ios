/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "WordCompletionView.h"
#import "WordCompletionCell.h"

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static NSString *WORD_COMPLETION_CELL_IDENTIFIER = @"WordCompletionCellIdentifier";

static const CGFloat DESIGN_WORD_HEIGHT = 80;

//
// Interface: WordCompletionView ()
//

@interface WordCompletionView ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *wordsContainerLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *wordsContainerTrailing;
@property (weak, nonatomic) IBOutlet UIView *wordsContainer;
@property (weak, nonatomic) IBOutlet UITableView *wordsTableView;

@property (nonatomic) NSArray *wordsSuggestion;

@end

//
// Implementation: WordCompletionView
//

#undef LOG_TAG
#define LOG_TAG @"WordCompletionView"

@implementation WordCompletionView

#pragma mark - UIView

- (instancetype)init {
    DDLogVerbose(@"%@ init", LOG_TAG);
    
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"WordCompletionView" owner:self options:nil];
    self = [objects objectAtIndex:0];
    
    self.frame = CGRectMake(0, 0, Design.DISPLAY_WIDTH, Design.DISPLAY_HEIGHT);
    
    if (self) {
        [self initViews];
    }
    return self;
}

- (void)setSuggestions:(NSArray *)suggestions {
    DDLogVerbose(@"%@ setSuggestions: %@", LOG_TAG, suggestions);
    
    self.wordsSuggestion = suggestions;
    
    [self.wordsTableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    DDLogVerbose(@"%@ numberOfSectionsInTableView: %@", LOG_TAG, tableView);
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
    DDLogVerbose(@"%@ tableView: %@ heightForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    return roundf(DESIGN_WORD_HEIGHT * Design.HEIGHT_RATIO);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ heightForHeaderInSection: %ld", LOG_TAG, tableView, (long)section);
    
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ heightForFooterInSection: %ld", LOG_TAG, tableView, (long)section);
    
    return CGFLOAT_MIN;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ numberOfRowsInSection: %ld", LOG_TAG, tableView, (long)section);
    
    return self.wordsSuggestion.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ cellForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    WordCompletionCell *cell = [tableView dequeueReusableCellWithIdentifier:WORD_COMPLETION_CELL_IDENTIFIER];
    if (!cell) {
        cell = [[WordCompletionCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:WORD_COMPLETION_CELL_IDENTIFIER];
    }
    
    [cell bindWithWord:[self.wordsSuggestion objectAtIndex:indexPath.row] backgroundColor:indexPath.row % 2 == 0 ? Design.WHITE_COLOR : Design.LIGHT_GREY_BACKGROUND_COLOR];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ didSelectRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
 
    if ([self.wordCompletionDelegate respondsToSelector:@selector(selectWord:)]) {
        [self.wordCompletionDelegate selectWord:[self.wordsSuggestion objectAtIndex:indexPath.row]];
    }
}

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.wordsContainerLeading.constant *= Design.WIDTH_RATIO;
    self.wordsContainerTrailing.constant *= Design.WIDTH_RATIO;
    
    self.wordsContainer.clipsToBounds = YES;
    self.wordsContainer.backgroundColor = Design.WHITE_COLOR;
    self.wordsContainer.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.wordsContainer.layer.borderWidth = 1;
    self.wordsContainer.layer.borderColor = Design.FONT_COLOR_GREY.CGColor;
    
    [self.wordsTableView registerNib:[UINib nibWithNibName:@"WordCompletionCell" bundle:nil] forCellReuseIdentifier:WORD_COMPLETION_CELL_IDENTIFIER];
    
    self.wordsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.wordsTableView.delegate = self;
    self.wordsTableView.dataSource = self;
    self.wordsTableView.backgroundColor = Design.WHITE_COLOR;
    self.wordsTableView.rowHeight =  roundf(DESIGN_WORD_HEIGHT * Design.HEIGHT_RATIO);
}

@end

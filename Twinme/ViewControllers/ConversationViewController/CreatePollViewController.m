/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "CreatePollViewController.h"

#import "PollHeaderCell.h"
#import "PollFooterCell.h"
#import "PollAddChoiceCell.h"
#import "UIPollChoice.h"

#import <Utils/NSString+Utils.h>

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

#define LIMIT_CHOICE 10

static NSString *POLL_HEADER_CELL_IDENTIFIER = @"PollHeaderCellIdentifier";
static NSString *POLL_FOOTER_CELL_IDENTIFIER = @"PollFooterCellIdentifier";
static NSString *POLL_ADD_CHOICE_CELL_IDENTIFIER = @"PollAddChoiceCellIdentifier";

static CGFloat DESIGN_HEADER_HEIGHT = 240;
static CGFloat DESIGN_CHOICE_HEIGHT = 160;

//
// Interface: CreatePollViewController ()
//

@interface CreatePollViewController ()<UITableViewDelegate, UITableViewDataSource, PollHeaderCellDelegate, PollAddChoiceCellDelegate, PollFooterCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) UIBarButtonItem *saveBarButtonItem;
@property (nonatomic) NSMutableArray<UIPollChoice *> *pollChoices;

@property (nonatomic) NSString *question;
@property (nonatomic) BOOL allowMultipleChoice;

@property (nonatomic) BOOL keyboardHidden;
@property (nonatomic) BOOL canSavePoll;
@property (nonatomic) BOOL editQuestion;

@end

//
// Implementation: CreatePollViewController
//

#undef LOG_TAG
#define LOG_TAG @"CreatePollViewController"

@implementation CreatePollViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _pollChoices = [[NSMutableArray alloc]init];
        _allowMultipleChoice = YES;
        _canSavePoll = NO;
        _question = @"";
        _keyboardHidden = YES;
        _editQuestion = YES;
    }
    return self;
}

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
    
    [self.pollChoices addObject:[[UIPollChoice alloc] initWithPosition:0 choice:@""]];
    [self.pollChoices addObject:[[UIPollChoice alloc] initWithPosition:1 choice:@""]];
    
    [self initViews];
}

- (void)viewWillAppear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillAppear: %@", LOG_TAG, animated ? @"YES" : @"NO");
    
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillDisappear: %@", LOG_TAG, animated ? @"YES" : @"NO");
    
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    DDLogVerbose(@"%@ keyboardWillShow: %@", LOG_TAG, notification);
    
    if (!self.keyboardHidden) {
        return;
    }
    
    self.keyboardHidden = NO;
    NSDictionary *info = [notification userInfo];
    CGRect keyboardFrame = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect keyboardFrameInView = [self.view convertRect:keyboardFrame fromView:nil];
    CGFloat keyboardHeight = MAX(0, CGRectGetMaxY(self.view.bounds) - CGRectGetMinY(keyboardFrameInView));
    UIEdgeInsets contentInset = self.tableView.contentInset;
    contentInset.bottom = keyboardHeight;
    self.tableView.contentInset = contentInset;
    self.tableView.scrollIndicatorInsets = contentInset;
    
    if ([self.twinmeApplication getDefaultKeyboardHeight] != keyboardHeight) {
        [self.twinmeApplication setDefaultKeyboardHeight:keyboardHeight];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    DDLogVerbose(@"%@ keyboardWillHide: %@", LOG_TAG, notification);
    
    self.keyboardHidden = YES;
    
    UIEdgeInsets contentInset = self.tableView.contentInset;
    contentInset.bottom = 0;
    self.tableView.contentInset = contentInset;
    self.tableView.scrollIndicatorInsets = contentInset;
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification {
    DDLogVerbose(@"%@ keyboardWillChangeFrame: %@", LOG_TAG, notification);
    
    NSDictionary *info = [notification userInfo];
    CGRect keyboardFrame = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect keyboardFrameInView = [self.view convertRect:keyboardFrame fromView:nil];
    CGFloat keyboardHeight = MAX(0, CGRectGetMaxY(self.view.bounds) - CGRectGetMinY(keyboardFrameInView));
    UIEdgeInsets contentInset = self.tableView.contentInset;
    contentInset.bottom = keyboardHeight;
    self.tableView.contentInset = contentInset;
    self.tableView.scrollIndicatorInsets = contentInset;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    DDLogVerbose(@"%@ numberOfSectionsInTableView: %@", LOG_TAG, tableView);
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
    DDLogVerbose(@"%@ tableView: %@ heightForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
        
    if (indexPath.row >= self.pollChoices.count) {
        return Design.CELL_HEIGHT;
    }
    return roundf(DESIGN_CHOICE_HEIGHT * Design.HEIGHT_RATIO);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ heightForHeaderInSection: %ld", LOG_TAG, tableView, (long)section);
    
    return roundf(DESIGN_HEADER_HEIGHT * Design.HEIGHT_RATIO);
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ heightForFooterInSection: %ld", LOG_TAG, tableView, (long)section);
    
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ viewForHeaderInSection: %ld", LOG_TAG, tableView, (long)section);
    
    PollHeaderCell *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:POLL_HEADER_CELL_IDENTIFIER];
    if (!header) {
        header = [[PollHeaderCell alloc] initWithReuseIdentifier:POLL_HEADER_CELL_IDENTIFIER];
    }
    
    header.pollHeaderCellDelegate = self;
    [header bind:self.question allowMultipleChoice:self.allowMultipleChoice beginEditing:self.editQuestion];
    self.editQuestion = NO;
    
    return header;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ numberOfRowsInSection: %ld", LOG_TAG, tableView, (long)section);
    
    return self.pollChoices.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ cellForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if (indexPath.row < self.pollChoices.count) {
        PollAddChoiceCell *cell = [tableView dequeueReusableCellWithIdentifier:POLL_ADD_CHOICE_CELL_IDENTIFIER];
        if (!cell) {
            cell = [[PollAddChoiceCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:POLL_ADD_CHOICE_CELL_IDENTIFIER];
        }
            
        cell.pollAddChoiceCellDelegate = self;
        [cell bindWithChoice:self.pollChoices[indexPath.row]];
        
        return cell;
    } else {
        PollFooterCell *cell = [tableView dequeueReusableCellWithIdentifier:POLL_FOOTER_CELL_IDENTIFIER];
        if (!cell) {
            cell = [[PollFooterCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:POLL_FOOTER_CELL_IDENTIFIER];
        }

        cell.pollFooterCellDelegate = self;
        BOOL canAddChoice = self.pollChoices.count < LIMIT_CHOICE && [self countValidChoices] == self.pollChoices.count;
        [cell bind:canAddChoice];
        
        return cell;
    }
    
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ didSelectRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
}

#pragma mark - PollHeaderCellDelegate

- (void)didUpdateQuestion:(nonnull NSString *)text {
    DDLogVerbose(@"%@ didUpdateQuestion: %@", LOG_TAG, text);
    
    self.question = text;
    
    [self setUpdated];
    [self updateViews];
}

- (void)didUpdateAllowMultipleChoice:(BOOL)allowMutlipleChoice {
    DDLogVerbose(@"%@ didUpdateAllowMultipleChoice: %@", LOG_TAG, allowMutlipleChoice ? @"YES" : @"NO");
    
    self.allowMultipleChoice = allowMutlipleChoice;
}

- (void)didEndEditing:(NSString *)text {
    DDLogVerbose(@"%@ didEndEditing: %@", LOG_TAG, text);
    
    self.question = text;
    for (UIPollChoice *pollChoice in self.pollChoices) {
        pollChoice.isSelected = NO;
    }
    UIPollChoice *firstChoice = [self.pollChoices firstObject];
    firstChoice.isSelected = YES;
    
    [self setUpdated];
    [self updateViews];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - PollAddChoiceCellDelegate

- (void)didUpdateChoice:(UIPollChoice *)pollChoice text:(NSString *)text {
    DDLogVerbose(@"%@ didUpdateChoice: %@ text: %@", LOG_TAG, pollChoice, text);
 
    UIPollChoice *pollChoiceToUpdate = [self.pollChoices objectAtIndex:pollChoice.position];
    pollChoiceToUpdate.choice = text;
    pollChoiceToUpdate.isSelected = YES;
        
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.pollChoices.count inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    [self setUpdated];
    [self updateViews];
}

- (void)didEndEditingChoice:(UIPollChoice *)pollChoice {
    DDLogVerbose(@"%@ didReturnChoice: %@", LOG_TAG, pollChoice);
    
    UIPollChoice *pollChoiceToUpdate = [self.pollChoices objectAtIndex:pollChoice.position];
    if (pollChoiceToUpdate.isSelected) {
        pollChoiceToUpdate.isSelected = NO;
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:pollChoiceToUpdate.position inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)didReturnChoice:(UIPollChoice *)pollChoice {
    DDLogVerbose(@"%@ didReturnChoice: %@", LOG_TAG, pollChoice);
            
    UIPollChoice *pollChoiceToUpdate = [self.pollChoices objectAtIndex:pollChoice.position];
    pollChoiceToUpdate.isSelected = NO;
    
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:pollChoiceToUpdate.position inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    
    if (pollChoice.position + 1 < self.pollChoices.count) {
        UIPollChoice *nextPollChoice = [self.pollChoices objectAtIndex:pollChoice.position + 1];
        nextPollChoice.isSelected = YES;
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:nextPollChoice.position inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    } else if (pollChoice.position + 1 == self.pollChoices.count) {
        [self didTapPollFooter];
    }
}

#pragma mark - PollFooterCellDelegate

- (void)didTapPollFooter {
    DDLogVerbose(@"%@ didTapPollFooter", LOG_TAG);
    
    if (self.pollChoices.count < LIMIT_CHOICE) {
        [self hapticFeedBack:UIImpactFeedbackStyleHeavy];
                
        int indexToUpdate = -1;
        for (UIPollChoice *pollChoice in self.pollChoices) {
            if (pollChoice.isSelected) {
                indexToUpdate = pollChoice.position;
            }
            pollChoice.isSelected = NO;
        }
        
        if (indexToUpdate != -1) {
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexToUpdate inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }
        
        UIPollChoice *pollChoice = [[UIPollChoice alloc] initWithPosition:(int)self.pollChoices.count choice:@""];
        pollChoice.isSelected = YES;
        
        [self.pollChoices addObject:pollChoice];
        [CATransaction begin];
        [CATransaction setCompletionBlock:^{
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.pollChoices.count inSection:0];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView scrollToRowAtIndexPath:indexPath
                                  atScrollPosition:UITableViewScrollPositionBottom
                                          animated:YES];
        }];

        [self.tableView beginUpdates];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.pollChoices.count - 1 inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];

        [CATransaction commit];
    }
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.view.backgroundColor = Design.WHITE_COLOR;
    
    [self setNavigationTitle:TwinmeLocalizedString(@"poll_view_title", nil)];
    
    UIBarButtonItem *cancelBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:TwinmeLocalizedString(@"application_cancel", nil) style:UIBarButtonItemStylePlain target:self action:@selector(cancelPoll:)];
    [cancelBarButtonItem setTitleTextAttributes: @{NSFontAttributeName: Design.FONT_BOLD36, NSForegroundColorAttributeName: [UIColor whiteColor]} forState:UIControlStateNormal];
    [cancelBarButtonItem setTitleTextAttributes: @{NSFontAttributeName: Design.FONT_BOLD36, NSForegroundColorAttributeName: [UIColor colorWithWhite:1.0 alpha:0.5]} forState:UIControlStateDisabled];
    self.navigationItem.leftBarButtonItem = cancelBarButtonItem;
    
    self.saveBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:TwinmeLocalizedString(@"create_group_view_create", nil) style:UIBarButtonItemStylePlain target:self action:@selector(createPoll:)];
    [self.saveBarButtonItem setTitleTextAttributes: @{NSFontAttributeName: Design.FONT_BOLD36, NSForegroundColorAttributeName: [UIColor whiteColor]} forState:UIControlStateNormal];
    [self.saveBarButtonItem setTitleTextAttributes: @{NSFontAttributeName: Design.FONT_BOLD36, NSForegroundColorAttributeName: [UIColor colorWithWhite:1.0 alpha:0.5]} forState:UIControlStateDisabled];
    self.saveBarButtonItem.enabled = NO;
    self.navigationItem.rightBarButtonItem = self.saveBarButtonItem;
    
    self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = Design.WHITE_COLOR;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PollHeaderCell" bundle:nil] forHeaderFooterViewReuseIdentifier:POLL_HEADER_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"PollAddChoiceCell" bundle:nil] forCellReuseIdentifier:POLL_ADD_CHOICE_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"PollFooterCell" bundle:nil] forCellReuseIdentifier:POLL_FOOTER_CELL_IDENTIFIER];

}

- (IBAction)cancelPoll:(UIButton *)sender {
    DDLogVerbose(@"%@ cancelPoll: %@", LOG_TAG, sender);
    
    [self finish];
}

- (void)createPoll:(UIButton *)sender {
    DDLogVerbose(@"%@ createPoll: %@", LOG_TAG, sender);
    
    if (!self.canSavePoll) {
        return;
    }
    
    NSMutableArray<TLChoice *> *choices = [NSMutableArray array];
    
    int position = 0;
    for (UIPollChoice *pollChoice in self.pollChoices) {
        if ([pollChoice.choice stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0) {
            TLChoice *choice = [[TLChoice alloc] initWithPosition:position label:pollChoice.choice];
            [choices addObject:choice];
            position++;
        }
    }
    
    [self.delegate createPollWithMultipleAnswersAllowed:self.allowMultipleChoice question:self.question choices:choices];
    
    [self finish];
}

- (void)setUpdated {
    DDLogVerbose(@"%@ setUpdated", LOG_TAG);
    
    self.canSavePoll = NO;
    
    if ([self.question stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
        return;
    }
    
    if ([self countValidChoices] < 2) {
        return;
    }
    
    self.canSavePoll = YES;
}

- (void)updateViews {
    DDLogVerbose(@"%@ updateViews", LOG_TAG);
    
    if (self.canSavePoll) {
        self.saveBarButtonItem.enabled = YES;
    } else {
        self.saveBarButtonItem.enabled = NO;
    }
}

- (int)countValidChoices {
    DDLogVerbose(@"%@ countValidChoices", LOG_TAG);
    
    int validChoices = 0;
    for (UIPollChoice *pollChoice in self.pollChoices) {
        if ([pollChoice.choice stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0) {
            validChoices++;
        }
    }
    
    return validChoices;
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    [self.tableView reloadData];
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.view.backgroundColor = Design.WHITE_COLOR;
    self.tableView.backgroundColor = Design.WHITE_COLOR;
}

@end

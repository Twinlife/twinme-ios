/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "MenuActionConversationView.h"
#import "MenuActionConversationCell.h"
#import "UIActionConversation.h"

#import <TwinmeCommon/ApplicationDelegate.h>
#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/TwinmeApplication.h>

#import "UIView+GradientBackgroundColor.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static CGFloat DESIGN_HEADER_HEIGHT = 80.f;
static CGFloat OFFSET_VISIBILITY_DELAY = 0.05f;

static NSString *MENU_ACTION_CONVERSATION_CELL_IDENTIFIER = @"MenuActionConversationCellIdentifier";

//
// Interface: MenuActionConversationView ()
//

@interface MenuActionConversationView () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) UIVisualEffectView *visualEffectView;

@property (nonatomic) NSMutableArray *actions;
@property (nonatomic) BOOL startCellAnimation;

@end

//
// Implementation: MenuActionConversationView
//

#undef LOG_TAG
#define LOG_TAG @"MenuActionConversationView"

@implementation MenuActionConversationView

#pragma mark - UIView

- (instancetype)init {
    DDLogVerbose(@"%@ init", LOG_TAG);
    
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"MenuActionConversationView" owner:self options:nil];
    self = [objects objectAtIndex:0];
    
    self.frame = CGRectMake(0, 0, Design.DISPLAY_WIDTH, Design.DISPLAY_HEIGHT);
    
    if (self) {
        _startCellAnimation = NO;
        [self initViews];
    }
    return self;
}

- (void)initWithActions {
    DDLogVerbose(@"%@ initWithActions", LOG_TAG);
    
    self.actions = [[NSMutableArray alloc]init];
    
    [self.actions addObject:[[UIActionConversation alloc]initWithConversationActionType:ConversationActionTypeCamera]];
    [self.actions addObject:[[UIActionConversation alloc]initWithConversationActionType:ConversationActionTypeGallery]];
    [self.actions addObject:[[UIActionConversation alloc]initWithConversationActionType:ConversationActionTypeFile]];
    [self.actions addObject:[[UIActionConversation alloc]initWithConversationActionType:ConversationActionTypeMediasAndFiles]];
    [self.actions addObject:[[UIActionConversation alloc]initWithConversationActionType:ConversationActionTypeManageConversation]];
    [self.actions addObject:[[UIActionConversation alloc]initWithConversationActionType:ConversationActionTypeReset]];
}

- (void)openMenu {
    DDLogVerbose(@"%@ openMenu", LOG_TAG);
        
    self.hidden = NO;

    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.visualEffectView.alpha = 1.0f;
     } completion:^(BOOL finished) {
         self.startCellAnimation = YES;
         [self.tableView reloadData];
     }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    DDLogVerbose(@"%@ numberOfSectionsInTableView: %@", LOG_TAG, tableView);
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return DESIGN_HEADER_HEIGHT * Design.HEIGHT_RATIO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
    DDLogVerbose(@"%@ tableView: %@ heightForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    return Design.CELL_HEIGHT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ numberOfRowsInSection: %ld", LOG_TAG, tableView, (long)section);
    
    if (self.startCellAnimation) {
        return self.actions.count;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ cellForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    MenuActionConversationCell *cell = [tableView dequeueReusableCellWithIdentifier:MENU_ACTION_CONVERSATION_CELL_IDENTIFIER];
    if (!cell) {
        cell = [[MenuActionConversationCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:MENU_ACTION_CONVERSATION_CELL_IDENTIFIER];
    }
    
    cell.contentView.transform = CGAffineTransformMakeScale(1, -1);
    
    CGFloat delay = OFFSET_VISIBILITY_DELAY * indexPath.row;
    UIActionConversation *actionConversation = [self.actions objectAtIndex:indexPath.row];
    [cell bindWithAction:actionConversation delay:delay];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ didSelectRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if ([self.menuActionConversationDelegate respondsToSelector:@selector(didSelectAction:)]) {
        UIActionConversation *actionConversation = [self.actions objectAtIndex:indexPath.row];
        [self.menuActionConversationDelegate didSelectAction:actionConversation];
        [self resetAnimation];
    }
}

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.backgroundColor = [UIColor clearColor];
    
    UIColor *gradientColorStart = Design.WHITE_COLOR;
    UIColor *gradientColorEnd = Design.WHITE_COLOR_20_OPACITY;
    
    if ([[UIApplication sharedApplication] userInterfaceLayoutDirection] == UIUserInterfaceLayoutDirectionLeftToRight) {
        [self setupGradientBackgroundFromColors:@[(id)gradientColorStart.CGColor, (id)gradientColorEnd.CGColor] opacity:1.0 orientation:GradientOrientationHorizontal];
    } else {
        [self setupGradientBackgroundFromColors:@[(id)gradientColorEnd.CGColor, (id)gradientColorStart.CGColor] opacity:1.0 orientation:GradientOrientationHorizontal];
    }
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    
    ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
    TwinmeApplication *twinmeApplication = [delegate twinmeApplication];
    
    if ([twinmeApplication darkModeEnable]) {
        blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    }
    
    self.visualEffectView = [[UIVisualEffectView alloc]initWithEffect:blurEffect];
    self.visualEffectView.userInteractionEnabled = YES;
    self.visualEffectView.frame = CGRectMake(0, 0, Design.DISPLAY_WIDTH, Design.DISPLAY_HEIGHT);
    self.visualEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.visualEffectView.alpha = 0.f;
    [self.tableView setBackgroundView:self.visualEffectView];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCloseMenu:)];
    [self.visualEffectView addGestureRecognizer:tapGestureRecognizer];
        
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.scrollEnabled = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"MenuActionConversationCell" bundle:nil] forCellReuseIdentifier:MENU_ACTION_CONVERSATION_CELL_IDENTIFIER];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.transform = CGAffineTransformMakeScale(1, -1);
    
    [self initWithActions];
}

- (void)handleCloseMenu:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleCloseMenu: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        if ([self.menuActionConversationDelegate respondsToSelector:@selector(cancelMenuAction)]) {
            [self.menuActionConversationDelegate cancelMenuAction];
            [self resetAnimation];
        }
    }
}

- (void)resetAnimation {
    DDLogVerbose(@"%@ resetAnimation", LOG_TAG);
    
    self.visualEffectView.alpha = 0.f;
    self.startCellAnimation = NO;
    [self.tableView reloadData];
}

@end

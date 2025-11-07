/*
 *  Copyright (c) 2019-2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Utils/NSString+Utils.h>

#import "MenuItemView.h"
#import "UIMenuItemAction.h"
#import "MenuItemCell.h"

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static const CGFloat DESIGN_MENU_VIEW_HEIGHT = 260;
static const CGFloat DESIGN_MENU_CELL_HEIGHT = 90;
static const CGFloat DESIGN_LEADING_MENU = 96;
static const CGFloat DESIGN_TRAILING_MENU = 52;

static UIColor* NOT_ALLOWED_COPY_COLOR;

static NSString *MENU_ITEM_CELL_IDENTIFIER = @"MenuItemCellIdentifier";

//
// Interface: MenuItemView ()
//

@interface MenuItemView ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *menuTableViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *menuTableViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *menuTableViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UITableView *menuTableView;

@property (nonatomic) Item *item;
@property (nonatomic) BOOL enableAction;
@property (nonatomic) BOOL canEditMessage;
@property (nonatomic) MenuType menuType;
@property (nonatomic) NSMutableArray *actionsArray;

@end

//
// Implementation: MenuItemView
//

#undef LOG_TAG
#define LOG_TAG @"MenuItemView"

@implementation MenuItemView

#pragma mark - UIView

- (instancetype)init {
    DDLogVerbose(@"%@ init", LOG_TAG);
    
    self = [super init];
    
    self.frame = CGRectMake(0, 0, Design.DISPLAY_WIDTH, DESIGN_MENU_VIEW_HEIGHT * Design.HEIGHT_RATIO);
    
    self.actionsArray = [[NSMutableArray alloc]init];
    self.enableAction = YES;
    self.canEditMessage = YES;
    if (self) {
        [self initViews];
    }
    
    return self;
}

- (void)setEditMessage:(BOOL)edit {
    DDLogVerbose(@"%@ setEditMessage: %@", LOG_TAG, edit ? @"YES" : @"NO");
    
    self.canEditMessage = edit;
}

- (void)openMenu:(Item *)item menuType:(MenuType)menuType {
    DDLogVerbose(@"%@ openMenu: %@ menuType: %d", LOG_TAG, item, menuType);
    
    self.item = item;
    self.menuType = menuType;
    [self.actionsArray removeAllObjects];
    
    if (self.item.state == ItemStateDeleted || [self.item isClearLocalItem] || (self.item.isPeerItem && (!self.item.copyAllowed || !self.item.isAvailableItem || self.item.isEphemeralItem))) {
        self.enableAction = NO;
    } else {
        self.enableAction = YES;
    }
    
    if (self.item.isPeerItem) {
        self.menuTableViewLeadingConstraint.constant = DESIGN_LEADING_MENU * Design.WIDTH_RATIO;
    } else {
        self.menuTableViewLeadingConstraint.constant = Design.DISPLAY_WIDTH - (self.menuTableViewWidthConstraint.constant + DESIGN_TRAILING_MENU * Design.WIDTH_RATIO);
    }
    
    switch (menuType) {
        case MenuTypeText:
            [self.actionsArray addObject:[[UIMenuItemAction alloc]initWithTitle:TwinmeLocalizedString(@"conversation_view_controller_menu_item_view_info_title", nil) image:[UIImage imageNamed:@"InfoItem"] actionType:ActionTypeInfo]];
            
            if (!self.item.isPeerItem && self.canEditMessage) {
                [self.actionsArray addObject:[[UIMenuItemAction alloc]initWithTitle:TwinmeLocalizedString(@"application_edit", nil) image:[UIImage imageNamed:@"EditMessageIcon"] actionType:ActionTypeEdit]];
            }
            
            [self.actionsArray addObject:[[UIMenuItemAction alloc]initWithTitle:TwinmeLocalizedString(@"conversation_view_controller_menu_item_view_reply_title", nil) image:[UIImage imageNamed:@"ReplyItem"] actionType:ActionTypeReply]];
            [self.actionsArray addObject:[[UIMenuItemAction alloc]initWithTitle:TwinmeLocalizedString(@"conversation_view_controller_menu_item_view_forward_title", nil) image:[UIImage imageNamed:@"ForwardItem"] actionType:ActionTypeForward]];
            [self.actionsArray addObject:[[UIMenuItemAction alloc]initWithTitle:TwinmeLocalizedString(@"conversation_view_controller_menu_item_view_share_title", nil) image:[UIImage imageNamed:@"ShareItem"] actionType:ActionTypeShare]];
            [self.actionsArray addObject:[[UIMenuItemAction alloc]initWithTitle:TwinmeLocalizedString(@"conversation_view_controller_menu_item_view_copy_title", nil) image:[UIImage imageNamed:@"CopyItem"] actionType:ActionTypeCopy]];
            [self.actionsArray addObject:[[UIMenuItemAction alloc]initWithTitle:TwinmeLocalizedString(@"conversation_view_controller_menu_item_view_delete_title", nil) image:[UIImage imageNamed:@"ToolbarTrash"] actionType:ActionTypeDelete]];
            [self.actionsArray addObject:[[UIMenuItemAction alloc]initWithTitle:TwinmeLocalizedString(@"application_select_more", nil) image:[UIImage imageNamed:@"SelectMoreItem"] actionType:ActionTypeSelectMore]];
            break;
            
        case MenuTypeImage:
        case MenuTypeVideo:
        case MenuTypeAudio:
        case MenuTypeFile:
            [self.actionsArray addObject:[[UIMenuItemAction alloc]initWithTitle:TwinmeLocalizedString(@"conversation_view_controller_menu_item_view_info_title", nil) image:[UIImage imageNamed:@"InfoItem"] actionType:ActionTypeInfo]];
            [self.actionsArray addObject:[[UIMenuItemAction alloc]initWithTitle:TwinmeLocalizedString(@"conversation_view_controller_menu_item_view_reply_title", nil) image:[UIImage imageNamed:@"ReplyItem"] actionType:ActionTypeReply]];
            [self.actionsArray addObject:[[UIMenuItemAction alloc]initWithTitle:TwinmeLocalizedString(@"conversation_view_controller_menu_item_view_forward_title", nil) image:[UIImage imageNamed:@"ForwardItem"] actionType:ActionTypeForward]];
            [self.actionsArray addObject:[[UIMenuItemAction alloc]initWithTitle:TwinmeLocalizedString(@"conversation_view_controller_menu_item_view_share_title", nil) image:[UIImage imageNamed:@"ShareItem"] actionType:ActionTypeShare]];
            [self.actionsArray addObject:[[UIMenuItemAction alloc]initWithTitle:TwinmeLocalizedString(@"conversation_view_controller_menu_item_view_save_title", nil) image:[UIImage imageNamed:@"SaveItem"] actionType:ActionTypeSave]];
            [self.actionsArray addObject:[[UIMenuItemAction alloc]initWithTitle:TwinmeLocalizedString(@"conversation_view_controller_menu_item_view_delete_title", nil) image:[UIImage imageNamed:@"ToolbarTrash"] actionType:ActionTypeDelete]];
            [self.actionsArray addObject:[[UIMenuItemAction alloc]initWithTitle:TwinmeLocalizedString(@"application_select_more", nil) image:[UIImage imageNamed:@"SelectMoreItem"] actionType:ActionTypeSelectMore]];
            break;
            
        case MenuTypeInvitation:
        case MenuTypeCall:
        case MenuTypeClear:
            [self.actionsArray addObject:[[UIMenuItemAction alloc]initWithTitle:TwinmeLocalizedString(@"conversation_view_controller_menu_item_view_info_title", nil) image:[UIImage imageNamed:@"InfoItem"] actionType:ActionTypeInfo]];
            [self.actionsArray addObject:[[UIMenuItemAction alloc]initWithTitle:TwinmeLocalizedString(@"conversation_view_controller_menu_item_view_delete_title", nil) image:[UIImage imageNamed:@"ToolbarTrash"] actionType:ActionTypeDelete]];
            [self.actionsArray addObject:[[UIMenuItemAction alloc]initWithTitle:TwinmeLocalizedString(@"application_select_more", nil) image:[UIImage imageNamed:@"SelectMoreItem"] actionType:ActionTypeSelectMore]];
            break;
            
        case MenuTypeLocation:
            [self.actionsArray addObject:[[UIMenuItemAction alloc]initWithTitle:TwinmeLocalizedString(@"conversation_view_controller_menu_item_view_info_title", nil) image:[UIImage imageNamed:@"InfoItem"] actionType:ActionTypeInfo]];
            [self.actionsArray addObject:[[UIMenuItemAction alloc]initWithTitle:TwinmeLocalizedString(@"conversation_view_controller_menu_item_view_reply_title", nil) image:[UIImage imageNamed:@"ReplyItem"] actionType:ActionTypeReply]];
            [self.actionsArray addObject:[[UIMenuItemAction alloc]initWithTitle:TwinmeLocalizedString(@"conversation_view_controller_menu_item_view_delete_title", nil) image:[UIImage imageNamed:@"ToolbarTrash"] actionType:ActionTypeDelete]];
            [self.actionsArray addObject:[[UIMenuItemAction alloc]initWithTitle:TwinmeLocalizedString(@"application_select_more", nil) image:[UIImage imageNamed:@"SelectMoreItem"] actionType:ActionTypeSelectMore]];
            break;
            
        default:
            break;
    }
    
    CGRect menuFrame = self.frame;
    menuFrame.size.height = self.actionsArray.count * (DESIGN_MENU_CELL_HEIGHT * Design.HEIGHT_RATIO);
    self.frame = menuFrame;
        
    [self updateColor];
    [self.menuTableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    DDLogVerbose(@"%@ numberOfSectionsInTableView: %@", LOG_TAG, tableView);
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
    DDLogVerbose(@"%@ tableView: %@ heightForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    return round(DESIGN_MENU_CELL_HEIGHT * Design.HEIGHT_RATIO);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ numberOfRowsInSection: %ld", LOG_TAG, tableView, (long)section);
    
    return self.actionsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ cellForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    MenuItemCell *cell = [tableView dequeueReusableCellWithIdentifier:MENU_ITEM_CELL_IDENTIFIER];
    if (!cell) {
        cell = [[MenuItemCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:MENU_ITEM_CELL_IDENTIFIER];
    }
    
    UIMenuItemAction *menuItemAction = [self.actionsArray objectAtIndex:indexPath.row];
    
    BOOL enable = self.enableAction;
    if (menuItemAction.actionType == ActionTypeInfo || menuItemAction.actionType == ActionTypeSelectMore || ((menuItemAction.actionType == ActionTypeDelete || menuItemAction.actionType == ActionTypeReply) && self.item.state != ItemStateDeleted)) {
        enable = YES;
    }
    
    BOOL hideSeparator = indexPath.row + 1 == self.actionsArray.count ? YES : NO;
    [cell bindWithMenuItem:menuItemAction enabled:enable hideSeparator:hideSeparator];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ didSelectRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    UIMenuItemAction *menuItemAction = [self.actionsArray objectAtIndex:indexPath.row];
    
    switch (menuItemAction.actionType) {
        case ActionTypeCopy:
            [self.menuItemDelegate copyItemClick];
            break;
            
        case ActionTypeEdit:
            [self.menuItemDelegate editItemClick];
            break;
            
        case ActionTypeDelete:
            [self.menuItemDelegate deleteItemClick];
            break;
            
        case ActionTypeForward:
            [self.menuItemDelegate forwardItemClick];
            break;
            
        case ActionTypeInfo:
            [self.menuItemDelegate infoItemClick];
            break;
            
        case ActionTypeReply:
            [self.menuItemDelegate replyItemClick];
            break;
            
        case ActionTypeSave:
            [self.menuItemDelegate saveItemClick];
            break;
            
        case ActionTypeShare:
            [self.menuItemDelegate shareItemClick];
            break;
            
        case ActionTypeSelectMore:
            [self.menuItemDelegate selectMoreItemClick];
            break;
            
        default:
            break;
    }
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"MenuItemView" owner:self options:nil];
    UIView *view = [objects objectAtIndex:0];
    view.frame = CGRectMake(0, 0, Design.DISPLAY_WIDTH, DESIGN_MENU_VIEW_HEIGHT * Design.HEIGHT_RATIO);
    [self addSubview:[objects objectAtIndex:0]];
    
    self.menuTableViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.menuTableViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.menuTableViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.menuTableView.clipsToBounds = YES;
    self.menuTableView.layer.cornerRadius = 12.0;
    self.menuTableView.delegate = self;
    self.menuTableView.dataSource = self;
    self.menuTableView.scrollEnabled = NO;
    self.menuTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.menuTableView registerNib:[UINib nibWithNibName:@"MenuItemCell" bundle:nil] forCellReuseIdentifier:MENU_ITEM_CELL_IDENTIFIER];
    self.menuTableView.backgroundColor = Design.MENU_BACKGROUND_COLOR;
}

- (void)updateColor {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.menuTableView.backgroundColor = Design.MENU_BACKGROUND_COLOR;
}

@end

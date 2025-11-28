/*
 *  Copyright (c) 2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "CallConversationView.h"

#import "CallMessageCell.h"
#import "CallNameCell.h"
#import "CallPeerMessageCell.h"
#import "NameItem.h"
#import "MessageItem.h"
#import "PeerMessageItem.h"

#import <TwinmeCommon/Design.h>

#import <Utils/NSString+Utils.h>

static const CGFloat DESIGN_CORNER_RADIUS = 14;
static const CGFloat DESIGN_MIN_MARGIN_ACTION = 34;
static const CGFloat DESIGN_SMALL_ROUND_CORNER_RADIUS = 8;
static const CGFloat DESIGN_LARGE_ROUND_CORNER_RADIUS = 38;
static const CGFloat DESIGN_TOP_MARGIN1 = 4;
static const CGFloat DESIGN_TOP_MARGIN2 = 18;
static const CGFloat DESIGN_BOTTOM_MARGIN1 = 4;
static const CGFloat DESIGN_BOTTOM_MARGIN2 = 18;
static const CGFloat DESIGN_HEIGHT_INSET = 24;

static NSString *CALL_MESSAGE_CELL_IDENTIFIER = @"CallMessageCellIdentifier";
static NSString *CALL_NAME_CELL_IDENTIFIER = @"CallNameCellIdentifier";
static NSString *CALL_PEER_MESSAGE_CELL_IDENTIFIER = @"CallPeerMessageCellIdentifier";

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: CallConversationView ()
//

@interface CallConversationView()<UITableViewDelegate, UITableViewDataSource, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sendMessageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sendMessageViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *sendMessageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerMessageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerMessageViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerMessageViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerMessageViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *containerMessageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageTextViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageTextViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageTextViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageTextViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sendViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *sendView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sendImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *sendImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *closeImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *closeView;

@property (nonatomic) NSMutableArray *items;

@property (nonatomic) CGFloat smallRadius;
@property (nonatomic) CGFloat largeRadius;
@property (nonatomic) CGFloat topMargin1;
@property (nonatomic) CGFloat topMargin2;
@property (nonatomic) CGFloat bottomMargin1;
@property (nonatomic) CGFloat bottomMargin2;

@end

//
// Implementation: CallConversationView
//

#undef LOG_TAG
#define LOG_TAG @"CallConversationView"

@implementation CallConversationView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    DDLogVerbose(@"%@ initWithCoder", LOG_TAG);
    
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        UIView *callConversationView = [[[NSBundle mainBundle] loadNibNamed:@"CallConversationView" owner:self options:nil] objectAtIndex:0];
        callConversationView.frame = self.bounds;
        callConversationView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:callConversationView];
        _items = [[NSMutableArray alloc]init];
        [self initViews];
    }
    
    return self;
}

- (void)addDescriptor:(TLDescriptor *)descriptor isLocal:(BOOL)isLocal needsReload:(BOOL)needsReload name:(NSString *)name {
    DDLogVerbose(@"%@ addDescriptor: %@", LOG_TAG, descriptor);
    
    if (descriptor.getType != TLDescriptorTypeObjectDescriptor) {
        return;
    }
    
    TLObjectDescriptor *objectDescriptor = (TLObjectDescriptor *)descriptor;
    
    if (isLocal) {
        MessageItem *messageItem = [[MessageItem alloc] initWithObjectDescriptor:objectDescriptor replyToDescriptor:nil];
        [self addItem:messageItem name:nil];
    } else {
        PeerMessageItem *peerMessageItem = [[PeerMessageItem alloc] initWithObjectDescriptor:objectDescriptor replyToDescriptor:nil];
        [self addItem:peerMessageItem name:name];
    }
    
    if (needsReload) {
        [self reloadData];
    }
}

- (void)addItem:(Item *)item name:(NSString *)name {
    DDLogVerbose(@"%@ addItem: %@", LOG_TAG, item);
    
    if (self.items.count == 0) {
        if ([item isPeerItem]) {
            NameItem *nameItem = [[NameItem alloc]initWithTimestamp:0 name:name];
            [self.items addObject:nameItem];
        }
        [self.items addObject:item];
        return;
    }
    
    Item *previousItem = [self.items lastObject];
    if (previousItem) {
        if (![item isPeerItem]) {
            if (!previousItem.isPeerItem) {
                previousItem.corners &= ~ITEM_BOTTOM_RIGHT;
                item.corners &= ~ITEM_TOP_RIGHT;
            } else {
                previousItem.corners |= ITEM_BOTTOM_LEFT;
                item.corners |= ITEM_TOP_RIGHT;
            }
        } else {
            item.visibleAvatar = YES;
            if (!previousItem.isPeerItem) {
                previousItem.corners |= ITEM_BOTTOM_RIGHT;
                item.corners |= ITEM_TOP_LEFT;
            } else {
                previousItem.corners &= ~ITEM_BOTTOM_LEFT;
                item.corners &= ~ITEM_TOP_LEFT;
            }
        }
    }
    
    if ([item isPeerItem] && (![previousItem isPeerItem] || ![previousItem.descriptorId.twincodeOutboundId isEqual:item.descriptorId.twincodeOutboundId])) {
        NameItem *nameItem = [[NameItem alloc]initWithTimestamp:0 name:name];
        [self.items addObject:nameItem];
    }
    
    [self.items addObject:item];
}

- (void)reloadData {
    DDLogVerbose(@"%@ reloadData", LOG_TAG);
    
    [self.tableView reloadData];
    [self scrollToBottom];
    [self centerTextViewContent:self.messageTextView];
}

- (CGFloat)getTopMarginWithMask:(int)mask item:(Item *)item {
    DDLogVerbose(@"%@ getTopMarginWithMask: %d item:%@", LOG_TAG, mask, item);
    
    if (item.isPeerItem && mask) {
        return self.topMargin1;
    }
    return mask ? self.topMargin2 : self.topMargin1;
}

- (CGFloat)getBottomMarginWithMask:(int)mask item:(Item *)item {
    DDLogVerbose(@"%@ getBottomMarginWithMask: %d item:%@", LOG_TAG, mask, item);
    
    if (mask) {
        return self.bottomMargin2;
    } else {
        return self.bottomMargin1;
    }
}

- (CGFloat)getRadiusWithMask:(int)mask {
    DDLogVerbose(@"%@ getRadiusWithMask: %d", LOG_TAG, mask);
    
    return mask ? self.largeRadius : self.smallRadius;
}

- (BOOL)hasDescriptors {
    DDLogVerbose(@"%@ hasDescriptors", LOG_TAG);
 
    return self.items.count > 0;
}


#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    DDLogVerbose(@"%@ textViewDidBeginEditing: %@", LOG_TAG, textView);
    
    [self scrollToBottom];
    
    if ([textView.text isEqualToString:TwinmeLocalizedString(@"conversation_view_controller_message", nil)]) {
        textView.text = @"";
        textView.textColor = [UIColor whiteColor];
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    DDLogVerbose(@"%@ textViewDidChange: %@", LOG_TAG, textView);
    
    if (![textView.text isEqualToString:@""]) {
        self.sendView.alpha = 1.0f;
    } else {
        self.sendView.alpha = 0.5f;
    }
    
    [self centerTextViewContent:textView];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    DDLogVerbose(@"%@ textViewDidEndEditing: %@", LOG_TAG, textView);
    
    if ([textView.text isEqualToString:@""]) {
        textView.text = TwinmeLocalizedString(@"conversation_view_controller_message", nil);
        textView.textColor = Design.PLACEHOLDER_COLOR;
    }
}

- (void)centerTextViewContent:(UITextView*)textView {
    DDLogVerbose(@"%@ centerTextViewContent: %@", LOG_TAG, textView);
    
    CGFloat emptySize = ([textView bounds].size.height - [textView contentSize].height);
    CGFloat inset = MAX(0, emptySize / 2.0);
    textView.contentInset = UIEdgeInsetsMake(inset, textView.contentInset.left, inset, textView.contentInset.right);
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ heightForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    return UITableViewAutomaticDimension;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    DDLogVerbose(@"%@ numberOfSectionsInTableView: %@", LOG_TAG, tableView);
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ numberOfRowsInSection: %ld", LOG_TAG, tableView, (long)section);
    
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ cellForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    NSUInteger index = [self.items count] - indexPath.row - 1;
    Item *item = [self.items objectAtIndex:index];
        
    if (item.type == ItemTypeName) {
        CallNameCell *cell = [tableView dequeueReusableCellWithIdentifier:CALL_NAME_CELL_IDENTIFIER];
        if (!cell) {
            cell = [[CallNameCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CALL_NAME_CELL_IDENTIFIER];
        }
        
        cell.contentView.transform = CGAffineTransformMakeScale (1,-1);
        
        NameItem *nameItem = (NameItem *)item;
        [cell bindWithName:nameItem.name];
            
        return cell;
    } else if (item.type == ItemTypeMessage) {
        CallMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:CALL_MESSAGE_CELL_IDENTIFIER];
        if (!cell) {
            cell = [[CallMessageCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CALL_MESSAGE_CELL_IDENTIFIER];
        }
        
        cell.contentView.transform = CGAffineTransformMakeScale (1,-1);
        
        MessageItem *messageItem = (MessageItem *)item;
        [cell bindWithItem:messageItem callConversationView:self];
            
        return cell;
    } else {
        CallPeerMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:CALL_PEER_MESSAGE_CELL_IDENTIFIER];
        if (!cell) {
            cell = [[CallPeerMessageCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CALL_PEER_MESSAGE_CELL_IDENTIFIER];
        }
        
        cell.contentView.transform = CGAffineTransformMakeScale (1,-1);
        
        PeerMessageItem *peerMessageItem = (PeerMessageItem *)item;
        [cell bindWithItem:peerMessageItem callConversationView:self];
            
        return cell;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ willDisplayCell: %@ forRowAtIndexPath: %@", LOG_TAG, tableView, cell, indexPath);
    
    if (self.items.count > 0 && !self.hidden) {
        Item *item = [self.items objectAtIndex:indexPath.row];

        if (item.isPeerItem && item.readTimestamp == 0) {
            if ([self.callConversationDelegate respondsToSelector:@selector(readMessage:)]) {
                [self.callConversationDelegate readMessage:item.descriptorId];
            }
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ didSelectRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
        
    self.smallRadius = DESIGN_SMALL_ROUND_CORNER_RADIUS * Design.HEIGHT_RATIO;
    self.largeRadius = DESIGN_LARGE_ROUND_CORNER_RADIUS * Design.HEIGHT_RATIO;
    self.topMargin1 = DESIGN_TOP_MARGIN1 * Design.HEIGHT_RATIO;
    self.topMargin2 = DESIGN_TOP_MARGIN2 * Design.HEIGHT_RATIO;
    self.bottomMargin1 = DESIGN_BOTTOM_MARGIN1 * Design.HEIGHT_RATIO;
    self.bottomMargin2 = DESIGN_BOTTOM_MARGIN2 * Design.HEIGHT_RATIO;
    
    self.backgroundColor = [UIColor clearColor];
    
    self.containerViewLeadingConstraint.constant = DESIGN_MIN_MARGIN_ACTION * Design.WIDTH_RATIO;
    self.containerViewTrailingConstraint.constant = DESIGN_MIN_MARGIN_ACTION * Design.WIDTH_RATIO;

    self.containerView.backgroundColor = [UIColor colorWithRed:60./255. green:60./255. blue:60./255. alpha:1];
    self.containerView.clipsToBounds = YES;
    self.containerView.layer.cornerRadius = DESIGN_CORNER_RADIUS;
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.transform = CGAffineTransformMakeScale (1,-1);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = Design.SETTING_CELL_HEIGHT;
    [self.tableView registerNib:[UINib nibWithNibName:@"CallMessageCell" bundle:nil] forCellReuseIdentifier:CALL_MESSAGE_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"CallNameCell" bundle:nil] forCellReuseIdentifier:CALL_NAME_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"CallPeerMessageCell" bundle:nil] forCellReuseIdentifier:CALL_PEER_MESSAGE_CELL_IDENTIFIER];
    
    CGFloat sendViewHeight = Design.FONT_REGULAR32.lineHeight + (DESIGN_HEIGHT_INSET * Design.HEIGHT_RATIO * 2);
    self.sendMessageViewHeightConstraint.constant = sendViewHeight;
    self.sendMessageViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.containerMessageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.containerMessageViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.containerMessageViewTopConstraint.constant = 0;
    self.containerMessageViewBottomConstraint.constant = 0;
    
    self.containerMessageView.backgroundColor = [UIColor clearColor];
    self.containerMessageView.clipsToBounds = YES;
        
    self.messageTextViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.messageTextViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.messageTextViewTopConstraint.constant = 0;
    self.messageTextViewBottomConstraint.constant = 0;
    
    self.messageTextView.textContainerInset = UIEdgeInsetsMake(DESIGN_HEIGHT_INSET * 0.5 * Design.HEIGHT_RATIO, 0, DESIGN_HEIGHT_INSET * 0.5 * Design.HEIGHT_RATIO, 0);
    self.messageTextView.font = Design.FONT_REGULAR32;
    self.messageTextView.keyboardAppearance = UIKeyboardAppearanceDark;
    self.messageTextView.textColor = [UIColor whiteColor];
    self.messageTextView.text = TwinmeLocalizedString(@"conversation_view_controller_message", nil);
    self.messageTextView.delegate = self;
    
    self.sendImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;

    self.sendImageView.image =  [self.sendImageView.image imageFlippedForRightToLeftLayoutDirection];
    
    self.sendViewHeightConstraint.constant = sendViewHeight;
    
    self.sendView.backgroundColor = Design.MAIN_COLOR;
    self.sendView.clipsToBounds = YES;
    self.sendView.layer.cornerRadius =  self.sendViewHeightConstraint.constant * 0.5f;
    self.sendView.accessibilityLabel = TwinmeLocalizedString(@"feedback_view_controller_send", nil);
    self.sendView.isAccessibilityElement = YES;
    
    UITapGestureRecognizer *sendTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSendViewTapGesture:)];
    [self.sendView addGestureRecognizer:sendTapGesture];
    
    self.containerMessageView.layer.cornerRadius = self.sendViewHeightConstraint.constant * 0.5f;
    self.containerMessageView.layer.borderWidth = 1.0f;
    self.containerMessageView.layer.borderColor = [UIColor colorWithRed:151./255. green:151./255. blue:151./255. alpha:1].CGColor;
    
    self.closeImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.closeViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.closeViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.closeView.userInteractionEnabled = YES;
    self.closeView.isAccessibilityElement = YES;
    self.closeView.accessibilityLabel = TwinmeLocalizedString(@"application_cancel", nil);
    UITapGestureRecognizer *closeGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleCloseTapGesture:)];
    [self.closeView addGestureRecognizer:closeGestureRecognizer];
}

- (void)handleSendViewTapGesture:(UITapGestureRecognizer *)recognizer {
    DDLogVerbose(@"%@ handleSendViewTapGesture", LOG_TAG);
    
    if (recognizer.state == UIGestureRecognizerStateEnded && [self.callConversationDelegate respondsToSelector:@selector(sendMessage:)] && ![self.messageTextView.text isEqualToString:@""]) {
        [self.callConversationDelegate sendMessage:self.messageTextView.text];
        self.messageTextView.text = @"";
    }
}

- (void)handleCloseTapGesture:(UITapGestureRecognizer *)recognizer {
    DDLogVerbose(@"%@ handleCloseTapGesture", LOG_TAG);
    
    if (recognizer.state == UIGestureRecognizerStateEnded && [self.callConversationDelegate respondsToSelector:@selector(closeConversation)]) {
        [self.callConversationDelegate closeConversation];
        [self dismissKeyboard];
    }
}

- (void)scrollToBottom {
    DDLogVerbose(@"%@ scrollToBottom", LOG_TAG);
    
    if (self.items.count > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0  inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

- (void)dismissKeyboard {
    DDLogVerbose(@"%@ dismissKeyboard", LOG_TAG);
    
    [self.messageTextView resignFirstResponder];
}

@end

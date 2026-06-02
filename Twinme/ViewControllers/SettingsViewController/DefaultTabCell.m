/*
 *  Copyright (c) 2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Utils/NSString+Utils.h>

#import "DefaultTabCell.h"

#import <TwinmeCommon/ApplicationDelegate.h>
#import <TwinmeCommon/TwinmeApplication.h>

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: DefaultTabCell
//

@interface DefaultTabCell()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *callsTabViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIView *callsTabView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *callsImageTabViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *callsImageTabView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contactsTabViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIView *contactsTabView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contactsImageTabViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *contactsImageTabView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *conversationsTabViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIView *conversationsTabView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *conversationsImageTabViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *conversationsImageTabView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *notificationsTabViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIView *notificationsTabView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *notificationsImageTabViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *notificationsImageTabView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *selectTabViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *selectTabViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *selectTabViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *selectTabView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@end

//
// Implementation: DefaultTabCell
//

#undef LOG_TAG
#define LOG_TAG @"DefaultTabCell"

@implementation DefaultTabCell

- (void)awakeFromNib {
    DDLogVerbose(@"%@ awakeFromNib", LOG_TAG);
    
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = Design.WHITE_COLOR;
        
    self.callsTabViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.callsTabView.userInteractionEnabled = YES;
    self.callsTabView.isAccessibilityElement = YES;
    UITapGestureRecognizer *callsTabTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleCallsTapGesture:)];
    [self.callsTabView addGestureRecognizer:callsTabTapGesture];
    self.callsTabView.accessibilityLabel = TwinmeLocalizedString(@"calls_view_title", nil);
    
    self.callsImageTabViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.callsImageTabView.tintColor = Design.UNSELECTED_TAB_COLOR;
    
    self.contactsTabViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.contactsTabView.userInteractionEnabled = YES;
    self.contactsTabView.isAccessibilityElement = YES;
    UITapGestureRecognizer *contactsTabTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleContactsTapGesture:)];
    [self.contactsTabView addGestureRecognizer:contactsTabTapGesture];
    self.contactsTabView.accessibilityLabel = TwinmeLocalizedString(@"contacts_view_title", nil);
    
    self.contactsImageTabViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.contactsImageTabView.tintColor = Design.UNSELECTED_TAB_COLOR;
    
    self.conversationsTabViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.conversationsTabView.userInteractionEnabled = YES;
    self.conversationsTabView.isAccessibilityElement = YES;
    UITapGestureRecognizer *conversationsTabTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleConversationsTapGesture:)];
    [self.conversationsTabView addGestureRecognizer:conversationsTabTapGesture];
    self.conversationsTabView.accessibilityLabel = TwinmeLocalizedString(@"conversations_view_title", nil);
    
    self.conversationsImageTabViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.conversationsImageTabView.tintColor = Design.UNSELECTED_TAB_COLOR;
    
    self.notificationsTabViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.notificationsTabView.userInteractionEnabled = YES;
    self.notificationsTabView.isAccessibilityElement = YES;
    UITapGestureRecognizer *notificationTabTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleNotificationTapGesture:)];
    [self.notificationsTabView addGestureRecognizer:notificationTabTapGesture];
    self.notificationsTabView.accessibilityLabel = TwinmeLocalizedString(@"application_notifications", nil);
    
    self.notificationsImageTabViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.notificationsImageTabView.tintColor = Design.UNSELECTED_TAB_COLOR;
    
    self.selectTabViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.selectTabViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.selectTabViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.selectTabView.backgroundColor = Design.MAIN_COLOR;
    
    self.separatorViewHeightConstraint.constant = Design.SEPARATOR_HEIGHT;
    self.separatorView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
}

- (void)bind {
    DDLogVerbose(@"%@ bind", LOG_TAG);
    
    [self updateTab];
    [self updateColor];
}

- (void)handleCallsTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleCallsTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self selectTab:DefaultTabCalls];
    }
}

- (void)handleContactsTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleContactsTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self selectTab:DefaultTabContacts];
    }
}

- (void)handleConversationsTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleConversationsTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self selectTab:DefaultTabConversations];
    }
}

- (void)handleNotificationTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleNotificationTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self selectTab:DefaultTabNotifications];
    }
}

- (void)selectTab:(DefaultTab)defaultTab {
    
    ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
    TwinmeApplication *twinmeApplication = [delegate twinmeApplication];
    [twinmeApplication setDefaultTabWithTab:defaultTab];
    [self updateTab];
}

- (void)updateTab {
    DDLogVerbose(@"%@ updateTab", LOG_TAG);
    
    ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
    TwinmeApplication *twinmeApplication = [delegate twinmeApplication];
    
    self.callsImageTabView.tintColor = Design.UNSELECTED_TAB_COLOR;
    self.contactsImageTabView.tintColor = Design.UNSELECTED_TAB_COLOR;
    self.conversationsImageTabView.tintColor = Design.UNSELECTED_TAB_COLOR;
    self.notificationsImageTabView.tintColor = Design.UNSELECTED_TAB_COLOR;
    
    CGFloat sizeView = Design.DISPLAY_WIDTH / 4.0;
    
    switch (twinmeApplication.defaultTab) {
        case DefaultTabCalls:
            self.selectTabViewLeadingConstraint.constant = 0;
            self.callsImageTabView.tintColor = Design.MAIN_COLOR;
            break;
            
        case DefaultTabContacts:
            self.selectTabViewLeadingConstraint.constant = sizeView;
            self.contactsImageTabView.tintColor = Design.MAIN_COLOR;
            break;
            
        case DefaultTabConversations:
            self.selectTabViewLeadingConstraint.constant = sizeView * 2;
            self.conversationsImageTabView.tintColor = Design.MAIN_COLOR;
            break;
            
        case DefaultTabNotifications:
        default:
            self.selectTabViewLeadingConstraint.constant = sizeView * 3;
            self.notificationsImageTabView.tintColor = Design.MAIN_COLOR;
            break;
    }
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.contentView.backgroundColor = Design.WHITE_COLOR;
    self.separatorView.backgroundColor = Design.SEPARATOR_COLOR_GREY;
    self.selectTabView.backgroundColor = Design.MAIN_COLOR;
}

@end

/*
 *  Copyright (c) 2024-2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (fabrice.trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Utils/NSString+Utils.h>

#import "AbstractPreviewViewController.h"
#import "MenuSendOptionsView.h"
#import "PremiumFeatureConfirmView.h"

#import "UIPremiumFeature.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static UIColor *DESIGN_PLACEHOLDER_COLOR;
static UIColor *DESIGN_TEXTFIELD_CONVERSATION_BACKGROUND_COLOR;
static UIColor *DESIGN_BORDER_COLOR;

static const CGFloat DESIGN_HEIGHT_INSET = 24;
static const int MAX_VISIBLE_LINES = 5;

//
// Interface: AbstractPreviewViewController ()
//

@interface AbstractPreviewViewController ()<UITextViewDelegate, SwitchViewDelegate, ConfirmViewDelegate, MenuSendOptionsDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *closeView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *closeImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *certifiedImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *certifiedImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textContainerViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textContainerLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textContainerBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageTextViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageTextViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageTextViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageTextViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sendViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sendViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sendViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sendImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *sendImageView;

@property (nonatomic) BOOL keyboardHidden;

@property (nonatomic) BOOL menuSendOptionsOpen;
@property (nonatomic) BOOL allowCopy;

@property (nonatomic) NSString *contactName;
@property (nonatomic) UIImage *contactAvatar;
@property (nonatomic) BOOL certified;
@property (nonatomic) NSString *message;

@end

//
// Implementation: AbstractPreviewViewController
//

#undef LOG_TAG
#define LOG_TAG @"AbstractPreviewViewController"

@implementation AbstractPreviewViewController

+ (void)initialize {
    DDLogVerbose(@"%@ initialize", LOG_TAG);
    
    DESIGN_PLACEHOLDER_COLOR = [UIColor colorWithRed:162./255. green:162./255 blue:162./255 alpha:255./255];
    DESIGN_TEXTFIELD_CONVERSATION_BACKGROUND_COLOR = [UIColor colorWithRed:72./255. green:72./255. blue:72./255. alpha:1];
    DESIGN_BORDER_COLOR = [UIColor colorWithRed:78./255. green:78./255. blue:78./255. alpha:1];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _keyboardHidden = YES;
        _menuSendOptionsOpen = NO;
    }
    return self;
}

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
    
    [self initViews];
}

- (void)viewWillAppear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillAppear: %@", LOG_TAG, animated ? @"YES" : @"NO");
    
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    self.nameLabel.text = self.contactName;
    self.avatarView.image = self.contactAvatar;
    self.certifiedImageView.hidden = !self.certified;
    
    if (self.message && ![self.message isEqualToString:@""]) {
        self.messageTextView.text = self.message;
        self.message = @"";
    }
    
    [self centerTextViewContent];
}

- (void)viewWillDisappear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillDisappear: %@", LOG_TAG, animated ? @"YES" : @"NO");
    
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)initWithURL:(NSURL *)url {
    DDLogVerbose(@"%@ initWithURL: %@", LOG_TAG, url);
    
}

- (void)initWithName:(NSString *)name avatar:(UIImage *)avatar certified:(BOOL)certified message:(NSString *)message {
    DDLogVerbose(@"%@ initWithName: %@ avatar: %@ certified: %@", LOG_TAG, name, avatar, certified ? @"YES":@"NO");
    
    self.contactName = name;
    self.contactAvatar = avatar;
    self.certified = certified;
    self.message = message;
}

- (void)close {
    DDLogVerbose(@"%@ close", LOG_TAG);
}

- (void)send:(BOOL)allowCopyText allowCopyFile:(BOOL)allowCopyFile {
    DDLogVerbose(@"%@ send: %@ allowCopyFile: %@", LOG_TAG, allowCopyText ? @"YES" : @"NO", allowCopyFile ? @"YES" : @"NO");
    
}

- (void)keyboardWillShow:(NSNotification *)notification {
    DDLogVerbose(@"%@ keyboardWillShow: %@", LOG_TAG, notification);
    
    if (!self.keyboardHidden) {
        return;
    }
    
    self.keyboardHidden = NO;
    NSDictionary *info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    CGRect frame = CGRectMake(0, 0, Design.DISPLAY_WIDTH, Design.DISPLAY_HEIGHT);
    frame.origin.y = -keyboardSize.height;
    self.view.frame = frame;
    
    if ([self.twinmeApplication getDefaultKeyboardHeight] != keyboardSize.height) {
        [self.twinmeApplication setDefaultKeyboardHeight:keyboardSize.height];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    DDLogVerbose(@"%@ keyboardWillHide: %@", LOG_TAG, notification);
    
    self.keyboardHidden = YES;
    
    CGRect frame = self.view.frame;
    frame.origin.y = 0;
    self.view.frame = frame;
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification {
    DDLogVerbose(@"%@ keyboardWillChangeFrame: %@", LOG_TAG, notification);
    
    NSDictionary *info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    CGRect frame = CGRectMake(0, 0, Design.DISPLAY_WIDTH, Design.DISPLAY_HEIGHT);
    frame.origin.y = -keyboardSize.height;
    self.view.frame = frame;
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    DDLogVerbose(@"%@ textViewDidBeginEditing: %@", LOG_TAG, textView);
    
    if ([textView.text isEqualToString:TwinmeLocalizedString(@"conversation_view_controller_message", nil)]) {
        textView.text = @"";
        textView.textColor = [UIColor whiteColor];
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    DDLogVerbose(@"%@ textViewDidChange: %@", LOG_TAG, textView);
    
    [self centerTextViewContent];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    DDLogVerbose(@"%@ textViewDidEndEditing: %@", LOG_TAG, textView);
    
    if ([textView.text isEqualToString:@""]) {
        textView.text = TwinmeLocalizedString(@"conversation_view_controller_message", nil);
        textView.textColor = Design.PLACEHOLDER_COLOR;
    }
}

- (void)centerTextViewContent {
    DDLogVerbose(@"%@ centerTextViewContent", LOG_TAG);
    
    CGFloat textViewWidth = Design.DISPLAY_WIDTH - self.textContainerLeadingConstraint.constant - self.messageTextViewLeadingConstraint.constant - self.messageTextViewTrailingConstraint.constant - self.sendViewLeadingConstraint.constant - self.sendViewHeightConstraint.constant - self.sendViewTrailingConstraint.constant;
    
    CGRect textRect = [self.messageTextView.text boundingRectWithSize:CGSizeMake(textViewWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{
        NSFontAttributeName : Design.FONT_REGULAR32
    } context:nil];
    
    int countLines = textRect.size.height / Design.FONT_REGULAR32.lineHeight;
    
    float containerHeight = Design.FONT_REGULAR32.lineHeight * countLines + (DESIGN_HEIGHT_INSET * Design.HEIGHT_RATIO * 2);
    float minHeight = Design.FONT_REGULAR32.lineHeight + (DESIGN_HEIGHT_INSET * Design.HEIGHT_RATIO * 2);
    float maxHeight = Design.FONT_REGULAR32.lineHeight * MAX_VISIBLE_LINES + (DESIGN_HEIGHT_INSET * Design.HEIGHT_RATIO * 2);
    if (containerHeight < minHeight) {
        containerHeight = minHeight;
    } else if (containerHeight > maxHeight) {
        containerHeight = maxHeight;
    }
    
    self.textContainerViewHeightConstraint.constant = containerHeight;
    
    [UIView animateWithDuration:0.2 animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        CGFloat emptySize = ([self.messageTextView bounds].size.height - [self.messageTextView contentSize].height);
        CGFloat inset = MAX(0, emptySize / 2.0);
        self.messageTextView.contentInset = UIEdgeInsetsMake(inset, self.messageTextView.contentInset.left, inset, self.messageTextView.contentInset.right);
    }];
}

#pragma mark - ConfirmViewDelegate

- (void)didTapConfirm:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didTapConfirm: %@", LOG_TAG, abstractConfirmView);
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:TwinmeLocalizedString(@"twinme_plus_link", nil)] options:@{} completionHandler:nil];
    
    [abstractConfirmView closeConfirmView];
}

- (void)didTapCancel:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didTapCancel: %@", LOG_TAG, abstractConfirmView);
    
    [abstractConfirmView closeConfirmView];
}

- (void)didClose:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didClose: %@", LOG_TAG, abstractConfirmView);
    
    [abstractConfirmView closeConfirmView];
}

- (void)didFinishCloseAnimation:(nonnull AbstractConfirmView *)abstractConfirmView {
    DDLogVerbose(@"%@ didFinishCloseAnimation: %@", LOG_TAG, abstractConfirmView);
    
    [abstractConfirmView removeFromSuperview];
}

#pragma mark - MenuSendOptionsDelegate

- (void)cancelMenuSendOptions:(MenuSendOptionsView *)menuSendOptionsView {
    DDLogVerbose(@"%@ cancelMenuSendOptions", LOG_TAG);
    
    self.menuSendOptionsOpen = NO;
    [menuSendOptionsView removeFromSuperview];
}

- (void)sendFromOptionsMenu:(MenuSendOptionsView *)menuSendOptionsView allowCopy:(BOOL)allowCopy allowEphemeral:(BOOL)allowEphemeral expireTimeout:(int)expireTimeout {
    DDLogVerbose(@"%@ sendFromOptionsMenu: %@ allowEphemeral: %@ expireTimeout: %d", LOG_TAG, allowCopy ? @"YES" : @"NO", allowEphemeral ? @"YES" : @"NO", expireTimeout);
    
    [menuSendOptionsView removeFromSuperview];
    
    BOOL allowCopyText = self.twinmeApplication.allowCopyText;
    BOOL allowCopyFile = self.twinmeApplication.allowCopyFile;
    if (self.menuSendOptionsOpen) {
        allowCopyText = allowCopy;
        allowCopyFile = allowCopy;
    }
    
    [self send:allowCopyText allowCopyFile:allowCopyFile];
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    tapGesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGesture];
    
    self.closeViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.closeViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.closeView.userInteractionEnabled = YES;
    self.closeView.isAccessibilityElement = YES;
    self.closeView.accessibilityLabel = TwinmeLocalizedString(@"application_cancel", nil);
    [self.closeView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCloseTapGesture:)]];
    
    self.closeImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.closeImageView.tintColor = [UIColor whiteColor];
    
    self.certifiedImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.avatarViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.avatarView.clipsToBounds = YES;
    self.avatarView.layer.cornerRadius = self.avatarViewHeightConstraint.constant * 0.5f;
    
    self.nameLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.nameLabel.font = Design.FONT_MEDIUM34;
    self.nameLabel.textColor = [UIColor whiteColor];
    
    self.headerViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.headerViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    CGFloat sendViewHeight = Design.FONT_REGULAR32.lineHeight + (DESIGN_HEIGHT_INSET * Design.HEIGHT_RATIO * 2);
    
    self.textContainerViewHeightConstraint.constant = sendViewHeight;
    self.textContainerLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.textContainerBottomConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.textContainerView.backgroundColor = [UIColor blackColor];
    self.textContainerView.clipsToBounds = YES;
    self.textContainerView.layer.cornerRadius = self.textContainerViewHeightConstraint.constant * 0.5;
    self.textContainerView.layer.borderColor = DESIGN_BORDER_COLOR.CGColor;
    self.textContainerView.layer.borderWidth = 1.0f;
    
    self.messageTextViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.messageTextViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.messageTextViewTopConstraint.constant = 0;
    self.messageTextViewBottomConstraint.constant = 0;
    
    self.messageTextView.textContainerInset = UIEdgeInsetsMake(DESIGN_HEIGHT_INSET * 0.5 * Design.HEIGHT_RATIO, 0, DESIGN_HEIGHT_INSET * 0.5 * Design.HEIGHT_RATIO, 0);
    self.messageTextView.textColor = [UIColor whiteColor];
    self.messageTextView.font = Design.FONT_REGULAR32;
    self.messageTextView.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    self.messageTextView.returnKeyType = UIReturnKeyDefault;
    self.messageTextView.delegate = self;
    self.messageTextView.text = TwinmeLocalizedString(@"conversation_view_controller_message", nil);
    self.messageTextView.textColor = Design.PLACEHOLDER_COLOR;
    
    self.sendViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.sendViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.sendViewHeightConstraint.constant = sendViewHeight;
    
    self.sendView.backgroundColor = Design.MAIN_COLOR;
    self.sendView.clipsToBounds = YES;
    self.sendView.layer.cornerRadius =  self.sendViewHeightConstraint.constant * 0.5f;
    self.sendView.accessibilityLabel = TwinmeLocalizedString(@"feedback_view_controller_send", nil);
    self.sendView.isAccessibilityElement = YES;
    [self.sendView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSendTapGesture:)]];
    
    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleSendLongPress:)];
    [self.sendView addGestureRecognizer:longPressGestureRecognizer];
    
    self.sendImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.sendImageView.image =  [self.sendImageView.image imageFlippedForRightToLeftLayoutDirection];
    
    [self updateViews];
    [self centerTextViewContent];
}

- (void)updateViews {
    DDLogVerbose(@"%@ updateViews", LOG_TAG);
    
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dismissKeyboard {
    DDLogVerbose(@"%@ dismissKeyboard", LOG_TAG);
    
    [self.messageTextView resignFirstResponder];
}

- (void)handleEphemeralTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleEphemeralTapGesture: %@", LOG_TAG, sender);
    
    PremiumFeatureConfirmView *premiumFeatureConfirmView = [[PremiumFeatureConfirmView alloc] init];
    premiumFeatureConfirmView.confirmViewDelegate = self;
    premiumFeatureConfirmView.forceDarkMode = YES;
    [premiumFeatureConfirmView initWithPremiumFeature:[[UIPremiumFeature alloc]initWithFeatureType:FeatureTypePrivacy] parentViewController:self];
    [self.view addSubview:premiumFeatureConfirmView];
    [premiumFeatureConfirmView showConfirmView];
}

- (void)handleCloseTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleCloseTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self close];
    }
}

- (void)handleSendTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleSendTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        
        BOOL allowCopyText = self.twinmeApplication.allowCopyText;
        BOOL allowCopyFile = self.twinmeApplication.allowCopyFile;
        if (self.menuSendOptionsOpen) {
            allowCopyText = self.allowCopy;
            allowCopyFile = self.allowCopy;
        }
        
        [self send:allowCopyText allowCopyFile:allowCopyFile];
    }
}

- (void)handleSendLongPress:(UITapGestureRecognizer *)recognizer {
    DDLogVerbose(@"%@ handleSendLongPress: %@", LOG_TAG, recognizer);
    
    if (!self.menuSendOptionsOpen) {
        if ([self.messageTextView isFirstResponder]) {
            [self.messageTextView resignFirstResponder];
        }
        
        MenuSendOptionsView *menuSendOptionsView = [[MenuSendOptionsView alloc] init];
        menuSendOptionsView.menuSendOptionsDelegate = self;
        menuSendOptionsView.forceDarkMode = YES;
        [self.view addSubview:menuSendOptionsView];
        
        self.menuSendOptionsOpen = YES;
        
        self.allowCopy = NO;
        
        BOOL allowCopyText = self.twinmeApplication.allowCopyText;
        BOOL allowCopyFile = self.twinmeApplication.allowCopyFile;
        
        BOOL isTextToSend = NO;
        
        if ([self.messageTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0) {
            isTextToSend = YES;
        }
        
        if (isTextToSend) {
            if (allowCopyText || allowCopyFile) {
                self.allowCopy = YES;
            }
        } else {
            self.allowCopy = allowCopyFile;
        }
        
        [menuSendOptionsView openMenu:self.allowCopy];
    }
}

@end

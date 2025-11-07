/*
 *  Copyright (c) 2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinme/TLSpace.h>

#import "SecretSpaceViewController.h"

#import <TwinmeCommon/SecretSpaceService.h>

#import <Utils/NSString+Utils.h>

#import <TwinmeCommon/Design.h>

#import "UIColor+Hex.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: SecretSpaceViewController ()
//

@interface SecretSpaceViewController () <UITextFieldDelegate, SecretSpaceServiceDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *secretContainerTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *secretContainerWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *secretContainerHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *secretContainerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *nameView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameTextFieldLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameTextFieldTrailingConstraint;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelButtonHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelButtonWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelButtonBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelButtonLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sendButtonHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sendButtonWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sendButtonBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sendButtonTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeImageViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeImageViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *closeImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *closeView;

@property (nonatomic) UIColor *customColor;

@property (nonatomic) SecretSpaceService *secretSpaceService;
@property (nonatomic) TLSpace *secretSpace;

@end

#undef LOG_TAG
#define LOG_TAG @"SecretSpaceViewController"

//
// Implementation: SecretSpaceViewController
//

@implementation SecretSpaceViewController

#pragma mark - UIViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _secretSpaceService = [[SecretSpaceService alloc] initWithTwinmeContext:self.twinmeContext delegate:self];
    }
    
    return self;
}

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
    
    [self initViews];
}

#pragma mark - Public methods

- (void)showInViewController:(UIViewController *)viewController {
    DDLogVerbose(@"%@ showInViewController: %@", LOG_TAG, viewController);
    
    self.view.frame = viewController.view.frame;
    [viewController.view addSubview:self.view];
    
    [viewController addChildViewController:self];
    [self didMoveToParentViewController:viewController];
}

#pragma mark - SecretSpaceServiceDelegate

- (void)onGetSpaces:(nonnull NSArray *)spaces {
    DDLogVerbose(@"%@ onGetSpaces: %@", LOG_TAG, spaces);
    
    self.secretSpace = nil;
    
    if (spaces.count > 0) {
        self.secretSpace = spaces.firstObject;
    }
}

- (void)onSetCurrentSpace:(nonnull TLSpace *)space {
    DDLogVerbose(@"%@ onSetCurrentSpace: %@", LOG_TAG, space);
    
    [self finish];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    DDLogVerbose(@"%@ textFieldShouldReturn: %@", LOG_TAG, textField);
    
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidChange:(UITextField *)textField{
    DDLogVerbose(@"%@ textFieldDidChange: %@", LOG_TAG, textField);
    
    [self.secretSpaceService findSecretSpaceByName:textField.text];
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.view.backgroundColor = [UIColor clearColor];
    
    self.secretContainerTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.secretContainerWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.secretContainerHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.secretContainerView.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
    self.secretContainerView.layer.cornerRadius = Design.POPUP_RADIUS;
    
    self.nameViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.nameViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.nameView.backgroundColor = Design.TEXTFIELD_POPUP_BACKGROUND_COLOR;
    self.nameView.layer.cornerRadius = 6.f;
    self.nameView.clipsToBounds = YES;
    
    self.nameTextFieldLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.nameTextFieldTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.nameTextField.font = Design.FONT_REGULAR44;
    self.nameTextField.textColor = Design.FONT_COLOR_DEFAULT;
    self.nameTextField.tintColor = Design.FONT_COLOR_DEFAULT;
    [self.nameTextField setReturnKeyType:UIReturnKeyDone];
    self.nameTextField.delegate = self;
    [self.nameTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    self.nameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:TwinmeLocalizedString(@"settings_space_view_controller_space_category_title", nil) attributes:[NSDictionary dictionaryWithObject:Design.PLACEHOLDER_COLOR forKey:NSForegroundColorAttributeName]];
    
    self.sendButtonTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.sendButtonBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.sendButtonWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.sendButtonHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    CALayer *saveButtonLayer = self.sendButton.layer;
    saveButtonLayer.cornerRadius = 6.f;
    saveButtonLayer.masksToBounds = YES;
    [self.sendButton setBackgroundColor:Design.BLUE_NORMAL];
    self.sendButton.titleLabel.font = Design.FONT_BOLD28;
    [self.sendButton setTitle:TwinmeLocalizedString(@"application_ok", nil) forState:UIControlStateNormal];
    
    self.cancelButtonLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.cancelButtonBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.cancelButtonWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.cancelButtonHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    CALayer *cancelButtonLayer = self.cancelButton.layer;
    cancelButtonLayer.cornerRadius = 6.f;
    cancelButtonLayer.masksToBounds = YES;
    [self.cancelButton setBackgroundColor:Design.BUTTON_RED_COLOR];
    self.cancelButton.titleLabel.font = Design.FONT_BOLD28;
    [self.cancelButton setTitle:TwinmeLocalizedString(@"application_cancel", nil) forState:UIControlStateNormal];
    
    self.closeImageViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.closeImageViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.closeImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.closeViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.closeViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.closeView.userInteractionEnabled = YES;
    UITapGestureRecognizer *closeGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleCloseTapGesture:)];
    [self.closeView addGestureRecognizer:closeGestureRecognizer];
}

- (void)handleCloseTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleCloseTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        
        [self finish];
    }
}

- (IBAction)sendAction:(id)sender {
    DDLogVerbose(@"%@ sendAction: %@", LOG_TAG, sender);
    
    if (self.secretSpace) {
        [self.secretSpaceService setCurrentSpace:self.secretSpace];
    } else {
        [self finish];
    }
}

- (IBAction)cancelAction:(id)sender {
    DDLogVerbose(@"%@ cancelAction: %@", LOG_TAG, sender);
    
    [self finish];
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    [self.secretSpaceService dispose];
    
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.nameTextField.font = Design.FONT_REGULAR44;
    self.sendButton.titleLabel.font = Design.FONT_BOLD28;
    self.cancelButton.titleLabel.font = Design.FONT_BOLD28;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    [self.sendButton setBackgroundColor:Design.BLUE_NORMAL];
    [self.cancelButton setBackgroundColor:Design.BUTTON_RED_COLOR];
    self.nameView.backgroundColor = Design.TEXTFIELD_POPUP_BACKGROUND_COLOR;
    self.nameTextField.textColor = Design.FONT_COLOR_DEFAULT;
    self.nameTextField.tintColor = Design.FONT_COLOR_DEFAULT;
}

@end

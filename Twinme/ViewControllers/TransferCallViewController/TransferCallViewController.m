/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "TransferCallViewController.h"
#import "EditIdentityViewController.h"

#import <TwinmeCommon/Design.h>

#import <Utils/NSString+Utils.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: TransferCallViewController ()
//

@interface TransferCallViewController()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *editViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *editViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *editView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *editRoundedViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *editRoundedView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *editImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *editImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *editLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *editLabel;

@end

//
// Implementation: TransferCallViewController
//

#undef LOG_TAG
#define LOG_TAG @"TransferCallViewController"

@implementation TransferCallViewController

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    [super initViews];
    
    self.editViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.editViewWidthConstraint.constant *= Design.WIDTH_RATIO;
        
    UITapGestureRecognizer *editCodeGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleEditTransfertCallTapGesture:)];
    [self.editView addGestureRecognizer:editCodeGestureRecognizer];
    self.editView.isAccessibilityElement = YES;
    self.editView.accessibilityLabel = TwinmeLocalizedString(@"application_edit", nil);
    
    self.editRoundedViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.editRoundedView.clipsToBounds = YES;
    self.editRoundedView.backgroundColor = [UIColor blackColor];
    self.editRoundedView.layer.cornerRadius = self.editRoundedViewHeightConstraint.constant * 0.5;
    self.editRoundedView.layer.borderColor = Design.ACTION_BORDER_COLOR.CGColor;
    self.editRoundedView.layer.borderWidth = 1.0;
    
    self.editImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.editImageView.tintColor = [UIColor whiteColor];
    
    self.editLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.editLabel.font = Design.FONT_MEDIUM28;
    self.editLabel.textColor = [UIColor whiteColor];
    self.editLabel.text = TwinmeLocalizedString(@"application_edit", nil);
}

- (void)handleEditTransfertCallTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleEditTransfertCallTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        EditIdentityViewController *editIdentityViewController = [[UIStoryboard storyboardWithName:@"iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"EditIdentityViewController"];
        [editIdentityViewController initWithCallReceiver:self.callReceiver];
        [self.navigationController pushViewController:editIdentityViewController animated:YES];
    }
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    [super updateFont];
    
    self.editLabel.font = Design.FONT_MEDIUM28;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    [super updateColor];
}

@end

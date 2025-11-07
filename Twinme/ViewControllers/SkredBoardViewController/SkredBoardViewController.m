/*
 *  Copyright (c) 2017-2021 twinlife SA & Telefun SAS.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Thibaud David (contact@thibauddavid.com)
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "SkredBoardViewController.h"

#import "CodeInputCollectionView.h"
#import <TwinmeCommon/Design.h>
#import "UIView+DropShadow.h"

#import <Utils/NSString+Utils.h>

static CGFloat DESIGN_RATIO_HEIGHT_SKREDBOARD = 249. / 667.;

//
// Interface: SkredBoardViewController ()
//

@interface SkredBoardViewController () <CodeInputCollectionViewDatasource, CodeInputCollectionViewDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *safeAreaViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *safeAreaView;
@property (weak, nonatomic) IBOutlet UIView *codeInputCollectionViewContainer;
@property (weak, nonatomic) IBOutlet UIView *closeSkredboardTouchZone;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIButton *createAccountButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteAccountButton;
@property (weak, nonatomic) IBOutlet UIButton *validateButton;
@property (weak, nonatomic) IBOutlet UILabel *codeInputLabel;
@property (weak, nonatomic) IBOutlet UIButton *clearCodeInputButton;

@property (strong, nonatomic) CodeInputCollectionView *codeInputCollectionView;
@property (strong, nonatomic) NSString *code;
@property (nonatomic) SkredBoardMode skredBoardMode;

@end

//
// Implementation: SkredBoardViewController
//

@implementation SkredBoardViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setSkredBoardMode:SkredBoardModeAccessAccount];
    
    [self initViews];
}

- (void)viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];
    
    UIWindow *window = UIApplication.sharedApplication.keyWindow;
    self.safeAreaViewHeightConstraint.constant = window.safeAreaInsets.top;
    
    self.codeInputCollectionView.frame = self.codeInputCollectionViewContainer.bounds;
    [self.codeInputCollectionView.collectionViewLayout invalidateLayout];
    [self.skredBoard updateShadowPath];
}

- (void)addToViewControllerWithoutStickGesture:(UIViewController*)viewController {
    
    [viewController addChildViewController:self];
    self.view.frame = viewController.view.bounds;
    [viewController.view addSubview:self.view];
    [self didMoveToParentViewController:viewController];
    [self setSkredBoardDisplayState:SkredBoardDisplayStateClose initialVelocity:0 animated:NO];
}

- (void)addToViewController:(UIViewController<SkredBoardViewControllerSwipeResponder> *)viewController {
    
    [viewController addChildViewController:self];
    self.view.frame = viewController.view.bounds;
    [viewController.view addSubview:self.view];
    [self didMoveToParentViewController:viewController];
    [self setSkredBoardDisplayState:SkredBoardDisplayStateClose initialVelocity:0 animated:NO];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGestureRecognizer:)];
    [[viewController skredBoardViewControllerSwipeableView] addGestureRecognizer:panGesture];
    [viewController skredBoardViewControllerSwipeableView].userInteractionEnabled = YES;
}

- (void)setSkredBoardMode:(SkredBoardMode)skredBoardMode {
    
    _skredBoardMode = skredBoardMode;
    self.code = @"";
    [self codeDidUpdate];
    
    switch (skredBoardMode) {
        case SkredBoardModeAccessAccount:
            self.createAccountButton.hidden = NO;
            self.deleteAccountButton.hidden = NO;
            self.titleLabel.text = TwinmeLocalizedString(@"main_view_controller_skredboard_access_title", nil);
            self.messageLabel.text = TwinmeLocalizedString(@"main_view_controller_skredboard_message", nil);
            break;
            
        case SkredBoardModeCreateAccount:
            self.createAccountButton.hidden = YES;
            self.deleteAccountButton.hidden = NO;
            self.titleLabel.text = TwinmeLocalizedString(@"main_view_controller_skredboard_create_title", nil);
            self.messageLabel.text = TwinmeLocalizedString(@"main_view_controller_skredboard_message", nil);
            break;
            
        case SkredBoardModeDeleteAccount:
            self.createAccountButton.hidden = NO;
            self.deleteAccountButton.hidden = YES;
            self.titleLabel.text = TwinmeLocalizedString(@"main_view_controller_skredboard_delete_title", nil);
            self.messageLabel.text = TwinmeLocalizedString(@"main_view_controller_skredboard_message", nil);
            break;
            
        default:
            break;
    }
}

- (NSString *)repeatString:(NSString*)string times:(NSUInteger)times {
    return [@"" stringByPaddingToLength:times * [string length]
                             withString:string
                        startingAtIndex:0];
}

- (void)codeDidUpdate {
    
    //    self.validateButton.enabled = self.code.length > 0;
    
    NSString *inputText = [self repeatString:@"·" times:self.code.length];
    self.codeInputLabel.text = inputText;
    self.clearCodeInputButton.hidden = (inputText.length == 0);
}

- (void)setSkredBoardDisplayState:(SkredBoardDisplayState)skredBoardDisplayState initialVelocity:(CGFloat)velocity animated:(BOOL)animated {
    
    if (!self.view.superview) return;
    
    __weak typeof(self) weakSelf = self;
    self.closeSkredboardTouchZone.userInteractionEnabled = skredBoardDisplayState == SkredBoardDisplayStateOpen;
    if(skredBoardDisplayState == SkredBoardDisplayStateClose) {
        [self setSkredBoardMode:SkredBoardModeAccessAccount];
    }
    
    CGFloat closedOriginY = -(DESIGN_RATIO_HEIGHT_SKREDBOARD * Design.DISPLAY_HEIGHT) - 50 - self.safeAreaViewHeightConstraint.constant;
    CGFloat destinationY = skredBoardDisplayState == SkredBoardDisplayStateClose ? closedOriginY : 0;
    CGFloat initialVelocity = velocity / (self.view.frame.origin.y - destinationY);
    [UIView animateWithDuration:animated ? 0.3 : 0 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:initialVelocity options:UIViewAnimationOptionCurveLinear
                     animations:^{
        weakSelf.view.frame = CGRectMake(0, destinationY, weakSelf.view.frame.size.width, weakSelf.view.frame.size.height);
    }
                     completion:nil];
    self.skredBoardDisplayState = skredBoardDisplayState;
}

- (IBAction)handlePanGestureRecognizer:(UIPanGestureRecognizer *)sender {
    
    CGFloat translationY = [sender translationInView:self.view].y;
    CGFloat destination = MAX(MIN(self.view.frame.origin.y + translationY, self.openedOrigin), self.closedOrigin);
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged: {
            self.view.frame = CGRectMake(0, destination, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
            [sender setTranslation:CGPointZero inView:sender.view];
            break;
        }
            
        case UIGestureRecognizerStateEnded: {
            [self updateDisplayStateToNearestWithVelocity:[sender velocityInView:sender.view].y];
        }
            
        default:
            break;
    }
}

#pragma mark - helpers

static CGFloat kMinSwipeThresholdToAppear = 50;

- (CGFloat)openedOrigin {
    
    return 0;
}

- (CGFloat)closedOrigin {
    
    return -self.skredBoard.frame.size.height - kMinSwipeThresholdToAppear;
}

- (void)updateDisplayStateToNearestWithVelocity:(CGFloat)velocity {
    
    CGFloat closingThreshold = self.closedOrigin/2 - velocity * 0.3;
    if (self.view.frame.origin.y > closingThreshold) {
        [self setSkredBoardDisplayState:SkredBoardDisplayStateOpen initialVelocity:velocity animated:YES];
    } else {
        [self setSkredBoardDisplayState:SkredBoardDisplayStateClose initialVelocity:velocity animated:YES];
    }
}

- (void)dismiss {
    
    if ([self.delegate respondsToSelector:@selector(dismissSkredBoardViewController:)]) {
        [self.delegate dismissSkredBoardViewController:self];
    }
}

#pragma mark - IBActions

- (IBAction)onTouchUpInsideSwitchToCreateAccountMode:(id)sender {
    
    [self setSkredBoardMode:SkredBoardModeCreateAccount];
}

- (IBAction)onTouchUpInsideSwitchToDeleteAccountMode:(id)sender {
    
    [self setSkredBoardMode:SkredBoardModeDeleteAccount];
}

- (IBAction)didTapOnCloseSkredBoardTouchZone:(UITapGestureRecognizer *)tapGesture {
    
    [self dismiss];
}

- (IBAction)onTouchUpInsideValidate:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(skredBoardViewController:didValidateCode:onMode:)]) {
        [self.delegate skredBoardViewController:self didValidateCode:self.code onMode:self.skredBoardMode];
    }
}

- (IBAction)onTouchUpInsideClearInputCode:(id)sender {
    self.code = @"";
    [self codeDidUpdate];
}


#pragma mark - CodeInputCollectionDataSource

- (NSArray<UIColor *> *)codeInputCollectionView:(CodeInputCollectionView *)codeInputCollectionView colorsForDigit:(NSInteger)digit {
    
    return [Design colorsForDigit:digit];
}

- (NSArray<UIColor *> *)codeInputCollectionView:(UICollectionView *)collectionView didHighlightItemForDigit:(NSInteger)digit
{
    return [Design colorsForDigit:digit];
}

- (NSArray<UIColor *> *)codeInputCollectionView:(UICollectionView *)collectionView didUnhighlightItemForDigit:(NSInteger)digit
{
    return [Design colorsForDigit:digit];
}

#pragma mark - CodeInputCollectionDelegate

-(void)codeInputCollectionView:(CodeInputCollectionView *)codeInputCollectionView didSelectDigit:(NSInteger)digit {
    
    self.code = [NSString stringWithFormat:@"%@%@", self.code, @(digit).stringValue];
    [self codeDidUpdate];
}

#pragma mark - Private

- (void)initViews {
    
    self.codeInputCollectionView = [[CodeInputCollectionView alloc] init];
    self.codeInputCollectionView.backgroundColor = [UIColor clearColor];
    self.codeInputCollectionView.codeInputCollectionViewDatasource = self;
    self.codeInputCollectionView.codeInputCollectionViewDelegate = self;
    [self.codeInputCollectionViewContainer addSubview:self.codeInputCollectionView];
    [self.skredBoard addDropShadowWithColor:Design.SHADOW_COLOR shadowRadius:8 shadowOffset:CGSizeMake(0, 8) opacity:0.4];
    
    [self.deleteAccountButton setTitle:TwinmeLocalizedString(@"application_remove", nil) forState:UIControlStateNormal];
    [self.validateButton setTitle:TwinmeLocalizedString(@"application_ok", nil) forState:UIControlStateNormal];
    
    [self.clearCodeInputButton setImage:[UIImage imageNamed:@"BlackCross"] forState:UIControlStateNormal];
    self.clearCodeInputButton.hidden = YES;
}

@end

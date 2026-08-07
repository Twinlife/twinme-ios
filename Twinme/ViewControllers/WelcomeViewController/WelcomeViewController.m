/*
 *  Copyright (c) 2015-2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Marouane Qasmi (Marouane.Qasmi@twinlife-systems.com)
 *   Chedi Baccari (Chedi.Baccari@twinlife-systems.com)
 *   Christian Jacquemot (Christian.Jacquemot@twinlife-systems.com)
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinme/TLSpace.h>
#import <Utils/NSString+Utils.h>

#import "WelcomeViewController.h"

#import "WelcomeCell.h"
#import "WelcomeFlowLayout.h"
#import "UIWelcome.h"

#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/MainViewController.h>
#import <TwinmeCommon/TwinmeNavigationController.h>

#import "TTTAttributedLabel.h"
#import "WebViewController.h"
#import "AccountMigrationScannerViewController.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static UIColor *DESIGN_TITLE_COLOR;
static UIColor *DESIGN_MESSAGE_COLOR;
static UIColor *DESIGN_ENTER_COLOR;
static UIColor *DESIGN_SHADOW_COLOR;

static NSString *WELCOME_CELL_IDENTIFIER = @"WelcomeCellIdentifier";

static const int WELCOME_STEP_COUNT = 3;

//
// Interface: WelcomeViewController ()
//

@interface WelcomeViewController () <TTTAttributedLabelDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *splashScreenLogoViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *splashScreenLogoViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *splashScreenLogoView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *splashScreenLogoImageWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *splashScreenLogoImageHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *splashScreenLogoImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *splashScreenTwinmeImageWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *splashScreenTwinmeImageHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *splashScreenTwinmeImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *startViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *startViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *startView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *startLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *startLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *restoreViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *restoreViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *restoreView;
@property (weak, nonatomic) IBOutlet UILabel *restoreLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *logoView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *welcomeCollectionViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *welcomeCollectionViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *welcomeCollectionViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UICollectionView *welcomeCollectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *footerViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *welcomePageControlBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *welcomePageControlWidthConstraint;
@property (weak, nonatomic) IBOutlet UIPageControl *welcomePageControl;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *prevClickableViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *prevClickableViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *prevClickableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *prevLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *prevLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nextClickableViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nextClickableViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nextClickableViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *nextClickableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nextLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nextLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *nextLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *termsOfUseWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *termsOfUseBottomConstraint;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *termsOfUseLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *backImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backClickableViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backClickableViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *backClickableView;

@property (nonatomic) NSMutableArray *uiWelcome;

@end

//
// Implementation: WelcomeViewController
//

#undef LOG_TAG
#define LOG_TAG @"WelcomeViewController"

@implementation WelcomeViewController

+ (void)initialize {
    DDLogVerbose(@"%@ initialize", LOG_TAG);
    
    DESIGN_TITLE_COLOR = [UIColor colorWithRed:52./255. green:54./255. blue:55./255. alpha:1];
    DESIGN_MESSAGE_COLOR = [UIColor colorWithRed:75./255. green:77./255. blue:78./255. alpha:1];
    DESIGN_ENTER_COLOR = [UIColor colorWithRed:46./255. green:122./255. blue:182./255. alpha:1];
    DESIGN_SHADOW_COLOR = [UIColor colorWithRed:87./255. green:123./255. blue:164./255. alpha:1];
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
    
    [self initViews];
}

- (void)viewWillAppear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillAppear", LOG_TAG);
    
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    
    self.backClickableView.hidden = YES;
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotificationsRequestAuthorizationFinish:) name:NotificationsRequestAuthorizationFinish object:nil];
    
    [self setupWelcome];
}

- (void)viewDidAppear:(BOOL)animated {
    DDLogVerbose(@"%@ viewDidAppear %@", LOG_TAG, animated ? @"YES" : @"NO");
    
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillDisappear", LOG_TAG);
    
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBarHidden = NO;
    
    [[NSNotificationCenter defaultCenter] removeObserver:NotificationsRequestAuthorizationFinish];
}

- (BOOL)adjustStatusBarAppearance {
    
    return YES;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    DDLogVerbose(@"%@ numberOfSectionsInCollectionView: %@", LOG_TAG, collectionView);
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ collectionView: %@ numberOfItemsInSection: %ld", LOG_TAG, collectionView, (long)section);
    
    return self.uiWelcome.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ collectionView: %@ layout: %@ sizeForItemAtIndexPath: %@", LOG_TAG, collectionView, collectionViewLayout, indexPath);
    
    return CGSizeMake(Design.DISPLAY_WIDTH, self.welcomeCollectionViewHeightConstraint.constant);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    DDLogVerbose(@"%@ collectionView: %@ layout: %@ minimumLineSpacingForSectionAtIndex: %ld", LOG_TAG, collectionView, collectionViewLayout, (long)section);
    
    return 0.0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ collectionView: %@ layout: %@ referenceSizeForHeaderInSection: %ld", LOG_TAG, collectionView, collectionViewLayout, (long)section);
    
    return CGSizeMake(0, 0);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ collectionView: %@ cellForItemAtIndexPath: %@", LOG_TAG, collectionView, indexPath);
            
    WelcomeCell *welcomeCell = [collectionView dequeueReusableCellWithReuseIdentifier:WELCOME_CELL_IDENTIFIER forIndexPath:indexPath];
    UIWelcome *uiWelcome = [self.uiWelcome objectAtIndex:indexPath.row];
    [welcomeCell bindWithTitle:[uiWelcome getMessage] image:[uiWelcome getImage] font:Design.FONT_MEDIUM34];
    return welcomeCell;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    DDLogVerbose(@"%@ scrollViewDidScroll: %@", LOG_TAG, scrollView);
    
    CGFloat offset = scrollView.contentOffset.x;
    CGFloat width = scrollView.frame.size.width;
    CGFloat center = width / 2.0;
    int currentPage = (int) ((offset + center) / width);
    self.welcomePageControl.currentPage = currentPage;
        
    if (currentPage == 0) {
        self.prevLabel.hidden = YES;
        self.prevClickableView.hidden = YES;
    } else {
        self.prevLabel.hidden = NO;
        self.prevClickableView.hidden = NO;
    }
        
    if (currentPage + 1 == self.uiWelcome.count) {
        self.nextLabel.text = TwinmeLocalizedString(@"welcome_view_start", nil);
        self.termsOfUseLabel.hidden = NO;
        self.nextClickableView.hidden = NO;
        self.nextLabel.hidden = NO;
    } else {
        self.nextLabel.text = TwinmeLocalizedString(@"welcome_view_next", nil);
        self.termsOfUseLabel.hidden = YES;
        self.nextClickableView.hidden = NO;
        self.nextLabel.hidden = NO;
    }
    
    [self setupTermsOfUse:currentPage];
}

#pragma mark - TTTAttributedLabelDelegate

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    DDLogVerbose(@"%@ attributedLabel: %@ didSelectLinkWithURL: %@", LOG_TAG, label, url);
    
    WebViewController *webViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
    webViewController.fileName = url.host;
    webViewController.name = TwinmeLocalizedString(@"application_name", nil);
    [self.navigationController pushViewController:webViewController animated:YES];
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.view.backgroundColor = Design.WHITE_COLOR;
    
    self.splashScreenLogoViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.splashScreenLogoViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
        
    self.splashScreenLogoImageWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.splashScreenLogoImageHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.splashScreenLogoImage.alpha = 1.0;
    
    self.splashScreenTwinmeImage.backgroundColor = [UIColor clearColor];
    self.splashScreenTwinmeImage.tintColor = Design.SPLASHSCREEN_LOGO_COLOR;
    self.splashScreenTwinmeImage.alpha = 1.0;
    
    self.splashScreenTwinmeImageWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.splashScreenTwinmeImageHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.logoViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.logoViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.logoViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.logoView.hidden = YES;
    
    self.messageLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.messageLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.messageLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.messageLabel.font = Design.FONT_REGULAR34;
    self.messageLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.messageLabel.text = TwinmeLocalizedString(@"add_contact_view_share_message_part_2", nil);
    
    self.startViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.startViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.startView.backgroundColor = Design.MAIN_COLOR;
    self.startView.userInteractionEnabled = YES;
    self.startView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.startView.clipsToBounds = YES;
    self.startView.isAccessibilityElement = YES;
    [self.startView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleStartTapGesture:)]];
    
    self.startLabelWidthConstraint.constant *= Design.WIDTH_RATIO;

    self.startLabel.font = Design.FONT_BOLD36;
    self.startLabel.textColor = [UIColor whiteColor];
    self.startLabel.text = TwinmeLocalizedString(@"application_start", nil);
    
    self.restoreViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.restoreViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.restoreView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *restoreViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleRestoreTapGesture:)];
    [self.restoreView addGestureRecognizer:restoreViewGestureRecognizer];
        
    UIWindow *window = [self currentWindow];
    if (window) {
        self.restoreViewBottomConstraint.constant = window.safeAreaInsets.bottom;
    } else {
        self.restoreViewBottomConstraint.constant = self.view.safeAreaInsets.bottom;
    }
    
    self.restoreLabel.font = Design.FONT_MEDIUM38;
    self.restoreLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.restoreLabel.text = TwinmeLocalizedString(@"application_transfer_restore", nil);
    
    self.welcomeCollectionViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.welcomeCollectionViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.welcomeCollectionViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.welcomeCollectionView.dataSource = self;
    self.welcomeCollectionView.delegate = self;
    self.welcomeCollectionView.hidden = YES;
    
    self.welcomeCollectionView.backgroundColor = Design.WHITE_COLOR;
    [self.welcomeCollectionView registerNib:[UINib nibWithNibName:@"WelcomeCell" bundle:nil] forCellWithReuseIdentifier:WELCOME_CELL_IDENTIFIER];
    
    self.prevClickableViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.prevClickableViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.prevClickableView.hidden = YES;
    UITapGestureRecognizer *prevClickableViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handlePrevTapGesture:)];
    [self.prevClickableView addGestureRecognizer:prevClickableViewGestureRecognizer];
    
    self.prevLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.prevLabel.font = Design.FONT_REGULAR34;
    self.prevLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.prevLabel.text = TwinmeLocalizedString(@"application_back", nil);
    self.prevLabel.hidden = YES;
    
    self.nextClickableViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.nextClickableViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.nextClickableViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.nextClickableView.clipsToBounds = YES;
    self.nextClickableView.backgroundColor = Design.MAIN_COLOR;
    self.nextClickableView.layer.cornerRadius = self.nextClickableViewHeightConstraint.constant * 0.5;
    self.nextClickableView.hidden = YES;
    
    UITapGestureRecognizer *nextClickableViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleNextTapGesture:)];
    [self.nextClickableView addGestureRecognizer:nextClickableViewGestureRecognizer];
    
    self.nextLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.nextLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.nextLabel.font = Design.FONT_BOLD34;
    self.nextLabel.textColor = [UIColor whiteColor];
    self.nextLabel.adjustsFontSizeToFitWidth = YES;
    self.nextLabel.text = TwinmeLocalizedString(@"welcome_view_next", nil);
    
    self.welcomePageControlBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.welcomePageControlWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.welcomePageControl.pageIndicatorTintColor = [UIColor colorWithRed:244./255. green:244./255. blue:244./255. alpha:1.0];
    self.welcomePageControl.currentPageIndicatorTintColor = Design.MAIN_COLOR;
    self.welcomePageControl.transform = CGAffineTransformMakeScale(1.2, 1.2);
    self.welcomePageControl.hidden = YES;
    
    self.termsOfUseWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.termsOfUseBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.termsOfUseLabel.font = Design.FONT_REGULAR28;
    self.termsOfUseLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.termsOfUseLabel.hidden = YES;
    
    NSMutableDictionary *mutableLinkAttributes = [NSMutableDictionary dictionary];
    [mutableLinkAttributes setObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCTUnderlineStyleAttributeName];
    [mutableLinkAttributes setObject:(__bridge id)[Design.MAIN_COLOR CGColor] forKey:(NSString *)kCTForegroundColorAttributeName];
    self.termsOfUseLabel.linkAttributes = [NSDictionary dictionaryWithDictionary:mutableLinkAttributes];
    
    NSString *headerString = [NSString stringWithFormat:TwinmeLocalizedString(@"welcome_view_accept", nil), TwinmeLocalizedString(@"welcome_view_pass", nil)];
    self.termsOfUseLabel.text = [NSString stringWithFormat:@"%@ %@ - %@", headerString, TwinmeLocalizedString(@"welcome_view_terms_of_use", nil), TwinmeLocalizedString(@"welcome_view_privacy_policy", nil)];
    NSString *termOfUse = TwinmeLocalizedString(@"welcome_view_terms_of_use", nil);
    NSRange termOfUseRange = [self.termsOfUseLabel.text rangeOfString:termOfUse];
    NSURL *termOfUseURL = [NSURL URLWithString:TwinmeLocalizedString(@"welcome_view_terms_of_use_url", nil)];
    self.termsOfUseLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink;
    [self.termsOfUseLabel addLinkToURL:termOfUseURL withRange:termOfUseRange];
    NSString *privacyPolicy = TwinmeLocalizedString(@"welcome_view_privacy_policy", nil);
    NSRange privacyPolicyRange = [self.termsOfUseLabel.text rangeOfString:privacyPolicy];
    NSURL *privacyPolicyURL = [NSURL URLWithString:TwinmeLocalizedString(@"welcome_view_privacy_policy_url", nil)];
    [self.termsOfUseLabel addLinkToURL:privacyPolicyURL withRange:privacyPolicyRange];
    
    self.termsOfUseLabel.delegate = self;
    
    self.backImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.backImageView.tintColor = Design.BLACK_COLOR;
    
    self.backImageView.image = [self.backImageView.image imageFlippedForRightToLeftLayoutDirection];
    
    self.backClickableViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.backClickableViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.backClickableView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *backClickableViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleBackTapGesture:)];
    [self.backClickableView addGestureRecognizer:backClickableViewGestureRecognizer];
    
    self.footerViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)handlePassTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handlePassTapGesture: %@", LOG_TAG, sender);
    
    [self.twinmeApplication hideWelcomeScreen];
    [self finish];
}

- (void)handleBackTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleBackTapGesture: %@", LOG_TAG, sender);
    
    [self.twinmeApplication hideWelcomeScreen];
    [self finish];
}

- (void)handlePrevTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handlePrevTapGesture: %@", LOG_TAG, sender);
    
    NSInteger currentPage = self.welcomePageControl.currentPage;
    
    if (currentPage > 0) {
        [self.welcomeCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:currentPage-1  inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
    }
}

- (void)handleNextTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleNextTapGesture: %@", LOG_TAG, sender);
    
    NSInteger currentPage = self.welcomePageControl.currentPage;
    
    if (currentPage + 1 < self.uiWelcome.count) {
        [self.welcomeCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:currentPage + 1  inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
    } else {
        [self.twinmeApplication hideWelcomeScreen];
        [self askNotification];
    }
}

- (void)handleStartTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleStartTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        self.splashScreenLogoView.hidden = YES;
        self.startView.hidden = YES;
        self.restoreView.hidden = YES;
        self.messageLabel.hidden = YES;
        self.logoView.hidden = NO;
        self.welcomeCollectionView.hidden = NO;
        self.nextClickableView.hidden = NO;
        self.welcomePageControl.hidden = NO;
    }
}

- (void)handleRestoreTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleRestoreTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        AccountMigrationScannerViewController *accountMigrationScannerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AccountMigrationScannerViewController"];
        accountMigrationScannerViewController.fromCurrentDevice = NO;
        [self.navigationController pushViewController:accountMigrationScannerViewController animated:YES];
    }
}

- (void)setupWelcome {
    DDLogVerbose(@"%@ setupWelcome", LOG_TAG);
    
    self.uiWelcome = [[NSMutableArray alloc]init];
    [self.uiWelcome addObject:[[UIWelcome alloc]initWithWelcomePart:WelcomePartOne spaceSettings:[self currentSpaceSettings]]];
    [self.uiWelcome addObject:[[UIWelcome alloc]initWithWelcomePart:WelcomePartTwo spaceSettings:[self currentSpaceSettings]]];
    [self.uiWelcome addObject:[[UIWelcome alloc]initWithWelcomePart:WelcomePartThree spaceSettings:[self currentSpaceSettings]]];
    [self.uiWelcome addObject:[[UIWelcome alloc]initWithWelcomePart:WelcomePartFour spaceSettings:[self currentSpaceSettings]]];
    
    self.welcomePageControl.numberOfPages = self.uiWelcome.count;
    
    WelcomeFlowLayout *viewFlowLayout = [[WelcomeFlowLayout alloc] init];
    [viewFlowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];    
    [viewFlowLayout setMinimumInteritemSpacing:0];
    [viewFlowLayout setMinimumLineSpacing:0];
    [viewFlowLayout setItemSize:CGSizeMake(Design.DISPLAY_WIDTH, self.welcomeCollectionViewHeightConstraint.constant)];
    
    [self.welcomeCollectionView setCollectionViewLayout:viewFlowLayout];
    [self.welcomeCollectionView reloadData];
}

- (void)setupTermsOfUse:(int)currentPage {
    DDLogVerbose(@"%@ setupTermsOfUse", LOG_TAG);
    
    if (currentPage + 1 == WELCOME_STEP_COUNT) {
        NSString *headerString = [NSString stringWithFormat:TwinmeLocalizedString(@"welcome_view_accept", nil), TwinmeLocalizedString(@"welcome_view_start", nil)];
        self.termsOfUseLabel.text = [NSString stringWithFormat:@"%@ %@ - %@", headerString, TwinmeLocalizedString(@"welcome_view_terms_of_use", nil), TwinmeLocalizedString(@"welcome_view_privacy_policy", nil)];
    } else {
        NSString *headerString = [NSString stringWithFormat:TwinmeLocalizedString(@"welcome_view_accept", nil), TwinmeLocalizedString(@"welcome_view_pass", nil)];
        self.termsOfUseLabel.text = [NSString stringWithFormat:@"%@ %@ - %@", headerString, TwinmeLocalizedString(@"welcome_view_terms_of_use", nil), TwinmeLocalizedString(@"welcome_view_privacy_policy", nil)];
    }
    
    NSString *termOfUse = TwinmeLocalizedString(@"welcome_view_terms_of_use", nil);
    NSRange termOfUseRange = [self.termsOfUseLabel.text rangeOfString:termOfUse];
    NSURL *termOfUseURL = [NSURL URLWithString:TwinmeLocalizedString(@"welcome_view_terms_of_use_url", nil)];
    self.termsOfUseLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink;
    [self.termsOfUseLabel addLinkToURL:termOfUseURL withRange:termOfUseRange];
    NSString *privacyPolicy = TwinmeLocalizedString(@"welcome_view_privacy_policy", nil);
    NSRange privacyPolicyRange = [self.termsOfUseLabel.text rangeOfString:privacyPolicy];
    NSURL *privacyPolicyURL = [NSURL URLWithString:TwinmeLocalizedString(@"welcome_view_privacy_policy_url", nil)];
    [self.termsOfUseLabel addLinkToURL:privacyPolicyURL withRange:privacyPolicyRange];
}

- (void)askNotification {
    DDLogVerbose(@"%@ askNotification", LOG_TAG);
    
    ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];    
    [delegate registerNotification:[UIApplication sharedApplication]];
}

- (void)onNotificationsRequestAuthorizationFinish:(NSNotification *)notification {
    DDLogVerbose(@"%@ onNotificationsRequestAuthorizationFinish: %@", LOG_TAG, notification);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self finish];
    });
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.prevLabel.font = Design.FONT_REGULAR34;
    self.nextLabel.font = Design.FONT_BOLD34;
    self.termsOfUseLabel.font = Design.FONT_REGULAR28;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.prevLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.termsOfUseLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.backImageView.tintColor = Design.BLACK_COLOR;
}

@end

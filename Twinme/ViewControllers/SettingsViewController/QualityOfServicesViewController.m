/*
 *  Copyright (c) 2022-2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <UserNotifications/UserNotifications.h>

#import "QualityOfServicesViewController.h"
#import "QualityOfServicesCell.h"
#import "WelcomeFlowLayout.h"
#import "UIQuality.h"

#import <Utils/NSString+Utils.h>

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static UIColor *DESIGN_GREY_COLOR;

static NSString *QUALITY_OF_SERVICES_CELL_IDENTIFIER = @"QualityOfServicesCellIdentifier";

static CGFloat MIN_CONTENT_VIEW_HEIGHT = 258;
static CGFloat MIN_CONTENT_CELL_HEIGHT = 690;
static CGFloat TEXT_MARGIN = 44;

//
// Interface: QualityOfServicesViewController ()
//

@interface QualityOfServicesViewController ()<QualityOfServicesDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *actionViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *actionViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *actionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *slideMarkViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *slideMarkViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *slideMarkViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *slideMarkView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *qualityCollectionViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *qualityCollectionViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UICollectionView *qualityCollectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *qualityPageControlTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *qualityPageControlBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *qualityPageControlWidthConstraint;
@property (weak, nonatomic) IBOutlet UIPageControl *qualityPageControl;

@property (nonatomic) UIView *overlayView;
@property (nonatomic) CGFloat maxCollectionViewHeight;

@property (nonatomic) BOOL isNotificationEnable;
@property (nonatomic) BOOL enableNotificationFromSettings;

@property (nonatomic) NSMutableArray *uiQualities;

@end

//
// Implementation: QualityOfServicesViewController
//

#undef LOG_TAG
#define LOG_TAG @"QualityOfServicesViewController"

@implementation QualityOfServicesViewController

+ (void)initialize {
    DDLogVerbose(@"%@ initialize", LOG_TAG);
    
    DESIGN_GREY_COLOR = [UIColor colorWithRed:142./255. green:142./255. blue:147./255. alpha:1.0];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _enableNotificationFromSettings = NO;
        _maxCollectionViewHeight = 0;
    }
    return self;
}

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getNotificationSettings) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [self initViews];
}

- (void)viewWillAppear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillAppear: %@", LOG_TAG, animated ? @"YES":@"NO");
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillDisappear", LOG_TAG);
    
    [super viewWillDisappear:animated];
}

- (void)showInView:(UIViewController *)view {
    DDLogVerbose(@"%@ showInView: %@", LOG_TAG, view);
    
    self.view.frame = view.view.frame;
    [view addChildViewController:self];
    [view.view addSubview:self.view];
    [self didMoveToParentViewController:view];
    [self initQualityOfServices];
    [self getNotificationSettings];
    [self showActionView];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    
    return UIStatusBarStyleDefault;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    DDLogVerbose(@"%@ numberOfSectionsInCollectionView: %@", LOG_TAG, collectionView);
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ collectionView: %@ numberOfItemsInSection: %ld", LOG_TAG, collectionView, (long)section);

    return self.uiQualities.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ collectionView: %@ layout: %@ sizeForItemAtIndexPath: %@", LOG_TAG, collectionView, collectionViewLayout, indexPath);
    
    return CGSizeMake(Design.DISPLAY_WIDTH, self.qualityCollectionViewHeightConstraint.constant);
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ collectionView: %@ willDisplayCell: %@ forItemAtIndexPath: %@", LOG_TAG, collectionView, cell, indexPath);
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
    
    QualityOfServicesCell *qualityOfServicesCell = [collectionView dequeueReusableCellWithReuseIdentifier:QUALITY_OF_SERVICES_CELL_IDENTIFIER forIndexPath:indexPath];
    qualityOfServicesCell.qualityOfServicesDelegate = self;
    UIQuality *uiQuality = [self.uiQualities objectAtIndex:indexPath.row];
    BOOL hideAction = [uiQuality hideAction] || self.isNotificationEnable;
    [qualityOfServicesCell bindWithQuality:uiQuality hideAction:hideAction];
    return qualityOfServicesCell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    DDLogVerbose(@"%@ scrollViewDidScroll: %@", LOG_TAG, scrollView);
    
    CGFloat offset = scrollView.contentOffset.x;
    CGFloat width = scrollView.frame.size.width;
    CGFloat center = width / 2.0;
    int currentPage = (int) ((offset + center) / width);
    self.qualityPageControl.currentPage = currentPage;
}

#pragma mark - QualityOfServicesDelegate

- (void)didTouchSettings {
    DDLogVerbose(@"%@ didTouchSettings", LOG_TAG);
    
    self.enableNotificationFromSettings = YES;
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
}
    
- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.view.backgroundColor = [UIColor clearColor];
    self.view.isAccessibilityElement = NO;
    
    self.overlayView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Design.DISPLAY_WIDTH, Design.DISPLAY_HEIGHT)];
    self.overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.overlayView.alpha = .0f;
    self.overlayView.userInteractionEnabled = YES;
    self.overlayView.backgroundColor = [UIColor blackColor];
    
    [self.view insertSubview:self.overlayView atIndex:0];
    
    UITapGestureRecognizer *tapOverlayGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCancelTapGesture:)];
    [self.overlayView addGestureRecognizer:tapOverlayGestureRecognizer];
    
    self.actionViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.actionViewBottomConstraint.constant *= Design.WIDTH_RATIO;
    
    self.actionView.hidden = YES;
    self.actionView.userInteractionEnabled = YES;
    self.actionView.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
    self.actionView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    self.actionView.layer.cornerRadius = 40 * Design.HEIGHT_RATIO;
    self.actionView.clipsToBounds = YES;
        
    UISwipeGestureRecognizer *swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleCancelTapGesture:)];
    [swipeGestureRecognizer setDirection:(UISwipeGestureRecognizerDirectionDown)];
    [self.actionView addGestureRecognizer:swipeGestureRecognizer];
    
    self.slideMarkViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.slideMarkViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.slideMarkViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.slideMarkView.backgroundColor = [UIColor colorWithRed:244./255. green:244./255. blue:244./255. alpha:1.0];
    self.slideMarkView.layer.cornerRadius = self.slideMarkViewHeightConstraint.constant * 0.5;
    self.slideMarkView.clipsToBounds = YES;
    
    self.titleLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.titleLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.titleLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.titleLabel.font = Design.FONT_BOLD36;
    self.titleLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.titleLabel.text = TwinmeLocalizedString(@"about_view_controller_quality_of_service", nil);;
        
    self.qualityCollectionViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.qualityCollectionViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.qualityCollectionView.dataSource = self;
    self.qualityCollectionView.delegate = self;
    self.qualityCollectionView.pagingEnabled = YES;
    self.qualityCollectionView.hidden = YES;
    
    self.qualityCollectionView.backgroundColor = [UIColor clearColor];
    [self.qualityCollectionView registerNib:[UINib nibWithNibName:@"QualityOfServicesCell" bundle:nil] forCellWithReuseIdentifier:QUALITY_OF_SERVICES_CELL_IDENTIFIER];
    self.qualityPageControlWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.qualityPageControlTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.qualityPageControlBottomConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.qualityPageControl.pageIndicatorTintColor = [UIColor colorWithRed:244./255. green:244./255. blue:244./255. alpha:1.0];
    self.qualityPageControl.currentPageIndicatorTintColor = Design.MAIN_COLOR;
    self.qualityPageControl.numberOfPages = 3;
    
    self.qualityPageControl.transform = CGAffineTransformMakeScale(1.2, 1.2);    
}

- (void)initQualityOfServices {
    DDLogVerbose(@"%@ initQualityOfServices", LOG_TAG);
    
    self.uiQualities = [[NSMutableArray alloc]init];

    [self.uiQualities addObject:[[UIQuality alloc]initWithQualityOfServicesPart:QualityOfServicesPartOne spaceSettings:[self currentSpaceSettings]]];
    [self.uiQualities addObject:[[UIQuality alloc]initWithQualityOfServicesPart:QualityOfServicesPartTwo spaceSettings:[self currentSpaceSettings]]];
    [self.uiQualities addObject:[[UIQuality alloc]initWithQualityOfServicesPart:QualityOfServicesPartThree spaceSettings:[self currentSpaceSettings]]];
    
    CGFloat titleWidth = Design.DISPLAY_WIDTH - (self.titleLabelLeadingConstraint.constant * 2);
    CGRect titleRect = [self.titleLabel.text boundingRectWithSize:CGSizeMake(titleWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{
        NSFontAttributeName : Design.FONT_BOLD36
    } context:nil];
    
    CGFloat maxCollectionViewHeight = Design.DISPLAY_HEIGHT - (MIN_CONTENT_VIEW_HEIGHT * Design.HEIGHT_RATIO) - titleRect.size.height;
    CGFloat textWidth = Design.DISPLAY_WIDTH - (TEXT_MARGIN * Design.WIDTH_RATIO * 2);
    CGFloat minContentCell = (MIN_CONTENT_CELL_HEIGHT * Design.HEIGHT_RATIO);
    
    CGFloat collectionViewHeight = 0;
    for (UIQuality *uiQuality in self.uiQualities) {
        
        CGRect textRect = [[uiQuality getMessage] boundingRectWithSize:CGSizeMake(textWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{
            NSFontAttributeName : Design.FONT_MEDIUM32
        } context:nil];
        
        CGFloat cellContentHeight = minContentCell + textRect.size.height;
        
        if (cellContentHeight > collectionViewHeight) {
            collectionViewHeight = cellContentHeight;
        }
    }
    
    if (collectionViewHeight > maxCollectionViewHeight) {
        collectionViewHeight = maxCollectionViewHeight;
    }
    
    self.qualityCollectionViewHeightConstraint.constant = collectionViewHeight;
    
    [self setupCollection];
}

- (void)setupCollection {
    DDLogVerbose(@"%@ setupCollection", LOG_TAG);
    
    WelcomeFlowLayout *viewFlowLayout = [[WelcomeFlowLayout alloc] init];
    [viewFlowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [viewFlowLayout setMinimumInteritemSpacing:0];
    [viewFlowLayout setMinimumLineSpacing:0];
    [viewFlowLayout setItemSize:CGSizeMake(Design.DISPLAY_WIDTH, self.qualityCollectionViewHeightConstraint.constant)];
    [self.qualityCollectionView setCollectionViewLayout:viewFlowLayout];
    self.qualityCollectionView.hidden = NO;
}

- (void)handleCancelTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleCancelTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self closeActionView];
    }
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
        
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [self removeFromParentViewController];
    [self.view removeFromSuperview];
}

- (void)handleSettingsTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleSettingsTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
    }
}

- (void)getNotificationSettings {
    DDLogVerbose(@"%@ getNotificationSettings", LOG_TAG);
            
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings *settings){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (settings.authorizationStatus != UNAuthorizationStatusAuthorized) {
                self.isNotificationEnable = NO;
            } else {
                self.isNotificationEnable = YES;
            }
            
            if (self.enableNotificationFromSettings) {
                self.enableNotificationFromSettings = NO;
                
                if (self.isNotificationEnable) {
                    [self.qualityCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.uiQualities.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
                }
            }
            
            [self.qualityCollectionView reloadData];
        });
    }];
}

- (void)showActionView {
    DDLogVerbose(@"%@ showActionView", LOG_TAG);
    
    self.actionView.frame = CGRectMake(0, Design.DISPLAY_HEIGHT, Design.DISPLAY_WIDTH, self.actionView.frame.size.height);
    self.actionView.hidden = NO;

    [UIView animateWithDuration:Design.ANIMATION_VIEW_DURATION
                          delay:0
                        options:0
                     animations:^{
        self.overlayView.alpha = 0.3f;
        self.actionView.frame = CGRectMake(0, Design.DISPLAY_HEIGHT - self.actionView.frame.size.height, Design.DISPLAY_WIDTH, self.actionView.frame.size.height);
    }
                     completion:^(BOOL finished) {
    }];
}

- (void)closeActionView {
    DDLogVerbose(@"%@ closeActionView", LOG_TAG);
    
    [UIView animateWithDuration:Design.ANIMATION_VIEW_DURATION
                          delay:0
                        options:0
                     animations:^{
        self.overlayView.alpha = 0.f;
        self.actionView.frame = CGRectMake(0, Design.DISPLAY_HEIGHT, Design.DISPLAY_WIDTH, self.actionView.frame.size.height);
    }
                     completion:^(BOOL finished) {
        [self finish];
    }];
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.titleLabel.font = Design.FONT_BOLD36;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.titleLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.actionView.backgroundColor = Design.POPUP_BACKGROUND_COLOR;}

@end

/*
 *  Copyright (c) 2022-2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "WhatsNewViewController.h"

#import "CustomProgressBarView.h"

#import <Utils/NSString+Utils.h>

#import <TwinmeCommon/Design.h>

#import "LastVersionManager.h"
#import "LastVersion.h"
#import "UIWhatsNew.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static const CGFloat DESIGN_CUSTOM_PROGRESS_MARGIN = 10;

//
// Interface: WhatsNewViewController ()
//

@interface WhatsNewViewController () <CustomProgressBarDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *actionViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *actionViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *actionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *slideMarkViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *slideMarkViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *slideMarkViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *slideMarkView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressContainerViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressContainerViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressContainerViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressContainerViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *progressContainerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *updateImageViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *updateImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *updateImageViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *updateImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *confirmViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *confirmViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *confirmViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *confirmViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *confirmLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *confirmView;
@property (weak, nonatomic) IBOutlet UILabel *confirmLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *cancelView;
@property (weak, nonatomic) IBOutlet UILabel *cancelLabel;

@property (nonatomic) UIView *overlayView;

@property (nonatomic) NSMutableArray *uiWhatsNew;
@property (nonatomic) NSMutableArray *customProgressBarView;
@property (nonatomic) NSMutableArray *imagesToDwonload;
@property (nonatomic) int currentWhatsNew;
@property (nonatomic) int showAllWhatsNew;

@property (nonatomic) BOOL initViewHeight;

@end

//
// Implementation: WhatsNewViewController
//

#undef LOG_TAG
#define LOG_TAG @"WhatsNewViewController"

@implementation WhatsNewViewController

#pragma mark - UIViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _initViewHeight = NO;
        _showAllWhatsNew = NO;
        _updateMode = NO;
        _currentWhatsNew = -1;
        _uiWhatsNew = [[NSMutableArray alloc]init];
        _imagesToDwonload = [[NSMutableArray alloc]init];
        _customProgressBarView = [[NSMutableArray alloc]init];
    }
    return self;
}

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
    
    [self initViews];
}

- (void)showInView:(UIViewController *)view {
    DDLogVerbose(@"%@ showInView: %@", LOG_TAG, view);
    
    self.view.frame = view.view.frame;
    [view addChildViewController:self];
    [view.view addSubview:self.view];
    [self didMoveToParentViewController:view];
    [self showActionView];
}

#pragma mark - CustomProgressBarDelegate

- (void)customProgressBarEndAnimation:(CustomProgressBarView *)customProgressBarView {
    DDLogVerbose(@"%@ customProgressBarEndAnimation: %@", LOG_TAG, customProgressBarView);
    
    [self nextWhatsNew];
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.view.backgroundColor = [UIColor clearColor];
    self.view.isAccessibilityElement = NO;
    
    self.overlayView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Design.DISPLAY_WIDTH, Design.DISPLAY_HEIGHT)];
    self.overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.overlayView.alpha = .0f;
    self.overlayView.backgroundColor = [UIColor blackColor];
    self.overlayView.userInteractionEnabled = YES;
    
    [self.view insertSubview:self.overlayView atIndex:0];
    
    UITapGestureRecognizer *tapOverlayGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCloseTapGesture:)];
    [self.overlayView addGestureRecognizer:tapOverlayGestureRecognizer];
    
    self.actionViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.actionViewBottomConstraint.constant *= Design.WIDTH_RATIO;
    
    self.actionView.hidden = YES;
    self.actionView.userInteractionEnabled = YES;
    self.actionView.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
    self.actionView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    self.actionView.layer.cornerRadius = 40 * Design.HEIGHT_RATIO;
    self.actionView.clipsToBounds = YES;
        
    UISwipeGestureRecognizer *swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleCloseTapGesture:)];
    [swipeGestureRecognizer setDirection:(UISwipeGestureRecognizerDirectionDown)];
    [self.actionView addGestureRecognizer:swipeGestureRecognizer];
    
    self.slideMarkViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.slideMarkViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.slideMarkViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.slideMarkView.backgroundColor = [UIColor colorWithRed:244./255. green:244./255. blue:244./255. alpha:1.0];
    self.slideMarkView.layer.cornerRadius = self.slideMarkViewHeightConstraint.constant * 0.5;
    self.slideMarkView.clipsToBounds = YES;
    
    self.progressContainerViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.progressContainerViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.progressContainerViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.progressContainerViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.progressContainerView.backgroundColor = [UIColor clearColor];
    self.progressContainerView.hidden = YES;
        
    self.titleLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.titleLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.titleLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.titleLabel.font = Design.FONT_BOLD36;
    self.titleLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.titleLabel.text = @"";
    
    self.updateImageViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.updateImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.updateImageViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.updateImageView.userInteractionEnabled = YES;
    [self.updateImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleImageTapGesture:)]];

    self.messageLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.messageLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.messageLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.messageLabel.font = Design.FONT_MEDIUM34;
    self.messageLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.messageLabel.text = @"";
    
    self.confirmViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.confirmViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.confirmViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.confirmViewWidthConstraint.constant *= Design.WIDTH_RATIO;
        
    self.confirmView.backgroundColor = Design.MAIN_COLOR;
    self.confirmView.userInteractionEnabled = YES;
    self.confirmView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.confirmView.clipsToBounds = YES;
    self.confirmView.isAccessibilityElement = YES;
    [self.confirmView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleConfirmTapGesture:)]];
    
    self.confirmLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
        
    self.confirmLabel.font = Design.FONT_BOLD36;
    self.confirmLabel.textColor = [UIColor whiteColor];
    self.confirmLabel.text = TwinmeLocalizedString(@"application_ok", nil);
    
    self.cancelViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    UITapGestureRecognizer *cancelViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCloseTapGesture:)];
    [self.cancelView addGestureRecognizer:cancelViewGestureRecognizer];
    
    UIWindow *window = UIApplication.sharedApplication.keyWindow;
    self.cancelViewBottomConstraint.constant = window.safeAreaInsets.bottom;

    self.cancelLabel.font = Design.FONT_BOLD36;
    self.cancelLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.cancelLabel.text = TwinmeLocalizedString(@"application_later", nil);
    
    if (self.updateMode) {
        self.cancelView.hidden = NO;
    } else {
        self.cancelView.hidden = YES;
        self.confirmViewBottomConstraint.constant *= 0.5f;
        self.cancelViewBottomConstraint.constant = 0;
        self.cancelViewHeightConstraint.constant = 0;
    }
    
    [self initLastVersion];
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
        
    for (CustomProgressBarView *customProgressBarView in self.customProgressBarView) {
        [customProgressBarView stopAnimation];
    }
        
    [self removeFromParentViewController];
    [self.view removeFromSuperview];
}

- (void)showActionView {
    DDLogVerbose(@"%@ showActionView", LOG_TAG);
    
    [self updateFont];
    [self updateColor];
    
    self.actionView.frame = CGRectMake(0, Design.DISPLAY_HEIGHT, Design.DISPLAY_WIDTH, self.actionView.frame.size.height);
    self.actionView.hidden = NO;

    [UIView animateWithDuration:Design.ANIMATION_VIEW_DURATION
                          delay:0
                        options:0
                     animations:^{
        self.overlayView.alpha = 0.3f;
        self.actionView.frame = CGRectMake(0, Design.DISPLAY_HEIGHT - self.actionView.frame.size.height, Design.DISPLAY_WIDTH, self.actionView.frame.size.height);
    }
                     completion:nil];
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

- (void)handleImageTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleImageTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        
        if (self.uiWhatsNew.count != 1) {
            
            if (self.currentWhatsNew < self.customProgressBarView.count) {
                CustomProgressBarView *customProgressBarView = [self.customProgressBarView objectAtIndex:self.currentWhatsNew];
                [customProgressBarView stopAnimation];
            }
            
            [self nextWhatsNew];
        }
    }
}

- (void)handleConfirmTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleConfirmTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        if (self.showAllWhatsNew) {
            if (self.updateMode) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:TwinmeLocalizedString(@"twinme_link", nil)] options:@{} completionHandler:nil];
            } else {
                [self closeActionView];
            }
        } else {
            if (self.currentWhatsNew < self.customProgressBarView.count) {
                CustomProgressBarView *customProgressBarView = [self.customProgressBarView objectAtIndex:self.currentWhatsNew];
                [customProgressBarView stopAnimation];
            }
            
            [self nextWhatsNew];
        }
    }
}

- (void)handleCloseTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleCloseTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        if (self.showAllWhatsNew) {
            [self closeActionView];
        } else {
            if (self.currentWhatsNew < self.customProgressBarView.count) {
                CustomProgressBarView *customProgressBarView = [self.customProgressBarView objectAtIndex:self.currentWhatsNew];
                [customProgressBarView stopAnimation];
            }
            
            [self nextWhatsNew];
        }
    }
}

- (void)nextWhatsNew {
    DDLogVerbose(@"%@ nextWhatsNew", LOG_TAG);
    
    self.currentWhatsNew++;
    
    if (self.currentWhatsNew == self.uiWhatsNew.count) {
        self.currentWhatsNew = 0;
        
        for (CustomProgressBarView *customProgressBarView in self.customProgressBarView) {
            [customProgressBarView resetAnimation];
        }
    }
        
    if (self.currentWhatsNew < self.uiWhatsNew.count) {
        UIWhatsNew *uiWhatsNew = [self.uiWhatsNew objectAtIndex:self.currentWhatsNew];
        self.updateImageView.image = uiWhatsNew.image;
        self.messageLabel.text = uiWhatsNew.message;
        
        if (self.currentWhatsNew < self.customProgressBarView.count) {
            CustomProgressBarView *customProgressBarView = [self.customProgressBarView objectAtIndex:self.currentWhatsNew];
            [customProgressBarView startAnimation];
        }
    }
    
    if (self.currentWhatsNew + 1 == self.uiWhatsNew.count) {
        self.confirmLabel.text = self.updateMode ? TwinmeLocalizedString(@"update_app_view_controller_update_title", nil) : TwinmeLocalizedString(@"application_ok", nil);
        self.showAllWhatsNew = YES;
    }
}

- (void)initLastVersion {
    DDLogVerbose(@"%@ initLastVersion", LOG_TAG);
    
    LastVersion *lastVersion = self.twinmeApplication.lastVersionManager.lastVersion;
    
    if (!lastVersion) {
        [self closeActionView];
    }
    
    self.titleLabel.text = lastVersion.versionNumber;
    
    NSMutableArray *messages = [[NSMutableArray alloc]init];
    
    if (self.updateMode || [self.twinmeApplication.lastVersionManager isMajorVersionWithUpdate:self.updateMode]) {
        [messages addObjectsFromArray:lastVersion.majorChanges];
    } else {
        [messages addObjectsFromArray:lastVersion.minorChanges];
    }
    
    for (NSString *message in messages) {
        UIWhatsNew *whatsNew = [[UIWhatsNew alloc]initWithImage:nil message:message];
        [self.uiWhatsNew addObject:whatsNew];
    }
    
    BOOL darkMode = [self.twinmeApplication darkModeEnable];
    
    if (darkMode && lastVersion.updateImagesDark.count > 0) {
        [self.imagesToDwonload addObjectsFromArray:lastVersion.updateImagesDark];
    } else {
        [self.imagesToDwonload addObjectsFromArray:lastVersion.updateImages];
    }
    
    if (self.imagesToDwonload.count > 0 && self.imagesToDwonload.count == self.uiWhatsNew.count) {
        [self downloadImage:[NSURL URLWithString:[self.imagesToDwonload objectAtIndex:0]]];
    } else {
        self.updateImageViewHeightConstraint.constant = 0;
        self.updateImageViewTopConstraint.constant = 0;
        
        [self updateViews];
    }
}

- (void)updateViews {
    DDLogVerbose(@"%@ updateViews", LOG_TAG);
    
    CGFloat textWidth = Design.DISPLAY_WIDTH - self.messageLabelLeadingConstraint.constant - self.messageLabelTrailingConstraint.constant;
    
    if (self.uiWhatsNew.count == 1) {
        self.showAllWhatsNew = YES;
                
        UIWhatsNew *uiWhatsNew = [self.uiWhatsNew firstObject];
        self.updateImageView.image = uiWhatsNew.image;
        self.messageLabel.text = uiWhatsNew.message;
        
        self.progressContainerViewHeightConstraint.constant = 0;
        self.progressContainerViewTopConstraint.constant = 0;
        self.progressContainerView.hidden = YES;
        self.confirmLabel.text = self.updateMode ? TwinmeLocalizedString(@"update_app_view_controller_update_title", nil) : TwinmeLocalizedString(@"application_ok", nil);
        
        CGRect messageRect = [uiWhatsNew.message boundingRectWithSize:CGSizeMake(textWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{
            NSFontAttributeName : Design.FONT_MEDIUM34
        } context:nil];
        
        self.messageLabelHeightConstraint.constant = messageRect.size.height;
        
    } else {
        self.progressContainerView.hidden = NO;
        self.confirmLabel.text = TwinmeLocalizedString(@"welcome_view_controller_next", nil);
        
        CGFloat customBarMargin = DESIGN_CUSTOM_PROGRESS_MARGIN * Design.WIDTH_RATIO;
        CGFloat customBarProgressWidth = (Design.DISPLAY_WIDTH - self.progressContainerViewLeadingConstraint.constant - self.progressContainerViewTrailingConstraint.constant - ((self.uiWhatsNew.count - 1) * customBarMargin)) / self.uiWhatsNew.count;
        
        CGFloat textMaxHeight = 0;
        int index = 0;
        for (UIWhatsNew *whatsNew in self.uiWhatsNew) {
            
            CGRect messageRect = [whatsNew.message boundingRectWithSize:CGSizeMake(textWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{
                NSFontAttributeName : Design.FONT_MEDIUM34
            } context:nil];
            
            if (messageRect.size.height > textMaxHeight) {
                textMaxHeight = messageRect.size.height;
            }
            
            CGFloat x = index == 0 ? 0 : index * customBarProgressWidth + (customBarMargin * index);
            CGRect frame = CGRectMake(x, 0, customBarProgressWidth, self.progressContainerViewHeightConstraint.constant);
            CustomProgressBarView *customBarProgressView = [[CustomProgressBarView alloc]initWithFrame:frame];
            customBarProgressView.isDarkMode = [self.twinmeApplication darkModeEnable];
            customBarProgressView.customProgressBarDelegate = self;
            [self.customProgressBarView addObject:customBarProgressView];
            [self.progressContainerView addSubview:customBarProgressView];
            
            index++;
        }
        
        self.messageLabelHeightConstraint.constant = textMaxHeight;
        
        [self nextWhatsNew];
    }
}

- (void)downloadImage:(NSURL *)url {
    DDLogVerbose(@"%@ downloadImage: %@", LOG_TAG, url);
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    NSURLSessionConfiguration *urlSessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:urlSessionConfiguration delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *urlSessionDataTask = [urlSession dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            UIImage *image = [UIImage imageWithData:data];
            [self updateWhatsNew:image];
        } else {
            [self updateWhatsNew:nil];
        }
    }];
    [urlSessionDataTask resume];
}

- (void)updateWhatsNew:(UIImage *)image {
    DDLogVerbose(@"%@ updateWhatsNew: %@", LOG_TAG, image);
    
    UIWhatsNew *whatsNewToUpdate;
    
    for (UIWhatsNew *whatsNew in self.uiWhatsNew) {
        if (!whatsNew.image) {
            whatsNewToUpdate = whatsNew;
            break;
        }
    }
    
    if (whatsNewToUpdate) {
        if (image) {
            whatsNewToUpdate.image = image;
        } else {
            whatsNewToUpdate.image = [UIImage imageNamed:@"SplashScreenLogo"];
        }
    }
    
    if (self.imagesToDwonload.count > 1) {
        [self.imagesToDwonload removeObjectAtIndex:0];
        [self downloadImage:[NSURL URLWithString:[self.imagesToDwonload objectAtIndex:0]]];
    } else {
        [self.imagesToDwonload removeAllObjects];
        [self updateViews];
    }
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.messageLabel.font = Design.FONT_MEDIUM34;
    self.titleLabel.font = Design.FONT_BOLD44;
    self.confirmLabel.font = Design.FONT_BOLD36;
    self.cancelLabel.font = Design.FONT_BOLD36;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.actionView.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
    self.messageLabel.textColor = Design.FONT_COLOR_GREY;
    self.titleLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.cancelLabel.textColor = Design.FONT_COLOR_DEFAULT;
}

@end

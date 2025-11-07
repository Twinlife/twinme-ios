/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Utils/NSString+Utils.h>

#import "MenuCleanUpExpirationView.h"
#import "CustomTabView.h"

#import "ExpirationDateCell.h"
#import "ExpirationPeriodCell.h"

#import "UICleanUpExpiration.h"
#import "UICustomTab.h"

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static const CGFloat DESIGN_DATE_CELL_HEIGHT = 600;
static const CGFloat DESIGN_PERIOD_CELL_HEIGHT = 100;

static NSString *EXPIRATION_PERIOD_CELL_IDENTIFIER = @"ExpirationPeriodCellIdentifier";
static NSString *EXPIRATION_DATE_CELL_IDENTIFIER = @"ExpirationDateCellIdentifier";

//
// Interface: MenuCleanUpExpirationView ()
//

@interface MenuCleanUpExpirationView ()<CAAnimationDelegate, UITableViewDelegate, UITableViewDataSource, ExpirationDateDelegate, CustomTabViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *customTabViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *customTabViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *customTabContainerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *expirationTableViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UITableView *expirationTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *confirmViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *confirmViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *confirmViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *confirmView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *confirmLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *confirmLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *cancelView;
@property (weak, nonatomic) IBOutlet UILabel *cancelLabel;

@property (nonatomic) CustomTabView *customTabView;

@property (nonatomic) NSMutableArray *expirationsType;
@property (nonatomic) NSMutableArray *expirationsPeriod;

@property (nonatomic) UICleanUpExpiration *uiCleanUpExpiration;

@end

//
// Implementation: MenuCleanUpExpirationView
//

#undef LOG_TAG
#define LOG_TAG @"MenuCleanUpExpirationView"

@implementation MenuCleanUpExpirationView

#pragma mark - UIView

- (instancetype)init {
    DDLogVerbose(@"%@ init", LOG_TAG);
    
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"MenuCleanUpExpirationView" owner:self options:nil];
    self = [objects objectAtIndex:0];
    
    self.frame = CGRectMake(0, 0, Design.DISPLAY_WIDTH, Design.DISPLAY_HEIGHT);
        
    self.expirationsType = [[NSMutableArray alloc]init];
    self.expirationsPeriod = [[NSMutableArray alloc]init];
    
    if (self) {
        [self initViews];
    }
    
    return self;
}

- (void)openMenu:(UICleanUpExpiration *)uiCleanUpExpiration {
    DDLogVerbose(@"%@ openMenu", LOG_TAG);
    
    self.uiCleanUpExpiration = uiCleanUpExpiration;
    
    [self initCustomTab];
    
    [super openMenu];
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ heightForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if (self.uiCleanUpExpiration.expirationType == ExpirationTypeDate) {
        return DESIGN_DATE_CELL_HEIGHT * Design.HEIGHT_RATIO;
    }
    return DESIGN_PERIOD_CELL_HEIGHT * Design.HEIGHT_RATIO;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    DDLogVerbose(@"%@ numberOfSectionsInTableView: %@", LOG_TAG, tableView);
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ numberOfRowsInSection: %ld", LOG_TAG, tableView, (long)section);
    
    if (self.uiCleanUpExpiration.expirationType == ExpirationTypeValue) {
        return self.expirationsPeriod.count;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ cellForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if (self.uiCleanUpExpiration.expirationType == ExpirationTypeDate) {
        ExpirationDateCell *cell = [tableView dequeueReusableCellWithIdentifier:EXPIRATION_DATE_CELL_IDENTIFIER];
        if (!cell) {
            cell = [[ExpirationDateCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:EXPIRATION_DATE_CELL_IDENTIFIER];
        }
        
        cell.expirationDateDelegate = self;
        [cell bind];
        
        return cell;
    } else {
        ExpirationPeriodCell *cell = [tableView dequeueReusableCellWithIdentifier:EXPIRATION_PERIOD_CELL_IDENTIFIER];
        if (!cell) {
            cell = [[ExpirationPeriodCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:EXPIRATION_PERIOD_CELL_IDENTIFIER];
        }
        
        UICleanUpExpiration *expiration;
        BOOL hideSeparator = indexPath.row + 1 == self.expirationsPeriod.count ? YES : NO;;
        expiration = [self.expirationsPeriod objectAtIndex:indexPath.row];
        BOOL checked = expiration.expirationPeriod == self.uiCleanUpExpiration.expirationPeriod;
        [cell bindWithExpiration:expiration displayValue:YES checked:checked hideSeparator:hideSeparator];
        
        return cell;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ didSelectRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if (self.uiCleanUpExpiration.expirationType == ExpirationTypeValue) {
        self.uiCleanUpExpiration = [self.expirationsPeriod objectAtIndex:indexPath.row];
        [self.expirationTableView reloadData];
    }
}

#pragma mark - ExpirationDateDelegate

- (void)didChangeDate:(NSDate *)date {
    DDLogVerbose(@"%@ didChangeDate: %@", LOG_TAG, date);

    [self.uiCleanUpExpiration setExpirationDate:date];
}

#pragma mark - CustomTabViewDelegate

- (void)didSelectTab:(UICustomTab *)uiCustomTab {
    DDLogVerbose(@"%@ didSelectTab: %@", LOG_TAG, uiCustomTab);
        
    if (uiCustomTab.tag == ExpirationTypeDate) {
        [self.uiCleanUpExpiration setExpirationType:ExpirationTypeDate];
        self.expirationTableViewHeightConstraint.constant = DESIGN_DATE_CELL_HEIGHT * Design.HEIGHT_RATIO;
    } else {
        [self.uiCleanUpExpiration setExpirationType:ExpirationTypeValue];
        self.expirationTableViewHeightConstraint.constant = DESIGN_PERIOD_CELL_HEIGHT * Design.HEIGHT_RATIO * self.expirationsPeriod.count;
    }
    
    [self.expirationTableView reloadData];
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    [super initViews];
    
    self.userInteractionEnabled = YES;
    
    self.titleLabel.text = TwinmeLocalizedString(@"cleanup_view_controller_expiration", nil);
    
    self.customTabViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.customTabViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
            
    self.expirationTableView.delegate = self;
    self.expirationTableView.dataSource = self;
    self.expirationTableView.bounces = NO;
    self.expirationTableView.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
    self.expirationTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.expirationTableView registerNib:[UINib nibWithNibName:@"ExpirationDateCell" bundle:nil] forCellReuseIdentifier:EXPIRATION_DATE_CELL_IDENTIFIER];
    [self.expirationTableView registerNib:[UINib nibWithNibName:@"ExpirationPeriodCell" bundle:nil] forCellReuseIdentifier:EXPIRATION_PERIOD_CELL_IDENTIFIER];
    
    [self initExpirations];
    
    self.expirationTableViewHeightConstraint.constant = DESIGN_PERIOD_CELL_HEIGHT * Design.HEIGHT_RATIO * self.expirationsPeriod.count;
    
    self.confirmViewTopConstraint.constant *= Design.HEIGHT_RATIO;
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
    self.confirmLabel.text = TwinmeLocalizedString(@"application_save", nil);
    
    self.cancelViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    UITapGestureRecognizer *cancelViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCancelTapGesture:)];
    [self.cancelView addGestureRecognizer:cancelViewGestureRecognizer];
    
    UIWindow *window = UIApplication.sharedApplication.keyWindow;
    self.cancelViewBottomConstraint.constant = window.safeAreaInsets.bottom;
    
    self.cancelLabel.font = Design.FONT_MEDIUM38;
    self.cancelLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.cancelLabel.text = TwinmeLocalizedString(@"application_cancel", nil);
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
        
    if ([self.menuCleanUpExpirationDelegate respondsToSelector:@selector(menuCleanUpExpirationCancel:)]) {
        [self.menuCleanUpExpirationDelegate menuCleanUpExpirationCancel:self];
    }
}

- (void)initCustomTab {
    DDLogVerbose(@"%@ initCustomTab", LOG_TAG);
    
    NSMutableArray *customTabs = [[NSMutableArray alloc]init];
    
    [customTabs addObject:[[UICustomTab alloc]initWithTitle:TwinmeLocalizedString(@"cleanup_view_controller_older_than", nil) tag:ExpirationTypeValue isSelected:self.uiCleanUpExpiration.expirationType == ExpirationTypeValue]];
    [customTabs addObject:[[UICustomTab alloc]initWithTitle:TwinmeLocalizedString(@"cleanup_view_controller_prior_to", nil) tag:ExpirationTypeDate isSelected:self.uiCleanUpExpiration.expirationType == ExpirationTypeDate]];
    
    self.customTabView = [[CustomTabView alloc] initWithCustomTab:customTabs];
    self.customTabView.customTabViewDelegate = self;
    [self.customTabView updateColor:Design.POPUP_BACKGROUND_COLOR mainColor:Design.GREY_BACKGROUND_COLOR textSelectedColor:Design.BLACK_COLOR borderColor:Design.GREY_BACKGROUND_COLOR];
    [self.customTabContainerView addSubview:self.customTabView];
}

- (void)initExpirations {
    DDLogVerbose(@"%@ initExpirations", LOG_TAG);
    
    [self.expirationsType addObject:[[UICleanUpExpiration alloc]initWithExpirationType:ExpirationTypeAll expirationDate:nil]];
    [self.expirationsType addObject:[[UICleanUpExpiration alloc]initWithExpirationType:ExpirationTypeValue expirationDate:nil]];
    [self.expirationsType addObject:[[UICleanUpExpiration alloc]initWithExpirationType:ExpirationTypeDate expirationDate:nil]];
    
    [self.expirationsPeriod addObject:[[UICleanUpExpiration alloc]initWithExpirationType:ExpirationTypeValue expirationPeriod:ExpirationPeriodOneDay]];
    [self.expirationsPeriod addObject:[[UICleanUpExpiration alloc]initWithExpirationType:ExpirationTypeValue expirationPeriod:ExpirationPeriodOneWeek]];
    [self.expirationsPeriod addObject:[[UICleanUpExpiration alloc]initWithExpirationType:ExpirationTypeValue expirationPeriod:ExpirationPeriodOneMonth]];
    [self.expirationsPeriod addObject:[[UICleanUpExpiration alloc]initWithExpirationType:ExpirationTypeValue expirationPeriod:ExpirationPeriodThreeMonths]];
    [self.expirationsPeriod addObject:[[UICleanUpExpiration alloc]initWithExpirationType:ExpirationTypeValue expirationPeriod:ExpirationPeriodSixMonths]];
    [self.expirationsPeriod addObject:[[UICleanUpExpiration alloc]initWithExpirationType:ExpirationTypeValue expirationPeriod:ExpirationPeriodOneYear]];
}

- (void)handleCancelTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleCancelTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self closeMenu];
    }
}

- (void)handleConfirmTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleConfirmTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        if ([self.menuCleanUpExpirationDelegate respondsToSelector:@selector(menuCleanUpExpirationSelectExpiration:uiCleanUpExpiration:)]) {
            [self.menuCleanUpExpirationDelegate menuCleanUpExpirationSelectExpiration:self uiCleanUpExpiration:self.uiCleanUpExpiration];
        }
    }
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    [self.expirationTableView reloadData];
    self.cancelLabel.font = Design.FONT_BOLD34;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    [super updateColor];
    
    self.expirationTableView.backgroundColor = Design.FONT_COLOR_RED;
    self.cancelLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.confirmView.backgroundColor = Design.MAIN_COLOR;
}

@end

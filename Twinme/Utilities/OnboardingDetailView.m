/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "OnboardingDetailView.h"

#import <Utils/NSString+Utils.h>

#import <TwinmeCommon/Design.h>

#import "OnboardingDetailCell.h"
#import "UIPremiumFeature.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static NSString *ONBOARDING_DETAIL_CELL_IDENTIFIER = @"OnboardingDetailCellIdentifier";

static CGFloat DESIGN_CELL_HEIGHT = 100.f;

//
// Interface: OnboardingDetailView ()
//

@interface OnboardingDetailView ()<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) UIPremiumFeature *premiumFeature;

@end

//
// Implementation: OnboardingDetailView
//

#undef LOG_TAG
#define LOG_TAG @"OnboardingDetailView"

@implementation OnboardingDetailView

#pragma mark - UIView

- (instancetype)init {
    DDLogVerbose(@"%@ init", LOG_TAG);
    
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"OnboardingDetailView" owner:self options:nil];
    self = [objects objectAtIndex:0];
    
    self.frame = CGRectMake(0, 0, Design.DISPLAY_WIDTH, Design.DISPLAY_HEIGHT);
    
    if (self) {
        [self initViews];
    }
    return self;
}

- (void)initWithPremiumFeature:(nonnull UIPremiumFeature *)premiumFeature {
    DDLogVerbose(@"%@ initWithPremiumFeature: %@", LOG_TAG, premiumFeature);
    
    self.premiumFeature = premiumFeature;
    self.tableViewHeightConstraint.constant = self.premiumFeature.featureDetails.count * roundf(DESIGN_CELL_HEIGHT * Design.HEIGHT_RATIO);
    [self initWithTitle:[premiumFeature getTitle] message:[premiumFeature getSubTitle] image:[premiumFeature getImage] action:TwinmeLocalizedString(@"application_ok", nil) actionColor:nil cancel:TwinmeLocalizedString(@"application_do_not_display", nil)];
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ heightForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    return roundf(DESIGN_CELL_HEIGHT * Design.HEIGHT_RATIO);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    DDLogVerbose(@"%@ numberOfSectionsInTableView: %@", LOG_TAG, tableView);
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ numberOfRowsInSection: %ld", LOG_TAG, tableView, (long)section);
    
    return self.premiumFeature.featureDetails.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ cellForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    OnboardingDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:ONBOARDING_DETAIL_CELL_IDENTIFIER];
    if (!cell) {
        cell = [[OnboardingDetailCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ONBOARDING_DETAIL_CELL_IDENTIFIER];
    }
    
    UIPremiumFeatureDetail *premiumFeatureDetail = [self.premiumFeature.featureDetails objectAtIndex:indexPath.row];
    [cell bindWithPremiumFeatureDetail:premiumFeatureDetail];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ didSelectRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);

}

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    [super initViews];
    
    self.tableViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.tableViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.tableView.scrollEnabled = NO;
    self.tableView.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"OnboardingDetailCell" bundle:nil] forCellReuseIdentifier:ONBOARDING_DETAIL_CELL_IDENTIFIER];
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    [super updateColor];
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    [super updateFont];
}

@end

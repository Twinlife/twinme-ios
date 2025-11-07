/*
 *  Copyright (c) 2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Utils/NSString+Utils.h>

#import "AnnotationsView.h"
#import "AnnotationInfoCell.h"

#import <TwinmeCommon/Design.h>

#import "UIAnnotation.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static NSString *ANNOTATION_INFO_CELL_IDENTIFIER = @"AnnotationInfoCellIdentifier";

//
// Interface: AnnotationsView ()
//

@interface AnnotationsView ()<CAAnimationDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) int selectedValue;

@property (nonatomic) NSMutableArray *annotationsArray;

@end

//
// Implementation: AnnotationsView
//

#undef LOG_TAG
#define LOG_TAG @"AnnotationsView"

@implementation AnnotationsView

#pragma mark - UIView

- (instancetype)init {
    DDLogVerbose(@"%@ init", LOG_TAG);
    
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"AnnotationsView" owner:self options:nil];
    self = [objects objectAtIndex:0];
    
    self.frame = CGRectMake(0, 0, Design.DISPLAY_WIDTH, Design.DISPLAY_HEIGHT);
    
    if (self) {
        [self initViews];
    }
    return self;
}

- (void)openMenu:(NSMutableArray *)annotations {
    DDLogVerbose(@"%@ openMenu", LOG_TAG);
    
    self.annotationsArray = annotations;
    
    self.tableViewHeightConstraint.constant = Design.SETTING_CELL_HEIGHT * self.annotationsArray.count;
    
    [self openMenu];
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ heightForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    return Design.SETTING_CELL_HEIGHT;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    DDLogVerbose(@"%@ numberOfSectionsInTableView: %@", LOG_TAG, tableView);
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ numberOfRowsInSection: %ld", LOG_TAG, tableView, (long)section);
    
    return self.annotationsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ cellForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    AnnotationInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:ANNOTATION_INFO_CELL_IDENTIFIER];
    if (!cell) {
        cell = [[AnnotationInfoCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ANNOTATION_INFO_CELL_IDENTIFIER];
    }
    
    UIAnnotation *uiAnnotation = [self.annotationsArray objectAtIndex:indexPath.row];
    BOOL hideSeparator = indexPath.row + 1 == self.annotationsArray.count ? YES : NO;
    [cell bindWithAnnotation:uiAnnotation hideSeparator:hideSeparator];
            
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ didSelectRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);

}

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    [super initViews];
        
    UIWindow *window = UIApplication.sharedApplication.keyWindow;
    CGFloat safeAreaInset = window.safeAreaInsets.bottom;
    
    self.tableViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.tableViewBottomConstraint.constant = safeAreaInset;
    
    self.tableView.scrollEnabled = NO;
    self.tableView.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"AnnotationInfoCell" bundle:nil] forCellReuseIdentifier:ANNOTATION_INFO_CELL_IDENTIFIER];
}

- (void)reloadData {
    DDLogVerbose(@"%@ reloadData", LOG_TAG);
    
    [self.tableView reloadData];
    self.tableView.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
}

#pragma mark - Private methods

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    if ([self.annotationsViewDelegate respondsToSelector:@selector(cancelAnnotationView:)]) {
        [self.annotationsViewDelegate cancelAnnotationView:self];
    }
}

@end

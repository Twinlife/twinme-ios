/*
 *  Copyright (c) 2019-2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "CellActionView.h"

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static CGFloat DESIGN_ACTION_WIDTH = 164;
static CGFloat DESIGN_ACTION_HEIGHT = 132;
static CGFloat DESIGN_BOTTOM_MARGIN = 24;
static CGFloat DESIGN_LABEL_HEIGHT = 32;
static CGFloat DESIGN_LABEL_MARGIN = 10;

static CGFloat ACTION_WIDTH;
static CGFloat ACTION_HEIGHT;
static CGFloat BOTTOM_MARGIN;
static CGFloat LABEL_HEIGHT;
static CGFloat LABEL_MARGIN;

//
// Interface: CellActionView ()
//

@interface CellActionView ()

@property (nonatomic) UILabel *actionLabel;
@property (nonatomic) UIImageView *actionImageView;

@property (nonatomic) NSString *title;
@property (nonatomic) NSString *icon;
@property (nonatomic) float iconHeight;
@property (nonatomic) float iconWidth;
@property (nonatomic) float iconTopMargin;
@property (nonatomic) UIColor *bgColor;

@end

#undef LOG_TAG
#define LOG_TAG @"CellActionView"

@implementation CellActionView

+ (void)initialize {
    DDLogVerbose(@"%@ initialize", LOG_TAG);
    
    ACTION_WIDTH = DESIGN_ACTION_WIDTH * Design.WIDTH_RATIO;
    ACTION_HEIGHT = DESIGN_ACTION_HEIGHT * Design.HEIGHT_RATIO;
    BOTTOM_MARGIN = DESIGN_BOTTOM_MARGIN * Design.HEIGHT_RATIO;
    LABEL_HEIGHT = DESIGN_LABEL_HEIGHT * Design.HEIGHT_RATIO;
    LABEL_MARGIN = DESIGN_LABEL_MARGIN * Design.WIDTH_RATIO;
}

- (instancetype)initWithTitle:(NSString*)title icon:(NSString *)icon backgroundColor:(UIColor *)backgroundColor iconWidth:(float)iconWidth iconHeight:(float)iconHeight iconTopMargin:(float)iconTopMargin {
    DDLogVerbose(@"%@ initWithTitle: %@ icon: %@ backgroundColor: %@ iconWidth: %f iconHeight: %f iconTopMargin: %f", LOG_TAG, title, icon, backgroundColor, iconWidth, iconHeight, iconTopMargin);
    
    self = [super init];
    self.frame = CGRectMake(0, 0, ACTION_WIDTH, ACTION_HEIGHT);
    
    self.title = title;
    self.icon = icon;
    self.bgColor = backgroundColor;
    self.iconHeight = iconHeight;
    self.iconWidth = iconWidth;
    self.iconTopMargin = iconTopMargin;
    
    [self initViews];
    
    return self;
}

- (UIImage *)imageFromView {
    DDLogVerbose(@"%@ imageFromView", LOG_TAG);
    
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    [self setBackgroundColor:self.bgColor];
    
    self.actionImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:self.icon]];
    [self.actionImageView setTintColor:[UIColor whiteColor]];
    CGFloat imageX = (ACTION_WIDTH - (self.iconWidth * Design.WIDTH_RATIO)) / 2;
    self.actionImageView.frame = CGRectMake(imageX, self.iconTopMargin * Design.HEIGHT_RATIO, self.iconWidth * Design.WIDTH_RATIO, self.iconHeight * Design.HEIGHT_RATIO);
    [self addSubview:self.actionImageView];
    
    CGFloat labelY = ACTION_HEIGHT - BOTTOM_MARGIN - LABEL_HEIGHT;
    CGFloat labelWidth = ACTION_WIDTH - (LABEL_MARGIN * 2);
    self.actionLabel = [[UILabel alloc]initWithFrame:CGRectMake(LABEL_MARGIN, labelY, labelWidth, LABEL_HEIGHT)];
    self.actionLabel.textAlignment = NSTextAlignmentCenter;
    self.actionLabel.font = Design.FONT_MEDIUM28;
    self.actionLabel.text = self.title;
    self.actionLabel.textColor = [UIColor whiteColor];
    [self addSubview:self.actionLabel];
}

@end

/*
 *  Copyright (c) 2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "SearchSpaceView.h"

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static CGFloat DESIGN_SEARCH_WIDTH = 160;
static CGFloat DESIGN_SEARCH_HEIGHT = 160;
static CGFloat DESIGN_ICON_SEARCH_HEIGHT = 40;

static CGFloat SEARCH_WIDTH;
static CGFloat SEARCH_HEIGHT;
static CGFloat SEARCH_ICON_HEIGHT;

//
// Interface: SearchSpaceView ()
//

@interface SearchSpaceView ()

@property (nonatomic) UIImageView *searchImageView;

@property (nonatomic) NSString *icon;
@property (nonatomic) float iconHeight;
@property (nonatomic) float iconWidth;
@property (nonatomic) float iconTopMargin;
@property (nonatomic) UIColor *bgColor;

@end

#undef LOG_TAG
#define LOG_TAG @"SearchSpaceView"

@implementation SearchSpaceView

+ (void)initialize {
    DDLogVerbose(@"%@ initialize", LOG_TAG);
    
    SEARCH_WIDTH = DESIGN_SEARCH_WIDTH * Design.WIDTH_RATIO;
    SEARCH_HEIGHT = DESIGN_SEARCH_HEIGHT * Design.HEIGHT_RATIO;
    SEARCH_ICON_HEIGHT = DESIGN_ICON_SEARCH_HEIGHT * Design.HEIGHT_RATIO;
}

- (instancetype)init {
    
    self = [super init];
    
    [self initViews];
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    [self initViews];
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    [self initViews];
    
    return self;
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.frame = CGRectMake(0, 0, SEARCH_WIDTH, SEARCH_HEIGHT);
    
    [self setBackgroundColor:[UIColor clearColor]];
    
    self.searchImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"SearchIcon"]];
    self.searchImageView.image = [self.searchImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.searchImageView.frame = CGRectMake(0, 0, SEARCH_ICON_HEIGHT, SEARCH_ICON_HEIGHT);
    self.searchImageView.tintColor = Design.BLACK_COLOR;
    [self addSubview:self.searchImageView];
    self.searchImageView.center = self.center;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.searchImageView.tintColor = Design.BLACK_COLOR;
}

@end

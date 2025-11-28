/*
 *  Copyright (c) 2020-2022 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Utils/NSString+Utils.h>

#import "MenuSelectColorView.h"

#import "ColorCell.h"

#import <TwinmeCommon/ApplicationDelegate.h>
#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/TwinmeApplication.h>

#import "UIContact.h"
#import "UICustomColor.h"
#import "UIColor+Hex.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

// static const CGFloat ANIMATION_DURATION = 0.1;
// static const CGFloat DESIGN_MENU_VIEW_HEIGHT = 650;

static NSString *COLOR_CELL_IDENTIFIER = @"ColorCellIdentifier";

static CGFloat DESIGN_COLLECTION_CELL_HEIGHT = 78;
static CGFloat DESIGN_COLLECTION_CELL_WIDTH = 70;

//
// Interface: MenuSelectColorView ()
//

@interface MenuSelectColorView ()<UICollectionViewDelegate, UICollectionViewDataSource, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *colorLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *colorLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *colorViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *colorViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *colorViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *colorView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *colorCollectionViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *colorCollectionViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *colorCollectionViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UICollectionView *colorCollectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *enterColorLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *enterColorLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *enterColorViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *enterColorViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *enterColorViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *enterColorView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *prefixColorLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *prefixColorLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *enterColorTextFieldLeadingConstraint;
@property (weak, nonatomic) IBOutlet UITextField *enterColorTextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *previewColorViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *previewColorViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *previewColorViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *previewColorView;
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

@property (nonatomic) NSString *defaultColor;
@property (nonatomic) NSString *hexColor;
@property (nonatomic) BOOL enterColorEnable;
@property (nonatomic) CGFloat sizeCell;
@end

//
// Implementation: MenuSelectColorView
//

#undef LOG_TAG
#define LOG_TAG @"MenuSelectColorView"

@implementation MenuSelectColorView

#pragma mark - UIView

- (instancetype)init {
    DDLogVerbose(@"%@ init", LOG_TAG);
    
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"MenuSelectColorView" owner:self options:nil];
    self = [objects objectAtIndex:0];
    
    self.frame = CGRectMake(0, 0, Design.DISPLAY_WIDTH, Design.DISPLAY_HEIGHT);
        
    self.defaultColor = Design.DEFAULT_COLOR;
    self.colors = Design.COLORS;
    self.enterColorEnable = NO;
    self.sizeCell = DESIGN_COLLECTION_CELL_WIDTH * Design.WIDTH_RATIO;
    
    if (self) {
        [self initViews];
    }
    return self;
}

#pragma mark - Public methods

- (void)updateKeyboard:(CGFloat)sizeKeyboard {
    DDLogVerbose(@"%@ updateKeyboard: %f", LOG_TAG, sizeKeyboard);
    
    self.actionViewBottomConstraint.constant = sizeKeyboard;
    
    [UIView animateWithDuration:1 animations:^{
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
    }];
}

- (void)openMenu:(UIColor *)color title:(NSString *)title defaultColor:(NSString *)defaultColor {
    DDLogVerbose(@"%@ openMenu: %@", LOG_TAG, color);
    
    if (title) {
        self.titleLabel.hidden = NO;
        self.titleLabel.text = title;
    } else {
        self.titleLabel.hidden = YES;
    }
    
    self.defaultColor = defaultColor;
    
    [self updateFont];
    [self updateColor];
    
    NSString *hexColor = [[UIColor hexStringWithColor:color] stringByReplacingOccurrencesOfString:@"#" withString:@""];
    BOOL findColor = NO;
    for (UICustomColor *uiCustomColor in self.colors) {
        NSString *customColor = [uiCustomColor.color stringByReplacingOccurrencesOfString:@"#" withString:@""];
        if ([customColor isEqualToString:hexColor]) {
            [uiCustomColor setSelectedColor:YES];
            findColor = YES;
        } else {
            [uiCustomColor setSelectedColor:NO];
        }
    }
    
    if (!findColor) {
        if (self.colors.count > 0 && [[self.defaultColor stringByReplacingOccurrencesOfString:@"#" withString:@""] isEqual:hexColor]) {
            UICustomColor *customColor = [self.colors firstObject];
            [customColor setSelectedColor:YES];
        } else if (hexColor) {
            self.enterColorEnable = YES;
            UIColor *customColor = [UIColor colorWithHexString:[NSString stringWithFormat:@"#%@",hexColor] alpha:1.0];
            if (customColor) {
                self.previewColorView.backgroundColor = customColor;
            } else {
                self.previewColorView.backgroundColor = Design.WHITE_COLOR;
            }
        }
    }
    
    [super openMenu];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    DDLogVerbose(@"%@ textFieldShouldReturn: %@", LOG_TAG, textField);
    
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidChange:(UITextField *)textField{
    DDLogVerbose(@"%@ textFieldDidChange: %@", LOG_TAG, textField);
    
    if ([textField.text isEqual:@""]) {
        self.previewColorView.backgroundColor = Design.WHITE_COLOR;
    } else {
        UIColor *customColor = [UIColor colorWithHexString:[NSString stringWithFormat:@"#%@",textField.text] alpha:1.0];
        if (customColor) {
            self.hexColor = [NSString stringWithFormat:@"#%@",textField.text];
            self.previewColorView.backgroundColor = customColor;
        } else {
            self.previewColorView.backgroundColor = Design.WHITE_COLOR;
            self.hexColor = nil;
        }
        
        [self reloadData];
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    DDLogVerbose(@"%@ numberOfSectionsInCollectionView: %@", LOG_TAG, collectionView);
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ collectionView: %@ numberOfItemsInSection: %ld", LOG_TAG, collectionView, (long)section);
    
    return self.colors.count + 1;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ collectionView: %@ layout: %@ sizeForItemAtIndexPath: %@", LOG_TAG, collectionView, collectionViewLayout, indexPath);
    
    CGFloat heightCell = DESIGN_COLLECTION_CELL_HEIGHT * Design.HEIGHT_RATIO;
    return CGSizeMake(self.sizeCell, heightCell);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    DDLogVerbose(@"%@ collectionView: %@ layout: %@ minimumLineSpacingForSectionAtIndex: %ld", LOG_TAG, collectionView, collectionViewLayout, (long)section);
    
    return 0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ collectionView: %@ layout: %@ referenceSizeForHeaderInSection: %ld", LOG_TAG, collectionView, collectionViewLayout, (long)section);
    
    return CGSizeMake(0, 0);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ collectionView: %@ cellForItemAtIndexPath: %@", LOG_TAG, collectionView, indexPath);
    
    ColorCell *colorCell = [collectionView dequeueReusableCellWithReuseIdentifier:COLOR_CELL_IDENTIFIER forIndexPath:indexPath];
    
    if (indexPath.row == self.colors.count) {
        [colorCell bindWithEditStyle:self.enterColorEnable];
    } else {
        UICustomColor *uiColor = self.colors[indexPath.row];
        [colorCell bindWithColor:uiColor];
    }
    
    return colorCell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ collectionView: %@ didSelectItemAtIndexPath: %@", LOG_TAG, collectionView, indexPath);
    
    if (indexPath.row == self.colors.count) {
        if ([self.menuSelectColorDelegate respondsToSelector:@selector(enterColor:)]) {
            [self.menuSelectColorDelegate enterColor:self];
        }
    } else {
        self.enterColorEnable = NO;
        for (UICustomColor *uiCustomColor in self.colors) {
            [uiCustomColor setSelectedColor:NO];
        }
        
        UICustomColor *uiCustomColor = self.colors[indexPath.row];
        [uiCustomColor setSelectedColor:YES];
        
        if (uiCustomColor.color) {
            self.hexColor = uiCustomColor.color;
        } else {
            self.hexColor = self.defaultColor;
        }
    }
    
    [self reloadData];
}

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    [super initViews];
    
    self.colorLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.colorLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.colorLabel.font = Design.FONT_BOLD28;
    self.colorLabel.text = TwinmeLocalizedString(@"personalization_view_controller_menu_choose_color", nil).uppercaseString;
    
    self.colorViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.colorViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.colorViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.colorView.backgroundColor = Design.TEXTFIELD_BACKGROUND_COLOR;
    self.colorView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.colorView.clipsToBounds = YES;
    
    self.colorCollectionViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.colorCollectionViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.colorCollectionViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.sizeCell = (self.colorViewWidthConstraint.constant - self.colorCollectionViewLeadingConstraint.constant - self.colorCollectionViewTrailingConstraint.constant) / (self.colors.count + 1);
    
    UICollectionViewFlowLayout* viewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    [viewFlowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [viewFlowLayout setMinimumInteritemSpacing:0];
    [viewFlowLayout setMinimumLineSpacing:0];
    CGFloat heightCell = DESIGN_COLLECTION_CELL_HEIGHT * Design.HEIGHT_RATIO;
    CGFloat widthCell = self.sizeCell;
    [viewFlowLayout setItemSize:CGSizeMake(widthCell, heightCell)];
    
    [self.colorCollectionView setCollectionViewLayout:viewFlowLayout];
    self.colorCollectionView.dataSource = self;
    self.colorCollectionView.delegate = self;
    self.colorCollectionView.backgroundColor = [UIColor clearColor];
    [self.colorCollectionView registerNib:[UINib nibWithNibName:@"ColorCell" bundle:nil] forCellWithReuseIdentifier:COLOR_CELL_IDENTIFIER];
    
    self.enterColorViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.enterColorViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.enterColorViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.enterColorLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.enterColorLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.enterColorLabel.font = Design.FONT_BOLD28;
    self.enterColorLabel.text = TwinmeLocalizedString(@"personalization_view_controller_menu_enter_color", nil).uppercaseString;
    
    self.enterColorView.backgroundColor = Design.TEXTFIELD_BACKGROUND_COLOR;
    self.enterColorView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.enterColorView.clipsToBounds = YES;
    
    self.prefixColorLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.prefixColorLabel.font = Design.FONT_REGULAR44;
    self.prefixColorLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.prefixColorLabel.text = @"#";
    
    self.enterColorTextFieldLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.enterColorTextField.font = Design.FONT_REGULAR44;
    self.enterColorTextField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    self.enterColorTextField.textColor = Design.FONT_COLOR_DEFAULT;
    self.enterColorTextField.tintColor = Design.FONT_COLOR_DEFAULT;
    [self.enterColorTextField setReturnKeyType:UIReturnKeyDone];
    self.enterColorTextField.delegate = self;
    [self.enterColorTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    self.previewColorViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.previewColorViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.previewColorViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.previewColorView.clipsToBounds = YES;
    self.previewColorView.layer.cornerRadius = self.previewColorViewHeightConstraint.constant * 0.5f;
    
    self.confirmViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.confirmViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.confirmViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    
    self.confirmView.backgroundColor = Design.MAIN_COLOR;
    self.confirmView.userInteractionEnabled = YES;
    self.confirmView.layer.cornerRadius = Design.CONTAINER_RADIUS;
    self.confirmView.clipsToBounds = YES;
    self.confirmView.isAccessibilityElement = YES;
    [self.confirmView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleConfirmTapGesture:)]];
    self.confirmView.alpha = 0.5f;
    
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
    
    [self dismissKeyboard];
    self.enterColorTextField.text = @"";
    self.hexColor = nil;
    
    if ([self.menuSelectColorDelegate respondsToSelector:@selector(cancelMenuSelectColor:)]) {
        [self.menuSelectColorDelegate cancelMenuSelectColor:self];
    }
}

#pragma mark - Private methods

- (void)handleCancelTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleCancelTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        
        if ([self.menuSelectColorDelegate respondsToSelector:@selector(cancelMenuSelectColor:)]) {
            [self.menuSelectColorDelegate cancelMenuSelectColor:self];
        }
    }
}

- (void)handleConfirmTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleConfirmTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        
        if (self.hexColor) {
            if ([self.hexColor isEqual:self.defaultColor]) {
                [self.menuSelectColorDelegate resetColor:self];
            } else {
                [self.menuSelectColorDelegate selectColor:self color:self.hexColor];
            }
        }
    }
}

- (void)dismissKeyboard {
    DDLogVerbose(@"%@ dismissKeyboard", LOG_TAG);
    
    [self.enterColorTextField resignFirstResponder];
}

- (void)enterColor {
    DDLogVerbose(@"%@ enterColor", LOG_TAG);
        
    if (self.enterColorEnable) {
        self.enterColorLabel.hidden = NO;
        self.enterColorView.hidden = NO;
        self.enterColorViewHeightConstraint.constant = self.colorViewHeightConstraint.constant;
        self.enterColorViewTopConstraint.constant = self.colorViewTopConstraint.constant;
        self.enterColorLabelTopConstraint.constant = self.colorLabelTopConstraint.constant;
    } else {
        self.enterColorLabel.hidden = YES;
        self.enterColorView.hidden = YES;
        self.enterColorViewHeightConstraint.constant = 0;
        self.enterColorViewTopConstraint.constant = 0;
        self.enterColorLabelTopConstraint.constant = 0;
    }
}

- (void)reloadData {
    DDLogVerbose(@"%@ reloadData", LOG_TAG);
    
    [self enterColor];
    [self.colorCollectionView reloadData];
    self.confirmView.alpha = self.hexColor ? 1.0f : 0.5f;
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.titleLabel.font = Design.FONT_BOLD34;
    self.colorLabel.font = Design.FONT_BOLD28;
    self.enterColorLabel.font = Design.FONT_BOLD28;
    self.enterColorTextField.font = Design.FONT_REGULAR44;
    self.cancelLabel.font = Design.FONT_BOLD34;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    [super updateColor];
    
    self.titleLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.colorLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.enterColorLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.enterColorTextField.textColor = Design.FONT_COLOR_DEFAULT;
    self.enterColorTextField.tintColor = Design.FONT_COLOR_DEFAULT;
    self.cancelLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.confirmView.backgroundColor = Design.MAIN_COLOR;
    
    ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
    TwinmeApplication *twinmeApplication = [delegate twinmeApplication];
    
    if ([twinmeApplication darkModeEnable]) {
        self.enterColorTextField.keyboardAppearance = UIKeyboardAppearanceDark;
    } else {
        self.enterColorTextField.keyboardAppearance = UIKeyboardAppearanceLight;
    }
}

@end


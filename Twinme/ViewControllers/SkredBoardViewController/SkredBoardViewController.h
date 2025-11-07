/*
 *  Copyright (c) 2017 twinlife SA & Telefun SAS.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Thibaud David (contact@thibauddavid.com)
 */

typedef enum {
    SkredBoardModeAccessAccount,
    SkredBoardModeCreateAccount,
    SkredBoardModeDeleteAccount
} SkredBoardMode;

typedef enum {
    SkredBoardDisplayStateOpen,
    SkredBoardDisplayStateClose
} SkredBoardDisplayState;

//
// Protocol: SkredBoardViewControllerDelegate
//

@class SkredBoardViewController;

@protocol SkredBoardViewControllerDelegate <NSObject>

- (void)dismissSkredBoardViewController:(SkredBoardViewController *)skredBoardViewController;

- (void)skredBoardViewController:(SkredBoardViewController *)skredBoardViewController didValidateCode:(NSString *)code onMode:(SkredBoardMode)mode;

@end

//
// Protocol: SkredBoardViewControllerDelegate
//

@protocol SkredBoardViewControllerSwipeResponder <NSObject>

- (UIView *)skredBoardViewControllerSwipeableView;

@end

//
// Interface: SkredBoardViewController
//

@interface SkredBoardViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *skredBoard;
@property (weak, nonatomic) id<SkredBoardViewControllerDelegate> delegate;
@property (nonatomic) SkredBoardDisplayState skredBoardDisplayState;

- (void)setSkredBoardDisplayState:(SkredBoardDisplayState)skredBoardDisplayState initialVelocity:(CGFloat)velocity animated:(BOOL)animated;

- (void)addToViewController:(UIViewController<SkredBoardViewControllerSwipeResponder> *)viewController;
- (void)addToViewControllerWithoutStickGesture:(UIViewController*)viewController;

- (IBAction)handlePanGestureRecognizer:(UIPanGestureRecognizer *)sender;

@end

/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

@class TLSpaceSettings;

//
// Interface: TextViewRightView
//

@interface TextViewRightView : UIView

@property (weak, nonatomic) IBOutlet UIView *cameraView;
@property (weak, nonatomic) IBOutlet UIView *microView;
@property (nonatomic, nonnull) TLSpaceSettings *spaceSettings;

- (void)updateColor;

@end

/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Chedi Baccari (Chedi.Baccari@twinlife-systems.com)
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Interface: SendButtonView
//

@interface SendButtonView : UIView

@property (weak, nonatomic) IBOutlet UIView *sendView;
@property (weak, nonatomic) IBOutlet UIView *editView;

- (void)editMode:(BOOL)enable;

- (BOOL)isEnabled;

- (void)setEnabled:(BOOL)enable;

@end

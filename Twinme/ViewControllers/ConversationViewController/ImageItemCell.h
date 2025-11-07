/*
 *  Copyright (c) 2016-2018 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Christian Jacquemot (Christian.Jacquemot@twinlife-systems.com)
 *   Chedi Baccari (Chedi.Baccari@twinlife-systems.com)
 *   Thibaud David (contact@thibauddavid.com)
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "ItemCell.h"

//
// Interface: ImageItemCell
//

@protocol ImageActionDelegate;

@interface ImageItemCell : ItemCell

@property (weak, nonatomic) id<ImageActionDelegate> imageActionDelegate;

@end

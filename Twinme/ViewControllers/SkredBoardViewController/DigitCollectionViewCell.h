/*
 *  Copyright (c) 2017 twinlife SA & Telefun SAS.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Thibaud David (contact@thibauddavid.com)
 */

static NSString *digitCollectionViewCellIdentifier = @"digitCollectionViewCellIdentifier";

//
// Interface: DigitCollectionViewCell
//

@interface DigitCollectionViewCell : UICollectionViewCell

@property (nonatomic) NSInteger digit;

- (void)setHighlight:(BOOL)isHighlight;
- (void)setDigit:(NSInteger)digit gradientColors:(NSArray<UIColor *> *)gradientColors;

@end

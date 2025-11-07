/*
 *  Copyright (c) 2017 twinlife SA & Telefun SAS.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Thibaud David (contact@thibauddavid.com)
 */

//
// Protocol: CodeInputCollectionViewDatasource
//

@class CodeInputCollectionView;

@protocol CodeInputCollectionViewDatasource <NSObject>

@optional
-(NSArray<UIColor *> *)codeInputCollectionView:(CodeInputCollectionView *)codeInputCollectionView colorsForDigit:(NSInteger)digit;

@end

//
// Protocol: CodeInputCollectionViewDelegate
//

@protocol CodeInputCollectionViewDelegate <NSObject>

- (void)codeInputCollectionView:(CodeInputCollectionView *)codeInputCollectionView didSelectDigit:(NSInteger)digit;

@end

//
// Interface: CodeInputCollectionView
//

@interface CodeInputCollectionView : UICollectionView

@property (weak, nonatomic) id<CodeInputCollectionViewDatasource> codeInputCollectionViewDatasource;
@property (weak, nonatomic) id<CodeInputCollectionViewDelegate> codeInputCollectionViewDelegate;

@end

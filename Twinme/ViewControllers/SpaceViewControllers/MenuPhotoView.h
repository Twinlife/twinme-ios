/*
 *  Copyright (c) 2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "AbstractMenuView.h"

//
// Protocol: MenuPhotoViewDelegate
//

@class MenuPhotoView;

@protocol MenuPhotoViewDelegate <NSObject>

- (void)cancelMenuPhoto:(MenuPhotoView *)menuPhotoView;

- (void)menuPhotoDidSelectCamera:(MenuPhotoView *)menuPhotoView;

- (void)menuPhotoDidSelectGallery:(MenuPhotoView *)menuPhotoView;

@optional

- (void)menuPhotoDidSelectColor:(MenuPhotoView *)menuPhotoView;

@end

//
// Interface: MenuPhotoView
//


@interface MenuPhotoView : AbstractMenuView

@property (weak, nonatomic) id<MenuPhotoViewDelegate> menuPhotoViewDelegate;
@property (nonatomic) BOOL showSelectColor;

- (void)openMenu:(BOOL)hideTitle;

@end

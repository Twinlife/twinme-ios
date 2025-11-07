/*
 *  Copyright (c) 2019 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Protocol: VideoZoomDelegate
//

@protocol VideoZoomDelegate <NSObject>

- (void)updateZoom:(CGFloat)zoomLevel;

@end


//
// Interface: ZoomSlider
//

@protocol VideoZoomDelegate;

@interface ZoomSlider : UIView

@property (weak, nonatomic) id<VideoZoomDelegate> delegate;

- (void)initializeSlider:(CGRect)rectThumb;

- (void)setZoom:(CGFloat)zoom withSliderHeight:(CGFloat)height;

- (void)updateColor:(UIColor *)color;

@end

/*
 *  Copyright (c) 2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

@class RecordView;

@protocol RecordViewDelegate <NSObject>

- (void)recordViewTouchBegan:(RecordView *)recordView;

- (void)recordViewTouchEnd:(RecordView *)recordView;

- (void)recordViewTouchCancel:(RecordView *)recordView;

@end

@interface RecordView : UIView

@property(nonatomic, weak) id<RecordViewDelegate> recordViewDelegate;

@end

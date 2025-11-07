/*
 *  Copyright (c) 2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Protocol: CallCertifyViewDelegate
//

@protocol CallCertifyViewDelegate <NSObject>

- (void)certifyViewCancelWord;

- (void)certifyViewConfirmWord;

- (void)certifyViewDidFinish;

- (void)certifyViewSingleTap;

@end

//
// Interface: CallCertifyView
//

@class WordCheckChallenge;

@interface CallCertifyView : UIView

@property (weak, nonatomic) id<CallCertifyViewDelegate> callCertifyViewDelegate;
@property (nonatomic) NSString *name;
@property (nonatomic) UIImage *avatar;

- (void)updateMessage;

- (void)updateWord:(WordCheckChallenge *)wordCheckChallenge;

- (void)certifyRelationSuccess;

- (void)certifyRelationFailed;

@end

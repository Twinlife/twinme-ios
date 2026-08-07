/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <TwinmeCommon/AbstractBottomSheetView.h>

extern NSString * _Nonnull const PRIVACY_POLICY_LINK;
extern NSString * _Nonnull const CONTACT_LINK;
extern NSString * _Nonnull const CONNECT_PEOPLE_LINK;

@class UIFAQArticle;
@class FAQArticleView;

//
// Protocol: ContactsServiceDelegate
//

@protocol FAQArticleViewDelegate <BottomSheetViewDelegate>

- (void)didTapOnFAQLink:(nonnull NSString *)link faqArticleView:(nonnull FAQArticleView *)faqArticleView;

@end

//
// Interface: FAQArticleView
//

@interface FAQArticleView : AbstractBottomSheetView

@property (weak, nonatomic) id<FAQArticleViewDelegate> faqArticleViewDelegate;

- (void)initWithFAQArticle:(nonnull UIFAQArticle *)article;

@end

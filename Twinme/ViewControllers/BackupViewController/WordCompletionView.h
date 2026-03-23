/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

//
// Protocol: RestoreEnterWordDelegate
//

@protocol WordCompletionDelegate <NSObject>

- (void)selectWord:(NSString *)word;

@end

//
// Interface: WordCompletionView
//

@interface WordCompletionView : UIView

@property (weak, nonatomic) id<WordCompletionDelegate> wordCompletionDelegate;

- (void)setSuggestions:(NSArray *)suggestions;

@end

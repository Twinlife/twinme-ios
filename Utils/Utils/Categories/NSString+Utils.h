/*
 *  Copyright (c) 2018-2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 *   Christian Jacquemot (Christian.Jacquemot@twinlife-systems.com)
 *   Stephane Carrez (Stephane.Carrez@twin.life)
 */

#import <UIKit/UIKit.h>

//
// Interface: NSString (Utils)
//

#define TwinmeLocalizedString(key, comment) [NSString localizedStringForKey:(key) replaceValue:(comment)]

@interface NSString (Utils)

+ (nonnull NSString *)convertWithLocale:(nonnull NSString *)string;

+ (nonnull NSString *)convertWithInterval:(NSTimeInterval)interval format:(nonnull NSString *)format;

+ (nonnull NSString *)formatTimeInterval:(NSTimeInterval)interval;

+ (nonnull NSString *)formatCallTimeInterval:(NSTimeInterval)interval;

+ (nonnull NSString *)formatItemTimeInterval:(NSTimeInterval)interval;

+ (nonnull NSString *)localizedStringForKey:(nonnull NSString *)key replaceValue:(nullable NSString *)comment;

+ (nonnull NSString *)firstCharacter:(nonnull NSString *)string;

+ (nonnull NSString *)convertEmoji:(nonnull NSString *)string;

+ (nullable NSUUID *)toUUID:(nonnull NSString *)string;

+ (nonnull NSString *)fromUUID:(nonnull NSUUID *)value;

+ (nonnull NSAttributedString *)formatText:(nonnull NSString *)text fontSize:(int)fontSize fontColor:(nonnull UIColor *)fontColor fontSearch:(nullable UIFont *)fontSearch;

@end

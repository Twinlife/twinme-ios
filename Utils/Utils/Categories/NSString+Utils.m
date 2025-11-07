/*
 *  Copyright (c) 2018-2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 *   Christian Jacquemot (Christian.Jacquemot@twinlife-systems.com)
 *   Stephane Carrez (Stephane.Carrez@twin.life)
 */

#import "NSString+Utils.h"

#define DEFAULT_LANGUAGE @"Base"

static NSString * HAPPY_EMOJI_CODE = @"\U0001F600";
static NSString * SAD_EMOJI_CODE = @"\U0001F641";

static NSString * BOLD_STYLE_SYMBOL = @"*";
static NSString * ITALIC_STYLE_SYMBOL = @"_";
static NSString * STRIKE_THROUGH_STYLE_SYMBOL = @"~";

static NSString * BOLD_PATTERN = @"[\\*]([^*]+)[\\*]";
static NSString * ITALIC_PATTERN = @"[\\_]([^_]+)[\\_]";
static NSString * STRIKE_THROUGH_PATTERN = @"[\\~]([^~]+)[\\~]";
static NSString * URL_PATTERN = @"((http|https)://)?([(w|W)]{3}+\\.)?+(.)+\\.+[A-Za-z]{2,3}+(\\.)?+(/(.)*)?";

static int BOLD_VALUE = -2;

@implementation NSString (Utils)

+ (NSString *)convertWithLocale:(NSString *)string {
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.locale = [NSLocale currentLocale];
    for (NSUInteger i = 0; i < 10; i++) {
        NSNumber *number = @(i);
        string = [string stringByReplacingOccurrencesOfString:number.stringValue withString:[numberFormatter stringFromNumber:number]];
    }
    return string;
}

+ (NSString *)convertWithInterval:(NSTimeInterval)interval format:(NSString *)format {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.locale = [NSLocale currentLocale];
    dateFormatter.dateFormat = format;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    return [dateFormatter stringFromDate:date];
}

+ (NSString *)formatTimeInterval:(NSTimeInterval)interval {
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit calendarUnit = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
    NSDateComponents* dateComponents = [calendar components:calendarUnit fromDate:date toDate:[NSDate date] options:NSCalendarWrapComponents];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.locale = [NSLocale currentLocale];
    
    if ([calendar isDateInToday:date]) {
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        [dateFormatter setDateStyle:NSDateFormatterNoStyle];
    } else if ([calendar isDateInYesterday:date]) {
        [dateFormatter setDoesRelativeDateFormatting:YES];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    } else if (dateComponents.year == 0 && dateComponents.month == 0 && dateComponents.day < 6) {
        [dateFormatter setDateFormat:@"EEEE"];
    } else {
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    }
    return  [dateFormatter stringFromDate:date];
}

+ (NSString *)formatCallTimeInterval:(NSTimeInterval)interval {
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit calendarUnit = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
    NSDateComponents* dateComponents = [calendar components:calendarUnit fromDate:date toDate:[NSDate date] options:NSCalendarWrapComponents];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.locale = [NSLocale currentLocale];
    
    if ([calendar isDateInToday:date]) {
        [dateFormatter setDateStyle:NSDateFormatterNoStyle];
    } else if ([calendar isDateInYesterday:date]) {
        [dateFormatter setDoesRelativeDateFormatting:YES];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    } else if (dateComponents.year == 0 && dateComponents.month == 0 && dateComponents.day < 6) {
        [dateFormatter setDateFormat:@"EEEE"];
    } else {
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    }
    
    NSString *dateToString = [dateFormatter stringFromDate:date];
    
    [dateFormatter setDateStyle:NSDateFormatterNoStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    NSString *timeToString = [dateFormatter stringFromDate:date];
    
    if ([dateToString isEqualToString:@""]) {
        return timeToString;
    } else {
        return [NSString stringWithFormat:@"%@\n%@", dateToString, timeToString];
    }
}

+ (NSString *)formatItemTimeInterval:(NSTimeInterval)interval {
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit calendarUnit = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
    NSDateComponents* dateComponents = [calendar components:calendarUnit fromDate:date toDate:[NSDate date] options:NSCalendarWrapComponents];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.locale = [NSLocale currentLocale];
    
    if ([calendar isDateInToday:date]) {
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        [dateFormatter setDateStyle:NSDateFormatterNoStyle];
    } else if ([calendar isDateInYesterday:date]) {
        [dateFormatter setDoesRelativeDateFormatting:YES];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    } else if (dateComponents.year == 0 && dateComponents.month == 0 && dateComponents.day < 6) {
        [dateFormatter setDateFormat:@"EEEE HH:mm"];
    } else if (dateComponents.year > 0) {
        [dateFormatter setDateFormat:@"EEE dd MMM YYYY HH:mm"];
    } else {
        [dateFormatter setDateFormat:@"EEE dd MMM HH:mm"];
    }
    
    return [dateFormatter stringFromDate:date];
}

+ (NSString *)localizedStringForKey:(NSString *)key replaceValue:(NSString *)comment {
    
    NSString *localizedString = [[NSBundle mainBundle] localizedStringForKey:key value:key table:nil];
    if (localizedString && ![localizedString isEqualToString:key]) {
        return localizedString;
    } else if (comment) {
        return comment;
    } else {
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:DEFAULT_LANGUAGE ofType:@"lproj"];
        NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
        NSString *defaultString = [bundle localizedStringForKey:key value:comment table:nil];
        return defaultString;
    }
}

+ (NSString *)capitalizedFirstLetter:(NSString *)string {
    
    if (!string || string.length == 0) {
        return @"";
    } else if (string.length == 1) {
        return string.capitalizedString;
    } else {
        NSString *firstLetter = [string substringToIndex:1];
        NSString *rest = [string substringWithRange:NSMakeRange(1, string.length - 1)];
        return [NSString stringWithFormat:@"%@%@", [firstLetter uppercaseString], [rest lowercaseString]];
    }
}

+ (NSString *)formatTimeout:(int64_t)timeout {
    
    int64_t oneMinute = 60;
    int64_t oneHour = oneMinute * 60;
    int64_t oneDay = oneHour * 24;
    int64_t oneWeek = oneDay * 7;
    int64_t oneMonth = oneDay * 30;
    
    if (timeout == 0) {
        return TwinmeLocalizedString(@"privacy_view_controller_lock_screen_timeout_instant", nil);
    } else if (timeout < oneMinute) {
        return [NSString stringWithFormat:TwinmeLocalizedString(@"application_timeout_seconds %@", nil),[NSString convertWithLocale:[NSString stringWithFormat:@"%lld",timeout]]];
    } else if (timeout == oneMinute) {
        return TwinmeLocalizedString(@"application_timeout_minute", nil);
    } else if (timeout < oneHour) {
        int64_t minutes = timeout / oneMinute;
        return [NSString stringWithFormat:TwinmeLocalizedString(@"application_timeout_minutes %@", nil),[NSString convertWithLocale:[NSString stringWithFormat:@"%lld",minutes]]];
    } else if (timeout == oneHour) {
        return TwinmeLocalizedString(@"application_timeout_hour", nil);
    } else if (timeout < oneDay) {
        int64_t hours = timeout / oneHour;
        return [NSString stringWithFormat:TwinmeLocalizedString(@"application_timeout_hours %@", nil),[NSString convertWithLocale:[NSString stringWithFormat:@"%lld",hours]]];
    } else if (timeout == oneDay) {
        return TwinmeLocalizedString(@"application_timeout_day", nil);
    } else if (timeout == oneWeek) {
        return TwinmeLocalizedString(@"application_timeout_week", nil);
    } else if (timeout == oneMonth) {
        return TwinmeLocalizedString(@"application_timeout_month", nil);
    }
    
    return [NSString convertWithLocale:[NSString stringWithFormat:@"%lld",timeout]];
}

+ (NSString *)convertEmoji:(NSString *)string {
    
    string = [string stringByReplacingOccurrencesOfString:@":-)" withString:HAPPY_EMOJI_CODE];
    string = [string stringByReplacingOccurrencesOfString:@":-(" withString:SAD_EMOJI_CODE];
    
    return string;
}

+ (NSString *)firstCharacter:(NSString *)string {
    
    if (!string || string.length == 0) {
        return @"";
    } else if (string.length == 1) {
        return string.capitalizedString;
    } else {
        NSString *firstLetter = [string substringToIndex:1];
        return [firstLetter uppercaseString];
    }
}

+ (NSUUID *)toUUID:(NSString *)string {
    
    if (string.length == 36) {
        return [[NSUUID alloc] initWithUUIDString:string];
    }

    // iOS does not have a Base64 URL decoding, change - into + and _ into / if they are used.
    if ([string containsString:@"-"]) {
        string = [string stringByReplacingOccurrencesOfString:@"-" withString:@"+"];
    }
    if ([string containsString:@"_"]) {
        string = [string stringByReplacingOccurrencesOfString:@"_" withString:@"/"];
    }

    // The 16-bytes encoded values are such that we expect two '=' at the end.
    string = [[NSString alloc] initWithFormat:@"%@==", string];
    NSData *data = [[NSData alloc] initWithBase64EncodedString:string options:0];
    if (data.length != 16) {
        return nil;
    }

    uuid_t bytes;
    [data getBytes:bytes range:NSMakeRange(0, 16)];
    return [[NSUUID alloc] initWithUUIDBytes:bytes];
}

+ (NSString *)fromUUID:(NSUUID *)value {

    uuid_t bytes;
    [value getUUIDBytes:bytes];
    NSData* data = [[NSData alloc] initWithBytes:bytes length:16];

    NSString *result = [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];

    // Due to the 16-bytes encoded value, we get two '=' at the end and we want to remove them.
    result = [result substringToIndex:result.length - 2];

    // iOS does not have a Base64 URL encoding, change + into - and / into _ if they are used.
    if ([result containsString:@"+"]) {
        result = [result stringByReplacingOccurrencesOfString:@"+" withString:@"-"];
    }
    if ([result containsString:@"/"]) {
        result = [result stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    }
    return result;
}

+ (NSAttributedString *)formatText:(nonnull NSString *)text fontSize:(int)fontSize fontColor:(nonnull UIColor *)fontColor fontSearch:(nullable UIFont *)fontSearch {
    
    NSRange range = NSMakeRange(0, text.length);
    NSMutableArray *excludeRanges = [[NSMutableArray alloc]init];
    if (@available(iOS 13, *)) {
        NSError *error = nil;
        NSDataDetector *linkDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
        NSArray *matches = [linkDetector matchesInString:text options:0 range:range];
        for (NSTextCheckingResult *match in matches) {
            [excludeRanges addObject:[NSValue valueWithRange:match.range]];
        }
    } else {
        NSRegularExpression *urlRegularExpression = [NSRegularExpression regularExpressionWithPattern:
                                                      URL_PATTERN options:NSRegularExpressionCaseInsensitive error:nil];
        [urlRegularExpression enumerateMatchesInString:text options:NSMatchingReportProgress range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
            if (result.range.length > 0) {
                [excludeRanges addObject:[NSValue valueWithRange:result.range]];
            }
        }];
    }
    
    NSMutableArray *styleRanges = [[NSMutableArray alloc]init];
    NSRegularExpression *boldRegularExpression = [NSRegularExpression regularExpressionWithPattern:
                                                  BOLD_PATTERN options:NSRegularExpressionCaseInsensitive error:nil];
    [boldRegularExpression enumerateMatchesInString:text options:NSMatchingReportProgress range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        if (result.range.length > 0 && ![NSString containsRange:result.range ranges:excludeRanges]) {
            [styleRanges addObject:[NSValue valueWithRange:result.range]];
        }
    }];
        
    NSRegularExpression *italicRegularExpression = [NSRegularExpression regularExpressionWithPattern:
                                                    ITALIC_PATTERN options:NSRegularExpressionCaseInsensitive error:nil];
    [italicRegularExpression enumerateMatchesInString:text options:NSMatchingReportProgress range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        if (result.range.length > 0 && ![NSString containsRange:result.range ranges:excludeRanges]) {
            [styleRanges addObject:[NSValue valueWithRange:result.range]];
        }
    }];
    
    NSRegularExpression *strikeThroughRegularExpression = [NSRegularExpression regularExpressionWithPattern:STRIKE_THROUGH_PATTERN options:NSRegularExpressionCaseInsensitive error:nil];
    [strikeThroughRegularExpression enumerateMatchesInString:text options:NSMatchingReportProgress range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        if (result.range.length > 0 && ![NSString containsRange:result.range ranges:excludeRanges]) {
            [styleRanges addObject:[NSValue valueWithRange:result.range]];
        }
    }];
    
    NSArray *sortedRanges = [styleRanges sortedArrayUsingComparator:^NSComparisonResult(NSValue *a, NSValue *b) {
        NSRange range1 = [a rangeValue];
        NSRange range2 = [b rangeValue];
        return range1.location > range2.location;
    }];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:text];
    
    [attributedString beginEditing];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:fontSize] range:NSMakeRange(0, attributedString.length)];
    
    for (int i = 0; i < sortedRanges.count; i++) {
        NSRange attributedRange = [[sortedRanges objectAtIndex:i]rangeValue];
        NSString *subString = [text substringWithRange:NSMakeRange(attributedRange.location, 1)];
        NSString *stringToReplace = [text substringWithRange:attributedRange];
        stringToReplace = [stringToReplace stringByReplacingOccurrencesOfString:subString withString:@""];
        int offset = [self getOffset:attributedRange withRanges:sortedRanges];
        attributedRange.location -= offset;
        [attributedString replaceCharactersInRange:attributedRange withString:stringToReplace];
        NSRange styleRange = NSMakeRange(attributedRange.location, attributedRange.length - 2);
        if ([subString isEqualToString:BOLD_STYLE_SYMBOL]) {
            [attributedString addAttribute:NSStrokeWidthAttributeName value:[NSNumber numberWithInt:BOLD_VALUE] range:styleRange];
        } else if ([subString isEqualToString:STRIKE_THROUGH_STYLE_SYMBOL]) {
            if (fontSearch) {
                [attributedString addAttribute:NSFontAttributeName value:fontSearch range:styleRange];
            } else {
                [attributedString addAttribute:NSStrikethroughStyleAttributeName value:[NSNumber numberWithInteger: NSUnderlineStyleSingle] range:styleRange];
            }
        } else if ([subString isEqualToString:ITALIC_STYLE_SYMBOL]) {
            [attributedString addAttribute:NSFontAttributeName value:[UIFont italicSystemFontOfSize:fontSize] range:styleRange];
        }
    }
    
    [attributedString addAttribute:NSForegroundColorAttributeName value:fontColor range:NSMakeRange(0, attributedString.length)];
    
    [attributedString endEditing];
    
    return attributedString;
}

+ (int)getOffset:(NSRange)range withRanges:(NSArray *)ranges {
    
    int offset = 0;
    long endRange = range.location + range.length;
    for (int i = 0; i < ranges.count; i++) {
        NSRange r = [[ranges objectAtIndex:i]rangeValue];
        long endRange2 = r.location + r.length;
        if (range.location == r.location) {
            return offset;
        }
        
        if (range.location > r.location) {
            offset++;
        }
        
        if (endRange2 < endRange) {
            offset++;
        }
    }
    
    return offset;
}

+ (BOOL)containsRange:(NSRange)range ranges:(NSArray *)ranges {
    
    for (NSValue *value in ranges) {
        NSRange r = value.rangeValue;
        if (NSIntersectionRange(r, range).length == range.length) {
            return YES;
        }
    }
    
    return NO;
}

@end

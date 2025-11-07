/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "UIFileSection.h"

#import <Utils/NSString+Utils.h>

#import "Item.h"

//
// Interface: UIFileSection ()
//

@interface UIFileSection ()

@property (nonatomic) NSMutableArray<Item *> *items;
@property (nonatomic) NSString *title;

@end

//
// Implementation: UIFileSection
//

@implementation UIFileSection

- (nonnull instancetype)initWithPeriod:(nonnull NSString *)period {
    
    self = [super init];
    
    if (self) {
        _items = [[NSMutableArray alloc]init] ;
        _period = period;
    }
    return self;
}

- (nonnull NSString *)getTitle {
    
    if (self.title) {
        return self.title;
    }
    
    if (self.items.count == 0) {
        return @"";
    }
        
    Item *item = [self.items firstObject];
    
    NSDateComponents *itemDay = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:[NSDate dateWithTimeIntervalSince1970:item.createdTimestamp / 1000]];
    NSDateComponents *today = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:[NSDate date]];
    
    if ([today month] == [itemDay month] && [today year] == [itemDay year]) {
        return TwinmeLocalizedString(@"conversation_files_view_controller_month", nil);
    }
    
    NSString *dateFormat = @"MMMM YYYY";
    if ([today year] == [itemDay year]) {
        dateFormat = @"MMMM";
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:dateFormat];
    self.title = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:item.createdTimestamp / 1000]].capitalizedString;
    
    return self.title;
}

- (NSUInteger)count {
    
    return self.items.count;
}

- (nonnull NSMutableArray *)getItems {
    
    return self.items;
}

- (void)addItem:(Item *)item {
    
    [self.items addObject:item];
}

@end

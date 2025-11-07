/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "UIInvitationCode.h"

#import <Utils/NSString+Utils.h>

//
// Implementation: UIInvitationCode
//

@implementation UIInvitationCode

- (nonnull instancetype)initWithTitle:(nonnull TLInvitation *)invitation code:(nonnull NSString *)code expirationDate:(long)expirationDate {
    
    self = [super init];
    
    if (self) {
        _invitation = invitation;
        _code = code;
        _expirationDate = expirationDate;
    }
    return self;
}

- (NSString *)formatExpirationDate {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY/MM/dd HH:mm"];
    
    NSMutableString *message = [[NSMutableString alloc] initWithString:TwinmeLocalizedString(@"invitation_code_view_controller_expiration", nil)];
    [message appendString:@" "];
    [message appendString:[dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:self.expirationDate]]];

    return message;
}

- (BOOL)hasExpired {
    
    return [[NSDate dateWithTimeIntervalSince1970:self.expirationDate] compare:[NSDate date]] == NSOrderedAscending;
}

@end

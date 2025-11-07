/*
 *  Copyright (c) 2022 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "CoachMarkManager.h"

#define SHOW_COACH_MARK @"ShowCoachMark"

#define LAST_SHOW_COACH_MARK_CONVERSATION_EPHEMERAL @"LastShowCoachMarkConversationEphemeral"
#define LAST_SHOW_COACH_MARK_ADD_PARTICIPANT_TO_CALL @"LastShowCoachMarkAddPartcipantToCall"
#define LAST_SHOW_COACH_MARK_PRIVACY @"LastShowCoachMarkPrivacy"
#define LAST_SHOW_COACH_MARK_CONTACT_CAPABILITIES @"LastShowCoachMarkContactCapabilities"

#define COUNT_SHOW_COACH_MARK_CONVERSATION_EPHEMERAL @"CountShowCoachMarkConversationEphemeral"
#define COUNT_SHOW_COACH_MARK_ADD_PARTICIPANT_TO_CALL @"CountShowCoachMarkAddPartcipantToCall"
#define COUNT_SHOW_COACH_MARK_PRIVACY @"CountShowCoachMarkPrivacy"
#define COUNT_SHOW_COACH_MARK_CONTACT_CAPABILITIES @"CountShowCoachMarkContactCapabilities"

static const int64_t COACH_MARK_MAX_SHOW = 3;
// static const int64_t COACH_MARK_INTERVAL_DATE = 60 * 60 * 24;

@implementation CoachMarkManager

- (BOOL)showCoachMark {
    
    id object = [[NSUserDefaults standardUserDefaults] objectForKey:SHOW_COACH_MARK];
    if (object) {
        return [object boolValue];
    }
    
    return YES;
}

- (void)setShowCoachMark:(BOOL)showCoachMark {
    
    [[NSUserDefaults standardUserDefaults] setBool:showCoachMark forKey:SHOW_COACH_MARK];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (showCoachMark) {
        [self resetCoachMark];
    } else {
        [self hideAllCoachMark];
    }
}

- (BOOL)showCoachMark:(CoachMarkTag)coachMarkTag {
    
    /*if (![self showCoachMark]) {
        return NO;
    }
    
    NSDate *lastShowDate = [self lastShowCoachMarkDate:coachMarkTag];
    int showCount = [self countShowCoachMark:coachMarkTag];
    
    if (!lastShowDate) {
        [self setLastShowCoachMark:coachMarkTag];
        [self setCountShowCoachMark:coachMarkTag count:showCount + 1];
        return YES;
    } else {
        NSDate *nextShowDate = [lastShowDate dateByAddingTimeInterval:COACH_MARK_INTERVAL_DATE];
        
        if ([nextShowDate compare:[NSDate date]] == NSOrderedAscending && showCount < COACH_MARK_MAX_SHOW) {
            [self setLastShowCoachMark:coachMarkTag];
            [self setCountShowCoachMark:coachMarkTag count:showCount + 1];
            return YES;
        }
    }*/
    
    return NO;
}

- (NSDate *)lastShowCoachMarkDate:(CoachMarkTag)coachMarkTag {
        
    NSString *key = [self getLastShowCoachMarkKey:coachMarkTag];
    if (key) {
        id object = [[NSUserDefaults standardUserDefaults] objectForKey:key];
        if (object) {
            return [NSDate dateWithTimeIntervalSince1970:[object integerValue]];
        }
    }

    return nil;
}

- (void)setLastShowCoachMark:(CoachMarkTag)coachMarkTag {
    
    NSString *key = [self getLastShowCoachMarkKey:coachMarkTag];
    [[NSUserDefaults standardUserDefaults] setInteger:[[NSDate date] timeIntervalSince1970] forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (int)countShowCoachMark:(CoachMarkTag)coachMarkTag {
        
    NSString *key = [self getCountShowCoachMarkKey:coachMarkTag];
    if (key) {
        id object = [[NSUserDefaults standardUserDefaults] objectForKey:key];
        if (object) {
            return [object intValue];
        }
    }

    return 0;
}

- (void)setCountShowCoachMark:(CoachMarkTag)coachMarkTag count:(int)count {
    
    NSString *key = [self getCountShowCoachMarkKey:coachMarkTag];
    
    [[NSUserDefaults standardUserDefaults] setInteger:count forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    int countShowCoachMark = [self countShowCoachMark:TAG_COACH_MARK_CONTACT_CAPABILITIES];
    if (countShowCoachMark >= COACH_MARK_MAX_SHOW) {
        countShowCoachMark = [self countShowCoachMark:TAG_COACH_MARK_PRIVACY];
        if (countShowCoachMark >= COACH_MARK_MAX_SHOW) {
            countShowCoachMark = [self countShowCoachMark:TAG_COACH_MARK_CONVERSATION_EPHEMERAL];
            if (countShowCoachMark >= COACH_MARK_MAX_SHOW) {
                countShowCoachMark = [self countShowCoachMark:TAG_COACH_MARK_ADD_PARTICIPANT_TO_CALL];
                if (countShowCoachMark >= COACH_MARK_MAX_SHOW) {
                    [self setShowCoachMark:NO];
                }
            }
        }
    }
}

- (void)hideCoachMark:(CoachMarkTag)coachMarkTag {
    
    NSString *key = [self getCountShowCoachMarkKey:coachMarkTag];
    
    [[NSUserDefaults standardUserDefaults] setInteger:COACH_MARK_MAX_SHOW forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)resetCoachMark {
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:COUNT_SHOW_COACH_MARK_ADD_PARTICIPANT_TO_CALL];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:COUNT_SHOW_COACH_MARK_PRIVACY];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:COUNT_SHOW_COACH_MARK_CONTACT_CAPABILITIES];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:COUNT_SHOW_COACH_MARK_CONVERSATION_EPHEMERAL];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:LAST_SHOW_COACH_MARK_ADD_PARTICIPANT_TO_CALL];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:LAST_SHOW_COACH_MARK_PRIVACY];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:LAST_SHOW_COACH_MARK_CONTACT_CAPABILITIES];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:LAST_SHOW_COACH_MARK_CONVERSATION_EPHEMERAL];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)hideAllCoachMark {
    
    [[NSUserDefaults standardUserDefaults] setInteger:COACH_MARK_MAX_SHOW forKey:COUNT_SHOW_COACH_MARK_ADD_PARTICIPANT_TO_CALL];
    [[NSUserDefaults standardUserDefaults] setInteger:COACH_MARK_MAX_SHOW forKey:COUNT_SHOW_COACH_MARK_PRIVACY];
    [[NSUserDefaults standardUserDefaults] setInteger:COACH_MARK_MAX_SHOW forKey:COUNT_SHOW_COACH_MARK_CONTACT_CAPABILITIES];
    [[NSUserDefaults standardUserDefaults] setInteger:COACH_MARK_MAX_SHOW forKey:COUNT_SHOW_COACH_MARK_CONVERSATION_EPHEMERAL];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)getLastShowCoachMarkKey:(CoachMarkTag)coachMarkTag {
    
    NSString *key;
    
    switch (coachMarkTag) {
        case TAG_COACH_MARK_ADD_PARTICIPANT_TO_CALL:
            key = LAST_SHOW_COACH_MARK_ADD_PARTICIPANT_TO_CALL;
            break;
            
        case TAG_COACH_MARK_PRIVACY:
            key = LAST_SHOW_COACH_MARK_PRIVACY;
            break;
            
        case TAG_COACH_MARK_CONTACT_CAPABILITIES:
            key = LAST_SHOW_COACH_MARK_CONTACT_CAPABILITIES;
            break;
            
        case TAG_COACH_MARK_CONVERSATION_EPHEMERAL:
            key = LAST_SHOW_COACH_MARK_CONVERSATION_EPHEMERAL;
            break;
            
        default:
            break;
    }
    
    return key;
}

- (NSString *)getCountShowCoachMarkKey:(CoachMarkTag)coachMarkTag {
    
    NSString *key;
    
    switch (coachMarkTag) {
        case TAG_COACH_MARK_ADD_PARTICIPANT_TO_CALL:
            key = COUNT_SHOW_COACH_MARK_ADD_PARTICIPANT_TO_CALL;
            break;
            
        case TAG_COACH_MARK_PRIVACY:
            key = COUNT_SHOW_COACH_MARK_PRIVACY;
            break;
            
        case TAG_COACH_MARK_CONTACT_CAPABILITIES:
            key = COUNT_SHOW_COACH_MARK_CONTACT_CAPABILITIES;
            break;
            
        case TAG_COACH_MARK_CONVERSATION_EPHEMERAL:
            key = COUNT_SHOW_COACH_MARK_CONVERSATION_EPHEMERAL;
            break;
            
        default:
            break;
    }
    
    return key;
}

@end

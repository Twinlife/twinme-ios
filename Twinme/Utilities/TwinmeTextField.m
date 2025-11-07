/*
 *  Copyright (c) 2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "TwinmeTextField.h"

//
// Interface: TwinmeTextField
//

@interface TwinmeTextField ()

@end

//
// Implementation: TwinmeTextField
//

@implementation TwinmeTextField

- (void)paste:(id)sender {
        
    NSString *content;
    if ([[UIPasteboard generalPasteboard] URL]) {
        content = [[[UIPasteboard generalPasteboard] URL] absoluteString];
    } else if ([[UIPasteboard generalPasteboard] string]) {
        content = [[UIPasteboard generalPasteboard] string];
    }
    
    if (content) {
        [[NSNotificationCenter defaultCenter] postNotificationName:TwinmeTextFieldDidPasteItemNotification object:content];
    }
}

- (void)deleteBackward {
    
    if (self.overrideDeleteBackWard) {
        [[NSNotificationCenter defaultCenter] postNotificationName:TwinmeTextFieldDeleteBackWardNotification object:self];
    } else {
        [super deleteBackward];
    }
}

- (void)drawRect:(CGRect)rect {
    
    [super drawRect:rect];
}

@end

/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "ShareItemSource.h"

#import <LinkPresentation/LinkPresentation.h>

//
// Interface: ShareItemSource
//

@interface ShareItemSource ()

@property (nonatomic, copy) NSString *message;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, copy) NSString *subject;

@end

//
// Implementation: ShareItemSource
//

@implementation ShareItemSource

- (nonnull instancetype)initWithMessage:(nonnull NSString *)message subject:(nullable NSString *)subject {
    
    self = [super init];
    
    if (self) {
        _message = message;
        _subject = subject;
    }
    
    return self;
}

#pragma mark - UIActivityItemSource

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController {

    return self.message;
}

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(UIActivityType)activityType {

    return self.message;
}

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController subjectForActivityType:(UIActivityType)activityType {

    return self.subject;
}

- (LPLinkMetadata *)activityViewControllerLinkMetadata:(UIActivityViewController *)activityViewController API_AVAILABLE(ios(13.0)) {
    
    LPLinkMetadata *linkMetadata = [LPLinkMetadata new];
    linkMetadata.title = self.subject;
    return linkMetadata;
}

@end

/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "UIExport.h"

#import <Utils/NSString+Utils.h>

//
// Implementation: UIExport
//

@implementation UIExport

- (nonnull instancetype)initWithExportContentType:(ExportContentType)exportContentType image:(nonnull UIImage *)image checked:(BOOL)checked {
    
    self = [super init];
    
    if (self) {
        _exportContentType = exportContentType;
        _checked = checked;
        _exportImage = image;
    }
    return self;
}

- (nonnull NSString *)getTitle {
    
    NSString *title = @"";
    
    switch (self.exportContentType) {
        case ExportContentTypeMessage:
            title = TwinmeLocalizedString(@"settings_view_controller_chat_category_title", nil);
            break;
            
        case ExportContentTypeImage:
            title = TwinmeLocalizedString(@"export_view_controller_images", nil);
            break;
            
        case ExportContentTypeVideo:
            title = TwinmeLocalizedString(@"export_view_controller_videos", nil);
            break;
            
        case ExportContentTypeAudio:
            title = TwinmeLocalizedString(@"export_view_controller_voice_messages", nil);
            break;
            
        case ExportContentTypeFile:
            title = TwinmeLocalizedString(@"export_view_controller_files", nil).capitalizedString;
            break;
            
        case ExportContentTypeMediaAndFile:
            title = TwinmeLocalizedString(@"cleanup_view_controller_medias_and_files", nil);
            break;
            
        case ExportContentTypeAll:
            title = TwinmeLocalizedString(@"cleanup_view_controller_messages", nil);
            break;
            
        default:
            break;
    }
    
    return title;
}

- (nonnull NSString *)getInformation {
    
    NSString *information = @"";
    NSString *contentType = [self getContentType];
    
    if (self.size > 0) {
        information = [NSString stringWithFormat:@"%lld %@ - %@", self.count, contentType, [self getContentSize:self.size]];
    } else {
        information = [NSString stringWithFormat:@"%lld %@", self.count, contentType];
    }
    
    return information;
}

- (NSString *)getContentType {
    
    NSString *contentType = @"";
    
    if (self.exportContentType == ExportContentTypeMessage || self.exportContentType == ExportContentTypeAll) {
        if (self.count > 1) {
            contentType = TwinmeLocalizedString(@"settings_view_controller_chat_category_title", nil);
        } else {
            contentType = TwinmeLocalizedString(@"feedback_view_controller_message", nil);
        }
    } else {
        if (self.count > 1) {
            contentType = TwinmeLocalizedString(@"export_view_controller_files", nil);
        } else {
            contentType = TwinmeLocalizedString(@"export_view_controller_file", nil);
        }
    }
    
    return contentType.lowercaseString;
}

- (NSString *)getContentSize:(int64_t)sizeContent {
    
    NSByteCountFormatter *byteCountFormatter = [[NSByteCountFormatter alloc] init];
    byteCountFormatter.countStyle = NSByteCountFormatterCountStyleFile;
    return [byteCountFormatter stringFromByteCount:sizeContent];
}

@end

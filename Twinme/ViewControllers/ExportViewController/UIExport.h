/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

typedef enum {
    ExportContentTypeMessage,
    ExportContentTypeImage,
    ExportContentTypeVideo,
    ExportContentTypeAudio,
    ExportContentTypeFile,
    ExportContentTypeMediaAndFile,
    ExportContentTypeAll
} ExportContentType;


//
// Interface: UIExport
//

@interface UIExport : NSObject

@property (nonatomic, nonnull) UIImage *exportImage;
@property (nonatomic) ExportContentType exportContentType;
@property (nonatomic) int64_t count;
@property (nonatomic) int64_t size;
@property (nonatomic) BOOL checked;

- (nonnull instancetype)initWithExportContentType:(ExportContentType)exportContentType image:(nonnull UIImage *)image checked:(BOOL)checked;

- (nonnull NSString *)getTitle;

- (nonnull NSString *)getInformation;

@end

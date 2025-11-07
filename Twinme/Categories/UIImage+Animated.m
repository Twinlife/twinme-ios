/*
 *  Copyright (c) 2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "UIImage+Animated.h"

#import <ImageIO/ImageIO.h>

#import <MobileCoreServices/UTCoreTypes.h>
#import <MobileCoreServices/UTType.h>

#define DEFAULT_DURATION 3

@implementation UIImage (Animated)

+ (CGFloat)imageDurationAtIndex:(NSUInteger)index source:(CGImageSourceRef)source {
    
    CGFloat duration = 1.0f;
    CFDictionaryRef properties = CGImageSourceCopyPropertiesAtIndex(source, index, nil);
    if (properties) {
        NSDictionary *frameProperties = (__bridge NSDictionary *)properties;
        NSDictionary *gifProperties = frameProperties[(NSString *)kCGImagePropertyGIFDictionary];
        if (gifProperties) {
            NSNumber *propertyUnclampedDelayTime =  gifProperties[(NSString *)kCGImagePropertyGIFUnclampedDelayTime];
            if (propertyUnclampedDelayTime) {
                duration = [propertyUnclampedDelayTime floatValue];
            } else {
                NSNumber *propertyDelayTime = gifProperties[(NSString *)kCGImagePropertyGIFDelayTime];
                if (propertyDelayTime) {
                    duration = [propertyDelayTime floatValue];
                }
            }
        }
        CFRelease(properties);
    }
    return duration;
}

+ (nullable UIImage *)animatedImageWithData:(nonnull NSData *)data {
    
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, nil);
    if (source) {
        UIImage *image;
        
        size_t count = CGImageSourceGetCount(source);
        
        if (count <= 1) {
            UIImage* result = [[UIImage alloc] initWithData:data];
            CFRelease(source);
            return result;
        }
        
        NSMutableArray *images = [NSMutableArray array];
        NSTimeInterval duration = 0;
        
        for (int i = 0; i < count; i++) {
            CGImageRef image = CGImageSourceCreateImageAtIndex(source, i, NULL);
            duration += [self imageDurationAtIndex:i source:source];
            [images addObject:[UIImage imageWithCGImage:image]];
            CGImageRelease(image);
        }
        
        if (!duration) {
            duration = DEFAULT_DURATION;
        }
        
        image = [UIImage animatedImageWithImages:images duration:duration];
        CFRelease(source);
        return image;
    } else {
        return nil;
    }
}

+ (void)animatedImageWithURL:(nonnull NSURL *)url completion:(nonnull AnimatedImageCompletion)completion {
                           
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        NSData *data = [NSData dataWithContentsOfURL:url];
        
        if (!data) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, url);
            });
            return;
        }
        
        CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, nil);
        if (source) {
            UIImage *image;
            
            size_t count = CGImageSourceGetCount(source);
            
            if (count <= 1) {
                UIImage* result = [[UIImage alloc] initWithData:data];
                CFRelease(source);
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(result, url);
                });
                return;
            }
            
            NSMutableArray *images = [NSMutableArray array];
            NSTimeInterval duration = 0;
            
    
            for (int i = 0; i < count; i++) {
                @autoreleasepool {
                    CGImageRef image = CGImageSourceCreateImageAtIndex(source, i, NULL);
                    duration += [self imageDurationAtIndex:i source:source];
                    [images addObject:[UIImage imageWithCGImage:image]];
                    CGImageRelease(image);
                }
            }
            
            if (!duration) {
                duration = DEFAULT_DURATION;
            }
            
            image = [UIImage animatedImageWithImages:images duration:duration];
            CFRelease(source);

            dispatch_async(dispatch_get_main_queue(), ^{
                completion(image, url);
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, url);
            });
        }
    });
}

+ (void)animatedThumbnailWithURL:(nonnull NSURL *)url maxSize:(CGFloat)maxSize completion:(nonnull AnimatedImageCompletion)completion {
                           
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        NSData *data = [NSData dataWithContentsOfURL:url];
        
        if (!data) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, url);
            });
            return;
        }
        
        CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, nil);
        if (source) {
            UIImage *image;
            
            NSDictionary *thumbnailOptions = @{
                    (__bridge NSString *)kCGImageSourceCreateThumbnailFromImageAlways : @YES,
                    (__bridge NSString *)kCGImageSourceThumbnailMaxPixelSize : @(maxSize),
                    (__bridge NSString *)kCGImageSourceCreateThumbnailWithTransform : @YES,
                    (__bridge NSString *)kCGImageSourceShouldCache : @NO
                };
            
            size_t count = CGImageSourceGetCount(source);
            
            if (count <= 1) {
                UIImage* result = [[UIImage alloc] initWithData:data];
                CFRelease(source);
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(result, url);
                });
                return;
            }
            
            NSMutableArray *images = [NSMutableArray array];
            NSTimeInterval duration = 0;
            
    
            for (int i = 0; i < count; i++) {
                @autoreleasepool {
                    CGImageRef image = CGImageSourceCreateThumbnailAtIndex(source, i, (__bridge CFDictionaryRef)thumbnailOptions);
                    duration += [self imageDurationAtIndex:i source:source];
                    [images addObject:[UIImage imageWithCGImage:image]];
                    CGImageRelease(image);
                }
            }
            
            if (!duration) {
                duration = DEFAULT_DURATION;
            }
            
            image = [UIImage animatedImageWithImages:images duration:duration];
            CFRelease(source);

            dispatch_async(dispatch_get_main_queue(), ^{
                completion(image, url);
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, url);
            });
        }
    });
}

+ (BOOL)isAnimatedImage:(NSString *)file {
    
    CFStringRef fileType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef) [file pathExtension], NULL);
    BOOL result = UTTypeConformsTo(fileType, kUTTypeGIF);
    CFRelease(fileType);
    return result;
}

@end

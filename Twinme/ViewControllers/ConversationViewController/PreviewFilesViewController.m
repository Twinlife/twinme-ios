/*
 *  Copyright (c) 2024-2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (fabrice.trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Photos/Photos.h>
#import <PhotosUI/PhotosUI.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <MobileCoreServices/UTType.h>

#import <Utils/NSString+Utils.h>

#import "PreviewFilesViewController.h"
#import "ConversationViewController.h"
#import "FullScreenImageCell.h"
#import "FullScreenVideoCell.h"
#import "PreviewAddCell.h"
#import "PreviewThumbnailCell.h"
#import "PreviewFileCell.h"
#import "UIPreviewFile.h"
#import "UIPreviewInfo.h"
#import "UIPreviewMedia.h"
#import "AlertMessageView.h"
#import <Twinme/UIImage+Resize.h>

#import "UIImage+Animated.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static NSString *FULL_SCREEN_IMAGE_CELL_IDENTIFIER = @"FullScreenImageCellIdentifier";
static NSString *FULL_SCREEN_VIDEO_CELL_IDENTIFIER = @"FullScreenVideoCellIdentifier";
static NSString *PREVIEW_FILE_CELL_IDENTIFIER = @"PreviewFileCellIdentifier";
static NSString *PREVIEW_ADD_CELL_IDENTIFIER = @"PreviewAddCellIdentifier";
static NSString *PREVIEW_THUMBNAIL_CELL_IDENTIFIER = @"PreviewThumbnailCellIdentifier";

static CGFloat DESIGN_THUMBNAIL_SIZE = 120;

//
// Interface: PreviewFilesViewController ()
//

@interface PreviewFilesViewController ()<UICollectionViewDelegate, UICollectionViewDataSource,UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPickerViewControllerDelegate, UIDocumentPickerDelegate, UIDocumentInteractionControllerDelegate, AlertMessageViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *filesCollectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *thumbnailCollectionViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *thumbnailCollectionViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UICollectionView *thumbnailCollectionView;
@property (weak, nonatomic) IBOutlet UIView *overlayView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@property (nonatomic) NSInteger currentItemIndex;
@property (nonatomic) NSMutableArray *files;
@property (nonatomic) int countFilePicking;
@property (nonatomic) BOOL endFilePicking;
@property (nonatomic) BOOL pickMediaError;

@end

//
// Implementation: PreviewFilesViewController
//

#undef LOG_TAG
#define LOG_TAG @"PreviewFilesViewController"

@implementation PreviewFilesViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _files = [[NSMutableArray alloc]init];
        _endFilePicking = NO;
        _pickMediaError = NO;
        _countFilePicking = 0;
        _startWithMedia = NO;
        _currentItemIndex = 0;
    }
    return self;
}

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillAppear: %@", LOG_TAG, animated ? @"YES" : @"NO");
    
    [super viewWillAppear:animated];
    
    if (self.startWithMedia) {
        self.currentItemIndex = [self getCurrentIndex];
    }
}

- (void)close {
    DDLogVerbose(@"%@ close", LOG_TAG);
    
    for (UIPreviewInfo *previewInfo in self.files) {
        if (previewInfo.previewType == PreviewTypeImage || previewInfo.previewType == PreviewTypeVideo) {
            UIPreviewMedia *previewMedia = (UIPreviewMedia *)previewInfo;
            if ([[NSFileManager defaultManager]fileExistsAtPath:previewMedia.path]) {
                [[NSFileManager defaultManager]removeItemAtPath:previewMedia.path error:nil];
            }
        }
    }
    
    [self finish];
}

- (void)send:(BOOL)allowCopyText allowCopyFile:(BOOL)allowCopyFile {
    DDLogVerbose(@"%@ send: %@ allowCopyFile: %@", LOG_TAG, allowCopyText ? @"YES" : @"NO", allowCopyFile ? @"YES" : @"NO");
    
    self.countFilePicking = 0;
    self.endFilePicking = NO;
    
    for (UIPreviewInfo *previewInfo in self.files) {
        self.countFilePicking++;
        if (previewInfo.previewType == PreviewTypeImage || previewInfo.previewType == PreviewTypeVideo) {
            UIPreviewMedia *previewMedia = (UIPreviewMedia *)previewInfo;
   
            if (previewMedia.previewType == PreviewTypeVideo) {
                if (self.twinmeApplication.sendVideoSize == SendVideoSizeOriginal) {
                    [self.previewViewDelegate sendVideo:previewMedia.path allowCopyFile:allowCopyFile];
                    self.countFilePicking--;
                    [self isAllMediaSent:allowCopyText];
                } else {
                    NSURL *url = [NSURL fileURLWithPath:previewMedia.path];
                    AVURLAsset *urlAsset = [[AVURLAsset alloc] initWithURL:url options:nil];
                    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:urlAsset presetName:AVAssetExportPresetMediumQuality];
                    NSString *fileName = [NSString stringWithFormat:@"%@.mp4", [[NSProcessInfo processInfo] globallyUniqueString]];
                    NSURL *outputURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:fileName]];
                    exportSession.outputURL = outputURL;
                    exportSession.outputFileType = AVFileTypeMPEG4;
                    exportSession.shouldOptimizeForNetworkUse = YES;
                    [exportSession exportAsynchronouslyWithCompletionHandler:^{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if ([exportSession status] == AVAssetExportSessionStatusCompleted) {
                                if ([[NSFileManager defaultManager]fileExistsAtPath:previewMedia.path]) {
                                    [[NSFileManager defaultManager]removeItemAtPath:previewMedia.path error:nil];
                                }
                                [self.previewViewDelegate sendVideo:outputURL.path allowCopyFile:allowCopyFile];
                            } else {
                                [self.previewViewDelegate sendVideo:previewMedia.path allowCopyFile:allowCopyFile];
                            }
                            self.countFilePicking--;
                            [self isAllMediaSent:allowCopyText];
                        });
                    }];
                }
            } else {
                if (self.twinmeApplication.sendImageSize == SendImageSizeOriginal) {
                    [self.previewViewDelegate sendImage:previewMedia.path allowCopyFile:allowCopyFile];
                    self.countFilePicking--;
                    [self isAllMediaSent:allowCopyText];
                } else {
                    [self resizeImage:previewMedia];
                    [self.previewViewDelegate sendImage:previewMedia.path allowCopyFile:allowCopyFile];
                    self.countFilePicking--;
                    [self isAllMediaSent:allowCopyText];
                }
            }
        } else {
            UIPreviewFile *previewFile = (UIPreviewFile *)previewInfo;
            [self.previewViewDelegate sendFile:previewFile.url.path allowCopyFile:allowCopyFile];
            self.countFilePicking--;
            [self isAllMediaSent:allowCopyText];
        }
    }
    
    self.endFilePicking = YES;
    [self isAllMediaSent:allowCopyText];
}

- (void)isAllMediaSent:(BOOL)allowCopyText {
    DDLogVerbose(@"%@ isAllMediaSent", LOG_TAG);
    
    if (self.endFilePicking && self.countFilePicking == 0) {
        
        NSString *message = self.messageTextView.text;
        if ([self.messageTextView.text isEqualToString:TwinmeLocalizedString(@"conversation_view_controller_message", nil)]) {
            message = @"";
        }
        
        [self.previewViewDelegate sendMediaCaption:message allowCopyText:allowCopyText];

        [self finish];
    }
}

- (void)initWithPreviewMedia:(NSArray *)previewMedias errorPicking:(BOOL)errorPicking {
    DDLogVerbose(@"%@ initWithPreviewMedia: %@", LOG_TAG, previewMedias);
    
    [self.files addObjectsFromArray:previewMedias];
    
    if (errorPicking) {
        AlertMessageView *alertMessageView = [[AlertMessageView alloc] init];
        alertMessageView.alertMessageViewDelegate = self;
        alertMessageView.forceDarkMode = YES;
        [alertMessageView initWithTitle:TwinmeLocalizedString(@"delete_account_view_controller_warning", nil) message:TwinmeLocalizedString(@"application_error_media_not_supported", nil)];
        [self.view addSubview:alertMessageView];
        [alertMessageView showAlertView];
    }
}

- (void)initWithImage:(NSURL *)url size:(CGSize)size {
    DDLogVerbose(@"%@ initWithImage: %@", LOG_TAG, url);
    
    UIPreviewMedia *previewMedia = [[UIPreviewMedia alloc]initWithUrl:url path:url.path size:size isVideo:NO];
    [self.files addObject:previewMedia];
}

- (void)initWithVideo:(NSURL *)url {
    DDLogVerbose(@"%@ initWithVideo: %@", LOG_TAG, url);
    
    UIPreviewMedia *previewMedia = [[UIPreviewMedia alloc]initWithUrl:url path:url.path size:CGSizeZero isVideo:YES];
    [self.files addObject:previewMedia];
}

- (void)initWithPreviewFiles:(NSArray <NSURL *>*)previewFiles {
    DDLogVerbose(@"%@ initWithPreviewFiles: %@", LOG_TAG, previewFiles);
    
    for (NSURL *url in previewFiles) {
        [self addPreviewFile:url fromPicker:NO];
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)pickerController didFinishPickingMediaWithInfo:(NSDictionary *)info {
    DDLogVerbose(@"%@ imagePickerController: %@ didFinishPickingMediaWithInfo: %@", LOG_TAG, pickerController, info);
    
    [pickerController dismissViewControllerAnimated:YES completion:^{
        if (!info) {
            return;
        }
        
        self.countFilePicking = 0;
        self.endFilePicking = NO;
        self.pickMediaError = NO;
        
        CFStringRef mediaType = (__bridge CFStringRef)([info objectForKey:@"UIImagePickerControllerMediaType"]);
        if (UTTypeConformsTo(mediaType, kUTTypeMovie)) {
            self.countFilePicking++;
            NSURL *url = [info objectForKey:@"UIImagePickerControllerMediaURL"];
            AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:url options:nil];
            NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
            if ([compatiblePresets containsObject:AVAssetExportPresetHighestQuality]) {
                AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset presetName:AVAssetExportPresetHighestQuality];
                NSString *videoPath = [url.path stringByReplacingOccurrencesOfString:url.pathExtension withString:@"mp4"];
                NSURL *urlExport = [[NSURL alloc] initFileURLWithPath:videoPath];
                if ([[NSFileManager defaultManager]fileExistsAtPath:videoPath]) {
                    [[NSFileManager defaultManager]removeItemAtPath:videoPath error:nil];
                }
                exportSession.outputURL = urlExport;
                exportSession.outputFileType = AVFileTypeMPEG4;
                exportSession.shouldOptimizeForNetworkUse = YES;
                [exportSession exportAsynchronouslyWithCompletionHandler:^{
                    if ([exportSession status] == AVAssetExportSessionStatusCompleted) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self addPreviewVideo:urlExport];
                            [[NSFileManager defaultManager]removeItemAtPath:url.path error:nil];
                        });
                        
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.pickMediaError = YES;
                            [self addPreviewVideo:nil];
                        });
                    }
                }];
            } else {
                [self addPreviewVideo:url];
            }
        } else if (UTTypeConformsTo(mediaType, kUTTypeImage)) {
            
            UIImage *originalImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
            NSURL *urlImage = [info objectForKey:@"UIImagePickerControllerImageURL"];
            
            if ([info objectForKey:@"UIImagePickerControllerPHAsset"]) {
                self.countFilePicking++;
                PHAsset *asset = [info objectForKey:@"UIImagePickerControllerPHAsset"];
                PHImageRequestOptions *imageRequestOptions = [[PHImageRequestOptions alloc] init];
                imageRequestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
                imageRequestOptions.networkAccessAllowed = YES;
                [[PHImageManager defaultManager] requestImageDataForAsset:asset options:imageRequestOptions resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                    
                    if (imageData) {
                        NSString *imgExtension = @".jpg";
                        if ([dataUTI isEqualToString:@"com.compuserve.gif"]) {
                            imgExtension = @".gif";
                        }
                        
                        UIImage *img = [[UIImage alloc] initWithData:imageData];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self addPreviewImage:img imageData:imageData imageExtension:imgExtension];
                        });
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self addPreviewImage:nil imageData:nil imageExtension:nil];
                        });
                    }
                }];
            } else if (originalImage && urlImage) {
                self.countFilePicking++;
                NSString *imgExtension = @".jpg";
                if (urlImage && [UIImage isAnimatedImage:[urlImage absoluteString]]) {
                    imgExtension = @".gif";
                }
                
                [self addPreviewImage:originalImage imageData:[NSData dataWithContentsOfURL:urlImage] imageExtension:imgExtension];
            } else if (originalImage) {
                self.countFilePicking++;
                [self addPreviewImage:originalImage imageData:nil imageExtension:@".jpg"];
            }
        }
        
        self.endFilePicking = YES;
        [self loadFileFromPicker];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)pickerController {
    DDLogVerbose(@"%@ imagePickerControllerDidCancel: %@", LOG_TAG, pickerController);
    
    [pickerController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - PHPickerViewControllerDelegate

- (void)picker:(PHPickerViewController *)pickerController didFinishPicking:(NSArray<PHPickerResult *> *)results API_AVAILABLE(ios(14)){
    DDLogVerbose(@"%@ picker: %@", LOG_TAG, pickerController);
        
    [pickerController dismissViewControllerAnimated:YES completion:^{
        if (!results || results.count == 0) {
            return;
        }
        
        self.countFilePicking = 0;
        self.endFilePicking = NO;
        self.pickMediaError = NO;
        
        for (PHPickerResult *result in results) {
            if ([result.itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeImage]) {
                
                self.countFilePicking++;
                [result.itemProvider loadDataRepresentationForTypeIdentifier:(NSString *)kUTTypeImage
                                                           completionHandler:^(NSData * _Nullable data,
                                                                               NSError * _Nullable error) {
                    if (!error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, nil);
                            NSString *extension = @".jpg";
                            if (source) {
                                size_t count = CGImageSourceGetCount(source);
                                if (count > 1) {
                                    extension = @".gif";
                                }
                                CFRelease(source);
                            }
                            
                            UIImage *image = [UIImage imageWithData:data];
                            
                            [self addPreviewImage:image imageData:data imageExtension:extension];
                        });
                    } else {
                        self.pickMediaError = YES;
                        [self addPreviewImage:nil imageData:nil imageExtension:nil];
                    }
                }];
            } else if ([result.itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeMovie]) {
                
                self.countFilePicking++;
                [result.itemProvider loadFileRepresentationForTypeIdentifier:(NSString *)kUTTypeMovie
                                                           completionHandler:^(NSURL * _Nullable url,
                                                                               NSError * _Nullable error) {
                    
                    if (!error) {
                        NSString *fileName = [NSString stringWithFormat:@"%@_.%@", [[NSProcessInfo processInfo] globallyUniqueString], url.pathExtension];
                        
                        NSURL *tmpUrl = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:fileName]];
                        [[NSFileManager defaultManager] copyItemAtURL:url toURL:tmpUrl error:nil];
                        
                        AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:tmpUrl options:nil];
                        NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
                        if ([compatiblePresets containsObject:AVAssetExportPresetHighestQuality]) {
                            AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset presetName:AVAssetExportPresetHighestQuality];
                            NSString *videoPath = [tmpUrl.path stringByReplacingOccurrencesOfString:tmpUrl.pathExtension withString:@"mp4"];
                            NSURL *urlExport = [[NSURL alloc] initFileURLWithPath:videoPath];
                            if ([[NSFileManager defaultManager]fileExistsAtPath:videoPath]) {
                                [[NSFileManager defaultManager]removeItemAtPath:videoPath error:nil];
                            }
                            exportSession.outputURL = urlExport;
                            exportSession.outputFileType = AVFileTypeMPEG4;
                            exportSession.shouldOptimizeForNetworkUse = YES;
                            [exportSession exportAsynchronouslyWithCompletionHandler:^{
                                if ([exportSession status] == AVAssetExportSessionStatusCompleted) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [self addPreviewVideo:urlExport];
                                        if (![urlExport.path isEqual:tmpUrl.path]) {
                                            [[NSFileManager defaultManager]removeItemAtPath:tmpUrl.path error:nil];
                                        }
                                    });
                                } else {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        self.pickMediaError = YES;
                                        [self addPreviewVideo:nil];
                                    });
                                }
                            }];
                        } else {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self addPreviewVideo:tmpUrl];
                            });
                        }
                    } else {
                        self.pickMediaError = YES;
                        [self addPreviewVideo:nil];
                    }
                }];
            }
        }
        
        self.endFilePicking = YES;
        [self loadFileFromPicker];
    }];
}

#pragma mark - DocumentPickerDelegate

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray <NSURL *>*)urls {
    DDLogVerbose(@"%@ documentPicker: %@ didPickDocumentsAtURLs: %@", LOG_TAG, controller, urls);
    
    if (urls.count == 0) {
        return;
    }
    
    self.countFilePicking = 0;
    self.endFilePicking = NO;
    self.pickMediaError = NO;
    
    for (NSURL *url in urls) {
        NSNumber *value = nil;
        [url getResourceValue:&value forKey:NSURLIsPackageKey error:nil];
        if ([value boolValue]) {
            self.pickMediaError = YES;
        }
        
        if (controller.documentPickerMode == UIDocumentPickerModeImport) {
            self.countFilePicking++;
            [self addPreviewFile:url fromPicker:YES];
        }
    }
    
    self.endFilePicking = YES;
    [self loadFileFromPicker];
}

#pragma mark - DocumentInteractionControllerDelegate

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
    
    return self;
}


#pragma mark - AlertMessageViewDelegate

- (void)didCloseAlertMessage:(nonnull AlertMessageView *)alertMessageView {
    DDLogVerbose(@"%@ didCloseAlertMessage: %@", LOG_TAG, alertMessageView);
    
    [alertMessageView closeAlertView];
}

- (void)didFinishCloseAlertMessageAnimation:(nonnull AlertMessageView *)alertMessageView {
    DDLogVerbose(@"%@ didFinishCloseAlertMessageAnimation: %@", LOG_TAG, alertMessageView);
    
    [alertMessageView removeFromSuperview];
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    DDLogVerbose(@"%@ numberOfSectionsInCollectionView: %@", LOG_TAG, collectionView);
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ collectionView: %@ numberOfItemsInSection: %ld", LOG_TAG, collectionView, (long)section);
    
    if (collectionView == self.filesCollectionView) {
        return self.files.count;
    }
    return self.files.count + 1;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ collectionView: %@ layout: %@ sizeForItemAtIndexPath: %@", LOG_TAG, collectionView, collectionViewLayout, indexPath);
    
    if (collectionView == self.filesCollectionView) {
        return CGSizeMake(Design.DISPLAY_WIDTH, Design.DISPLAY_HEIGHT);
    }
    
    return CGSizeMake(DESIGN_THUMBNAIL_SIZE * Design.HEIGHT_RATIO, DESIGN_THUMBNAIL_SIZE * Design.HEIGHT_RATIO);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    DDLogVerbose(@"%@ collectionView: %@ layout: %@ minimumLineSpacingForSectionAtIndex: %ld", LOG_TAG, collectionView, collectionViewLayout, (long)section);
    
    return CGFLOAT_MIN;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ collectionView: %@ layout: %@ referenceSizeForHeaderInSection: %ld", LOG_TAG, collectionView, collectionViewLayout, (long)section);
    
    return CGSizeMake(0, 0);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ collectionView: %@ cellForItemAtIndexPath: %@", LOG_TAG, collectionView, indexPath);
    
    if (collectionView == self.filesCollectionView) {
        UIPreviewInfo *previewInfo = [self.files objectAtIndex:indexPath.row];
        if ([previewInfo isMedia]) {
            UIPreviewMedia *previewMedia = (UIPreviewMedia *)previewInfo;
            if (previewMedia.previewType == PreviewTypeVideo) {
                FullScreenVideoCell *fullScreenVideoCell = [collectionView dequeueReusableCellWithReuseIdentifier:FULL_SCREEN_VIDEO_CELL_IDENTIFIER forIndexPath:indexPath];
                [fullScreenVideoCell bindWithPreviewMedia:previewMedia];
                return fullScreenVideoCell;
            } else {
                FullScreenImageCell *fullScreenImageCell = [collectionView dequeueReusableCellWithReuseIdentifier:FULL_SCREEN_IMAGE_CELL_IDENTIFIER forIndexPath:indexPath];
                [fullScreenImageCell bindWithPreviewMedia:previewMedia];
                return fullScreenImageCell;
            }
        } else {
            PreviewFileCell *previewFileCell = [collectionView dequeueReusableCellWithReuseIdentifier:PREVIEW_FILE_CELL_IDENTIFIER forIndexPath:indexPath];
            UIPreviewFile *previewFile = (UIPreviewFile *)previewInfo;
            [previewFileCell bind:previewFile];
            return previewFileCell;
        }
    } else {
        if (indexPath.row == self.files.count) {
            PreviewAddCell *previewAddCell = [collectionView dequeueReusableCellWithReuseIdentifier:PREVIEW_ADD_CELL_IDENTIFIER forIndexPath:indexPath];
            [previewAddCell bind];
            return previewAddCell;
        } else {
            UIPreviewInfo *previewInfo = [self.files objectAtIndex:indexPath.row];
            PreviewThumbnailCell *previewThumbnailCell = [collectionView dequeueReusableCellWithReuseIdentifier:PREVIEW_THUMBNAIL_CELL_IDENTIFIER forIndexPath:indexPath];
            if ([previewInfo isMedia]) {
                UIPreviewMedia *previewMedia = (UIPreviewMedia *)previewInfo;
                [previewThumbnailCell bindWithPreviewMedia:previewMedia isCurrentPreview:self.currentItemIndex == indexPath.row candDelete:self.files.count > 1];
            } else {
                UIPreviewFile *previewFile = (UIPreviewFile *)previewInfo;
                [previewThumbnailCell bindWithPreviewFile:previewFile isCurrentPreview:self.currentItemIndex == indexPath.row candDelete:self.files.count > 1];
            }
            return previewThumbnailCell;
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ collectionView: %@ didEndDisplayingCell: %@", LOG_TAG, collectionView, indexPath);
            
    if (collectionView == self.filesCollectionView && indexPath.row < [self.files count]) {
        
        UIPreviewInfo *previewInfo = [self.files objectAtIndex:indexPath.row];
        if ([previewInfo isMedia]) {
            UIPreviewMedia *previewMedia = (UIPreviewMedia *)previewInfo;
            if (previewMedia.previewType == PreviewTypeImage) {
                if ([cell isKindOfClass:[FullScreenImageCell class]]) {
                    FullScreenImageCell *fullScreenImageCell = (FullScreenImageCell *)cell;
                    [fullScreenImageCell resetZoom];
                }
            } else {
                if ([cell isKindOfClass:[FullScreenVideoCell class]]) {
                    FullScreenVideoCell *fullScreenVideoCell = (FullScreenVideoCell *)cell;
                    [fullScreenVideoCell stopVideo];
                }
            }
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    DDLogVerbose(@"%@ scrollViewDidEndDecelerating: %@", LOG_TAG, scrollView);
    
    if (scrollView == self.filesCollectionView) {
        CGFloat offset = scrollView.contentOffset.x;
        CGFloat width = scrollView.frame.size.width;
        CGFloat center = width / 2.0;
        int currentPage = (int) ((offset + center) / width);
        
        if (self.currentItemIndex != currentPage) {
            NSMutableArray *indexPaths = [[NSMutableArray alloc]init];
            [indexPaths addObject:[NSIndexPath indexPathForRow:self.currentItemIndex inSection:0]];

            self.currentItemIndex = currentPage;
            
            [indexPaths addObject:[NSIndexPath indexPathForRow:currentPage inSection:0]];
            [self.thumbnailCollectionView reloadItemsAtIndexPaths:indexPaths];
        }
    }
}

- (CGPoint)collectionView:(UICollectionView *)collectionView targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset {
    DDLogVerbose(@"%@ collectionView: %@ targetContentOffsetForProposedContentOffset: %f", LOG_TAG, collectionView, proposedContentOffset.x);
    
    if (collectionView == self.filesCollectionView && self.currentItemIndex != -1) {
        UICollectionViewLayoutAttributes *attributes = [self.filesCollectionView layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:self.currentItemIndex inSection:0]];
        
        return attributes.frame.origin;
    }
    
    return proposedContentOffset;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ collectionView: %@ didSelectItemAtIndexPath: %@", LOG_TAG, collectionView, indexPath);
    
    if (collectionView == self.thumbnailCollectionView) {
        if (indexPath.row == self.files.count) {
            [self addFile];
        } else if (indexPath.row == self.currentItemIndex && self.files.count > 1) {
            [self removeFile:indexPath];
        } else {
            NSInteger previousIndex = self.currentItemIndex;
            self.currentItemIndex = indexPath.row;
            [self.thumbnailCollectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:previousIndex inSection:0], [NSIndexPath indexPathForRow:indexPath.row inSection:0]]];
            [self.filesCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionRight animated:NO];
        }
    }
}

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.filesCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.filesCollectionView.backgroundColor = [UIColor blackColor];
    self.filesCollectionView.pagingEnabled = YES;
    self.filesCollectionView.dataSource = self;
    self.filesCollectionView.delegate = self;
    [self.filesCollectionView registerNib:[UINib nibWithNibName:@"FullScreenImageCell" bundle:nil] forCellWithReuseIdentifier:FULL_SCREEN_IMAGE_CELL_IDENTIFIER];
    [self.filesCollectionView registerNib:[UINib nibWithNibName:@"FullScreenVideoCell" bundle:nil] forCellWithReuseIdentifier:FULL_SCREEN_VIDEO_CELL_IDENTIFIER];
    [self.filesCollectionView registerNib:[UINib nibWithNibName:@"PreviewFileCell" bundle:nil] forCellWithReuseIdentifier:PREVIEW_FILE_CELL_IDENTIFIER];

    UICollectionViewFlowLayout *viewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    [viewFlowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [viewFlowLayout setMinimumInteritemSpacing:0];
    [viewFlowLayout setMinimumLineSpacing:0];
    [viewFlowLayout setItemSize:CGSizeMake(Design.DISPLAY_WIDTH, Design.DISPLAY_HEIGHT)];
    [self.filesCollectionView setCollectionViewLayout:viewFlowLayout];
    [self.filesCollectionView reloadData];
    
    self.thumbnailCollectionViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.thumbnailCollectionViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.thumbnailCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.thumbnailCollectionView.backgroundColor = [UIColor clearColor];
    self.thumbnailCollectionView.dataSource = self;
    self.thumbnailCollectionView.delegate = self;
    [self.thumbnailCollectionView registerNib:[UINib nibWithNibName:@"PreviewAddCell" bundle:nil] forCellWithReuseIdentifier:PREVIEW_ADD_CELL_IDENTIFIER];
    [self.thumbnailCollectionView registerNib:[UINib nibWithNibName:@"PreviewThumbnailCell" bundle:nil] forCellWithReuseIdentifier:PREVIEW_THUMBNAIL_CELL_IDENTIFIER];
    
    UICollectionViewFlowLayout *previewThumbnailFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    [previewThumbnailFlowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [previewThumbnailFlowLayout setMinimumInteritemSpacing:0];
    [previewThumbnailFlowLayout setMinimumLineSpacing:0];
    CGFloat thumbnailSize = DESIGN_THUMBNAIL_SIZE * Design.HEIGHT_RATIO;
    [previewThumbnailFlowLayout setItemSize:CGSizeMake(thumbnailSize, thumbnailSize)];
    [self.thumbnailCollectionView setCollectionViewLayout:previewThumbnailFlowLayout];
    [self.thumbnailCollectionView reloadData];
    
    self.overlayView.backgroundColor = Design.OVERLAY_COLOR;
    self.overlayView.hidden = YES;
    
    self.activityIndicatorView.hidesWhenStopped = YES;
    self.activityIndicatorView.color = [UIColor whiteColor];
    
    [super initViews];
}

- (void)updateViews {
    DDLogVerbose(@"%@ updateViews", LOG_TAG);
    
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    [super finish];
}

- (void)resizeImage:(UIPreviewMedia *)previewMedia {
    DDLogVerbose(@"%@ resizeImage", LOG_TAG);
    
    NSString *fileName = [NSString stringWithFormat:@"%@_%@", [[NSProcessInfo processInfo] globallyUniqueString], @".jpg"];
    NSURL *url = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:fileName]];
    
    float maxSize = 0;
    
    if (self.twinmeApplication.sendImageSize == SendImageSizeMedium) {
        maxSize = STANDARD_RESOLUTION;
    } else {
        maxSize = MINIMAL_RESOLUTION;
    }
    
    float scale = 1;
    if (previewMedia.size.width > previewMedia.size.height) {
        scale = maxSize / previewMedia.size.width;
    } else {
        scale = maxSize / previewMedia.size.height;
    }
    
    if (scale >= 1) {
        return;
    }
    
    CGSize newSize = previewMedia.size;
    newSize.width = ceilf(scale * newSize.width);
    newSize.height = ceilf(scale * newSize.height);
    
    if (scale < MAX_COMPRESSION) {
        scale = MAX_COMPRESSION;
    }

    UIImage *originalImage = [UIImage imageWithContentsOfFile:previewMedia.path];
    UIImage *resizeImage = [originalImage resizeMedia:newSize];
    NSData *data = UIImageJPEGRepresentation(resizeImage, scale);
    if ([data writeToURL:url options:NSDataWritingAtomic error:nil]) {
        if ([[NSFileManager defaultManager]fileExistsAtPath:previewMedia.path]) {
            [[NSFileManager defaultManager]removeItemAtPath:previewMedia.path error:nil];
        }
        
        previewMedia.path = url.path;
    }
}

- (void)addPreviewImage:(UIImage *)image imageData:(NSData *)imageData imageExtension:(NSString *)imageExtension  {
    DDLogVerbose(@"%@ openPreviewImage: %@", LOG_TAG, image);
    
    if (image) {
        NSString *fileName = [NSString stringWithFormat:@"%@_%@", [[NSProcessInfo processInfo] globallyUniqueString], imageExtension];
        NSURL *url = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:fileName]];
        if (!imageData) {
            imageData = UIImageJPEGRepresentation(image, 1.0);
        }
        
        [imageData writeToURL:url options:NSDataWritingAtomic error:nil];
        
        UIPreviewMedia *previewMedia = [[UIPreviewMedia alloc]initWithUrl:url path:url.path size:image.size isVideo:NO];
        [self.files addObject:previewMedia];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.files.count - 1 inSection:0];
        [self.filesCollectionView insertItemsAtIndexPaths:@[indexPath]];
        [self.thumbnailCollectionView insertItemsAtIndexPaths:@[indexPath]];
    }
    
    self.countFilePicking--;
    [self loadFileFromPicker];
}

- (void)addPreviewVideo:(NSURL *)url {
    DDLogVerbose(@"%@ addPreviewVideo: %@", LOG_TAG, url);
    
    if (url) {
        UIPreviewMedia *previewMedia = [[UIPreviewMedia alloc]initWithUrl:url path:url.path size:CGSizeZero isVideo:YES];
        [self.files addObject:previewMedia];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.files.count - 1 inSection:0];
        [self.filesCollectionView insertItemsAtIndexPaths:@[indexPath]];
        [self.thumbnailCollectionView insertItemsAtIndexPaths:@[indexPath]];
    }
    
    self.countFilePicking--;
    [self loadFileFromPicker];
}

- (void)addPreviewFile:(NSURL *)url fromPicker:(BOOL)fromPicker {
    DDLogVerbose(@"%@ addPreviewFile: %@", LOG_TAG, url);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIDocumentInteractionController *documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:url];
        
        BOOL isImage = UTTypeConformsTo((__bridge CFStringRef _Nonnull)(documentInteractionController.UTI), kUTTypeImage);
        BOOL isVideo = UTTypeConformsTo((__bridge CFStringRef _Nonnull)(documentInteractionController.UTI), kUTTypeMovie);
        
        if (isImage) {
            UIPreviewMedia *previewMedia = [[UIPreviewMedia alloc]initWithUrl:url path:url.path size:CGSizeZero isVideo:NO];
            [self.files addObject:previewMedia];
            if (fromPicker) {
                [self addPreviewFileFromPicker];
            } else {
                [self reloadData];
            }
        } else if (isVideo) {
            UIPreviewMedia *previewMedia = [[UIPreviewMedia alloc]initWithUrl:url path:url.path size:CGSizeZero isVideo:YES];
            [self.files addObject:previewMedia];
            if (fromPicker) {
                [self addPreviewFileFromPicker];
            } else {
                [self reloadData];
            }
        } else {
            NSString *fileName = documentInteractionController.name;
            NSString *fileExtension = [url pathExtension];
            UIImage *fileIcon;
        
            if ([fileExtension.lowercaseString isEqualToString:@"pdf"]) {
                fileIcon = [UIImage imageNamed:@"FileIconPDF"];
            } else if ([fileExtension isEqualToString:@"doc"] || [fileExtension isEqualToString:@"docx"]) {
                fileIcon = [UIImage imageNamed:@"FileIconWord"];
            } else if ([fileExtension isEqualToString:@"xls"] || [fileExtension isEqualToString:@"xlsx"]) {
                fileIcon = [UIImage imageNamed:@"FileIconExcel"];
            } else if ([fileExtension isEqualToString:@"ppt"] || [fileExtension isEqualToString:@"pptx"]) {
                fileIcon = [UIImage imageNamed:@"FileIconPowerpoint"];
            } else if ([[documentInteractionController icons] count] > 0) {
                fileIcon = [[documentInteractionController icons] objectAtIndex:0];
            } else {
                fileIcon = [UIImage imageNamed:@"ToolbarFileGrey"];
            }
            
            NSError *error = nil;
            NSFileCoordinator *coordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
            [coordinator coordinateReadingItemAtURL:url options:NSFileCoordinatorReadingImmediatelyAvailableMetadataOnly error:&error byAccessor:^(NSURL *newURL) {
                
                NSError *error = nil;
                NSNumber *size;
                int64_t fileSize = 0;
                if([url getPromisedItemResourceValue:&size forKey:NSURLFileSizeKey error:&error]) {
                    fileSize = size.doubleValue;
                }
                
                UIPreviewFile *previewFile = [[UIPreviewFile alloc]initWithUrl:url title:fileName extension:fileExtension icon:fileIcon size:fileSize];
                [self.files addObject:previewFile];
                
                if (fromPicker) {
                    [self addPreviewFileFromPicker];
                } else {
                    [self reloadData];
                }
            }];
        }

    });
}

- (void)addPreviewFileFromPicker {
    DDLogVerbose(@"%@ addPreviewFileFromPicker", LOG_TAG);
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.files.count - 1 inSection:0];
    [self.filesCollectionView insertItemsAtIndexPaths:@[indexPath]];
    [self.thumbnailCollectionView insertItemsAtIndexPaths:@[indexPath]];
    
    self.countFilePicking--;
    [self loadFileFromPicker];
}
        
- (void)reloadData {
    DDLogVerbose(@"%@ reloadData", LOG_TAG);
    
    [self.filesCollectionView reloadData];
    [self.thumbnailCollectionView reloadData];
}

- (void)addFile {
    DDLogVerbose(@"%@ addFile", LOG_TAG);
    
    if (self.startWithMedia) {
        [self openGallery];
    } else {
        [self openFile];
    }
}

- (void)openGallery {
    DDLogVerbose(@"%@ openGallery", LOG_TAG);
    
    if (@available(iOS 14, *)) {
        PHPickerConfiguration *config = [[PHPickerConfiguration alloc] init];
        config.selectionLimit = 10;
        
        PHPickerViewController *pickerViewController = [[PHPickerViewController alloc] initWithConfiguration:config];
        pickerViewController.delegate = self;
        [self presentViewController:pickerViewController animated:YES completion:nil];
    } else {
        UIImagePickerController *mediaPicker = [[UIImagePickerController alloc] init];
        mediaPicker.delegate = self;
        mediaPicker.modalPresentationStyle = UIModalPresentationFormSheet;
        mediaPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        mediaPicker.mediaTypes = [[NSArray alloc]initWithObjects:(NSString *)kUTTypeMovie, (NSString *)kUTTypeImage, nil];
        mediaPicker.videoQuality = UIImagePickerControllerQualityTypeHigh;
        [self presentViewController:mediaPicker animated:YES completion:nil];
    }
}

- (void)openFile {
    DDLogVerbose(@"%@ openFile", LOG_TAG);
    
    UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[(__bridge NSString*)(kUTTypeData),(__bridge NSString*)(kUTTypeContent)] inMode:UIDocumentPickerModeImport];
    documentPicker.delegate = self;
    documentPicker.allowsMultipleSelection = YES;
    documentPicker.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:documentPicker animated:YES completion:nil];
}

- (NSInteger)getCurrentIndex {
    DDLogVerbose(@"%@ getCurrentIndex", LOG_TAG);
    
    NSArray *indexPaths = self.filesCollectionView.indexPathsForVisibleItems;
    
    if (indexPaths.count > 0) {
        NSIndexPath *first = [indexPaths firstObject];
        return first.row;
    }
    
    return -1;
}

- (void)removeFile:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ removeFile: %@", LOG_TAG, indexPath);
    
    UICollectionViewCell *cell = [self.filesCollectionView cellForItemAtIndexPath:indexPath];
    if (cell && [cell isKindOfClass:[FullScreenVideoCell class]]) {
        FullScreenVideoCell *fullScreenVideoCell = (FullScreenVideoCell *)cell;
        [fullScreenVideoCell stopVideo];
    }
    
    UIPreviewMedia *previewMedia = [self.files objectAtIndex:indexPath.row];
    [self.files removeObject:previewMedia];
    [self.filesCollectionView deleteItemsAtIndexPaths:@[indexPath]];
    [self.thumbnailCollectionView deleteItemsAtIndexPaths:@[indexPath]];
    
    if (self.currentItemIndex == self.files.count) {
        self.currentItemIndex--;
    }
    
    [self.filesCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.currentItemIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:NO];
    [self.thumbnailCollectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.currentItemIndex inSection:0]]];
}

- (void)loadFileFromPicker {
    DDLogVerbose(@"%@ loadFileFromPicker", LOG_TAG);
     
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.endFilePicking && self.countFilePicking == 0) {
            self.overlayView.hidden = YES;
            if ([self.activityIndicatorView isAnimating]) {
                [self.activityIndicatorView stopAnimating];
            }
            
            if (self.pickMediaError) {
                AlertMessageView *alertMessageView = [[AlertMessageView alloc] init];
                alertMessageView.alertMessageViewDelegate = self;
                alertMessageView.forceDarkMode = YES;
                [alertMessageView initWithTitle:TwinmeLocalizedString(@"delete_account_view_controller_warning", nil) message:TwinmeLocalizedString(@"application_error_media_not_supported", nil)];
                [self.view addSubview:alertMessageView];
                [alertMessageView showAlertView];
            }
            
            NSInteger previousIndex = self.currentItemIndex;
            self.currentItemIndex = self.files.count - 1;
            [self.thumbnailCollectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:previousIndex inSection:0], [NSIndexPath indexPathForRow:self.files.count - 1 inSection:0]]];
            [self.filesCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.files.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:NO];
        } else {
            self.overlayView.hidden = NO;
            if (![self.activityIndicatorView isAnimating]) {
                [self.activityIndicatorView startAnimating];
            }
        }
    });
}

@end

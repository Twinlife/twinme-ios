/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (fabrice.trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Photos/Photos.h>
#import <PhotosUI/PhotosUI.h>

#import <Twinme/TLContact.h>
#import <Twinme/TLGroup.h>

#import "ShareFilesViewController.h"
#import "UIContact.h"
#import "UIPreviewInfo.h"
#import "UIPreviewFile.h"
#import "UIPreviewMedia.h"

#import <TwinmeCommon/ShareService.h>
#import <Utils/NSString+Utils.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: ShareFilesViewController ()
//

@interface ShareFilesViewController () <ShareServiceDelegate>

@property (nonatomic, readonly, nonnull) ShareService *shareService;
@property (nonatomic, nonnull) NSMutableArray *uiSelectedContact;
@property (nonatomic, nonnull) NSMutableArray *filesToSend;
@property (nonatomic, nullable) NSString *comment;
@property (nonatomic) BOOL allowCopyText;
@property (nonatomic) BOOL allowCopyFile;
@property (nonatomic) int64_t timeout;

@end

//
// Implementation: ShareFilesViewController
//

#undef LOG_TAG
#define LOG_TAG @"ShareFilesViewController"

@implementation ShareFilesViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _uiSelectedContact = [[NSMutableArray alloc] init];
        _filesToSend = [[NSMutableArray alloc] init];
        _shareService = [[ShareService alloc] initWithTwinmeContext:self.twinmeContext delegate:self fromExtension:YES];
    }
    return self;
}

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
}

- (void)initWithContacts:(NSArray *)contacts groups:(NSArray *)groups {
    DDLogVerbose(@"%@ initWithContacts: %@ groups: %@", LOG_TAG, contacts, groups);
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *groupURL = [fileManager containerURLForSecurityApplicationGroupIdentifier:[TLTwinlife APP_GROUP_NAME]];
    
    NSURL *directoryURL = [groupURL
            URLByAppendingPathComponent:@"preview"
                            isDirectory:YES];
    NSArray<NSURL *> *files =
        [fileManager contentsOfDirectoryAtURL:directoryURL
                   includingPropertiesForKeys:nil
                                      options:0
                                        error:nil];
    
    
    BOOL hasFiles = NO;
    for (NSURL *file in files) {
        if (![self isImageFile:file.path] && ![self isVideoFile:file.path]) {
            hasFiles = YES;
            break;
        }
    }
    
    self.startWithMedia = !hasFiles;
    [self initWithPreviewFiles:files];
    [self.shareService findContactsAndGroupsById:contacts groupsIds:groups];
}

- (void)send:(BOOL)allowCopyText allowCopyFile:(BOOL)allowCopyFile timeout:(int64_t)timeout {
    DDLogVerbose(@"%@ send: %@ allowCopyFile: %@ timeout: %lld", LOG_TAG, allowCopyText ? @"YES" : @"NO", allowCopyFile ? @"YES" : @"NO", timeout);
    
    self.allowCopyText = allowCopyText;
    self.allowCopyFile = allowCopyFile;
    self.timeout = timeout;
    
    self.overlayView.hidden = NO;
    if (![self.activityIndicatorView isAnimating]) {
        [self.activityIndicatorView startAnimating];
    }
    
    self.stateLabel.text = TwinmeLocalizedString(@"preview_files_view_resize_message", nil);
    
    self.countFilePicking = 0;
    self.endFilePicking = NO;
    
    for (UIPreviewInfo *previewInfo in self.files) {
        self.countFilePicking++;
        if (previewInfo.previewType == PreviewTypeImage || previewInfo.previewType == PreviewTypeVideo) {
            UIPreviewMedia *previewMedia = (UIPreviewMedia *)previewInfo;
   
            if (previewMedia.previewType == PreviewTypeVideo) {
                if (self.isQualityMediaOriginal) {
                    [self.filesToSend addObject:previewMedia.path];
                    self.countFilePicking--;
                    [self isAllMediaResize];
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
                                [self.filesToSend addObject:outputURL.path];
                            } else {
                                [self.filesToSend addObject:previewMedia.path];
                            }
                            self.countFilePicking--;
                            [self isAllMediaResize];
                        });
                    }];
                }
            } else {
                if (self.isQualityMediaOriginal) {
                    [self.filesToSend addObject:previewMedia.path];
                    self.countFilePicking--;
                    [self isAllMediaResize];
                } else {
                    [self resizeImage:previewMedia];
                    [self.filesToSend addObject:previewMedia.path];
                    self.countFilePicking--;
                    [self isAllMediaResize];
                }
            }
        } else {
            UIPreviewFile *previewFile = (UIPreviewFile *)previewInfo;
            [self.filesToSend addObject:previewFile.url.path];
            self.countFilePicking--;
            [self isAllMediaResize];
        }
    }
    
    self.endFilePicking = YES;
    [self isAllMediaResize];
}

- (void)isAllMediaResize{
    DDLogVerbose(@"%@ isAllMediaResize", LOG_TAG);
    
    if (self.endFilePicking && self.countFilePicking == 0) {
        NSString *message = self.messageTextView.text;
        if (![message isEqual:@""] && ![message isEqualToString:TwinmeLocalizedString(@"conversation_view_message", nil)]) {
            self.comment = message;
        }
        
        UIContact *selectedContact = [self.uiSelectedContact objectAtIndex:0];
        [self.uiSelectedContact removeObjectAtIndex:0];
        if (selectedContact.contact.isGroup) {
            [self.shareService getConversationWithGroup:(TLGroup *)selectedContact.contact];
        } else {
            [self.shareService getConversationWithContact:(TLContact *)selectedContact.contact];
        }
    }
}

#pragma mark - ShareServiceDelegate

- (void)onSetCurrentSpace:(nonnull TLSpace *)space {
    DDLogVerbose(@"%@ onSetCurrentSpace: %@", LOG_TAG, space);
    
}

- (void)onGetContacts:(NSArray *)contacts {
    DDLogVerbose(@"%@ onGetContacts: %@", LOG_TAG, contacts);
    
    for (TLContact *contact in contacts) {
        [self updateUIContact:contact avatar:nil];
    }
    
    [self updateViews];
}

- (void)onCreateContact:(TLContact *)contact avatar:(nonnull UIImage *)avatar {
    DDLogVerbose(@"%@ onCreateContact: %@ avatar: %@", LOG_TAG, contact, avatar);

}

- (void)onUpdateContact:(nonnull TLContact *)contact avatar:(nullable UIImage *)avatar {
    DDLogVerbose(@"%@ onUpdateContact: %@ avatar: %@", LOG_TAG, contact, avatar);
    
}

- (void)onDeleteContact:(NSUUID *)contactId {
    DDLogVerbose(@"%@ onDeleteContact: %@", LOG_TAG, contactId);
    
}

- (void)onGetGroups:(NSArray *)groups {
    DDLogVerbose(@"%@ onGetGroups: %@", LOG_TAG, groups);
 
    for (TLGroup *group in groups) {
        [self updateUIGroup:group avatar:nil];
    }
    
    [self updateViews];
}

- (void)onCreateGroup:(TLGroup *)group conversation:(id<TLGroupConversation>)conversation {
    DDLogVerbose(@"%@ onCreateGroup: %@ conversation: %@", LOG_TAG, group, conversation);
    
}

- (void)onUpdateGroup:(nonnull TLGroup *)group avatar:(nullable UIImage *)avatar {
    DDLogVerbose(@"%@ onUpdateGroup: %@ avatar: %@", LOG_TAG, group, avatar);
    
}

- (void)onDeleteGroup:(NSUUID *)groupId {
    DDLogVerbose(@"%@ onDeleteGroup: %@", LOG_TAG, groupId);
    
}

- (void)onGetConversation:(id<TLConversation>)conversation {
    DDLogVerbose(@"%@ onGetConversation: %@", LOG_TAG, conversation);
    
    BOOL toBeDeleted = self.uiSelectedContact.count == 0;
    for (NSString *filePath in self.filesToSend) {
        if ([self isImageFile:filePath]) {
            [self.shareService pushFileWithPath:filePath type:TLDescriptorTypeImageDescriptor toBeDeleted:toBeDeleted copyAllowed:self.allowCopyFile timeout:self.timeout];
        } else if ([self isVideoFile:filePath]) {
            [self.shareService pushFileWithPath:filePath type:TLDescriptorTypeVideoDescriptor toBeDeleted:toBeDeleted copyAllowed:self.allowCopyFile timeout:self.timeout];
        } else if ([self isAudioFile:filePath]) {
            [self.shareService pushFileWithPath:filePath type:TLDescriptorTypeAudioDescriptor toBeDeleted:toBeDeleted copyAllowed:self.allowCopyFile timeout:self.timeout];
        } else {
            [self.shareService pushFileWithPath:filePath type:TLDescriptorTypeNamedFileDescriptor toBeDeleted:toBeDeleted copyAllowed:self.allowCopyFile timeout:self.timeout];
        }
    }
    
    if (self.comment && ![self.comment isEqualToString:@""]) {
        [self.shareService pushMessage:self.comment copyAllowed:self.allowCopyText timeout:self.timeout];
    }

    if (self.uiSelectedContact.count == 0) {
        [self finish];
    } else {
        UIContact *selectedContact = [self.uiSelectedContact objectAtIndex:0];
        [self.uiSelectedContact removeObjectAtIndex:0];

        if (selectedContact.contact.isGroup) {
            [self.shareService getConversationWithGroup:(TLGroup *)selectedContact.contact];
        } else {
            [self.shareService getConversationWithContact:(TLContact *)selectedContact.contact];
        }
    }
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
 
    [super initViews];
    
    self.nameLabel.text = @"";
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    self.overlayView.hidden = YES;
    if ([self.activityIndicatorView isAnimating]) {
        [self.activityIndicatorView stopAnimating];
    }
    
    [self.shareService dispose];
    [super finish];
}

- (void)updateUIContact:(TLContact *)contact avatar:(nullable UIImage *)avatar {
    DDLogVerbose(@"%@ updateUIContact: %@ avatar: %@", LOG_TAG, contact, avatar);
    
    UIContact *uiContact = nil;
    for (UIContact *lUIContact in self.uiSelectedContact) {
        if ([lUIContact.contact.uuid isEqual:contact.uuid]) {
            uiContact = lUIContact;
            break;
        }
    }
    
    if (uiContact)  {
        [self.uiSelectedContact removeObject:uiContact];
        [uiContact setContact:contact];
    } else {
        uiContact = [[UIContact alloc] initWithContact:contact];
    }
    if (!avatar && [contact hasPeer]) {
        [self.shareService getImageWithContact:contact withBlock:^(UIImage *image) {
            [uiContact updateAvatar:image];
        }];
    } else {
        [uiContact updateAvatar:avatar];
    }
    
    BOOL added = NO;
    NSInteger count = self.uiSelectedContact.count;
    for (NSInteger i = 0; i < count; i++) {
        UIContact *lUIContact = self.uiSelectedContact[i];
        if ([lUIContact.name caseInsensitiveCompare:uiContact.name] == NSOrderedDescending) {
            [self.uiSelectedContact insertObject:uiContact atIndex:i];
            added = YES;
            break;
        }
    }
    if (!added) {
        [self.uiSelectedContact addObject:uiContact];
    }
}

- (void)updateUIGroup:(TLGroup *)group avatar:(nullable UIImage *)avatar {
    DDLogVerbose(@"%@ updateUIGroup: %@ avatar: %@", LOG_TAG, group, avatar);
    
    UIContact *uiContact = nil;
    for (UIContact *lUIContact in self.uiSelectedContact) {
        if ([lUIContact.contact.uuid isEqual:group.uuid]) {
            uiContact = lUIContact;
            break;
        }
    }
    
    if (uiContact)  {
        [self.uiSelectedContact removeObject:uiContact];
        [uiContact setContact:group];
    } else {
        uiContact = [[UIContact alloc] initWithContact:group];
    }
    if (!avatar) {
        [self.shareService getImageWithGroup:group withBlock:^(UIImage *image) {
            [uiContact updateAvatar:image];
        }];
    } else {
        [uiContact updateAvatar:avatar];
    }
    
    BOOL added = NO;
    NSInteger count = self.uiSelectedContact.count;
    for (NSInteger i = 0; i < count; i++) {
        UIContact *lUIContact = self.uiSelectedContact[i];
        if ([lUIContact.name caseInsensitiveCompare:uiContact.name] == NSOrderedDescending) {
            [self.uiSelectedContact insertObject:uiContact atIndex:i];
            added = YES;
            break;
        }
    }
    if (!added) {
        [self.uiSelectedContact addObject:uiContact];
    }
}

- (void)updateViews {
    DDLogVerbose(@"%@ updateViews", LOG_TAG);
    
    if (self.uiSelectedContact.count > 1) {
        NSString *name = @"";
        for (UIContact *uiContact in self.uiSelectedContact) {
            if (name.length > 0) {
                name = [name stringByAppendingString:@", "];
            }
            name = [name stringByAppendingString:uiContact.name];
        }
        self.certifiedImageView.hidden =  YES;
        self.avatarView.image = [[UIImage imageNamed:@"GroupsIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.avatarView.tintColor = [UIColor whiteColor];
        self.nameLabel.text = name;
    } else if(self.uiSelectedContact.count == 1) {
        UIContact *uiContact = [self.uiSelectedContact firstObject];
        self.nameLabel.text = uiContact.name;
        self.avatarView.image = uiContact.avatar;
        self.certifiedImageView.hidden = !uiContact.isCertified;
    }
}

- (BOOL)isImageFile:(NSString *)file {
    DDLogVerbose(@"%@ isImageFile: %@", LOG_TAG, file);
    
    UTType *fileType = [UTType typeWithFilenameExtension:[file pathExtension]];
    return [fileType conformsToType:UTTypeImage];
}

- (BOOL)isVideoFile:(NSString *)file {
    DDLogVerbose(@"%@ isVideoFile: %@", LOG_TAG, file);
    
    UTType *fileType = [UTType typeWithFilenameExtension:[file pathExtension]];
    return [fileType conformsToType:UTTypeMovie];
}

- (BOOL)isAudioFile:(NSString *)file {
    DDLogVerbose(@"%@ isAudioFile: %@", LOG_TAG, file);
    
    UTType *fileType = [UTType typeWithFilenameExtension:[file pathExtension]];
    return [fileType conformsToType:UTTypeAudio];
}

@end

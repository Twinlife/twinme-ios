/*
 *  Copyright (c) 2015-2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Chedi Baccari (Chedi.Baccari@twinlife-systems.com)
 *   Christian Jacquemot (Christian.Jacquemot@twinlife-systems.com)
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 *   Stephane Carrez (Stephane.Carrez@twin.life)
 */

#import <SLKTextViewController.h>

#import <Twinlife/TLConversationService.h>

static CGFloat DESIGN_IMAGE_VIEW_WIDTH = 360;
static CGFloat DESIGN_IMAGE_VIEW_HEIGHT = 420;
static CGFloat DESIGN_LIBRARY_VIEW_WIDTH = 150;
static CGFloat DESIGN_ADD_FILE_VIEW_WIDTH = 124;
static CGFloat DESIGN_PREVIEW_FILE_WIDTH = 290;
static CGFloat DESIGN_DELETE_ANIMATION_DURATION = 5; // s

static int64_t MINIMAL_RESOLUTION = 640;
static int64_t STANDARD_RESOLUTION = 1600;
static CGFloat MAX_COMPRESSION = 0.8f;

@protocol AsyncLoader;

//
// Protocol: DeleteActionDelegate
//

@class Item;

@protocol DeleteActionDelegate <NSObject>

- (void)deleteItem:(Item *)item;

@end

//
// Protocol: ImageActionDelegate
//

@class TLImageDescriptor;

@protocol ImageActionDelegate <NSObject>

- (void)fullscreenImageWithImageDescriptor:(TLImageDescriptor *)imageDescriptor thumbnail:(UIImage *)thumbnail isPeerItem:(BOOL)isPeerItem;

@end

//
// Protocol: VideoActionDelegate
//

@class TLVideoDescriptor;

@protocol VideoActionDelegate <NSObject>

- (void)fullscreenVideoWithVideoDescriptor:(TLVideoDescriptor *)videoDescriptor;

@end

//
// Protocol: AudioActionDelegate
//

@class TLAudioDescriptor;

@protocol AudioActionDelegate <NSObject>

- (void)readAudioDescriptor:(TLAudioDescriptor *)audioDescriptor;

@end

//
// Protocol: FileActionDelegate
//

@class TLFileDescriptor;

@protocol FileActionDelegate <NSObject>

- (void)openFileWithNamedFileDescriptor:(TLNamedFileDescriptor *)fileDescriptor;

- (void)openFileWithNamedFileDescriptorNotFound;

@end

//
// Protocol: GroupActionDelegate
//

@class TLInvitationDescriptor;

@protocol GroupActionDelegate <NSObject>

- (void)openGroupWithInvitationDescriptor:(TLInvitationDescriptor *)invitationDescriptor;

@end

//
// Protocol: LocationActionDelegate
//

@class TLGeolocationDescriptor;

@protocol LocationActionDelegate <NSObject>

- (void)fullscreenMapWithGeolocationDescriptor:(TLGeolocationDescriptor *)locationDescriptor avatar:(UIImage *)avatar;

- (void)saveMapWithPath:(NSString *)path geolocationDescriptor:(TLGeolocationDescriptor *)geolocationDescriptor;

@end


//
// Protocol: CallActionDelegate
//

@class TLCallDescriptor;

@protocol CallActionDelegate <NSObject>

- (void)recallWithCallDescriptor:(TLCallDescriptor *)callDescriptor;

@end

//
// Protocol: TwincodeActionDelegate
//

@class TLTwincodeDescriptor;

@protocol TwincodeActionDelegate <NSObject>

- (void)openTwincodeDescriptor:(TLTwincodeDescriptor *)twincodeDescriptor;

@end

//
// Protocol: LinkActionDelegate
//

@protocol LinkActionDelegate <NSObject>

- (void)openLinkWithURL:(NSURL *)url;

@end

//
// Protocol: MenuActionDelegate
//

@class Item;

@protocol MenuActionDelegate <NSObject>

- (void)openMenu:(Item *)item;

- (void)closeMenu;

@end

//
// Protocol: ReplyViewDelegate
//

@protocol ReplyViewDelegate <NSObject>

- (void)closeReplyView;

@end

//
// Protocol: SelectItemDelegate
//

@protocol SelectItemDelegate <NSObject>

- (void)didSelectItem:(Item *)item;

@end

//
// Protocol: MenuItemDelegate
//

@protocol MenuItemDelegate <NSObject>

- (void)copyItemClick;

- (void)editItemClick;

- (void)deleteItemClick;

- (void)infoItemClick;

- (void)forwardItemClick;

- (void)replyItemClick;

- (void)saveItemClick;

- (void)shareItemClick;

- (void)selectMoreItemClick;

@end

//
// Protocol: AudioTrackViewDelegate
//

@protocol AudioTrackViewDelegate <NSObject>

- (void)audioTrackViewTouchEnd:(float)progress;

@end

//
// Protocol: ReactionViewDelegate
//

@protocol ReactionViewDelegate <NSObject>

- (void)openAnnotationViewWithDescriptorId:(TLDescriptorId *)descriptord;

@end

//
// Protocol:PreviewViewDelegate
//

@class CLLocation;

@protocol PreviewViewDelegate <NSObject>

- (void)sendFile:(NSString *)filePath allowCopyFile:(BOOL)allowCopyFile expireTimeout:(int64_t)timeout;

- (void)sendImage:(NSString *)imagePath allowCopyFile:(BOOL)allowCopyFile expireTimeout:(int64_t)timeout;

- (void)sendVideo:(NSString *)videoPath allowCopyFile:(BOOL)allowCopyFile expireTimeout:(int64_t)timeout;

- (void)sendMediaCaption:(NSString *)text allowCopyText:(BOOL)allowCopyText expireTimeout:(int64_t)timeout;

- (void)sendLocation:(double)latitudeDelta longitudeDelta:(double)longitudeDelta location:(CLLocation *)userLocation text:(NSString *)text allowCopyText:(BOOL)allowCopyText allowCopyFile:(BOOL)allowCopyFile expireTimeout:(int64_t)timeout;

@end

//
// Interface: ConversationViewController
//

@class CustomAppearance;
@class TLSpace;

@protocol TLOriginator;

@interface ConversationViewController : SLKTextViewController

@property (nonatomic) TLSpace *space;

- (void)initWithContact:(id<TLOriginator>)contact;

- (void)scrollToDescriptor:(TLDescriptorId *)descriptorId;

- (CGFloat)getTopMarginWithMask:(int)mask item:(Item *)item;

- (CGFloat)getBottomMarginWithMask:(int)mask item:(Item *)item;

- (CGFloat)getRadiusWithMask:(int)mask;

- (UIImage *)getContactAvatarWithUUID:(NSUUID *)peerTwincodeOutboundId;

- (UIImage *)getContactAvatarForMap:(NSUUID *)peerTwincodeOutboundId;

- (BOOL)isSameDayWithDate1:(NSDate *)date1 date2:(NSDate *)date2;

- (void)pushFileWithPath:(NSString *)path type:(TLDescriptorType)type toBeDeleted:(BOOL)toBeDeleted allowCopy:(BOOL)allowCopy expireTimeout:(int64_t)timeout;

- (Item *)getSelectedItem;

- (BOOL)isMenuOpen;

- (BOOL)isSelectItemMode;

- (UIFont *)getMessageFont;

- (id<TLOriginator>)getOriginator;

- (void)updateInCall;

- (BOOL)isViewAppearing;

- (CustomAppearance *)getCustomAppearance;

- (void)openMenuSendOptions;

- (void)resetVoiceRecorder;

@end

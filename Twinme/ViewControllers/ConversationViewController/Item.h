/*
 *  Copyright (c) 2017-2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Christian Jacquemot (Christian.Jacquemot@twinlife-systems.com)
 *   Chedi Baccari (Chedi.Baccari@twinlife-systems.com)
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 *   Stephane Carrez (Stephane.Carrez@twin.life)
 */

static const int ITEM_TOP_LEFT = 1 << 0;
static const int ITEM_TOP_RIGHT = 1 << 1;
static const int ITEM_BOTTOM_RIGHT = 1 << 2;
static const int ITEM_BOTTOM_LEFT = 1 << 3;

static const int ITEM_DEFAULT_SEQUENCE_ID = -1;

//
// Interface: Item
//

typedef enum {
    ItemTypeInfoPrivacy,
    ItemTypeTime,
    ItemTypeMessage,
    ItemTypePeerMessage,
    ItemTypeLink,
    ItemTypePeerLink,
    ItemTypeImage,
    ItemTypePeerImage,
    ItemTypeAudio,
    ItemTypePeerAudio,
    ItemTypeVideo,
    ItemTypePeerVideo,
    ItemTypeFile,
    ItemTypePeerFile,
    ItemTypeInvitation,
    ItemTypePeerInvitation,
    ItemTypeLocation,
    ItemTypePeerLocation,
    ItemTypeName,
    ItemTypeCall,
    ItemTypePeerCall,
    ItemTypeInvitationContact,
    ItemTypePeerInvitationContact,
    ItemTypeClear,
    ItemTypePeerClear
} ItemType;

typedef enum {
    ItemStateDefault,
    ItemStateSending,
    ItemStateReceived,
    ItemStateRead,
    ItemStateNotSent,
    ItemStateDeleted,
    ItemStatePeerDeleted,
    ItemStateBothDeleted
} ItemState;

typedef enum {
    ItemModeNormal,
    ItemModePreview,
    ItemModeSmallPreview
} ItemMode;

@class TLDescriptor;
@class TLDescriptorId;
@class TLDescriptorAnnotation;
@class ConversationViewController;

@interface Item : NSObject

@property (readonly) ItemType type;
@property (readonly, nonnull) TLDescriptorId *descriptorId;
@property int64_t createdTimestamp;
@property int64_t updatedTimestamp;
@property int64_t sentTimestamp;
@property int64_t receivedTimestamp;
@property int64_t readTimestamp;
@property int64_t deletedTimestamp;
@property int64_t peerDeletedTimestamp;
@property int64_t expireTimeout;
@property int corners;
@property ItemState state;
@property BOOL visibleAvatar;
@property BOOL copyAllowed;
@property BOOL forwarded;
@property ItemMode mode;
@property BOOL replyAllowed;
@property (nullable) TLDescriptorId *replyTo;
@property (nullable) TLDescriptor *replyToDescriptor;
@property (nullable) NSArray<TLDescriptorAnnotation *> *likeDescriptorAnnotations;
@property BOOL selected;

- (nonnull instancetype)initWithType:(ItemType)type descriptor:(nonnull TLDescriptor *)descriptor;

- (nonnull instancetype)initWithType:(ItemType)type descriptor:(nonnull TLDescriptor *)descriptor replyToDescriptor:(nullable TLDescriptor *)replyToDescriptor;

- (nonnull instancetype)initWithType:(ItemType)type descriptorId:(nonnull TLDescriptorId *)descriptorId timestamp:(int64_t)timestamp;

- (BOOL)isPeerItem;

- (BOOL)isDeletedItem;

- (BOOL)isAvailableItem;

- (BOOL)isFileItemExist;

- (BOOL)isEditedtem;

- (BOOL)needsUpdateReadTimestamp;

- (BOOL)isEphemeralItem;

- (BOOL)isClearLocalItem;

- (nullable NSUUID *)peerTwincodeOutboundId;

- (BOOL)isSamePeer:(nonnull Item *)item;

- (int64_t)timestamp;

- (void)resetState;

- (void)updateState;

- (void)updateTimestampsWithDescriptor:(nonnull TLDescriptor *)descriptor;

- (BOOL)hasLikeAnnotationWithValue:(int)value;

- (void)updateAnnotationsWithDescriptor:(nonnull TLDescriptor *)descriptor;

- (nullable NSURL *)getURL;

- (nullable NSString *)getExtension;

- (int64_t)getLength;

- (int64_t)getDuration;

- (int)getHeight;

- (int)getWidth;

- (nullable NSString *)getInformation;

- (CGFloat)deleteProgress;

- (void)startDeleteItem;

- (NSComparisonResult)compareWithItem:(nonnull Item *)second;

- (void)appendTo:(nonnull NSMutableString *)string;

@end

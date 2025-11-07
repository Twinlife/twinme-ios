/*
 *  Copyright (c) 2018-2022 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 *   Stephane Carrez (Stephane.Carrez@twin.life)
 */

#import <TwinmeCommon/AbstractTwinmeViewController.h>
#import <Twinlife/TLConversationService.h>

//
// Protocol: AddCommentDelegate
//

@protocol AddCommentDelegate <NSObject>

- (void)commentDidChange:(nullable NSString *)comment;

@end

//
// Interface: ShareViewController
//

@class Item;
@class ConversationViewController;

@interface ShareViewController : AbstractTwinmeViewController

@property (nonatomic, nullable) NSURL *fileURL;
@property (nonatomic, nullable) NSString *content;
@property (nonatomic, nullable) TLDescriptorId *descriptorId;
@property (nonatomic) TLDescriptorType descriptorType;

@property (weak, nonatomic, nullable) ConversationViewController *conversationViewController;
@property (weak, nonatomic, nullable) Item *item;

@end

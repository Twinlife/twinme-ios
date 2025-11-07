/*
 *  Copyright (c) 2022 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "Item.h"

//
// Interface: LinkItem
//

@class TLObjectDescriptor;

@interface LinkItem : Item

@property NSString *content;
@property NSURL *url;
@property TLObjectDescriptor *objectDescriptor;

- (instancetype)initWithObjectDescriptor:(TLObjectDescriptor *)objectDescriptor replyToDescriptor:(TLDescriptor *)replyToDescriptor url:(NSURL *)url;

@end

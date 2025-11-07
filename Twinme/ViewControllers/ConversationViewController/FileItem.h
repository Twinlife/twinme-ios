/*
 *  Copyright (c) 2018-2021 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "Item.h"

@class TLNamedFileDescriptor;

@interface FileItem : Item

@property TLNamedFileDescriptor *namedFileDescriptor;

- (instancetype)initWithNamedFileDescriptor:(TLNamedFileDescriptor *)namedFileDescriptor replyToDescriptor:(TLDescriptor *)replyToDescriptor;

@end

/*
 *  Copyright (c) 2022 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

@class TLCallDescriptor;
@class UIContact;

//
// Interface: UICall
//

@interface UICall : NSObject

@property (nonatomic, nonnull) NSArray<TLCallDescriptor *> *callDescriptors;
@property (nonatomic, nonnull) UIContact *uiContact;
           
- (nonnull instancetype)initWithCall:(nonnull NSArray<TLCallDescriptor *> *)callDescriptors uiContact:(nonnull UIContact *)uiContact;

- (nonnull TLCallDescriptor *)getLastCallDescriptor;

- (NSUInteger)getCount;

@end

/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "UIConfigExternalCall.h"

//
// Interface: UIConfigExternalCall
//

@interface UIConfigExternalCallItem : NSObject

@property (nonatomic) ConfigExternalCallSettings configExternalCallSettings;

- (nonnull instancetype)initWithConfigExternalCallSettings:(ConfigExternalCallSettings)configExternalCallSettings;

- (nonnull NSString *)getTitle;

@end

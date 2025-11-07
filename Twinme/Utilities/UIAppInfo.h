/*
 *  Copyright (c) 2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum {
    InfoFloatingViewTypeConnected,
    InfoFloatingViewTypeConnectionInProgress,
    InfoFloatingViewTypeNoServices,
    InfoFloatingViewTypeOffline
} InfoFloatingViewType;

//
// Interface: UIAppInfo
//

@interface UIAppInfo : NSObject

@property (nonatomic) InfoFloatingViewType infoFloatingViewType;

- (nonnull instancetype)initWithInfoType:(InfoFloatingViewType)infoFloatingViewType;

- (nonnull NSString *)getAppInfoTitle;

- (nonnull NSString *)getAppInfoMessage;

- (nonnull UIImage *)getAppInfoImage;

- (nullable UIColor *)getAppInfoColor;

@end

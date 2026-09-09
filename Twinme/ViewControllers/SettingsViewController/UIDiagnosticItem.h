/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

typedef enum {
    DiagnosticItemTypeConnection,
    DiagnosticItemTypePermissionMicro,
    DiagnosticItemTypePermissionCamera,
    DiagnosticItemTypePermissionNotification,
    DiagnosticItemTypePush
} DiagnosticItemType;

typedef enum {
    DiagnosticItemStateOK,
    DiagnosticItemStateKO,
    DiagnosticItemStateUnknown
} DiagnosticItemState;

//
// Interface: UIDiagnosticItem
//


@interface UIDiagnosticItem : NSObject

@property (nonatomic) DiagnosticItemType diagnosticItemType;
@property (nonatomic) DiagnosticItemState diagnosticItemState;
@property (nonatomic, nonnull) NSString *title;
@property (nonatomic, nullable) NSString *subTitle;
@property (nonatomic, nullable) UIImage *icon;

- (nonnull instancetype)initWithType:(DiagnosticItemType)diagnosticItemType;

@end

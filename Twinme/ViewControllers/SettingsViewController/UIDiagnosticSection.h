/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

typedef enum {
    DiagnosticSectionTypeConnection,
    DiagnosticSectionTypePermission,
    DiagnosticSectionTypePush
} UIDiagnosticSectionType;

//
// Interface: UIDiagnosticItem
//

@class UIDiagnosticItem;

@interface UIDiagnosticSection : NSObject

@property (nonatomic) UIDiagnosticSectionType sectionType;
@property (nonatomic, nonnull) NSString *title;
@property (nonatomic, nonnull) NSMutableArray<UIDiagnosticItem *> *items;

- (nonnull instancetype)initWithType:(UIDiagnosticSectionType)sectionType;

@end

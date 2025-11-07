/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <TwinmeCommon/AbstractTwinmeViewController.h>

@class TLContact;
@class TLGroup;
@class TLSpace;

//
// Interface: ExportViewController
//

@interface ExportViewController : AbstractTwinmeViewController

- (void)initExportWithContact:(TLContact *)contact;

- (void)initExportWithGroup:(TLGroup *)group;

- (void)initExportWithSpace:(TLSpace *)space;

- (void)initExportWithCurrentSpace;

@end

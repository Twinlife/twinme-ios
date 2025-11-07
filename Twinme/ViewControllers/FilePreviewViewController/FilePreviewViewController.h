/*
 *  Copyright (c) 2018 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <QuickLook/QuickLook.h>

//
// Interface: FilePreviewViewController
//

@class TLNamedFileDescriptor;

@interface FilePreviewViewController : QLPreviewController

@property (weak, nonatomic) TLNamedFileDescriptor *namedFileDescriptor;

@end

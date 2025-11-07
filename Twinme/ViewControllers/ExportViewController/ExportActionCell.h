/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

typedef enum {
    ExportActionTypeCancel,
    ExportActionTypeExport,
    ExportActionTypeCleanup
} ExportActionType;

//
// Protocol: ExportActionDelegate
//

@protocol ExportActionDelegate <NSObject>

- (void)didTapAction:(ExportActionType)exportActionType;

@end

//
// Interface: ExportActionCell
//

@interface ExportActionCell : UITableViewCell

@property (weak, nonatomic) id<ExportActionDelegate> exportActionDelegate;

- (void)bindWithAction:(ExportActionType)exportActionType enable:(BOOL)enable;

@end

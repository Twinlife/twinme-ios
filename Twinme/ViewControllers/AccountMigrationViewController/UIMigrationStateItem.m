/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "UIMigrationStateItem.h"

#import <UIKit/UIKit.h>

#import <Utils/NSString+Utils.h>
#import <TwinmeCommon/Design.h>

static const CGFloat DESIGN_TRANSFER_INFO_LINE_SPACING = 6.f;

//
// Interface: UIMigrationStateItem ()
//

@interface UIMigrationStateItem ()

@property (nonatomic) MigrationStateItemType migrationStateItemType;
@property (nonatomic) MigrationStateItemState migrationStateItemState;
@property (nonatomic, nonnull) NSString *title;
@property (nonatomic, nullable) NSString *subTitle;
@property (nonatomic, nullable) NSAttributedString *attributedSubTitle;

@end

//
// Implementation: UIMigrationStateItem
//

@implementation UIMigrationStateItem

- (nonnull instancetype)initWithType:(MigrationStateItemType)type {
    self = [super init];
    
    if (self) {
        _migrationStateItemType = type;
        _migrationStateItemState = MigrationStateItemStatePending;
        [self initTitle];
    }
    
    return self;
}

- (MigrationStateItemType)getType {
    
    return self.migrationStateItemType;
}

- (nonnull NSString *)getTitle {
 
    return self.title;
}

- (nullable NSString *)getInfo {
 
    return self.subTitle;
}

- (nullable NSAttributedString *)getAttributedInfo {
 
    return self.attributedSubTitle;
}

- (MigrationStateItemState)getState {
    
    return self.migrationStateItemState;
}

- (void)update:(TLAccountMigrationState)state status:(nullable TLAccountMigrationStatus *)status {
    
    switch (self.migrationStateItemType) {
        case MigrationStateItemTypeHeader:
            [self updateHeader:state status:status];
            break;
            
        case MigrationStateItemTypeInit:
            if (state == TLAccountMigrationStateStarting) {
                self.migrationStateItemState = MigrationStateItemStateInProgress;
            } else if (state == TLAccountMigrationStateNone) {
                self.migrationStateItemState = MigrationStateItemStatePending;
            } else if (state < TLAccountMigrationStateTerminated) {
                self.migrationStateItemState = MigrationStateItemStateDone;
            }
                
            break;
            
        case MigrationStateItemTypeTransfer:
            if (state == TLAccountMigrationStateNegociate) {
                self.migrationStateItemState = MigrationStateItemStateInProgress;
            } else if (state < TLAccountMigrationStateNegociate) {
                self.migrationStateItemState = MigrationStateItemStatePending;
            } else if (state >= TLAccountMigrationStateListFiles) {
                [self updateTransferInfo:status];
            }
            break;
            
        case MigrationStateItemTypeSettings:
            if (state == TLAccountMigrationStateSendSettings) {
                self.migrationStateItemState = MigrationStateItemStateInProgress;
            } else if (state < TLAccountMigrationStateSendSettings) {
                self.migrationStateItemState = MigrationStateItemStatePending;
            } else if (state < TLAccountMigrationStateTerminated) {
                self.migrationStateItemState = MigrationStateItemStateDone;
            }
            [self updateInfo];
            break;
            
        case MigrationStateItemTypeDatabase:
            if (state == TLAccountMigrationStateSendDatabase) {
                self.migrationStateItemState = MigrationStateItemStateInProgress;
            } else if (state < TLAccountMigrationStateSendDatabase) {
                self.migrationStateItemState = MigrationStateItemStatePending;
            } else if (state < TLAccountMigrationStateTerminated) {
                self.migrationStateItemState = MigrationStateItemStateDone;
            }
            [self updateInfo];
            break;
            
        case MigrationStateItemTypeAcocunt:
            if (state == TLAccountMigrationStateSendAccount) {
                self.migrationStateItemState = MigrationStateItemStateInProgress;
            } else if (state < TLAccountMigrationStateSendAccount) {
                self.migrationStateItemState = MigrationStateItemStatePending;
            } else if (state < TLAccountMigrationStateTerminated) {
                self.migrationStateItemState = MigrationStateItemStateDone;
            }
            [self updateInfo];
            break;
            
        case MigrationStateItemTypeTerminated:
            if (state == TLAccountMigrationStateCheckDatabase) {
                self.migrationStateItemState = MigrationStateItemStateInProgress;
            } else if (state < TLAccountMigrationStateCheckDatabase) {
                self.migrationStateItemState = MigrationStateItemStatePending;
            } else if (state == TLAccountMigrationStateTerminated) {
                self.migrationStateItemState = MigrationStateItemStateDone;
            }
            break;
            
        default:
            break;
    }
}


#pragma mark - Private

- (void)initTitle {
    
    switch (self.migrationStateItemType) {
        case MigrationStateItemTypeHeader:
            self.title = TwinmeLocalizedString(@"account_migration_view_ready_to_start", nil);
            break;
            
        case MigrationStateItemTypeInit:
            self.title = TwinmeLocalizedString(@"account_migration_view_initializing", nil);
            break;
            
        case MigrationStateItemTypeTransfer:
            self.title = TwinmeLocalizedString(@"export_view_files", nil).capitalizedString;
            break;
            
        case MigrationStateItemTypeSettings:
            self.title = TwinmeLocalizedString(@"navigation_view_settings", nil);
            break;
            
        case MigrationStateItemTypeDatabase:
            self.title = TwinmeLocalizedString(@"account_migration_view_database", nil);
            break;
            
        case MigrationStateItemTypeAcocunt:
            self.title = TwinmeLocalizedString(@"account_view_title", nil);
            break;
            
        case MigrationStateItemTypeTerminated:
            self.title = TwinmeLocalizedString(@"account_migration_view_finalizing", nil);
            break;
            
        default:
            break;
    }
}

- (void)updateHeader:(TLAccountMigrationState)state status:(nullable TLAccountMigrationStatus *)status  {
        
    if (!status) {
        return;
    }
    
    if (!status.isConnected) {
        self.subTitle = TwinmeLocalizedString(@"account_migration_view_state_wait_connect", nil);
    } else if (state == TLAccountMigrationStateStarting) {
        self.subTitle = TwinmeLocalizedString(@"account_migration_view_network_message", nil);
    } else if (state != TLAccountMigrationStateStopped && state != TLAccountMigrationStateTerminated && state != TLAccountMigrationStateCanceled && state != TLAccountMigrationStateError) {
        self.subTitle = @"";
    }
    
    if (state == TLAccountMigrationStateNone || state == TLAccountMigrationStateCanceled || state == TLAccountMigrationStateTerminated) {
        if (state == TLAccountMigrationStateCanceled) {
            self.title = TwinmeLocalizedString(@"account_migration_view_state_canceled", nil);
            self.subTitle = TwinmeLocalizedString(@"account_migration_view_cancel_message", nil);;
        } else {
            self.title = TwinmeLocalizedString(@"account_migration_view_success_message", nil);
            self.subTitle = TwinmeLocalizedString(@"account_migration_view_close_message", nil);
        }
    } else if (state == TLAccountMigrationStateError) {
        if (status.errorCode == TLAccountMigrationErrorCodeNoSpaceLeft) {
            self.title = TwinmeLocalizedString(@"account_migration_view_not_enough_space_for_files", nil);
            self.subTitle = TwinmeLocalizedString(@"application_migration_no_storage_space_message", nil);
        } else {
            self.title = TwinmeLocalizedString(@"account_migration_view_state_canceled", nil);
            self.subTitle = [NSString stringWithFormat:@"%@ \n %ld", TwinmeLocalizedString(@"cleanup_view_error", nil), (long)status.errorCode];
        }
    } else if (state == TLAccountMigrationStateStopped) {
        self.title = TwinmeLocalizedString(@"account_migration_view_success_message", nil);
        self.subTitle = TwinmeLocalizedString(@"account_migration_view_close_message", nil);
    } else {
        CGFloat progressPercent = status.progress;
        if (progressPercent >= 0 && progressPercent <= 100) {
            self.title = [NSString stringWithFormat:@"%d %%", (int)progressPercent];
        } else if (progressPercent <= 0) {
            self.title = TwinmeLocalizedString(@"0%", nil);
        } else {
            self.title = TwinmeLocalizedString(@"100%", nil);
        }
    }
}

- (void)updateInfo {
    
    self.attributedSubTitle = nil;
    
    if (self.migrationStateItemState == MigrationStateItemStateDone) {
        self.subTitle = TwinmeLocalizedString(@"account_migration_view_transfer_complete", nil);
    } else if (self.migrationStateItemState == MigrationStateItemStateInProgress) {
        self.subTitle = TwinmeLocalizedString(@"account_migration_view_transfer", nil);
    }
}

- (void)updateTransferInfo:(nullable TLAccountMigrationStatus *)status {
    
    if (!status) {
        return;
    }
    
    long sent = status.bytesSent;
    long sentRemain = status.estimatedBytesRemainSend;
    long received = status.bytesReceived;
    long receivedRemain = status.estimatedBytesRemainReceive;
    
    NSByteCountFormatter *byteCountFormatter = [[NSByteCountFormatter alloc] init];
    byteCountFormatter.countStyle = NSByteCountFormatterCountStyleFile;
    
    NSString *sentInfo = [NSString stringWithFormat:@"%@ / %@",
                          [byteCountFormatter stringFromByteCount:sent],
                          [byteCountFormatter stringFromByteCount:sent + sentRemain]];
    
    NSString *receivedInfo = [NSString stringWithFormat:@"%@ / %@",
                              [byteCountFormatter stringFromByteCount:received],
                              [byteCountFormatter stringFromByteCount:received + receivedRemain]];
    
    self.subTitle = [NSString stringWithFormat:@"%@\n%@", sentInfo, receivedInfo];
    self.attributedSubTitle = [self attributedTransferInfoWithSentInfo:sentInfo receivedInfo:receivedInfo];
    
    if (receivedRemain == 0 && sentRemain == 0) {
        self.migrationStateItemState = MigrationStateItemStateDone;
    } else {
        self.migrationStateItemState = MigrationStateItemStateInProgress;
    }
}

- (NSAttributedString *)attributedTransferInfoWithSentInfo:(NSString *)sentInfo receivedInfo:(NSString *)receivedInfo {
    
    NSMutableAttributedString *attributedTransferInfo = [[NSMutableAttributedString alloc] initWithString:@""];
    [attributedTransferInfo appendAttributedString:[self attributedTransferInfoWithIcon:@"MigrationSendIcon" info:sentInfo]];
    [attributedTransferInfo appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
    [attributedTransferInfo appendAttributedString:[self attributedTransferInfoWithIcon:@"MigrationReceiveIcon" info:receivedInfo]];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = roundf(DESIGN_TRANSFER_INFO_LINE_SPACING * Design.HEIGHT_RATIO);
    [attributedTransferInfo addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attributedTransferInfo.length)];
    
    return attributedTransferInfo;
}

- (NSAttributedString *)attributedTransferInfoWithIcon:(NSString *)iconName info:(NSString *)info {
    
    NSMutableAttributedString *attributedInfo = [[NSMutableAttributedString alloc] initWithString:@""];
    UIImage *icon = [UIImage imageNamed:iconName];
    
    if (icon) {
        NSTextAttachment *iconAttachment = [[NSTextAttachment alloc] init];
        iconAttachment.image = icon;
        CGFloat iconSize = Design.FONT_REGULAR32.lineHeight;
        iconAttachment.bounds = CGRectMake(0.f, (Design.FONT_REGULAR32.capHeight - iconSize) * 0.5f, iconSize, iconSize);
        [attributedInfo appendAttributedString:[NSAttributedString attributedStringWithAttachment:iconAttachment]];
        [attributedInfo appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
    }
    
    [attributedInfo appendAttributedString:[[NSAttributedString alloc] initWithString:info]];
    
    return attributedInfo;
}

@end

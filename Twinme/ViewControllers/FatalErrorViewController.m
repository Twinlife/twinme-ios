/*
 *  Copyright (c) 2021-2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Utils/NSString+Utils.h>

#import "FatalErrorViewController.h"

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: FatalErrorViewController ()
//

@interface FatalErrorViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *logoView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoImageWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoImageHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *logoImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twinmeImageWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twinmeImageHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *twinmeImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@property (nonatomic) NSString *errorMessage;

@property (nonatomic) BOOL customMessage;

@end

#undef LOG_TAG
#define LOG_TAG @"FatalErrorViewController"

@implementation FatalErrorViewController

+ (void)initialize {
    DDLogVerbose(@"%@ initialize", LOG_TAG);
}

#pragma mark - UIViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _customMessage = NO;
    }
    return self;
}

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
    
    [self initViews];
}

- (void)initWithErrorCode:(TLBaseServiceErrorCode)errorCode databaseError:(nullable NSError *)databaseError {
    DDLogVerbose(@"%@ initWithErrorCode: %d", LOG_TAG, errorCode);

    switch (errorCode) {
        case TLBaseServiceErrorCodeBadRequest:
        case TLBaseServiceErrorCodeLibraryError:
        case TLBaseServiceErrorCodeFeatureNotImplemented:
        case TLBaseServiceErrorCodeServerError:
        default:
            self.customMessage = YES;
            self.errorMessage = [NSString stringWithFormat:TwinmeLocalizedString(@"fatal_error_view_controller_error_code_message %@", nil), errorCode];
            break;
            
        case TLBaseServiceErrorCodeFeatureNotSupportedByPeer:
            self.errorMessage = TwinmeLocalizedString(@"conversation_view_controller_feature_not_supported_by_peer", nil);
            break;
            
        case TLBaseServiceErrorCodeWrongLibraryConfiguration:
            self.errorMessage = TwinmeLocalizedString(@"application_wrong_configuration", nil);
            break;
            
        case TLBaseServiceErrorCodeDatabaseError:
            if (databaseError) {
                self.customMessage = YES;
                self.errorMessage = [NSString stringWithFormat:@"%@\n\n%@", [NSString stringWithFormat:TwinmeLocalizedString(@"fatal_error_view_controller_error_code_message %@", nil), errorCode], databaseError.description];
            } else {
                self.errorMessage = TwinmeLocalizedString(@"application_database_error", nil);
            }
        
            break;
            
        case TLBaseServiceErrorCodeNoStorageSpace:
            self.customMessage = YES;
            
            if (![self.twinmeContext isDatabaseUpgraded]) {
                self.errorMessage = TwinmeLocalizedString(@"application_migration_no_storage_space", nil);
            } else {
                self.errorMessage = [NSString stringWithFormat:@"%@\n\n%@", TwinmeLocalizedString(@"application_error_no_storage_space", nil), TwinmeLocalizedString(@"application_error_no_storage_space_message", nil)];
            }

            break;
            
        case TLBaseServiceErrorCodeAccountDeleted:
            self.errorMessage = TwinmeLocalizedString(@"application_account_deleted", nil);
            break;
    }
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.view.backgroundColor = Design.WHITE_COLOR;
    
    self.logoViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.logoViewWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.logoViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.logoImageWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.logoImageHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.twinmeImageWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.twinmeImageHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.twinmeImage.tintColor = Design.SPLASHSCREEN_LOGO_COLOR;
    
    self.messageLabelWidthConstraint.constant *= Design.WIDTH_RATIO;
    self.messageLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.messageLabel.font = Design.FONT_REGULAR36;
    self.messageLabel.textColor = Design.FONT_COLOR_DEFAULT;
    
    if (self.customMessage) {
        self.messageLabel.text = self.errorMessage;
    } else {
        self.messageLabel.text = [NSString stringWithFormat:TwinmeLocalizedString(@"fatal_error_view_controller_error_message %@", nil), self.errorMessage];
    }
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    self.messageLabel.font = Design.FONT_REGULAR36;
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.view.backgroundColor = Design.WHITE_COLOR;
    self.messageLabel.textColor = Design.FONT_COLOR_DEFAULT;
}

@end

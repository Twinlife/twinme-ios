/*
 *  Copyright (c) 2018-2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "PreviewFileCell.h"

#import <TwinmeCommon/Design.h>

#import "UIPreviewFile.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: PreviewFileCell ()
//

@interface PreviewFileCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

//
// Implementation: PreviewFileCell
//

#undef LOG_TAG
#define LOG_TAG @"PreviewFileCell"

@implementation PreviewFileCell

- (void)awakeFromNib {
    DDLogVerbose(@"%@ awakeFromNib", LOG_TAG);
    
    [super awakeFromNib];
        
    self.isAccessibilityElement = YES;
    
    self.imageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.imageViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.titleLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.titleLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.titleLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.titleLabel.font = Design.FONT_REGULAR34;
    self.titleLabel.textColor = [UIColor whiteColor];
}

- (void)prepareForReuse {
    DDLogVerbose(@"%@ prepareForReuse", LOG_TAG);
    
    [super prepareForReuse];
}

- (void)bind:(UIPreviewFile *)previewFile {
    DDLogVerbose(@"%@ bind: %@", LOG_TAG, previewFile);
    
    self.imageView.image = previewFile.icon;
        
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:previewFile.title attributes:[NSDictionary dictionaryWithObjectsAndKeys: Design.FONT_MEDIUM38, NSFontAttributeName, nil]];
    if (![previewFile.size isEqual:@""]) {
        [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n"]];
        [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:previewFile.size attributes:[NSDictionary dictionaryWithObjectsAndKeys: Design.FONT_REGULAR36, NSFontAttributeName, nil]]];
    }

    self.titleLabel.attributedText = attributedString;
}

@end

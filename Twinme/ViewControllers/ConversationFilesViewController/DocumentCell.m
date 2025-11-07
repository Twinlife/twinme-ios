/*
 *  Copyright (c) 2023 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinlife/TLConversationService.h>

#import "DocumentCell.h"

#import "Item.h"
#import "FileItem.h"
#import "PeerFileItem.h"

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static const CGFloat DESIGN_FILE_RADIUS = 6;

static UIColor *DESIGN_PLACEHOLDER_COLOR;

//
// Interface: DocumentCell ()
//

@interface DocumentCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *typeDocumentContainerViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *typeDocumentContainerViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIView *typeDocumentContainerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *typeDocumentImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *typeDocumentImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *documentLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *documentLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *documentLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkMarkViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkMarkViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *checkMarkView;
@property (weak, nonatomic) IBOutlet UIImageView *checkMarkImageView;

@end

//
// Implementation: DocumentCell
//

#undef LOG_TAG
#define LOG_TAG @"DocumentCell"

@implementation DocumentCell

+ (void)initialize {
    DDLogVerbose(@"%@ initialize", LOG_TAG);
    
    DESIGN_PLACEHOLDER_COLOR = [UIColor colorWithRed:229./255. green:229./255. blue:229./255. alpha:1];
}

- (void)awakeFromNib {
    DDLogVerbose(@"%@ awakeFromNib", LOG_TAG);
    
    [super awakeFromNib];
        
    self.isAccessibilityElement = YES;
    self.contentView.backgroundColor = Design.WHITE_COLOR;
    
    self.typeDocumentContainerViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.typeDocumentContainerViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
        
    self.typeDocumentContainerView.backgroundColor = DESIGN_PLACEHOLDER_COLOR;
    self.typeDocumentContainerView.clipsToBounds = YES;
    self.typeDocumentContainerView.layer.cornerRadius = DESIGN_FILE_RADIUS;
    
    self.typeDocumentImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
        
    self.documentLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.documentLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.documentLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.documentLabel.font = Design.FONT_MEDIUM34;
    
    CGFloat checkMarkViewHeightConstraintConstant = self.checkMarkViewHeightConstraint.constant * Design.HEIGHT_RATIO;
    CGFloat roundedCheckMarkViewHeightConstraintConstant = ((int) (roundf(checkMarkViewHeightConstraintConstant / 2))) * 2;
         
    self.checkMarkViewHeightConstraint.constant = roundedCheckMarkViewHeightConstraintConstant;
    self.checkMarkViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    CALayer *checkMarkViewLayer = self.checkMarkView.layer;
    checkMarkViewLayer.cornerRadius = self.checkMarkViewHeightConstraint.constant * 0.5;
    checkMarkViewLayer.borderWidth = Design.CHECKMARK_BORDER_WIDTH;
    checkMarkViewLayer.borderColor = Design.CHECKMARK_BORDER_COLOR.CGColor;
    
    self.checkMarkView.clipsToBounds = YES;
    self.checkMarkImageView.tintColor = Design.MAIN_COLOR;
}

- (void)bindWithItem:(Item *)item isSelectable:(BOOL)isSelectable {
    DDLogVerbose(@"%@ bind", LOG_TAG);
    
    TLNamedFileDescriptor *namedFileDescriptor;
    if (item.isPeerItem) {
        FileItem *fileItem = (FileItem *)item;
        namedFileDescriptor = fileItem.namedFileDescriptor;
    } else {
        PeerFileItem *peerFileItem = (PeerFileItem *)item;
        namedFileDescriptor = peerFileItem.namedFileDescriptor;
    }
        
    NSString *extension = namedFileDescriptor.extension.lowercaseString;
    if ([extension isEqualToString:@"pdf"]) {
        self.typeDocumentImageView.image = [UIImage imageNamed:@"FileIconPDF"];
    } else if ([extension isEqualToString:@"doc"] || [extension isEqualToString:@"docx"]) {
        self.typeDocumentImageView.image = [UIImage imageNamed:@"FileIconWord"];
    } else if ([extension isEqualToString:@"xls"] || [extension isEqualToString:@"xlsx"]) {
        self.typeDocumentImageView.image = [UIImage imageNamed:@"FileIconExcel"];
    } else if ([extension isEqualToString:@"ppt"] || [extension isEqualToString:@"pptx"]) {
        self.typeDocumentImageView.image = [UIImage imageNamed:@"FileIconPowerPoint"];
    } else {
        self.typeDocumentImageView.image = [UIImage imageNamed:@"ToolbarFileGrey"];
    }
    
    NSMutableAttributedString *fileAttributedString = [[NSMutableAttributedString alloc] initWithString:namedFileDescriptor.name attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_MEDIUM34, NSFontAttributeName, Design.FONT_COLOR_DEFAULT, NSForegroundColorAttributeName, nil]];
    
    [fileAttributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n"]];
    
    NSByteCountFormatter *byteCountFormatter = [[NSByteCountFormatter alloc]init];
    byteCountFormatter.countStyle = NSByteCountFormatterCountStyleFile;

    [fileAttributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:[byteCountFormatter stringFromByteCount:namedFileDescriptor.length] attributes:[NSDictionary dictionaryWithObjectsAndKeys:Design.FONT_REGULAR24, NSFontAttributeName, Design.FONT_COLOR_GREY, NSForegroundColorAttributeName, nil]]];
    
    self.documentLabel.attributedText = fileAttributedString;
    
    self.checkMarkView.hidden = !isSelectable;
    self.checkMarkImageView.hidden = !item.selected;
    
    [self updateColor];
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.contentView.backgroundColor = Design.WHITE_COLOR;
}

@end

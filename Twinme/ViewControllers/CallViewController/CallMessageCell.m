/*
 *  Copyright (c) 2024 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "CallMessageCell.h"

#import <TwinmeCommon/Design.h>
#import "DecoratedLabel.h"

#import <Utils/NSString+Utils.h>
#import "UIView+Toast.h"
#import "CallConversationView.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static const int MAX_EMOJI = 5;

//
// Interface: CallMessageCell ()
//

@interface CallMessageCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentLabelBottomConstraint;
@property (weak, nonatomic) IBOutlet DecoratedLabel *contentLabel;

@property (nonatomic) CGFloat topLeftRadius;
@property (nonatomic) CGFloat topRightRadius;
@property (nonatomic) CGFloat bottomRightRadius;
@property (nonatomic) CGFloat bottomLeftRadius;

@end

//
// Implementation: CallMessageCell
//

#undef LOG_TAG
#define LOG_TAG @"CallMessageCell"

@implementation CallMessageCell

- (void)awakeFromNib {
    DDLogVerbose(@"%@ awakeFromNib", LOG_TAG);
    
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
        
    self.contentLabel.font = Design.FONT_REGULAR32;
    self.contentLabel.numberOfLines = 0;
    self.contentLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.contentLabel.preferredMaxLayoutWidth = Design.MESSAGE_CELL_MAX_WIDTH;
    self.contentLabel.textColor = [UIColor whiteColor];
    CGFloat heightPadding = Design.TEXT_HEIGHT_PADDING;
    CGFloat widthPadding = Design.TEXT_WIDTH_PADDING;
    [self.contentLabel setPaddingWithTop:heightPadding left:widthPadding bottom:heightPadding right:widthPadding];
    [self.contentLabel setDecorShadowColor:[UIColor clearColor]];
    [self.contentLabel setDecorColor:Design.MAIN_COLOR];
    [self.contentLabel setBorderColor:[UIColor clearColor]];
    [self.contentLabel setBorderWidth:0];
    self.contentLabel.longPressGestureRecognizer.cancelsTouchesInView = NO;
        
    NSMutableDictionary *mutableLinkAttributes = [NSMutableDictionary dictionary];
    [mutableLinkAttributes setObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCTUnderlineStyleAttributeName];
    [mutableLinkAttributes setObject:(__bridge id)[[UIColor whiteColor] CGColor] forKey:(NSString *)kCTForegroundColorAttributeName];
    self.contentLabel.linkAttributes = [NSDictionary dictionaryWithDictionary:mutableLinkAttributes];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPressInsideContent:)];
    [self.contentLabel addGestureRecognizer:longPressGesture];
    
    self.contentLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.contentLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.contentLabelBottomConstraint.constant *= Design.HEIGHT_RATIO;
}

- (void)prepareForReuse {
    DDLogVerbose(@"%@ prepareForReuse", LOG_TAG);
    
    [super prepareForReuse];
    
    self.contentLabel.text = nil;
}

- (void)dealloc {
    DDLogVerbose(@"%@ dealloc", LOG_TAG);
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)bindWithItem:(MessageItem *)item callConversationView:(CallConversationView *)callConversationView {
    DDLogVerbose(@"%@ bindWithItem: %@", LOG_TAG, item);
        
    [self.contentLabel setDecorColor:Design.MAIN_COLOR];
    [self.contentLabel setBorderColor:[UIColor clearColor]];
    
    CGFloat topMargin = [callConversationView getTopMarginWithMask:item.corners & ITEM_TOP_RIGHT item:item];
    self.contentLabelTopConstraint.constant = topMargin;
    self.contentLabelBottomConstraint.constant = [callConversationView getBottomMarginWithMask:item.corners & ITEM_BOTTOM_RIGHT item:item];
    
    int countEmoji = [self countEmoji:item.content];
    
    if (countEmoji == 0) {
        self.contentLabel.font = Design.FONT_REGULAR32;
        CGFloat heightPadding = Design.TEXT_HEIGHT_PADDING;
        CGFloat widthPadding = Design.TEXT_WIDTH_PADDING;
        [self.contentLabel setPaddingWithTop:heightPadding left:widthPadding bottom:heightPadding right:widthPadding];
    } else {
        [self.contentLabel setDecorColor:[UIColor clearColor]];
        [self.contentLabel setBorderColor:[UIColor clearColor]];
        [self.contentLabel setPaddingWithTop:0 left:0 bottom:0 right:0];
        self.contentLabel.font = [Design getEmojiFont:countEmoji];
    }
    
    self.contentLabel.text = item.content;
    
    int corners = item.corners;
    if ([[UIApplication sharedApplication] userInterfaceLayoutDirection] == UIUserInterfaceLayoutDirectionRightToLeft) {
        self.topLeftRadius = [callConversationView getRadiusWithMask:corners & ITEM_TOP_RIGHT];
        self.topRightRadius = [callConversationView getRadiusWithMask:corners & ITEM_TOP_LEFT];
        self.bottomRightRadius = [callConversationView getRadiusWithMask:corners & ITEM_BOTTOM_LEFT];
        self.bottomLeftRadius = [callConversationView getRadiusWithMask:corners & ITEM_BOTTOM_RIGHT];
    } else {
        self.topLeftRadius = [callConversationView getRadiusWithMask:corners & ITEM_TOP_LEFT];
        self.topRightRadius = [callConversationView getRadiusWithMask:corners & ITEM_TOP_RIGHT];
        self.bottomRightRadius = [callConversationView getRadiusWithMask:corners & ITEM_BOTTOM_RIGHT];
        self.bottomLeftRadius = [callConversationView getRadiusWithMask:corners & ITEM_BOTTOM_LEFT];
    }
    
    [self.contentLabel setCornerRadiusWithTopLeft:self.topLeftRadius topRight:self.topRightRadius bottomRight: self.bottomRightRadius bottomLeft:self.bottomLeftRadius];
    
    [self updateColor];
    [self setNeedsDisplay];
}

- (void)onLongPressInsideContent:(UILongPressGestureRecognizer *)longPressGesture {
    DDLogVerbose(@"%@ onLongPressInsideContent: %@", LOG_TAG, longPressGesture);
    
    if (longPressGesture.state == UIGestureRecognizerStateBegan) {
        [[UIPasteboard generalPasteboard] setString:self.contentLabel.text];
        [[UIApplication sharedApplication].keyWindow makeToast:TwinmeLocalizedString(@"conversation_view_controller_menu_item_view_copy_message", nil)];
    }
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.contentLabel.textColor = [UIColor whiteColor];
}

- (int)countEmoji:(NSString *)content {
    
    NSMutableArray *characters = [NSMutableArray arrayWithCapacity:content.length];
    [content enumerateSubstringsInRange:NSMakeRange(0, content.length)
                                  options:NSStringEnumerationByComposedCharacterSequences
                               usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        [characters addObject:substring];
    }];
        
    if (characters.count > MAX_EMOJI) {
        return 0;
    }
    
    int countEmoji = 0;
    
    for (NSString *character in characters) {
        BOOL contains = CFStringFindCharacterFromSet((CFStringRef)character, Design.EMOJI_CHARACTER_SET, CFRangeMake(0, character.length), 0, NULL);
        if (contains) {
            countEmoji++;
        } else {
            return 0;
        }
        
        if (countEmoji == MAX_EMOJI) {
            break;
        }
    }
    return countEmoji;
}

@end

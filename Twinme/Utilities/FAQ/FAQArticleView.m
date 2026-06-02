/*
 *  Copyright (c) 2025-2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "FAQArticleView.h"

#import <Utils/NSString+Utils.h>

#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/UIFAQArticle.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static const CGFloat CONTENT_MIN_HEIGHT = 314;
static const CGFloat MAX_ICON_SIZE = 24;

static NSString * IMAGE_PATTERN = @"\\[\\[([^\\]]+)\\]\\]";

// Link
NSString * const PRIVACY_POLICY_LINK = @"https://twin.me/privacy-policy/";
NSString * const CONTACT_LINK = @"https://twin.me/en/contact/";
NSString * const VIDEO_PRESENTATION_LINK = @"https://youtu.be/uj2bFKQ_L60";
NSString * const KURIO_LINK = @"https://www.youtube.com/embed/BZCIT-g5tBo/";
NSString * const DONT_KILL_MY_APP_LINK = @"https://dontkillmyapp.com/";
NSString * const CONNECT_PEOPLE_LINK = @"https://twin.me/support/connect-people";
NSString * const OPEN_SOURCE_LINK = @"https://github.com/France-en-Ligne";

// Image
NSString * const ADD_CONTACT_IMAGE = @"AddContact";
NSString * const CHAT_IMAGE = @"Chat";
NSString * const SEND_IMAGE = @"Send";
NSString * const TRASH_IMAGE = @"Trash";
NSString * const CAMERA_IMAGE = @"Camera";
NSString * const GALLERY_IMAGE = @"Gallery";
NSString * const SPINNER_IMAGE = @"Spinner";
NSString * const RECEIVED_STATE_IMAGE = @"ReceivedState";
NSString * const NOT_SENT_STATE_IMAGE = @"NoSentState";
NSString * const MICRO_MUTE_IMAGE = @"MicroMute";
NSString * const SPEAKER_ON_IMAGE = @"SpeakerOn";
NSString * const AUDIO_CALL_IMAGE = @"AudioCall";
NSString * const VIDEO_CALL_IMAGE = @"VideoCall";
NSString * const SWITCH_CAMERA_IMAGE = @"SwitchCamera";
NSString * const VIDEO_MUTE_IMAGE = @"VideoMute";
NSString * const MENU_IMAGE = @"Menu";

//
// Interface: FAQArticleView ()
//

@interface FAQArticleView ()<UITextViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageTextViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageTextViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageTextViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageTextViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *confirmViewBottomConstraint;

@property (nonatomic) NSMutableDictionary<NSString *, NSString *> *images;

@end

//
// Implementation: FAQArticleView
//

#undef LOG_TAG
#define LOG_TAG @"FAQArticleView"

@implementation FAQArticleView

#pragma mark - UIView

- (instancetype)init {
    DDLogVerbose(@"%@ init", LOG_TAG);
    
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"FAQArticleView" owner:self options:nil];
    self = [objects objectAtIndex:0];
    self.translatesAutoresizingMaskIntoConstraints = NO;
    if (self) {
        [self initViews];
    }
    return self;
}

- (void)layoutSubviews {
    DDLogVerbose(@"%@ layoutSubviews", LOG_TAG);
    
    [self updateTextViewHeight];
}

- (void)initWithFAQArticle:(UIFAQArticle *)article {
    DDLogVerbose(@"%@ initWithFAQArticle: %@", LOG_TAG, article);
    
    self.titleLabel.text = article.question;
    self.messageTextView.attributedText = [self formatAnswer:article.answer];
    [self updateTextViewHeight];
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction {
    DDLogVerbose(@"%@ textView: %@ shouldInteractWithURL: %@", LOG_TAG, textView, URL);
    
    [self interactWithURL:URL];
    
    return NO;
}

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    [super initViews];
    
    self.messageTextViewTopConstraint.constant *= Design.HEIGHT_RATIO;
    self.messageTextViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.messageTextViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.messageTextView.font = Design.FONT_REGULAR32;
    self.messageTextView.textColor = Design.FONT_COLOR_GREY;
    self.messageTextView.editable = NO;
    self.messageTextView.selectable = YES;
    self.messageTextView.delegate = self;
    self.messageTextView.textContainerInset = UIEdgeInsetsZero;
    self.messageTextView.textContainer.lineFragmentPadding = 0;

    self.confirmViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.confirmView.backgroundColor = Design.MAIN_COLOR;
    self.confirmLabel.text = TwinmeLocalizedString(@"application_ok", nil);
        
    [self updateTextViewHeight];
    [self initImages];
}

- (void)updateTextViewHeight {
    DDLogVerbose(@"%@ updateTextViewHeight", LOG_TAG);
    
    CGRect titleRect;
    CGFloat textWidth = self.frame.size.width - self.messageTextViewLeadingConstraint.constant - self.messageTextViewTrailingConstraint.constant;
    
    if (self.titleLabel.attributedText) {
        titleRect =
          [self.titleLabel.attributedText boundingRectWithSize:CGSizeMake(textWidth, CGFLOAT_MAX)
          options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
          context:nil];
    } else {
        titleRect = [self.titleLabel.text boundingRectWithSize:CGSizeMake(textWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{
            NSFontAttributeName : Design.FONT_BOLD36
        } context:nil];
    }

    CGFloat maxHeight = self.frame.size.height - (CONTENT_MIN_HEIGHT * Design.HEIGHT_RATIO) - titleRect.size.height;

    CGRect messageRect;
    if (self.messageTextView.attributedText.length > 0) {
        messageRect = [self.messageTextView.attributedText boundingRectWithSize:CGSizeMake(textWidth, CGFLOAT_MAX)
          options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
          context:nil];
    } else {
        messageRect = CGRectZero;
    }
    
    if (messageRect.size.height > maxHeight) {
        self.messageTextViewHeightConstraint.constant = maxHeight;
    } else {
        self.messageTextViewHeightConstraint.constant = messageRect.size.height;
    }
}

- (NSMutableAttributedString *)formatAnswer:(NSString *)answer {
    DDLogVerbose(@"%@ formatAnswer", LOG_TAG);
    
    if ([answer isEqualToString:@""]) {
        return [[NSMutableAttributedString alloc] initWithString:@""];
    }

    NSData *data = [answer dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *options = @{
        NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
        NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding),
    };

    NSError *error = nil;
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithData:data
                                                                            options:options
                                                                 documentAttributes:nil
                                                                              error:&error];
    if (error || !attributedString) {
        return [[NSMutableAttributedString alloc] initWithString:answer];
    }

    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:attributedString];
    NSRange fullRange = NSMakeRange(0, mutableAttributedString.length);
    UIColor *textColor = self.forceDarkMode ? [UIColor whiteColor] : Design.FONT_COLOR_DEFAULT;
    [mutableAttributedString beginEditing];
    [mutableAttributedString enumerateAttribute:NSFontAttributeName
                                        inRange:fullRange
                                        options:0
                                     usingBlock:^(UIFont *font, NSRange range, BOOL *stop) {
        [mutableAttributedString addAttribute:NSFontAttributeName value:Design.FONT_REGULAR32 range:range];
    }];
    [mutableAttributedString addAttribute:NSForegroundColorAttributeName value:textColor range:fullRange];
    [self addImages:mutableAttributedString];
    
    [mutableAttributedString endEditing];

    return mutableAttributedString;
}

- (void)addImages:(NSMutableAttributedString *)attributedString {
    DDLogVerbose(@"%@ addImages", LOG_TAG);
    
    NSError *error = nil;
    NSRegularExpression *placeholderImageRegex = [NSRegularExpression regularExpressionWithPattern:IMAGE_PATTERN
                                                                                       options:0
                                                                                         error:&error];
    if (error || !placeholderImageRegex) {
        return;
    }

    NSArray<NSTextCheckingResult *> *matches = [placeholderImageRegex matchesInString:attributedString.string
                                                                          options:0
                                                                            range:NSMakeRange(0, attributedString.length)];
    
    for (NSTextCheckingResult *match in [matches reverseObjectEnumerator]) {
        if (match.numberOfRanges >= 2) {
            NSString *imageName = [attributedString.string substringWithRange:[match rangeAtIndex:1]];
            
            UIImage *image = [self getImageFromPlaceholder:imageName];
            if (!image) {
                [attributedString replaceCharactersInRange:match.range withString:@""];
            } else {
                if ([self needsTint:imageName]) {
                    image = [self tintedImage:image color:Design.FONT_COLOR_DEFAULT size:image.size];
                }
                
                NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
                attachment.image = image;
                
                CGFloat scale = MAX_ICON_SIZE / image.size.width;
                CGFloat height = image.size.height * scale;
                attachment.bounds = CGRectMake(0, -4, MAX_ICON_SIZE, height);

                NSAttributedString *imageString = [NSAttributedString attributedStringWithAttachment:attachment];
                [attributedString replaceCharactersInRange:match.range withAttributedString:imageString];
            }
        }
    }
}

- (UIImage *)getImageFromPlaceholder:(NSString *)placeholder {
    DDLogVerbose(@"%@ getImageFromPlaceholder: %@", LOG_TAG, placeholder);
    
    if ([self.images valueForKey:placeholder]) {
        return [UIImage imageNamed:[self.images valueForKey:placeholder]];
    }
    
    return nil;
}

- (void)interactWithURL:(NSURL *)url {
    DDLogVerbose(@"%@ interactWithURL: %@", LOG_TAG, url);
    
    NSString *path = [url absoluteString];
    if ([path isEqual:VIDEO_PRESENTATION_LINK] || [path isEqual:KURIO_LINK] || [path isEqual:DONT_KILL_MY_APP_LINK] || [path isEqual:OPEN_SOURCE_LINK] || [path isEqual:CONNECT_PEOPLE_LINK]) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    } else {
        if ([self.faqArticleViewDelegate respondsToSelector:@selector(didTapOnFAQLink:faqArticleView:)]) {
            [self.faqArticleViewDelegate didTapOnFAQLink:path faqArticleView:self];
        }
    }
}

- (BOOL)needsTint:(NSString *)imageName {
    DDLogVerbose(@"%@ needsTint: %@", LOG_TAG, imageName);
    
    if ([imageName isEqualToString:RECEIVED_STATE_IMAGE] || [imageName isEqualToString:NOT_SENT_STATE_IMAGE]) {
        return NO;
    }
    
    return YES;
}

- (UIImage *)tintedImage:(UIImage *)image color:(UIColor *)color size:(CGSize)size {
    DDLogVerbose(@"%@ tintedImage: %@", LOG_TAG, image);
    
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:size];

    return [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
        CGRect rect = CGRectMake(0, 0, size.width, size.height);
        [image drawInRect:rect];
        [color setFill];
        UIRectFillUsingBlendMode(rect, kCGBlendModeSourceIn);
    }];
}

- (void)initImages {
    DDLogVerbose(@"%@ initImages", LOG_TAG);
    
    self.images = [[NSMutableDictionary alloc] init];
    self.images[ADD_CONTACT_IMAGE] = @"ActionBarAddContact";
    self.images[CHAT_IMAGE] = @"CallChatIcon";
    self.images[SEND_IMAGE] = @"Send";
    self.images[TRASH_IMAGE] = @"ToolbarTrash";
    self.images[CAMERA_IMAGE] = @"GreyCamera";
    self.images[GALLERY_IMAGE] = @"GalleryIcon";
    self.images[SPINNER_IMAGE] = @"";
    self.images[RECEIVED_STATE_IMAGE] = @"ItemStateReceived";
    self.images[NOT_SENT_STATE_IMAGE] = @"ItemStateNotSent";
    self.images[MICRO_MUTE_IMAGE] = @"MuteActionCallOn";
    self.images[SPEAKER_ON_IMAGE] = @"LoudSpeakerActionCallOn";
    self.images[AUDIO_CALL_IMAGE] = @"AudioCall";
    self.images[VIDEO_CALL_IMAGE] = @"VideoCall";
    self.images[SWITCH_CAMERA_IMAGE] = @"TurnActionCall";
    self.images[VIDEO_MUTE_IMAGE] = @"VideoMuteActionCallOn";
    self.images[MENU_IMAGE] = @"SideMenu";
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    [super updateColor];
    
    if (self.messageTextView.attributedText.length > 0) {
        NSMutableAttributedString *mutableAttributedText = [[NSMutableAttributedString alloc] initWithAttributedString:self.messageTextView.attributedText];
        UIColor *textColor = self.forceDarkMode ? [UIColor whiteColor] : Design.FONT_COLOR_DEFAULT;
        [mutableAttributedText addAttribute:NSForegroundColorAttributeName value:textColor range:NSMakeRange(0, mutableAttributedText.length)];
        self.messageTextView.attributedText = mutableAttributedText;
    } else if (!self.forceDarkMode) {
        self.messageTextView.textColor = Design.FONT_COLOR_GREY;
    } else {
        self.messageTextView.textColor = UIColor.whiteColor;
    }
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    [super updateFont];
    
    if (!self.titleLabel.attributedText) {
        self.titleLabel.font = Design.FONT_BOLD36;
    }
    
    if (self.messageTextView.attributedText.length > 0) {
        NSMutableAttributedString *mutableAttributedText = [[NSMutableAttributedString alloc] initWithAttributedString:self.messageTextView.attributedText];
        [mutableAttributedText enumerateAttribute:NSFontAttributeName
                                          inRange:NSMakeRange(0, mutableAttributedText.length)
                                          options:0
                                       usingBlock:^(UIFont *font, NSRange range, BOOL *stop) {
            [mutableAttributedText addAttribute:NSFontAttributeName value:Design.FONT_REGULAR32 range:range];
        }];
        self.messageTextView.attributedText = mutableAttributedText;
    } else {
        self.messageTextView.font = Design.FONT_REGULAR32;
    }
}

@end

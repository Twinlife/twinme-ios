/*
 *  Copyright (c) 2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "RestoreWordsCell.h"

#import "RestoreWordCell.h"
#import "UIBackupWord.h"
#import "TwinmeTextField.h"
#import "WordCompletionView.h"

#import <Utils/NSString+Utils.h>

#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/MnemonicCodeUtils.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static NSString *RESTORE_WORD_CELL_IDENTIFIER = @"RestoreWordCellIdentifier";

static const CGFloat COUNT_WORDS = 12;
static const CGFloat DESIGN_WORD_HEIGHT = 100;
static const CGFloat DESIGN_COMPLETION_HEIGHT = 80;
//
// Interface: RestoreWordsCell ()
//

@interface RestoreWordsCell ()<UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate, WordCompletionDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *positionLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *positionLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *wordTextFieldLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *wordTextFieldTrailingConstraint;
@property (weak, nonatomic) IBOutlet TwinmeTextField *wordTextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *wordsCollectionViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *wordsCollectionViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *wordsCollectionViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *wordsCollectionViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *wordsCollectionViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UICollectionView *wordsCollectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pasteWordViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *pasteWordView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pasteWordImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pasteWordImageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pasteWordImageViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pasteWordImageViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *pasteWordImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pasteWordLabelTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *pasteWordLabel;
@property (nonatomic) WordCompletionView *wordCompletionView;

@property (nonatomic) NSMutableArray *words;
@property (nonatomic) MnemonicCodeUtils *mnemonicCodeUtils;

@property (nonatomic) int currentWord;

@end

//
// Implementation: RestoreWordsCell
//

#undef LOG_TAG
#define LOG_TAG @"RestoreWordsCell"

@implementation RestoreWordsCell

- (void)awakeFromNib {
    DDLogVerbose(@"%@ awakeFromNib", LOG_TAG);
    
    [super awakeFromNib];
    
    self.currentWord = -1;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    
    self.messageLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.messageLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.messageLabelTopConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.messageLabel.font = Design.FONT_REGULAR32;
    self.messageLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.messageLabel.text = TwinmeLocalizedStringFromTable(@"restore_view_enter_words", @"LocalizableBackup", nil);
    
    self.containerViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.containerViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.containerViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.containerViewTopConstraint.constant *= Design.HEIGHT_RATIO;
        
    self.containerView.backgroundColor = Design.GREY_ITEM;
    self.containerView.clipsToBounds = YES;
    self.containerView.layer.cornerRadius = self.containerViewHeightConstraint.constant * 0.5f;
    self.containerView.layer.borderWidth = 1.f;
    self.containerView.layer.borderColor = Design.FONT_COLOR_GREY.CGColor;
    
    self.positionLabelLeadingConstraint.constant *= Design.WIDTH_RATIO;

    self.positionLabel.textColor = Design.FONT_COLOR_GREY;
    self.positionLabel.font = [Design getBackupWordFont];
    self.positionLabel.hidden = YES;
    
    self.wordTextFieldLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.wordTextFieldTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.wordTextField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    self.wordTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.wordTextField.spellCheckingType = UITextSpellCheckingTypeNo;
    self.wordTextField.delegate = self;
    self.wordTextField.font = [Design getBackupWordFont];
    self.wordTextField.textColor = Design.FONT_COLOR_DEFAULT;
    [self.wordTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    self.wordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:TwinmeLocalizedString(@"application_search_hint", nil) attributes:[NSDictionary dictionaryWithObject:Design.PLACEHOLDER_COLOR forKey:NSForegroundColorAttributeName]];
    
    self.wordsCollectionViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.wordsCollectionViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    self.wordsCollectionViewTopConstraint.constant *= Design.WIDTH_RATIO;
    self.wordsCollectionViewHeightConstraint.constant = COUNT_WORDS * 0.5 * DESIGN_WORD_HEIGHT * Design.HEIGHT_RATIO;
    self.wordsCollectionViewBottomConstraint.constant *= Design.WIDTH_RATIO;
    
    self.wordsCollectionView.dataSource = self;
    self.wordsCollectionView.delegate = self;
    self.wordsCollectionView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    [self.wordsCollectionView registerNib:[UINib nibWithNibName:@"RestoreWordCell" bundle:nil] forCellWithReuseIdentifier:RESTORE_WORD_CELL_IDENTIFIER];
    
    UICollectionViewFlowLayout* viewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    [viewFlowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [viewFlowLayout setMinimumInteritemSpacing:0];
    [viewFlowLayout setMinimumLineSpacing:0];
    [viewFlowLayout setItemSize:CGSizeMake(Design.DISPLAY_WIDTH * 0.5f, DESIGN_WORD_HEIGHT * Design.HEIGHT_RATIO)];
    [self.wordsCollectionView setCollectionViewLayout:viewFlowLayout];
    
    self.pasteWordViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    
    self.pasteWordView.userInteractionEnabled = YES;
    self.pasteWordView.accessibilityLabel = TwinmeLocalizedStringFromTable(@"restore_view_paste", @"LocalizableBackup", nil);
    UITapGestureRecognizer *pasteWordsGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleCopyWordsTapGesture:)];
    [self.pasteWordView addGestureRecognizer:pasteWordsGestureRecognizer];
    
    self.pasteWordImageViewHeightConstraint.constant *= Design.HEIGHT_RATIO;
    self.pasteWordImageViewBottomConstraint.constant *= Design.HEIGHT_RATIO;
    self.pasteWordImageViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.pasteWordImageViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.pasteWordImageView.tintColor = Design.BLACK_COLOR;
    
    self.pasteWordLabelTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    self.pasteWordLabel.font = Design.FONT_MEDIUM30;
    self.pasteWordLabel.textColor = Design.FONT_COLOR_DEFAULT;
    self.pasteWordLabel.text = TwinmeLocalizedStringFromTable(@"restore_view_paste", @"LocalizableBackup", nil);
}

- (void)bind:(MnemonicCodeUtils *)mnemonicCodeUtils words:(NSArray *)words {
    DDLogVerbose(@"%@ bind: %@", LOG_TAG, mnemonicCodeUtils);
    
    if (words && words.count > 0) {
        if (!self.words) {
            self.words = [[NSMutableArray alloc]init];
        } else {
            [self.words removeAllObjects];
        }
        
        [self.words addObjectsFromArray:words];
    }
   
    [self.wordsCollectionView reloadData];
    
    self.mnemonicCodeUtils = mnemonicCodeUtils;
    
    [self updateColor];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    DDLogVerbose(@"%@ textFieldShouldReturn: %@", LOG_TAG, textField);
    
    [textField resignFirstResponder];
    if (self.wordCompletionView) {
        self.wordCompletionView.hidden = YES;
    }
    self.positionLabel.hidden = YES;
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    DDLogVerbose(@"%@ textFieldDidBeginEditing: %@", LOG_TAG, textField);
    
    if (self.currentWord == -1) {
        self.currentWord = 0;
        self.positionLabel.hidden = NO;
        self.positionLabel.text = [NSString stringWithFormat:@"%d", self.currentWord + 1];
        [self.wordsCollectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathWithIndex:0]]];
    }
}

- (void)textFieldDidChange:(UITextField *)textField {
    DDLogVerbose(@"%@ textFieldDidChange: %@", LOG_TAG, textField);
    
    textField.text = [textField.text uppercaseString];
    [self searchWord:textField.text];
}

#pragma mark - WordCompletionDelegate

- (void)searchWord:(NSString *)text {
    DDLogVerbose(@"%@ searchWord: %@", LOG_TAG, text);
    
    if (!self.wordCompletionView) {
        self.wordCompletionView = [[WordCompletionView alloc]init];
        CGFloat completionHeight = DESIGN_COMPLETION_HEIGHT * 3 * Design.HEIGHT_RATIO;
        self.wordCompletionView.frame = CGRectMake(0, self.wordsCollectionView.frame.origin.y, Design.DISPLAY_WIDTH, completionHeight);
        self.wordCompletionView.wordCompletionDelegate = self;
        [self.contentView addSubview:self.wordCompletionView];
    }
    
    self.wordCompletionView.hidden = NO;
    [self.wordCompletionView setSuggestions:[self.mnemonicCodeUtils getSuggestionsWithPrefix:text locale:nil]];
}

- (void)selectWord:(NSString *)word {
    DDLogVerbose(@"%@ selectWord: %@", LOG_TAG, word);
    
    self.wordCompletionView.hidden = YES;
    self.wordTextField.text = @"";
    
    if (!self.words) {
        self.words = [[NSMutableArray alloc]init];
        
        for (int i = 0; i < COUNT_WORDS; i++) {
            [self.words addObject:[[UIBackupWord alloc]initWithWord:nil position:i]];
        }
    }
    
    if (self.currentWord != -1 && self.currentWord < COUNT_WORDS) {
        UIBackupWord *backupWord = [self.words objectAtIndex:self.currentWord];
        [backupWord updateWord:word];
    }
            
    if ([self.restoreWordsDelegate respondsToSelector:@selector(updateWord:)]) {
        [self.restoreWordsDelegate updateWords:self.words];
    }
    
    if ([self isAllWordsCompleted]) {
        if ([self.restoreWordsDelegate respondsToSelector:@selector(didEnterAllWords)]) {
            [self.restoreWordsDelegate didEnterAllWords];
        }
        
        [self.wordTextField resignFirstResponder];
        self.positionLabel.hidden = YES;
    } else {
        [self nextCurrentWord];
        self.positionLabel.text = [NSString stringWithFormat:@"%d", self.currentWord + 1];
    }
    
    [self.wordsCollectionView reloadData];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    DDLogVerbose(@"%@ numberOfSectionsInCollectionView: %@", LOG_TAG, collectionView);
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ collectionView: %@ numberOfItemsInSection: %ld", LOG_TAG, collectionView, (long)section);
    
    return COUNT_WORDS;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ collectionView: %@ layout: %@ sizeForItemAtIndexPath: %@", LOG_TAG, collectionView, collectionViewLayout, indexPath);
    
    return CGSizeMake(Design.DISPLAY_WIDTH * 0.5f, DESIGN_WORD_HEIGHT * Design.HEIGHT_RATIO);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ collectionView: %@ cellForItemAtIndexPath: %@", LOG_TAG, collectionView, indexPath);
    
    RestoreWordCell *restoreWordCell = [collectionView dequeueReusableCellWithReuseIdentifier:RESTORE_WORD_CELL_IDENTIFIER forIndexPath:indexPath];

    UIBackupWord *backupWord = self.words[indexPath.row];
    
    if ([backupWord getWord]) {
        [restoreWordCell bind:backupWord currentWord:self.currentWord == indexPath.row];
    } else {
        [restoreWordCell bindWithPosition:(int)indexPath.row currentWord:self.currentWord == indexPath.row];
    }
    
    return restoreWordCell;
}

#pragma mark - UICollectionViewDataSource

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ collectionView: %@ didSelectItemAtIndexPath: %@", LOG_TAG, collectionView, indexPath);
    
    self.currentWord = (int) indexPath.row;
    self.wordCompletionView.hidden = YES;
    self.wordTextField.text = @"";
    self.positionLabel.hidden = NO;
    self.positionLabel.text = [NSString stringWithFormat:@"%d", self.currentWord + 1];
    [self.wordsCollectionView reloadData];
    
    if (![self.wordTextField isFirstResponder]) {
        [self.wordTextField becomeFirstResponder];
    }
}

- (void)handleCopyWordsTapGesture:(UITapGestureRecognizer *)sender {
    DDLogVerbose(@"%@ handleCopyWordsTapGesture: %@", LOG_TAG, sender);
    
    if (sender.state == UIGestureRecognizerStateEnded && [self.restoreWordsDelegate respondsToSelector:@selector(didTapPasteWords)]) {
        [self.restoreWordsDelegate didTapPasteWords];
    }
}

- (BOOL)isAllWordsCompleted {
    DDLogVerbose(@"%@ isAllWordsCompleted", LOG_TAG);
    
    if (!self.words) {
        return NO;
    }
    
    for (UIBackupWord *backupWord in self.words) {
        if (![backupWord getWord]) {
            return NO;
        }
    }
    
    return YES;
}

- (void)nextCurrentWord {
    DDLogVerbose(@"%@ nextCurrentWord", LOG_TAG);
    
    for (int index = 0; index < self.words.count; index++) {
        UIBackupWord *backupWord = [self.words objectAtIndex:index];
        if (![backupWord getWord]) {
            self.currentWord = index;
            break;
        }
    }
}

- (void)updateColor {
    DDLogVerbose(@"%@ updateColor", LOG_TAG);
    
    self.contentView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    self.wordsCollectionView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    
    self.wordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:TwinmeLocalizedString(@"application_search_hint", nil) attributes:[NSDictionary dictionaryWithObject:Design.PLACEHOLDER_COLOR forKey:NSForegroundColorAttributeName]];
}


@end

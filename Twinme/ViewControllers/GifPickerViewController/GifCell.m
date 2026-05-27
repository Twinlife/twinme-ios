/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 */

#import "GifCell.h"
#import "GifItem.h"
#import "UIImage+Animated.h"

NSString * const GifCellReuseIdentifier = @"GifCell";

@interface GifCell ()
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, copy, nullable) NSURL *currentPreviewURL;
@end

@implementation GifCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.clipsToBounds = YES;
        self.contentView.layer.cornerRadius = 8.0;
        if (@available(iOS 13.0, *)) {
            self.contentView.backgroundColor = [UIColor secondarySystemBackgroundColor];
        } else {
            self.contentView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
        }

        _imageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        [self.contentView addSubview:_imageView];

        UIActivityIndicatorViewStyle style;
        if (@available(iOS 13.0, *)) {
            style = UIActivityIndicatorViewStyleMedium;
        } else {
            style = UIActivityIndicatorViewStyleGray;
        }
        _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:style];
        _spinner.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_spinner];
        [NSLayoutConstraint activateConstraints:@[
            [_spinner.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor],
            [_spinner.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor]
        ]];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.imageView.image = nil;
    self.currentPreviewURL = nil;
    [self.spinner stopAnimating];
}

- (void)configureWithGifItem:(GifItem *)gifItem {
    self.imageView.image = nil;
    self.currentPreviewURL = gifItem.previewURL;
    self.isAccessibilityElement = YES;
    self.accessibilityLabel = gifItem.contentDescription.length ? gifItem.contentDescription : @"GIF";
    self.accessibilityTraits = UIAccessibilityTraitImage | UIAccessibilityTraitButton;

    NSURL *requestedURL = gifItem.previewURL;
    if (!requestedURL) {
        return;
    }
    [self.spinner startAnimating];
    __weak typeof(self) weakSelf = self;
    [UIImage animatedImageWithURL:requestedURL completion:^(UIImage * _Nullable image, NSURL * _Nonnull imageURL) {
        typeof(self) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        // Ignore the result if the cell was reused for another GIF in the meantime.
        if (![strongSelf.currentPreviewURL isEqual:imageURL]) {
            return;
        }
        [strongSelf.spinner stopAnimating];
        strongSelf.imageView.image = image;
    }];
}

@end

/*
 *  Copyright (c) 2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 */

#import "GifPickerViewController.h"
#import "GifCell.h"
#import "GifItem.h"
#import "GifService.h"
#import "GifProvider.h"

static NSInteger const kGifPageLimit = 30;
static NSTimeInterval const kSearchDebounce = 0.35;
static CGFloat const kCellSpacing = 4.0;

@interface GifPickerViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate>

@property (nonatomic, strong) GifService *gifService;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong, nullable) UISegmentedControl *providerControl;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UILabel *attributionLabel;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UIActivityIndicatorView *footerSpinner;
@property (nonatomic, strong) UIView *downloadOverlay;

@property (nonatomic, strong) NSMutableArray<GifItem *> *items;
@property (nonatomic, copy, nullable) NSString *nextPosition;
@property (nonatomic, copy, nullable) NSString *currentQuery;
@property (nonatomic, assign) BOOL loading;
@property (nonatomic, assign) BOOL reachedEnd;
@property (nonatomic, assign) NSInteger requestGeneration;

@end

@implementation GifPickerViewController

- (instancetype)init {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _gifService = [GifService sharedService];
        _items = [NSMutableArray array];
    }
    return self;
}

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    if (@available(iOS 13.0, *)) {
        self.view.backgroundColor = [UIColor systemBackgroundColor];
    } else {
        self.view.backgroundColor = [UIColor whiteColor];
    }
    [self setupNavigationItem];
    [self setupSearchBar];
    [self setupProviderControlIfNeeded];
    [self setupCollectionView];
    [self setupAttributionLabel];
    [self setupMessageLabel];
    [self setupConstraints];

    if (!self.gifService.isConfigured) {
        [self showMessage:@"GIF search is not configured.\nAdd a Tenor or Giphy API key to Info.plist (TenorAPIKey / GiphyAPIKey)."];
        return;
    }
    [self updateAttribution];
    [self reloadFromStart];
}

- (void)setupNavigationItem {
    self.title = @"GIF";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                          target:self
                                                                                          action:@selector(cancelTapped)];
}

- (void)setupSearchBar {
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.translatesAutoresizingMaskIntoConstraints = NO;
    self.searchBar.delegate = self;
    self.searchBar.placeholder = @"Search GIFs";
    self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.searchBar.returnKeyType = UIReturnKeySearch;
    self.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [self.view addSubview:self.searchBar];
}

- (void)setupProviderControlIfNeeded {
    NSArray<id<GifProvider>> *providers = self.gifService.availableProviders;
    if (providers.count < 2) {
        return; // No switch needed when zero or one provider is configured.
    }
    NSMutableArray<NSString *> *titles = [NSMutableArray array];
    for (id<GifProvider> provider in providers) {
        [titles addObject:provider.displayName];
    }
    self.providerControl = [[UISegmentedControl alloc] initWithItems:titles];
    self.providerControl.translatesAutoresizingMaskIntoConstraints = NO;
    NSInteger selected = [providers indexOfObject:self.gifService.activeProvider];
    self.providerControl.selectedSegmentIndex = (selected == NSNotFound) ? 0 : selected;
    [self.providerControl addTarget:self action:@selector(providerChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.providerControl];
}

- (void)setupCollectionView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = kCellSpacing;
    layout.minimumLineSpacing = kCellSpacing;
    layout.sectionInset = UIEdgeInsetsMake(kCellSpacing, kCellSpacing, kCellSpacing, kCellSpacing);

    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.collectionView.alwaysBounceVertical = YES;
    [self.collectionView registerClass:[GifCell class] forCellWithReuseIdentifier:GifCellReuseIdentifier];
    [self.view addSubview:self.collectionView];
}

- (void)setupAttributionLabel {
    self.attributionLabel = [[UILabel alloc] init];
    self.attributionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.attributionLabel.font = [UIFont systemFontOfSize:11.0];
    self.attributionLabel.textAlignment = NSTextAlignmentCenter;
    if (@available(iOS 13.0, *)) {
        self.attributionLabel.textColor = [UIColor secondaryLabelColor];
    } else {
        self.attributionLabel.textColor = [UIColor grayColor];
    }
    [self.view addSubview:self.attributionLabel];
}

- (void)setupMessageLabel {
    self.messageLabel = [[UILabel alloc] init];
    self.messageLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.messageLabel.numberOfLines = 0;
    self.messageLabel.textAlignment = NSTextAlignmentCenter;
    self.messageLabel.font = [UIFont systemFontOfSize:15.0];
    if (@available(iOS 13.0, *)) {
        self.messageLabel.textColor = [UIColor secondaryLabelColor];
    } else {
        self.messageLabel.textColor = [UIColor grayColor];
    }
    self.messageLabel.hidden = YES;
    [self.view addSubview:self.messageLabel];
}

- (void)setupConstraints {
    UILayoutGuide *guide = self.view.safeAreaLayoutGuide;
    NSMutableArray<NSLayoutConstraint *> *constraints = [NSMutableArray array];

    [constraints addObjectsFromArray:@[
        [self.searchBar.topAnchor constraintEqualToAnchor:guide.topAnchor],
        [self.searchBar.leadingAnchor constraintEqualToAnchor:guide.leadingAnchor constant:4.0],
        [self.searchBar.trailingAnchor constraintEqualToAnchor:guide.trailingAnchor constant:-4.0]
    ]];

    NSLayoutYAxisAnchor *collectionTop = self.searchBar.bottomAnchor;
    if (self.providerControl) {
        [constraints addObjectsFromArray:@[
            [self.providerControl.topAnchor constraintEqualToAnchor:self.searchBar.bottomAnchor constant:4.0],
            [self.providerControl.leadingAnchor constraintEqualToAnchor:guide.leadingAnchor constant:12.0],
            [self.providerControl.trailingAnchor constraintEqualToAnchor:guide.trailingAnchor constant:-12.0]
        ]];
        collectionTop = self.providerControl.bottomAnchor;
    }

    [constraints addObjectsFromArray:@[
        [self.collectionView.topAnchor constraintEqualToAnchor:collectionTop constant:4.0],
        [self.collectionView.leadingAnchor constraintEqualToAnchor:guide.leadingAnchor],
        [self.collectionView.trailingAnchor constraintEqualToAnchor:guide.trailingAnchor],
        [self.collectionView.bottomAnchor constraintEqualToAnchor:self.attributionLabel.topAnchor constant:-2.0],

        [self.attributionLabel.leadingAnchor constraintEqualToAnchor:guide.leadingAnchor],
        [self.attributionLabel.trailingAnchor constraintEqualToAnchor:guide.trailingAnchor],
        [self.attributionLabel.bottomAnchor constraintEqualToAnchor:guide.bottomAnchor constant:-4.0],
        [self.attributionLabel.heightAnchor constraintEqualToConstant:16.0],

        [self.messageLabel.centerXAnchor constraintEqualToAnchor:self.collectionView.centerXAnchor],
        [self.messageLabel.centerYAnchor constraintEqualToAnchor:self.collectionView.centerYAnchor],
        [self.messageLabel.leadingAnchor constraintEqualToAnchor:guide.leadingAnchor constant:24.0],
        [self.messageLabel.trailingAnchor constraintEqualToAnchor:guide.trailingAnchor constant:-24.0]
    ]];

    [NSLayoutConstraint activateConstraints:constraints];
}

#pragma mark - Data loading

- (id<GifProvider>)activeProvider {
    return self.gifService.activeProvider;
}

- (void)reloadFromStart {
    self.requestGeneration += 1;
    NSInteger generation = self.requestGeneration;
    // Any in-flight request is now stale (its completion checks the generation
    // and bails out), so free the loading flag to let this request proceed.
    self.loading = NO;
    [self.items removeAllObjects];
    self.nextPosition = nil;
    self.reachedEnd = NO;
    [self.collectionView reloadData];
    [self loadNextPageForGeneration:generation firstPage:YES];
}

- (void)loadNextPageForGeneration:(NSInteger)generation firstPage:(BOOL)firstPage {
    id<GifProvider> provider = self.activeProvider;
    if (!provider || self.loading || self.reachedEnd) {
        return;
    }
    self.loading = YES;
    [self updateMessageVisibility];

    NSString *query = self.currentQuery;
    NSString *position = firstPage ? nil : self.nextPosition;
    __weak typeof(self) weakSelf = self;
    GifProviderCompletion completion = ^(NSArray<GifItem *> *items, NSString *next, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            typeof(self) strongSelf = weakSelf;
            if (!strongSelf || generation != strongSelf.requestGeneration) {
                return; // A newer request superseded this one.
            }
            strongSelf.loading = NO;
            if (error) {
                if (strongSelf.items.count == 0) {
                    [strongSelf showMessage:@"Could not load GIFs. Check your connection and API key."];
                }
                return;
            }
            [strongSelf appendItems:items firstPage:firstPage next:next];
        });
    };

    if (query.length) {
        [provider searchWithQuery:query limit:kGifPageLimit position:position completion:completion];
    } else {
        [provider fetchTrendingWithLimit:kGifPageLimit position:position completion:completion];
    }
}

- (void)appendItems:(NSArray<GifItem *> *)newItems firstPage:(BOOL)firstPage next:(NSString *)next {
    NSMutableArray<GifItem *> *toAdd = [NSMutableArray array];
    if (firstPage && self.currentQuery.length == 0) {
        // On the trending feed, surface recently sent GIFs first.
        [toAdd addObjectsFromArray:self.gifService.recentGifs];
    }
    for (GifItem *item in newItems) {
        if (![toAdd containsObject:item] && ![self.items containsObject:item]) {
            [toAdd addObject:item];
        }
    }
    [self.items addObjectsFromArray:toAdd];
    self.nextPosition = next;
    self.reachedEnd = (next == nil);
    [self.collectionView reloadData];
    [self updateMessageVisibility];
}

- (void)updateMessageVisibility {
    if (!self.gifService.isConfigured) {
        return;
    }
    if (self.items.count == 0 && !self.loading) {
        [self showMessage:self.currentQuery.length ? @"No GIFs found." : @""];
    } else {
        self.messageLabel.hidden = YES;
    }
}

- (void)showMessage:(NSString *)message {
    self.messageLabel.text = message;
    self.messageLabel.hidden = (message.length == 0);
}

- (void)updateAttribution {
    NSString *name = self.activeProvider.displayName ?: @"";
    self.attributionLabel.text = name.length ? [NSString stringWithFormat:@"Powered by %@", name] : @"";
}

#pragma mark - Actions

- (void)cancelTapped {
    if ([self.delegate respondsToSelector:@selector(gifPickerViewControllerDidCancel:)]) {
        [self.delegate gifPickerViewControllerDidCancel:self];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)providerChanged:(UISegmentedControl *)control {
    NSArray<id<GifProvider>> *providers = self.gifService.availableProviders;
    if (control.selectedSegmentIndex >= 0 && (NSUInteger)control.selectedSegmentIndex < providers.count) {
        self.gifService.activeProvider = providers[control.selectedSegmentIndex];
        [self updateAttribution];
        [self reloadFromStart];
    }
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(performSearch) object:nil];
    [self performSelector:@selector(performSearch) withObject:nil afterDelay:kSearchDebounce];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(performSearch) object:nil];
    [self performSearch];
    [searchBar resignFirstResponder];
}

- (void)performSearch {
    NSString *trimmed = [self.searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.currentQuery = trimmed.length ? trimmed : nil;
    [self reloadFromStart];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    GifCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:GifCellReuseIdentifier forIndexPath:indexPath];
    if (indexPath.item < (NSInteger)self.items.count) {
        [cell configureWithGifItem:self.items[indexPath.item]];
    }
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger columns = [self columnCountForWidth:CGRectGetWidth(collectionView.bounds)];
    CGFloat totalSpacing = kCellSpacing * (columns + 1);
    CGFloat side = floor((CGRectGetWidth(collectionView.bounds) - totalSpacing) / columns);
    if (side <= 0) {
        side = 100;
    }
    return CGSizeMake(side, side);
}

- (NSInteger)columnCountForWidth:(CGFloat)width {
    if (width >= 700) {
        return 5;
    }
    if (width >= 500) {
        return 4;
    }
    return 3;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item >= (NSInteger)self.items.count) {
        return;
    }
    [self.searchBar resignFirstResponder];
    GifItem *item = self.items[indexPath.item];
    [self downloadAndSendGif:item];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat distanceFromBottom = scrollView.contentSize.height - scrollView.contentOffset.y - scrollView.bounds.size.height;
    if (distanceFromBottom < scrollView.bounds.size.height && !self.loading && !self.reachedEnd) {
        [self loadNextPageForGeneration:self.requestGeneration firstPage:NO];
    }
}

#pragma mark - Selection / download

- (void)downloadAndSendGif:(GifItem *)item {
    [self showDownloadOverlay:YES];
    __weak typeof(self) weakSelf = self;
    [self.gifService downloadGif:item completion:^(NSString *localPath, NSError *error) {
        typeof(self) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        [strongSelf showDownloadOverlay:NO];
        if (error || localPath.length == 0) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                          message:@"Could not download this GIF."
                                                                   preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            [strongSelf presentViewController:alert animated:YES completion:nil];
            return;
        }
        [strongSelf.gifService addRecentGif:item];
        [strongSelf.delegate gifPickerViewController:strongSelf didSelectGifWithLocalPath:localPath gifItem:item];
    }];
}

- (void)showDownloadOverlay:(BOOL)show {
    if (show) {
        if (!self.downloadOverlay) {
            UIView *overlay = [[UIView alloc] initWithFrame:self.view.bounds];
            overlay.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            overlay.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.25];
            UIActivityIndicatorViewStyle style;
            if (@available(iOS 13.0, *)) {
                style = UIActivityIndicatorViewStyleLarge;
            } else {
                style = UIActivityIndicatorViewStyleWhiteLarge;
            }
            UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:style];
            spinner.center = overlay.center;
            spinner.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
            [spinner startAnimating];
            [overlay addSubview:spinner];
            self.downloadOverlay = overlay;
        }
        [self.view addSubview:self.downloadOverlay];
        self.view.userInteractionEnabled = NO;
    } else {
        [self.downloadOverlay removeFromSuperview];
        self.view.userInteractionEnabled = YES;
    }
}

- (void)dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

@end

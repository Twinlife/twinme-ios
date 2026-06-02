/*
 *  Copyright (c) 2025-2026 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import "FAQViewController.h"

#import "SettingsSectionHeaderCell.h"
#import "FAQCell.h"
#import "FAQArticleView.h"

#import "WebViewController.h"
#import "FeedBackViewController.h"

#import <TwinmeCommon/Design.h>
#import <TwinmeCommon/FAQManager.h>
#import <TwinmeCommon/UIFAQArticle.h>
#import <TwinmeCommon/UIFAQCategory.h>

#import <Utils/NSString+Utils.h>


#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static NSString *SECTION_CELL_IDENTIFIER = @"HeaderSettingsCellIdentifier";
static NSString *FAQ_CELL_IDENTIFIER = @"FAQCellIdentifier";
static int CONNECT_PEOPLE_ARTICLE_ID = 9;


//
// Interface: FAQViewController
//

@interface FAQViewController ()<UITableViewDelegate, UITableViewDataSource, FAQArticleViewDelegate, UISearchResultsUpdating>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@property (nonatomic) NSMutableArray<UIFAQCategory *> *faqCategories;
@property (nonatomic) NSMutableArray<UIFAQCategory *> *filteredFAQCategories;
@property (nonatomic) UISearchController *searchController;

@end

//
// Implementation: FAQViewController
//

#undef LOG_TAG
#define LOG_TAG @"FAQViewController"

@implementation FAQViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _faqCategories = [[NSMutableArray alloc]init];
        _filteredFAQCategories = [[NSMutableArray alloc]init];
    }
    return self;
}

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
    
    [self initViews];
    [self loadFAQ];
}

- (void)viewWillAppear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillAppear: %@", LOG_TAG, animated ? @"YES" : @"NO");
    
    [super viewWillAppear:animated];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    DDLogVerbose(@"%@ numberOfSectionsInTableView: %@", LOG_TAG, tableView);
    
    return [self faqCategoriesArray].count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
    DDLogVerbose(@"%@ tableView: %@ heightForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    return Design.CELL_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ heightForHeaderInSection: %ld", LOG_TAG, tableView, (long)section);
    
    return Design.SETTING_SECTION_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ heightForFooterInSection: %ld", LOG_TAG, tableView, (long)section);
    
    return CGFLOAT_MIN;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ numberOfRowsInSection: %ld", LOG_TAG, tableView, (long)section);
    
    UIFAQCategory *faqCategory = [[self faqCategoriesArray] objectAtIndex:section];
    return faqCategory.articles.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ viewForHeaderInSection: %ld", LOG_TAG, tableView, (long)section);
    
    SettingsSectionHeaderCell *settingsSectionHeaderCell = (SettingsSectionHeaderCell *)[tableView dequeueReusableCellWithIdentifier:SECTION_CELL_IDENTIFIER];
    if (!settingsSectionHeaderCell) {
        settingsSectionHeaderCell = [[SettingsSectionHeaderCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SECTION_CELL_IDENTIFIER];
    }
    
    UIFAQCategory *faqCategory = [[self faqCategoriesArray] objectAtIndex:section];
    [settingsSectionHeaderCell bindWithTitle:faqCategory.title backgroundColor:Design.LIGHT_GREY_BACKGROUND_COLOR hideSeparator:NO uppercaseString:YES];
    return settingsSectionHeaderCell;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ cellForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    FAQCell *cell = [tableView dequeueReusableCellWithIdentifier:FAQ_CELL_IDENTIFIER];
    if (!cell) {
        cell = [[FAQCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:FAQ_CELL_IDENTIFIER];
    }
    
    UIFAQCategory *faqCategory = [[self faqCategoriesArray] objectAtIndex:indexPath.section];
    UIFAQArticle *faqArticle = [faqCategory.articles objectAtIndex:indexPath.row];
    
    BOOL hideSeparator = indexPath.row == faqCategory.articles.count - 1;
    [cell bindWithArticle:faqArticle hideSeparator:hideSeparator];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ didSelectRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    UIFAQCategory *faqCategory = [[self faqCategoriesArray] objectAtIndex:indexPath.section];
    UIFAQArticle *faqArticle = [faqCategory.articles objectAtIndex:indexPath.row];
    
    [self showArticle:faqArticle];
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    DDLogVerbose(@"%@ updateSearchResultsForSearchController: %@", LOG_TAG, searchController);
    
    [self searchInFAQ:searchController.searchBar.text];
    [self.tableView reloadData];
}

#pragma mark - FAQArticleViewDelegate

- (void)didTapOnFAQLink:(nonnull NSString *)link faqArticleView:(nonnull FAQArticleView *)faqArticleView {
    DDLogVerbose(@"%@ didTapOnFAQLink: %@ faqArticleView: %@", LOG_TAG, link, faqArticleView);
    
    [faqArticleView closeConfirmView];
    
    if ([link isEqual:PRIVACY_POLICY_LINK]) {
        WebViewController *webViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
        webViewController.fileName = TwinmeLocalizedString(@"privacy_policy_url", nil);
        webViewController.name = TwinmeLocalizedString(@"about_view_privacy_policy", nil);
        [self.navigationController pushViewController:webViewController animated:YES];
    } else if ([link isEqual:CONTACT_LINK]) {
        FeedbackViewController *feedbackViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FeedbackViewController"];
        [self.navigationController pushViewController:feedbackViewController animated:YES];
    } else if ([link isEqual:CONNECT_PEOPLE_LINK]) {
        [self getFAQArticle:CONNECT_PEOPLE_ARTICLE_ID];
    }
}


- (void)didTapConfirm:(nonnull AbstractBottomSheetView *)abstractBottomSheetView {
    DDLogVerbose(@"%@ didTapConfirm: %@", LOG_TAG, abstractBottomSheetView);
    
    [abstractBottomSheetView closeConfirmView];
}

- (void)didTapCancel:(nonnull AbstractBottomSheetView *)abstractBottomSheetView {
    DDLogVerbose(@"%@ didTapCancel: %@", LOG_TAG, abstractBottomSheetView);
    
    [abstractBottomSheetView closeConfirmView];
}

- (void)didClose:(nonnull AbstractBottomSheetView *)abstractBottomSheetView {
    DDLogVerbose(@"%@ didClose: %@", LOG_TAG, abstractBottomSheetView);
    
    [abstractBottomSheetView closeConfirmView];
}

- (void)didFinishCloseAnimation:(nonnull AbstractBottomSheetView *)abstractBottomSheetView {
    DDLogVerbose(@"%@ didFinishCloseAnimation: %@", LOG_TAG, abstractBottomSheetView);
        
    [abstractBottomSheetView removeFromSuperview];
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.view.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    
    [self setNavigationTitle:TwinmeLocalizedString(@"navigation_view_faq", nil)];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"FAQCell" bundle:nil] forCellReuseIdentifier:FAQ_CELL_IDENTIFIER];
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsSectionHeaderCell" bundle:nil] forCellReuseIdentifier:SECTION_CELL_IDENTIFIER];
    self.tableView.backgroundColor = Design.LIGHT_GREY_BACKGROUND_COLOR;
    
    self.searchController = [[UISearchController alloc]initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.searchBar.searchBarStyle = UISearchBarStyleProminent;
    self.searchController.obscuresBackgroundDuringPresentation = NO;
    self.searchController.searchBar.placeholder = TwinmeLocalizedString(@"application_search_hint", nil);
    self.searchController.searchBar.backgroundColor = [UIColor clearColor];
    self.searchController.searchBar.searchTextField.backgroundColor = Design.POPUP_BACKGROUND_COLOR;
    self.searchController.searchBar.searchTextField.tintColor = [UIColor darkGrayColor];
    self.searchController.searchBar.translucent = NO;
    self.navigationItem.hidesSearchBarWhenScrolling = NO;
    self.navigationItem.searchController = self.searchController;

    self.definesPresentationContext = YES;
    
    self.activityIndicatorView.hidesWhenStopped = YES;
}

- (void)loadFAQ {
    DDLogVerbose(@"%@ loadFAQ", LOG_TAG);
    
    [self.activityIndicatorView startAnimating];
    
    FAQManager *faqManager = [[FAQManager alloc]init];
    [faqManager loadFAQWithCompletion:^(NSArray<UIFAQCategory *>  * _Nullable faqCategories, NSError * _Nullable error) {
        if (!error) {
            [self.faqCategories removeAllObjects];
            
            if (faqCategories) {
                [self.faqCategories addObjectsFromArray:faqCategories];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self searchInFAQ:self.searchController.searchBar.text];
                [self.activityIndicatorView stopAnimating];
                [self.tableView reloadData];
            });
        }
    }];
}

- (NSArray<UIFAQCategory *> *)faqCategoriesArray {
    
    return [self isFilteringFAQ] ? self.filteredFAQCategories : self.faqCategories;
}

- (BOOL)isFilteringFAQ {
    
    NSString *term = [self.searchController.searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return term && ![term isEqualToString:@""];
}

- (void)searchInFAQ:(nullable NSString *)text {
    
    [self.filteredFAQCategories removeAllObjects];
    NSString *searchText = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (!searchText || [searchText isEqualToString:@""]) {
        return;
    }

    for (UIFAQCategory *faqCategory in self.faqCategories) {
        
        NSMutableArray<UIFAQArticle *> *filteredArticles = [[NSMutableArray alloc] init];
        for (UIFAQArticle *faqArticle in faqCategory.articles) {
            if ([faqArticle containsSearchText:searchText]) {
                [filteredArticles addObject:faqArticle];
            }
        }

        if (filteredArticles.count > 0) {
            UIFAQCategory *filteredCategory = [[UIFAQCategory alloc] initWithTitle:faqCategory.title articles:filteredArticles];
            [self.filteredFAQCategories addObject:filteredCategory];
        }
    }
}

- (void)showArticle:(UIFAQArticle *)faqArticle {
    DDLogVerbose(@"%@ showArticle: %@", LOG_TAG, faqArticle);
    
    [self.searchController.searchBar resignFirstResponder];
    
    FAQArticleView *faqArticleView = [[FAQArticleView alloc]init];
    [faqArticleView initWithFAQArticle:faqArticle];
    faqArticleView.faqArticleViewDelegate = self;
    faqArticleView.bottomSheetViewDelegate = self;
    [self.navigationController.view addSubview:faqArticleView];
    [faqArticleView showConfirmView];
}

- (void)getFAQArticle:(int)faqArticleId {
    DDLogVerbose(@"%@ getFAQArticle: %d", LOG_TAG, faqArticleId);
    
    for (UIFAQCategory *faqCategory in self.faqCategories) {
        for (UIFAQArticle *faqArticle in faqCategory.articles) {
            if (faqArticle.articleId == faqArticleId) {
                [self showArticle:faqArticle];
                return;
            }
        }
    }
}

- (void)updateFont {
    DDLogVerbose(@"%@ updateFont", LOG_TAG);
    
    [self.tableView reloadData];
}

@end

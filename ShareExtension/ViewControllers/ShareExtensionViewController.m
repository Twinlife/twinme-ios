/*
 *  Copyright (c) 2021-2025 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 *   Stephane Carrez (Stephane.Carrez@twin.life)
 */

#import <CocoaLumberjack.h>

#import <MobileCoreServices/UTCoreTypes.h>
#import <MobileCoreServices/UTType.h>

#import <WebRTC/RTCLogging.h>
#import <WebRTC/RTCSSLAdapter.h>

#import <Twinlife/TLTwinlife.h>
#import <Twinme/TLTwinmeAttributes.h>
#import <Twinme/TLMessage.h>
#import <Twinme/TLTyping.h>
#import <Twinme/TLOriginator.h>
#import <Twinme/TLContact.h>
#import <Twinme/TLSpace.h>
#import <Twinme/TLGroup.h>
#import <Twinme/TLTwinmeApplication.h>
#import <Twinme/TLTwinmeContext.h>

#import <UIKit/UIKit.h>

#import "ShareExtensionViewController.h"
#import <Utils/NSString+Utils.h>

#import "ShareExtensionContactCell.h"
#import "ShareExtensionHeaderCell.h"

#import "DesignExtension.h"

#import "ShareExtensionService.h"

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

#define DATA_CHUNK_SIZE (64 * 1024)
#define PROPERTY_DEFAULT_MESSAGE_SETTINGS @"DefaultMessageSettings"

@interface UIContact : NSObject

@property (nonatomic, nonnull) id<TLOriginator> contact;
@property (nonatomic, nonnull) NSString *name;
@property (nonatomic, nonnull) UIImage *avatar;

- (nonnull instancetype)initWithContact:(nonnull id<TLOriginator>)contact;

- (void)setContact:(nonnull id<TLOriginator>)contact;

- (void)updateAvatar:(nonnull UIImage *)avatar;

- (BOOL)isCertified;

@end

@implementation UIContact : NSObject

- (instancetype)initWithContact:(id<TLOriginator>)contact {
    
    self = [super init];
    
    if (self) {
        _contact = contact;
        _name = _contact.name;
        _avatar = [TLContact ANONYMOUS_AVATAR];
    }
    return self;
}

- (void)setContact:(id<TLOriginator>)contact {
    
    _contact = contact;
    
    self.name = _contact.name;
}

- (void)updateAvatar:(UIImage *)avatar {
    
    self.avatar = avatar;
}

- (BOOL)isCertified {
    
    if ([(NSObject *)self.contact isKindOfClass:[TLContact class]]) {
        TLContact *c = (TLContact *)self.contact;
        return [c certificationLevel] == TLCertificationLevel4;
    } else {
        return NO;
    }
}

@end

static NSString *SHARE_EXTENSION_CONTACT_CELL_IDENTIFIER = @"ShareExtensionContactCellIdentifier";
static NSString *SHARE_EXTENSION_HEADER_CELL_IDENTIFIER = @"ShareExtensionHeaderCellIdentifier";

static CGFloat DESIGN_SECTION_HEIGHT = 110;
static CGFloat DESIGN_CELL_HEIGHT = 124;

static const int SHARE_VIEW_SECTION_COUNT = 2;

static const int CONTACTS_VIEW_SECTION = 0;
static const int GROUPS_VIEW_SECTION = 1;

//
// Interface: ShareExtensionViewController
//

@interface ShareExtensionViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, ShareExtensionServiceDelegate>

@property (weak, nonatomic) IBOutlet UITableView *contactsTableView;
@property (nonatomic) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic) UIBarButtonItem *cancelBarButtonItem;
@property (nonatomic) UISearchController *searchController;

@property (nonatomic) BOOL uiInitialized;
@property (nonatomic) NSMutableArray *uiContacts;
@property (nonatomic) NSMutableArray *uiGroups;

@property (nonatomic) NSMutableArray *contents;
@property (nonatomic) BOOL fileCopyAllowed;
@property (nonatomic) BOOL messageCopyAllowed;
@property (nonatomic) BOOL refreshTableScheduled;

@property (nonatomic) NSIndexPath *selectedIndexPath;
@property (nonatomic) ShareExtensionService *shareService;
@property (nonatomic) id<TLOriginator> contact;

@property (nonatomic) int currentItem;

@end

//
// Implementation: ShareExtensionViewController
//

#undef LOG_TAG
#define LOG_TAG @"ShareExtensionViewController"

@implementation ShareExtensionViewController

#pragma mark - UIViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    DDLogVerbose(@"%@ initWithCoder: %@", LOG_TAG, coder);
    
    self = [super initWithCoder:coder];
    
    if (self) {
        _uiContacts = [[NSMutableArray alloc] init];
        _uiGroups = [[NSMutableArray alloc] init];
        _fileCopyAllowed = NO;
        _messageCopyAllowed = NO;
        _refreshTableScheduled = NO;
        _currentItem = 0;
        _contents = [[NSMutableArray alloc]init];
        _shareService = [ShareExtensionService instance];
        _shareService.shareExtensionServiceDelegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
    
    [self initViews];
}

- (void)viewWillAppear:(BOOL)animated {
    DDLogVerbose(@"%@ viewWillAppear: %@", LOG_TAG, animated ? @"YES":@"NO");
    
    [super viewWillAppear:animated];
    [self.shareService start];
}

#pragma mark - ShareExtensionServiceDelegate

- (void)onGetContacts:(NSArray<TLContact *> *)contacts {
    DDLogVerbose(@"%@ onGetContacts: %@", LOG_TAG, contacts);
    
    self.refreshTableScheduled = YES;
    [self.uiContacts removeAllObjects];
    for (TLContact *contact in contacts) {
        [self updateUIContact:contact avatar:nil];
    }
    [self reloadContactTableData];
}

- (void)onUpdateContact:(nonnull TLContact *)contact avatar:(nonnull UIImage *)avatar {
    DDLogVerbose(@"%@ onUpdateContact: %@ avatar: %@", LOG_TAG, contact, avatar);
    
    self.refreshTableScheduled = YES;
    [self updateUIContact:contact avatar:avatar];
    [self reloadContactTableData];
}

- (void)onGetGroups:(NSArray *)groups {
    DDLogVerbose(@"%@ onGetGroups: %@", LOG_TAG, groups);
    
    self.refreshTableScheduled = YES;
    [self.uiGroups removeAllObjects];
    for (TLGroup *group in groups) {
        if ([self.shareService hasConversationActive:group]) {
            [self updateUIGroup:group avatar:nil];
        }
    }
    [self reloadContactTableData];
}

- (void)onUpdateGroup:(nonnull TLGroup *)group avatar:(nonnull UIImage *)avatar {
    DDLogVerbose(@"%@ onUpdateGroup: %@ avatar: %@", LOG_TAG, group, avatar);
    
    self.refreshTableScheduled = YES;
    if ([self.shareService hasConversationActive:group]) {
        [self updateUIGroup:group avatar:avatar];
    }
    [self reloadContactTableData];
}

- (void)onGetConversation:(id<TLConversation>)conversation {
    DDLogVerbose(@"%@ onGetConversation: %@", LOG_TAG, conversation);
    
    if (self.contents.count > 0) {
        
        for (id object in self.contents) {
            if ([object isKindOfClass:[NSString class]]) {
                NSString *message = (NSString *)object;
                [self.shareService pushMessage:message copyAllowed:self.messageCopyAllowed];
            } else if ([object isKindOfClass:[NSURL class]]) {
                NSURL *url = (NSURL *)object;
                
                if ([self isImageFile:url.path]) {
                    [self.shareService pushFileWithPath:url.path type:TLDescriptorTypeImageDescriptor toBeDeleted:YES copyAllowed:self.fileCopyAllowed];
                } else  if ([self isVideoFile:url.path]) {
                    [self.shareService pushFileWithPath:url.path type:TLDescriptorTypeVideoDescriptor toBeDeleted:YES copyAllowed:self.fileCopyAllowed];
                } else  if ([self isAudioFile:url.path]) {
                    [self.shareService pushFileWithPath:url.path type:TLDescriptorTypeAudioDescriptor toBeDeleted:YES copyAllowed:self.fileCopyAllowed];
                } else {
                    [self.shareService pushFileWithPath:url.path type:TLDescriptorTypeNamedFileDescriptor toBeDeleted:YES copyAllowed:self.messageCopyAllowed];
                }
            }
        }
    }
}

-(BOOL)openURL:(NSURL *)url {
    DDLogVerbose(@"%@ openURL: %@", LOG_TAG, url);
    
    UIResponder * responder = self;
    while (responder != nil) {
        if ([responder isKindOfClass:[UIApplication class]]) {
            UIApplication * application = (UIApplication *) responder;
            if (application != nil) {
                [application openURL:url options:@{} completionHandler:nil];
                return YES;
            }
        }
        responder = [responder nextResponder];
    }
    
    return NO;
}

- (void)onShareCompleted {
    DDLogVerbose(@"%@ onShareCompleted", LOG_TAG);
    
    [self.activityIndicatorView stopAnimating];
    [self openURL:[self.shareService getConversationURLWithOriginator:self.contact]];
    
    [self.uiContacts removeAllObjects];
    [self.uiGroups removeAllObjects];
    [self refreshTable];
    self.contact = nil;
    
    // Stop the twinlife framework and acknowledge the shared content only when we are ready to suspend.
    [self.shareService stopWithCompletionHandler:^(TLBaseServiceErrorCode errorCode) {
        [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
    }];
}

#pragma mark - Private

- (void)updateUIContact:(TLContact *)contact avatar:(nullable UIImage *)avatar {
    DDLogVerbose(@"%@ updateUIContact: %@ avatar: %@", LOG_TAG, contact, avatar);
    
    UIContact *uiContact = nil;
    for (UIContact *lUIContact in self.uiContacts) {
        if ([lUIContact.contact.uuid isEqual:contact.uuid]) {
            uiContact = lUIContact;
            break;
        }
    }
    
    // TBD Sort using id order when name are equals
    if (uiContact)  {
        [self.uiContacts removeObject:uiContact];
        [uiContact setContact:contact];
    } else {
        uiContact = [[UIContact alloc] initWithContact:contact];
    }
    if (!avatar && [contact hasPeer]) {
        [self.shareService getImageWithContact:contact withBlock:^(UIImage *image) {
            [uiContact updateAvatar:image];
            [self refreshTable];
        }];
    } else if (avatar) {
        [uiContact updateAvatar:avatar];
    }
    
    BOOL added = NO;
    NSInteger count = self.uiContacts.count;
    for (NSInteger i = 0; i < count; i++) {
        UIContact *lUIContact = self.uiContacts[i];
        if ([lUIContact.name caseInsensitiveCompare:uiContact.name] == NSOrderedDescending) {
            [self.uiContacts insertObject:uiContact atIndex:i];
            added = YES;
            break;
        }
    }
    if (!added) {
        [self.uiContacts addObject:uiContact];
    }
}

- (void)updateUIGroup:(nonnull TLGroup *)group avatar:(nullable UIImage *)avatar {
    DDLogVerbose(@"%@ updateUIGroup: %@ avatar: %@", LOG_TAG, group, avatar);
    
    UIContact *uiContact = nil;
    for (UIContact *lUIContact in self.uiGroups) {
        if ([lUIContact.contact.uuid isEqual:group.uuid]) {
            uiContact = lUIContact;
            break;
        }
    }
    
    // TBD Sort using id order when name are equals
    if (uiContact)  {
        [self.uiGroups removeObject:uiContact];
        [uiContact setContact:group ];
    } else {
        uiContact = [[UIContact alloc] initWithContact:group];
    }
    if (!avatar) {
        [self.shareService getImageWithGroup:group withBlock:^(UIImage *image) {
            [uiContact updateAvatar:image];
            [self refreshTable];
        }];
    } else {
        [uiContact updateAvatar:avatar];
    }
    
    BOOL added = NO;
    NSInteger count = self.uiGroups.count;
    for (NSInteger i = 0; i < count; i++) {
        UIContact *lUIContact = self.uiGroups[i];
        if ([lUIContact.name caseInsensitiveCompare:uiContact.name] == NSOrderedDescending) {
            [self.uiGroups insertObject:uiContact atIndex:i];
            added = YES;
            break;
        }
    }
    if (!added) {
        [self.uiGroups addObject:uiContact];
    }
}

- (void)reloadContactTableData {
    DDLogVerbose(@"%@ reloadContactTableData", LOG_TAG);
    
    self.refreshTableScheduled = NO;
    [self.contactsTableView reloadData];
}

- (void)refreshTable {
    DDLogVerbose(@"%@ refreshTable", LOG_TAG);
    
    // Schedule only one table reload for possibly several asynchronous fetch of images.
    if (!self.refreshTableScheduled) {
        self.refreshTableScheduled = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadContactTableData];
        });
    }
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    DDLogVerbose(@"%@ searchBar: %@ textDidChange: %@", LOG_TAG, searchBar, searchText);
    
    [self.uiContacts removeAllObjects];
    [self.uiGroups removeAllObjects];
    [self refreshTable];
    
    if (![searchText isEqualToString:@""]) {
        [self.shareService findContactsAndGroupsByName:searchText];
    } else {
        [self.shareService getContactsAndGroups];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    DDLogVerbose(@"%@ searchBarCancelButtonClicked: %@", LOG_TAG, searchBar);
    
    [self.shareService getContactsAndGroups];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    DDLogVerbose(@"%@ numberOfSectionsInTableView: %@", LOG_TAG, tableView);
    
    return SHARE_VIEW_SECTION_COUNT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ numberOfRowsInSection: %ld", LOG_TAG, tableView, (long)section);
    
    if (section == CONTACTS_VIEW_SECTION) {
        return self.uiContacts.count;
    } else if (section == GROUPS_VIEW_SECTION) {
        return self.uiGroups.count;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ heightForHeaderInSection: %ld", LOG_TAG, tableView, (long)section);
    
    switch (section) {
        case CONTACTS_VIEW_SECTION:
            if (self.uiContacts.count > 0) {
                return DESIGN_SECTION_HEIGHT * DesignExtension.HEIGHT_RATIO;
            }
            break;
            
        case GROUPS_VIEW_SECTION:
            if (self.uiGroups.count > 0) {
                return DESIGN_SECTION_HEIGHT * DesignExtension.HEIGHT_RATIO;
            }
            break;
            
        default:
            break;
    }
    
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
    
    return DesignExtension.HEIGHT_RATIO * DESIGN_CELL_HEIGHT;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ viewForHeaderInSection: %ld", LOG_TAG, tableView, (long)section);
    
    ShareExtensionHeaderCell *shareExtensionHeaderCell = (ShareExtensionHeaderCell *)[tableView dequeueReusableCellWithIdentifier:SHARE_EXTENSION_HEADER_CELL_IDENTIFIER];
    if (!shareExtensionHeaderCell) {
        shareExtensionHeaderCell = [[ShareExtensionHeaderCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SHARE_EXTENSION_HEADER_CELL_IDENTIFIER];
    }
    
    NSString *sectionName = @"";
    switch (section) {
        case CONTACTS_VIEW_SECTION: {
            if (self.uiContacts.count > 0)
                sectionName = TwinmeLocalizedString(@"share_view_controller_contact_list_title", nil);
        }
            break;
            
        case GROUPS_VIEW_SECTION:
            if (self.uiGroups.count > 0) {
                sectionName = TwinmeLocalizedString(@"share_view_controller_group_list_title", nil);
            }
            break;
            
        default:
            break;
    }
    
    [shareExtensionHeaderCell bindWithTitle:sectionName];
    
    return shareExtensionHeaderCell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ tableView: %@ titleForHeaderInSection: %ld", LOG_TAG, tableView, (long)section);
    
    NSString *sectionName = @"";
    switch (section) {
        case CONTACTS_VIEW_SECTION:
            if (self.uiContacts.count > 0) {
                sectionName = TwinmeLocalizedString(@"share_view_controller_contact_list_title", nil);
            }
            break;
            
        case GROUPS_VIEW_SECTION:
            if (self.uiGroups.count > 0) {
                sectionName = TwinmeLocalizedString(@"share_view_controller_group_list_title", nil);
            }
            break;
            
        default:
            break;
    }
    return sectionName;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ cellForRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    ShareExtensionContactCell *shareExtensionCell = (ShareExtensionContactCell *)[tableView dequeueReusableCellWithIdentifier:SHARE_EXTENSION_CONTACT_CELL_IDENTIFIER];
    if (!shareExtensionCell) {
        shareExtensionCell = [[ShareExtensionContactCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SHARE_EXTENSION_CONTACT_CELL_IDENTIFIER];
    }
    
    if (indexPath.section == CONTACTS_VIEW_SECTION) {
        if (indexPath.row < self.uiContacts.count) {
            UIContact *uiContact = [self.uiContacts objectAtIndex:indexPath.row];
            BOOL hideSeparator = indexPath.row + 1 == self.uiContacts.count ? YES : NO;
            [shareExtensionCell bindWithName:uiContact.name avatar:uiContact.avatar isCertified:uiContact.isCertified hideSeparator:hideSeparator];
        }
    } else {
        if (indexPath.row < self.uiGroups.count) {
            UIContact *uiGroup = [self.uiGroups objectAtIndex:indexPath.row];
            BOOL hideSeparator = indexPath.row + 1 == self.uiGroups.count ? YES : NO;
            [shareExtensionCell bindWithName:uiGroup.name avatar:uiGroup.avatar isCertified:NO hideSeparator:hideSeparator];
        }
    }
    
    return shareExtensionCell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ tableView: %@ didSelectRowAtIndexPath: %@", LOG_TAG, tableView, indexPath);
    
    if (!self.selectedIndexPath) {
        self.selectedIndexPath = indexPath;
        [self.activityIndicatorView startAnimating];
        [self loadItem];
    }
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    UIColor *backgroundColor = DesignExtension.NAVIGATION_BACKGROUND_COLOR;
    
    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *navBarAppearance = [self.navigationController.navigationBar standardAppearance];
        [navBarAppearance configureWithOpaqueBackground];
        navBarAppearance.titleTextAttributes = @{NSFontAttributeName: DesignExtension.FONT_BOLD34, NSForegroundColorAttributeName: [UIColor whiteColor]};
        navBarAppearance.largeTitleTextAttributes = @{NSFontAttributeName: DesignExtension.FONT_BOLD68, NSForegroundColorAttributeName: [UIColor whiteColor]};
        navBarAppearance.backgroundColor = backgroundColor;
        self.navigationController.navigationBar.standardAppearance = navBarAppearance;
        self.navigationController.navigationBar.scrollEdgeAppearance = navBarAppearance;
        self.navigationController.navigationBar.compactAppearance = navBarAppearance;
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    } else {
        self.navigationController.navigationBar.translucent = NO;
        self.navigationController.navigationBar.barTintColor = backgroundColor;
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        self.navigationController.navigationBar.backgroundColor = backgroundColor;
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName: DesignExtension.FONT_REGULAR34, NSForegroundColorAttributeName: [UIColor whiteColor]}];
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName: DesignExtension.FONT_BOLD34, NSForegroundColorAttributeName: [UIColor whiteColor]}];
    }
    
    self.navigationItem.title = TwinmeLocalizedString(@"application_name", nil).capitalizedString;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.cancelBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:TwinmeLocalizedString(@"application_cancel", nil) style:UIBarButtonItemStylePlain target:self action:@selector(handleCancelTapGesture:)];
    [self.cancelBarButtonItem setTitleTextAttributes: @{NSFontAttributeName: DesignExtension.FONT_REGULAR34, NSForegroundColorAttributeName: [UIColor whiteColor]} forState:UIControlStateNormal];
    [self.cancelBarButtonItem setTitleTextAttributes: @{NSFontAttributeName: DesignExtension.FONT_REGULAR34, NSForegroundColorAttributeName: [UIColor colorWithWhite:1.0 alpha:0.5]} forState:UIControlStateDisabled];
    self.navigationItem.leftBarButtonItem = self.cancelBarButtonItem;
    self.navigationItem.hidesSearchBarWhenScrolling = NO;
    
    self.searchController = [[UISearchController alloc]initWithSearchResultsController:nil];
    self.searchController.searchBar.placeholder = TwinmeLocalizedString(@"application_search_hint", nil);
    
    UISearchBar *contactSearchBar = self.searchController.searchBar;
    contactSearchBar.barStyle = UIBarStyleDefault;
    contactSearchBar.searchBarStyle = UISearchBarStyleProminent;
    contactSearchBar.translucent = NO;
    contactSearchBar.barTintColor = DesignExtension.NAVIGATION_BACKGROUND_COLOR;
    contactSearchBar.tintColor = [UIColor whiteColor];
    contactSearchBar.placeholder = TwinmeLocalizedString(@"application_search_hint", nil);
    contactSearchBar.backgroundImage = [UIImage new];
    contactSearchBar.backgroundColor = DesignExtension.NAVIGATION_BACKGROUND_COLOR;
    contactSearchBar.delegate = self;
    
    if (@available(iOS 13.0, *)) {
        self.searchController.searchBar.backgroundColor = [UIColor whiteColor];
        self.searchController.searchBar.searchTextField.backgroundColor = DesignExtension.POPUP_BACKGROUND_COLOR;
        self.searchController.searchBar.searchTextField.tintColor = DesignExtension.FONT_COLOR_DEFAULT;
        self.searchController.searchBar.searchTextField.textColor = DesignExtension.FONT_COLOR_DEFAULT;
        self.searchController.searchBar.translucent = NO;
        self.navigationItem.searchController = self.searchController;
    } else {
        self.contactsTableView.tableHeaderView = self.searchController.searchBar;
        self.searchController.searchBar.backgroundColor = DesignExtension.NAVIGATION_BACKGROUND_COLOR;
    }
    
    self.contactsTableView.backgroundColor = DesignExtension.LIGHT_GREY_BACKGROUND_COLOR;
    self.contactsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.contactsTableView.tableFooterView = nil;
    self.contactsTableView.delegate = self;
    self.contactsTableView.dataSource = self;
    self.contactsTableView.sectionHeaderHeight = 0;
    self.contactsTableView.sectionFooterHeight = 0;
    
    [self.contactsTableView registerNib:[UINib nibWithNibName:@"ShareExtensionContactCell" bundle:nil] forCellReuseIdentifier:SHARE_EXTENSION_CONTACT_CELL_IDENTIFIER];
    [self.contactsTableView registerNib:[UINib nibWithNibName:@"ShareExtensionHeaderCell" bundle:nil] forCellReuseIdentifier:SHARE_EXTENSION_HEADER_CELL_IDENTIFIER];
    
    if (@available(iOS 13.0, *)) {
        self.activityIndicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    } else {
        self.activityIndicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    self.activityIndicatorView.center = self.view.center;
    [self.activityIndicatorView hidesWhenStopped];
    
    [self.view addSubview:self.activityIndicatorView];
}

- (void)handleCancelTapGesture:(UIButton *)sender {
    DDLogVerbose(@"%@ handlecancelTapGesture: %@", LOG_TAG, sender);

    [self.uiContacts removeAllObjects];
    [self.uiGroups removeAllObjects];
    [self refreshTable];
    self.contact = nil;

    // Stop the twinlife framework and acknowledge the shared content only when we are ready to suspend.
    [self.shareService stopWithCompletionHandler:^(TLBaseServiceErrorCode errorCode) {
        NSError *error = [[NSError alloc]initWithDomain:[[NSBundle mainBundle] bundleIdentifier] code:0 userInfo:nil];
        [self.extensionContext cancelRequestWithError:error];
    }];
}

- (void)loadItem {
    DDLogVerbose(@"%@ loadItem", LOG_TAG);
    
    NSString *typeIdentifierFileURL = (NSString *)kUTTypeFileURL;
    NSString *typeIdentifierURL = (NSString *)kUTTypeURL;
    NSString *typeIdentifierImage = (NSString *)kUTTypeImage;
    NSString *typeIdentifierVideo = (NSString *)kUTTypeMovie;
    NSString *typeIdentifierPlainText = (NSString *)kUTTypeText;
    NSExtensionItem *item = self.extensionContext.inputItems.firstObject;
    
    if (self.currentItem < item.attachments.count) {
        NSItemProvider *itemProvider = [item.attachments objectAtIndex:self.currentItem];
        NSString *typeIdentifier = @"";
        if ([itemProvider hasItemConformingToTypeIdentifier:typeIdentifierFileURL]) {
            typeIdentifier = typeIdentifierFileURL;
        } else if ([itemProvider hasItemConformingToTypeIdentifier:typeIdentifierImage]) {
            typeIdentifier = typeIdentifierImage;
        } else if ([itemProvider hasItemConformingToTypeIdentifier:typeIdentifierVideo]) {
            typeIdentifier = typeIdentifierVideo;
        }
                
        if ([typeIdentifier isEqualToString:typeIdentifierImage]) {
            
            [itemProvider loadDataRepresentationForTypeIdentifier:typeIdentifier
                                                completionHandler:^(NSData * _Nullable data,
                                                                    NSError * _Nullable error) {
                if (!error && data && [UIImage imageWithData:data]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, nil);
                        NSString *extension = @".jpg";
                        if (source) {
                            size_t count = CGImageSourceGetCount(source);
                            if (count > 1) {
                                extension = @".gif";
                            }
                            CFRelease(source);
                        }
                        
                        NSString *fileName = [NSString stringWithFormat:@"%@_%@", [[NSProcessInfo processInfo] globallyUniqueString], extension];
                        NSURL *url = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:fileName]];
                        if ([data writeToURL:url options:NSDataWritingAtomic error:nil]) {
                            [self.contents addObject:url];
                        }
                        
                        self.currentItem++;
                        [self loadItem];
                    });
                } else {
                    [itemProvider loadItemForTypeIdentifier:typeIdentifierImage options:nil completionHandler:^(id<NSSecureCoding> lItem, NSError *error) {
                        if (!error && lItem) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                UIImage *image = nil;
                                if ([(NSObject *)lItem isKindOfClass:[UIImage class]]) {
                                    image = (UIImage *)lItem;
                                } else if ([(NSObject *)lItem isKindOfClass:[NSURL class]]) {
                                    NSData *data = [NSData dataWithContentsOfURL:(NSURL *)lItem];
                                    image = [UIImage imageWithData:data];
                                }
                                if (image) {
                                    NSString *fileName = [NSString stringWithFormat:@"%@.jpg", [[NSProcessInfo processInfo] globallyUniqueString]];
                                    NSURL *fileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:fileName]];
                                    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
                                    if ([imageData writeToURL:fileURL options:NSDataWritingAtomic error:nil]) {
                                        [self.contents addObject:fileURL];
                                    }
                                }
                            });
                        }
                        
                        self.currentItem++;
                        [self loadItem];
                    }];
                }
            }];
        } else if ([typeIdentifier isEqualToString:typeIdentifierVideo] || [typeIdentifier isEqualToString:typeIdentifierFileURL]) {
            [itemProvider loadItemForTypeIdentifier:typeIdentifier
                                            options:nil
                                  completionHandler:^(NSURL *url, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    NSString *fileName = url.lastPathComponent;
                    NSURL *fileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:fileName]];
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    
                    if (![fileManager createFileAtPath:fileURL.path contents:nil attributes:nil]) {
                        self.currentItem++;
                        [self loadItem];
                        return;
                    }
                    
                    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:fileURL.path];
                    [fileHandle seekToEndOfFile];
                    
                    NSUInteger offset = 0;
                    NSError *error = nil;
                    NSFileHandle *readFileHandle = [NSFileHandle fileHandleForReadingFromURL:url error:&error];
                    if (!readFileHandle || error) {
                        self.currentItem++;
                        [self loadItem];
                        return;
                    }
                    
                    unsigned long long totalSize = [readFileHandle seekToEndOfFile];
                    [readFileHandle seekToFileOffset:0];
                
                    if (totalSize <= 0) {
                        self.currentItem++;
                        [self loadItem];
                        return;
                    }
                    
                    NSData *data;
                    BOOL readData = YES;
                    while (readData) {
                        @autoreleasepool {
                            if (offset + DATA_CHUNK_SIZE < totalSize) {
                                [readFileHandle seekToFileOffset:offset];
                                data = [readFileHandle readDataOfLength:DATA_CHUNK_SIZE];
                                [fileHandle writeData:data];
                                offset += [data length];
                            } else {
                                data = [readFileHandle readDataToEndOfFile];
                                [fileHandle writeData:data];
                                readData = NO;
                            }
                        }
                    }
                    
                    [fileHandle closeFile];
                    [readFileHandle closeFile];
                    
                    [self.contents addObject:fileURL];
                    self.currentItem++;
                    [self loadItem];
                });
                
            }];
        } else if ([itemProvider hasItemConformingToTypeIdentifier:typeIdentifierURL]) {
            [itemProvider loadItemForTypeIdentifier:typeIdentifierURL
                                            options:nil
                                  completionHandler:^(NSURL *url, NSError *error) {
                [self.contents addObject:url.absoluteString];
                self.currentItem++;
                [self loadItem];
            }];
        } else if ([itemProvider hasItemConformingToTypeIdentifier:typeIdentifierPlainText]) {
            [itemProvider loadItemForTypeIdentifier:typeIdentifierPlainText
                                            options:nil
                                  completionHandler:^(NSString *content, NSError *error) {
                [self.contents addObject:content];
                self.currentItem++;
                [self loadItem];
            }];
        }
    } else {
        [self shareContent];
    }
}

- (void)shareContent {
    DDLogVerbose(@"%@ shareContent", LOG_TAG);
    
    if (self.selectedIndexPath.section == CONTACTS_VIEW_SECTION) {
        UIContact *uiContact = [self.uiContacts objectAtIndex:self.selectedIndexPath.row];
        
        TLSpaceSettings *spaceSettings = uiContact.contact.space.settings;
        if ([uiContact.contact.space.settings getBooleanWithName:PROPERTY_DEFAULT_MESSAGE_SETTINGS defaultValue:YES]) {
            spaceSettings = [self.shareService getDefaultSpaceSettings];
        }
        
        self.messageCopyAllowed = spaceSettings.messageCopyAllowed;
        self.fileCopyAllowed = spaceSettings.fileCopyAllowed;
        self.contact = uiContact.contact;
        [self.shareService getConversationWithContact:(TLContact *)uiContact.contact];
    } else if (self.selectedIndexPath.section == GROUPS_VIEW_SECTION) {
        UIContact *uiGroup = [self.uiGroups objectAtIndex:self.selectedIndexPath.row];
        
        TLSpaceSettings *spaceSettings = uiGroup.contact.space.settings;
        if ([uiGroup.contact.space.settings getBooleanWithName:PROPERTY_DEFAULT_MESSAGE_SETTINGS defaultValue:YES]) {
            spaceSettings = [self.shareService getDefaultSpaceSettings];
        }
        
        self.messageCopyAllowed = spaceSettings.messageCopyAllowed;
        self.fileCopyAllowed = spaceSettings.fileCopyAllowed;
        self.contact = uiGroup.contact;
        [self.shareService getConversationWithGroup:(TLGroup *)uiGroup.contact];
    }
}

- (BOOL)isImageFile:(NSString *)file {
    DDLogVerbose(@"%@ isImageFile: %@", LOG_TAG, file);
    
    CFStringRef fileType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef) [file pathExtension], NULL);
    BOOL result = UTTypeConformsTo(fileType, kUTTypeImage);
    CFRelease(fileType);
    return result;
}

- (BOOL)isVideoFile:(NSString *)file {
    DDLogVerbose(@"%@ isVideoFile: %@", LOG_TAG, file);
    
    CFStringRef fileType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef) [file pathExtension], NULL);
    BOOL result = UTTypeConformsTo(fileType, kUTTypeMovie);
    CFRelease(fileType);
    return result;
}

- (BOOL)isAudioFile:(NSString *)file {
    DDLogVerbose(@"%@ isAudioFile: %@", LOG_TAG, file);
    
    CFStringRef fileType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef) [file pathExtension], NULL);
    BOOL result = UTTypeConformsTo(fileType, kUTTypeAudio);
    CFRelease(fileType);
    return result;
}

@end

/*
 *  Copyright (c) 2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <Twinlife/TLConversationService.h>

#import <Twinme/TLTwinmeContext.h>
#import <Twinme/TLGroup.h>

#import <Utils/NSString+Utils.h>

#import "SelectedMembersCell.h"
#import "SelectedGroupMemberCell.h"
#import "UIInvitation.h"

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

static NSString *SELECTED_GROUP_MEMBER_CELL_IDENTIFIER = @"SelectedGroupMemberCellIdentifier";
static CGFloat DESIGN_COLLECTION_CELL_HEIGHT = 116;

//
// Interface: SelectedMembersCell ()
//

@interface SelectedMembersCell () <UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *membersCollectionViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *membersCollectionViewTrailingConstraint;

@property (nonatomic) NSMutableArray *uiMembers;
@property (nonatomic) UIImage *adminAvatar;
@property (nonatomic) BOOL fromCreateGroup;

@end

//
// Implementation: SelectedMembersCell
//

#undef LOG_TAG
#define LOG_TAG @"SelectedMembersCell"

@implementation SelectedMembersCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = Design.WHITE_COLOR;
    
    self.membersCollectionViewLeadingConstraint.constant *= Design.WIDTH_RATIO;
    self.membersCollectionViewTrailingConstraint.constant *= Design.WIDTH_RATIO;
    
    UICollectionViewFlowLayout* viewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    [viewFlowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [viewFlowLayout setMinimumInteritemSpacing:0];
    [viewFlowLayout setMinimumLineSpacing:0];
    CGFloat heightCell = DESIGN_COLLECTION_CELL_HEIGHT * Design.HEIGHT_RATIO;
    [viewFlowLayout setItemSize:CGSizeMake(heightCell, heightCell)];
    
    [self.membersCollectionView setCollectionViewLayout:viewFlowLayout];
    self.membersCollectionView.dataSource = self;
    self.membersCollectionView.backgroundColor = Design.WHITE_COLOR;
    [self.membersCollectionView registerNib:[UINib nibWithNibName:@"SelectedGroupMemberCell" bundle:nil] forCellWithReuseIdentifier:SELECTED_GROUP_MEMBER_CELL_IDENTIFIER];
}

- (void)prepareForReuse {
    
    [super prepareForReuse];
}

- (void)bindWithMembers:(NSMutableArray *)uiMembers fromCreateGroup:(BOOL)fromCreateGroup adminAvatar:(UIImage *)adminAvatar {
    DDLogVerbose(@"%@ bindWithMembers: %@", LOG_TAG, uiMembers);
    
    self.uiMembers = uiMembers;
    self.adminAvatar = adminAvatar;
    self.fromCreateGroup = fromCreateGroup;
    
    if (self.uiMembers.count > 0 || self.fromCreateGroup) {
        self.membersCollectionView.backgroundColor = Design.WHITE_COLOR;
        self.contentView.backgroundColor = Design.WHITE_COLOR;
    } else {
        self.membersCollectionView.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
    }
    [self.membersCollectionView reloadData];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    DDLogVerbose(@"%@ numberOfSectionsInCollectionView: %@", LOG_TAG, collectionView);
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    DDLogVerbose(@"%@ collectionView: %@ numberOfItemsInSection: %ld", LOG_TAG, collectionView, (long)section);
    
    if (self.fromCreateGroup) {
        return 1 + self.uiMembers.count;
    }
    return self.uiMembers.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ collectionView: %@ layout: %@ sizeForItemAtIndexPath: %@", LOG_TAG, collectionView, collectionViewLayout, indexPath);
    
    CGFloat heightCell = DESIGN_COLLECTION_CELL_HEIGHT * Design.HEIGHT_RATIO;
    return CGSizeMake(heightCell, heightCell);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    DDLogVerbose(@"%@ collectionView: %@ layout: %@ minimumLineSpacingForSectionAtIndex: %ld", LOG_TAG, collectionView, collectionViewLayout, (long)section);
    
    return 0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    DDLogVerbose(@"%@ collectionView: %@ layout: %@ referenceSizeForHeaderInSection: %ld", LOG_TAG, collectionView, collectionViewLayout, (long)section);
    
    return CGSizeMake(0, 0);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    DDLogVerbose(@"%@ collectionView: %@ cellForItemAtIndexPath: %@", LOG_TAG, collectionView, indexPath);
    
    SelectedGroupMemberCell *groupMemberCell = [collectionView dequeueReusableCellWithReuseIdentifier:SELECTED_GROUP_MEMBER_CELL_IDENTIFIER forIndexPath:indexPath];
    
    UIImage *avatar;
    
    if (self.fromCreateGroup) {
        if (indexPath.row == 0) {
            avatar = self.adminAvatar;
        } else {
            UIContact *uiMember = self.uiMembers[indexPath.row - 1];
            avatar = uiMember.avatar;
        }
    } else {
        UIContact *uiMember = self.uiMembers[indexPath.row];
        avatar = uiMember.avatar;
    }
    
    [groupMemberCell bindWithAvatar:avatar];

    return groupMemberCell;
}

@end

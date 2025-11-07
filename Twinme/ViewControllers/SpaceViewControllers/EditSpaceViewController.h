/*
 *  Copyright (c) 2019 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import "AbstractShowViewController.h"

//
// Protocol: SettingsSpaceDelegate
//

@class MessageSettingsSpaceViewController;

@protocol SettingsSpaceDelegate <NSObject>

- (void)saveSettings:(MessageSettingsSpaceViewController *)settingsSpaceViewController allowNotification:(BOOL)allowNotification allowCopyText:(BOOL)allowCopyText allowCopyFile:(BOOL)allowCopyFile allowEphemeral:(BOOL)allowEphemeral expireTimeout:(int64_t)expireTimeout isDefault:(BOOL)isDefault isSecret:(BOOL)isSecret;

@end

//
// Protocol: SpaceAppearanceDelegate
//

@class ConversationAppearanceViewController;
@class CustomAppearance;

@protocol SpaceAppearanceDelegate <NSObject>

- (void)saveAppearance:(ConversationAppearanceViewController *)spaceAppearanceViewController customAppearance:(CustomAppearance *)customAppearance conversationBackgroundLightImage:(UIImage *)conversationBackgroundLightImage conversationBackgroundDarkImage:(UIImage *)conversationBackgroundDarkImage;

@end

//
// Protocol: ContactsSpaceDelegate
//

@class ContactsSpaceViewController;

@protocol ContactsSpaceDelegate <NSObject>

- (void)moveContacts:(ContactsSpaceViewController *)contactsSpaceViewController contacts:(NSMutableArray *)contacts;

@end

//
// Protocol: CreateProfileSpaceDelegate
//

@class EditIdentityViewController;

@protocol CreateProfileSpaceDelegate <NSObject>

- (void)createProfile:(EditIdentityViewController *)editIdentityViewController name:(NSString *)name descriptionProfile:(NSString *)descriptionProfile avatar:(UIImage *)avatar largeAvatar:(UIImage *)largeAvatar;

@end

//
// Protocol: CustomColorDelegate
//

@class UICustomColor;

@protocol CustomColorDelegate <NSObject>

- (void)didSelectCustomColor:(UICustomColor *)customColor;

@end

//
// Interface: EditSpaceViewController
//

@class UITemplateSpace;

@interface EditSpaceViewController : AbstractShowViewController

- (void)initWithSpace:(TLSpace *)space;

- (void)initWithTemplateSpace:(UITemplateSpace *)templateSpace;


@end

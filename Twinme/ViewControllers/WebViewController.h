/*
 *  Copyright (c) 2014-2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Zhuoyu Ma (Zhuoyu.Ma@twinlife-systems.com)
 *   Christian Jacquemot (Christian.Jacquemot@twinlife-systems.com)
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <TwinmeCommon/AbstractTwinmeViewController.h>

//
// Interface: WebViewController
//

@interface WebViewController : AbstractTwinmeViewController

@property (nonatomic) NSString *name;
@property (nonatomic) NSString *fileName;
@property (nonatomic) NSString *url;

@end

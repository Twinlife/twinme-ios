/*
 *  Copyright (c) 2014-2020 twinlife SA.
 *  SPDX-License-Identifier: AGPL-3.0-only
 *
 *  Contributors:
 *   Zhuoyu Ma (Zhuoyu.Ma@twinlife-systems.com)
 *   Christian Jacquemot (Christian.Jacquemot@twinlife-systems.com)
 *   Fabrice Trescartes (Fabrice.Trescartes@twin.life)
 */

#import <CocoaLumberjack.h>

#import <WebKit/WebKit.h>

#import "WebViewController.h"

#import <TwinmeCommon/Design.h>

#if 0
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

//
// Interface: WebViewController ()
//

@interface WebViewController ()

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (nonatomic) WKWebView *webView;

@end

//
// Implementation: WebViewController
//

#undef LOG_TAG
#define LOG_TAG @"WebViewController"

@implementation WebViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    DDLogVerbose(@"%@ viewDidLoad", LOG_TAG);
    
    [super viewDidLoad];
    
    [self initViews];
}

#pragma mark - Private methods

- (void)initViews {
    DDLogVerbose(@"%@ initViews", LOG_TAG);
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setNavigationTitle:self.name];
    
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height) configuration:[[WKWebViewConfiguration alloc] init]];
    [self.contentView addSubview:self.webView];
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.webView.opaque = NO;
    [self.webView setClipsToBounds:YES];
    
    if(self.fileName) {
        NSString *htmlPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:self.fileName];
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:htmlPath]]];
    } else if (self.url) {
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.url]]];
    }
}

- (void)finish {
    DDLogVerbose(@"%@ finish", LOG_TAG);
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end

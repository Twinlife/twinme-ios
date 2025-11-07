/*
 *  Copyright (c) 2023 twinlife SA.
 *
 *  All Rights Reserved.
 *
 *  Contributors:
 *   Stephane Carrez (Stephane.Carrez@twin.life)
 */

#import <CocoaLumberjack.h>

#import <XCTest/XCTest.h>

#import <WebRTC/RTCLogging.h>
#import <WebRTC/RTCSSLAdapter.h>

#import <Twinme/TLExportExecutor.h>
#import <Utils/NSString+Utils.h>

#undef LOG_TAG
#define LOG_TAG @"utilityTests"

/// The utilityTests to execute and verify some basic utility operation.
@interface utilityTests : XCTestCase

@end

@implementation utilityTests

- (void)testExportNameFilter {

    // Bug 252: the '\' is not escaped.
    NSString *name = [TLExportExecutor exportWithName:@"../..\\..\\test"];

    XCTAssertEqualObjects(@"......test", name, @"Invalid exportWithName");

    // Check other special characters
    name = [TLExportExecutor exportWithName:@"A*?|\\<\":>B"];

    XCTAssertEqualObjects(@"AB", name, @"Invalid exportWithName");
}

- (void)testBase64UUID {

    NSUUID *value = [NSString toUUID:@"gJKBmZHoRGK0X2I-mYS-_Q"];
    NSUUID *expect = [[NSUUID alloc] initWithUUIDString:@"80928199-91e8-4462-b45f-623e9984befd"];

    XCTAssertEqualObjects(expect, value, @"Invalid conversion");

    NSString *b64 = [NSString fromUUID:expect];
    XCTAssertEqualObjects(@"gJKBmZHoRGK0X2I-mYS-_Q", b64, @"Invalid UUID encoding");
}

@end

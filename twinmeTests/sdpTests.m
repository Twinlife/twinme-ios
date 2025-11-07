/*
 *  Copyright (c) 2022 twinlife SA.
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

#import <Twinlife/TLSdp.h>

#if 1
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

#undef LOG_TAG
#define LOG_TAG @"sdpTests"

/// The sdpTests follow the Java unit tests to ensure proper encoding, compression, decompression, decoding
/// of SDP and transport candidates.
@interface sdpTests : XCTestCase

@end

@implementation sdpTests

- (void)testNoCompress {

    TLSdp *sdp = [[TLSdp alloc] initWithSdp:@"test"];

    XCTAssertEqual(NO, [sdp isCompressed], @"Small SDP is not compressed");

    NSData *data = [sdp data];
    XCTAssert(data != nil, @"SDP data must not be null");

    sdp = [[TLSdp alloc] initWithData:data compressed:NO keyIndex:0];
    XCTAssert([[sdp sdp] isEqual:@"test"], @"Invalid SDP content");
}

- (void)testCompress {

    NSMutableString *content = [[NSMutableString alloc] initWithCapacity:1024];
    for (int i = 0; i < 100; i++) {
        [content appendString:@"a=ice-options:trickle renomination"];
        [content appendString:[[NSUUID alloc] init].UUIDString];
    }

    TLSdp *sdp = [[TLSdp alloc] initWithSdp:content];

    XCTAssertEqual(YES, [sdp isCompressed], @"Big SDP must be compressed");

    NSData *data = [sdp data];
    XCTAssert(data.length < [content length], @"SDP data must be < length");

    sdp = [[TLSdp alloc] initWithData:data compressed:YES keyIndex:0];
    XCTAssert([content isEqual:[sdp sdp]], @"Invalid SDP content");
}

- (void)testTransportCandidate {

    TLTransportCandidateList *candidates = [[TLTransportCandidateList alloc] init];
    NSString *candidate = @"candidate:1052210311 1 tcp 1518280447 192.168.0.72 50417 typ host tcptype passive generation 0 ufrag KjZR network-id 1 network-cost 10";
    [candidates addCandidateWithId:1 label:@"data" sdp:candidate];

    TLSdp *sdp = [candidates buildSdpWithRequestId:1];
    NSString *packedSdp = [sdp sdp];
    NSString *expect = @"+data\t1\t\0011052210311 1\0031518280447 192.168.0.72 50417\005\006\016\017\022 0\v KjZR\021 1\020 10";

    for (int i = 0; i < [expect length]; i++) {
        if ([expect characterAtIndex:i] != [packedSdp characterAtIndex:i]) {
            XCTAssertEqual([expect characterAtIndex:i], [packedSdp characterAtIndex:i], @"Invalid character");
        }
    }

    NSArray<TLTransportCandidate *> *result = [sdp candidates];
    XCTAssert(result != nil, "candidates returned null list");
    XCTAssertEqual(1, [result count], @"Invalid number of candidates");

    TLTransportCandidate *c = result[0];
    XCTAssert([candidate isEqual:c.sdp], @"invalid candidate");
}

static NSString *C1 = @"candidate:560224848 1 udp 2113937151 192.168.122.20 51950 typ host generation 0 ufrag xKtp network-cost 999";
static NSString *C2 = @"candidate:560224848 1 udp 2113937151 192.168.122.20 38306 typ host generation 0 ufrag LIMa network-cost 999";
static NSString *C3 = @"candidate:842163049 1 udp 1685987071 37.171.3.77 2692 typ srflx raddr 192.168.8.154 rport 48531 generation 0 ufrag atY7 network-id 3 network-cost 10";
static NSString *C4 = @"candidate:577336358 1 udp 25043199 195.201.85.202 61645 typ relay raddr 37.171.3.77 rport 2761 generation 0 ufrag atY7 network-id 3 network-cost 10";
static NSString *C5 = @"candidate:577336358 1 udp 25108735 195.201.85.202 58159 typ relay raddr 2a01:cb1e:53:50b9:3401:a631:6f24:7107 rport 50299 generation 0 ufrag sXqx network-id 6 network-cost 900";
static NSString *C6 = @"candidate:3717173733 1 udp 1685987071 92.184.112.141 50150 typ srflx raddr 192.0.0.1 rport 50150 generation 0 ufrag xlqh network-id 5 network-cost 900";
static NSString *C7 = @"candidate:1827309782 1 udp 41886207 195.201.85.202 61739 typ relay raddr 2a01:cb1e:53:50b9:3401:a631:6f24:7107 rport 58554 generation 0 ufrag XQtu network-id 6 network-cost 900";

- (void)testCandidates {

    NSString *C_Ref[] = {
            C1, C2, C3, C4, C5, C6, C7
    };

    for (int i = 0; i < 10; i++) {
        TLTransportCandidateList *warmup = [[TLTransportCandidateList alloc] init];
        
        [warmup addCandidateWithId:1 label:@"data" sdp:C_Ref[0]];
        [warmup addCandidateWithId:1 label:@"data" sdp:C_Ref[1]];
        [warmup addCandidateWithId:1 label:@"data" sdp:C_Ref[2]];
        [warmup buildSdpWithRequestId:12];
    }

    for (int i = 0; i < 7; i++) {
        TLTransportCandidateList *candidates = [[TLTransportCandidateList alloc] init];

        for (int k = 0; k <= i; k++) {
            if (k < 5) {
                [candidates addCandidateWithId:k label:@"data" sdp:C_Ref[k]];
            } else {
                [candidates removeCandidateWithId:k label:@"data" sdp:C_Ref[k]];
            }
        }

        int64_t now = [[NSDate date] timeIntervalSince1970] * 1000000L;
        TLSdp *sdp = [candidates buildSdpWithRequestId:123];
        int64_t dt = [[NSDate date] timeIntervalSince1970] * 1000000L - now;

        NSArray<TLTransportCandidate *> *result = [sdp candidates];
        XCTAssert(result != nil, "candidates returned null list");
        XCTAssertEqual(i + 1, [result count], @"Invalid number of candidates");
        int totLength = 0;
        for (int k = 0; k < [result count]; k++) {
            TLTransportCandidate *candidate = result[k];
            XCTAssert(candidate != nil, "candidate must not be null");
            XCTAssertEqual(k, candidate.ident, @"Invalid candidate 'ident'");

            XCTAssert([C_Ref[k] isEqual:candidate.sdp], @"invalid candidate");
            XCTAssertEqual(k >= 5, candidate.removed, @"Invalid candidate 'removed'");

            totLength += [candidate.label length] + [candidate.sdp length] + 1;
        }

        NSLog(@"Encoded %d in %lld us tot size reduced from %d to %d", (i + 1), dt, totLength, (int)[sdp.data length]);
    }
}

@end

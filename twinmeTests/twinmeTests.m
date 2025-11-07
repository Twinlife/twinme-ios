/*
 *  Copyright (c) 2021-2023 twinlife SA.
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

#import <Twinlife/TLTwinlife.h>
#import <Twinlife/TLManagementService.h>
#import <Twinlife/TLPeerConnectionService.h>
#import <Twinlife/TLAccountService.h>
#import <Twinlife/TLConnectivityService.h>
#import <Twinlife/TLConversationService.h>
#import <Twinlife/TLNotificationService.h>
#import <Twinlife/TLPeerConnectionService.h>
#import <Twinlife/TLRepositoryService.h>
#import <Twinlife/TLTwincodeFactoryService.h>
#import <Twinlife/TLTwincodeInboundService.h>
#import <Twinlife/TLTwincodeOutboundService.h>
#import <Twinlife/TLImageService.h>
#import <Twinlife/TLTwinlifeContext.h>
#import <Twinlife/TLJobService.h>
#import <Twinlife/TLPeerConnectionService.h>
#import <Twinlife/TLApplication.h>
#import <Twinlife/TLAssertion.h>

#import <Twinme/TLMessage.h>
#import <Twinme/TLTyping.h>
#import <Twinme/TLOriginator.h>
#import <Twinme/TLContact.h>
#import <Twinme/TLGroup.h>
#import <Twinme/TLGroupMember.h>
#import <Twinme/TLRoomCommand.h>
#import <Twinme/TLRoomCommandResult.h>
#import <Twinme/TLTwinmeApplication.h>
#import <Twinme/TLTwinmeContext.h>
#import <Twinme/TLTwinmeConfiguration.h>

#import <TwinmeCommon/ApplicationDelegate.h>

//#import "Configuration/Configuration.h"

#if 1
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelWarning;
#endif

#undef LOG_TAG
#define LOG_TAG @"twinmeTests"

static BOOL waitInitDone = NO;

@interface TestMessage : NSObject

@property (nonatomic) TLContact *contact;
@property (nonatomic) id <TLConversation> conversation;
@property (nonatomic) TLDescriptor *descriptor;

- (nonnull instancetype)initWithContact:(nullable TLContact *)contact conversation:(nullable id<TLConversation>)conversation;

- (nonnull instancetype)initWithDescriptor:(nonnull TLDescriptor *)descriptor conversation:(nonnull id<TLConversation>)conversation;

@end

@interface twinmeTests : XCTestCase <TLConversationServiceDelegate>

@property (nonatomic) TLTwinmeContext *twinmeContext;
@property (nonatomic) TwinmeApplication *twinmeApplication;
@property (nonatomic) XCTestExpectation *offlineExpectation;
@property (nonatomic) XCTestExpectation *onlineExpectation;
@property (nonatomic) XCTestExpectation *testExpectation;
@property (nonatomic) NSMutableArray<TLContact *> *contacts;
@property (nonatomic) NSMutableDictionary<NSNumber *, TestMessage *> *requests;
@property (nonatomic) NSMutableArray<TestMessage *> *messages;

@property int pushCompletionCount;

- (void)checkInit;

- (void)onTwinlifeReady;

- (void)onTwinlifeOnline;

- (void)onTwinlifeOffline;

- (void)onPushDescriptorRequestId:(int64_t)requestId conversation:(nonnull id <TLConversation>)conversation descriptor:(nonnull TLDescriptor *)descriptor;

- (void)finishPushWithRequestId:(int64_t)requestId;

@end

@implementation TestMessage

- (nonnull instancetype)initWithContact:(nullable TLContact *)contact conversation:(nullable id<TLConversation>)conversation {

    self = [super init];
    if (self) {
        _contact = contact;
        _conversation = conversation;
    }
    return self;
}

- (nonnull instancetype)initWithDescriptor:(nonnull TLDescriptor *)descriptor conversation:(nonnull id<TLConversation>)conversation {
    
    self = [super init];
    if (self) {
        _descriptor = descriptor;
        _conversation = conversation;
    }
    return self;
}

@end

@implementation twinmeTests

- (void)onTwinlifeReady {
    DDLogVerbose(@"%@ onTwinlifeReady", LOG_TAG);

}

- (void)onTwinlifeOnline {
    DDLogError(@"%@ onTwinlifeOnline", LOG_TAG);

    if (self.onlineExpectation) {
        [self.onlineExpectation fulfill];
        self.onlineExpectation = nil;
    }
}

- (void)onTwinlifeOffline {
    DDLogVerbose(@"%@ onTwinlifeOffline", LOG_TAG);

    if (self.offlineExpectation) {
        [self.offlineExpectation fulfill];
        self.offlineExpectation = nil;
    }
}

- (void)onPushDescriptorRequestId:(int64_t)requestId conversation:(id <TLConversation>)conversation descriptor:(TLDescriptor *)descriptor {
    DDLogVerbose(@"%@ onPushDescriptorRequestId", LOG_TAG);
    NSLog(@"%@ onPushDescriptorRequestId %lld", LOG_TAG, requestId);

    NSNumber *lRequestId = [NSNumber numberWithLongLong:requestId];
    @synchronized (self) {
        TestMessage *message = self.requests[lRequestId];
        if (message) {
            [self.requests removeObjectForKey:lRequestId];

            message.conversation = conversation;
            message.descriptor = descriptor;
            [self.messages addObject:message];
            if (self.requests.count == 0) {
                [self.testExpectation fulfill];
            }
        }
    }
}

- (void)finishPushWithRequestId:(int64_t)requestId {
    DDLogVerbose(@"%@ finishPushWithRequestId", LOG_TAG);
    NSLog(@"%@ finishPushWithRequestId %lld", LOG_TAG, requestId);

    NSNumber *lRequestId = [NSNumber numberWithLongLong:requestId];
    @synchronized (self) {
        TestMessage *message = self.requests[lRequestId];
        if (message) {
            [self.requests removeObjectForKey:lRequestId];

            if (self.requests.count == 0) {
                [self.testExpectation fulfill];
            }
        }
    }
}

- (void)checkInit {
    DDLogVerbose(@"%@ checkInit", LOG_TAG);

    // For a first execution, wait for the iOS to execute the application delegate applicationDidBecomeActive
    // because it will put the job scheduler in the foreground state and the stop operation will do nothing.
    if (!waitInitDone) {
        waitInitDone = YES;
        NSLog(@"testDisconnectReconnect waiting startup");

        XCTestExpectation *startup = [self expectationWithDescription:@"startup framework"];

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [startup fulfill];
        });
        [self waitForExpectationsWithTimeout:10.0 handler:^(NSError *error) {
            DDLogError(@"%@ startup expectation failed: %@", LOG_TAG, error);
        }];
    }
}

- (void)setUp {
    DDLogError(@"%@ setUp", LOG_TAG);

    NSLog(@"setup is called");
    
    ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
    self.twinmeApplication = [delegate twinmeApplication];
    self.twinmeContext = [delegate twinmeContext];

    [self.twinmeContext addDelegate:self];
}

- (void)tearDown {
    DDLogVerbose(@"%@ tearDown", LOG_TAG);

    [self.twinmeContext removeDelegate:self];
}

- (void)testDisconnectReconnect {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.

    NSLog(@"testDisconnectReconnect is started");

    [self checkInit];

    int currentPushCount = self.pushCompletionCount;

    int64_t startTime = [[NSDate date] timeIntervalSince1970] * 1000;
    self.offlineExpectation = [self expectationWithDescription:@"stop twinlife framework"];

    NSLog(@"Stopping twinlife!!!!");
    ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
    [self.twinmeContext applicationDidEnterBackground:delegate];
    [self.twinmeContext stopWithCompletionHandler:^(TLBaseServiceErrorCode errorCode) {
        
    }];

    NSLog(@"%@ isConnected=%d", LOG_TAG, [self.twinmeContext isConnected]);
    if (![self.twinmeContext isConnected]) {
        [self.offlineExpectation fulfill];
    }

    NSLog(@"Waiting twinlife!!!!");
    [self waitForExpectationsWithTimeout:60.0 handler:^(NSError *error) {
        DDLogError(@"%@ offline expectation failed: %@", LOG_TAG, error);
        self.offlineExpectation = nil;
    }];

    NSLog(@"%@ simulating a push", LOG_TAG);

    self.onlineExpectation = [self expectationWithDescription:@"twinlife online"];

    [self.twinmeContext didReceiveIncomingPushWithPayload:[[NSDictionary alloc] init] application:delegate completionHandler:^(TLBaseServiceErrorCode status, TLPushNotificationContent *notificationContent) {
        self.pushCompletionCount++;
        NSLog(@"%@ push completion %d", LOG_TAG, self.pushCompletionCount);
    } terminateCompletionHandler:^(TLBaseServiceErrorCode errorCode) {
        NSLog(@"%@ terminate completion handler executed %d", LOG_TAG, self.pushCompletionCount);
    }];
    [self.twinmeContext start];

    NSLog(@"%@ waiting Twinlife to be up", LOG_TAG);
    [self waitForExpectationsWithTimeout:60.0 handler:^(NSError *error) {
        DDLogError(@"%@ online expectation failed: %@", LOG_TAG, error);
        self.onlineExpectation = nil;
    }];

    self.offlineExpectation = [self expectationWithDescription:@"stop twinlife framework"];
    [self.twinmeContext stopWithCompletionHandler:^(TLBaseServiceErrorCode errorCode) {
        
    }];

    NSLog(@"Waiting twinlife offline (2)!!!!");
    [self waitForExpectationsWithTimeout:60.0 handler:^(NSError *error) {
        DDLogError(@"%@ offline expectation failed: %@", LOG_TAG, error);
        self.offlineExpectation = nil;
    }];

    int64_t endTime = [[NSDate date] timeIntervalSince1970] * 1000;

    NSLog(@"%@ testDisconnectReconnect done in %lld", LOG_TAG, endTime - startTime);

    // Wait for completion.
    [NSThread sleepForTimeInterval:1.0];
    XCTAssertEqual(currentPushCount + 1, self.pushCompletionCount, @"Invalid number of background push completion");
}

- (void)testEnterForegroundBackground {
    NSLog(@"testEnterForegroundBackground is started");

    [self checkInit];

    int currentPushCount = self.pushCompletionCount;

    int64_t startTime = [[NSDate date] timeIntervalSince1970] * 1000;
    self.onlineExpectation = [self expectationWithDescription:@"twinlife online"];

    ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
    [self.twinmeContext applicationDidBecomeActive:delegate];

    NSLog(@"%@ isConnected=%d", LOG_TAG, [self.twinmeContext isConnected]);
    if ([self.twinmeContext isConnected]) {
        [self.onlineExpectation fulfill];
    }

    NSLog(@"Waiting twinlife!!!!");
    [self waitForExpectationsWithTimeout:60.0 handler:^(NSError *error) {
        DDLogError(@"%@ online expectation failed: %@", LOG_TAG, error);
        self.onlineExpectation = nil;
    }];

    // Repeat the sequence:
    //  - enter in background,
    //  - receive push,
    //  - enter in foreground
    int retryCount = 10;
    for (int retry = 0; retry < retryCount; retry++) {
        [self.twinmeContext applicationDidEnterBackground:delegate];

        NSLog(@"%@ simulating a push", LOG_TAG);
        [self.twinmeContext didReceiveIncomingPushWithPayload:[[NSDictionary alloc] init] application:delegate completionHandler:^(TLBaseServiceErrorCode status, TLPushNotificationContent *notificationContent) {
            self.pushCompletionCount++;
            NSLog(@"%@ push completion %d", LOG_TAG, self.pushCompletionCount);
        } terminateCompletionHandler:^(TLBaseServiceErrorCode errorCode) {
            NSLog(@"%@ terminate completion handler executed %d", LOG_TAG, self.pushCompletionCount);
        }];

        [self.twinmeContext applicationDidBecomeActive:delegate];
    }

    [self.twinmeContext applicationDidEnterBackground:delegate];

    self.offlineExpectation = [self expectationWithDescription:@"stop twinlife framework"];
    [self.twinmeContext stopWithCompletionHandler:^(TLBaseServiceErrorCode errorCode) {
        
    }];

    [self waitForExpectationsWithTimeout:60.0 handler:^(NSError *error) {
        DDLogError(@"%@ offline expectation failed: %@", LOG_TAG, error);
        self.offlineExpectation = nil;
    }];

    int64_t endTime = [[NSDate date] timeIntervalSince1970] * 1000;

    NSLog(@"%@ testEnterForegroundBackground done in %lld", LOG_TAG, endTime - startTime);

    // Wait for completion.
    [NSThread sleepForTimeInterval:1.0];
    XCTAssertEqual(currentPushCount + retryCount, self.pushCompletionCount, @"Invalid number of background push completion");
}

- (void)testStressDisconnectReconnect {
    NSLog(@"testStressDisconnectReconnect is started");

    [self checkInit];

    ApplicationDelegate *delegate = (ApplicationDelegate *)[[UIApplication sharedApplication] delegate];
    [self.twinmeContext applicationDidEnterBackground:delegate];

    for (int i = 0; i < 10; i++) {
        @autoreleasepool {

            int64_t startTime = [[NSDate date] timeIntervalSince1970] * 1000;
            self.onlineExpectation = [self expectationWithDescription:@"twinlife online"];

            NSLog(@"%@ isConnected=%d", LOG_TAG, [self.twinmeContext isConnected]);
            if ([self.twinmeContext isConnected]) {
                [self.onlineExpectation fulfill];
            }

            NSLog(@"%@ simulating a push", LOG_TAG);
            [self.twinmeContext didReceiveIncomingPushWithPayload:[[NSDictionary alloc] init] application:delegate completionHandler:^(TLBaseServiceErrorCode status, TLPushNotificationContent *notificationContent) {
                self.pushCompletionCount++;
                NSLog(@"%@ push completion %d", LOG_TAG, self.pushCompletionCount);
            } terminateCompletionHandler:^(TLBaseServiceErrorCode errorCode) {
                NSLog(@"%@ terminate completion handler executed %d", LOG_TAG, self.pushCompletionCount);
            }];

            NSLog(@"Waiting twinlife!!!!");
            [self waitForExpectationsWithTimeout:60.0 handler:^(NSError *error) {
                DDLogError(@"%@ online expectation failed: %@", LOG_TAG, error);
                self.onlineExpectation = nil;
            }];

            NSLog(@"Stopping!!!");
            self.offlineExpectation = [self expectationWithDescription:@"stop twinlife framework"];
            [self.twinmeContext stopWithCompletionHandler:^(TLBaseServiceErrorCode errorCode) {
                
            }];

            [self waitForExpectationsWithTimeout:60.0 handler:^(NSError *error) {
                DDLogError(@"%@ offline expectation failed: %@", LOG_TAG, error);
                self.offlineExpectation = nil;
            }];

            int64_t endTime = [[NSDate date] timeIntervalSince1970] * 1000;

            NSLog(@"%@ testEnterForegroundBackground done in %lld", LOG_TAG, endTime - startTime);

            // Wait for completion.
            [NSThread sleepForTimeInterval:1.0];

            TLImageId *imageId = [[TLImageId alloc] initWithLocalId:0];
            TLImageService *imageService = [self.twinmeContext getImageService];
            UIImage *thumbnail = [imageService getCachedImageWithImageId:imageId kind:TLImageServiceKindThumbnail];

            XCTAssertTrue(thumbnail == nil, @"getCachedImageWithImageId returned an image");
        }
    }

    NSLog(@"%@ testStressDisconnectReconnect done", LOG_TAG);
}

- (void)testDatabase {
    NSLog(@"%@ testDatabase", LOG_TAG);

    [self checkInit];

    self.contacts = nil;
    self.testExpectation = [self expectationWithDescription:@"find contacts"];

    int64_t requestId = [self.twinmeContext newRequestId];
    TLFilter *filter = [self.twinmeContext createSpaceFilter];
    [self.twinmeContext findContactsWithFilter:filter withBlock:^(NSMutableArray<TLContact *> *list) {
        self.contacts = list;
        [self.testExpectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError *error) {
        NSLog(@"%@ find contacts expectation failed: %@", LOG_TAG, error);
        self.testExpectation = nil;
    }];

    XCTAssertTrue(self.contacts != nil, @"findContacts returned nil");
    XCTAssertTrue(self.contacts.count > 0, @"findContacts no contact");

    self.messages = [[NSMutableArray alloc] init];
    self.requests = [[NSMutableDictionary alloc] init];

    TLConversationService *conversationService = [self.twinmeContext getConversationService];

    [conversationService addDelegate:self];

    // Set a fake request to make sure the onPushObject callback will not call the expectation until we have finished.
    int64_t waitRequestId = [self.twinmeContext newRequestId];
    [self.requests setObject:[[TestMessage alloc] initWithContact:nil conversation:nil] forKey:[NSNumber numberWithLongLong:waitRequestId]];

    self.testExpectation = [self expectationWithDescription:@"push messages"];
    for (TLContact *contact in self.contacts) {
        id<TLConversation> conversation = [conversationService getOrCreateConversationWithSubject:contact create:YES];

        XCTAssertTrue(conversation != nil, @"getOrCreateConversationWithSubject returned nil");

        NSUUID *conversationId = conversation.uuid;
        requestId = [self.twinmeContext newRequestId];
        [self.requests setObject:[[TestMessage alloc] initWithContact:contact conversation:conversation] forKey:[NSNumber numberWithLongLong:requestId]];

        NSLog(@"%@ pushObject requestId: %lld", LOG_TAG, requestId);

        NSString *message = @"test message from unit test!";
        [conversationService pushObjectWithRequestId:requestId conversation:conversation sendTo:nil replyTo:nil message:message copyAllowed:NO expireTimeout:120 * 1000L];

        requestId = [self.twinmeContext newRequestId];
        NSLog(@"%@ pushTyping requestId: %lld", LOG_TAG, requestId);

        NSObject *typing = [[TLTyping alloc] initWithAction:TLTypingActionStart];
        [conversationService pushTransientObjectWithRequestId:requestId conversation:conversation object:typing];

        requestId = [self.twinmeContext newRequestId];
        [self.requests setObject:[[TestMessage alloc] initWithContact:contact conversation:conversation] forKey:[NSNumber numberWithLongLong:requestId]];

        NSLog(@"%@ pushTwincode requestId: %lld", LOG_TAG, requestId);

        [conversationService pushTwincodeWithRequestId:requestId conversation:conversation sendTo:nil replyTo:nil twincodeId:conversationId schemaId:conversationId publicKey:nil copyAllowed:YES expireTimeout:30 * 1000L];

        // [conversationService resetConversationWithRequestId:requestId conversationId:conversationId];
    }

    [self finishPushWithRequestId:waitRequestId];

    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError *error) {
        NSLog(@"%@ conversation push failed: %@", LOG_TAG, error);
        NSLog(@"%@ request count: %d message count: %d", LOG_TAG, (int)self.requests.count, (int)self.messages.count);
        self.testExpectation = nil;
    }];

    for (TestMessage *message in self.messages) {
        [conversationService markDescriptorReadWithRequestId:requestId descriptorId:[message.descriptor descriptorId]];
    }

    [conversationService removeDelegate:self];
}

- (void)testAnnotations {
    NSLog(@"%@ testAnnotations", LOG_TAG);

    [self checkInit];

    self.contacts = nil;
    self.testExpectation = [self expectationWithDescription:@"find contacts for annotations"];

    int64_t requestId = [self.twinmeContext newRequestId];
    TLFilter *filter = [self.twinmeContext createSpaceFilter];
    [self.twinmeContext findContactsWithFilter:filter withBlock:^(NSMutableArray<TLContact *> *list) {
        self.contacts = list;
        [self.testExpectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError *error) {
        NSLog(@"%@ find contacts expectation failed: %@", LOG_TAG, error);
        self.testExpectation = nil;
    }];

    XCTAssertTrue(self.contacts != nil, @"findContacts returned nil");
    XCTAssertTrue(self.contacts.count > 0, @"findContacts no contact");

    self.messages = [[NSMutableArray alloc] init];
    self.requests = [[NSMutableDictionary alloc] init];

    TLConversationService *conversationService = [self.twinmeContext getConversationService];

    [conversationService addDelegate:self];

    // Set a fake request to make sure the onPushObject callback will not call the expectation until we have finished.
    int64_t waitRequestId = [self.twinmeContext newRequestId];
    [self.requests setObject:[[TestMessage alloc] initWithContact:nil conversation:nil] forKey:[NSNumber numberWithLongLong:waitRequestId]];

    self.testExpectation = [self expectationWithDescription:@"push messages (annotations)"];
    for (TLContact *contact in self.contacts) {
        id<TLConversation> conversation = [conversationService getOrCreateConversationWithSubject:contact create:YES];

        XCTAssertTrue(conversation != nil, @"getOrCreateConversationWithSubject returned nil");

        requestId = [self.twinmeContext newRequestId];
        [self.requests setObject:[[TestMessage alloc] initWithContact:contact conversation:conversation] forKey:[NSNumber numberWithLongLong:requestId]];

        NSLog(@"%@ pushObject requestId: %lld", LOG_TAG, requestId);

        [conversationService pushObjectWithRequestId:requestId conversation:conversation sendTo:nil replyTo:nil message:@"test message from annotation unit test!" copyAllowed:NO expireTimeout:120 * 1000L];
    }

    [self finishPushWithRequestId:waitRequestId];

    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError *error) {
        NSLog(@"%@ conversation push failed: %@", LOG_TAG, error);
        NSLog(@"%@ request count: %d message count: %d", LOG_TAG, (int)self.requests.count, (int)self.messages.count);
        self.testExpectation = nil;
    }];

    for (TestMessage *message in self.messages) {
        // Set a Like annotation.
        TLBaseServiceErrorCode status = [conversationService setAnnotationWithDescriptorId:[message.descriptor descriptorId] type:TLDescriptorAnnotationTypeLike value:1];

        XCTAssertEqual(status, TLBaseServiceErrorCodeSuccess, @"setAnnotationWithConversationId returned bad code");

        TLDescriptorAnnotation *annotation = [message.descriptor getDescriptorAnnotationWithType:TLDescriptorAnnotationTypeLike];
        XCTAssertTrue(annotation != nil, @"missing Like annotation on the descriptor");
        XCTAssertEqual(annotation.value, 1, @"invalid Like annotation value on the descriptor");
        XCTAssertEqual(annotation.count, 1, @"invalid Like annotation count on the descriptor");

        // Change the annotation value.
        status = [conversationService setAnnotationWithDescriptorId:[message.descriptor descriptorId] type:TLDescriptorAnnotationTypeLike value:1234];

        XCTAssertEqual(status, TLBaseServiceErrorCodeSuccess, @"setAnnotationWithConversationId returned bad code");

        annotation = [message.descriptor getDescriptorAnnotationWithType:TLDescriptorAnnotationTypeLike];
        XCTAssertTrue(annotation != nil, @"missing Like annotation on the descriptor");
        XCTAssertEqual(annotation.value, 1234, @"invalid Like annotation value on the descriptor");
        XCTAssertEqual(annotation.count, 1, @"invalid Like annotation count on the descriptor");

        // Add a Poll annotation.
        status = [conversationService setAnnotationWithDescriptorId:[message.descriptor descriptorId] type:TLDescriptorAnnotationTypePoll value:4];

        XCTAssertEqual(status, TLBaseServiceErrorCodeSuccess, @"setAnnotationWithConversationId returned bad code");

        // Like annotation must not be changed.
        annotation = [message.descriptor getDescriptorAnnotationWithType:TLDescriptorAnnotationTypeLike];
        XCTAssertTrue(annotation != nil, @"missing Like annotation on the descriptor");
        XCTAssertEqual(annotation.value, 1234, @"invalid Like annotation value on the descriptor");
        XCTAssertEqual(annotation.count, 1, @"invalid Like annotation count on the descriptor");

        // And Poll annotation must be available.
        annotation = [message.descriptor getDescriptorAnnotationWithType:TLDescriptorAnnotationTypePoll];
        XCTAssertTrue(annotation != nil, @"missing Poll annotation on the descriptor");
        XCTAssertEqual(annotation.value, 4, @"invalid Poll annotation value on the descriptor");
        XCTAssertEqual(annotation.count, 1, @"invalid Poll annotation count on the descriptor");

        // Remove a Poll annotation.
        status = [conversationService deleteAnnotationWithDescriptorId:[message.descriptor descriptorId] type:(TLDescriptorAnnotationType)TLDescriptorAnnotationTypePoll];

        XCTAssertEqual(status, TLBaseServiceErrorCodeSuccess, @"deleteAnnotationWithConversationId returned bad code");
        annotation = [message.descriptor getDescriptorAnnotationWithType:TLDescriptorAnnotationTypePoll];
        XCTAssertTrue(annotation == nil, @"Poll annotation was not removed on the descriptor");

        // Set a Forward annotation generates a BadRequest.
        status = [conversationService setAnnotationWithDescriptorId:[message.descriptor descriptorId] type:TLDescriptorAnnotationTypeForward value:1];

        XCTAssertEqual(status, TLBaseServiceErrorCodeBadRequest, @"setAnnotationWithConversationId returned bad code");
    }

    [conversationService removeDelegate:self];
}

- (void)testAssertions {
    NSLog(@"%@ testAssertions", LOG_TAG);
    
    [self checkInit];
    
    // Check sending the assertion, the server receives:
    //  - assertion EXCEPTION
    //  - line number,
    //  - P1 (UUID) as FactoryId
    //  - P2 (UUID) as FactoryId
    //  - parameter with value 1
    NSUUID *p1 = [NSUUID UUID];
    NSUUID *p2 = [NSUUID UUID];
    TL_ASSERT_EQUAL(self.twinmeContext, p1, p2, [TLTwinlifeAssertPoint EXCEPTION], TLAssertionParameterFactoryId, [TLAssertValue initWithNumber:1], nil);
    
    // Check another assertion, the server receives:
    //  - assertion SERVICE,
    //  - line number,
    //  - P2 (UUID) as EnvironmentId
    p1 = nil;
    TL_ASSERT_NOT_NULL(self.twinmeContext, p1, [TLTwinlifeAssertPoint SERVICE],  [TLAssertValue initWithEnvironmentId:p2], nil);
    
    // Check sending the assertion, the server receives:
    //  - assertion UNEXPECTED_EXCEPTION
    //  - line number,
    //  - s1 being a NSString, the server will receive NULL
    //  - s2 being a NSString, the server will receive NULL
    //  - parameter with value 3
    NSString *s1 = @"TEST STRING MUST NOT BE SENT";
    NSString *s2 = @"SECOND STRING MUST NOT BE SENT";
    TL_ASSERT_EQUAL(self.twinmeContext, s1, s2, [TLTwinlifeAssertPoint UNEXPECTED_EXCEPTION], TLAssertionParameterSubject, [TLAssertValue initWithNumber:3], nil);
    
    self.contacts = nil;
    self.testExpectation = [self expectationWithDescription:@"find contacts for assertions"];
    
    TLFilter *filter = [self.twinmeContext createSpaceFilter];
    [self.twinmeContext findContactsWithFilter:filter withBlock:^(NSMutableArray<TLContact *> *list) {
        self.contacts = list;
        [self.testExpectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError *error) {
        NSLog(@"%@ find contacts expectation failed: %@", LOG_TAG, error);
        self.testExpectation = nil;
    }];

    for (TLContact *contact in self.contacts) {
        [self.twinmeContext assertionWithAssertPoint:[TLTwinlifeAssertPoint SERVICE], [TLAssertValue initWithSubject:contact], [TLAssertValue initWithTwincodeOutbound:contact.twincodeOutbound], [TLAssertValue initWithLine:__LINE__], nil];
    }
}

- (void)testParseURI {
    NSLog(@"%@ testParseURI", LOG_TAG);
    
    [self checkInit];
    
    
    TLTwincodeOutboundService *twincodeOutboundService = [self.twinmeContext getTwincodeOutboundService];
    __block TLBaseServiceErrorCode status;
    __block TLTwincodeURI *result;

    // Check with an IPv4 address.
    NSURL *uri = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"https://%@/1.2.3.4", [TLTwincodeURI PROXY_ACTION]]];
    self.testExpectation = [self expectationWithDescription:@"parseURI"];
    [twincodeOutboundService parseUriWithUri:uri withBlock:^(TLBaseServiceErrorCode errorCode, TLTwincodeURI* twincodeURI) {
        status = errorCode;
        result = twincodeURI;
        [self.testExpectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError *error) {
        NSLog(@"%@ parseURI failed: %@", LOG_TAG, error);
        self.testExpectation = nil;
    }];

    XCTAssertEqual(status, TLBaseServiceErrorCodeSuccess, @"parseURI returned bad code");
    XCTAssertEqual(result.kind, TLTwincodeURIKindProxy, @"parseURI returned bad twincode Kind");
    XCTAssertTrue([@"1.2.3.4" isEqual:result.twincodeOptions], @"parseURI returned options");

    // Check with an IPv4 address and a port.
    uri = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"https://%@/92.2.3.4:445", [TLTwincodeURI PROXY_ACTION]]];
    self.testExpectation = [self expectationWithDescription:@"parseURI"];
    [twincodeOutboundService parseUriWithUri:uri withBlock:^(TLBaseServiceErrorCode errorCode, TLTwincodeURI* twincodeURI) {
        status = errorCode;
        result = twincodeURI;
        [self.testExpectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError *error) {
        NSLog(@"%@ parseURI failed: %@", LOG_TAG, error);
        self.testExpectation = nil;
    }];

    XCTAssertEqual(status, TLBaseServiceErrorCodeSuccess, @"parseURI returned bad code");
    XCTAssertEqual(result.kind, TLTwincodeURIKindProxy, @"parseURI returned bad twincode Kind");
    XCTAssertTrue([@"92.2.3.4:445" isEqual:result.twincodeOptions], @"parseURI returned options");

    // Check with a hostname.
    uri = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"https://%@/ws.skred.mobi", [TLTwincodeURI PROXY_ACTION]]];
    self.testExpectation = [self expectationWithDescription:@"parseURI"];
    [twincodeOutboundService parseUriWithUri:uri withBlock:^(TLBaseServiceErrorCode errorCode, TLTwincodeURI* twincodeURI) {
        status = errorCode;
        result = twincodeURI;
        [self.testExpectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError *error) {
        NSLog(@"%@ parseURI failed: %@", LOG_TAG, error);
        self.testExpectation = nil;
    }];

    XCTAssertEqual(status, TLBaseServiceErrorCodeSuccess, @"parseURI returned bad code");
    XCTAssertEqual(result.kind, TLTwincodeURIKindProxy, @"parseURI returned bad twincode Kind");
    XCTAssertEqual([@"ws.skred.mobi" isEqual:result.twincodeOptions], @"parseURI returned options");

}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end

//
//  AsyncTesting.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 05/03/14.
//
//

// Set the flag for a block completion handler
#define StartBlock() __block BOOL waitingForBlock = YES

// Set the flag to stop the loop
#define EndBlock() waitingForBlock = NO

// Wait and loop until flag is set
#define WaitUntilBlockCompletes() WaitWhile(waitingForBlock)

// Macro - Wait for condition to be NO/false in blocks and asynchronous calls
#define WaitWhile(condition) \
do { \
NSDate* __startTime = [NSDate date]; \
while(condition) { \
[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]]; \
if ([[NSDate date] timeIntervalSinceDate:__startTime] > 30.0) { \
XCTAssertFalse(true, @"Asynchronous test timed out."); \
break; \
} \
} \
} while(0)

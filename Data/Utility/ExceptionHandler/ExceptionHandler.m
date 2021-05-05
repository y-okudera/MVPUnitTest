//
//  ExceptionHandler.m
//  Data
//
//  Created by okudera on 2021/05/04.
//

#import "ExceptionHandler.h"

@implementation ExceptionHandler
+ (BOOL)catchExceptionWithTryBlock:(__attribute__((noescape)) void(^ _Nonnull)(void))tryBlock
                             error:(NSError * _Nullable __autoreleasing * _Nullable)error
{
    @try {
        tryBlock();
        return YES;
    } @catch (NSException *exception) {
        NSString *domain = [NSString stringWithFormat:@"%@.ExceptionHandler", [NSBundle mainBundle].bundleIdentifier];
        NSMutableDictionary * info = [NSMutableDictionary dictionary];
        info[@"ExceptionName"] = exception.name;
        info[@"ExceptionReason"] = exception.reason;
        info[@"ExceptionCallStackReturnAddresses"] = exception.callStackReturnAddresses;
        info[@"ExceptionCallStackSymbols"] = exception.callStackSymbols;
        info[@"ExceptionUserInfo"] = exception.userInfo;
        *error = [[NSError alloc] initWithDomain:domain code:-9999 userInfo:info];
        return NO;
    }
}
@end

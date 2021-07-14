//
//  UniInstance.m
//  GDPlayer
//
//  Created by 徐照临 on 2021/7/12.
//

#import "UniInstance.h"

@implementation UniInstance
@synthesize sdkInstance;

static UniInstance *instance = nil;


+ (UniInstance *) getInstance {
    @synchronized (self) {
        if (instance == nil) {
            instance = [UniInstance new];
        }
    }
    return instance;
}

@end

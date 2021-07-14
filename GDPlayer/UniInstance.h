//
//  UniInstance.h
//  GDPlayer
//
//  Created by 徐照临 on 2021/7/12.
//

#import "DCUniBasePlugin.h"

@interface UniInstance : NSObject
@property(nonatomic, retain) DCUniSDKInstance *sdkInstance;
+(UniInstance *) getInstance;
@end

//
//  ZFTableViewCellLayout.h
//  GDPlayer
//
//  Created by 徐照临 on 2021/7/13.
//

#import <Foundation/Foundation.h>
#import "ZFTableData.h"

@interface ZFTableViewCellLayout : NSObject
@property (nonatomic, strong) ZFTableData *data;
@property (nonatomic, readonly) CGRect videoRect;
@property (nonatomic, readonly) CGRect playBtnRect;
@property (nonatomic, readonly) CGRect titleLabelRect;
@property (nonatomic, readonly) CGRect maskViewRect;
@property (nonatomic, readonly) CGFloat height;
@property (nonatomic, readonly) BOOL isVerticalVideo;

- (instancetype)initWithData:(ZFTableData *)data;

- (instancetype)initWXData:(ZFTableData *)data;


@end

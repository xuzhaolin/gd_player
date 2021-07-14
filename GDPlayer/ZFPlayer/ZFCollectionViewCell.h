//
//  ZFCollectionViewCell.h
//  Player
//
//  Created by 任子丰 on 17/3/22.
//  Copyright © 2017年 任子丰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZFCollectionViewCell : UIView
@property (nonatomic, strong) UIImageView *coverImageView;
@property (nonatomic, strong) UIButton *playBtn;
/// 播放按钮block 
@property (nonatomic, copy  ) void(^playBlock)(UIButton *sender);

- (void) coverUrl:(NSString *) coverURL ;

@end

//
//  ZFCollectionViewCell.m
//  Player
//
//  Created by 任子丰 on 17/3/22.
//  Copyright © 2017年 任子丰. All rights reserved.
//

#import "ZFCollectionViewCell.h"
#import "UIImageView+ZFCache.h"
#import "ZFUtilities.h"
#define kPlayerViewTag 100

@implementation ZFCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.coverImageView.tag = kPlayerViewTag;
        [self addSubview:self.coverImageView];
        [self.coverImageView addSubview:self.playBtn];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.coverImageView.frame = self.bounds;
    self.playBtn.frame = CGRectMake(0, 0, 44, 44);
    self.playBtn.center = self.coverImageView.center;
}

- (void)coverUrl:(NSString *) coverURL {
    [self.coverImageView setImageWithURLString:coverURL placeholder:ZFPlayer_Image(@"ZFPlayer_loadingBg")];
}

- (UIImageView *)coverImageView {
    if (!_coverImageView) {
        _coverImageView = [[UIImageView alloc] init];
        _coverImageView.userInteractionEnabled = YES;
        _coverImageView.tag = kPlayerViewTag;
        _coverImageView.contentMode = UIViewContentModeScaleAspectFill;
        _coverImageView.clipsToBounds = YES;
    }
    return _coverImageView;
}


- (void)playBtnClick:(UIButton *)sender {
    if (self.playBlock) {
        self.playBlock(sender);
    }
}

- (UIButton *)playBtn {
    if (!_playBtn) {
        _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playBtn setImage: ZFPlayer_Image(@"new_allPlay_44x44_") forState:UIControlStateNormal];
        [_playBtn addTarget:self action:@selector(playBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playBtn;
}
@end

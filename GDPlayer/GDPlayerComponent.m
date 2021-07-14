//
//  GDPlayerComponent.m
//  GDPlayer
//
//  Created by 徐照临 on 2021/7/12.
//

#import "GDPlayerComponent.h"
#import "DCUniConvert.h"
#import "ZFIJKPlayerManager.h"
#import "ZFPlayerControlView.h"
#import "UIView+ZFFrame.h"
#import "UIImageView+ZFCache.h"
#import "ZFPlayerConst.h"
#import "ZFUtilities.h"
#import "ZFCollectionViewCell.h"
#import "UIImageView+ZFCache.h"

@interface GDPlayerComponent ()

@property (nonatomic, strong) ZFPlayerController *player;
@property (nonatomic, strong) UIImageView *containerView;
@property (nonatomic, strong) ZFCollectionViewCell *cell;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIImageView *coverImageView;
@property (nonatomic, strong) ZFPlayerControlView *controlView;

@property (nonatomic, strong) NSString *coverUrl;
@property (nonatomic, strong) NSString *src;

@property (nonatomic, assign) BOOL playEvent;
@property (nonatomic, assign) BOOL pauseEvent;
@property (nonatomic, assign) BOOL timeUpdateEvent;
@property (nonatomic, assign) BOOL endedEvent;
@property (nonatomic, assign) BOOL waitingEvent;
@property (nonatomic, assign) BOOL fullScreenchangeEvent;
@property (nonatomic, assign) BOOL controlStoggleEvent;
@property (nonatomic, assign) BOOL progressEvent;
@property (nonatomic, assign) BOOL errorEvent;
@property (nonatomic, assign) BOOL backgroundPlayEvent;
@property (nonatomic, assign) BOOL loadedmetadataEvent;
@property (nonatomic, assign) NSString *objectFit;
@property (nonatomic, assign) NSString *title;
@property (nonatomic, assign) BOOL showPlayBtn;



@end

@implementation GDPlayerComponent

- (void)onCreateComponentWithRef:(NSString *)ref type:(NSString *)type styles:(NSDictionary *)styles attributes:(NSDictionary *)attributes events:(NSArray *)events uniInstance:(DCUniSDKInstance *)uniInstance {
    NSLog(@"Dictionary: %@", [styles description]);
    if (attributes[@"poster"]) {
        _coverUrl = [DCUniConvert NSString: attributes[@"poster"]];
    }
    
    if (attributes[@"src"]) {
        _src = [DCUniConvert NSString: attributes[@"src"]];
    }
    
    if (attributes[@"title"]) {
        _title = [DCUniConvert NSString: attributes[@"title"]];
    }
    
    if (attributes[@"object-fit"]) {
        _objectFit = [DCUniConvert NSString: attributes[@"object-fit"]];
    }
    
    if (attributes[@"show-play-btn"]) {
        _showPlayBtn = [DCUniConvert BOOL: attributes[@"show-play-btn"]];
    } else {
        _showPlayBtn = YES;
    }
}


- (void)viewWillUnload {
    if(!self.player.pauseWhenAppResignActive) {
        self.player.pauseWhenAppResignActive = YES;
    }
    self.player.viewControllerDisappear = YES;
}

- (UIView *)loadView {
    [self setupView];
    return self.contentView;
}

- (void)setupView {
    [self setupPlayer];
    self.player.viewControllerDisappear = NO;
    self.contentView = [[UIView alloc] init];
    self.contentView.backgroundColor = [UIColor blackColor];
    [self.contentView addSubview: self.player.containerView];
    NSLog(@"%@", NSStringFromCGRect(self.contentView.frame));
   
    
}

- (void)viewDidLoad {
    ZFCollectionViewCell *cell = [[ZFCollectionViewCell alloc] initWithFrame: self.contentView.frame];
    self.cell = cell;
    [self.cell coverUrl: _coverUrl];
    if (_showPlayBtn) {
        self.cell.playBtn.hidden = NO;
    } else {
        self.cell.playBtn.hidden = YES;
    }
    self.containerView.frame = self.contentView.frame;
    @zf_weakify(self)
    self.cell.playBlock = ^(UIButton *sender) {
        weak_self.cell.hidden = YES;
        [weak_self play];
    };
    [self.contentView addSubview: cell];
}


- (void)setupPlayer {
    
    ZFIJKPlayerManager *playerManager = [[ZFIJKPlayerManager alloc] init];
    
    self.player = [[ZFPlayerController alloc] initWithPlayerManager:playerManager containerView:self.containerView];
    self.player.controlView = self.controlView;
    [self.controlView showTitle:self.title coverURLString: self.coverUrl fullScreenMode: ZFFullScreenModeLandscape];
    self.player.shouldAutoPlay = NO;
    self.player.playerDisapperaPercent = 1.0;

    @zf_weakify(self)
    self.player.orientationWillChange = ^(ZFPlayerController * _Nonnull player, BOOL isFullScreen) {
        [weak_self videoFullScreenChangeEventHandler:isFullScreen];
    };
    
    self.player.playerPlayTimeChanged = ^(id<ZFPlayerMediaPlayback> asset, NSTimeInterval currentTime, NSTimeInterval duration) {
        [weak_self videoTimeUpdateEventHandler:currentTime:duration];
    };
    
    
    self.player.playerPlayStateChanged = ^(id<ZFPlayerMediaPlayback> asset, ZFPlayerPlaybackState playState) {
        if (playState == ZFPlayerPlayStatePlaying) {
            [weak_self videoPlayEventHandler];
        } else if (playState == ZFPlayerPlayStatePaused) {
            [weak_self videoPauseEventHandler];
        }
    };
    
    self.player.playerReadyToPlay = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, NSURL * _Nonnull assetURL) {
       
    };
    
    self.player.playerLoadStateChanged = ^(id<ZFPlayerMediaPlayback> asset, ZFPlayerLoadState loadState) {
        if (loadState == ZFPlayerLoadStatePrepare) {
//            [weak_self.player.activity stopAnimating];
           
        } else if (loadState == ZFPlayerLoadStateStalled) {
            [weak_self videoWaitingEventHandler];
        } else if (loadState == ZFPlayerLoadStatePlaythroughOK) {
            NSInteger totalTime = asset.totalTime;
            NSInteger width = asset.presentationSize.width;
            NSInteger height = asset.presentationSize.height;
            [weak_self videoLoadedmetadataEventHandler:totalTime:width:height];
        }
    };
    
    self.player.playerPlayFailed = ^(id<ZFPlayerMediaPlayback> asset, id error) {
        [weak_self videoErrorEventHandler];
    };
    
    self.player.playerDidToEnd = ^(id<ZFPlayerMediaPlayback> asset) {
        NSInteger totalTime = weak_self.player.currentPlayerManager.totalTime;
        [weak_self videoTimeUpdateEventHandler:totalTime:totalTime];
        [weak_self videoEndedEventHandler];
    };
    
    self.player.audioPlayStateChange = ^(BOOL isAudioPlay) {
        [weak_self videoPlayInBackgroundEventHandler:isAudioPlay];
    };
    
    
    [self objectFitUpdate];
    
    
}

- (UIImageView *)containerView {
    if (!_containerView) {
        _containerView = [UIImageView new];
        [_containerView setImageWithURLString:_coverUrl placeholder:[ZFUtilities imageWithColor:[UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1] size:CGSizeMake(1, 1)]];
    }
    return _containerView;
}


- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden {
    return self.player.isStatusBarHidden;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationNone;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}


- (ZFPlayerControlView *)controlView {
    if (!_controlView) {
        _controlView = [ZFPlayerControlView new];
//        _controlView.prepareShowLoading = YES;
        _controlView.prepareShowControlView = YES;
    }
    return _controlView;
}



- (void)addEvent:(NSString *)eventName {
    if ([eventName isEqualToString:@"play"]) {
        _playEvent = YES;
    }
    
    if ([eventName isEqualToString:@"ended"]) {
        _endedEvent = YES;
    }
    
    if ([eventName isEqualToString:@"pause"]) {
        _pauseEvent = YES;
    }
    
    if ([eventName isEqualToString:@"timeupdate"]) {
        _timeUpdateEvent = YES;
    }
    
    if ([eventName isEqualToString:@"fullscreenchange"]) {
        _fullScreenchangeEvent = YES;
    }
    
    if ([eventName isEqualToString:@"waiting"]) {
        _waitingEvent = YES;
    }
    
    if ([eventName isEqualToString:@"error"]) {
        _errorEvent = YES;
    }
    
    if ([eventName isEqualToString:@"progress"]) {
        _progressEvent = YES;
    }
    
    if ([eventName isEqualToString:@"controlstoggle"]) {
        _controlStoggleEvent = YES;
    }
    
    if ([eventName isEqualToString:@"backgroundplay"]) {
        _backgroundPlayEvent = YES;
    }
    
    if ([eventName isEqualToString:@"loadedmetadata"]) {
        _loadedmetadataEvent = YES;
    }
    
}

/// 对应的移除事件回调方法
/// @param eventName 事件名称
- (void)removeEvent:(NSString *)eventName {
    if ([eventName isEqualToString:@"play"]) {
        _playEvent = NO;
    }
    
    if ([eventName isEqualToString:@"ended"]) {
        _endedEvent = NO;
    }
    
    if ([eventName isEqualToString:@"pause"]) {
        _pauseEvent = NO;
    }
    
    if ([eventName isEqualToString:@"timeupdate"]) {
        _timeUpdateEvent = NO;
    }
    
    if ([eventName isEqualToString:@"fullscreenchange"]) {
        _fullScreenchangeEvent = NO;
    }
    
    if ([eventName isEqualToString:@"waiting"]) {
        _waitingEvent = NO;
    }
    
    if ([eventName isEqualToString:@"error"]) {
        _errorEvent = NO;
    }
    
    if ([eventName isEqualToString:@"progress"]) {
        _progressEvent = NO;
    }
    
    if ([eventName isEqualToString:@"controlstoggle"]) {
        _controlStoggleEvent = NO;
    }
    
    if ([eventName isEqualToString:@"fullscreenchange"]) {
        _fullScreenchangeEvent = NO;
    }
    
    if ([eventName isEqualToString:@"backgroundplay"]) {
        _backgroundPlayEvent = NO;
    }
    
    if ([eventName isEqualToString:@"loadedmetadata"]) {
        _loadedmetadataEvent = NO;
    }
    
}

- (void) showCover {
    self.cell.hidden = NO;
    self.cell.playBtn.hidden = YES;
//    weak_self.containerView.frame = weak_self.contentView.frame;
}

- (void) showPlay {
    self.cell.hidden = YES;
    self.containerView.frame = self.contentView.frame;
}


// JS EVENT
- (void)videoPlayEventHandler {
    if (_playEvent) {
        [self fireEvent:@"play" params: nil domChanges:nil];
    }
}

- (void) videoPauseEventHandler {
    if (_pauseEvent) {
        [self fireEvent:@"pause" params: nil domChanges:nil];
    }
}

- (void) videoEndedEventHandler {
    if (_endedEvent) {
        [self fireEvent:@"ended" params: nil domChanges:nil];
    }
}

- (void) videoFullScreenChangeEventHandler: (BOOL) isFullScreen {
    if (_fullScreenchangeEvent) {
        NSString *isFullScreenStr = isFullScreen ? @"true" : @"false";
        [self fireEvent:@"fullscreenchange" params: @{@"detail":@{@"isFullScreen": isFullScreenStr}} domChanges:nil];
    }
}

- (void) videoWaitingEventHandler {
    if (_waitingEvent) {
        [self fireEvent:@"waiting" params: nil domChanges:nil];
    }
}

- (void) videoErrorEventHandler {
    if (_errorEvent) {
        [self fireEvent:@"waiting" params: nil domChanges:nil];
    }
}

- (void) videoProgressEventHandler {
    if (_errorEvent) {
        [self fireEvent:@"progress" params: nil domChanges:nil];
    }
}

- (void) videoControlStoggleEventHandler {
    if (_errorEvent) {
        [self fireEvent:@"controlStoggle" params: nil domChanges:nil];
    }
}

- (void) videoPlayInBackgroundEventHandler: (BOOL) playInBackground {
    if (playInBackground) {
        self.player.currentPlayerManager.view.playerView.hidden = YES;
        self.player.currentPlayerManager.view.coverImageView.hidden = NO;
    } else {
        self.player.currentPlayerManager.view.playerView.hidden = NO;
        self.player.currentPlayerManager.view.coverImageView.hidden = YES;
    }
    if (_backgroundPlayEvent) {
        NSString *str = playInBackground ? @"true" : @"false";
        [self fireEvent:@"backgroundplay" params: @{@"detail":@{@"playInBackground": str}}];
    }
}

- (void) videoAudioPlayer: (BOOL)pauseWhenAppResignActive {
    if (pauseWhenAppResignActive) {
        self.cell.hidden = NO;
        self.cell.playBtn.hidden = YES;
    } else {
        self.cell.hidden = YES;
    }
}

- (void) videoLoadedmetadataEventHandler:(NSInteger) totalTime:(NSInteger) width:(NSInteger) height {
    NSString *totalTimeStr = [NSString stringWithFormat:@"%ld", (long)totalTime];
    NSString *widthStr = [NSString stringWithFormat:@"%ld", (long)width];
    NSString *heightStr = [NSString stringWithFormat:@"%ld", (long)height];
    if (_loadedmetadataEvent) {
        [self fireEvent:@"loadedmetadata" params: @{@"detail":@{@"duration": totalTimeStr, @"width": widthStr,@"height": heightStr}} domChanges:nil];
    }
}


- (void) videoTimeUpdateEventHandler: (NSTimeInterval) currentDuration: (NSTimeInterval) duration {
    NSInteger currentTimeInt = currentDuration;
    NSInteger totalTime = duration;
    NSString *currentTimeStr = [NSString stringWithFormat:@"%ld", (long)currentTimeInt];
    NSString *totalDurationStr = [NSString stringWithFormat:@"%ld", (long)totalTime];
    if (_timeUpdateEvent) {
        [self fireEvent:@"timeupdate" params: @{@"detail":@{@"currentTime": currentTimeStr, @"duration": totalDurationStr}} domChanges:nil];
    }
}

// 属性更新
- (void)updateAttributes:(NSDictionary *)attributes {
    if (attributes[@"object-fit"]) {
        self.objectFit = [DCUniConvert NSString: attributes[@"object-fit"]];
        [self objectFitUpdate];
    }
    
    if (attributes[@"src"]) {
        self.src = [DCUniConvert NSString: attributes[@"src"]];
        if (self.player.currentPlayerManager.isPlaying) {
            [self.player.currentPlayerManager playerReadyToPlay];
            self.player.assetURL = [NSURL URLWithString: self.src];
        }
    }
    
    if (attributes[@"poster"]) {
        self.coverUrl = [DCUniConvert NSString: attributes[@"poster"]];
        [self.cell coverUrl: _coverUrl];
        [self.controlView showTitle:self.title coverURLString: self.coverUrl fullScreenMode: ZFFullScreenModeLandscape];
    }
    
    if (attributes[@"title"]) {
        self.title = [DCUniConvert NSString: attributes[@"title"]];
        [self.controlView showTitle:self.title coverURLString: self.coverUrl fullScreenMode: ZFFullScreenModeLandscape];
    }
    
}



- (void) objectFitUpdate {
    if (self.objectFit != nil && self.objectFit != NULL) {
        if ([self.objectFit isEqualToString: @"contain"]) {
            [self.player.currentPlayerManager setScalingMode: ZFPlayerScalingModeAspectFit];
        } else if ([self.objectFit isEqualToString: @"fill"]) {
            [self.player.currentPlayerManager setScalingMode: ZFPlayerScalingModeAspectFill];
        } else {
            [self.player.currentPlayerManager setScalingMode: ZFPlayerScalingModeFill];
        }
    } else {
        [self.player.currentPlayerManager setScalingMode: ZFPlayerScalingModeFill];
    }
}



// JS方法
UNI_EXPORT_METHOD(@selector(play))
- (void)play {
    if (self.src != nil && self.src != NULL && !self.player.currentPlayerManager.isPlaying) {
        self.controlView.prepareShowLoading = YES;
        if (self.player.currentPlayerManager.playState == ZFPlayerPlayStatePaused) {
            [self.player.currentPlayerManager play];
        } else if (self.player.currentPlayerManager.playState ==  ZFPlayerPlayStatePlayStopped){
            [self.player.currentPlayerManager replay];
        } else {
            self.player.assetURL = [NSURL URLWithString:_src];
        }
        self.cell.hidden = YES;
    }
}

UNI_EXPORT_METHOD(@selector(pause))
- (void)pause {
    if (self.player.currentPlayerManager.isPlaying) {
        [self.player.currentPlayerManager pause];
    }
}

UNI_EXPORT_METHOD(@selector(next:))
- (void)next:(NSDictionary *)options {
    NSString *url = [DCUniConvert NSString: options[@"url"]];
    if (url != nil && url != NULL) {
        self.src = url;
        [self.player.currentPlayerManager playerReadyToPlay];
        self.player.assetURL = [NSURL URLWithString: self.src];
    }
}


UNI_EXPORT_METHOD(@selector(replay))
- (void)replay {
    [self.player seekToTime:0 completionHandler:nil];
    [self.player.currentPlayerManager play];

}

UNI_EXPORT_METHOD(@selector(audioPlay))
- (void) audioPlay {
    
}

UNI_EXPORT_METHOD(@selector(requestFullScreen))
- (void) requestFullScreen {
    if (!self.player.isFullScreen) {
        [self.player enterFullScreen:YES animated:YES];
    }
}

UNI_EXPORT_METHOD(@selector(exitFullScreen))
- (void) exitFullScreen {
    if (self.player.isFullScreen) {
        [self.player enterFullScreen:NO animated:YES];
    }
}

UNI_EXPORT_METHOD(@selector(seekTo:))
- (void) seekTo:(NSDictionary *)options {
    NSInteger seekTime = 0;
    NSInteger totalTime = self.player.currentPlayerManager.totalTime;
    if (options[@"time"]) {
        seekTime = [DCUniConvert NSInteger: options[@"time"]];
    }
    if (seekTime > totalTime) {
        seekTime = totalTime;
    }
    [self.player seekToTime:seekTime completionHandler:nil];
    BOOL isPlay = FALSE;
    if (options[@"isPlay"]) {
        isPlay = [DCUniConvert BOOL: options[@"isPlay"]];
    }
    if (isPlay) {
        [self.player.currentPlayerManager play];
    } else {
        [self.player.currentPlayerManager pause];
    }
}





@end

//
//  ZFLandScaprWindow.m
//  ZFPlayer
//
// Copyright (c) 2020年 任子丰 ( http://github.com/renzifeng )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "ZFLandscapeWindow.h"

@implementation ZFLandscapeWindow
@dynamic rootViewController;

- (void)setBackgroundColor:(nullable UIColor *)backgroundColor {}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    NSLog(@"%@", NSStringFromCGRect(frame));
    if (self) {
        self.windowLevel = UIWindowLevelNormal;
        _landscapeViewController = [[ZFLandscapeViewController alloc] init];
//        UIViewController *vc = [[self class] dc_findCurrentShowingViewController];
//        [vc.navigationController pushViewController:_landscapeViewController animated:YES];
//
        self.rootViewController = _landscapeViewController;
        if (@available(iOS 13.0, *)) {
            if (self.windowScene == nil) {
                self.windowScene = UIApplication.sharedApplication.keyWindow.windowScene;
            }
        }
        
        
        self.hidden = YES;
    }
    return self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *_Nullable)event {
    return YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    static CGRect bounds;
    if (!CGRectEqualToRect(bounds, self.bounds)) {
        UIView *superview = self;
        if (@available(iOS 13.0, *)) {
            superview = self.subviews.firstObject;
        }
        [UIView performWithoutAnimation:^{
            for (UIView *view in superview.subviews) {
                if (view != self.rootViewController.view && [view isMemberOfClass:UIView.class]) {
                    view.backgroundColor = UIColor.clearColor;
                    for (UIView *subview in view.subviews) {
                        subview.backgroundColor = UIColor.clearColor;
                    }
                }
            }
        }];
    }
    bounds = self.bounds;
    self.rootViewController.view.frame = bounds;
}


+ (UIViewController *)dc_findCurrentShowingViewController{
    //获取当前活动窗口的根识图
    UIViewController* vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *currentShowingVC = [self findCurrentShowingViewControllerFrom:vc];
    return currentShowingVC;
    }


+ (UIViewController *)findCurrentShowingViewControllerFrom: (UIViewController*) vc {
        UIViewController *currentShowingVC;
            if([vc presentedViewController]){
                //当前视图是被presented出来的
                UIViewController *nextRootVC = [vc presentedViewController];
                currentShowingVC = [self findCurrentShowingViewControllerFrom:nextRootVC];
            } else if([vc isKindOfClass:[UITabBarController class]]){
                // 根视图为UITabBarController
                UIViewController *nextRootVC = [(UITabBarController *)vc selectedViewController];
                currentShowingVC = [self findCurrentShowingViewControllerFrom:nextRootVC];
            } else if ([vc isKindOfClass:[UINavigationController class]]){
                // 根视图为UINavigationController
                UIViewController *nextRootVC = [(UINavigationController *)vc visibleViewController];
                currentShowingVC = nextRootVC;
                //        currentShowingVC = [self findCurrentShowingViewControllerFrom:nextRootVC];
            } else {
                // 根视图为非导航类
                currentShowingVC = vc;
            }
            
            return currentShowingVC;
    }



@end

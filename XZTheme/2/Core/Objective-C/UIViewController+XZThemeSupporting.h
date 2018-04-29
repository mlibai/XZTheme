//
//  UIViewController+XZTheme.h
//  Example
//
//  Created by mlibai on 2018/4/24.
//  Copyright © 2018年 mlibai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSObject+XZThemeSupporting.h"

@interface UIViewController (XZThemeSupporting)

/// 在 UIViewController 中：
/// @note 控制器每次显示时都会检查当前已应用的主题是否与当前主题是否一致，从而决定是否需要刷新主题外观。
+ (void)load;

/// 作为控制器，当其自身被标记为需要应用主题时，会同时标记其 childViewControllers、presentedViewController、navigationItem、toolbarItems、tabBarItem 。
- (void)xz_setNeedsThemeAppearanceUpdate;

@end

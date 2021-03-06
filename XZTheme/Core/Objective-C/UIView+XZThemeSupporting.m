//
//  UIView+XZTheme.m
//  XZKit
//
//  Created by mlibai on 2018/4/24.
//  Copyright © 2018年 mlibai. All rights reserved.
//

#import "UIView+XZThemeSupporting.h"
#import "XZTheme/XZTheme-Swift.h"
@import ObjectiveC;

@implementation UIView (XZThemeSupporting)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class cls = [UIView class];
        Method m1 = class_getInstanceMethod(cls, @selector(willMoveToSuperview:));
        Method m2 = class_getInstanceMethod(cls, @selector(XZTheme_willMoveToSuperview:));
        method_exchangeImplementations(m1, m2);
    });
}

- (void)XZTheme_willMoveToSuperview:(nullable UIView *)newSuperview {
    [self XZTheme_willMoveToSuperview:newSuperview];
    
    // 不在父视图上的控件没有显示，不需要操作。
    if (newSuperview == nil) { return; }
    // 如果已应用的主题与当前主题一致，不需要操作。
    // 如果视图没有配置过主题，但是不代表子视图没有配置主题。
    if ([[self xz_appliedTheme] isEqual:[XZTheme currentTheme]]) {
        return;
    }
    // MARK: 仅标记是否在显示效果上会延迟，待验证。
    [self xz_setNeedsThemeAppearanceUpdate];
}


@end




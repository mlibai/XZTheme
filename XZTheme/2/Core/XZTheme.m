//
//  XZTheme.m
//  XZTheme
//
//  Created by mlibai on 2018/4/23.
//  Copyright © 2018年 mlibai. All rights reserved.
//

#import "XZTheme.h"
#import "XZThemeStyles.h"
#import "NSObject+XZTheme.h"
@import ObjectiveC;


XZTheme const XZThemeDefault = @"default";

static const void * const _theme = &_theme;

static XZTheme _Nonnull _currentTheme = XZThemeDefault;

@implementation XZThemes {
    NSMutableDictionary<XZTheme, XZThemeStyles *> *_styles;
}

+ (XZTheme)currentTheme {
    return _currentTheme;
}

+ (void)setCurrentTheme:(XZTheme)currentTheme {
    if (![_currentTheme isEqualToString:currentTheme]) {
        _currentTheme = [currentTheme copy];
        
        [NSUserDefaults.standardUserDefaults setObject:_currentTheme forKey:XZThemeUserDefaultsKey];
        // send events.
        for (UIWindow *window in UIApplication.sharedApplication.windows) {
            // 当前正显示的视图，立即更新视图。方便设置动画渐变效果。
            [window xz_setNeedsThemeAppearanceUpdate];
            [window xz_updateThemeAppearanceIfNeeded];
            [window.rootViewController xz_setNeedsThemeAppearanceUpdate];
            [window.rootViewController xz_updateThemeAppearanceIfNeeded];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:XZThemeDidChangeNotification object:_currentTheme];
    }
}

- (instancetype)initWithObject:(UIView *)object {
    self = [super init];
    if (self != nil) {
        _object = object;
        _styles = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(object, _theme, self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return self;
}

- (XZThemeStyles *)styleForTheme:(XZTheme)theme {
    XZThemeStyles *themeStyle = _styles[theme];
    if (themeStyle != nil) {
        return themeStyle;
    }
    themeStyle = [[XZThemeStyles alloc] init];
    _styles[theme] = themeStyle;
    return themeStyle;
}

- (void)setStyle:(XZThemeStyles *)style forTheme:(XZTheme)theme {
    _styles[theme] = style;
}


- (XZThemeStyles *)defaultStyle {
    return [self styleForTheme:XZThemeDefault];
}

@end






@implementation NSObject (XZThemeSupporting)

- (XZThemes *)xz_themes {
    XZThemes *theme = objc_getAssociatedObject(self, _theme);
    if (theme != nil) {
        return theme;
    }
    theme = [[XZThemes alloc] initWithObject:self];
    return theme;
}

- (XZThemes *)xz_themesIfLoaded {
    return objc_getAssociatedObject(self, _theme);
}

@end



NSNotificationName const _Nonnull XZThemeDidChangeNotification  = @"com.mlibai.XZKit.theme.changed";
NSString         * const _Nonnull XZThemeUserDefaultsKey        = @"com.mlibai.XZKit.theme.default";

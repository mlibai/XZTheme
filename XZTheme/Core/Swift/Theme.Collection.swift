//
//  Theme.Collection.swift
//  XZKit
//
//  Created by mlibai on 2018/5/2.
//  Copyright © 2018年 mlibai. All rights reserved.
//

import Foundation

extension Theme.Collection {
    
    /// 获取默认主题的样式的快捷方法。
    /// - Note: 该方法等同于调用 themeStyle(forTheme:) 方法。
    /// - Note: 建议给自定义主题添加类似的访问方法。
    public var `default`: Theme.Style.Collection {
        return themeStyles(forTheme: .default)
    }
    
}

extension Theme.Collection {
    
    /// 获取已设置的主题样式（如果有）。
    ///
    /// - Parameter theme: 主题。
    /// - Returns: 主题样式集合。
    @objc public func themeStylesIfLoaded(forTheme theme: Theme) -> Theme.Style.Collection? {
        return themedStylesIfLoaded?[theme]
    }
    
    /// 获取已设置的主题样式，如果主题对应的样式不存在，则会自动创建。
    ///
    /// - Parameter theme: 主题。
    /// - Returns: 主题样式。
    @objc public func themeStyles(forTheme theme: Theme) -> Theme.Style.Collection {
        if let themeStyles = themedStylesIfLoaded?[theme] {
            return themeStyles
        }
        let themeStyles = Theme.Style.Collection.init(object: self.object, themes: self, theme: theme)
        setThemeStyles(themeStyles, forTheme: theme)
        return themeStyles
    }
    
    /// 设置主题样式。
    ///
    /// - Parameter themeStyles: 主题样式。
    /// - Parameter theme: 主题。
    @objc public func setThemeStyles(_ themeStyles: Theme.Style.Collection, forTheme theme: Theme) {
        themedStyles[theme] = themeStyles
    }
    
    /// 当前生效的主题样式集。如果所有者没有配置主题样式集，则返回全局主题样式集（如果有）。
    ///
    /// - Parameter theme: 主题。
    /// - Returns: 主题样式集。
    @objc public func effectiveThemeStyles(forTheme theme: Theme) -> Theme.Style.Collection? {
        if let themeStyles = themeStylesIfLoaded(forTheme: theme) {
            return themeStyles
        }
        var superThemes: Theme.Collection! = self.superThemes
        
        while superThemes != nil {
            if let themeStyles = superThemes.themeStylesIfLoaded(forTheme: theme) {
                return themeStyles
            }
            superThemes = superThemes.superThemes
        }
        
        return nil
    }
    
}

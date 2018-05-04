//
//  Theme.Style.swift
//  XZKit
//
//  Created by mlibai on 2018/5/2.
//  Copyright © 2018年 mlibai. All rights reserved.
//

import Foundation

extension Theme.Style {
    
    /// 主题样式是否包含主题属性。
    /// - Note: 因为属性值可以为 nil ，所以判断是否包含属性，不能根据其值来判断。
    ///
    /// - Parameter themeAttribute: 主题属性。
    /// - Returns: 是否包含。
    @objc public func containsThemeAttribute(_ themeAttribute: Theme.Attribute) -> Bool {
        return attributedValues[themeAttribute] != nil
    }
    
    /// 添加/更新/删除主题属性值。
    /// - Note: 设置 nil 值，请使用 updateValue(_:forThemeAttribute:) 方法。
    ///
    /// - Parameter value: 主题属性值。
    /// - Parameter themeAttribute: 主题属性。
    @objc public func setValue(_ value: Any?, forThemeAttribute themeAttribute: Theme.Attribute) {
        attributedValues[themeAttribute] = value
        object.setNeedsThemeAppearanceUpdate()
    }
    
    /// 添加/更新/删除主题属性值。
    ///
    /// - Parameter value: 主题属性值。
    /// - Parameter themeAttribute: 主题属性。
    @objc public func updateValue(_ value: Any?, forThemeAttribute themeAttribute: Theme.Attribute) {
        attributedValues.updateValue(value, forKey: themeAttribute)
        object.setNeedsThemeAppearanceUpdate()
    }
    
    /// 删除主题属性值。
    ///
    /// - Parameter themeAttribute: 主题属性。
    @objc public func removeValue(forThemeAttribute themeAttribute: Theme.Attribute) -> Any? {
        if let value = attributedValues.removeValue(forKey: themeAttribute) {
            object.setNeedsThemeAppearanceUpdate()
            return value
        }
        return nil
    }
    
    /// 获取已设置的主题属性值。
    ///
    /// - Parameter themeAttribute: 主题属性。
    /// - Returns: 主题属性值。
    @objc public func value(forThemeAttribute themeAttribute: Theme.Attribute) -> Any? {
        if let value = attributedValues[themeAttribute] {
            return value
        }
        return nil
    }
    
    /// 获取/添加/更新/删除主题属性值。
    ///
    /// - Parameter themeAttribute: 主题属性。
    @objc public subscript(themeAttribute: Theme.Attribute) -> Any? {
        get { return value(forThemeAttribute: themeAttribute)       }
        set { setValue(newValue, forThemeAttribute: themeAttribute) }
    }
    
    /// 配置主题样式的链式编程方式支持。
    ///
    /// - Parameters:
    ///   - value: 主题属性值。
    ///   - themeAttribute: 主题属性。
    /// - Returns: 当前主题样式对象。
    @discardableResult
    open func setting(_ value: Any?, for themeAttribute: Theme.Attribute) -> Theme.Style {
        setValue(value, forThemeAttribute: themeAttribute)
        return self
    }
    
    /// 更新主题属性值。链式编程支持。
    ///
    /// - Parameters:
    ///   - value: 主题属性值。
    ///   - themeAttribute: 主题属性。
    @discardableResult
    public func updating(_ value: Any?, for themeAttribute: Theme.Attribute) -> Theme.Style {
        updateValue(value, forThemeAttribute: themeAttribute)
        return self
    }
}


extension Array where Element == Theme.Attribute {
    
    /// 获取主题样式中所有已配置值的主题属性。
    ///
    /// - Parameter themeStyle: 主题样式。
    public init(_ themeStyle: Theme.Style) {
        self.init(themeStyle.attributedValues.keys)
    }
}
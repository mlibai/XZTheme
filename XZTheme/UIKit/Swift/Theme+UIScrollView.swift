//
//  Theme+UIScrollView.swift
//  XZKit
//
//  Created by mlibai on 2018/5/1.
//  Copyright © 2018年 mlibai. All rights reserved.
//

import UIKit
import XZKit

extension Theme.Attribute {
    
    /// UIScrollView
    public static let indicatorStyle = Theme.Attribute.init(rawValue: "indicatorStyle")
    
}

extension Theme.Style {
    
    /// 获取已设置的主题属性值：UIScrollViewIndicatorStyle 。如下值将可以自动转换。
    /// 1. UIScrollViewIndicatorStyle 原始值（Int）。
    /// 2. 字符串 default、black、white 。
    ///
    /// - Parameter themeAttribute: 主题属性。
    /// - Returns: 主题属性值。
    public func scrollViewIndicatorStyle(for themeAttribute: Theme.Attribute) -> UIScrollView.IndicatorStyle {
        guard let value = value(for: themeAttribute) else { return .default }
        if let indicatorStyle = value as? UIScrollView.IndicatorStyle {
            return indicatorStyle
        }
        if let number = value as? Int, let indicatorStyle = UIScrollView.IndicatorStyle.init(rawValue: number) {
            return indicatorStyle
        }
        if let aString = value as? String {
            switch aString {
            case "default": return .default
            case "black":   return .black
            case "white":   return .white
            default: break
            }
        }
        XZLog("XZTheme: The theme style value (%@) for attribute (%@) is not a UIScrollViewIndicatorStyle value, `.default` returned.", value, themeAttribute)
        return .default
    }
    
    public var indicatorStyle: UIScrollView.IndicatorStyle {
        get { return scrollViewIndicatorStyle(for: .indicatorStyle) }
        set { setValue(newValue, for: .indicatorStyle) }
    }
    
}

extension UIScrollView {
    
    open override func updateAppearance(with themeStyles: Theme.Style.Collection) {
        super.updateAppearance(with: themeStyles)
        
        if themeStyles.contains(.indicatorStyle) {
            self.indicatorStyle = themeStyles.indicatorStyle
        }
    }
    
}

//
//  Theme.Parser.swift
//  XZKit
//
//  Created by mlibai on 2018/4/30.
//  Copyright © 2018年 mlibai. All rights reserved.
//

import Foundation
import XZKit

extension Theme {
    
    /// 默认的主题样式属性解析器。
    /// - Note: 此属性可写，即可以自定解析方法。
    public static var parser: ThemeParsing = Parser.init()
    
    /// 默认的主题样式解析器。
    @objc(XZThemeParser)
    private final class Parser: NSObject, ThemeParsing {
        
    }
    
}



/// 主题属性值解析器。
/// 配置主题属性值时，使用实际值可能会更效率，但是内存可能不允许。
/// 例如主题样式包含大量图片，虽然 XZTheme 样式存储会随对象一起销毁，但是为了避免某些极端情况的内存问题，XZTheme 允许其它值来设置主题样式，比如图片名字。
/// 在默认规则下， ThemeParser 的作用是负责将样式配置值转换成实际使用值。
public protocol ThemeParsing {
    
    /// 解析样式表。
    ///
    /// - Parameters:
    ///   - sheetURL: 样式表路径。
    ///   - theme: 主题，懒加载，只解析当前主题下的样式。
    /// - Returns: 主题集。
    func parse(_ sheetURL: URL, for theme: Theme) -> Theme.Collection?
    
    /// 将主题属性值解析为 UIColor 对象。
    /// - Note: 在默认实现中，支持使用十六进制颜色值，格式如 0xAABBCCFF、`"#FF0099"`、`"#F0F"`、`"#E2FA237F"` 。
    ///
    /// - Parameter value: 主题属性值。
    /// - Returns: UIColor 对象。
    func parse(_ value: Any?) -> UIColor?
    
    /// 将主题属性值解析为 UIImage 对象。
    /// - Note: 支持使用资源图片名字。
    /// - Note: 支持 animatedImage，格式如下。
    /// ```json
    /// { name: "imageName", duration: 1.2 }
    /// { name: ["image_a", "image_b"], duration: 1.2 }
    /// ```
    ///
    /// - Parameter value: 主图属性值。
    /// - Returns: UIImage 对象。
    func parse(_ value: Any?) -> UIImage?
    
    /// 将主题属性值解析为 UIImage 集合（一般是作为动图使用）。
    /// - Note: 支持使用字符串或字符串数组。
    ///
    /// - Parameter value: 主题属性值。
    /// - Returns: [UIImage]
    func parse(_ value: Any?) -> [UIImage]?
    
    /// 将主题属性值解析为 UIFont 对象，支持使用字体名称或大小。
    /// - 如果值类型为 String，将作为字体名称，使用系统默认字体大小创建字体对象。
    /// - 如果值类型为 CGFloat/Int/Double ，将作为字体大小，使用系统字体创建对象。
    /// - 支持使用如下格式字典。
    /// ```
    /// {name: "fontName", size: 15.0 }
    /// {size: 16.0, weight: 400 }  // 使用系统默认字体。
    /// ```
    /// - Parameter value: 主题属性值。
    /// - Returns: UIFont 对象。
    func parse(_ value: Any?) -> UIFont?
    
    /// 富文本解析。
    /// 如果值已经是 NSAttributedString 则直接返回原始值。
    /// 如果值为字符串，则直接通过此字符串构造 NSAttributedString 。
    /// 如果格式为字典，其目前仅支持如下格式：
    /// ```json
    /// {
    ///     "type": "html"
    ///     "content": "<b>This is the text.</b>"
    /// }
    /// ```
    ///
    /// - Parameter value: 待解析的值。
    /// - Returns: 富文本。
    func parse(_ value: Any?) -> NSAttributedString?
    
    /// 富文本属性。
    /// 目前支持配置字典格式如：
    /// ```
    /// {font: "所有支持的字体解析格式", color: "所有支持的颜色解析格式", backgroundColor: "所有支持的颜色解析格式"}
    /// ```
    ///
    /// - Parameter value: 主题属性值。
    /// - Returns: 富文本属性。
    func parse(_ value: Any?) -> [NSAttributedString.Key: Any]?
}


extension ThemeParsing {
    
    
    public func parse(_ sheetURL: URL, for theme: Theme) -> Theme.Collection? {
        // TODO: - 解析 xzss 样式表。
        // 匹配样式 ^(#day)* *( *\.[a-z\-0-9_]+(\:[a-z]+)*,*)* *\{([^\}]*)\}
        guard let styleDicts = Array<Any>.init(json: try? Data.init(contentsOf: sheetURL, options: .uncached)) else { return nil }
        
        for item in styleDicts {
            guard let styleDict = item as? [String: Any] else {
                break
            }
        }
        
        return nil
    }
    
    public func parse(_ value: Any?) -> UIColor? {
        guard let value = value else { return nil }
        if let color = value as? UIColor {
            return color
        }
        if let number = value as? ColorValue {
            return UIColor.init(number)
        }
        if let number = value as? Int {
            return UIColor.init(ColorValue(number))
        }
        if let string = value as? String {
            return UIColor.init(string)
        }
        XZLog("XZTheme: Unparsable color value (%@), nil returned.", value)
        return nil
    }
    
    public func parse(_ value: Any?) -> UIImage? {
        guard let value = value else { return nil }
        if let image = value as? UIImage {
            return image
        }
        if let imageName = value as? String {
            return UIImage(named: imageName)
        }
        if let dict = value as? [String: Any] {
            if let images: [UIImage] = self.parse(dict["name"]) {
                if let duration = dict["duration"] as? TimeInterval {
                    return UIImage.animatedImage(with: images, duration: duration)
                }
            }
        }
        XZLog("XZTheme: Unparsable image value (%@), nil returned.", value)
        return nil
    }
    
    public func parse(_ value: Any?) -> [UIImage]? {
        guard let value = value else { return nil }
        if let imageName = value as? String {
            var images = [UIImage]()
            for index in 0 ... 1024 {
                guard let image = UIImage(named: String.init(format: "%@%d", imageName, index)) else { break }
                images.append(image)
            }
            return images
        } else if let imageNames = value as? [String] {
            var images = [UIImage]()
            for name in imageNames {
                guard let image = UIImage.init(named: name) else { continue }
                images.append(image)
            }
            return images
        }
        XZLog("XZTheme: Unparsable images value (%@), nil returned.", value)
        return nil
    }
    
    public func parse(_ value: Any?) -> UIFont? {
        guard let value = value else { return nil }
        if let font = value as? UIFont {
            return font
        }
        if let fontName = value as? String {
            return UIFont(name: fontName, size: UIFont.systemFontSize)
        }
        if let fontSize = value as? CGFloat {
            return UIFont.systemFont(ofSize: fontSize)
        }
        if let fontSize = value as? Double {
            return UIFont.systemFont(ofSize: CGFloat(fontSize))
        }
        if let fontSize = value as? Int {
            return UIFont.systemFont(ofSize: CGFloat(fontSize))
        }
        guard let dict = value as? [String: Any] else { return nil }
        
        if let fontName = dict["name"] as? String {
            // name and size
            if let fontSize = dict["size"] as? CGFloat {
                return UIFont(name: fontName, size: fontSize)
            } else {
                return UIFont(name: fontName, size: UIFont.systemFontSize)
            }
        } else if let fontSize = dict["size"] as? CGFloat {
            // systeme font size and weight
            if #available(iOS 8.2, *), let fontWeight = dict["weight"] as? CGFloat {
                return UIFont.systemFont(ofSize: fontSize, weight: UIFont.Weight(rawValue: fontWeight))
            } else {
                return UIFont.systemFont(ofSize: fontSize)
            }
        }
        XZLog("XZTheme: Unparsable font value (%@), system font returned.", value)
        return UIFont.systemFont(ofSize: UIFont.systemFontSize)
    }
    
    public func parse(_ value: Any?) -> NSAttributedString? {
        guard let value = value else { return nil }
        if let attributedString = value as? NSAttributedString {
            return attributedString
        }
        if let dict = value as? [String: Any] {
            if let content = dict["content"] as? String {
                if let type = dict["type"] as? String {
                    switch type {
                    case "html":
                        guard let data = content.data(using: .utf8) else { break }
                        let options = [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html]
                        if let attributedString = try? NSAttributedString.init(data: data, options: options, documentAttributes: nil) {
                            return attributedString;
                        }
                        
                    default: break
                    }
                } else {
                    return NSAttributedString.init(string: content)
                }
            }
        }
        if let string = value as? String {
            return NSAttributedString.init(string: string)
        }
        XZLog("XZTheme: Unparsable AttributedString value (%@), nil returned.", value)
        return nil
    }
    
    public func parse(_ value: Any?) -> [NSAttributedString.Key : Any]? {
        guard let value = value else { return nil }
        if let stringAttributes = value as? [NSAttributedString.Key: Any] {
            return stringAttributes
        }
        if let dict = value as? [String: Any] {
            let font: UIFont? = self.parse(dict["font"])
            let color: UIColor? = self.parse(dict["color"])
            let backgroundColor: UIColor? = self.parse(dict["backgroundColor"])
            if font != nil || color != nil || backgroundColor != nil {
                var stringAttributes = [NSAttributedString.Key: Any]()
                stringAttributes[.font] = font
                stringAttributes[.foregroundColor] = color
                stringAttributes[.backgroundColor] = backgroundColor
                return stringAttributes
            }
        }
        XZLog("XZTheme: Unparsable StringAttributes value (%@), nil returned.", value)
        return nil
    }
    
}

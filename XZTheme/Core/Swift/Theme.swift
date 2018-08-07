//
//  Theme.swift
//  XZKit
//
//  Created by mlibai on 2018/5/2.
//  Copyright © 2018年 mlibai. All rights reserved.
//

import UIKit
import XZKit

extension Notification.Name {
    
    /// 当主题发生改变时，发送 Notification 所使用的名称。
    /// - Note: 视图及视图控制器 UIView/UIViewController 及其子类，无需监听通知，其会自动的在适当的时机应用主题。
    public static let ThemeDidChange = Notification.Name.init(Domain + ".theme.changed")
    
}

extension Theme {
    
    /// 默认主题，缺省主题。
    /// - Note: 在应用主题时，如果没有任何可以应用的主题样式，会读取此主题下配置的主题样式。
    public static let `default`: Theme = Theme.init(name: "default")
    
    /// 当前主题，最后一次应用过的主题。
    ///
    /// - Note: 如果从未应用过主题，则为 Theme.default 。
    /// - Note: 应用主题，请主题对象的 `apply(animated:)` 方法。
    @objc(currentTheme)
    public private(set) static var current: Theme = {
        if let themeName = UserDefaults.standard.string(forKey: Theme.UserDefaultsKey) {
            return Theme.init(name: themeName)
        }
        return Theme.default
    }()
    
    /// 应用主题。
    /// - Note: 该方法会自动记录当前应用的主题。
    /// - Note: 应用主题会向所有 UIApplication.sharedApplication.windows 和根控制器发送主题事件。
    /// - Note: 视图控件或视图控制器，默认会向其子视图或自控制器以及相关联的对象发送事件。
    /// - Note: 没有正在显示的视图，会在显示（添加到父视图）时，根据自身主题和当前主题判断是否需要更新主题外观。
    /// - Note: 控制器也会在其将要显示时，判断主题从而决定是否更新主题外观。
    ///
    /// - Parameter animated: 是否渐变主题应用的过程。
    public func apply(animated: Bool) {
        guard Theme.current != self else {
            return
        }
        Theme.current = self
        // 记住当前主题。
        UserDefaults.standard.set(self.name, forKey: Theme.UserDefaultsKey)
        // 更新正在显示的视图。
        for window in UIApplication.shared.windows {
            window.setNeedsThemeAppearanceUpdate()
            window.rootViewController?.setNeedsThemeAppearanceUpdate()
            guard animated else { continue }
            guard let snapView = window.snapshotView(afterScreenUpdates: false) else { continue }
            window.addSubview(snapView)
            UIView.animate(withDuration: Theme.AnimationDuration, animations: {
                snapView.alpha = 0
            }, completion: { (_) in
                snapView.removeFromSuperview()
            })
        }
        // 发送通知。
        NotificationCenter.default.post(name: .ThemeDidChange, object: self)
    }
    
    /// 应用主题动画时长，0.5 秒。
    public static let AnimationDuration: TimeInterval = 0.5
    
    /// 在 UserDefaults 中记录当前主题所使用的 Key 。
    public static let UserDefaultsKey: String = Domain + ".theme.default"
    
}


/// 主题。
@objc(XZTheme)
public final class Theme: NSObject {

    /// 主题名称。
    /// - Note: 主题名称为主题的唯一标识符，判断两个主题对象是否相等的唯一标准。
    public let name: String
    
    /// 构造主题对象。
    ///
    /// - Parameter name: 主题名称。
    public init(name: String) {
        self.name = name
        super.init()
    }
    
    /// 此属性与主题名称相同。
    public override var description: String {
        return name
    }
    
    /// 返回 name 的 hashValue 属性值。
    public override var hashValue: Int {
        return name.hashValue
    }
    
    /// Key 为类名，Value 为样式表。
    /// 表示当前主题下，所有类的样式表。
    public private(set) var keyedThemesIfLoaded: [String: Theme.Collection]?
    
    /// 主题集，管理了某主题下的样式。
    /// - Note: 在主题集中，按主题进行分类存储所有的的主题样式。
    @objc(XZThemeCollection)
    public final class Collection: NSObject {
        
        public unowned let theme: Theme
        
        /// 构造主题集对象。
        ///
        /// - Parameter theme: 主题。
        public init(for theme: Theme) {
            self.theme = theme
            super.init()
        }
        
        /// 样式表。
        public private(set) var identifiedThemeStylesIfLoaded: [Theme.Identifier: Theme.Style.Collection]?
    }
    
    
    // MARK: - 定义：主题样式。
    
    /// 主题样式，用于存储主题外观样式属性以及属性值的对象。
    /// - Note: 使用 Array.init(themeStyles:) 可以取得所有已配置的属性。
    @objc(XZThemeStyle)
    public class Style: NSObject, NSCopying {

        /// 按属性存储的属性值，非懒加载。
        /// - Note: 更新样式属性值会标记所有者需要更新主题。
        public private(set) var attributedValuesIfLoaded: [Theme.Attribute: Any?]? {
            didSet { object?.setNeedsThemeAppearanceUpdate() }
        }
        
        /// 样式在复制时，如果是私有样式，会成为普通样式。
        public func copy(with zone: NSZone? = nil) -> Any {
            let themeStyle = Theme.Style.init()
            themeStyle.attributedValuesIfLoaded = self.attributedValuesIfLoaded
            return themeStyle
        }
        
        /// 私有样式集的所有者。
        public private(set) weak var object: NSObject?
        
        /// 构造私有样式集。私有样式不区分主题，切换主题时不清空。
        ///
        /// - Parameter object: 私有样式集所属的对象。
        public convenience init(for object: NSObject?) {
            self.init()
            self.object = object
        }
        
        /// 主题样式集：同一主题下，按状态分类的所有主题样式集合。同时，主题样式集也是 .normal 主题状态的主题样式。
        @objc(XZThemeStyleCollection)
        public final class Collection: Theme.Style {
            
            /// 按主题状态存储的主题样式集合，非懒加载。
            /// - Note: 会标记所有者需要更新主题。
            /// - Note: 该集合不包含 normal 状态的主题。
            /// - Note: 该集合不包含全局样式。
            public private(set) var statedThemeStylesIfLoaded: [Theme.State: Theme.Style]? {
                didSet {
                    // 修改私有样式会重置计算样式。
                    // xzss 样式默认不可以修改。
                    object?.computedThemeStyles = nil;
                    // 更新主题。
                    object?.setNeedsThemeAppearanceUpdate()
                }
            }
            
        }
    }
    
    
    // MARK: - 定义：主题属性。
    
    /// 主题标识符。
    public struct Identifier: RawRepresentable {
        
        public typealias RawValue = String
        
        public let rawValue: String
        
        public init(rawValue: String) {
            guard rawValue.count > 0 else {
                fatalError("The `\(rawValue)` is not an valid Theme.Identifier rawValue.")
            }
            self.rawValue = rawValue
        }
    }
    
    /// 主题属性。
    public struct Attribute: RawRepresentable {
        
        public typealias RawValue = String
        
        public let rawValue: String
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
        
    }
    
    /// 主题状态。
    /// - Note: 主题状态是为了解决主题属性的多状态值而设立的。
    /// - Note: 主题状态名必须符合正则表达式 /^\:[A-Za-z]+$/ 。
    /// - Note: 一个或多个基本主题状态，通过数组的方式可以组合成复合主题状态。
    /// - Note: 复合状态用于解决主题属性同时具有不同类型的状态值。
    /// - Note: 复合状态是有序的，比如 `[.state1, .state2]` 与 `[.state2, .state1]` 是不同的主题状态。
    /// - Note: 可以使用 for-in 语句来遍历主题状态中的所有子元素。
    public struct State {
        
        /// 特殊值，非主题状态。
        public static let notAState = Theme.State.init(name: "", rawValue: "", rawType: String.self, isOptionSet: false, children: [])
    
        /// 主题状态名，区分主题状态的标识符。
        public let name: String
        
        /// 主题状态原始值，复合状态原始值为 0 。
        public let rawValue: Any
        
        /// 原始类型。
        public let rawType: Any.Type
        
        /// 主题状态的原始值，是否为 OptionSet 类型，用于优化性能。
        /// - Note: 相同 OptionSet 类型的基本主题状态组成的复合状态，此属性为 true 。
        public let isOptionSet: Bool
        
        /// 复合状态的子状态，子状态也可能是复合状态。
        private let children: [State]
        
        /// 指定初始化方法。私有构造方法，避免构造出不合法的主题状态。
        private init(name: String, rawValue: Any, rawType: Any.Type, isOptionSet: Bool = false, children: [State] = []) {
            self.name        = name
            self.rawValue    = rawValue
            self.rawType     = rawType
            self.isOptionSet = isOptionSet
            self.children    = children
        }
        
    }
    
}

extension Theme {
    
    public private(set) var keyedThemes: [String: Theme.Collection] {
        get {
            if keyedThemesIfLoaded != nil {
                return keyedThemesIfLoaded!
            }
            keyedThemesIfLoaded = [:]
            return keyedThemesIfLoaded!
        }
        set {
            keyedThemesIfLoaded = newValue
        }
    }
    
    public func themesIfLoaded(forKey aKey: String) -> Theme.Collection? {
        return self.keyedThemesIfLoaded?[aKey]
    }
    
    public func set(_ themes: Theme.Collection, forKey aKey: String) {
        keyedThemes[aKey] = themes
    }
    
    public func themesIfLoaded(forObject anObject: NSObject) -> Theme.Collection? {
        let aKey = NSStringFromClass(type(of: anObject))
        return self.keyedThemesIfLoaded?[aKey]
    }
    
}

extension Theme.State: Sequence, IteratorProtocol {
    
    /// 是否为基本主题状态。
    /// - Note: 没有子状态的主题状态为基本状态。
    public var isPrimary: Bool {
        return children.isEmpty
    }
    
    /// 子状态个数，基本状态没有子状态。
    public var count: Int {
        return children.count
    }
    
    /// 获取指定的子状态。
    ///
    /// - Parameter index: 子状态复合时的索引。
    public subscript(index: Int) -> Theme.State {
        return children[index]
    }
    
    /// 检查状态是否符合要求的正则。
    private static let regularExpression = try! NSRegularExpression(pattern: "^\\:[A-Za-z]+$", options: .none)
    
    /// 基本主题状态构造方法，主题状态名必须符合正则表达式：`/^\:[A-Za-z]+$/` 。
    ///
    /// - Parameters:
    ///     - name: 主题状态名。
    ///     - rawValue: 主题状态原始值。
    ///     - rawType: 主题状态原始类型。
    ///     - isOptionSet: 原始类型是否为 OptionSet 类型。
    public init<T>(name: String, rawValue: T, rawType: T.Type = T.self, isOptionSet: Bool = false) {
        let range = NSMakeRange(0, name.count)
        guard NSEqualRanges(range, Theme.State.regularExpression.rangeOfFirstMatch(in: name, options: .none, range: range)) else {
            fatalError("The `\(rawValue)` is not an valid state rawValue, which must be matched the regular expression /^\\:[A-Za-z]+$/ .")
        }
        self.init(name: name, rawValue: rawValue, rawType: rawType, isOptionSet: isOptionSet, children: [])
    }
    
    /// 将主题状态集合转换复合主题状态。
    /// - Note: 空数组将获得 .normal 状态。
    /// - Note: 单个元素也可以复合，且与原来不相等。
    /// - Note: 任何状态与 .normal 复合等于对其自身进行复合。
    /// ```
    /// let state1: Theme.State = .highlighted
    /// let state2: Theme.State = [.normal, .highlighted]
    /// print(state1 == state2) // prints true
    /// print(state1 === state2) // prints false
    /// ```
    /// - Note: 复合状态可以再次被复合成新的复合状态，且与原来不相等。
    ///
    /// - Parameter rawValue: 主题状态原始值。
    public init(_ elements: Array<Theme.State>) {
        switch elements.count {
        case 0:
            self = .notAState
        default:
            var isOptionSet = true
            var rawType: Any.Type! = nil
            var rawValue: [Any] = []
            let name = elements.map({ (element) -> String in
                // 只要数组存在非 OptionSet 元素或存在两个不同的 OptionSet 类型，那么复合状态就不是 OptionSet
                if isOptionSet {
                    if rawType == nil { // first loop
                        rawType = element.rawType
                        isOptionSet = element.isOptionSet
                    } else {
                        // 如果有元素是非 OptionSet 或者存在两种不同的类型 或者非基本状态，则复合状态不是 OptionSet 。
                        if !element.isOptionSet || rawType != element.rawType /* || !element.isPrimary */{
                            isOptionSet = false
                            rawType = Any.self
                        }
                    }
                }
                // 复合状态的原始值是子元素原始值的数组。
                rawValue.append(element.rawValue)
                // 如果元素是复合元素，用 [] 包裹它。
                if element.children.count > 0 {
                    return "[\(element.name)]"
                }
                // 否则直接使用元素名。
                return element.name
            }).joined()
            self.init(name: name, rawValue: rawValue, rawType: rawType, isOptionSet: isOptionSet, children: elements)
        }
    }
    
    /// 遍历主题状态中的所有基本元素，遍历顺序为正序。
    ///
    /// - Returns: 剩余未遍历的主题状态。
    public mutating func next() -> Theme.State? {
        // 遍历的终点
        if self == .notAState {
            return nil
        }
        // 复合状态
        // 复合状态在遍历的过程中，原始值不变，只改变其 children
        // 如果 children 变为一个了，则停止遍历。
        switch children.count {
        case 0:
            // 基本状态。
            let state = self
            self = .notAState
            return state
        case 1:
            // 只有一个子状态的复合状态。
            let state = children[0]
            self = .notAState
            return state
        default:
            let state = children[0]
            // 这里会产生一个不合法的状态
            self = Theme.State.init(
                name:           name,
                rawValue:       rawValue,
                rawType:        rawType,
                isOptionSet:    isOptionSet,
                children:       Array.init(children.suffix(from: 1))
            )
            return state
        }
        
    }
    
}

// MARK: - 拓展：Theme.Collection

extension Theme.Collection {
    
    /// 按主题分类的主题样式集合，懒加载。
    public private(set) var identifiedThemeStyles: [Theme.Identifier: Theme.Style.Collection] {
        get {
            if identifiedThemeStylesIfLoaded != nil {
                return identifiedThemeStylesIfLoaded!
            }
            identifiedThemeStylesIfLoaded = [Theme.Identifier: Theme.Style.Collection]()
            return identifiedThemeStylesIfLoaded!
        }
        set {
            identifiedThemeStylesIfLoaded = newValue
        }
    }
    
    /// 设置主题样式。
    ///
    /// - Parameter themeStyles: 主题样式。
    /// - Parameter theme: 主题。
    public func set(_ themeStyles: Theme.Style.Collection, for themeIdentifier: Theme.Identifier) {
        identifiedThemeStyles[themeIdentifier] = themeStyles
    }
    
    /// 当发生内存警告时，Theme.Collection 将尝试将样式缓存到 tmp 目录，并释放相关资源。
    /// - Note: 目前该函数的功能没有实现。
    public func didReceiveMemoryWarning() {
        /// 如果当前对象没有样式标识符，不缓存。待确定。
        
        /// 通过配置文件和代码配置的，毕竟有可能是混合用的。
        
        /// 没有样式，也就不需要释放了。
        
        /// 将样式转换成字典。
        
        // TODO: - 将样式字典缓存到 tmp 目录。
    }
    
}

extension Theme.Style {
    
    /// 按样式属性存储的属性值，懒加载。
    /// - Note: 更新样式属性值会标记所有者需要更新主题。
    public private(set) var attributedValues: [Theme.Attribute: Any?] {
        get {
            if attributedValuesIfLoaded != nil {
                return attributedValuesIfLoaded!
            }
            attributedValuesIfLoaded = [Theme.Attribute: Any?]()
            return attributedValuesIfLoaded!
        }
        set {
            attributedValuesIfLoaded = newValue
        }
    }
    
    /// 添加/更新/删除主题属性值。
    /// - Note: 设置 nil 值，请使用 updateValue(_:forThemeAttribute:) 方法。
    ///
    /// - Parameter value: 主题属性值。
    /// - Parameter themeAttribute: 主题属性。
    public func setValue(_ value: Any?, for themeAttribute: Theme.Attribute) {
        attributedValues[themeAttribute] = value
    }
    
    /// 添加/更新/删除主题属性值。
    ///
    /// - Parameter value: 主题属性值。
    /// - Parameter themeAttribute: 主题属性。
    public func updateValue(_ value: Any?, for themeAttribute: Theme.Attribute) {
        attributedValues.updateValue(value, forKey: themeAttribute)
    }
    
    /// 删除主题属性值。
    ///
    /// - Parameter themeAttribute: 主题属性。
    public func removeValue(for themeAttribute: Theme.Attribute) -> Any? {
        guard let value = attributedValuesIfLoaded?.removeValue(forKey: themeAttribute) else {
            return nil
        }
        return value
    }
    
}

extension Theme.Style.Collection {
    
    /// 按主题状态存储的主题样式集合，懒加载。
    /// - Note: 会标记所有者需要更新主题。
    /// - Note: 该集合不包含 normal 状态的主题。
    /// - Note: 该集合不包含全局样式。
    public private(set) var statedThemeStyles: [Theme.State: Theme.Style] {
        get {
            if statedThemeStylesIfLoaded != nil {
                return statedThemeStylesIfLoaded!
            }
            statedThemeStylesIfLoaded = [Theme.State: Theme.Style]()
            return statedThemeStylesIfLoaded!
        }
        set {
            statedThemeStylesIfLoaded = newValue
        }
    }

    /// 设置指定状态下的主题样式。
    /// - Note: 无需设置状态状态 normal 的样式。
    /// - Note: 被设置的样式的所有者，必须与当前集合的所有者相同。
    ///
    /// - Parameters:
    ///   - themeStyle: 主题样式。
    ///   - themeState: 主题状态。
    public func set(_ themeStyle: Theme.Style, for themeState: Theme.State) {
        if themeState == .normal || themeState == .notAState {
            return
        }
        statedThemeStyles[themeState] = themeStyle
    }
    
    /// 获取指定状态的主题样式，如果已创建。
    /// - Note: 主题状态 Empty 与 normal 返回当前对象自身。
    /// - Note: 该方法不会返回全局的主题样式集，以避免全局主题样式被意外修改。
    ///
    /// - Parameter themeState: 主题状态。
    /// - Returns: 主题样式。
    public func themeStyleIfLoaded(for themeState: Theme.State) -> Theme.Style? {
        if themeState == .normal || themeState == .notAState {
            return self
        }
        return statedThemeStyles[themeState]
    }
    
}

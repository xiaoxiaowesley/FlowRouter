import Foundation
import UIKit

/// 定义路由选项
public struct RouteOption {
    /// 是否有动画
    public var animated: Bool
    /// 入栈方法
    public var navigationType: NavigationType
    /// 导航栏标题
    public var navbarTitle: String?
    /// 是否显示导航栏
    public var navbarVisible: Bool?
    /// 支持左滑退出
    public var swipeBackEnabled: Bool = true
    /// 是否透明
    public var transparent: Bool = false
    /// UIHostingController是否忽略键盘事件,
    public var ignoreKeyboard: Bool = false

    public init(
        animated: Bool = true,
        navigationType: NavigationType = .push,
        navBarTitle: String? = nil,
        navbarVisible: Bool = true,
        swipeBackEnabled: Bool = true,
        transparent: Bool = false,
        ignoreKeyboard: Bool = false,
    ) {
        self.animated = animated
        self.navigationType = navigationType
        self.navbarTitle = navBarTitle
        self.navbarVisible = navbarVisible
        self.swipeBackEnabled = swipeBackEnabled
        self.transparent = transparent
        self.ignoreKeyboard = ignoreKeyboard

        self.disableSwipeBackWhenInPresent()
    }

    init(from: [String: Any]) {
        self.animated = true
        self.navigationType = .push
        self.navbarTitle = nil
        self.navbarVisible = true
        self.swipeBackEnabled = true
        self.transparent = false
        self.ignoreKeyboard = false
        self.setup(from: from)
        self.disableSwipeBackWhenInPresent()
    }

    init(from url: String) {
        self.animated = true
        self.navigationType = .push
        self.navbarTitle = nil
        self.navbarVisible = true
        self.swipeBackEnabled = true
        self.transparent = false
        self.ignoreKeyboard = false
        self.merge(from: url)
        self.disableSwipeBackWhenInPresent()
    }

    mutating func merge(from url: String) {
        let urlComponents = URLComponents(string: url)
        var queryItems: [String: Any] = [:]
        urlComponents?.queryItems?.forEach { queryItems[$0.name] = $0.value }

        // 获取名为option的value
        if let option = queryItems["options"] as? String {
            let optionData = option.data(using: .utf8)
            let optionDict =
                try? JSONSerialization.jsonObject(with: optionData!, options: .mutableContainers)
                as? [String: Any]
            if let optionDict = optionDict {
                self.setup(from: optionDict)
            }
        }
    }

    mutating func setup(from: [String: Any]) {
        if let animate = from["animate"] as? Bool {
            self.animated = animate
        } else if let animated = from["animated"] as? Bool {
            self.animated = animated
        } else {
            self.animated = true
        }
        if let navigationType = from["navigationType"] as? String {
            switch navigationType {
            case "push":
                self.navigationType = .push
            case "present":
                self.navigationType = .defaultPresent()
            default:
                self.navigationType = .defaultPresent()
            }
        }
        if let navBarTitle = from["navbarTitle"] as? String {
            self.navbarTitle = navBarTitle
        }

        if let navbarVisible = from["navbarVisible"] as? Bool {
            self.navbarVisible = navbarVisible
        }

        if let swipeBackEnabled = from["swipeBackEnabled"] as? Bool {
            self.swipeBackEnabled = swipeBackEnabled
        }
        if let transparent = from["transparent"] as? Bool {
            self.transparent = transparent
            if self.transparent == true {
                if navigationType == .push {
                    Log.w(
                        "RouteOption",
                        "当transparent == true时，会强制将改为navigationType为.defaultPresent()")
                }
                self.navigationType = .defaultPresent()
            }
        }
    }

    mutating func disableSwipeBackWhenInPresent() {

        if self.navigationType != .push {
            if self.swipeBackEnabled == true {
                self.swipeBackEnabled = false
                Log.w("RouterOption", "在present模式下，禁用swipeBackEnabled")
            }
        }
    }
}



/// 路由打开请求
public struct RouterOpenRequest {
    public var pageClass: AnyClass
    public var scheme: String
    public var query: [String: Any]
    public var option: RouteOption
    public var closeHandler: ([String: Any]?) -> Void
    
    public init(
        pageClass: AnyClass,
        scheme: String,
        query: [String: Any],
        option: RouteOption,
        closeHandler: @escaping ([String: Any]?) -> Void
    ) {
        self.pageClass = pageClass
        self.scheme = scheme
        self.query = query
        self.option = option
        self.closeHandler = closeHandler
    }
}

/// 路由关闭请求
public struct RouterCloseRequest {
    public var pageClass: AnyClass
    public var scheme: String
    public var query: [String: Any]
    public var option: RouteOption
    
    public init(
        pageClass: AnyClass,
        scheme: String,
        query: [String: Any],
        option: RouteOption
    ) {
        self.pageClass = pageClass
        self.scheme = scheme
        self.query = query
        self.option = option
    }
}

//
//  Router.swift
//  GlobalIdleFish4iOS
//
//  Created by xiaoxiang's m1 mbp on 2024/5/21.
//

import Photos
import SwiftUI
import UIKit

public typealias RouteAction = (
    _ schemeStr: String,
    _ query: [String: Any],
    _ option: RouteOption,
    _ closeHandler: @escaping ([String: Any]?) -> Void,
    _ completion: (() -> Void)?
) -> RouterPageProtocol?

///  暴露的方法
public struct FlowRouter {
    
    /// 注册路由
    /// - Parameters:
    ///   - map: 页面映射表
    ///   - actionMap: 动作映射表
    ///   - rootViewController: 根视图控制器
    ///   - navigationController: 导航控制器
    @MainActor public static func register(
        _ map: [String: AnyClass],
        _ actionMap: [String: RouteAction],
        rootViewController: UIViewController,
        navigationController: UINavigationController
    ){
        RouterModule.shared.register(map, actionMap, rootViewController: rootViewController, navigationController: navigationController)
    }
    
    /// 打开页面
    /// - Parameters:
    ///   - scheme: 页面scheme
    ///   - query: 业务参数
    ///   - option: 打开配置(动画，导航类型等)
    ///   - closeHandler: 关闭页面时的回调
    /// - Returns: 页面实例
    @discardableResult
    @MainActor public static func open(
        _ scheme: Scheme,
        _ query: [String: Any] = [:],
        _ option: RouteOption = RouteOption(animated: true, navigationType: .push),
        _ closeHandler: (([String: Any]?) -> Void)? = nil,
        _ completion: (() -> Void)? = nil
    ) -> RouterPageProtocol? {

        return RouterModule.shared.open(
            scheme.rawValue, query, option,
            { (closeData: [String: Any]?) in
                Log.i("Router", "onClose")
                if let closeHandler = closeHandler {
                    closeHandler(closeData)
                }
            },
            {
                // completion
                completion?()
            })
    }

    /// 打开页面(等待关闭)
    /// - Parameters:
    ///   - scheme: 页面scheme
    ///   - query: 业务参数
    ///   - option: 打开配置(动画，导航类型等)
    /// - Returns: 关闭页面时传递的数据
    @discardableResult
    @MainActor public static func awaitOpen(
        _ scheme: Scheme,
        _ query: [String: Any] = [:],
        _ option: RouteOption = RouteOption(animated: true, navigationType: .push)
    ) async throws -> RouteCloseData? {
        Log.i("Router", "awaitOpen scheme:\(scheme.rawValue)")
        return try await withCheckedThrowingContinuation { continuation in
            RouterModule.shared.open(
                scheme.rawValue, query, option,
                { (closeData: [String: Any]?) in
                    Log.i("Router", "onClose")
                    continuation.resume(returning: RouteCloseData(closeData))
                },
                {
                    // completion 打开完毕
                    Log.i("Router", "awaitOpen, open complete")
                })
        }
    }


    /// pop页面
    /// - Parameters:
    ///   - closeData: 关闭页面时传递的数据
    /// - Returns: 关闭页面的实例
    @discardableResult
    @MainActor public static func pop(_ closeData: [String: Any]? = nil, _ option: RouteOption? = nil)
        -> RouterPageProtocol?
    {
        guard let openRecord = RouterModule.shared.pageRecords.last else {
            Log.e("Router", "The page stack is empty.")
            return nil
        }
        return RouterModule.shared.close(
            openRecord.page.uuid, closeData, option,
            { closeData in
                // completion
            })

    }

    /// 关闭当前界面，并等待pop完成
    /// - Parameters:
    ///   - closeData: closeData 关闭时带回去的数据
    ///   - option: 关闭时页面参数
    @discardableResult
    @MainActor public static func awaitPop(_ closeData: [String: Any]? = nil, _ option: RouteOption? = nil)
        async throws -> Bool
    {
        guard let openRecord = RouterModule.shared.pageRecords.last else {
            Log.e("Router", "The page stack is empty.")
            return false
        }
        do {
            return try await self.awaitClose(openRecord.page.uuid, closeData, option)
        } catch {
            Log.e("Router", "awaitPop error: \(error).")
            return false
        }
    }

    /// 根据uuid关闭界面，并等待close完成
    /// - Parameters:
    ///   - closeData: closeData 关闭时带回去的数据
    ///   - option: 关闭时页面参数
    @discardableResult
    @MainActor static func awaitClose(
        _ uuid: String, _ closeData: [String: Any]? = nil, _ closeOption: RouteOption? = nil
    ) async throws -> Bool {
        return try await withCheckedThrowingContinuation { continuation in
            Task {
                let ret = RouterModule.shared.close(
                    uuid, closeData, closeOption,
                    { closeData in
                        // completion
                        continuation.resume(returning: true)
                    })
                if ret == nil {
                    continuation.resume(returning: false)
                }
            }
        }
    }

    /// 关闭页面
    /// - Parameters:
    ///   - uuid: 页面uuid
    ///   - closeData: 关闭页面时传递的数据
    /// - Returns: 关闭页面的实例
    @discardableResult
    @MainActor public static func close(
        _ uuid: String, _ closeData: [String: Any]? = nil, _ closeOption: RouteOption? = nil
    )
        -> RouterPageProtocol?
    {
        return RouterModule.shared.close(
            uuid, closeData, closeOption,
            { closeData in
                // completion
            })
    }

    /// pop到根页面
    /// - Parameter:
    ///  - closeData: 关闭页面时传递的数据
    ///  - option: 关闭配置(动画，导航类型等)
    /// - Returns: 关闭页面的实例数组
    @discardableResult
    @MainActor public static func popToRoot(
        _ closeData: [String: Any]? = nil, _ option: RouteOption? = RouteOption(animated: false)
    ) async
        -> Bool
    {
        let pages = RouterModule.shared.pages()
        guard pages.count > 1 else {
            Log.e("Router", "popToRoot.The page stack is empty.")
            return false
        }
        let destPage = pages.first!
        Log.i("Router", "popToRoot destPage:\(type(of: destPage))  pages: \(pages)")
        return await popTo(destPage.uuid, closeData, option)
    }

    /// pop到指定页面
    /// - Parameter:
    ///  - uuid: 页面uuid
    ///  - closeData: 关闭页面时传递的数据
    ///  - option: 关闭配置(动画，导航类型等)
    /// - Returns: 关闭页面的实例数组
    @discardableResult
    @MainActor public static func popTo(
        _ uuid: String, _ closeData: [String: Any]? = nil, _ option: RouteOption? = nil
    ) async
        -> Bool
    {
        let pages = RouterModule.shared.pages()
        var index = -1
        for (idx, record) in pages.enumerated() {
            if record.uuid == uuid {
                index = idx
                break
            }
        }
        // 找不到
        if index == -1 {
            return false
        } else if index + 1 >= pages.count {
            // 当前已经是顶了
            return false
        }

        // 已经pop的页面
        var keepGo = true
        while keepGo {
            do {
                let pageRecord = RouterModule.shared.pageRecords.last

                if pageRecord == nil {
                    keepGo = false
                    continue
                } else if pageRecord!.page.uuid == uuid {
                    keepGo = false
                    continue
                }
                let ret = try await awaitClose(pageRecord!.page.uuid, closeData, option)
                if ret == false {
                    keepGo = false
                    continue
                }

            } catch {
                keepGo = false
                Log.e("Router", "popTo error: \(error).")
            }
        }
        return true
    }
    
    
    public struct Scheme: Hashable, Equatable, RawRepresentable, @unchecked Sendable {
        public var rawValue: String

        public init(_ rawValue: String) {
            self.rawValue = rawValue
        }

        public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }
}

extension FlowRouter {


    ///通过 页面pageId ，获取当前对应的 viewController对象
    @MainActor public static func getViewControllerByPageId(pageId: String) -> RouterPageProtocol? {
        let pages = RouterModule.shared.pages()
        return nil
    }

    ///通过 页面pageId ，获取从哪个viewController打开的
    @MainActor public static func getPreViewControllerByPageId(pageId: String) -> RouterPageProtocol? {
        let records = RouterModule.shared.pageRecords
        var index = -1
  
        if index > -1 && index > 0 {
            let preIndex = index - 1
            return records[preIndex].page
        } else {
            return nil
        }
    }
}

extension FlowRouter {
    @MainActor public static func pages() -> [RouterPageProtocol] {
        return RouterModule.shared.pages()
    }
}

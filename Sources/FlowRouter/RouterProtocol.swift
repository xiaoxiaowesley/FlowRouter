//
//  RouterProtocol.swift
//  Runner
//
//  Created by xiaoxiang's m1 mbp on 2024/4/1.
//

import Foundation
import UIKit

@MainActor
public protocol RouterProtocol {
    /// 和类的映射关系
    ///
    /// - Parameters:
    ///   - map: 映射关系
    ///   - rootViewController: 根视图控制器
    ///   - navigationController: 导航控制器
    func register(
        _ map: [String: AnyClass],
        _ actionMap: [String: RouteAction],
        rootViewController: UIViewController,
        navigationController: UINavigationController)

    /// 打开
    ///
    /// - Parameters:
    ///   - schemeStr: 要推送的页面
    ///   - params: 页面参数
    ///   - option: 请求选项（控制页面的打开的方式：是否打开动画，是否push/present等）
    ///   - closeHandler: 页面关闭时（close函数）传入的closeData
    ///   - completion: 页面打开结束回调
    /// - Returns: 如果成功推送到指定页面，则返回 true；如果无法找到对应的路由，则返回 nil。
    func open(
        _ schemeStr: String,
        _ query: [String: Any],
        _ option: RouteOption,
        _ closeHandler: @escaping ([String: Any]?) -> Void,
        _ completion: (() -> Void)?
    ) -> RouterPageProtocol?

    /// 根据uuid移除界面
    ///
    ///
    /// - Parameters:
    ///   - uuid: 要移除的UUID
    ///   - closeData: 关闭时带回到open的数据
    ///   - completion: 关闭完成回调
    ///
    /// - Returns: 是否成功移除
    func close(
        _ uuid: String, _ closeData: [String: Any]?, _ closeOption: RouteOption?,
        _ completion: (([String: Any]?) -> Void)?
    )
        -> RouterPageProtocol?

    /// 获取当前页面堆栈
    ///
    /// - Returns: 当前页面堆栈数组
    func pages() -> [RouterPageProtocol]

    /// 根据uuid查看是否存在界面
    ///
    /// - Parameter uuid: 要判断的uuid
    /// - Returns: 如果uuid存在则返回true，否则返回false
    func isExist(_ uuid: String) -> Bool

    /// 添加页面打开前置拦截器
    ///
    /// - Parameter filter: 拦截器
    func addOpenBeforeInterceptor(interceptor: RouterOpenBeforeInterceptor)

    /// 添加页面打开后置拦截器
    ///
    /// - Parameter filter: 拦截器
    func addOpenAfterInterceptor(filter: RouterOpenAfterInterceptor)

    /// 添加页面关闭前置拦截器
    ///
    /// - Parameter filter: 拦截器
    func addCloseBeforeInterceptor(filter: RouterCloseBeforeInterceptor)

    /// 添加页面关闭后置拦截器
    ///
    /// - Parameter filter: 拦截器
    func addCloseAfterInterceptor(filter: RouterCloseAfterInterceptor)

    /// 清除打开前置拦截器
    func clearBeforeInterceptor()

    /// 清除打开后置拦截器
    func clearAfterInterceptor()

    /// 清除关闭前置拦截器
    func clearCloseBeforeInterceptor()

    /// 清除关闭后置拦截器
    func clearCloseAfterInterceptor()
}

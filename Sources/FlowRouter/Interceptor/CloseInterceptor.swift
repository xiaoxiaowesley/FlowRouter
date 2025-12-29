//
//  CloseInterceptor.swift
//  Runner
//
//  Created by xiaoxiang's m1 mbp on 2024/4/8.
//

import Foundation

/// 关闭处理结果
public class RouterCloseInterceptorResult {
    init(action: RouterInterceptorAction, request: RouterCloseRequest? = nil) {
        self.action = action
        if request == nil && action == .interupt {
            Log.w("RouterInterceptorResult", "action is .interupt but not custom the request")
        }
        self.newRequest = request
    }
    var action: RouterInterceptorAction
    var newRequest: RouterCloseRequest?
}

/// 关闭界面-前置拦截器
public protocol RouterCloseBeforeInterceptor {

    /// 判断是否可拦截
    ///
    /// - Parameter request: 关闭请求
    /// - Returns: 是否可以初始化路由记录，当返回true时，才会调用handleBeforeClose
    func canInitBeforeClose(request: RouterCloseRequest) -> Bool

    /// 在执行路由前的拦截器
    /// 本函数仅canInitBeforeOpen返回true时才会被调用
    ///
    /// - Parameter request: 关闭请求
    /// - Returns: 拦截结果，当返回RouterCloseInterceptorResult(action: .interupt)是才会调用handleInterupt
    func handleBeforeClose(_ request: RouterCloseRequest) -> RouterCloseInterceptorResult

    /// 处理中断
    /// 注意只有在handleBeforeClose返回RouterOpenInterceptorResult(action: .interupt)时才会调用
    func handleCloseInterupt(_ request: RouterCloseRequest)

}

/// 关闭界面-后置拦截器
public protocol RouterCloseAfterInterceptor {

    /// 判断是否可拦截
    ///
    /// - Parameter request: 关闭请求
    /// - Returns: 是否可以初始化路由记录
    func canInitAfterClose(request: RouterCloseRequest) -> Bool

    /// 在执行路由后的拦截器
    /// 本函数仅handleAfterInterceptor返回true时才会被调用
    ///
    /// - Parameter request: 关闭请求
    func handleAfterOpen(_ request: RouterCloseRequest)
}

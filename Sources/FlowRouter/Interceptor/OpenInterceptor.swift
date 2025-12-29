//
//  OpenInterceptor.swift
//  Runner
//
//  Created by xiaoxiang's m1 mbp on 2024/4/8.
//

import Foundation

public enum RouterInterceptorAction {
    /// 继续执行跳转
    case goOn
    /// 中断跳转（使用此值时，需要自己定义跳转逻辑）
    case interupt
}

/// 打开处理结果
public  class RouterOpenInterceptorResult {
    init(action: RouterInterceptorAction, request: RouterOpenRequest? = nil) {
        self.action = action
        if request == nil && action == .interupt {
            Log.w("RouterInterceptorResult", "action is .interupt but not custom the request")
        }
        self.newRequest = request
    }
    var action: RouterInterceptorAction
    var newRequest: RouterOpenRequest?
}

/// 打开界面-前置拦截器
public protocol RouterOpenBeforeInterceptor {

    /// 判断是否可拦截
    ///
    /// - Parameter request: 打开请求
    /// - Returns: 是否可以初始化路由记录 ，当返回true时，才会调用handleBeforeOpen
    func canInitBeforeOpen(request: RouterOpenRequest) -> Bool

    /// 在执行路由前的拦截器
    /// 本函数仅canInitBeforeOpen返回true时才会被调用
    ///
    /// - Parameter request: 打开请求
    /// - Returns: 拦截结果 ，当返回RouterOpenInterceptorResult(action: .interupt)是才会调用
    func handleBeforeOpen(_ request: RouterOpenRequest) -> RouterOpenInterceptorResult

    /// 处理中断
    /// 注意只有在handleBeforeOpen函数返回RouterOpenInterceptorResult(action: .interupt)时才会调用
    func handleOpenInterupt(_ request: RouterOpenRequest)

}

/// 打开界面-后置拦截器
public protocol RouterOpenAfterInterceptor {

    /// 判断是否可拦截
    ///
    /// - Parameter request: 打开请求
    /// - Returns: 是否可以初始化路由记录
    func canInitAfterOpen(request: RouterOpenRequest) -> Bool

    /// 在执行路由后的拦截器
    /// 本函数仅handleAfterInterceptor返回true时才会被调用
    ///
    /// - Parameter request: 打开请求
    func handleAfterOpen(_ request: RouterOpenRequest)
}

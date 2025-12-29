//
//  File.swift
//  FlowRouter
//
//  Created by xiaoxiang on 2025/12/29.
//

import Foundation
import UIKit

/// 页面栈记录（包含具体页面信息，打开时的信息）
open class PageRecord {
    /// 页面 weak 引用
    weak var page: RouterPageProtocol!

    /// 打开时的请求
    var openRequest: RouterOpenRequest
    /// 打开时的导航VC
    var navigationController: UINavigationController
    /// 前一个栈
    var formerViewController: UIViewController?

    init(
        page: RouterPageProtocol,
        openRequest: RouterOpenRequest,
        navigationController: UINavigationController,
        formerViewController: UIViewController?
    ) {
        self.page = page
        self.openRequest = openRequest
        self.navigationController = navigationController
        self.formerViewController = formerViewController
    }
}

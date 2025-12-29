//
//  RouterModule.swift
//  Runner
//
//  Created by xiaoxiang's m1 mbp on 2024/4/1.
//

import UIKit

final class RouterModule: NSObject, RouterProtocol,
    UIAdaptivePresentationControllerDelegate,
    UINavigationControllerDelegate, UIGestureRecognizerDelegate
{

    /// idle->opening->idle->closing->idle
    enum Status {
        /// 空闲
        case idle
        /// 打开中
        case opening
        /// 关闭中
        case closing
    }

    var status: Status = .idle

    static private let TAG = "Router"

    /// 导航ViewController
    var navigationController: UINavigationController? = nil
    /// 根ViewController
    var rootViewController: UIViewController? = nil
    /// 页面栈记录
    var pageRecords: [PageRecord] = []

    /// 打开操作-前缀拦截器
    var openBeforeInterceptors: [[String: RouterOpenBeforeInterceptor]] = []
    /// 打开操作-后置拦截器
    var openAfterInterceptors: [[String: RouterOpenAfterInterceptor]] = []

    /// 关闭操作-前缀拦截器
    var closeBeforeInterceptors: [[String: RouterCloseBeforeInterceptor]] = []
    /// 关闭操作-后置拦截器
    var closeAfterInterceptors: [[String: RouterCloseAfterInterceptor]] = []

    // MARK: ModuleProtocol
    public static var shared = RouterModule()

    func moduleInit() {}

    func moduleExecute() {}

    func topPage() -> PageRecord? {
        return pageRecords.last
    }

    // MARK: - RouterProtocol
    public func isExist(_ uuid: String) -> Bool {
        return pages().contains { $0.uuid == uuid }
    }
    
    @MainActor
    public func register(
        _ map: [String: AnyClass],
        _ actionMap: [String: RouteAction],
        rootViewController: UIViewController,
        navigationController: UINavigationController
    ) {
        RouteMapManager.shared.setup(routerPageMap: map, routerActionMap: actionMap)
        self.rootViewController = rootViewController
        self.navigationController = navigationController

        // 获取rootViewController的 class名
        let rootVCClass: AnyClass = type(of: rootViewController)
        let schemeString = map.first { $0.value == rootVCClass }?.key ?? "root"

        let openRequest = RouterOpenRequest(
            pageClass: rootVCClass,
            scheme: schemeString,
            query: [:],
            option: RouteOption(),
            closeHandler: { (_: [String: Any]?) in

            }
        )
        pageRecords.append(
            PageRecord(
                page: rootViewController as! RouterPageProtocol,
                openRequest: openRequest,
                navigationController: navigationController,
                formerViewController: nil))
        #if DEBUG
            Log.i(
                RouterModule.TAG,
                "register rootViewController: \(rootViewController),uuid: \((rootViewController as! RouterPageProtocol).uuid)"
            )
        #endif
    }

    @MainActor public func open(
        _ schemeStr: String,
        _ query: [String: Any],
        _ option: RouteOption,
        _ closeHandler: @escaping ([String: Any]?) -> Void,
        _ completion: (() -> Void)?
    ) -> RouterPageProtocol? {

        if let action = RouteMapManager.shared.findAction(schemeStr) {
            return action(schemeStr, query, option, closeHandler, completion)
        }

        status = .opening
        // 未注册
        guard let pageClass = RouteMapManager.shared.findPage(schemeStr) else {
            let errorInfo =
                "☂️Could not find the corresponding class for \(schemeStr). Please check if you have called register to register it."
            Log.e(RouterModule.TAG, errorInfo)
            #if DEBUG && !TARGET_IS_UNIT_TEST
                // Alert.show(title: "未注册", message: errorInfo)
            #endif
            return nil
        }

        guard let pageType = pageClass as? RouterPageProtocol.Type else {
            Log.e(
                RouterModule.TAG, "☂️The class for \(schemeStr) is not a UIViewController subclass.")
            #if DEBUG && !TARGET_IS_UNIT_TEST
                // Alert.show(
//                    title: "ERROR",
//                    message: "The class for \(schemeStr) is not a UIViewController subclass.")
            #endif
            return nil
        }

        var openRequest = RouterOpenRequest(
            pageClass: pageClass, scheme: schemeStr, query: query, option: option,
            closeHandler: closeHandler
        )

        // 2.前置拦截器
        for filterArray in openBeforeInterceptors {
            for (uuid, filter) in filterArray {
                if filter.canInitBeforeOpen(request: openRequest) {
                    let result = filter.handleBeforeOpen(openRequest)
                    if let newRequest = result.newRequest {
                        openRequest = newRequest
                        Log.i(
                            RouterModule.TAG,
                            "☂️新request被替换 uuid:\(uuid) scheme:\(openRequest.scheme) params:\(openRequest.query)"
                        )
                    }
                    if result.action == .interupt {
                        Log.i(RouterModule.TAG, "☂️被中断 uuid:\(uuid) scheme:\(openRequest.scheme)")
                        filter.handleOpenInterupt(openRequest)
                        return nil
                    }
                }
            }
        }

        // 3. init实例化UIViewController
        let viewController = pageType.init(
            uuid: UUID().uuidString, scheme: openRequest.scheme, query: openRequest.query,
            option: openRequest.option)

        // 事件回调
        viewController.beforeOpen(request: openRequest)

        // 获取前置的ViewController
        if pageRecords.count == 0 {
            Log.e(RouterModule.TAG, "☂️pageRecords.count:\(pageRecords.count)")
            #if DEBUG
                fatalError("这种场景不应该存在!!请排查")
            #endif
        }

        // 4. 调用push
        guard let formerViewController: UIViewController = pageRecords.last?.page else {
            let errorDesc = "☂️formerViewController is null . Check RootViewController pageRecords.count:\(pageRecords.count)"
            Log.e(RouterModule.TAG, errorDesc)
            return nil
        }
        var currentNavigationController: UINavigationController
        guard let navigationController = navigationController else {
            Log.e(
                RouterModule.TAG,
                "☂️navigationController is null . Check RootViewController setupControllers has been call"
            )
            return nil
        }

        let after = { (currentNavigationController: UINavigationController) in
            // 事件回调
            viewController.afterOpen(request: openRequest)

            // 后置拦截器
            for filterArray in self.openAfterInterceptors {
                for (_, filter) in filterArray {
                    if filter.canInitAfterOpen(request: openRequest) {
                        let _ = filter.handleAfterOpen(openRequest)
                    }
                }
            }

            //            self.pageRecords.append(
            //                PageRecord(
            //                    page: viewController,
            //                    openRequest: openRequest,
            //                    navigationController: currentNavigationController,
            //                    formerViewController: formerViewController))
            Log.i(
                RouterModule.TAG,
                #function
                    + "☂️[2] open after handle. page : \(type(of: viewController)),uuid: \(viewController.uuid),pageRecords.count: \(self.pageRecords.count)"
            )
        }

        // 跳转
        switch openRequest.option.navigationType {
        case .push:
            if pageRecords.isEmpty {
                currentNavigationController = navigationController
            } else {
                if let lastNavigationController = pageRecords.last?.navigationController {
                    currentNavigationController = lastNavigationController
                } else {
                    currentNavigationController = navigationController
                }
            }
            currentNavigationController.delegate = self

            Log.i(
                RouterModule.TAG,
                #function
                    + "☂️[1] push page: \(type(of: viewController)),uuid: \(viewController.uuid),animated: \(openRequest.option.animated),naviVC:\(currentNavigationController),pageRecords.count: \(self.pageRecords.count)"
            )

            // 压栈
            self.pageRecords.append(
                PageRecord(
                    page: viewController,
                    openRequest: openRequest,
                    navigationController: currentNavigationController,
                    formerViewController: formerViewController))

            currentNavigationController.pushViewController(
                viewController, animated: openRequest.option.animated)

            status = .idle
            // 移除页面栈
            after(currentNavigationController)

            Log.i(
                RouterModule.TAG,
                #function
                    + "☂️[3] push page completion : \(type(of: viewController)),uuid: \(viewController.uuid),pageRecords.count: \(self.pageRecords.count)"
            )
            completion?()

        case .present(let style, let transitioningDelegate):

            currentNavigationController = UINavigationController(rootViewController: viewController)
            currentNavigationController.modalPresentationStyle = style ?? .fullScreen

            // 接管present，修复手动关闭时，未移除页面栈的问题
            currentNavigationController.presentationController?.delegate = self

            // 自定义进场动画
            if let transitionDelegate = transitioningDelegate {
                currentNavigationController.transitioningDelegate = transitionDelegate as! any UIViewControllerTransitioningDelegate
            } else {
                if style == .custom {
                    currentNavigationController.transitioningDelegate = transitionDelegate

                }
            }

            Log.i(
                RouterModule.TAG,
                #function
                    + "☂️[1] present page: \(type(of: viewController)),uuid: \(viewController.uuid),naviVC:\(currentNavigationController),pageRecords.count: \(self.pageRecords.count)"
            )

            if style != .fullScreen {
                formerViewController.viewWillDisappear(openRequest.option.animated)
            }

            // 压栈
            self.pageRecords.append(
                PageRecord(
                    page: viewController,
                    openRequest: openRequest,
                    navigationController: currentNavigationController,
                    formerViewController: formerViewController))

            formerViewController.present(
                currentNavigationController, animated: openRequest.option.animated,
                completion: {
                    if style != .fullScreen {
                        formerViewController.viewDidDisappear(openRequest.option.animated)
                    }

                    self.status = .idle

                    // 移除页面栈
                    after(currentNavigationController)

                    Log.i(
                        RouterModule.TAG,
                        #function
                            + "☂️[3] present page completion : \(type(of: viewController)),uuid: \(viewController.uuid),pageRecords.count: \(self.pageRecords.count)"
                    )
                    completion?()

                })

        }
        return viewController
    }

    @MainActor public func close(
        _ uuid: String, _ closeData: [String: Any]?, _ closeOption: RouteOption?,
        _ completion: (([String: Any]?) -> Void)?
    )
        -> RouterPageProtocol?
    {
        Log.d(
            RouterModule.TAG,
            #function
                + "🌂start close uuid: \(uuid),pageRecords.count: \(pageRecords.count)"
        )
        if status == .closing {
            Log.e(RouterModule.TAG, "🌂The page is closing.")
            return nil
        } else {
            status = .closing
        }

        guard let openRecord = pageRecords.first(where: { $0.page.uuid == uuid }) else {
            Log.e(RouterModule.TAG, "🌂The page stack is empty.")
            return nil
        }

        if pageRecords.count == 1 {
            Log.e(RouterModule.TAG, "🌂The root page can not close.")
            return nil
        }

        //找到历史
        guard let page = openRecord.page else {
            Log.e(RouterModule.TAG, "🌂openRecord.page is nil.")
            return nil
        }
        let openRequest = openRecord.openRequest
        var closeRequest = RouterCloseRequest(
            pageClass: type(of: page),
            scheme: page.scheme,
            query: page.query,
            option: closeOption ?? openRequest.option
        )

        // 前置拦截器
        for filterArray in closeBeforeInterceptors {
            for (uuid, filter) in filterArray {
                if filter.canInitBeforeClose(request: closeRequest) {
                    let result = filter.handleBeforeClose(closeRequest)
                    if let newRequest = result.newRequest {
                        closeRequest = newRequest
                        Log.i(
                            RouterModule.TAG,
                            "🌂新request被替换 uuid:\(uuid) scheme:\(closeRequest.scheme) params:\(closeRequest.query)"
                        )
                    }
                    if result.action == .interupt {
                        Log.i(RouterModule.TAG, "🌂被中断 uuid:\(uuid) scheme:\(closeRequest.scheme)")
                        filter.handleCloseInterupt(closeRequest)
                        return nil
                    }
                }
            }
        }

        // 事件回调
        page.beforeClose(request: closeRequest)

        let after = {
            //事件回调
            page.afterClose(request: closeRequest)

            // 移除记录
            if let index = self.pageRecords.firstIndex(where: { $0.page.uuid == page.uuid }) {
                let removed = self.pageRecords.remove(at: index)
                if let page = removed.page {
                    // 获取page的类名
                    Log.i(
                        RouterModule.TAG,
                        #function
                            + "🌂[2]close final .remove stack page: \(type(of: page)),uuid: \(page.uuid),pageRecords.count: \(self.pageRecords.count)"
                    )
                    #if DEBUG
                        if self.pageRecords.count == 0 {
                            Log.e(RouterModule.TAG, "!!!!!警告!!!! pageRecords.count is 0")
                            fatalError("!!!!!警告!!!! pageRecords.count is 0")
                        }
                    #endif
                }
            }

            //后置拦截器
            for filterArray in self.closeAfterInterceptors {
                for (_, filter) in filterArray {
                    if filter.canInitAfterClose(request: closeRequest) {
                        let _ = filter.handleAfterOpen(closeRequest)
                    }
                }
            }

        }

        // 关闭
        let navigationType: NavigationType = openRequest.option.navigationType
        switch navigationType {
        case .push:
            let navigationController = openRecord.navigationController

            status = .idle
            Log.i(
                RouterModule.TAG,
                #function
                    + "🌂close[1] popViewController page: \(type(of: page)),uuid: \(page.uuid),pageRecords.count: \(self.pageRecords.count)"
            )
            navigationController.popViewController(animated: closeRequest.option.animated)
            openRequest.closeHandler(closeData)

            // 移除堆栈
            after()

            Log.i(
                RouterModule.TAG,
                #function
                    + "🌂close[3] completion page: \(type(of: page)),uuid: \(page.uuid),pageRecords.count: \(self.pageRecords.count)"
            )
            completion?(closeData)

        case .present(let style, _):
            Log.i(
                RouterModule.TAG,
                #function
                    + "🌂close[1] dismiss page: \(type(of: page)),uuid: \(page.uuid),pageRecords.count: \(self.pageRecords.count)"
            )

            if style != .fullScreen {
                // https://stackoverflow.com/questions/51089058/swift-viewwillappear-not-being-called-after-dismissing-view-controller
                openRecord.formerViewController?.viewWillAppear(closeRequest.option.animated)
            }

            openRecord.formerViewController!.dismiss(
                animated: closeRequest.option.animated,
                completion: {
                    if style != .fullScreen {
                        openRecord.formerViewController?.viewDidAppear(closeRequest.option.animated)
                    }

                    self.status = .idle
                    // 调用打开的closeHandler
                    openRequest.closeHandler(closeData)

                    // 移除堆栈
                    after()
                    Log.i(
                        RouterModule.TAG,
                        #function
                            + "🌂close[3] page: \(type(of: page)),uuid: \(page.uuid),pageRecords.count: \(self.pageRecords.count)"
                    )
                    completion?(closeData)
                })
        }

        return page
    }

    public func pages() -> [RouterPageProtocol] {
        return pageRecords.map { $0.page }
    }

    public func addOpenBeforeInterceptor(interceptor: RouterOpenBeforeInterceptor) {
        let uuid = UUID().uuidString
        openBeforeInterceptors.append([uuid: interceptor])
        Log.i(RouterModule.TAG, "addBeforeInterceptor \(uuid)")
    }

    public func addOpenAfterInterceptor(filter: RouterOpenAfterInterceptor) {
        let uuid = UUID().uuidString
        openAfterInterceptors.append([uuid: filter])
    }

    public func addCloseBeforeInterceptor(filter: RouterCloseBeforeInterceptor) {
        let uuid = UUID().uuidString
        closeBeforeInterceptors.append([uuid: filter])
    }

    public func addCloseAfterInterceptor(filter: RouterCloseAfterInterceptor) {
        let uuid = UUID().uuidString
        closeAfterInterceptors.append([uuid: filter])
    }

    public func clearBeforeInterceptor() {
        openBeforeInterceptors.removeAll()
    }

    public func clearAfterInterceptor() {
        openAfterInterceptors.removeAll()
    }

    public func clearCloseBeforeInterceptor() {
        closeBeforeInterceptors.removeAll()
    }

    public func clearCloseAfterInterceptor() {
        closeAfterInterceptors.removeAll()
    }

    // MARK: UIAdaptivePresentationControllerDelegate
    // 当用户直接操作右划退出关闭
    public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        Log.i(
            RouterModule.TAG, "🌂presentationControllerDidDismiss was dismissed by user interaction")
        for (_, openRecord) in pageRecords.enumerated() {
            if openRecord.formerViewController == presentationController.presentingViewController {
                self.closeWithoutInterceptor(openRecord: openRecord)
            }
        }
    }

    // MARK: UINavigationControllerDelegate
    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        // https://stackoverflow.com/questions/26674279/app-freeze-on-ios-8-when-push-or-pop
        if navigationController.viewControllers.count > 1 {
            if let viewController = viewController as? RouterPageProtocol {
                viewController.navigationController(navigationController, didShow: animated)
                Log.d("PopGestureRecognizer", "call RouterPageProtocol")
            } else {
                Log.d("PopGestureRecognizer", "no call RouterPageProtocol.")
            }
        } else {
            navigationController.interactivePopGestureRecognizer?.delegate = nil
            navigationController.interactivePopGestureRecognizer?.isEnabled = false

            Log.d("PopGestureRecognizer", "navigationController.viewControllers.count 0.")

        }
    }

    //    当用户直接操作右划退出关闭
    public func navigationController(
        _ navigationController: UINavigationController, willShow viewController: UIViewController,
        animated: Bool
    ) {

        if let coordinator = navigationController.topViewController?.transitionCoordinator {
            coordinator.notifyWhenInteractionChanges { [weak self] context in

                if !context.isCancelled {
                    let found = RouterModule.shared.pageRecords.last

                    guard let openRecord = found else {
                        Log.e(RouterModule.TAG, "The page stack is empty.")

                        #if DEBUG
                            fatalError("The page stack is empty.")
                        #else
                            return
                        #endif
                    }
                    openRecord.page.viewWillDisappearByUserDrag()
                    self?.closeWithoutInterceptor(openRecord: openRecord)
                }
            }
        }
    }

    func closeWithoutInterceptor(openRecord: PageRecord) {

        guard let page = openRecord.page else {
            Log.e(RouterModule.TAG, #function + "🌂openRecord.page is nil.")
            return
        }
        let openRequest = openRecord.openRequest
        let closeRequest = RouterCloseRequest(
            pageClass: type(of: page),
            scheme: page.scheme,
            query: page.query,
            option: openRequest.option
        )

        Log.d(RouterModule.TAG, #function + "🌂右划退出。page: \(type(of: page)),uuid: \(page.uuid) pageRecords.count: \(pageRecords.count)")

        // 前置拦截器
        for filterArray in closeBeforeInterceptors {
            for (uuid, filter) in filterArray {
                if filter.canInitBeforeClose(request: closeRequest) {
                    let warning = "⚠️用户操作关闭无法被中断 uuid:\(uuid) scheme:\(closeRequest.scheme)"
                    Log.e(RouterModule.TAG, warning)
                    filter.handleCloseInterupt(closeRequest)
                    #if DEBUG
                        // Alert.show(title: "⚠️警告", message: warning)
                    #endif
                }
            }
        }

        // 事件回调
        page.beforeClose(request: closeRequest)

        //事件回调
        page.afterClose(request: closeRequest)
        // 移除记录
        if let index = pageRecords.firstIndex(where: { $0.page.uuid == page.uuid }) {
            pageRecords.remove(at: index)

            #if DEBUG
                if pageRecords.count == 0 {
                    Log.e(RouterModule.TAG, "!!!!!警告!!!! pageRecords.count is 0")
                    fatalError("!!!!!警告!!!! pageRecords.count is 0")
                }
            #endif
        }

        // // 关闭
        //后置拦截器
        for filterArray in closeAfterInterceptors {
            for (_, filter) in filterArray {
                if filter.canInitAfterClose(request: closeRequest) {
                    let _ = filter.handleAfterOpen(closeRequest)
                }
            }
        }

        // 调用打开的closeHandler
        // TOOD: 补全数据
        Log.w(RouterModule.TAG, #function + "🌂用户操作关闭,可能无法回传数据 page: \(type(of: page)),uuid: \(page.uuid) pageRecords.count: \(pageRecords.count)")
        openRequest.closeHandler([:])
    }

    let transitionDelegate = FadeTransitioningDelegate()

}

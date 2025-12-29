//
//  RouterPage.swift
//  GlobalIdleFish4iOS
//
//  Created by xiaoxiang's m1 mbp on 2024/4/1.
//

import UIKit

/// 路由页面协议
/// 定义路由必要的属性和方法，如果使用路由打开页面，需要实现该协议
public protocol RouterPageProtocol: UIViewController {

    /// 唯一ID
    var uuid: String { get set }

    /// 路由名
    var scheme: String { get set }

    /// 参数
    var query: [String: Any] { get set }

    /// 容器配置
    var option: RouteOption { get set }

    /// 初始化时被调用
    init(uuid: String, scheme: String, query: [String: Any], option: RouteOption)

    /// 打开前被调用
    func beforeOpen(request: RouterOpenRequest)

    /// 打开时被调用
    func afterOpen(request: RouterOpenRequest)

    /// 关闭前被调用
    func beforeClose(request: RouterCloseRequest)

    /// 关闭后被调用
    func afterClose(request: RouterCloseRequest)

    /// 用户手动滑动关闭时被调用
    func viewWillDisappearByUserDrag()

    /// push完成时被调用
    func navigationController(_ navigationController: UINavigationController, didShow animated: Bool)

    /// 导航栏
    var navibar: NaviBarBaseView? { get set }

    /// 获得导航栏
    func getNavibar(rect: CGRect) -> NaviBarBaseView?

    //是否是返回
    func getIsbk() -> Bool?

}

/// 路由页面ViewControler
/// 该类实现了RouterPageProtocol协议，提供了一些常用的方法,如果使用UIKit进行排版，可以继承该类
 open class RouterViewController: UIViewController, RouterPageProtocol,
    UIAdaptivePresentationControllerDelegate
{

    static private let TAG = "RouterPage"

    public var scheme: String = ""

    public var uuid: String = ""

    public var query: [String: Any] = [:]

    public var option: RouteOption = RouteOption()

    public var navibar: NaviBarBaseView?

    var viewAppearCnt = 0

    required public init(uuid: String, scheme: String, query: [String: Any], option: RouteOption) {
        self.uuid = uuid
        self.scheme = scheme
        self.query = query
        self.option = option
        super.init(nibName: nil, bundle: nil)
    }

     required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func beforeOpen(request: RouterOpenRequest) {
        Log.d(RouterViewController.TAG, "beforeOpen")
    }

    public func afterOpen(request: RouterOpenRequest) {
        Log.d(RouterViewController.TAG, "afterOpen")
    }

    public func beforeClose(request: RouterCloseRequest) {
        Log.d(RouterViewController.TAG, "beforeClose")
    }

    public func afterClose(request: RouterCloseRequest) {
        Log.d(RouterViewController.TAG, "afterClose")
    }

    public func getNavibar(rect: CGRect) -> NaviBarBaseView? {
//        return CenterTitleNaviBarView(frame: rect)
        return nil
    }

    public func viewWillDisappearByUserDrag() {
        Log.d(RouterViewController.TAG, "viewWillDisappearByUserDrag")
    }

    //获取页面pageId
    public func getUTPageId() -> String {
        self.uuid
    }

    public func getIsbk() -> Bool? {
        return self.viewAppearCnt > 1
    }


    /// push完成时被调用
    public func navigationController(_ navigationController: UINavigationController, didShow animated: Bool) {
        setPopGestureRecognizer(navigationController: navigationController)
    }

    // MARK: Life cycle

    open override func viewDidLoad() {
        super.viewDidLoad()
        preformViewDidload()
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        performViewWillAppear(animated)
        Log.d("RouterPage", "RouterViewController viewWillAppear self:\(self).")
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        performViewDidAppear(animated)

        self.viewAppearCnt += 1
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        performViewWillDisappear(animated)
    }

    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        performViewDidDisappear(animated)
    }

    open override func loadView() {
        super.loadView()
        addNaviBarIfNeed()
    }

}

extension RouterPageProtocol {
    func preformViewDidload() {
        showNavBarIfNeed()
    }

    func performViewWillAppear(_ animated: Bool) {
        showNavBarIfNeed()
    }

    func performViewDidAppear(_ animated: Bool) {

    }

    func performViewWillDisappear(_ animated: Bool) {

    }

    func performViewDidDisappear(_ animated: Bool) {

    }

    func preformLoadView() {
        addNaviBarIfNeed()

    }
}

extension RouterPageProtocol {
    // MARK: 导航栏
    fileprivate func addNaviBarIfNeed() {
        // 不使用系统导航栏，自己绘制
        self.navigationController?.navigationBar.isHidden = true

        if option.navbarVisible == true, navibar == nil {
            let rect = CGRect(
                x: 0, y: 0, width: self.view.frame.width, height: UI.SafeAreaAndNavibarHeight)
            navibar = getNavibar(rect: rect)
            guard let navibar = navibar else {
                Log.e("RouterPageProtocol", "navibar is nil!!!")
                return
            }
            if let title = option.navbarTitle {
                navibar.setTitle(title)
            }
            view.addSubview(self.navibar!)
            view.bringSubviewToFront(self.navibar!)
        }
    }

    func showNavBarIfNeed() {
        // 不使用系统导航栏，自己绘制
        self.navigationController?.navigationBar.isHidden = true
        if let navibar = self.navibar {
            if option.navbarVisible == false {
                navibar.removeFromSuperview()
            } else {
                navibar.layer.zPosition = 1
                self.view.bringSubviewToFront(self.navibar!)
            }
        }
    }

    func setPopGestureRecognizer(navigationController: UINavigationController) {
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self as? any UIGestureRecognizerDelegate
        navigationController.interactivePopGestureRecognizer?.isEnabled = option.swipeBackEnabled

//        // 加强版的左滑退出
//        navigationController.fd_fullscreenPopGestureRecognizer.isEnabled = option.swipeBackEnabled
//        self.fd_interactivePopDisabled = false
    }
    // MARK: UIGestureRecognizerDelegate
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        Log.d("PopGestureRecognizer", "self:\(self),option.swipeBackEnabled:\(option.swipeBackEnabled)")
        return option.swipeBackEnabled
    }

    func setTitle(_ title: String) {
        if option.navbarVisible == true, navibar != nil {
            navibar?.setTitle(title)
        } else {
            Log.w("RouterPage", "navibar is nil or invisible")
        }
    }

}

/// 路由页面ViewControler
/// 该类实现了RouterPageProtocol协议，提供了一些常用的方法,如果使用UIKit进行排版，可以继承该类
open class RouterUIKitViewController: RouterViewController {
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public required init(uuid: String, scheme: String, query: [String: Any], option: RouteOption) {
        super.init(uuid: uuid, scheme: scheme, query: query, option: option)
    }
}

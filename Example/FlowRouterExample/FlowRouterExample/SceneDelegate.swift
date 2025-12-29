//
//  SceneDelegate.swift
//  FlowRouterExample
//
//  Created by xiaoxiang on 2025/12/26.
//

import UIKit
import FlowRouter

extension FlowRouter.Scheme {
    /// 1. 声明路由
    static let root = FlowRouter.Scheme("myScheme://root")
    static let tab1 = FlowRouter.Scheme("myScheme://tab1")
    static let tab2 = FlowRouter.Scheme("myScheme://tab2")
    static let uikit = FlowRouter.Scheme("myScheme://uikit")
    
    /// 2.路由+ViewController 绑定
    static public func schemeMap() -> [FlowRouter.Scheme: AnyClass] {
        let map: [FlowRouter.Scheme: AnyClass] = [
                .root: RootViewController.self,
                .tab1: Tab1ViewController.self,
                .tab2: Tab2ViewController.self,
                .uikit: UIKitViewController.self,
        ]
        return map
    }
    
    @MainActor
    static public func schemeActionMap() -> [FlowRouter.Scheme: RouteAction] {
        return [:]
    }
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }            
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        let root = RootViewController.shared
        root.window = window
        window.rootViewController = root
        window.makeKeyAndVisible()

        // 遍历所有的Router.schemeMap(),把key获取rawValue，value保持不变，生成一个新的map
        let stringVCMap = Dictionary<String, AnyClass>(
            uniqueKeysWithValues: FlowRouter.Scheme.schemeMap().map { (key, value) -> (String, AnyClass) in
                return (key.rawValue, value)
            })
        let stringActionMap = Dictionary<String, RouteAction>(
            uniqueKeysWithValues: FlowRouter.Scheme.schemeActionMap().map { (key, value) -> (String, RouteAction) in
                return (key.rawValue, value)
            })

        FlowRouter.register(
            stringVCMap,
            stringActionMap,
            rootViewController: RootViewController.shared,
            navigationController: RootViewController.shared.naviController!
        )
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }


}

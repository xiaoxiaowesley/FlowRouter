//
//  RootViewController.swift
//  FlowRouterExample
//
//  Created by xiaoxiang on 2025/12/26.
//

import UIKit
import FlowRouter

final class RootViewController: RouterViewController {
    
    var window: UIWindow?
    var naviController: UINavigationController?


    static let shared = RootViewController(
        uuid: UUID().uuidString, scheme: FlowRouter.Scheme.root.rawValue, query: [:],
        option: RouteOption(navbarVisible: false))
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        setupControllers()
    }
    
    func setupControllers() {
        let tabbarController = UITabBarController()
                
        let tab1VC = Tab1ViewController(
            uuid: UUID().uuidString, scheme: FlowRouter.Scheme.tab1.rawValue, query: [:],
            option: RouteOption(
                navBarTitle: "Tab1", navbarVisible: true))
        tab1VC.tabBarItem.title = "Tab1"
        tab1VC.tabBarItem.tag = 0
        
        let tab2VC = Tab2ViewController(
            uuid: UUID().uuidString, scheme: FlowRouter.Scheme.tab2.rawValue, query: [:],
            option: RouteOption(
                navBarTitle: "Tab2", navbarVisible: true))
        tab2VC.tabBarItem.title = "Tab2"
        tab2VC.tabBarItem.tag = 1
        
        tabbarController.viewControllers = [tab1VC,tab2VC]
        
        self.naviController = UINavigationController(rootViewController: tabbarController)
        addChild(naviController!)
        view.addSubview(naviController!.view)
        naviController!.didMove(toParent: self)
    }
}

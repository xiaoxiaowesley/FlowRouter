//
//  RouteMapManager.swift
//  GlobalIdleFish4iOS
//
//  Created by xiaoxiang's m1 mbp on 2024/5/16.
//

import UIKit

class RouteMapManager {
    @MainActor static let shared = RouteMapManager()
    func setup(
        routerPageMap: [String: AnyClass],
        routerActionMap: [String: RouteAction]
    ) {
        self.routerPageMap = routerPageMap
        self.routerActionMap = routerActionMap
    }

    var routerPageMap: [String: AnyClass]?
    var routerActionMap: [String: RouteAction]?

    func findPage(_ scheme: String) -> AnyClass? {
        return routerPageMap?[scheme]
    }

    func findAction(_ action: String) -> RouteAction? {
        return routerActionMap?[action]
    }
}

//
//  UI.swift
//  GlobalIdleFish4iOS
//
//  Created by xiaoxiang's m1 mbp on 2024/6/3.
//

import Foundation
import UIKit

@MainActor
struct UI {
    /// 导航栏+安全区高度
    static let SafeAreaAndNavibarHeight: Double = safeDistanceTop() + navigationBarHeight()

    /// 屏幕宽度
    static let screenWidth = UIScreen.main.bounds.width

    /// 屏幕高度
    static let screenHeight = UIScreen.main.bounds.height

    
    /// 导航栏高度
    static func navigationBarHeight() -> CGFloat {
        return 52.0
    }
    
    /// 顶部安全区高度
    static func safeDistanceTop() -> CGFloat {
        if #available(iOS 13.0, *) {
            let scene = UIApplication.shared.connectedScenes.first
            guard let windowScene = scene as? UIWindowScene else { return 0 }
            guard let window = windowScene.windows.first else { return 0 }
            return window.safeAreaInsets.top
        }

        if #available(iOS 11.0, *) {
            guard let window = UIApplication.shared.windows.first else { return 0 }
            return window.safeAreaInsets.top
        }
        return 0
    }

    /// 底部安全区高度
    static func safeDistanceBottom() -> CGFloat {
        if #available(iOS 13.0, *) {
            let scene = UIApplication.shared.connectedScenes.first
            guard let windowScene = scene as? UIWindowScene else { return 0 }
            guard let window = windowScene.windows.first else { return 0 }
            return window.safeAreaInsets.bottom
        }
        return 0
    }
}

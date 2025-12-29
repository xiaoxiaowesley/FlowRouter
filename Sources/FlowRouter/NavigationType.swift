//
//  File.swift
//  FlowRouter
//
//  Created by xiaoxiang on 2025/12/29.
//

import Foundation
import UIKit
/// 导航类型
public enum NavigationType: Equatable {
    public static func == (lhs: NavigationType, rhs: NavigationType) -> Bool {
        switch (lhs, rhs) {
        case (.push, .push):
            return true
        case (.present(let style1, let delegate1), .present(let style2, let delegate2)):
            // 比较 presenting style
            if style1 != style2 {
                return false
            }
            // 比较 transitioning delegate
            // 由于 delegate 是可选的，因此需要处理 nil 的情况
            if let delegate1 = delegate1, let delegate2 = delegate2 {
                return delegate1 === delegate2  // 使用引用比较
            } else {
                return delegate1 == nil && delegate2 == nil  // 只有两个都是 nil 时返回 true
            }
        default:
            return false
        }
    }

    case push
    /// pressent 方式 （参数二用于自定义进/退场动画）
    case present(UIModalPresentationStyle, (any UIViewControllerTransitioningDelegate)?)
}

extension NavigationType {
    public static func defaultPresent() -> NavigationType {
        return .present(.overFullScreen, nil)
    }
}

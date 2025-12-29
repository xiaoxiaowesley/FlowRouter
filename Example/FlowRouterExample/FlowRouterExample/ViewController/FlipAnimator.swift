//
//  FlipPresentAnimator.swift
//  FlowRouterExample
//
//  Created by xiaoxiang on 2025/12/29.
//

import UIKit

//////////////////////////////////////////////////////
// MARK: - Present: 右向左的 3D 翻页
//////////////////////////////////////////////////////

class FlipPresentAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    func transitionDuration(using ctx: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.7
    }

    func animateTransition(using ctx: UIViewControllerContextTransitioning) {

        guard let fromVC = ctx.viewController(forKey: .from),
              let toVC = ctx.viewController(forKey: .to) else { return }

        let container = ctx.containerView
        let duration = transitionDuration(using: ctx)

        // 添加 toVC
        container.addSubview(toVC.view)

        // 设置 3D 透视
        var transform = CATransform3DIdentity
        transform.m34 = -1.0 / 800

        container.layer.sublayerTransform = transform

        // 初始角度：从右边 -90° 开始翻进来
        toVC.view.layer.transform = CATransform3DMakeRotation(-.pi / 2, 0, 1, 0)

        UIView.animate(withDuration: duration, animations: {

            // fromVC 往左翻过去 90°
            fromVC.view.layer.transform =
                CATransform3DMakeRotation(.pi / 2, 0, 1, 0)

            // toVC 翻到正面
            toVC.view.layer.transform = CATransform3DIdentity

        }, completion: { finished in

            // 重置 transform
            fromVC.view.layer.transform = CATransform3DIdentity
            container.layer.sublayerTransform = CATransform3DIdentity

            ctx.completeTransition(finished)
        })
    }
}


//////////////////////////////////////////////////////
// MARK: - Dismiss: 左向右翻回
//////////////////////////////////////////////////////
class FlipDismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    func transitionDuration(using ctx: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.7
    }

    func animateTransition(using ctx: UIViewControllerContextTransitioning) {

        guard let fromVC = ctx.viewController(forKey: .from),
              let toVC   = ctx.viewController(forKey: .to) else { return }

        let container = ctx.containerView
        let duration = transitionDuration(using: ctx)

        // 强制确保 toVC.view 正确显示
        if toVC.view.superview == nil {
            container.addSubview(toVC.view)
        }
        container.bringSubviewToFront(fromVC.view)
        toVC.view.frame = ctx.finalFrame(for: toVC)

        // 设置 3D 透视
        var transform = CATransform3DIdentity
        transform.m34 = -1.0 / 800
        container.layer.sublayerTransform = transform

        // 初始角度：toVC 在左边等着翻出来
        toVC.view.layer.transform = CATransform3DMakeRotation(.pi / 2, 0, 1, 0)

        UIView.animate(withDuration: duration, animations: {

            fromVC.view.layer.transform =
                CATransform3DMakeRotation(-.pi / 2, 0, 1, 0)

            toVC.view.layer.transform = CATransform3DIdentity

        }, completion: { finished in

            // 重置 transform
            fromVC.view.layer.transform = CATransform3DIdentity
            container.layer.sublayerTransform = CATransform3DIdentity

            ctx.completeTransition(!ctx.transitionWasCancelled)
        })
    }
}

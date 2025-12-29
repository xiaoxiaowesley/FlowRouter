//
//  FadeTransitioning.swift
//  GlobalIdleFish4iOS
//
//  Created by xiaoxiang's m1 mbp on 2024/11/28.
//

import Foundation
import UIKit

class FadeInTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    // 设置动画持续时间
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }

    // 执行动画
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        // 获取源视图控制器和目标视图控制器
        guard let toViewController = transitionContext.viewController(forKey: .to) else {
            return
        }

        // 获取容器视图
        let containerView = transitionContext.containerView
        containerView.frame = CGRectMake(0, 0, UI.screenWidth, UI.screenHeight)
        let duration = transitionDuration(using: transitionContext)

        // 将目标视图控制器的视图添加到容器视图中
        containerView.addSubview(toViewController.view)
        toViewController.view.frame = containerView.bounds
        toViewController.view.alpha = 0 // 设置目标视图的初始透明度为 0

        // 执行动画
        UIView.animate(withDuration: duration, animations: {
            // 渐显目标视图
            toViewController.view.alpha = 1 // 使目标视图渐显到完全不透明
        }) { finished in
            // 动画结束后，进行 cleanup
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }

}


class FadeOutTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    // 动画持续时间
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?)
        -> TimeInterval
    {
        return 0.3
    }

    // 实际动画实现
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: .from) else {
            return
        }
        fromViewController.view.alpha = 1.0
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            animations: {
                fromViewController.view.alpha = 0.0
            },
            completion: { finished in
                transitionContext.completeTransition(finished)
            })
    }
}

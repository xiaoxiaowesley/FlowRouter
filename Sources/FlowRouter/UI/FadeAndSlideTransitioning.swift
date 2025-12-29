//
//  FadeAndSlideTransitioning.swift
//  GlobalIdleFish4iOS
//
//  Created by xiaoxiang's m1 mbp on 2024/7/16.
//

import Foundation
import UIKit

protocol TransitionLifeCycleDelegate: AnyObject {
    func transitionDidStart(transitionContext: UIViewControllerContextTransitioning)
    func transitionDidComplete(transitionContext: UIViewControllerContextTransitioning)
}

class FadeTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    // backgroundView开始颜色和结束颜色
    var backgroundStartColor: UIColor = UIColor.black.withAlphaComponent(0.0)
    var backgroundEndColor: UIColor = UIColor.black.withAlphaComponent(0.5)

    func animationController(
        forPresented presented: UIViewController, presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        return FadeAndSlideInTransitionAnimator(backgroundStartColor: backgroundStartColor, backgroundEndColor: backgroundEndColor)
    }

    func animationController(forDismissed dismissed: UIViewController)
        -> UIViewControllerAnimatedTransitioning?
    {
        return FadeAndSlideOutTransitionAnimator()
    }
}

class FadeAndSlideInTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    var backgroundStartColor: UIColor = UIColor.black.withAlphaComponent(0.0)
    var backgroundEndColor: UIColor = UIColor.black.withAlphaComponent(0.5)
    init(
        backgroundStartColor: UIColor = UIColor.black.withAlphaComponent(0.0),
        backgroundEndColor: UIColor = UIColor.black.withAlphaComponent(0.5)
    ) {
        self.backgroundStartColor = backgroundStartColor
        self.backgroundEndColor = backgroundEndColor
        super.init()
    }

    weak var completionDelegate: TransitionLifeCycleDelegate?

    // 动画持续时间
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?)
        -> TimeInterval
    {
        return 0.3
    }

    // 实际动画实现
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toViewController = transitionContext.viewController(forKey: .to) else {
            return
        }

        let containerView = transitionContext.containerView
        let finalFrame = transitionContext.finalFrame(for: toViewController)

        if let delegate = completionDelegate {
            delegate.transitionDidStart(transitionContext: transitionContext)
        }

        // 初始状态：透明并位于屏幕底部外
        toViewController.view.frame = finalFrame.offsetBy(dx: 0, dy: finalFrame.height)
        toViewController.view.alpha = 0.0
        let backgroundView = UIView(frame: finalFrame)
        backgroundView.backgroundColor = backgroundStartColor
        containerView.addSubview(backgroundView)
        containerView.addSubview(toViewController.view)

        // 动画效果：位置自下而上，透明度从0到0.5
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            animations: {
                backgroundView.backgroundColor = self.backgroundEndColor
                toViewController.view.frame = finalFrame
                toViewController.view.alpha = 1.0
            },
            completion: { finished in

                //            backgroundView.removeFromSuperview()
                transitionContext.completeTransition(finished)
            })
    }
}

class FadeAndSlideOutTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {

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

        let initialFrame = transitionContext.initialFrame(for: fromViewController)

        // 动画效果：位置自上而下，透明度从0.5到0
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            animations: {
                fromViewController.view.frame = initialFrame.offsetBy(
                    dx: 0, dy: initialFrame.height)
                fromViewController.view.alpha = 0.0
            },
            completion: { finished in
                transitionContext.completeTransition(finished)
            })
    }
}

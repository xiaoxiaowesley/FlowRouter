//
//  HomeViewController.swift
//  FlowRouterExample
//
//  Created by xiaoxiang on 2025/12/29.
//

import UIKit
import FlowRouter

class Tab1ViewController: RouterUIKitViewController {
    
    private let pushButton = UIButton(type: .system)
    private let presentButton = UIButton(type: .system)
    private let customTransitionButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        // Set frames for buttons with absolute positioning
        let buttonWidth: CGFloat = 200
        let buttonHeight: CGFloat = 50
        let spacing: CGFloat = 20
        let startX = (view.frame.width - buttonWidth) / 2
        let startY = (view.frame.height - (buttonHeight * 3 + spacing * 2)) / 2
        
        pushButton.frame = CGRect(x: startX, y: startY, width: buttonWidth, height: buttonHeight)
        pushButton.setTitle("open (push)", for: .normal)
        pushButton.backgroundColor = .systemBlue
        pushButton.setTitleColor(.white, for: .normal)
        pushButton.layer.cornerRadius = 8
        pushButton.addTarget(self, action: #selector(pushButtonTapped), for: .touchUpInside)
        
        presentButton.frame = CGRect(x: startX, y: startY + buttonHeight + spacing, width: buttonWidth, height: buttonHeight)
        presentButton.setTitle("open (present)", for: .normal)
        presentButton.backgroundColor = .systemGreen
        presentButton.setTitleColor(.white, for: .normal)
        presentButton.layer.cornerRadius = 8
        presentButton.addTarget(self, action: #selector(presentButtonTapped), for: .touchUpInside)
        
        customTransitionButton.frame = CGRect(x: startX, y: startY + (buttonHeight + spacing) * 2, width: buttonWidth, height: buttonHeight)
        customTransitionButton.setTitle("open (custom transition)", for: .normal)
        customTransitionButton.backgroundColor = .systemOrange
        customTransitionButton.setTitleColor(.white, for: .normal)
        customTransitionButton.layer.cornerRadius = 8
        customTransitionButton.addTarget(self, action: #selector(customTransitionButtonTapped), for: .touchUpInside)
        
        view.addSubview(pushButton)
        view.addSubview(presentButton)
        view.addSubview(customTransitionButton)
    }
    
    @objc private func pushButtonTapped() {
        FlowRouter.open(.uikit)
    }
    
    @objc private func presentButtonTapped() {
        FlowRouter.open(.uikit,[:],RouteOption(navigationType:.defaultPresent()))
    }
    
    @objc private func customTransitionButtonTapped() {
        FlowRouter.open(.uikit,[:],RouteOption(navigationType:.present(.custom, self)))
    }
    
    // MARK: 生命周期
    required init(uuid: String, scheme: String, query: [String: Any], option: RouteOption) {
        super.init(uuid: uuid, scheme: scheme, query: query, option: option)
    }
    
    @MainActor required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
// MARK: - UIViewControllerTransitioningDelegate
extension Tab1ViewController : UIViewControllerTransitioningDelegate{
    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController)
        -> UIViewControllerAnimatedTransitioning? {
        return FlipPresentAnimator()
    }

    func animationController(forDismissed dismissed: UIViewController)
        -> UIViewControllerAnimatedTransitioning? {
        return FlipDismissAnimator()
    }
}

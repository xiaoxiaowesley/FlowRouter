//
//  SecondViewController.swift
//  FlowRouterExample
//
//  Created by xiaoxiang on 2025/12/29.
//

import UIKit
import FlowRouter

class UIKitViewController: RouterUIKitViewController {
    
    private let infoLabel = UILabel()
    private let pushButton = UIButton(type: .system)
    private let presentButton = UIButton(type: .system)
    private let customTransitionButton = UIButton(type: .system)
    private let defaultTransitionButton = UIButton(type: .system)
    private let closeButton = UIButton(type: .system)
    private let openAwaitCloseButton = UIButton(type: .system)
    private let closeWithDataButton = UIButton(type: .system)
    private let resultLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        // Create info label to display router information
        infoLabel.numberOfLines = 0
        infoLabel.textAlignment = .left
        infoLabel.font = UIFont.systemFont(ofSize: 14)
        infoLabel.backgroundColor = UIColor.systemGray6
        infoLabel.layer.cornerRadius = 8
        infoLabel.clipsToBounds = true
        
        // Set frames for buttons with absolute positioning
        let buttonWidth: CGFloat = 200
        let buttonHeight: CGFloat = 50
        let spacing: CGFloat = 20
        let infoLabelHeight: CGFloat = 200
        let startX = (view.frame.width - buttonWidth) / 2
        let infoStartY = 100
        let buttonStartY = CGFloat(infoStartY) + infoLabelHeight + spacing
        
        infoLabel.frame = CGRect(x: 20, y: CGFloat(infoStartY), width: view.frame.width - 40, height: infoLabelHeight)
        
        pushButton.frame = CGRect(x: startX, y: buttonStartY, width: buttonWidth, height: buttonHeight)
        pushButton.setTitle("open (push)", for: .normal)
        pushButton.backgroundColor = .systemBlue
        pushButton.setTitleColor(.white, for: .normal)
        pushButton.layer.cornerRadius = 8
        pushButton.addTarget(self, action: #selector(pushButtonTapped), for: .touchUpInside)
        
        presentButton.frame = CGRect(x: startX, y: buttonStartY + buttonHeight + spacing, width: buttonWidth, height: buttonHeight)
        presentButton.setTitle("open (present)", for: .normal)
        presentButton.backgroundColor = .systemGreen
        presentButton.setTitleColor(.white, for: .normal)
        presentButton.layer.cornerRadius = 8
        presentButton.addTarget(self, action: #selector(presentButtonTapped), for: .touchUpInside)
        
        customTransitionButton.frame = CGRect(x: startX, y: buttonStartY + (buttonHeight + spacing) * 2, width: buttonWidth, height: buttonHeight)
        customTransitionButton.setTitle("open (custom transition)", for: .normal)
        customTransitionButton.backgroundColor = .systemOrange
        customTransitionButton.setTitleColor(.white, for: .normal)
        customTransitionButton.layer.cornerRadius = 8
        customTransitionButton.addTarget(self, action: #selector(customTransitionButtonTapped), for: .touchUpInside)
        
        defaultTransitionButton.frame = CGRect(x: startX, y: buttonStartY + (buttonHeight + spacing) * 3, width: buttonWidth, height: buttonHeight)
        defaultTransitionButton.setTitle("open (default transition)", for: .normal)
        defaultTransitionButton.backgroundColor = .systemPurple
        defaultTransitionButton.setTitleColor(.white, for: .normal)
        defaultTransitionButton.layer.cornerRadius = 8
        defaultTransitionButton.addTarget(self, action: #selector(defaultTransitionButtonTapped), for: .touchUpInside)
        
        closeButton.frame = CGRect(x: startX, y: buttonStartY + (buttonHeight + spacing) * 4, width: buttonWidth, height: buttonHeight)
        closeButton.setTitle("close", for: .normal)
        closeButton.backgroundColor = .systemRed
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.layer.cornerRadius = 8
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        
        openAwaitCloseButton.frame = CGRect(x: startX, y: buttonStartY + (buttonHeight + spacing) * 5, width: buttonWidth, height: buttonHeight)
        openAwaitCloseButton.setTitle("open await close data", for: .normal)
        openAwaitCloseButton.backgroundColor = .systemTeal
        openAwaitCloseButton.setTitleColor(.white, for: .normal)
        openAwaitCloseButton.layer.cornerRadius = 8
        openAwaitCloseButton.addTarget(self, action: #selector(openAwaitCloseButtonTapped), for: .touchUpInside)
        
        closeWithDataButton.frame = CGRect(x: startX, y: buttonStartY + (buttonHeight + spacing) * 6, width: buttonWidth, height: buttonHeight)
        closeWithDataButton.setTitle("close with data", for: .normal)
        closeWithDataButton.backgroundColor = .systemPink
        closeWithDataButton.setTitleColor(.white, for: .normal)
        closeWithDataButton.layer.cornerRadius = 8
        closeWithDataButton.addTarget(self, action: #selector(closeWithDataButtonTapped), for: .touchUpInside)
        
        resultLabel.frame = CGRect(x: 20, y: buttonStartY + (buttonHeight + spacing) * 7, width: view.frame.width - 40, height: 60)
        resultLabel.numberOfLines = 0
        resultLabel.textAlignment = .left
        resultLabel.font = UIFont.systemFont(ofSize: 14)
        resultLabel.backgroundColor = UIColor.systemGray6
        resultLabel.layer.cornerRadius = 8
        resultLabel.clipsToBounds = true
        resultLabel.text = "Result will be shown here"
        
        view.addSubview(infoLabel)
        view.addSubview(pushButton)
        view.addSubview(presentButton)
        view.addSubview(customTransitionButton)
        view.addSubview(defaultTransitionButton)
        view.addSubview(closeButton)
        view.addSubview(openAwaitCloseButton)
        view.addSubview(closeWithDataButton)
        view.addSubview(resultLabel)
        
        // Update info label with router information
        updateInfoLabel()
    }
    
    @objc private func pushButtonTapped() {
        FlowRouter.open(.uikit)
    }
    
    @objc private func presentButtonTapped() {
        FlowRouter.open(.uikit, [:], RouteOption(navigationType: .defaultPresent()))
    }
    
    @objc private func customTransitionButtonTapped() {
        FlowRouter.open(.uikit,[:],RouteOption(navigationType:.present(.custom, self)))
    }
    
    @objc private func defaultTransitionButtonTapped() {
        FlowRouter.open(.uikit, [:], RouteOption(navigationType: .defaultPresent()))
    }
    
    @objc private func closeButtonTapped() {
        FlowRouter.pop()
    }
    
    @objc private func openAwaitCloseButtonTapped() {
        Task {
            let result = try await FlowRouter.awaitOpen(.uikit)
            DispatchQueue.main.async {
                if let dictResult = result {
                    self.resultLabel.text = "Await result: \(String(describing: dictResult.value))"
                } else {
                    self.resultLabel.text = "Await result: \(String(describing: result))"
                }
            }
        }
    }
    
    @objc private func closeWithDataButtonTapped() {
        FlowRouter.pop(["closeData": "This is data passed when closing"])
    }
    
    private func updateInfoLabel() {
        let infoText = """
        UUID: \(uuid)
        Scheme: \(scheme)
        Query: \(query.map { "\($0.key): \($0.value)" }.joined(separator: ", "))
        Animated: \(option.animated)
        Navigation Type: \(option.navigationType)
        Navbar Title: \(option.navbarTitle ?? "nil")
        Navbar Visible: \(option.navbarVisible ?? true)
        Swipe Back Enabled: \(option.swipeBackEnabled)
        Transparent: \(option.transparent)
        Ignore Keyboard: \(option.ignoreKeyboard)
        """
        infoLabel.text = infoText
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
extension UIKitViewController : UIViewControllerTransitioningDelegate{
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

//
//  NaviBarView.swift
//  GlobalIdleFish4iOS
//
//  Created by xiaoxiang's m1 mbp on 2024/5/15.
//

import UIKit

public class NaviBarBaseView: UIView {
    let backgroundView = UIImageView()
    let rightViews: [UIView]
    let leftViews: [UIView]
    let centerView: [UIView]
    let spaceView = UIImageView()
    let bottomView = UIView()

    init(frame: CGRect, right: [UIView], left: [UIView], center: [UIView]) {
        self.rightViews = right
        self.leftViews = left
        self.centerView = center
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func commonInit() {
        self.backgroundColor = .white

        addSubview(backgroundView)

        // Add subviews and configure constraints
        addSubview(spaceView)
//        spaceView.snp.makeConstraints { make in
//            make.top.left.right.equalToSuperview()
//            make.height.equalTo(UI.safeDistanceTop())
//        }

        addSubview(bottomView)
//        bottomView.snp.makeConstraints { make in
//            make.top.equalTo(spaceView.snp.bottom)
//            make.left.right.bottom.equalToSuperview()
//        }

        //添加左边的按钮
        for view in leftViews {
            bottomView.addSubview(view)
        }
        //添加中间的按钮
        for view in centerView {
            bottomView.addSubview(view)
        }
        //添加右边的按钮
        for view in rightViews {
            bottomView.addSubview(view)
        }

        self.update()
//
//        backgroundView.snp.makeConstraints { make in
//            make.top.left.right.bottom.equalToSuperview()
//        }
    }

    func setTitle(_ title: String) {
        update()
    }

    func update() {
        //左边
//        var lastView: UIView?
//        for view in leftViews {
//            view.snp.updateConstraints { make in
//                make.centerY.equalToSuperview()
//                if let lastView = lastView {
//                    make.left.equalTo(lastView.snp.right).offset(16)
//                } else {
//                    make.left.equalToSuperview().offset(16)
//                }
//                // 宽度等于原来的宽度
//                make.width.equalTo(view.frame.width)
//            }
//            lastView = view
//        }
//
//        //中间
//        lastView = nil
//        for view in centerView {
//            view.snp.updateConstraints { make in
//                make.centerY.equalToSuperview()
//                if let lastView = lastView {
//                    make.left.equalTo(lastView.snp.right).offset(20)
//                } else {
//                    make.centerX.equalToSuperview()
//                }
//                make.width.equalTo(view.frame.width)
//            }
//            lastView = view
//        }
//        //右边
//        lastView = nil
//        for view in rightViews {
//            view.snp.updateConstraints { make in
//                make.centerY.equalToSuperview()
//                if let lastView = lastView {
//                    make.right.equalTo(lastView.snp.left).offset(-16)
//                } else {
//                    make.right.equalToSuperview().offset(-16)
//                }
//                make.width.equalTo(view.frame.width)
//            }
//            lastView = view
//        }
    }
}

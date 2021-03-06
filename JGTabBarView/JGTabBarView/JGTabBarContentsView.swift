//
//  JGTabBarView.swift
//  JGTabBarView
//
//  Created by JungMoon-Mac on 09/11/2018.
//  Copyright © 2018 JungMoon. All rights reserved.
//

import UIKit

public class JGTabBarContentsView: UIView {
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var contentScrollView: UIScrollView!
    @IBOutlet weak var headerWidthConstraint: NSLayoutConstraint!
    
    var tabButtons: [JGTabButton]? = []
    public var tabs: [JGTabBar]? {
        didSet {
            tabs?.forEach({ (tab) in
                if let button = addTab(tab: tab){
                    tabButtons?.append(button)
                    addViewController(tab: tab)
                }
            })
            onTouchTab(index: 0)
        }
    }
    
    private var lastCallBackIndex: Int = -1
    
    // MARK: public
    open func refreshCurrentTab() {
        lastCallBackIndex = -1
        let currentButton = tabButtons?[getCurrentIndex()]
        currentButton?.sendActions(for: UIControl.Event.touchUpInside)
        
    }
        
    open func selectTab(index: Int) {
        if let selectedButton = tabButtons?[index] {
            selectedButton.sendActions(for: UIControl.Event.touchUpInside)
        }
    }
    
    // MARK: - private
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public override func awakeFromNib() {
        headerWidthConstraint.isActive = false
        contentScrollView.delegate = self
    }
    
    private func addTab(tab: JGTabBar) -> JGTabButton? {
        if let tabButton = UINib(nibName: "JGTabButton", bundle: Bundle(for: JGTabButton.self)).instantiate(withOwner: self, options: nil).first as? JGTabButton {
            let lastButton = headerView.subviews.last
            
            headerView.addSubview(tabButton)
            tabButton.setTitle(tab.getTabTitle(), for: UIControl.State.normal)
            tabButton.addTarget(self, action: #selector(touchTab), for: UIControl.Event.touchUpInside)
            tabButton.translatesAutoresizingMaskIntoConstraints = false
            tabButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
            tabButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 32).isActive = true
            
            guard let tabObject = tab as? NSObject, let tabs = tabs else { return nil }
            if let first = tabs.first as? NSObject, first == tabObject { // 첫
                tabButton.isSelected = true
                tabButton.leftAnchor.constraint(equalTo: headerView.leftAnchor).isActive = true
            } else if let last = tabs.last as? NSObject, last == tabObject, let lastButton = lastButton { // 마지막
                tabButton.leadingAnchor.constraint(equalTo: lastButton.trailingAnchor, constant: 0).isActive = true
                tabButton.rightAnchor.constraint(equalTo: headerView.rightAnchor).isActive = true
            } else if let lastButton = lastButton { // 중간
                tabButton.leadingAnchor.constraint(equalTo: lastButton.trailingAnchor).isActive = true
            }
            
            return tabButton
        }
        
        return nil
    }
    
    private func addViewController(tab: JGTabBar){
        let lastView = contentScrollView.subviews.last
        
        let viewController = tab.getViewController()
        let view = viewController.view!
        contentScrollView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        guard let tabObject = tab as? NSObject, let tabs = tabs else { return }
        if let first = tabs.first as? NSObject, first == tabObject { // 첫
            view.leftAnchor.constraint(equalTo: contentScrollView.leftAnchor).isActive = true
        } else if let last = tabs.last as? NSObject, last == tabObject, let lastView = lastView { // 마지막
            view.leadingAnchor.constraint(equalTo: lastView.trailingAnchor, constant: 0).isActive = true
            view.rightAnchor.constraint(equalTo: contentScrollView.rightAnchor).isActive = true
        } else if let lastView = lastView { // 중간
            view.leadingAnchor.constraint(equalTo: lastView.trailingAnchor).isActive = true
        }
        
        view.widthAnchor.constraint(equalTo: contentScrollView.widthAnchor).isActive = true
        view.heightAnchor.constraint(equalTo: contentScrollView.heightAnchor).isActive = true
    }

    private func getCurrentIndex() -> Int {
        let offsetX = contentScrollView.contentOffset.x
        let scrollWidth = contentScrollView.bounds.width
        let index = Int(roundf(Float(offsetX)/Float(scrollWidth)))
        return index
    }
    /// 버튼 선택 처리 (나머지 셀렉트 취소)
    ///
    /// - Parameter selectedButton: 셀렉트할 버튼
    private func selectButton(selectedButton: UIButton) {
        tabButtons?.forEach({ (tabButton) in
            tabButton.isSelected = false
        })
        selectedButton.isSelected = true
    }
    
    private func onTouchTab(index: Int) {
        if index != lastCallBackIndex {
            lastCallBackIndex = index
            tabs?[index].onTouchTab()
        }
    }
    
    // MARK: - Touch Event
    @objc func touchTab(sender: JGTabButton) {
        selectButton(selectedButton: sender)
        let index = tabButtons?.firstIndex(of: sender)
        contentScrollView.contentOffset = CGPoint(x: contentScrollView.bounds.size.width * CGFloat(index ?? 0), y: 0)
        onTouchTab(index: getCurrentIndex())
    }
}

extension JGTabBarContentsView: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let index = getCurrentIndex()
        if let button = tabButtons?[Int(index)] {
            selectButton(selectedButton: button)
        }
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        onTouchTab(index: getCurrentIndex())
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        onTouchTab(index: getCurrentIndex())
    }
    
}

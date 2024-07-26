//
//  TestViewController.swift
//  EYViewPager
//
//  Created by Ezimet Yusuf on 10/16/16.
//  Copyright © 2016 ww.otkur.biz. All rights reserved.
//

import Foundation
import UIKit

class ExampleViewController: UIViewController, WormTabStripDelegate {

    var tabs:[UIViewController] = []
    let numberOfTabs = 3
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        setUpTabs()
        setUpViewPager()
    }
    
    func setUpTabs(){
        for _ in 1...numberOfTabs {
            let vc = ViewController()
            tabs.append(vc)
        }
    }
    
    func setUpViewPager(){
        let frame =  CGRect(x: 0, y: 40, width: self.view.frame.size.width, height: self.view.frame.size.height - 40)
        let viewPager:WormTabStrip = WormTabStrip(frame: frame)
        self.view.addSubview(viewPager)
        viewPager.delegate = self
        viewPager.eyStyle.wormStyle = .notWormyLine
        viewPager.eyStyle.isWormEnable = true
        viewPager.eyStyle.spacingBetweenTabs = 0
        viewPager.eyStyle.dividerBackgroundColor = .clear
        viewPager.eyStyle.tabItemSelectedColor = .blue
        viewPager.eyStyle.tabItemDefaultColor = .lightGray
        viewPager.eyStyle.topScrollViewBackgroundColor = .white
        viewPager.eyStyle.contentScrollViewBackgroundColor = .white
        viewPager.eyStyle.WormColor = .blue
        viewPager.currentTabIndex = 0
        viewPager.eyStyle.kPaddingOfIndicator = 0;
        viewPager.buildUI()
    }
    
    func wtsNumberOfTabs() -> Int {
        return numberOfTabs
    }
    
    func wtsTitleForTab(index: Int) -> String {
        return "Tab \(index)"
    }
    
    func wtsBadgeForTab(index: Int) -> Int {
        0;
    }
    
    func wtsViewOfTab(index: Int) -> UIView {
        let view = tabs[index]
        return view.view
    }

    func wtsDidSelectTab(index: Int) {
        print("selected index:\(index)")
    }
}

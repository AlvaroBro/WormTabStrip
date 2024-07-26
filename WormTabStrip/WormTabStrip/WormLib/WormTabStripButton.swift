//
//  TestTabButton.swift
//  EYViewPager
//
//  Created by Ezimet Yusuf on 10/16/16.
//  Copyright © 2016 ww.otkur.biz. All rights reserved.
//

import Foundation
import UIKit

@objc public class CustomBadge: NSObject {
    public let view: UIView
    public let position: CGPoint
    
    @objc public init(view: UIView, position: CGPoint) {
        self.view = view
        self.position = position
    }
}

class WormTabStripButton: UILabel {
    var index: Int?
    var paddingToEachSide: CGFloat = 10
    
    private var badgeLabel: UILabel?
    private var customBadgeView: UIView?
    
    var tabText: NSString? {
        didSet {
            updateLayout()
        }
    }
    
    var badgeCount: Int? {
        didSet {
            updateBadge()
        }
    }
    
    var customBadge: CustomBadge? {
        didSet {
            updateCustomBadge()
        }
    }

    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBadgeLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(key: String) {
        self.init(frame: .zero)
    }
    
    // MARK: - Setup
    
    private func setupBadgeLabel() {
        badgeLabel = UILabel()
        badgeLabel?.textAlignment = .center
        badgeLabel?.textColor = .white
        badgeLabel?.backgroundColor = .red
        badgeLabel?.layer.cornerRadius = 8
        badgeLabel?.clipsToBounds = true
        badgeLabel?.isHidden = true
        addSubview(badgeLabel!)
    }
    
    // MARK: - Layout
    
    private func updateLayout() {
        guard let text = tabText else { return }
        
        let textSize: CGSize = text.size(withAttributes: [.font: font!])
        self.frame.size.width = textSize.width + paddingToEachSide * 2
        
        self.text = String(text)
        
        updateBadgePosition()
        updateCustomBadge()
    }
    
    private func updateBadge() {
        guard customBadge == nil else { return }
        guard let badgeLabel = badgeLabel else { return }
        
        if let count = badgeCount, count > 0 {
            badgeLabel.text = "\(count)"
            badgeLabel.isHidden = false
            badgeLabel.sizeToFit()
            badgeLabel.frame.size = CGSize(width: max(16, badgeLabel.frame.width + 8), height: 16)
        } else {
            badgeLabel.isHidden = true
        }
        
        updateBadgePosition()
    }
    
    private func updateCustomBadge() {
        customBadgeView?.removeFromSuperview()
        
        if let customBadge = customBadge {
            customBadgeView = customBadge.view
            addSubview(customBadgeView!)
            customBadgeView!.frame.origin = customBadge.position
        }
        
        badgeLabel?.isHidden = (customBadge != nil)
    }
    
    private func updateBadgePosition() {
        guard let badgeLabel = badgeLabel else { return }
        
        let badgeSize = badgeLabel.frame.size
        badgeLabel.frame.origin = CGPoint(x: frame.width, y: badgeSize.height / 2)
    }
}

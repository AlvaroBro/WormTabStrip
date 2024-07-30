//
//  Test.swift
//  EYViewPager
//
//  Created by Ezimet Yusuf on 7/4/16.
//  Copyright © 2016 Ezimet Yusup. All rights reserved.
//

import Foundation
import UIKit

@objc public protocol WormTabStripDelegate: AnyObject {
    
    //return the Number SubViews in the ViewPager
    func wtsNumberOfTabs() -> Int
    //return the View for sepecific position
    func wtsViewOfTab(index:Int) -> UIView
    //return the title for each view
    func wtsTitleForTab(index:Int) -> String

    func wtsDidSelectTab(index:Int)
    
    func wtsBadgeForTab(index: Int) -> Int
    
    @objc optional func wtsCustomBadgeForTab(index: Int, tabFrame: CGRect) -> CustomBadge
}

@objc public enum WormStyle: Int {
    case bubble = 0
    case line = 1
    case notWormyLine = 2
}

@objc public class WormTabStripStylePropertyies: NSObject {
    
    @objc var wormStyle: WormStyle = .bubble
    /**********************
      Heights
     **************************/
    
    @objc var kHeightOfWorm: CGFloat = 3
    
    @objc var kHeightOfWormForBubble: CGFloat = 45
    
    @objc var kHeightOfDivider: CGFloat = 2
    
    @objc var kHeightOfTopScrollView: CGFloat = 50
    
    @objc var kMinimumWormHeightRatio: CGFloat = 4/5
    
    /**********************
     paddings
     **************************/
    
    //Padding of tabs text to each side
    @objc var kPaddingOfIndicator: CGFloat = 30
    
    //initial value for the tabs margin
    @objc var kWidthOfButtonMargin: CGFloat = 0
    
    
    @objc var isHideTopScrollView = false
    
    @objc var spacingBetweenTabs: CGFloat = 15
    
    @objc var isWormEnable = true
    
    /**********
     fonts
     ************/
    // font size of tabs
    //let kFontSizeOfTabButton:CGFloat = 15
    @objc var tabItemDefaultFont: UIFont = UIFont(name: "arial", size: 14)!
    @objc var tabItemSelectedFont: UIFont = UIFont(name: "arial", size: 14)!
    
    /*****
     colors
     ****/
    
    @objc var tabItemDefaultColor: UIColor = .white
    
    @objc var tabItemSelectedColor: UIColor = .red
    
    //color for worm
    @objc var WormColor: UIColor = UIColor(netHex: 0x1EAAF1)
    
    @objc var topScrollViewBackgroundColor: UIColor = UIColor(netHex: 0x364756)
    
    @objc var contentScrollViewBackgroundColor: UIColor = UIColor.gray
    
    @objc var dividerBackgroundColor: UIColor = UIColor.red
    
    @objc var notifyAppearanceTransitions = false
}


@objc public class WormTabStrip: UIView,UIScrollViewDelegate {
    
    private let topScrollView: UIScrollView = UIScrollView()
    
    private let contentScrollView: UIScrollView = UIScrollView()
    
    public var shouldCenterSelectedWorm = true
    
    private var titles: [String]! = []
    
    private var contentViews: [UIView]! = []
    
    private var tabs: [WormTabStripButton]! = []
    
    private let divider: UIView = UIView()
    
    private let worm: UIView = UIView()
    
    @objc public var eyStyle: WormTabStripStylePropertyies = WormTabStripStylePropertyies()
    
    //delegate
    @objc weak var delegate: WormTabStripDelegate?
    
    //Justify flag
    private var isJustified = false
    
    //tapping flag
    private var isUserTappingTab = false
    
    private var dynamicWidthOfTopScrollView: CGFloat = 0
    
    //MARK: init
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    convenience required public init(key:String) {
        self.init(frame: CGRect.zero)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        
    }
    
    
    @objc func buildUI()  {
        validate()
        addTopScrollView()
        addWorm()
        addDivider()
        addContentScrollView()
        buildContent()
        checkAndJustify()
        if currentTabIndex == -1 {
            currentTabIndex = 0
        }
        selectTabAt(index: currentTabIndex, animated: false)
        setTabStyle()
        slideWormToCurrentTab(animated: false)
    }
    
    private func validate(){
        if delegate == nil {
            assert(false, "EYDelegate is null, please set the EYDelegate")
            return
        }

        if delegate!.wtsNumberOfTabs() <= currentTabIndex {
            assert(false, "currentTabIndex can not be bigger or equal to EYnumberOfTab")
        }
    }
    
    
    // add top scroll view to the view stack which will contain the all the tabs
    private func addTopScrollView(){
        topScrollView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: eyStyle.kHeightOfTopScrollView)
        topScrollView.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
        topScrollView.backgroundColor = eyStyle.topScrollViewBackgroundColor
        topScrollView.showsHorizontalScrollIndicator = false
        self.addSubview(topScrollView)
    }
    // add divider between the top scroll view and content scroll view
    private func addDivider(){
        divider.frame = CGRect(x:0,y: eyStyle.kHeightOfTopScrollView, width:self.frame.width, height:eyStyle.kHeightOfDivider)
        divider.backgroundColor = eyStyle.dividerBackgroundColor
        self.addSubview(divider)
    }
    // add content scroll view to the view stack which will hold mian  views such like table view ...
    private func addContentScrollView(){
        if eyStyle.isHideTopScrollView {
            contentScrollView.frame = self.bounds
        } else {
            contentScrollView.frame = CGRect(x: 0,
                                             y: eyStyle.kHeightOfTopScrollView + eyStyle.kHeightOfDivider,
                                             width: self.bounds.width,
                                             height: self.bounds.height - eyStyle.kHeightOfTopScrollView - eyStyle.kHeightOfDivider)
        }
        contentScrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentScrollView.backgroundColor = eyStyle.contentScrollViewBackgroundColor
        contentScrollView.isPagingEnabled = true
        contentScrollView.delegate = self
        contentScrollView.showsHorizontalScrollIndicator = false
        contentScrollView.showsVerticalScrollIndicator = false
        contentScrollView.bounces = false
        self.addSubview(contentScrollView)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        // Actualizar el tamaño del contentScrollView
        if eyStyle.isHideTopScrollView {
            contentScrollView.frame = self.bounds
        } else {
            contentScrollView.frame = CGRect(x: 0,
                                             y: eyStyle.kHeightOfTopScrollView + eyStyle.kHeightOfDivider,
                                             width: self.bounds.width,
                                             height: self.bounds.height - eyStyle.kHeightOfTopScrollView - eyStyle.kHeightOfDivider)
        }
        
        // Actualizar el tamaño del contenido
        contentScrollView.contentSize = CGSize(width: CGFloat(delegate!.wtsNumberOfTabs()) * self.bounds.width,
                                               height: contentScrollView.bounds.height)
        
        // Actualizar la posición y tamaño de las vistas de contenido
        for i in 0..<delegate!.wtsNumberOfTabs() {
            let view = delegate!.wtsViewOfTab(index: i)
            view.frame = CGRect(x: CGFloat(i) * self.bounds.width,
                                y: 0,
                                width: self.bounds.width,
                                height: contentScrollView.bounds.height)
        }
        
        self.checkAndJustify()
        
        self.selectTabAt(index: currentTabIndex, animated: false)
        
        // Actualizar la posición del worm si es necesario
        slideWormToCurrentTab(animated: false)
    }
    
    private func addWorm(){
        topScrollView.addSubview(worm)
        
        resetHeightOfWorm()
        worm.frame.size.width = 100
        worm.backgroundColor = eyStyle.WormColor
        currentWormWidth = worm.frame.size.width
        
    }
    
    private func buildContent(){
        buildTopScrollViewsContent()
        buildContentScrollViewsContent()
    }
    
    private func buildTopScrollViewsContent(){
        dynamicWidthOfTopScrollView = 0
        var XOffset:CGFloat = eyStyle.spacingBetweenTabs;
        for i in 0..<delegate!.wtsNumberOfTabs(){
            //build the each tab and position it
            let tab:WormTabStripButton = WormTabStripButton()
            tab.index = i
            formatButton(tab: tab, XOffset: XOffset)
            XOffset += eyStyle.spacingBetweenTabs + tab.frame.width
            dynamicWidthOfTopScrollView += eyStyle.spacingBetweenTabs + tab.frame.width
            topScrollView.addSubview(tab)
            tabs.append(tab)
            topScrollView.contentSize.width = dynamicWidthOfTopScrollView
        }
    }
    
    /**************************
     format tab style, tap event
    ***************************************/
    private func formatButton(tab:WormTabStripButton,XOffset:CGFloat){
        tab.frame.size.height = eyStyle.kHeightOfTopScrollView
        tab.paddingToEachSide = eyStyle.kPaddingOfIndicator
        tab.tabText = delegate!.wtsTitleForTab(index: tab.index!) as NSString?
        tab.textColor = eyStyle.tabItemDefaultColor
        tab.font = eyStyle.tabItemDefaultFont
        tab.frame.origin.x = XOffset
        tab.frame.origin.y = 0
        tab.textAlignment = .center
        tab.isUserInteractionEnabled = true
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tabPress(sender:)))
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        tab.addGestureRecognizer(tap)
        if let customBadge = delegate?.wtsCustomBadgeForTab?(index: tab.index!, tabFrame: tab.frame) {
            tab.customBadge = customBadge
        } else if let badgeCount = delegate?.wtsBadgeForTab(index: tab.index!) {
            tab.badgeCount = badgeCount
        }
    }
    
    @objc public func updateBadges() {
        for (index, tab) in tabs.enumerated() {
            if let customBadge = delegate?.wtsCustomBadgeForTab?(index: index, tabFrame: tab.frame) {
                tab.customBadge = customBadge
            } else if let badgeCount = delegate?.wtsBadgeForTab(index: index) {
                tab.badgeCount = badgeCount
            } else {
                tab.badgeCount = nil
                tab.customBadge = nil
            }
        }
    }
    
    @objc public func updateBadge(at index: Int) {
        guard index >= 0 && index < tabs.count else { return }
        let tab = tabs[index]
        if let customBadge = delegate?.wtsCustomBadgeForTab?(index: index, tabFrame: tab.frame) {
            tab.customBadge = customBadge
        } else if let badgeCount = delegate?.wtsBadgeForTab(index: index) {
            tab.badgeCount = badgeCount
        } else {
            tab.badgeCount = nil
            tab.customBadge = nil
        }
    }
    
    // add all content views to content scroll view and tabs to top scroll view
    private func buildContentScrollViewsContent(){
        //print("buildContentScrollViewsContent")
        let count = delegate!.wtsNumberOfTabs()
        for i in 0..<count{
            let view = delegate!.wtsViewOfTab(index: i)
            var responder: UIResponder? = view
                   while !(responder is UIViewController) {
                       responder = responder?.next
                       if nil == responder {
                           break
                       }
                   }
            let vc = (responder as? UIViewController)!
            guard let parent = delegate as? UIViewController else {
                contentScrollView.addSubview(view)
                return
            }
            parent.addChild(vc)
            //vc.beginAppearanceTransition(true, animated: false)
            // Don't need to call beginAppearanceTransition and endAppearanceTransition because
            // it's already called automatically because of addSubview
            contentScrollView.addSubview(view)
            vc.didMove(toParent: parent)
            //vc.endAppearanceTransition()
        }
    }
    
    /*** if the content width of the topScrollView smaller than screen width
        do justification to the tabs  by increasing spcases between the tabs
        and rebuild all top and content views
     ***/
    private func checkAndJustify(){
        var totalTabsWidth:CGFloat = 0
        for tab in tabs {
            totalTabsWidth += tab.frame.size.width
        }
        
        // calculate the available space
        let gap:CGFloat = self.frame.width - totalTabsWidth
        // increase the space by dividing available space to # of tab plus one
        //plus one bc we always want to have margin from last tab to to right edge of screen
        eyStyle.spacingBetweenTabs = gap/CGFloat(delegate!.wtsNumberOfTabs()+1)
        dynamicWidthOfTopScrollView = 0
        var XOffset:CGFloat = eyStyle.spacingBetweenTabs;
        for tab in tabs {
            tab.frame.origin.x = XOffset
            XOffset += eyStyle.spacingBetweenTabs + tab.frame.width
            dynamicWidthOfTopScrollView += eyStyle.spacingBetweenTabs + tab.frame.width
            topScrollView.contentSize.width = dynamicWidthOfTopScrollView
        }
    }
    
    /*******
     tabs selector
     ********/
     @objc func tabPress(sender:AnyObject){
        
        isUserTappingTab = true
        
        let tap:UIGestureRecognizer = sender as! UIGestureRecognizer
        let tab:WormTabStripButton = tap.view as! WormTabStripButton
        selectTab(tab: tab, animated: true)
    }
    
    func selectTabAt(index:Int, animated:Bool){
        if index >= tabs.count {return}
        let tab = tabs[index]
        selectTab(tab: tab, animated: animated)
    }
    
    private func selectTab(tab:WormTabStripButton, animated:Bool){
        prevTabIndex = currentTabIndex
        currentTabIndex = tab.index!
        //print("selectTab: ", currentTabIndex);
        setTabStyle()
        
        slideWormToPosition(tab: tab, animated: animated)
        slideContentScrollViewToPosition(index: tab.index!, animated: animated)
        adjustTopScrollViewsContentOffsetX(tab: tab)
        centerCurrentlySelectedWorm(tab: tab)
    }
    
    
    private func slideWormToCurrentTab(animated:Bool) {
        let tab = tabs[currentTabIndex]
        slideWormToPosition(tab: tab, animated: animated)
    }
    
    /*******
     move worm to the correct position with slinding animation when the tabs are clicked
     ********/
    private func slideWormToPosition(tab:WormTabStripButton, animated:Bool){
        
        if !animated {
            self.worm.layer.removeAllAnimations()
        }
        
        UIView.animate(withDuration: animated ? 0.3 : 0.0) {
            self.slideWormToTabPosition(tab: tab)
        }
    }
    
    private func slideWormToTabPosition(tab:WormTabStripButton){
        //print("slideWormToTabPosition ", tab.frame)
        self.worm.frame.origin.x = tab.frame.origin.x
        self.worm.frame.size.width = tab.frame.width
        currentWormWidth = tab.frame.width
    }
    /*********************
        if the tab was at position of only half of it was showing up,
            we need to adjust it by setting content OffSet X of Top ScrollView
                when the tab was clicked
    *********************/
    private func adjustTopScrollViewsContentOffsetX(tab:WormTabStripButton){
        let widhtOfTab:CGFloat = tab.bounds.size.width
        let XofTab:CGFloat = tab.frame.origin.x
        let spacingBetweenTabs = eyStyle.spacingBetweenTabs
        //if tab at right edge of screen
        if XofTab - topScrollView.contentOffset.x > self.frame.width - (spacingBetweenTabs+widhtOfTab) {
            topScrollView.setContentOffset(CGPoint(x:XofTab - (self.frame.width-(spacingBetweenTabs+widhtOfTab)) , y:0), animated: true)
        }
        //if tab at left edge of screen
        if XofTab - topScrollView.contentOffset.x  < spacingBetweenTabs {
            topScrollView.setContentOffset(CGPoint(x:XofTab - spacingBetweenTabs, y:0), animated: true)
        }
    }
    
    func centerCurrentlySelectedWorm(tab:WormTabStripButton){
        //check the settings
        if shouldCenterSelectedWorm == false {return}
        //if worm tab was right/left side of screen and if there are enough space to scroll to center
        let XofTab:CGFloat = tab.frame.origin.x
        let toLeftOfScreen = (self.frame.width-tab.frame.width)/2
        //return if there is no enough space at right
        if XofTab + tab.frame.width + toLeftOfScreen > topScrollView.contentSize.width{
            return
        }
        //return if there is no enough space at left
        if XofTab - toLeftOfScreen < 0 {
            return
        }
        //center it 
        if topScrollView.contentSize.width - XofTab+tab.frame.width > toLeftOfScreen{
            // XofTab = x + (screenWidth-tab.frame.width)/2
            let offsetX = XofTab - toLeftOfScreen
            topScrollView.setContentOffset(CGPoint.init(x: offsetX, y: 0), animated: true)
        }
        
    }
    
    /*******
     move content scroll view to the correct position with animation when the tabs are clicked
     ********/
    private func slideContentScrollViewToPosition(index:Int, animated:Bool){
        let point = CGPoint(x:CGFloat(index)*self.frame.width,y: 0)
        UIView.animate(withDuration: animated ? 0.3 : 0.0, animations: {
                self.contentScrollView.setContentOffset(point, animated: false)
        }) { (finish) in
                self.isUserTappingTab = false
        }
        
    }
    
    /*************************************************
    //MARK: UIScrollView Delegate start
    ******************************************/
    var prevTabIndex = 0
    @objc public var currentTabIndex: Int = -1 {
        didSet {
            if currentTabIndex != oldValue {
                if delegate!.wtsNumberOfTabs() > oldValue && oldValue >= 0 {
                    if self.eyStyle.notifyAppearanceTransitions {
                        syncAppearanceOfVC(tabIndex: oldValue)
                    }
                }
                if delegate!.wtsNumberOfTabs() > currentTabIndex && currentTabIndex >= 0 && oldValue >= 0 {
                    if self.eyStyle.notifyAppearanceTransitions {
                        syncAppearanceOfVC(tabIndex: currentTabIndex)
                    }
                }
                delegate?.wtsDidSelectTab(index: currentTabIndex)
            }
        }
    }
    var currentWormX:CGFloat = 0
    var currentWormWidth:CGFloat = 0
    var contentScrollContentOffsetX:CGFloat = 0
    
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let currentX = scrollView.contentOffset.x
        currentTabIndex = Int(currentX > contentScrollContentOffsetX ? ceil(currentX/self.frame.width) : currentX/self.frame.width)
        
        //print("scrollViewWillBeginDragging: ", currentTabIndex)
        setTabStyle()
        prevTabIndex = currentTabIndex
        let tab = tabs[currentTabIndex]
        //need to call setTabStyle twice because, when user swipe their finger really fast, scrollViewWillBeginDragging method will be called agian without scrollViewDidEndDecelerating get call
        setTabStyle()
        currentWormX = tab.frame.origin.x
        currentWormWidth = tab.frame.width
        contentScrollContentOffsetX = scrollView.contentOffset.x
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //if user was tapping tab no need to do worm animation
        if isUserTappingTab == true {return}
        
        if eyStyle.isWormEnable == false {return}
        
        let currentX = scrollView.contentOffset.x
        var gap:CGFloat = 0
        
        //if user dragging to right, which means scrolling finger from right to left
        //which means scroll view is scrolling to right, worm also should worm to right
        if currentX > contentScrollContentOffsetX {
            gap = currentX -  contentScrollContentOffsetX
            
            //if currentTab is not last one do worm to next tab position 
            if currentTabIndex + 1 < tabs.count {
                let currentTab = tabs[currentTabIndex]
                let nextTab = tabs[currentTabIndex + 1]
                let sizeDiff: CGFloat = nextTab.frame.size.width - currentTab.frame.size.width
                let nextDistance:CGFloat = calculateNextMoveDistance(gap: gap, nextTotal: getNextTotalWormingDistance(index: min(currentTabIndex+1, tabs.count-1), adjustment: eyStyle.wormStyle == .notWormyLine ? -sizeDiff : 0))
                // println(nextDistance)
                setWidthAndHeightOfWormForDistance(distance: nextDistance)
                if eyStyle.wormStyle == .notWormyLine {
                    worm.frame.origin.x = currentWormX + nextDistance // Necesario para que sea progresivo y no wormy
                    let tabsDistance: CGFloat = nextTab.frame.origin.x - currentTab.frame.origin.x
                    let traveledDistance: CGFloat = worm.frame.origin.x - currentTab.frame.origin.x
                    let progess: CGFloat = traveledDistance / tabsDistance
                    let delta: CGFloat = progess * sizeDiff
                    //print(delta)
                    let intermediateWidth: CGFloat = currentTab.frame.size.width + delta
                    worm.frame.size.width = intermediateWidth
                }
            }
        }else{
            //else  user dragging to left, which means scrolling finger from  left to right
            //which means scroll view is scrolling to left, worm also should worm to left
            gap = contentScrollContentOffsetX - currentX
            //if current is not first tab at left do worm to left
            if currentTabIndex >= 1  {
                let prevTab = tabs[currentTabIndex - 1]
                let currentTab = tabs[currentTabIndex]
                let sizeDiff: CGFloat = prevTab.frame.size.width - currentTab.frame.size.width
                let nextDistance:CGFloat = calculateNextMoveDistance(gap: gap, nextTotal: getNextTotalWormingDistance(index: currentTabIndex-1, adjustment: eyStyle.wormStyle == .notWormyLine ? -sizeDiff : 0))
                 //print(nextDistance)
                setWidthAndHeightOfWormForDistance(distance: nextDistance)
                let prevWormX: CGFloat = worm.frame.origin.x;
                worm.frame.origin.x = currentWormX - nextDistance // necesario para que sea progresivo (tanto wormy como no wormy)
                if eyStyle.wormStyle == .notWormyLine {
                    let tabsDistance: CGFloat = currentTab.frame.origin.x - prevTab.frame.origin.x
                    let traveledDistance: CGFloat = currentTab.frame.origin.x - prevWormX
                    let progess: CGFloat = traveledDistance / tabsDistance
                    let delta: CGFloat = progess * sizeDiff
                    //print(delta)
                    let intermediateWidth: CGFloat = currentTab.frame.size.width + delta
                    worm.frame.origin.x -= delta
                    worm.frame.size.width = intermediateWidth
                }
            }
        }
        //print(worm.frame)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentX = scrollView.contentOffset.x
        currentTabIndex = Int(currentX/self.frame.width)
        //print("scrollViewDidEndDecelerating: ", currentTabIndex);
        let tab = tabs[currentTabIndex]
        setTabStyle()
        
        adjustTopScrollViewsContentOffsetX(tab: tab)
        UIView.animate(withDuration: 0.23) {
            self.slideWormToTabPosition(tab: tab)
            self.resetHeightOfWorm()
            self.centerCurrentlySelectedWorm(tab: tab)
        }
    }
    
    /*************************************************
    //MARK:  UIScrollView Delegate end
     ******************************************/
   
    
    /*************************************************
     //MARK:  UIScrollView Delegate Calculations  start
     ******************************************/
    private  func getNextTotalWormingDistance(index:Int, adjustment:CGFloat)->CGFloat{
        let tab = tabs[index]
        let nextTotal:CGFloat = eyStyle.spacingBetweenTabs + tab.frame.width + adjustment
        return nextTotal
    }
    
    private func calculateNextMoveDistance(gap:CGFloat,nextTotal:CGFloat)->CGFloat{
        let nextMove:CGFloat = (gap*nextTotal)/self.frame.width
        
        return nextMove
        
    }
    
    private func setWidthAndHeightOfWormForDistance(distance:CGFloat){
        if distance < 1 {
            resetHeightOfWorm()
        }else{
            let height:CGFloat = self.calculatePrespectiveHeightOfIndicatorLine(distance: distance)
            worm.frame.size.height = height
            worm.frame.size.width = eyStyle.wormStyle == .notWormyLine ? currentWormWidth : currentWormWidth + distance
        }
        if eyStyle.wormStyle == .bubble {
            worm.frame.origin.y = (eyStyle.kHeightOfTopScrollView-worm.frame.size.height)/2
        }else{
            worm.frame.origin.y = eyStyle.kHeightOfTopScrollView - eyStyle.kHeightOfWorm
        }
        
        worm.layer.cornerRadius = worm.frame.size.height/2
    }
    
    private func resetHeightOfWorm(){
        // if the style is line it should be placed under the tab
        if eyStyle.wormStyle == .bubble {
            worm.frame.origin.y = (eyStyle.kHeightOfTopScrollView - eyStyle.kHeightOfWormForBubble)/2
            worm.frame.size.height = eyStyle.kHeightOfWormForBubble
            
        }else{
            worm.frame.origin.y = eyStyle.kHeightOfTopScrollView - eyStyle.kHeightOfWorm
            worm.frame.size.height = eyStyle.kHeightOfWorm
        }
        worm.layer.cornerRadius = worm.frame.size.height/2
    }
    
    private  func calculatePrespectiveHeightOfIndicatorLine(distance:CGFloat)->CGFloat{
        
        var height:CGFloat = 0
        var originalHeight:CGFloat = 0
        if eyStyle.wormStyle == .bubble {
            height =  eyStyle.kHeightOfWormForBubble*(self.currentWormWidth/(distance+currentWormWidth))
            originalHeight = eyStyle.kHeightOfWormForBubble
        }else{
            height =  eyStyle.kHeightOfWorm*(self.currentWormWidth/(distance+currentWormWidth))
            originalHeight = eyStyle.kHeightOfWorm
        }
        
        //if the height of worm becoming too small just make it half of it
        if height < (originalHeight*eyStyle.kMinimumWormHeightRatio) {
           height = originalHeight*eyStyle.kMinimumWormHeightRatio
        }
        
//        return worm.frame.height
        return height
    }

    private func setTabStyle(){
        makePrevTabDefaultStyle()
        makeCurrentTabSelectedStyle()
    }
    
    private func makePrevTabDefaultStyle(){
        let tab = tabs[prevTabIndex]
        tab.textColor = eyStyle.tabItemDefaultColor
        tab.font = eyStyle.tabItemDefaultFont
    }
    
    private func makeCurrentTabSelectedStyle(){
        let tab = tabs[currentTabIndex]
        tab.textColor = eyStyle.tabItemSelectedColor
        tab.font = eyStyle.tabItemSelectedFont
    }

    private func syncAppearanceOfVC(tabIndex: Int){
        //print("syncAppearanceOfVC")
        let view = delegate!.wtsViewOfTab(index: tabIndex)
        var responder: UIResponder? = view
                         while !(responder is UIViewController) {
                             responder = responder?.next
                             if nil == responder {
                                 break
                             }
                         }
        if tabIndex == currentTabIndex {
            //view will move to parent
            let vc = (responder as? UIViewController)!
            guard let parent = delegate as? UIViewController else {
                return
            }
            parent.addChild(vc)
            vc.beginAppearanceTransition(true, animated: false)
            vc.didMove(toParent: parent)
            vc.endAppearanceTransition()
        } else {
            //remove view from parent
            let vc = (responder as? UIViewController)!
            guard delegate is UIViewController else {
                return
            }
            vc.beginAppearanceTransition(false, animated: false)
            vc.willMove(toParent: nil)
            vc.removeFromParent()
            vc.endAppearanceTransition()
        }
    }
    /*************************************************
     //MARK:  Worm Calculations Ends
     ******************************************/
}


extension UIColor {
    convenience init(r: Int, g: Int, b: Int) {
        assert(r >= 0 && r <= 255, "Invalid red component")
        assert(g >= 0 && g <= 255, "Invalid green component")
        assert(b >= 0 && b <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex: Int) {
        self.init(r: (netHex >> 16) & 0xff, g: (netHex >> 8) & 0xff, b: netHex & 0xff)
    }
}

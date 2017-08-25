//
//  SWPagerViewController.swift
//  OleApp
//
//  Created by jp007 on 2017/8/18.
//  Copyright © 2017年 crv. All rights reserved.
//

import UIKit

public protocol SWPagerViewHeaderDelegate: NSObjectProtocol {
     func pagerViewController(_ pager: SWPagerViewController,willTransitionTo vc:UIViewController)
    
     func pagerViewTabHeader() -> UIView?
    
     func pagerViewTabDidSelectd(index: Int)

}

class SWPagerItem: NSObject {
    var title: String?
    var content: UIViewController
    init(_ content: UIViewController = UIViewController(),title: String? = nil) {
        self.title = title
        self.content = content
    }
}

public class SWPagerConfig: NSObject {
    
    var items: [SWPagerItem] = [SWPagerItem.init(UIViewController(), title: "Item")]
    
    var tabHeight: CGFloat = 40
    var intialIndex: Int = 0
    
    var titleFont = UIFont.systemFont(ofSize: 13)
    var titleColor = UIColor.black
    var selectTitleColor = UIColor.blue
    var indicatorColor = UIColor.blue
    
    var tabBackgroundColor = UIColor.lightGray
    
    weak var tabViewDelegate: SWPagerViewHeaderDelegate?
    

}





public class SWPagerViewController: UIViewController {
  


    fileprivate var tabView: UIView?
    
    fileprivate var _selectedIndex: Int = 0
    
    
    lazy var _pager: UIPageViewController = {
        var pager = UIPageViewController.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        
        return pager
    }()
    fileprivate var isInitial = false
   
 public   var config: SWPagerConfig = SWPagerConfig() {
        didSet{
            self.reloadData()
        }
    }
    
  public  func reloadData()  {
        if isInitial == false {
            return
        }
         tabView?.removeFromSuperview()
        _pager.delegate = self
        _pager.dataSource = self
        
        var frame = self.view.frame
        frame.origin.y = config.tabHeight
        frame.size.height -= config.tabHeight
        
        _pager.view.frame = frame
    
        
        _pager.view.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        self.view.autoresizesSubviews = true
        
        self.view.addSubview(_pager.view)
        
 
        
        if  config.items.first == nil {
            config.items = [SWPagerItem.init(UIViewController(), title: "item")]
        }
        
        
        _pager.setViewControllers([config.items[0].content], direction: .forward, animated: true, completion: nil)
        
        if let view = config.tabViewDelegate?.pagerViewTabHeader() {
            view.frame = CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: self.view.frame.width, height: config.tabHeight))
            tabView = view
            self.view.addSubview(view)
        }
    }
    
    public  override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.white
        if self.responds(to: #selector(setter: UIViewController.edgesForExtendedLayout)) {
            self.edgesForExtendedLayout = []
        }
        
        
      
        if config.tabViewDelegate == nil {
            config.tabViewDelegate = self
        }
        
        
        isInitial = true
            
        
        
         self.reloadData()
        
        // Do any additional setup after loading the view.
    }

    @discardableResult
   public func setSelect(_ index: Int, animated: Bool) -> Bool {
        let count = config.items.count
        guard count > index , index != _selectedIndex else {
            return false
        }
        
        let direction: UIPageViewControllerNavigationDirection = index > _selectedIndex ? .forward : .reverse
        
        let vc = config.items[index].content

        _selectedIndex = index
        _pager.setViewControllers([vc], direction: direction, animated: animated, completion: nil)
        return true
    
    }
    

  public  override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    



}
 extension SWPagerViewController: SWPagerViewHeaderDelegate
{
  public  func pagerViewController(_ pager: SWPagerViewController, willTransitionTo vc: UIViewController) {
        //tab要滚动到xxx位置
        //let childs = self.tabView?.subviews
        let index = indexOf(vc: vc)
        self.tabClickAtIndex(index: index)
        
    }
    
  public  func pagerViewTabDidSelectd(index: Int) {
        self.setSelect(index, animated: true)
    }
    
  public  func pagerViewTabHeader() -> UIView? {
        
        return self.defaultTabHeader()
    }
    
  public  func defaultTabHeader() -> UIView? {
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.width, height:  config.tabHeight))
        view.backgroundColor = config.tabBackgroundColor
        
        let count = config.items.count
        guard count > 0 else {
            return nil
        }
        let w = self.view.frame.width/CGFloat(count)
        for (index,value) in config.items.enumerated() {
            
            let btn = UIButton.init(type: .custom)
            btn.frame = CGRect.init(x: CGFloat(index)*w, y: 0, width: w, height: config.tabHeight)
            view.addSubview(btn)
            btn.tag = index
            btn.setTitle(value.title ?? "item\(index)", for: .normal)
            
            btn.setTitleColor(config.titleColor, for: .normal)
            btn.setTitleColor(config.selectTitleColor, for: .selected)
            
            btn.addTarget(self, action: #selector(tabBtnClick(btn:)), for: .touchUpInside)
            if index == _selectedIndex {
                btn.isSelected = true
            }
        }
        
        
        let w1 = min(60, w)
        
        
        let indicator = UIView.init(frame: CGRect.init(x: (w - w1)/2, y: config.tabHeight - 5 , width: w1, height: 2))
        
        indicator.tag = 9999
        
        indicator.backgroundColor = config.indicatorColor
        view.addSubview(indicator)
        return view
    }

    func tabBtnClick(btn: UIButton) {
        
        if btn.tag == self._selectedIndex {
            return
        }
        
        self.tabClickAtIndex(index: btn.tag)
        
        self.pagerViewTabDidSelectd(index: btn.tag)
        
        
 
    }

    func tabClickAtIndex(index: Int){
    
        let view = self.tabView
        if let childs = view?.subviews {
            for child in childs {
                if child.isKind(of: UIButton.classForCoder()) {
                    (child as! UIButton).isSelected = index == child.tag
                    if index == child.tag , let indicator = view?.viewWithTag(9999) {
                     var center = indicator.center
                     center.x = child.center.x
                    UIView.animate(withDuration: 0.2, animations: { 
                            indicator.center = center
                    })
                    }
                }
                
            }
        }
        
        
    
    }

}

extension SWPagerViewController: UIPageViewControllerDelegate,UIPageViewControllerDataSource
{
    
    func nextOf(vc: UIViewController) -> UIViewController? {
        let index = indexOf(vc: vc)
        if index == NSNotFound {
            return nil
        }
        let count = config.items.count
        if index == count - 1 {//最后一个了
            return nil
        }
        return config.items[index + 1].content
    }
    func previourOf(vc: UIViewController) -> UIViewController? {
        let index = indexOf(vc: vc)
        if index == NSNotFound {
            return nil
        }
        
        if index == 0 {
            return nil
        }
        return config.items[index - 1].content
        
        
    }
    
    func indexOf(vc: UIViewController) -> Int  {
        for (index,value) in config.items.enumerated() {
            if value.content == vc {
                return index
            }
        }
        return NSNotFound
    }
    
  public  func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
     
        return previourOf(vc: viewController)
    }
 public   func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
       
        
        return nextOf(vc: viewController)
    }
    
  public  func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        if let will = pendingViewControllers.first {
            let index =  indexOf(vc: will)

            config.tabViewDelegate?.pagerViewController(self, willTransitionTo: will)

            _selectedIndex = index

        }
    }
    
    
}

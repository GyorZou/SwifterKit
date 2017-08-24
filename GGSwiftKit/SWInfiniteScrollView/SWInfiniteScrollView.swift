//
//  InfiniteScrollView.swift
//  SWKit
//
//  Created by zougyor on 2017/8/20.
//  Copyright © 2017年 crv.jp007. All rights reserved.
//

import UIKit

protocol SWInfiniteScrollViewDelegate: NSObjectProtocol {
    func infiniteView(_ scrollView: SWInfiniteScrollView,viewAfter view: UIView) -> UIView?

    func infiniteView(_ scrollView: SWInfiniteScrollView,viewBefore view: UIView) -> UIView?
    
    func infiniteView(_ scrollView: SWInfiniteScrollView,didScrollTo view: UIView)
}

public class SWInfiniteScrollView: UIView {
    
    fileprivate var dequeueViews: [UIView] = []
    
    fileprivate(set) var pageCount: Int = 3
    fileprivate var scrollView = UIScrollView()
    var tapAble = true
    var visibleViews : [UIView] = []
    fileprivate var isDity: Bool = true
    var visibleView: UIView?
    
    fileprivate let tap = UITapGestureRecognizer()
    
    override public var frame: CGRect{
        didSet{
            scrollView.frame = self.bounds
            
            self.reloadData()
        }
    }
   
    
    weak var infiniteDelegate: SWInfiniteScrollViewDelegate?
    
    func dequeueReusableView() -> UIView? {
        if let first = dequeueViews.first {
            dequeueViews.removeFirst()
            return first
        }
        return nil
    }
 public   func reloadData(){
        guard let view = visibleView else {
            return
        }
        scrollView.delegate = self
        self.addSubview(scrollView)
        for child in visibleViews {
            child.removeFromSuperview()
        }
        
        scrollView.removeGestureRecognizer(tap)
        
        tap.addTarget(self, action: #selector(doTap))
        scrollView.addGestureRecognizer(tap)
        
        visibleViews.removeAll()
        
        self.scrollView.isPagingEnabled = true
        self.scrollView.showsHorizontalScrollIndicator = false
        
        
        let size = self.frame.size
        view.frame = CGRect.init(origin: CGPoint.init(x: 0, y: 0), size: size)
        scrollView.addSubview(view)
        
        visibleViews.append(view)
        
        
        self.placeView(before: view)
        
        self.placeView(after: view)
        
        self.positonVisibleViews(center: view)
        
        
        self.scrollView.contentSize = CGSize.init(width: CGFloat(visibleViews.count) * self.frame.width, height: self.frame.height)
        
        
       self.scrollView.setContentOffset(CGPoint.init(x: view.frame.origin.x, y: 0), animated: false)
    }
    
    func doTap() {
        if tapAble == false  || self.scrollView.isDecelerating {
            return
        }
        let point = tap.location(in: self)
        
        let left = point.x.truncatingRemainder(dividingBy: self.frame.width)
        //var point = self.contentOffset
        
        if left < self.frame.width/2 {
            self.displayPreviour(animated: true)
        }else{
            self.displayNext(animated: true)
        }
        
    }
    func displayNext(animated: Bool) {
        //判断还有没有下一页
        guard let center = self.centerView() else {
            return
        }
        if infiniteDelegate?.infiniteView(self, viewAfter: center) == nil {
            return
        }
        var offset = self.scrollView.contentOffset
        offset.x += self.frame.width
        self.scrollView.setContentOffset(offset, animated: animated)
        
    }
    func centerView() -> UIView? {
        let offset = self.scrollView.contentOffset

        for view in visibleViews {
            if view.frame.origin.x == offset.x {
                return view
            }
        }
        return nil
        
    }
    func displayPreviour(animated: Bool) {
        
        guard let center = self.centerView() else {
            return
        }
        if infiniteDelegate?.infiniteView(self, viewBefore: center) == nil {
            return
        }
        var offset = self.scrollView.contentOffset
        offset.x -= self.frame.width
        self.scrollView.setContentOffset(offset, animated: animated)
    }

    
    
    func setVisible(view: UIView,animated: Bool) {
        
        visibleView = view
      
        reloadData()
        
    }
    
    func positonVisibleViews(center: UIView) {
        
        var point = CGPoint.zero
        
        let size = self.frame.size
        let indexCenter = visibleViews.index(of: center)
        guard indexCenter != nil else {
            return
        }
        
        for (index,view) in visibleViews.enumerated() {
            
            point.x = CGFloat(index) * view.frame.width
            view.frame = CGRect.init(origin: point, size: size)
            
        }
        


    }
    @discardableResult
    func placeView(before view: UIView) -> Bool {
        let previour = infiniteDelegate?.infiniteView(self, viewBefore: view)
        guard let before = previour else {
            return false
        }
        
        var frame = view.frame
        frame.origin.x -= view.frame.width
        
        before.frame = frame
        visibleViews.insert(before, at: 0)
        
        scrollView.addSubview(before)
        return true
    }
    @discardableResult
    func placeView(after view: UIView) -> Bool {
        let next = infiniteDelegate?.infiniteView(self, viewAfter: view)
        guard let nextView = next else {
            return false
        }
        var frame = view.frame
        frame.origin.x += view.frame.width
        
        nextView.frame = frame
        
        visibleViews.append(nextView)
        scrollView.addSubview(nextView)
        return true

    }

    
    
    
    override public func layoutSubviews() {
        
        super.layoutSubviews()
        
        self.adjustPositionIfNeed()
        
        
        
    }
    
    func moveX(value: CGFloat) {
        var offset = self.scrollView.contentOffset
        
        for view in visibleViews {
            var frame = view.frame
            frame.origin.x += value
            view.frame = frame
        }
        offset.x += value
        //self.setContentOffset(offset, animated: false)
        self.scrollView.contentOffset = offset
    }
    
    func adjustPositionIfNeed() {
        let offset = self.scrollView.contentOffset
       // let size = self.contentSize
        let w = self.frame.width
        /*
         判断是否需要加载下一页
         */
        let last = visibleViews.last
        let first = visibleViews.first
        
        if offset.x >  1.5 * w {
            //判断最后一个视图的x 是否 3*w
            if let last = last {
                if last.frame.origin.x < 3*w {
                    if last != visibleView {
                        visibleView = last
                        infiniteDelegate?.infiniteView(self, didScrollTo: last)
                    }
                    if self.placeView(after: last) {
                        //加了一个就请删除一个
                        if let first = visibleViews.first {
                            first.removeFromSuperview()
                            visibleViews.removeFirst()
                            dequeueViews.append(first)
                        }
                        
                        //左侧滑动一个宽度
                        moveX(value: -w)
                        
                    }
                    
                }
            }
        }else if offset.x < 0.5 * w {
            
            if let first = first {
                if first != visibleView {
                    visibleView = first
                    infiniteDelegate?.infiniteView(self, didScrollTo: first)
                }
                if first.frame.origin.x >= 0 {
                    if self.placeView(before: first) {
                        if let last = visibleViews.last {
                            last.removeFromSuperview()
                            visibleViews.removeLast()
                            dequeueViews.append(last)
                        }
                        
                        moveX(value: w)
                        
                        
                    }
                }
            }
        }
    }
}

extension SWInfiniteScrollView: UIScrollViewDelegate
{
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.setNeedsLayout()
    }

}

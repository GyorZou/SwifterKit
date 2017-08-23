//
//  SWInfiniteImageView.swift
//  SWKit
//
//  Created by zougyor on 2017/8/20.
//  Copyright © 2017年 crv.jp007. All rights reserved.
//

import UIKit

class SWInfiniteImageView: SWInfiniteScrollView,SWInfiniteScrollViewDelegate {

    var interval: TimeInterval = 5
    
    
    private var timer: Timer?
    
    var tapAction: ((Int,[UIImage]) -> Void)? {
        didSet{
            
        }
    }
    override func doTap() {
        if let tap = tapAction {
            tap(0,images)
            return
        }
        self.doTap()
    }
    
    
    var indicator: UIPageControl = {
        let indicator = UIPageControl.init()
        indicator.currentPageIndicatorTintColor = UIColor.red
        indicator.pageIndicatorTintColor = UIColor.white
        //indicator.frame = CGRect.init(x: 100, y: 100, width: 100, height: 20)
        return indicator
    }()
    
    var images: [UIImage] = [] {
        didSet{
            if images.count == 0 {
                images.append(UIImage())
            }
            self.addSubview(indicator)
            self.indicator.numberOfPages = images.count
            
            self.infiniteDelegate = self
            let imageView =  UIImageView()
            imageView.contentMode = .scaleAspectFit
            let view =  imageView
            view.tag = 0
            view.image = images[0]
            self.setVisible(view: view, animated: false)
        }
    }
    override var frame: CGRect{
        didSet{
            indicator.width = self.width
            indicator.y = self.height - 30
            indicator.height = 20
            indicator.x = 0
        }
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        timer?.invalidate()
        timer = nil

        if newSuperview != nil {
            timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        }
    }
    func timerAction(){
        displayNext(animated: true)
    }
    
    
    func infiniteView(_ scrollView: SWInfiniteScrollView, didScrollTo view: UIView) {
        
        timer?.fireDate = Date.init(timeIntervalSinceNow:interval)
        indicator.currentPage = view.tag % images.count
    }
    
    func infiniteView(_ scrollView: SWInfiniteScrollView, viewAfter view: UIView) -> UIView? {
        let tag = view.tag + 1 + images.count
        let index = tag % images.count
        
        let imageView = (scrollView.dequeueReusableView() as? UIImageView) ?? UIImageView()
        imageView.image = images[index]
        imageView.tag = tag
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
    func infiniteView(_ scrollView: SWInfiniteScrollView, viewBefore view: UIView) -> UIView? {
        let tag = view.tag - 1 + images.count
        let index = tag % images.count
        
        let imageView = (scrollView.dequeueReusableView() as? UIImageView) ?? UIImageView()
        imageView.image = images[index]
        imageView.contentMode = .scaleAspectFit
        imageView.tag = tag
        return imageView
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.bringSubview(toFront: indicator)
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

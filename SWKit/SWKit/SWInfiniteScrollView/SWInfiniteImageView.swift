//
//  SWInfiniteImageView.swift
//  SWKit
//
//  Created by zougyor on 2017/8/20.
//  Copyright © 2017年 crv.jp007. All rights reserved.
//

import UIKit

class SWInfiniteImageView: SWInfiniteScrollView,SWInfiniteScrollViewDelegate {

    private var imageViews = [UIImageView(),UIImageView(),UIImageView()]
    
    var indicator: UIPageControl = {
        let indicator = UIPageControl.init()
        indicator.currentPageIndicatorTintColor = UIColor.red
        indicator.pageIndicatorTintColor = UIColor.white
        indicator.frame = CGRect.init(x: 100, y: 100, width: 100, height: 20)
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
            let view =  imageViews[0]
            view.tag = 0
            view.image = images[0]
            self.setVisible(view: view, animated: false)
        }
    }
    
    func infiniteView(_ scrollView: SWInfiniteScrollView, didScrollTo view: UIView) {
        
        
    }
    
    func infiniteView(_ scrollView: SWInfiniteScrollView, viewAfter view: UIView) -> UIView? {
        let tag = view.tag + 1 + images.count
        let index = tag % images.count
        
        let imageView = UIImageView()
        imageView.image = images[index]
        imageView.tag = tag
        return imageView
    }
    func infiniteView(_ scrollView: SWInfiniteScrollView, viewBefore view: UIView) -> UIView? {
        let tag = view.tag - 1 + images.count
        let index = tag % images.count
        
        let imageView = UIImageView()
        imageView.image = images[index]
        
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

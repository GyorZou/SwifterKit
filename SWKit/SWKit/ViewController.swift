//
//  ViewController.swift
//  SWKit
//
//  Created by jp007 on 2017/8/19.
//  Copyright © 2017年 crv.jp007. All rights reserved.
//

import UIKit

class ViewController: UIViewController ,SWInfiniteScrollViewDelegate{

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let infinite = SWInfiniteScrollView.init(frame: self.view.bounds)
        
        infinite.infiniteDelegate = self
        
        let label = UILabel.init()
        label.tag = 0
        label.text = "test\(label.tag)"
    
        infinite.setVisible(view: label, animated: true)
        
        self.view.addSubview(infinite)
        
        
        let imageViews = SWInfiniteImageView.init(frame: self.view.bounds)
        imageViews.images = [UIImage.init(named: "index_3.jpg")!,UIImage.init(named: "index_2.jpg")!]
        self.view.addSubview(imageViews)
        
        
    }
    func infiniteView(_ scrollView: SWInfiniteScrollView, didScrollTo view: UIView) {
        print("scrolling to: \(view)")
    }
    func infiniteView(_ scrollView: SWInfiniteScrollView, viewAfter view: UIView) -> UIView? {
        let label = UILabel.init()
        label.tag = view.tag + 1
        label.text = "test\(label.tag)"
        if view.tag == 10 {
            return nil
        }

        return label
    }
    
    func infiniteView(_ scrollView: SWInfiniteScrollView, viewBefore view: UIView) -> UIView? {
         let label = UILabel.init()
        label.tag = view.tag - 1
        label.text = "test\(label.tag)"
        if view.tag == -10 {
            return nil
        }
        return label
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func doTset() {
    
        let pager = SWPagerViewController()
        
        pager.config.items = [SWPagerItem.init(TestViewController(), title: "item1"),SWPagerItem.init(TestViewController(), title: "item2")]
        
        self.navigationController?.pushViewController(pager, animated: true)
    
    }

}


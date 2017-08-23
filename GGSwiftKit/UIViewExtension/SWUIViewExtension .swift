//
//  UIView+Extension.swift
//  SWKit
//
//  Created by jp007 on 2017/8/21.
//  Copyright © 2017年 crv.jp007. All rights reserved.
//

import UIKit

extension UIView {
    var x: CGFloat {
    
        get{
            return self.frame.origin.x
        }
        
        set(value){
            var frame = self.frame
            frame.origin.x = value
            self.frame = frame
        }

    }
    
    var y: CGFloat {
        
        get{
            return self.frame.origin.y
        }
        
        set(value){
            var frame = self.frame
            frame.origin.y = value
            self.frame = frame
        }
        
    }
    
    var width: CGFloat {
        
        get{
            return self.frame.size.width
        }
        
        set(value){
            var frame = self.frame
            frame.size.width = value
            self.frame = frame
        }
        
    }
    
    var height: CGFloat {
        
        get{
            return self.frame.size.height
        }
        
        set(value){
            var frame = self.frame
            frame.size.height = value
            self.frame = frame
        }
        
    }

}


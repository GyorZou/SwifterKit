//
//  SWScrollRefresher.swift
//  SWKit
//
//  Created by zougyor on 2017/8/21.
//  Copyright © 2017年 crv.jp007. All rights reserved.
//

import UIKit

enum SWRefresherState {
    case Idle
    case Draging(offsetX:Float)
    case Freshing
    case NoMore
    
    func rawValue() -> Int {
        switch self {
        case .Idle:
            return 0
        case .Draging(offsetX: _):
            return 1
        case .Freshing:
            return 2
        case .NoMore:
            return 3
        }
    }
}

extension SWRefresherState: Equatable{
    public static func ==(lhs: SWRefresherState, rhs: SWRefresherState) -> Bool{
        
        return lhs.rawValue() == rhs.rawValue()
    }
    
}


public class SWRefresherBaseView: UIView {
    
    fileprivate(set) var state = SWRefresherState.Idle
    var contentHeight: CGFloat = 60
    weak fileprivate var scrollView: UIScrollView?
    var originContentInset = UIEdgeInsets.zero

  public  override func willMove(toSuperview newSuperview: UIView?) {
        self.removeObeser()
        
        guard  let view = newSuperview as? UIScrollView else {
            scrollView = nil
            return
        }
        scrollView = view
        self.addObserver()
        
    }
    
    func removeObeser() {
        
    }
    func addObserver() {
        scrollView?.addObserver(self, forKeyPath: "contentOffset", options: [.new,.old], context: nil)
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentOffset" {
            let dict = change?[.newKey] as? NSValue
            
            if let d = dict {
                self.offsetChanged(d)
            }
            
        }
    }
    func offsetChanged(_ dict: NSValue) {
    
        
    }
    func setState(_ stateT: SWRefresherState) {
    }

   public  func endRefresh()  {
        switch state {
            case .Freshing:
                setState(.Idle)
            default:
                break
        }
    }
}


public class SWRefresherBaseHeader: SWRefresherBaseView {
    
   public  typealias ActionBlock = (UIScrollView) -> Void
    private var _titleLabel: UILabel?
    private var actionBlock: ActionBlock?
    
    private(set) var titleLabel: UILabel {
        get{
            if _titleLabel == nil {
                _titleLabel = UILabel.init(frame: CGRect(x: 0, y: 5, width: 100, height: 30));
                self.addSubview(_titleLabel!)
                
                _titleLabel!.center = CGPoint.init(x: self.frame.size.width/2, y: self.frame.size.height/2)
                _titleLabel!.text = "this is head"
                
                
            }
            return _titleLabel!
        }
        set{
            _titleLabel = newValue
        }
    }

   public  init(action: ActionBlock? = nil) {
        super.init(frame: CGRect.zero)
        self.actionBlock = action
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func offsetChanged(_ dict: NSValue) {
        
        let p = dict.cgPointValue
        let stateV = state
        let scroll = scrollView!
        if scroll.isDragging {
            
            switch stateV {
            case .Idle:
                self.originContentInset = scroll.contentInset
                setState(.Draging(offsetX: Float(p.y)))
                
            case .Draging(offsetX: _):
                setState(.Draging(offsetX: Float(p.y)))
                
            default:
                break
            }
            
        }else{
            
            switch stateV {
            case .Draging(offsetX: let x):
                if x < Float( -(self.originContentInset.top + contentHeight)) {
                    setState(.Freshing)
                }else{
                    setState(.Idle)
                }
                break
                
            default: break
                
            }
            
            
        }
        
        
    }
    override  func setState(_ state: SWRefresherState) {
        switch state {
        case .Idle:
            self.titleLabel.text = "下拉刷新"

            UIView.animate(withDuration: 0.2, animations: {
                self.scrollView?.contentInset = self.originContentInset
            })
        case .Freshing:
            self.titleLabel.text = "正在刷新"
            var ins = self.originContentInset
            ins.top += contentHeight
            
            if let action = actionBlock {
                action(scrollView!)
            }
            UIView.animate(withDuration: 0.2, animations: {
                self.scrollView?.contentInset = ins
                self.scrollView?.setContentOffset(CGPoint.init(x: 0, y: -ins.top), animated: true)
            })
        case .Draging(offsetX: let value):
            if  value > Float(-(self.originContentInset.top + contentHeight)) {
                self.titleLabel.text = "下拉刷新"
                
            }else{
                self.titleLabel.text = "松开刷新"
                
            }

            break;

        default:
            break
        }
        
        self.state = state

    }


}


extension UIScrollView {
  public  var sw_header: SWRefresherBaseHeader?{
        set{
            self.findHeader()?.removeFromSuperview()
            
            if let view = newValue {
                
                let frame = self.frame
                view.frame = CGRect.init(x: 0, y: -view.contentHeight, width: frame.size.width, height: view.contentHeight)
                self.addSubview(view)
            }

        }
        get{
              return self.findHeader()
        }

    }
    
    func findHeader() -> SWRefresherBaseHeader? {
        let subs = self.subviews
        for item in subs {
            if let item = item as? SWRefresherBaseHeader {
                return  item
            }
        }
        return nil
    }

    
}

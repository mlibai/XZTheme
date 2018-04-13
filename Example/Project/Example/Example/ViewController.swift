//
//  ViewController.swift
//  Example
//
//  Created by mlibai on 2018/4/13.
//  Copyright © 2018年 mlibai. All rights reserved.
//

import UIKit

@IBDesignable open class OMLabel: UILabel {
    
    @IBInspectable open var contentInsets: UIEdgeInsets = UIEdgeInsets.init(top: 10, left: 10, bottom: 10, right: 10)
    
    override open func drawText(in rect: CGRect) {
        let textRect = UIEdgeInsetsInsetRect(rect, contentInsets)
        super.drawText(in: textRect)
    }
    
    override open var intrinsicContentSize: CGSize {
        let size1 = super.intrinsicContentSize
        return CGSize.init(
            width: size1.width + contentInsets.left + contentInsets.right,
            height: size1.height + contentInsets.top + contentInsets.bottom
        )
    }
    
    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        let size1 = super.sizeThatFits(size)
        return CGSize.init(
            width: size1.width + contentInsets.left + contentInsets.right,
            height: size1.height + contentInsets.top + contentInsets.bottom
        )
    }
    
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let label = OMLabel.init(frame: CGRect.init(x: 100, y: 100, width: 100, height: 100))
        label.text = "This is a label."
        label.backgroundColor = UIColor.lightGray
        view.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false;
        let lc1 = NSLayoutConstraint(item: label, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0)
        let lc2 = NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1.0, constant: 0)
        view.addConstraint(lc1)
        view.addConstraint(lc2)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


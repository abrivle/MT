//
//  CardView.swift
//  MT
//
//  Created by ILYA Abramovich on 24.12.2017.
//  Copyright © 2017 ILYA Abramovich. All rights reserved.
//

import UIKit


class CardView: UIView {

    var cornerRadius: CGFloat = 5
    
    var shadowOffsetWidth: Int = 0
    var shadowOffsetHeight: Int = 2
    var shadowColor: UIColor? = UIColor.black
    var shadowOpacity: Float = 0.2
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = cornerRadius
        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        self.clipsToBounds = true
        
        layer.masksToBounds = false
        layer.shadowColor = shadowColor?.cgColor
        layer.shadowOffset = CGSize(width: shadowOffsetWidth, height: shadowOffsetHeight);
        layer.shadowOpacity = shadowOpacity
        layer.shadowPath = shadowPath.cgPath
    }

}

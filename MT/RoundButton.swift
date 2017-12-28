//
//  RoundButton.swift
//  MT
//
//  Created by ILYA Abramovich on 23.12.2017.
//  Copyright © 2017 ILYA Abramovich. All rights reserved.
//

import UIKit


class RoundButton: UIButton {
    
    var buttonCustomType = 0
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        tintColor = Constants.buttonColor
        if buttonCustomType == 0 {
            setBackgroundImage(#imageLiteral(resourceName: "Button"), for: .normal)
        } else {
            layer.cornerRadius = frame.size.width / 2
            layer.backgroundColor = Constants.buttonColor.cgColor
        }
        setImage(#imageLiteral(resourceName: "Right"), for: .normal)
    }
    
}

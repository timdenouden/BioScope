//
//  BottomBarToolSelectView.swift
//  BioScope
//
//  Created by Timothy DenOuden on 11/10/17.
//  Copyright © 2017 Timothy DenOuden. All rights reserved.
//

import UIKit

class BottomBarToolSelectView: UIView {
    var topConstraint: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        for constraint in constraints where (constraint.identifier == "topBottomBar") {
            topConstraint = constraint
            break
        }
    }
    
    public func add(toolView: UIView, icon: UIImage) {
        //add an openable view to the layout
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

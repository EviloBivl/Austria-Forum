//
//  LoadingScreen.swift
//  Austria-Forum
//
//  Created by Paul Neuhold on 07.01.16.
//  Copyright © 2016 Paul Neuhold. All rights reserved.
//

import UIKit

class LoadingScreen: UIView {

    
    @IBOutlet weak var labelMessage: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var viewLoadingHolder: UIView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        print("init with frame")
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        print("init with coder")
        self.backgroundColor = UIColor(white: 1, alpha: 0.0)
        
    }
    
    
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    deinit {
        print("DEINIT Loading")
        self.activityIndicator.stopAnimating()
        
        
    }
}

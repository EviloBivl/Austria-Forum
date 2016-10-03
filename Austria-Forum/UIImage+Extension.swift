//
//  UIImage+Extension.swift
//  Austria-Forum
//
//  Created by Paul Neuhold on 14.02.16.
//  Copyright © 2016 Paul Neuhold. All rights reserved.
//

import UIKit


extension UIImage {
    
    class func renderedImageInGraphicContext(_ name: String, size: CGSize) -> UIImage?
    {
        
        let image = UIImage(named: name)
        let imageViewForRendering = UIImageView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        var renderedImage : UIImage?
        
        if let unwrapped_image = image
        {
            imageViewForRendering.image = unwrapped_image
            
            UIGraphicsBeginImageContextWithOptions(size, false, 0)
            if let currentGraphicContext = UIGraphicsGetCurrentContext()
            {
                imageViewForRendering.layer.render(in: currentGraphicContext)
                renderedImage = UIGraphicsGetImageFromCurrentImageContext()
            }
            UIGraphicsEndImageContext()
        }
        return renderedImage
    }
    
}

//
//  ToolBar.swift
//  Austria-Forum
//
//  Created by Paul Neuhold on 14.02.16.
//  Copyright © 2016 Paul Neuhold. All rights reserved.
//

import UIKit

class ToolBar: UIToolbar {
    
    
    //toptoolbar tags
    fileprivate let settings = 10
    fileprivate let random = 11
    fileprivate let monthly = 12
    fileprivate let location = 13
    fileprivate let search = 14
    fileprivate let home = 15
    
    
    //bottom toolbartags
    fileprivate let back = 20
    fileprivate let forward = 21
    fileprivate let like = 22
    fileprivate let favourites = 23
    fileprivate let share = 24
    
    fileprivate(set) var likedImage : UIImage?
    fileprivate(set) var notLikedImage : UIImage?
    
    var size : CGSize = CGSize(width: 25, height: 25)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setUpIcons()
    }
    
    func redrawIconsWithSize(_ size: CGSize){
        self.size = size
        self.setUpIcons()
    }
    
    fileprivate func setUpIcons(){
        
        likedImage =  UIImage.renderedImageInGraphicContext("Hearts_Filled.png", size: size)
        notLikedImage =  UIImage.renderedImageInGraphicContext("Hearts.png", size: size)
        
        if let items = self.items {
            
            for aToolBarItem in items {
                
                switch aToolBarItem.tag {
                case settings:
                    aToolBarItem.image = UIImage.renderedImageInGraphicContext("Settings_3.png", size: size)
                    break
                case random:
                    aToolBarItem.image = UIImage.renderedImageInGraphicContext("Shuffle.png", size: size)
                    break
                case monthly:
                    aToolBarItem.image = UIImage.renderedImageInGraphicContext("Calendar.png", size: size)
                    break
                case location:
                    aToolBarItem.image = UIImage.renderedImageInGraphicContext("Marker.png", size: size)
                    break
                case search:
                    aToolBarItem.image = UIImage.renderedImageInGraphicContext("Search100.png", size: size)
                    break
                case back:
                    let smallerSize = CGSize(width: size.width-5, height: size.height-5)
                    aToolBarItem.image = UIImage.renderedImageInGraphicContext("back.png", size: smallerSize)
                    break
                case forward:
                    let smallerSize = CGSize(width: size.width-5, height: size.height-5)
                    aToolBarItem.image = UIImage.renderedImageInGraphicContext("forward.png", size: smallerSize)
                    break
                case like:
                    aToolBarItem.image = UIImage.renderedImageInGraphicContext("Hearts.png", size: size)
                    break
                case favourites:
                    aToolBarItem.image = UIImage.renderedImageInGraphicContext("Bookmark.png", size: size)
                    break
                case share:
                    aToolBarItem.image = UIImage.renderedImageInGraphicContext("Upload.png", size: size)
                    break
                case home:
                    aToolBarItem.image = UIImage.renderedImageInGraphicContext("home.png", size: size)
                    break
                default:
                    break
                }
            }
        }
    }
}



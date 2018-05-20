//
//  ToolBar.swift
//  Austria-Forum
//
//  Created by Paul Neuhold on 14.02.16.
//  Copyright © 2016 Paul Neuhold. All rights reserved.
//

import UIKit

protocol ToolbarDelegate: class {
    func didPressToolbarButton(with itemType: ToolBar.ToolbarItemType)
}

class ToolBar: UIToolbar {
    
    public enum ToolbarItemType : Int {
        //toptoolbar tags
        case settings = 10
        case random = 11
        case monthly = 12
        case location = 13
        case search = 14
        case home = 15
        
        //bottom toolbartags
        case back = 20
        case forward = 21
        case like = 22
        case favourites = 23
        case share = 24
        
        var viewController: UIViewController? {
            switch self {
            case .settings:
                return SettingsViewController.create(viewModel: SettingsViewModel())
            case .location:
                return NearbyArticlesViewController.create(viewModel: NearbyArticlesViewModel())
            case .search:
                return SearchTableViewController.create(viewModel: SearchViewModel())
            case .favourites:
                return FavouritesTableViewController.create(viewModel: FavouritesViewModel())
            default:
                return nil
            }
        }
        
    }
    
    weak var customDelegate: ToolbarDelegate?
   
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
    
    @objc func didPressToolbarButton(sender: UIBarButtonItem){
        guard let itemType = ToolbarItemType.init(rawValue: sender.tag) else { return }
        customDelegate?.didPressToolbarButton(with: itemType)
    }
    
    
    
    fileprivate func setUpIcons(){
        
        likedImage =  UIImage.renderedImageInGraphicContext("Hearts_Filled.png", size: size)
        notLikedImage =  UIImage.renderedImageInGraphicContext("Hearts.png", size: size)
        
        if let items = self.items {
            for item in items {
                if let itemTag = ToolbarItemType.init(rawValue: item.tag) {
                item.action = #selector(didPressToolbarButton(sender:))
                switch itemTag {
                case .settings:
                    item.image = UIImage.renderedImageInGraphicContext("Settings_3.png", size: size)
                    break
                case .random:
                    item.image = UIImage.renderedImageInGraphicContext("Shuffle.png", size: size)
                    break
                case .monthly:
                    item.image = UIImage.renderedImageInGraphicContext("Calendar.png", size: size)
                    break
                case .location:
                    item.image = UIImage.renderedImageInGraphicContext("Marker.png", size: size)
                    break
                case .search:
                    item.image = UIImage.renderedImageInGraphicContext("Search100.png", size: size)
                    break
                case .back:
                    let smallerSize = CGSize(width: size.width-5, height: size.height-5)
                    item.image = UIImage.renderedImageInGraphicContext("back.png", size: smallerSize)
                    break
                case .forward:
                    let smallerSize = CGSize(width: size.width-5, height: size.height-5)
                    item.image = UIImage.renderedImageInGraphicContext("forward.png", size: smallerSize)
                    break
                case .like:
                    item.image = UIImage.renderedImageInGraphicContext("Hearts.png", size: size)
                    break
                case .favourites:
                    item.image = UIImage.renderedImageInGraphicContext("Bookmark.png", size: size)
                    break
                case .share:
                    item.image = UIImage.renderedImageInGraphicContext("Upload.png", size: size)
                    break
                case .home:
                    item.image = UIImage.renderedImageInGraphicContext("home.png", size: size)
                    break
                }
            }
            }
        }
    }
}



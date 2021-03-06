//
//  SearchHolder.swift
//  Austria-Forum
//
//  Created by Paul Neuhold on 11.12.15.
//  Copyright © 2015 Paul Neuhold. All rights reserved.
//

import Foundation

class SearchHolder {
    
    static let sharedInstance = SearchHolder()
    
    var searchResults : [SearchResult] = []
    var selectedItem : SearchResult? {
        didSet{
            if let _ = self.selectedItem?.licenseResult {
                //ok do nothing
            } else {
                //default to af license
                self.selectedItem?.licenseResult = License(css: "af", title: "af", url:  UserData.AF_URL + "/af/Lizenzen/AF", id: "AF")
            }
        }
    }
    var currentTitle : String? 
    var currentUrl: String? 
    var resultMessage: String = "Leider liegt ein Fehler vor. Es wird daran gearbeitet."
    var currentCategory : String?
    var dummyObjectHolder : AnyObject?
    
    
    var fetchedPageInfosFromGetPageInfo : SearchResult?
    
    fileprivate init(){}
    
}

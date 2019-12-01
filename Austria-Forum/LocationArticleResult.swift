//
//  LocationArticle.swift
//  Austria-Forum
//
//  Created by Paul Neuhold on 21.01.16.
//  Copyright © 2016 Paul Neuhold. All rights reserved.
//

import Foundation

class LocationArticleResult {
    
    fileprivate(set) var title : String = ""
    fileprivate(set) var name : String = ""
    fileprivate(set) var url: String = ""
    fileprivate(set) var distanceString : String = ""
    fileprivate(set) var distanceValue : Int = 0
    fileprivate(set) var licenseResult: License?
    
    
    fileprivate init(){
        
    }
    
    convenience init(title: String, name: String, url: String, distanceStr: String, distanceVal : Int, licenseResult: License?) {
        self.init()
        self.title = title
        self.name = name
        self.url = url
        self.distanceValue = distanceVal
        self.distanceString = distanceStr
        self.licenseResult = licenseResult
    }

}

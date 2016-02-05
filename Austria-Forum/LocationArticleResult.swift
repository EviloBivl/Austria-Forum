//
//  LocationArticle.swift
//  Austria-Forum
//
//  Created by Paul Neuhold on 21.01.16.
//  Copyright © 2016 Paul Neuhold. All rights reserved.
//

import Foundation

class LocationArticleResult {
    
    private(set) var title : String = ""
    private(set) var name : String = ""
    private(set) var url: String = ""
    private(set) var distanceString : String = ""
    private(set) var distanceValue : Int = 0
    
    private init(){
        
    }
    
    convenience init(title: String, name: String, url: String, distanceStr: String, distanceVal : Int) {
        self.init()
        self.title = title
        self.name = name
        self.url = url
        self.distanceValue = distanceVal
        self.distanceString = distanceStr
    }

}
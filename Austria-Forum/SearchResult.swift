//
//  SearchResults.swift
//  Austria-Forum
//
//  Created by Paul Neuhold on 11.12.15.
//  Copyright © 2015 Paul Neuhold. All rights reserved.
//

import Foundation

class SearchResult {
    
    private(set) var title : String = ""
    private(set) var name : String = ""
    private(set) var url: String = ""
    private(set) var score : Int = 0;
    private(set) var license : String?
    
    private init(){
        
    }
    
    convenience init(title: String, name: String, url: String, score: Int, license: String?) {
        self.init()
        self.title = title
        self.name = name
        self.url = url
        self.score = score
        self.license = license
    }
    
}

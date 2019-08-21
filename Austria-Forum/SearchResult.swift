//
//  SearchResults.swift
//  Austria-Forum
//
//  Created by Paul Neuhold on 11.12.15.
//  Copyright © 2015 Paul Neuhold. All rights reserved.
//

import Foundation

public struct SearchResult {
    
    fileprivate(set) var title : String?
    fileprivate(set) var name : String?
    fileprivate(set) var url: String?
    fileprivate(set) var score : Int = 0;
    var licenseResult : LicenseResult?
    
    fileprivate init(){
        
    }
    
    init(title: String?, name: String?, url: String?, score: Int, licenseResult: LicenseResult?) {
        self.init()
        self.title = title
        self.name = name
        self.url = url
        self.score = score
        self.licenseResult = licenseResult
    }
}

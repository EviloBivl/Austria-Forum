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
    var selectedItem : SearchResult?
    var currentTitle : String? 
    var lastUrl: String?
    
    
    private init(){}
    
}
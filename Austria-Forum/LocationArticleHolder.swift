//
//  LocationArticleResults.swift
//  Austria-Forum
//
//  Created by Paul Neuhold on 21.01.16.
//  Copyright © 2016 Paul Neuhold. All rights reserved.
//

import Foundation

class LocationArticleHolder {
    
    static let sharedInstance = LocationArticleHolder()
    var articles : Array<LocationArticleResult> = []
    
    
    private init(){}
    
}
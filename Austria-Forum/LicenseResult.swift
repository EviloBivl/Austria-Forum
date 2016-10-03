//
//  LicenseResult.swift
//  Austria-Forum
//
//  Created by Paul Neuhold on 19.07.16.
//  Copyright © 2016 Paul Neuhold. All rights reserved.
//

import Foundation

struct LicenseResult {
    
    
    let css : String?
    let title: String?
    let url: String?
    let id: String?
    
    
    init(withCss: String?, withTitle: String? , withUrl: String?, withId: String?){
        css = withCss
        title = withTitle
        url = withUrl
        id = withId
    }
    
    
    
    
}

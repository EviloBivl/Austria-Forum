//
//  GetPageInfoFromUrls.swift
//  Austria-Forum
//
//  Created by Paul Neuhold on 05.02.16.
//  Copyright © 2016 Paul Neuhold. All rights reserved.
//

import Foundation
import SwiftyJSON

class GetPageInfoFromUrls : BaseRequest{
    
    let method : String = "search.getPageInfo"
    var urls : [String]?
    
    
    override init(){
        super.init()
    }
    
    
    convenience init(urls: [String]?) {
        self.init()
        self.urls = urls
        self.customInitAfterSuperInit()
        self.addAdditionalRequestInfo()
    }
    
    override func addAdditionalRequestInfo() {
        self.requestBody["method"] = self.method
        let paramsArray : Array<String> = self.urls!
        self.requestBody["params"] = paramsArray
    }
    
    override func parseResponse(response: JSON) {
        print("parse in \(self.debugDescription)")
        
        
        
    }

}
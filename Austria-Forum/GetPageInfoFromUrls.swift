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
        self.requestBody["params"] = [paramsArray]
    }
    
    override func parseResponse(response: JSON) {
        print("Request : \(self.description)\nResponseData: \(response.description)")
        
        
        //do somthing usefull with the result
        if let articles = response["result"]["list"].arrayObject {
            for object in articles {
                if let page = object["map"] {
                    if page!["ResultCode"] as! String == "0"{
                        let name = page!["name"] as! String
                        let title = page!["title"] as! String
                        let url = page!["url"] as! String
                        let license = page!["license"] as! String?
                        let searchResult = SearchResult(title: title, name: name, url: url, score: 100, license: license)
                        SearchHolder.sharedInstance.selectedItem = searchResult
                    } else {
                        super.handleResponseError(self.description, article: [:])
                    }
                }
                
            }
        } else {
            super.handleResponseError(self.description, article: [:])
            
        }
        
        
        
    }
    
}
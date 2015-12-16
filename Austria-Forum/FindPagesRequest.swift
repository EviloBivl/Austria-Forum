//
//  findPagesRequest.swift
//  Austria-Forum
//
//  Created by Paul Neuhold on 10.12.15.
//  Copyright © 2015 Paul Neuhold. All rights reserved.
//

import Foundation
import SwiftyJSON

class FindPagesRequest : BaseRequest {
    
    let method: String = "search.findPagesMobile"
    var query : String?
    var numberOfMaxResults : Int?
    
    private override init(){
        super.init()
        self.customInitAfterSuperInit()
    }
    
    convenience init(query: String, numberOfMaxResults: Int) {
        self.init()
        self.query = query
        self.numberOfMaxResults = numberOfMaxResults
        self.addAdditionalRequestInfo()
    }
    
    override func addAdditionalRequestInfo() {
        
        self.requestBody["method"] = method
        var paramsArray : Array<AnyObject> = []
        if let q = self.query, let n = self.numberOfMaxResults {
            paramsArray = [q , n]
        } else {
            //we won't find a endoint with false parameters - so just handle requestfailed
        }
        self.requestBody["params"] = paramsArray
        
    }
    
    override func parseResponse(response: JSON) {
        print("Request : \(self.description)\nResponseData: \(response.description)")
        //do somthing usefull with the result
        if let articles = response["result"]["list"].arrayObject {
            for object in articles {
                if let page = object["map"] {
                    let result: SearchResult = SearchResult(title: page!["title"] as! String, name: page!["page"]! as! String, url: page!["url"]! as! String, score: page!["score"] as! Int)
                    SearchHolder.sharedInstance.searchResults.append(result)
                }
            }
        }
    }
    
    
    
}
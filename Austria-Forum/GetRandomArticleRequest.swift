//
//  GetRandomArticleRequest.swift
//  Austria-Forum
//
//  Created by Paul Neuhold on 10.12.15.
//  Copyright © 2015 Paul Neuhold. All rights reserved.
//

import Foundation
import SwiftyJSON


class GetRandomArticleRequest: BaseRequest {
    
    var method: String = "search.getRandomPage"
    var categories: [String] = []
    
    private override init(){
        super.init()
        self.customInitAfterSuperInit()
    }
    
    convenience init(categories: [String]) {
        self.init()
        self.categories.appendContentsOf(categories)
        self.addAdditionalRequestInfo()
    }
    
    /*
    //provide a dummy paramter so that JSON-RPC can handle the incoming call
    var paramsArray : Array<AnyObject> = [];
    if (self.categories.count > 0){
    paramsArray.append(self.categories)
    } else {
    paramsArray.append(NSNull())
    }
    
    */
    override func addAdditionalRequestInfo() {
        self.requestBody["method"] = self.method
        //provide a dummy paramter so that JSON-RPC can handle the incoming call
        var paramsArray : Array<AnyObject> = [];
        if (self.categories[0] == "ALL"){
            paramsArray.append(NSNull())
        } else {
            paramsArray.append(self.categories)
        }
        self.requestBody["params"] = paramsArray
    }
    
    override func parseResponse (response : JSON){
        print("Request : \(self.description)\nResponseData: \(response.description)")
        //do somthing usefull with the result
        
        if let articles = response["result"]["map"].dictionaryObject {
            if articles["ResultCode"] as! String == "0"{
                let name = articles["name"] as! String
                let title = articles["title"] as! String
                let url = articles["url"] as! String
                let score = 100
                let license = articles["license"] as! String?
                let result : SearchResult = SearchResult(title: title, name: name, url: url, score: score, license: license)
                SearchHolder.sharedInstance.selectedItem = result
            } else {
                super.handleResponseError(self.description, article: articles)
                SearchHolder.sharedInstance.resultMessage = "Zur Zeit können leider keine Zufallsartikel vom Server generiert werden."
            }
            
        }
        
        
        
        
    }
    
    
}

//
//  GetRandomArticleRequest.swift
//  Austria-Forum
//
//  Created by Paul Neuhold on 10.12.15.
//  Copyright © 2015 Paul Neuhold. All rights reserved.
//

import Foundation
import SwiftyJSON

class GetArticleFromMonthlyPool: BaseRequest {
    
    let method : String = "search.getArticleFromMonthlyPool"
    var month : String?
    var year : String?
    
    
    override init(){
        super.init()
        self.customInitAfterSuperInit()
        self.addAdditionalRequestInfo()
    }
    
    
    convenience init(month: String, year: String) {
        self.init()
        self.month = month
        self.year = year
        self.addAdditionalRequestInfo()
    }
    
    override func addAdditionalRequestInfo() {
        self.requestBody["method"] = self.method
        var paramsArray : Array<AnyObject> = []
        if let m = self.month, let y = self.year {
            paramsArray = [1337, m , y]
        } else {
            paramsArray = [1337, "notSet" , "notSet"]
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
                let result : SearchResult = SearchResult(title: title, name: name, url: url, score: score)
                SearchHolder.sharedInstance.selectedItem = result
                UserData.sharedInstance.articleOfTheMonth = result
            } else {
                super.handleResponseError(self.description, article: articles)
            }
            
        }
    }
    
}

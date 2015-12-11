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
        self.customInit()
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
            paramsArray = [1337, m , y, 0]
        } else {
            paramsArray = [1337, "notSet" , "notSet", 0]
        }
        
        self.requestBody["params"] = paramsArray
    }
    
    override func parseResponse (response : JSON){
        print("Request : \(self.description)\nResponseData: \(response.description)")
        //do somthing usefull with the result
        
        
    }
    
}

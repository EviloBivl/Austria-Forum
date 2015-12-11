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
    
    
    override init(){
        super.init()
        self.customInit()
        self.addAdditionalRequestInfo()
    }
    
    
    override func addAdditionalRequestInfo() {
        self.requestBody["method"] = self.method
        //provide a dummy paramter so that JSON-RPC can handle the incoming call
        let paramsArray : Array<AnyObject> = ["1337"]
        self.requestBody["params"] = paramsArray
    }
    
    override func parseResponse (response : JSON){
        print("Request : \(self.description)\nResponseData: \(response.description)")
        //do somthing usefull with the result
        
        
    }

    
}

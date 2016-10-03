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
    
    fileprivate override init(){
        super.init()
        self.requestID = RequestID.getRandomPage.rawValue
        self.customInitAfterSuperInit()
    }
    
    convenience init(categories: [String]) {
        self.init()
        self.requestID = RequestID.getRandomPage.rawValue
        self.categories.append(contentsOf: categories)
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
        self.requestBody["method"] = self.method as AnyObject?
        //provide a dummy paramter so that JSON-RPC can handle the incoming call
        var paramsArray : Array<AnyObject> = [];
        if (self.categories[0] == "ALL"){
            paramsArray.append(NSNull())
        } else {
            paramsArray.append(self.categories as AnyObject)
        }
        self.requestBody["params"] = paramsArray as AnyObject?
    }
    
    override func parseResponse (_ response : JSON){
        //print("Request : \(self.description)\nResponseData: \(response.description)")
        //do somthing usefull with the result
        
        if let map = response["result"]["map"].dictionary {
            if map["ResultCode"]?.string == "0"{
                let name = map["name"]?.string
                let title = map["title"]?.string
                let url = map["url"]?.string
                let score = 100
                
                var licenseResult: LicenseResult? = .none
                if let lic = map["license"]?.dictionary {
                    if let licenseMap = lic["map"]?.dictionary {
                        let licCss = licenseMap["css"]?.string
                        let licUrl = licenseMap["url"]?.string
                        let licId = licenseMap["id"]?.string
                        let licTitle = licenseMap["title"]?.string
                        licenseResult = LicenseResult(withCss: licCss, withTitle: licTitle, withUrl: licUrl, withId: licId)
                        
                    }
                }
                
                let result : SearchResult = SearchResult(title: title, name: name, url: url, score: score, licenseResult: licenseResult)
                SearchHolder.sharedInstance.selectedItem = result
            } else {
                super.handleResponseError(self.description, article: map)
                SearchHolder.sharedInstance.resultMessage = "Zur Zeit können leider keine Zufallsartikel vom Server generiert werden."
            }
            
        }
        
        
        
        
    }
    
    deinit {
        print("\(self.description) deinit")
    }
    
    
}

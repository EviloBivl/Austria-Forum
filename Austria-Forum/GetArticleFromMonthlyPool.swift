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
        self.requestID = RequestID.getMonthlyArticle.rawValue
        self.customInitAfterSuperInit()
        self.addAdditionalRequestInfo()
    }
    
    
    convenience init(month: String, year: String) {
        self.init()
        self.requestID = RequestID.getMonthlyArticle.rawValue
        self.month = month
        self.year = year
        self.addAdditionalRequestInfo()
    }
    
    override func addAdditionalRequestInfo() {
        self.requestBody["method"] = self.method as AnyObject?
        var paramsArray : Array<AnyObject> = []
        if let m = self.month, let y = self.year {
            paramsArray = [1337 as AnyObject, m as AnyObject , y as AnyObject]
        } else {
            paramsArray = [1337 as AnyObject, "notSet" as AnyObject , "notSet" as AnyObject]
        }
        
        self.requestBody["params"] = paramsArray as AnyObject?
    }
    
    override func parseResponse (_ response : JSON){
        // print("Request : \(self.description)\nResponseData: \(response.description)")
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
                UserData.sharedInstance.articleOfTheMonth = result
            } else {
                super.handleResponseError(self.description, article: map)
                SearchHolder.sharedInstance.resultMessage = "Für dieses Monat wurde noch kein \"Artikel des Monats\" gesetzt bitte versuchen Sie es später noch einmal."
            }
        }
    }
    
    deinit {
        print("\(self.description) deinit")
    }
}

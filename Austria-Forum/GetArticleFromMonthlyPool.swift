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
        do {
            let monthlyArticle = try JSONDecoder().decode(AustriaFormBaseResponse<ResultMap<MonthlyArticle>>.self,
                                                          from: response.rawData()).result.map
            if monthlyArticle.ResultCode == "0" {
                let result : SearchResult = SearchResult(title: monthlyArticle.title,
                                                         name: monthlyArticle.page,
                                                         url: monthlyArticle.url,
                                                         score: 100,
                                                         licenseResult: monthlyArticle.license?.map)
                SearchHolder.sharedInstance.selectedItem = result
                UserData.sharedInstance.articleOfTheMonth = result
            } else {
                super.handleResponseError("Für dieses Monat wurde noch kein \"Artikel des Monats\" gesetzt bitte versuchen Sie es später noch einmal.")
            }
        } catch (let error){
            print(" ===================== DECODE ERROR : =====================\n\(error)")
            super.handleResponseError("Für dieses Monat wurde noch kein \"Artikel des Monats\" gesetzt bitte versuchen Sie es später noch einmal.")
        }
    }
}

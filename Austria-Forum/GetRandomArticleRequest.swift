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
        do {
            let randomArticle = try JSONDecoder().decode(AustriaFormBaseResponse<ResultMap<RandomArticle>>.self, from: response.rawData()).result.map
            if randomArticle.ResultCode == "0" {
                let result : SearchResult = SearchResult(title: randomArticle.title,
                                                         name: randomArticle.page,
                                                         url: randomArticle.url,
                                                         score: 100,
                                                         licenseResult: randomArticle.license?.map ?? .none)
                SearchHolder.sharedInstance.selectedItem = result
            } else {
                super.handleResponseError("Zur Zeit können leider keine Zufallsartikel vom Server generiert werden.")
            }
        } catch (let error) {
            print(" ===================== DECODE ERROR : =====================\n\(error)")
            super.handleResponseError("Zur Zeit können leider keine Zufallsartikel vom Server generiert werden.")
        }
    }
}

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
    
    deinit {
        print("\(self.description) deinit")
    }
    
    convenience init(urls: [String]?) {
        self.init()
        self.urls = urls
        self.requestID = RequestID.getPageInfo.rawValue
        self.customInitAfterSuperInit()
        self.addAdditionalRequestInfo()
    }
    
    override func addAdditionalRequestInfo() {
        self.requestBody["method"] = self.method as AnyObject?
        var paramsArray : Array<AnyObject> = []
        for (url) in self.urls!{
            paramsArray.append(url as AnyObject)
        }
        var urlsInArray : Array<AnyObject> = []
        urlsInArray.append(paramsArray as AnyObject)
        self.requestBody["params"] = urlsInArray as AnyObject?

    }
    
    override func parseResponse(_ response: JSON) {
        do {
            let pageInfoList = try JSONDecoder().decode(AustriaFormBaseResponse<ResultList<ResultMap<PageInfo>>>.self,
                from: response.rawData()).result.list
            guard let pageInfo = pageInfoList.first?.map else { return }
            
            if pageInfo.ResultCode == "0" {
                SearchHolder.sharedInstance.selectedItem = SearchResult(title: pageInfo.title,
                                                                        name: pageInfo.page,
                                                                        url: pageInfo.url,
                                                                        score: 100,
                                                                        licenseResult: pageInfo.license?.map)
            } else {
                let queryString = pageInfo.query
                SearchHolder.sharedInstance.selectedItem = SearchResult(title: queryString,
                                                                        name: queryString,
                                                                        url: queryString,
                                                                        score: 100,
                                                                        licenseResult: .none)
            }
        } catch (let error) {
            print("========================= DECODE ERROR =========================\n\(error)")
        }
    }
}

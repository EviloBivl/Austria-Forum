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
    
    fileprivate override init(){
        super.init()
        self.requestID = RequestID.getSearchedArticles.rawValue
        self.customInitAfterSuperInit()
    }
    
    convenience init(query: String, numberOfMaxResults: Int) {
        self.init()
        self.query = query
        self.requestID = RequestID.getSearchedArticles.rawValue
        self.numberOfMaxResults = numberOfMaxResults
        self.addAdditionalRequestInfo()
    }
    
    override func addAdditionalRequestInfo() {
        
        self.requestBody["method"] = method as AnyObject?
        var paramsArray : Array<AnyObject> = []
        if let q = self.query, let n = self.numberOfMaxResults {
            paramsArray = [q as AnyObject , n as AnyObject]
        } else {
            //we won't find a endoint with false parameters - so just handle requestfailed
        }
        self.requestBody["params"] = paramsArray as AnyObject?
        
    }
    
    override func parseResponse(_ response: JSON) {
        SearchHolder.sharedInstance.searchResults.removeAll()
        
        do {
            let searchResultList = try JSONDecoder().decode(AustriaFormBaseResponse<ResultList<ResultMap<SearchArticle>>>.self, from: response.rawData()).result.list
            SearchHolder.sharedInstance.searchResults = searchResultList.filter({ return $0.map.score > 1 }).compactMap {
                return SearchResult(title: $0.map.title,
                                    name: $0.map.page,
                                    url: $0.map.url,
                                    score: $0.map.score,
                                    licenseResult: $0.map.license?.map )
            }
        } catch (let error) {
            print("===================== DECODE ERROR : =====================\n\(error)")
        }
    }
}

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
        //a leaky print :O
        //print("Request : \(self.description)\nResponseData: \(response.description)")
        //do somthing usefull with the result
        
        SearchHolder.sharedInstance.searchResults.removeAll()
        
        if let results = response["result"].dictionary {
            if let listObjects = results["list"]?.array {
                if listObjects.count == 0 {
                    // super.handleResponseError("Es wurden keine Artikel gefunden", article: [:])
                }
                for listEntry in listObjects {
                    if let dict = listEntry.dictionary {
                        if let map = dict["map"]?.dictionary {
                            let name = map["page"]?.string
                            let title = map["title"]?.string
                            let url = map["url"]?.string
                            let score = map["score"]?.int
                            
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
                            
                            if let score = score {
                                if score > 1 {
                                    let searchResult : SearchResult = SearchResult(title: title, name: name, url: url, score: score, licenseResult: licenseResult)
                                    SearchHolder.sharedInstance.searchResults.append(searchResult)
                                    
                                }
                            }
                        }
                    }
                }
            }
        }
        
//        if let articles = response["result"]["list"].arrayObject {
//            for object in articles {
//                if let page = object["map"] {
//                    if page!["score"] as! Int > 1 {
//                        let result: SearchResult = SearchResult(title: page!["title"] as! String, name: page!["page"]! as! String, url: page!["url"]! as! String, score: page!["score"] as! Int, license: page!["license"] as! String? )
//                        SearchHolder.sharedInstance.searchResults.append(result)
//                    }
//                }
//            }
//        }
    }
    
    
    deinit {
        print("\(self.description) deinit")
    }
    
    
}

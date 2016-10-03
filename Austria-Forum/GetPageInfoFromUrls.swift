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
        
        
       // print("Request : \(self.description)\nResponseData: \(response.description)")
        
        //do somthing usefull with the result
        if let results = response["result"].dictionary {
            if let listObjects = results["list"]?.array {
                for listEntry in listObjects {
                    if let dict = listEntry.dictionary {
                        if let map = dict["map"]?.dictionary {
                            if let resultCode = map["ResultCode"]?.string {
                                if resultCode == "0" {
                                    let name = map["name"]?.string
                                    let title = map["title"]?.string
                                    let url = map["url"]?.string
                                    
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
                                    
                                    let searchResult = SearchResult(title: title!, name: name!, url: url!, score: 100, licenseResult: licenseResult)
                                    SearchHolder.sharedInstance.selectedItem = searchResult
                                } else if resultCode == "-1" {
                                    let query = map["query"]?.string
                                    let searchResult = SearchResult(title: query!, name: query!, url: query!, score: 100, licenseResult: .none)
                                    SearchHolder.sharedInstance.selectedItem = searchResult
                                }
                            }
                        }
                    }
                }
            }
        }
    
    }
//
//    override func sendValue(response: AnyObject) {
//        
//        //print("Request : \(self.description)\nResponseData: \(response.description)")
//        
//        if let response = response as? String {
//            print("saving \(response) to SearchHolder now")
//            SearchHolder.sharedInstance.dummyObjectHolder = response
//        }
//        return
//        
//        
//        if let results = response["result"] as? [String: AnyObject] {
//            if let list = results["list"] as? [AnyObject]{
//                if let mapDict = list.first as? [String: AnyObject]{
//                    if let map = mapDict["map"] as? [String: AnyObject]{
//                        if let resultCode = map["ResultCode"] as? Int{
//                            if resultCode == 0 {
//                                //request success
//                                if  let name = map["name"] as? String, let title = map["title"] as? String, let url = map["url"] as? String, let license = map["license"] as? String {
//                                    let searchResult = SearchResult(title: title, name: name, url: url, score: 100, license: license)
//                                    SearchHolder.sharedInstance.selectedItem = searchResult
//                                    print("saved new searchResult")
//                                }
//                            } else if resultCode == -1 {
//                                //no infos found from query
//                                if let query = map["query"] as? String{
//                                    let searchResult = SearchResult(title: query, name: query, url: query, score: 100, license: "AF")
//                                    SearchHolder.sharedInstance.selectedItem = searchResult
//                                    print("saved new searchResult but url not found")
//                                }
//                            }
//                            
//                            
//                        }
//                    }
//                }
//            }
//        }
//        
    
        
        //do somthing usefull with the result
        //        if let articles = response["result"]["list"].arrayObject {
        //            for object in articles {
        //                if let page = object["map"] {
        //                    if page!["ResultCode"] as! String == "0"{
        //                        let name = page!["name"] as! String
        //                        let title = page!["title"] as! String
        //                        let url = page!["url"] as! String
        //                        let license = page!["license"] as! String?
        //                        let searchResult = SearchResult(title: title, name: name, url: url, score: 100, license: license)
        //                        SearchHolder.sharedInstance.selectedItem = searchResult
        //                    } else {
        //                        let query = page!["query"] as! String
        //                        let searchResult = SearchResult(title: query, name: query, url: query, score: 100, license: "AF")
        //                        SearchHolder.sharedInstance.selectedItem = searchResult
        //
        //                        super.handleResponseError(self.description, article: [:])
        //                    }
        //                }
        //
        //            }
        //        } else {
        //            super.handleResponseError(self.description, article: [:])
        //
        //        }
        //
        
        
//    }
    
}

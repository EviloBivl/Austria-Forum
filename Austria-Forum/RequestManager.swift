//
//  RequestManager.swift
//  Austria-Forum
//
//  Created by Paul Neuhold on 10.12.15.
//  Copyright © 2015 Paul Neuhold. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import CoreLocation

/** RequestManager Class
 
 */
class RequestManager : NSObject {
    
    static let sharedInstance = RequestManager()
    
    var alamo : SessionManager?
    let timeoutInSeconds : TimeInterval = 6
    
    fileprivate override init(){
        super.init()
        self.alamo = SessionManager()
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = timeoutInSeconds
        config.timeoutIntervalForResource = timeoutInSeconds
        self.alamo = SessionManager(configuration: config)
        
    }
    
    
    func getRandomArticle(_ delegate: NetworkDelegation, categories: [String]){
        let getRandomArticleRequest : GetRandomArticleRequest = GetRandomArticleRequest(categories: categories)
        performRequest(getRandomArticleRequest, delegate: delegate)
    }
    
    func getArticleFromMonthlyPool(_ delegate: NetworkDelegation, month: String? = nil, year: String? = nil){
        
        let getArticleFMPReq : GetArticleFromMonthlyPool?
        if let m = month, let y = year {
            getArticleFMPReq = GetArticleFromMonthlyPool(month: m, year: y)
        } else {
            getArticleFMPReq = GetArticleFromMonthlyPool()
        }
        
        performRequest(getArticleFMPReq!, delegate: delegate)
    }
    
    
    func findPages(_ delegate: NetworkDelegation ,query : String, numberOfMaxResults: Int ){
        let findPagesReq : FindPagesRequest = FindPagesRequest(query: query, numberOfMaxResults: numberOfMaxResults)
        performRequest(findPagesReq, delegate: delegate)
        
    }
    
    func getArticlesByLocation (_ delegate: NetworkDelegation, location: CLLocationCoordinate2D, numberOfResults: Int){
        let getArticlesByLocationRequest : GetArticlesByLocationRequest = GetArticlesByLocationRequest(coordinates: location, numberOfResults: numberOfResults)
        performRequest(getArticlesByLocationRequest, delegate: delegate)
        
    }
    
    func getPageInfoFromUrls(_ delegate: NetworkDelegation, urls : [String]){
        let pageInfoRequest : GetPageInfoFromUrls = GetPageInfoFromUrls(urls: urls)
        performRequest(pageInfoRequest, delegate: delegate)
    }
    
    
    fileprivate func performRequest(_ req: BaseRequest, delegate: NetworkDelegation) -> Void {
        
        
        if ReachabilityHelper.sharedInstance.connection == ReachabilityType.no_INTERNET{
            delegate.noInternet?()
            return
        }
        
        
       // print("====== STARTING REQUEST ========= FOR ID:  \(req.requestBody["id"]!)    =====");
       // print("\(req.requestBody.debugDescription)")
        self.alamo!.request(req.urlAF, method: .post, parameters: req.requestBody, encoding: JSONEncoding.default, headers: req.requestHeader ).responseJSON { /*[unowned delegate]*/
            
            jsonResp in
            
            
            if let error = jsonResp.result.error {
                print(error.localizedDescription)
                delegate.onRequestFailed()
                return
            }
                
            else if jsonResp.result.isSuccess {
                if let responseJSON = jsonResp.result.value as? [String: AnyObject], let value = jsonResp.result.value {
                    if let idFromReq = responseJSON["id"] as? Int /*let results = responseJSON["result"] as? [String: AnyObject]*/{
                        
                        
                        print("====== REQUEST STARTED WITH ===== FOR ID:  \(idFromReq)    =====")
                        print("====== RESPONSE DESCRIPTION ===== FOR ID:  \(idFromReq)    =====")
                        print("\(String(describing: jsonResp.result.value))")
                        print("=======================================================")
                        let methodString = RequestID.getStringForRawValue(idFromReq)
                        
                        let responseInJson = JSON(value)
                        req.parseResponse(responseInJson)
                        delegate.onRequestSuccess(methodString)
                    }
                }
                
            } else if jsonResp.result.isFailure {
//                print("For now we are failing in the alamo closures - later send it to delegate")
            }
            
            
            print("====== RESPONSE END         ============================")
        }
    }
}

public enum RequestID : Int {
    
    case getPageInfo = 1001
    case getRandomPage = 1002
    case getLocationArticles = 1003
    case getMonthlyArticle = 1004
    case getSearchedArticles = 1005
    
    static func getStringForRawValue (_ rawVal : Int)  -> String {
        
        let requestId = RequestID(rawValue: rawVal)
        if let requestId = requestId {
            switch requestId {
            case .getPageInfo:
                return "search.getPageInfo"
            case .getRandomPage:
                return "search.getRandomPage"
            case .getLocationArticles:
                return "search.getAllPagesInRange"
            case .getSearchedArticles:
                return "search.findPagesMobile"
            case .getMonthlyArticle:
                return "search.getArticleFromMonthlyPool"
            }
        } else {
            return ""
        }
    }
    
}

/*
 
 
 */


































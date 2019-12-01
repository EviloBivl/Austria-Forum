//
//  RequestManager.swift
//  Austria-Forum
//
//  Created by Paul Neuhold on 10.12.15.
//  Copyright © 2015 Paul Neuhold. All rights reserved.
//

import Foundation
import Alamofire
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
        
        if ReachabilityHelper.sharedInstance.connection == ReachabilityType.no_INTERNET {
            delegate.noInternet?()
            return
        }
        
        print("====== STARTING REQUEST ========= FOR ID:  \(req.requestBody["id"]!)    =====");
        self.alamo!.request(req.urlAF, method: .post, parameters: req.requestBody, encoding: JSONEncoding.default, headers: req.requestHeader ).responseData {
            dataResp in
            
            if let error = dataResp.result.error {
                print(error.localizedDescription)
                delegate.onRequestFailed()
                return
            }
                
            guard dataResp.result.isSuccess,
                let data = dataResp.data else {
                    delegate.onRequestFailed()
                    return
            }
                do {
                    let baseResponse = try JSONDecoder().decode(AustriaForumConcreteResponse.self, from: data)
            
                    print("====== RESPONSE DESCRIPTION ===== FOR ID:  \(baseResponse.id)  \(req.requestBody["method"]!)  =====")
                    print("\(String(data: data, encoding: .utf8) ?? "No Valid Data Response")")
                    print("=======================================================")
                    
                    let methodString = RequestID.getStringForRawValue(baseResponse.id)
                    req.parseResponse(data)
                    delegate.onRequestSuccess(methodString)
                } catch (let error) {
                    print("====== REQUEST PARSING ERROR AFConcreteResponse =====\n\(error)")
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


































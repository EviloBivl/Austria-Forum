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

/** RequestManager Class
 
 */
class RequestManager : NSObject {
    
    static let sharedInstance = RequestManager()
    
    var alamo : Manager?
    
    private override init(){
        super.init()
        self.alamo = Manager.sharedInstance
        
    }
    
    
    func getRandomArticle(delegate: AnyObject? = nil, categories: [String]){
        let getRandomArticleRequest : GetRandomArticleRequest = GetRandomArticleRequest(categories: categories)
        performRequest(getRandomArticleRequest, delegate: delegate)
        
    }
    
    func getArticleFromMonthlyPool(delegate: AnyObject? = nil, month: String? = nil, year: String? = nil){
        
        let getArticleFMPReq : GetArticleFromMonthlyPool?
        if let m = month, let y = year {
            getArticleFMPReq = GetArticleFromMonthlyPool(month: m, year: y)
        } else {
            getArticleFMPReq = GetArticleFromMonthlyPool()
        }
        
        performRequest(getArticleFMPReq!, delegate: delegate)
    }
    
    
    func findPages(delegate: AnyObject? = nil ,query : String, numberOfMaxResults: Int ){
        let findPagesReq : FindPagesRequest = FindPagesRequest(query: query, numberOfMaxResults: numberOfMaxResults)
        performRequest(findPagesReq, delegate: delegate)
        
    }
    
    
    private func performRequest(req: BaseRequest, delegate: AnyObject? = nil){
        
        
        print("====== STARTING REQUEST ========= FOR ID:  \(req.requestBody["id"]!)    =====");
        //clear old SearchResults
        SearchHolder.sharedInstance.searchResults.removeAll()
        
        self.alamo!.request(.POST, req.urlAF, parameters: req.requestBody, encoding: .JSON, headers: req.requestHeader ).responseJSON { jsonResp in
            
            
            var id : Int = 0;
            
            if let body = jsonResp.request!.HTTPBody {
                let json = JSON(data: body)
                id = json["id"].intValue
                print("====== REQUEST STARTED WITH ===== FOR ID:  \(id)    =====")
                print(json.debugDescription)

            }
            
            print("====== RESPONSE DESCRIPTION ===== FOR ID:  \(id)    =====")
            
            if let error = jsonResp.result.error {
                print(error.debugDescription)
                if delegate is NetworkDelegation {
                    (delegate as! NetworkDelegation).onRequestFailed()
                }
            }
            
            if jsonResp.result.isSuccess {
                if let value = jsonResp.result.value {
                    req.parseResponse(JSON(value))
                    if delegate is NetworkDelegation {
                        (delegate as! NetworkDelegation).onRequestSuccess()
                    }
                }
            } else if jsonResp.result.isFailure {
                print("For now we are failing in the alamo closures - later send it to delegate")
            }
            
            
            print("====== RESPONSE END         ===== FOR ID:  \(id)    =====")
        }
    }
}

































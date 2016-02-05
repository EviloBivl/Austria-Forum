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
    
    func getArticlesByLocation (delegate: AnyObject?  = nil, location: CLLocationCoordinate2D, numberOfResults: Int){
        //for now till the webservice is completed
        //just call the success delegate to trigger the Push Notification and fill some Data to the locationTable
        //let result : LocationArticleResult = LocationArticleResult(title: "Link to Austria forum", name: "dummy name", url: "http://www.austria-forum.org", distance: 13.37)
        //LocationArticleHolder.sharedInstance.articles.append(result)
        //print("\n\n STARTED LOCATION REQUEST \n\n")
        //(delegate as! NetworkDelegation).onRequestSuccess()
        
       // Activate this once the webservice is finished
        let getArticlesByLocationRequest : GetArticlesByLocationRequest = GetArticlesByLocationRequest(coordinates: location, numberOfResults: numberOfResults)
        performRequest(getArticlesByLocationRequest, delegate: delegate)
        
    }


    private func performRequest(req: BaseRequest, delegate: AnyObject? = nil) -> Void{

        if let reachable = delegate as? ReachabilityDelegate {
            if ReachabilityHelper.sharedInstance.connection == ReachabilityType.NO_INTERNET{
                reachable.noInternet()
                return
            }
        }
        
        
        print("====== STARTING REQUEST ========= FOR ID:  \(req.requestBody["id"]!)    =====");
        
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

































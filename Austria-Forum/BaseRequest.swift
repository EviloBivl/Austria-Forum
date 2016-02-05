//
//  BaseRequest.swift
//  Austria-Forum
//
//  Created by Paul Neuhold on 10.12.15.
//  Copyright © 2015 Paul Neuhold. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class BaseRequest : NSObject {
    
    //TODO: Change this to the live Url
    let urlAF: String = "http://www.austria-forum.org/JSON-RPC"
    static let urlAFStatic = "austria-forum.org"
 //   let urlAF: String = "http://192.168.178.21:8080/JSON-RPC"
 //   static let urlAFStatic = "http://192.168.178.21:8080"
    var requestHeader : [String:String] = [:]
    var requestBody : [String:AnyObject] = [:]
    private(set) var requestID : Int = random()
    
    override init() {
        super.init()
    }
    
    
    func customInitAfterSuperInit(){
        self.requestHeader["Content-Type"] = "application/json"
        self.requestBody["id"] = requestID
        
    }
    
    func addAdditionalRequestInfo(){
        fatalError("\(self.description) must override addAdditionalRequestInfo()")
    }
    
    func parseResponse (response: JSON){
        fatalError("\(self.description) must override parseResponse(response: JSON)")
    }
    
    func handleResponseError(errorFrom: String, article: [String:AnyObject]){
        print("Error from \(errorFrom) with ResultCode: \(article["ResultCode"] as? String) and Message: \(article["ResultDescription"])")
        //set the article to nil to provide the error message and proper handling of relaoding on failed requests
        SearchHolder.sharedInstance.selectedItem = nil
    }
    
}

//
//  BaseRequest.swift
//  Austria-Forum
//
//  Created by Paul Neuhold on 10.12.15.
//  Copyright © 2015 Paul Neuhold. All rights reserved.
//

import Foundation
import Alamofire


class BaseRequest : NSObject {
    
    let urlAF: String = "https://austria-forum.org/JSON-RPC"
    var requestHeader : [String:String] = [:]
    var requestBody : [String:AnyObject] = [:]
    
    //TODO make requestID random again
    var requestID : Int = 1337
    
    override init() {
        super.init()
    }
    
    func customInitAfterSuperInit(){
        self.requestHeader["Content-Type"] = "application/json"
        self.requestBody["id"] = requestID as AnyObject?
        
    }
    
    func addAdditionalRequestInfo(){
        fatalError("\(self.description) must override addAdditionalRequestInfo()")
    }
    
    func parseResponse(_ response: Data){
        fatalError("\(self.description) must override parseResponse(response: JSON)")
    }
    func sendValue(_ response: AnyObject){
        
        print("Response BASEREQUEST: \(response)")
    }
    
    func handleResponseError(_ errorFrom: String, article: [String:AnyObject] = [String:AnyObject]()){
        //TODO implement better handling
        SearchHolder.sharedInstance.resultMessage = errorFrom
        SearchHolder.sharedInstance.selectedItem = nil
    }
}

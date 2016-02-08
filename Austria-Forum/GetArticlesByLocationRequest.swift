//
//  GetArticlesByLocationRequest.swift
//  Austria-Forum
//
//  Created by Paul Neuhold on 21.01.16.
//  Copyright © 2016 Paul Neuhold. All rights reserved.
//

import Foundation
import CoreLocation
import SwiftyJSON

class GetArticlesByLocationRequest: BaseRequest {
    
    var method: String = "search.getAllPagesInRange"
    var coordinates: CLLocationCoordinate2D?
    let rangeToSearch : Int = 1000
    var numberOfResults : Int = 40
    
    private override init(){
        super.init()
        self.customInitAfterSuperInit()
    }
    
    convenience init(coordinates: CLLocationCoordinate2D, numberOfResults : Int) {
        self.init()
        self.coordinates = coordinates
        self.numberOfResults = numberOfResults
        self.addAdditionalRequestInfo()
    }
    
    override func addAdditionalRequestInfo() {
        self.requestBody["method"] = self.method
        let paramsArray : Array<AnyObject> = [self.coordinates!.latitude, self.coordinates!.longitude, rangeToSearch, numberOfResults]
        self.requestBody["params"] = paramsArray
    }
    
    override func parseResponse(response: JSON) {
        print("Request : \(self.description)\nResponseData: \(response.description)")
        
        LocationArticleHolder.sharedInstance.articles.removeAll()
        
        //do somthing usefull with the result
        if let articles = response["result"]["list"].arrayObject {
            for object in articles {
                if let page = object["map"] {
                    let name = page!["page"] as! String
                    let title = page!["title"] as! String
                    let url = page!["url"] as! String
                    let distanceInt = page!["distance"] as! Int
                    let license = page!["license"] as! String?
                    
                    var distString = ""
                    if  distanceInt <= 1000 {
                        distString += "\(distanceInt)" + " m"
                    } else {
                        let distFloat = Float(distanceInt)
                        distString += "\(distFloat/1000)"
                        let decimalIndex = distString.characters.indexOf(".")
                        let endIndex = distString.characters.endIndex
                        if let index = decimalIndex {
                            if index.distanceTo(endIndex) >= 3{
                            distString = distString.substringToIndex(index.advancedBy(3))
                            }
                            distString = distString.stringByReplacingOccurrencesOfString(".", withString: ",")
                        }
                        distString += " Km"
                    }
                    
                    let result : LocationArticleResult = LocationArticleResult(title: title, name: name, url: url, distanceStr: distString, distanceVal: distanceInt, license: license)
                    LocationArticleHolder.sharedInstance.articles.append(result)
                }
                
            }
        } else {
            super.handleResponseError(self.description, article: [:])
            
        }
    }
    
    
}

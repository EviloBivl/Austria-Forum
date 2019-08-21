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
    var numberOfResults : Int = 100
    
    fileprivate override init(){
        super.init()
        self.requestID = RequestID.getLocationArticles.rawValue
        self.customInitAfterSuperInit()
    }
    
    convenience init(coordinates: CLLocationCoordinate2D, numberOfResults : Int) {
        self.init()
        self.requestID = RequestID.getLocationArticles.rawValue
        self.coordinates = coordinates
        self.numberOfResults = numberOfResults
        self.addAdditionalRequestInfo()
    }
    
    override func addAdditionalRequestInfo() {
        self.requestBody["method"] = self.method as AnyObject?
        let paramsArray : Array<AnyObject> = [self.coordinates!.latitude as AnyObject, self.coordinates!.longitude as AnyObject, rangeToSearch as AnyObject, numberOfResults as AnyObject]
        self.requestBody["params"] = paramsArray as AnyObject?
    }
    
    override func parseResponse(_ response: JSON) {
       // print("Request : \(self.description)\nResponseData: \(response.description)")
        
        LocationArticleHolder.sharedInstance.articles.removeAll()
        
        if let results = response["result"].dictionary {
            if let listObjects = results["list"]?.array {
                if listObjects.count == 0 {
                    super.handleResponseError("Es wurden keine Artikel im Umkreis von \(rangeToSearch) Kilometer gefunden.", article: [:])
                }
                for listEntry in listObjects {
                    if let dict = listEntry.dictionary {
                        if let map = dict["map"]?.dictionary {
                            let name = map["page"]?.string
                            let title = map["title"]?.string
                            let url = map["url"]?.string
                            let distance = map["distance"]?.int
                            
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
                            
                            let distanceStr = claculateDistanceString(distance)
                            let result : LocationArticleResult = LocationArticleResult(title: title!, name: name!, url: url!, distanceStr: distanceStr, distanceVal: distance!, licenseResult: licenseResult)
                            LocationArticleHolder.sharedInstance.articles.append(result)
                        }
                    }
                }
            }
        }
    }
    
    deinit {
        print("\(self.description) deinit")
    }
    
    //
    //        //do somthing usefull with the result
    //        if let articles = response["result"]["list"].arrayObject {
    //            for object in articles {
    //                if let page = object["map"] {
    //                    let name = page!["page"] as! String
    //                    let title = page!["title"] as! String
    //                    let url = page!["url"] as! String
    //                    let distanceInt = page!["distance"] as! Int
    //                    let license = page!["license"] as! String?
    //
    //                    var distString = ""
    //                    
    //                    let result : LocationArticleResult = LocationArticleResult(title: title, name: name, url: url, distanceStr: distString, distanceVal: distanceInt, license: license)
    //                    LocationArticleHolder.sharedInstance.articles.append(result)
    //                }
    //
    //            }
    //        } else {
    //            super.handleResponseError(self.description, article: [:])
    //
    //        }
    //    }
    
    fileprivate func claculateDistanceString(_ distanceInt: Int?) -> String {
        var distString = ""
        if let distanceInt = distanceInt {
            if  distanceInt <= 1000 {
                distString += "\(distanceInt)" + " m"
            } else {
                let distDouble = Double(distanceInt) / 1000
                distString += String(format: "%.2f", distDouble.truncate(places: 2))
                distString = distString.replacingOccurrences(of: ".", with: ",")
                distString += " Km"
            }
        }
        return distString
    }
}

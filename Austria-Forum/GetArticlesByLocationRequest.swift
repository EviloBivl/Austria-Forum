//
//  GetArticlesByLocationRequest.swift
//  Austria-Forum
//
//  Created by Paul Neuhold on 21.01.16.
//  Copyright © 2016 Paul Neuhold. All rights reserved.
//

import Foundation
import CoreLocation

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
    
    override func parseResponse(_ response: Data) {
        LocationArticleHolder.sharedInstance.articles.removeAll()
        
        do {
            let nearbyResults = try JSONDecoder().decode(AustriaFormBaseResponse<ResultList<ResultMap<NearbyArticle>>>.self, from: response).result.list
            LocationArticleHolder.sharedInstance.articles = nearbyResults.compactMap {
                return LocationArticleResult(title: $0.map.title,
                                             name: $0.map.page,
                                             url: $0.map.url,
                                             distanceStr: self.claculateDistanceString($0.map.distance),
                                             distanceVal: $0.map.distance,
                                             licenseResult: $0.map.license?.map)
            }
        } catch (let error) {
            print("===================== DECODE ERROR : =====================\n\(error)")
        }
    }
    
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

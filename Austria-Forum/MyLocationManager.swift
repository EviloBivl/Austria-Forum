//
//  MyLocationManager.swift
//  Austria-Forum
//
//  Created by Paul Neuhold on 19.01.16.
//  Copyright © 2016 Paul Neuhold. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

/** MyLocationManager Class
 
 */
class MyLocationManager : NSObject{
    
    static let sharedInstance = MyLocationManager()
    let localNotification : UILocalNotification = UILocalNotification()
    var lastCoordinates : CLLocationCoordinate2D?
    var requestCurrentLocation : Bool = false
    var articlesByLocationDelegate : AnyObject?
    var numberOfLocationWSResult : Int = 20
    
    let locationManager: CLLocationManager! = {
        let manager = CLLocationManager()
        manager.requestAlwaysAuthorization()
        return manager
    }()
    
    
    private override init(){
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    //if we run in background or foreground we can make use of that distancefilter
    func startFromRunningState() {
        locationManager.stopMonitoringSignificantLocationChanges()
        if UserData.sharedInstance.locationChangeValue! == 0 {
            locationManager.distanceFilter = kCLDistanceFilterNone
            print("started with kCLDistanceFilterNone")
        } else {
            locationManager.distanceFilter = Double(UserData.sharedInstance.locationChangeValue!)
            
        }
        if #available(iOS 9.0, *) {
            locationManager.allowsBackgroundLocationUpdates = true
        } else {
            // we don't need this in earlier verions
        }
        locationManager.startUpdatingLocation()
        
     
    }
    
    //if we the app got started from terminated due to localization update
    func startFromTerminated() {
        locationManager.stopUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    func startIfAllowed() {
        print("Location Options changed - stopping service bevore we restart the correct one")
        self.stopTracking()
        if let frequentLocationAllowed = UserData.sharedInstance.locationDistanceChangeAllowed, let significantChangeAllowed = UserData.sharedInstance.locationSignifacantChangeAllowed {
            if frequentLocationAllowed {
                print("start updating location")
                self.startFromRunningState()
            } else if significantChangeAllowed {
                print("start significant change location")
                self.startFromTerminated()
            } else {
                self.stopTracking()
            }
        }
    }
    
    //TODO
    //stop tracking when settings are switched.
    //proper starting of locationservice - depending on which mode we are. and what the user wants
    //handle the correct scheduling of the local Notification - date and distance(distancefilter work)
    //handle if the user declines the alwaysauthorization - if yes we need one time authorization for geetting the nearby articles
    //
    
    func stopTracking() {
        if UserData.sharedInstance.locationDistanceChangeAllowed == false {
            locationManager.stopUpdatingLocation()
            print("stopUpdatingLocation")
        }
        if UserData.sharedInstance.locationSignifacantChangeAllowed == false {
            print("stopMonitoringSignificantLocationChanges")
            locationManager.stopMonitoringSignificantLocationChanges()
        }
    }
    
    func refreshToCurrentLocation(delegate: AnyObject, numberOfResults: Int) {
        self.requestCurrentLocation = true;
        self.numberOfLocationWSResult = numberOfResults
        self.articlesByLocationDelegate = delegate
        if let allow  = UserData.sharedInstance.locationDistanceChangeAllowed {
            if allow {
                self.startIfAllowed()
            }
        }
        
    }
    
    func isAllowedBySystem() -> Bool {
        let status = CLLocationManager.authorizationStatus()
        if status == .NotDetermined || status == .Denied || status == .Restricted{
            return false
        }else {
            return true
        }
    }
    
    
}


extension MyLocationManager : CLLocationManagerDelegate {
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        
        self.lastCoordinates = locations.last?.coordinate
        
        if self.requestCurrentLocation {
            RequestManager.sharedInstance.getArticlesByLocation(self.articlesByLocationDelegate, location: self.lastCoordinates!, numberOfResults: self.numberOfLocationWSResult )
            self.requestCurrentLocation = false
            print("attempt a manual update")
            return
        }
        
        if UIApplication.sharedApplication().applicationState == .Active {
          //  print("Foreground: New Location \((locations.last)!.description)")
        } else {
            print("BACKGROUND: New Location \((locations.last)!.description)")
            self.fireWebserviceCall()
        }
    }
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Location Error")
    }
    
    private func fireWebserviceCall () {
        if let allowPush =  UserData.sharedInstance.allowPushNotification {
            if allowPush {
                if self.isIntervalTimePassedSinceLastPush(){
                    print("Making the WS Call")
                    UserData.sharedInstance.lastNotificationDate = NSDate()
                    RequestManager.sharedInstance.getArticlesByLocation(self, location: self.lastCoordinates!, numberOfResults: 1)
                }
            }
        }
    }
    
    private func isIntervalTimePassedSinceLastPush() -> Bool{
        
        let now = NSDate()
        let lastPush = UserData.sharedInstance.lastNotificationDate!
        let elapsedTime = Int(now.timeIntervalSinceDate(lastPush))
        print ("elapsed time : +\(elapsedTime) - interval is \(UserData.sharedInstance.notificationIntervalInSeconds)")
        return elapsedTime >= UserData.sharedInstance.notificationIntervalInSeconds ? true : false
    }
}
/**
    Delagation for the location based Request.
 */
extension MyLocationManager : NetworkDelegation {
    func onRequestFailed(from: String?){
        
    }
    func onRequestSuccess(from: String?){
        
        
        let articles = LocationArticleHolder.sharedInstance.articles
        if !articles.isEmpty {
            if articles[0].distanceValue < 1000{
                self.createAndFireNotification(articles[0])
            }
        }
        
      
    }
    
    private func createAndFireNotification (lr : LocationArticleResult){
        
        let calendar = NSCalendar.init(calendarIdentifier: NSCalendarIdentifierGregorian)
        let currentHour = (calendar?.component(NSCalendarUnit.Hour, fromDate: NSDate()))!
        let currentMinute = (calendar?.component(NSCalendarUnit.Minute, fromDate: NSDate()))!
        let currentSecond = (calendar?.component(NSCalendarUnit.Second, fromDate: NSDate()))!
        let localNotification : UILocalNotification = UILocalNotification()
        
        localNotification.fireDate = NSDate()
        localNotification.soundName = UILocalNotificationDefaultSoundName
        localNotification.userInfo = ["url" : lr.url, "title" : lr.title, "distance" : lr.distanceString , "name" : lr.name]
        localNotification.alertBody = "Artikel in der Nähe gefunden - \(currentHour):\(currentMinute):\(currentSecond) - \"\(lr.title) - befindet sich \(lr.distanceString) entfernt.\""
        localNotification.timeZone = NSTimeZone.defaultTimeZone()
        localNotification.applicationIconBadgeNumber = UIApplication.sharedApplication().applicationIconBadgeNumber + 1
        print("previous app badge number: \(UIApplication.sharedApplication().applicationIconBadgeNumber)")
        
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
    }
}

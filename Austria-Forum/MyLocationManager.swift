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
import UserNotifications




/** MyLocationManager Class
 
 */
class MyLocationManager : NSObject{
    
    static let sharedInstance = MyLocationManager()
  //  let localNotification : UILocalNotification = UILocalNotification()
    var lastCoordinates : CLLocationCoordinate2D?
    var requestCurrentLocation : Bool = false
    weak var locationArticlesDelegate : LocationControllerDelegate?
    weak var articlesByLocationDelegate : NetworkDelegation?
    weak var optionsLocationDelegate : OptionsLocationDelegate?
    weak var locationErrorDelegate : LocationErrorDelegate?
    var numberOfLocationWSResult : Int = 100
    
    let locationManager: CLLocationManager! = {
        let manager = CLLocationManager()
        return manager
    }()
    
    
    func requestWhenInUse(){
         locationManager.requestWhenInUseAuthorization()
    }
    
    func requestAlways(){
         locationManager.requestAlwaysAuthorization()
    }
    
    fileprivate override init(){
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        //  locationManager.activityType = .Fitness
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
    
    func startAsResultTOLaunchFromLocationKey(){
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    func startIfAllowed() {
        print("Location Options changed - stopping service bevore we restart the correct one")
        self.stopTracking()
        if !UserData.sharedInstance.allowPushNotification!{
            return
        }
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
    
    class func isLocationAllowedByAppSettings() -> Bool {
        if let frequentLocationAllowed = UserData.sharedInstance.locationDistanceChangeAllowed, let significantChangeAllowed = UserData.sharedInstance.locationSignifacantChangeAllowed {
            return frequentLocationAllowed || significantChangeAllowed;
        }
        return false
    }
    
    //TODO
    //stop tracking when settings are switched.
    //proper starting of locationservice - depending on which mode we are. and what the user wants
    //handle the correct scheduling of the local Notification - date and distance(distancefilter work)
    //handle if the user declines the alwaysauthorization - if yes we need one time authorization for geetting the nearby articles
    //
    
    func stopTracking() {
        //If Push notifications are not allowed - no need to do background location
        if !UserData.sharedInstance.allowPushNotification! {
            locationManager.stopUpdatingLocation()
            print("stopUpdatingLocation - push not allowed")
            print("stopMonitoringSignificantLocationChanges - push not allowed")
            locationManager.stopMonitoringSignificantLocationChanges()
            return
        }
        
        if UserData.sharedInstance.locationDistanceChangeAllowed == false {
            locationManager.stopUpdatingLocation()
            print("stopUpdatingLocation")
        }
        if UserData.sharedInstance.locationSignifacantChangeAllowed == false {
            print("stopMonitoringSignificantLocationChanges")
            locationManager.stopMonitoringSignificantLocationChanges()
        }
    }
    
    func refreshToCurrentLocation(_ delegate: NetworkDelegation, numberOfResults: Int) {
        self.requestCurrentLocation = true;
        self.numberOfLocationWSResult = numberOfResults
        self.articlesByLocationDelegate = delegate
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()
    }
    
    class func isAllowedBySystem() -> Bool {
        let status = CLLocationManager.authorizationStatus()
        if status == .notDetermined || status == .denied || status == .restricted{
            return false
        }else {
            return true
        }
    }
    
    
}


extension MyLocationManager : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            if !UserData.sharedInstance.wasPushPermissionAsked! {
                self.optionsLocationDelegate?.receivedAlwaysPermissions()
            }
        } else if status == .authorizedWhenInUse {
            self.locationArticlesDelegate?.receivedPermissionResult()
        }
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        
        self.lastCoordinates = locations.last?.coordinate
        
        if self.requestCurrentLocation {
            if let cords = locations.last?.coordinate, let delegate = self.articlesByLocationDelegate {
                RequestManager.sharedInstance.getArticlesByLocation(delegate, location: cords, numberOfResults: self.numberOfLocationWSResult )
                self.requestCurrentLocation = false
                print("attempt a manual update")
                self.startIfAllowed()
                return
            }
            return
        }
        
        if UIApplication.shared.applicationState == .active {
            //  print("Foreground: New Location \((locations.last)!.description)")
        } else {
            print("BACKGROUND: New Location \((locations.last)!.description) \n state: \(UIApplication.shared.applicationState)")
            self.fireWebserviceCall()
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Error")
        self.locationErrorDelegate?.receivedErrorFromLocationManager()
        
    }
    
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        let now = Date()
        let lastPush = UserData.sharedInstance.lastNotificationDate!
        let elapsedTime = Int(now.timeIntervalSince(lastPush as Date))
        print ("Did Pause Location Updates : +\(elapsedTime) - interval is \(UserData.sharedInstance.notificationIntervalInSeconds!)")
    }
    
    
    fileprivate func fireWebserviceCall () {
        if let allowPush =  UserData.sharedInstance.allowPushNotification {
            if allowPush {
                if self.isIntervalTimePassedSinceLastPush(){
                    // createAndFireNotification("Making the WS Call")
                    MyLocationManager.sharedInstance.startFromRunningState()
                    UserData.sharedInstance.lastNotificationDate = Date()
                    RequestManager.sharedInstance.getArticlesByLocation(self, location: self.lastCoordinates!, numberOfResults: 1)
                }
            }
        }
    }
    
    fileprivate func isIntervalTimePassedSinceLastPush() -> Bool{
        
        let now = Date()
        let lastPush = UserData.sharedInstance.lastNotificationDate!
        let elapsedTime = Int(now.timeIntervalSince(lastPush as Date))
        print ("elapsed time : +\(elapsedTime) - interval is \(UserData.sharedInstance.notificationIntervalInSeconds!)")
        print("remaining time running: \(UIApplication.shared.backgroundTimeRemaining)")
        return elapsedTime >= UserData.sharedInstance.notificationIntervalInSeconds! ? true : false
    }
}
/**
 Delagation for the location based Request.
 */
extension MyLocationManager : NetworkDelegation {
    func onRequestFailed(){
        //createAndFireNotification("req failed")
    }
    func onRequestSuccess(_ from: String){
        
        
        let articles = LocationArticleHolder.sharedInstance.articles
        //debug fire
        //createAndFireNotification(LocationArticleResult(title: "", name: "", url: "", distanceStr: "", distanceVal: 10, license: nil))
        if !articles.isEmpty {
            if articles[0].distanceValue < 1000{
                self.createAndFireNotification(articles[0])
            } else {
                //  createAndFireNotification("NOthing found");
            }
        }
        
    }
    
    fileprivate func createAndFireNotification (_ lr : LocationArticleResult){
        Helper.fireNotificationWithInfosFromLocaionResult(lr: lr)
    }
    
    /*fileprivate func createAndFireNotification(_ msg: String){
        
        let calendar = Calendar.init(identifier: Calendar.Identifier.gregorian)
        let currentHour = ((calendar as NSCalendar?)?.component(NSCalendar.Unit.hour, from: Date()))!
        let currentMinute = ((calendar as NSCalendar?)?.component(NSCalendar.Unit.minute, from: Date()))!
        let currentSecond = ((calendar as NSCalendar?)?.component(NSCalendar.Unit.second, from: Date()))!
        
        localNotification.fireDate = Date()
        localNotification.sonndName = UILocalNotificationDefaultSoundName
        localNotification.alertBody = "\(msg) - \(currentHour):\(currentMinute):\(currentSecond)"
        localNotification.timeZone = TimeZone.current
        localNotification.applicationIconBadgeNumber = UIApplication.shared.applicationIconBadgeNumber + 1
        print("previous app badge number: \(UIApplication.shared.applicationIconBadgeNumber)")
        
        UIApplication.shared.scheduleLocalNotification(localNotification)
    }*/
}

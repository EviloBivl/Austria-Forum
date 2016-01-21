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
    var significantChange : Bool = false
    var distanceFilter : Bool = false
    
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
        locationManager.distanceFilter = Double(UserData.sharedInstance.locationChangeValue!)
        locationManager.startUpdatingLocation()
        self.distanceFilter = true
        self.significantChange = false
    }
    
    //if we the app got started from terminated due to localization update
    func startFromTerminated() {
        locationManager.stopUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
        self.significantChange = true
        self.distanceFilter = false
    }
    
    //TODO
    //stop tracking when settings are switched.
    //proper starting of locationservice - depending on which mode we are. and what the user wants
    //handle the correct scheduling of the local Notification - date and distance(distancefilter work)
    //handle if the user declines the alwaysauthorization - if yes we need one time authorization for geetting the nearby articles
    //
    
    func stopTracking() {
        if self.distanceFilter {
            locationManager.stopUpdatingLocation()
        } else if self.significantChange {
            locationManager.stopMonitoringSignificantLocationChanges()
        }
    }
    
    
}


extension MyLocationManager : CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // Add another annotation to the map.
        let calendar = NSCalendar.init(calendarIdentifier: NSCalendarIdentifierGregorian)
        let currentHour = (calendar?.component(NSCalendarUnit.Hour, fromDate: NSDate()))!
        let currentMinute = (calendar?.component(NSCalendarUnit.Minute, fromDate: NSDate()))!
        let currentSecond = (calendar?.component(NSCalendarUnit.Second, fromDate: NSDate()))!
        
        if UIApplication.sharedApplication().applicationState == .Active {
            print("Foreground: New Location \((locations.last)!.description)")
            let date = NSDate()
            localNotification.fireDate = date
            localNotification.alertBody = "Location Update FOREGROUND"
            localNotification.timeZone = NSTimeZone.defaultTimeZone()
            //   UIApplication.sharedApplication().scheduleLocalNotification(self.localNotification)
            
        } else {
            
            localNotification.fireDate = NSDate()
            localNotification.alertBody = "Background \(currentHour):\(currentMinute):\(currentSecond)"
            localNotification.timeZone = NSTimeZone.defaultTimeZone()
            UIApplication.sharedApplication().scheduleLocalNotification(self.localNotification)
            print("BACKGROUND: New Location \((locations.last)!.description)")
            RequestManager.sharedInstance.getArticleFromMonthlyPool()
            
        }
    }
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Location Error")
    }
    
}

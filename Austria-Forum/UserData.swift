//
//  UserData.swift
//  Austria-Forum
//
//  Created by Paul Neuhold on 11.12.15.
//  Copyright © 2015 Paul Neuhold. All rights reserved.
//

import Foundation

/** UserData Class
 
 On creation the class will load all stored Values from the NSUserDefaults into the stored properties of the class
 if you set a property it will also be saved within the NSUserDefaults
 
 */
class UserData : NSObject {
    
    static let sharedInstance = UserData()
    private var userDefaults : NSUserDefaults?
    
    /**
     If you set this property it will also get stored as Object in the NSUserDefaults with the key UserDefaultKeys.kLastVisitedString
     */
    var lastVisitedString : String? = nil {
        didSet{
            if let toSave = self.lastVisitedString {
                self.setValueForKey(toSave, key: UserDefaultKeys.kLastVisitedString)
            }
        }
    }
    
    /**
     If you set this property it will also get stored as Object in the NSUserDefaults with the key UserDefaultKeys.kLastVisitedString
     */
    var optionsOne : String?  = nil {
        didSet{
            if let toSave = self.optionsOne {
                self.setValueForKey(toSave, key: UserDefaultKeys.kOptionOneString)
            }
        }
        
    }
    
    /**
     If we set this property, persist it
     */
    var articleOfTheMonth : String? = nil {
        didSet{
            if let toSave = self.articleOfTheMonth{
                self.persistArticleOfTheMonth(toSave)
            }
        }
    }
    
    private override init(){
        super.init()
        self.userDefaults = NSUserDefaults.standardUserDefaults()
        
        
        //load all saved defaults to save userDefaults access later
        self.loadAllSavedValuesFromUserDefaults()
        
    }
    
    func setValueForKey(value: AnyObject, key: String){
        self.userDefaults?.setObject(value, forKey: key)
    }
    
    func getValueForKey(key: String) -> AnyObject?{
        return self.userDefaults?.objectForKey(key)
    }
    
    func removeValueForKey(key: String) {
        self.userDefaults?.removeObjectForKey(key)
    }
    
    
    private func persistArticleOfTheMonth(article: String) {
        if checkIfArticleOfTheMonthNeedsReload() {
            setValueForKey(article, key: UserDefaultKeys.kArticleOfTheMonthString)
            setValueForKey(NSDate(), key: UserDefaultKeys.kLastMonthOfArticleOfTheMonthNSDate)
        }
    }
    
    func checkIfArticleOfTheMonthNeedsReload () -> Bool{
        let calendar = NSCalendar.init(calendarIdentifier: NSCalendarIdentifierGregorian)
        let currentMonth = (calendar?.component(NSCalendarUnit.Month, fromDate: NSDate()))!
        let currentYear = (calendar?.component(NSCalendarUnit.Year, fromDate: NSDate()))!
        
        if let lastDate = getValueForKey(UserDefaultKeys.kLastMonthOfArticleOfTheMonthNSDate) as? NSDate {
            let lastMonth = (calendar?.component(NSCalendarUnit.Month, fromDate: lastDate))!
            let lastYear = (calendar?.component(NSCalendarUnit.Year, fromDate: lastDate))!
            if lastYear < currentYear {
                return true
            } else {
                if lastMonth < currentMonth {
                    return true
                }
            }
        } else {
            return true
        }
        return false
    }
    
    
    private func loadAllSavedValuesFromUserDefaults () {
        
        self.lastVisitedString = getValueForKey(UserDefaultKeys.kLastVisitedString) as? String
        self.optionsOne = getValueForKey(UserDefaultKeys.kOptionOneString) as? String
        
    }
    
    
    
}



class UserDefaultKeys {
    
    static let kLastVisitedString : String = "kLastVisited"
    static let kOptionOneString :   String = "kOptionOne"
    static let kOptionTwoString :   String = "kOptionTwo"
    static let kOptionThreeBool :   String = "kOptionThreeBool"
    static let kArticleOfTheMonthString: String = "kArticleOfTheMonth"
    static let kLastMonthOfArticleOfTheMonthNSDate: String = "kLastMonthOfArticleOfTheMonth"
    
    
    private init(){
        
    }
    
}



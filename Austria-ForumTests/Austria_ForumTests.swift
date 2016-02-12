//
//  Austria_ForumTests.swift
//  Austria-ForumTests
//
//  Created by Paul Neuhold on 10.12.15.
//  Copyright © 2015 Paul Neuhold. All rights reserved.
//

import XCTest
@testable import Austria_Forum

class Austria_ForumTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    
    func testNSUserDefaultsSaving () {
        //check if setting the properties results in persisting it do the UserDefaults
        UserData.sharedInstance.lastVisitedString = "Something"
        assert(UserData.sharedInstance.getValueForKey(UserDefaultKeys.kLastVisitedString) as! String == "Something", "saving lastVistedString failed")
        
        
        UserData.sharedInstance.removeValueForKey(UserDefaultKeys.kLastMonthOfArticleOfTheMonthNSDate)
        UserData.sharedInstance.removeValueForKey(UserDefaultKeys.kArticleOfTheMonthSearchResult)
        
        if UserData.sharedInstance.checkIfArticleOfTheMonthNeedsReload() {
            assert(true)
        } else {
            //we removed the values so we need to reload - if we are here just fail
            assertionFailure("checkIfArticleOfTheMonthNeedsReload returns false although no values are set")
        }
        let url : String = "http://a.glorious.url"
        UserData.sharedInstance.articleOfTheMonth = url
        assert(UserData.sharedInstance.getValueForKey(UserDefaultKeys.kArticleOfTheMonthSearchResult) as! String == url, "saving articleOfTheMonth failed")
        
        if UserData.sharedInstance.checkIfArticleOfTheMonthNeedsReload(){
            assertionFailure("checkIfArticleOfTheMonthNeedsReload returns true although values are set")
        }
        
        
        UserData.sharedInstance.removeValueForKey(UserDefaultKeys.kFirstTimeStartingAppString)
        if UserData.sharedInstance.checkIfAppStartsTheFirstTime() {
            assert(true)
        } else{
            XCTAssert(false, "this should not be the case, since we have nothing set in the kFirstTimeStartingAppString")
        }
        UserData.sharedInstance.setValueForKey("its set", key: UserDefaultKeys.kFirstTimeStartingAppString)
        if UserData.sharedInstance.checkIfAppStartsTheFirstTime() {
            XCTAssert(false, "kFirstTimeStartingAppString was set, so we shouldn't be here")
        }
        
        
    }
    func testDictionaryExtension () {
        
        let dict : Dictionary = ["12":"12" , "aB!": "aB!" , "abc" : "abc"]
        let dictShorter : Dictionary = ["12":"12" , "aB!": "aB!"]
        let dictTwo = ["12":"12" , "aB!": "aB!" , "abc" : "abC"]
        
        XCTAssert(dict.isEqual(dict), "dict should be equal to it self")
        XCTAssertFalse(dict.isEqual(dictTwo), "dict should not be equal to dictTwo ")
        XCTAssertFalse(dict.isEqual(dictShorter), "dict should not be equal - due to less count")
        
        
        
        
    }
    
    func testComputedProperties () {
        
        XCTAssert(UserData.sharedInstance.optionLocationUpdateInterval == 10)
        UserData.sharedInstance.setValueForKey(15, key: UserDefaultKeys.kOptionLocationUpdateIntervalInt)
        XCTAssert(UserData.sharedInstance.optionLocationUpdateInterval == 15)
        UserData.sharedInstance.optionLocationUpdateInterval = 20
        XCTAssert(UserData.sharedInstance.optionLocationUpdateInterval == 20)
        
    }
    
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}

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
        
        UserData.sharedInstance.optionsOne = "optionOne"
        assert(UserData.sharedInstance.getValueForKey(UserDefaultKeys.kOptionOneString) as! String == "optionOne", "saving optionOne failed")
        
        UserData.sharedInstance.removeValueForKey(UserDefaultKeys.kLastMonthOfArticleOfTheMonthNSDate)
        UserData.sharedInstance.removeValueForKey(UserDefaultKeys.kArticleOfTheMonthString)
        
        if UserData.sharedInstance.checkIfArticleOfTheMonthNeedsReload() {
            assert(true)
        } else {
            //we removed the values so we need to reload - if we are here just fail
            assertionFailure("checkIfArticleOfTheMonthNeedsReload returns false although no values are set")
        }
        let url : String = "http://a.glorious.url"
        UserData.sharedInstance.articleOfTheMonth = url
        assert(UserData.sharedInstance.getValueForKey(UserDefaultKeys.kArticleOfTheMonthString) as! String == url, "saving articleOfTheMonth failed")
        
        if UserData.sharedInstance.checkIfArticleOfTheMonthNeedsReload(){
            assertionFailure("checkIfArticleOfTheMonthNeedsReload returns true although values are set")
        }
        
        
        
        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}

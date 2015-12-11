//
//  StartViewController.swift
//  Austria-Forum
//
//  Created by Paul Neuhold on 10.12.15.
//  Copyright © 2015 Paul Neuhold. All rights reserved.
//

import Foundation
import UIKit
import Crashlytics


class StartViewController: UIViewController {
    
    
    // MARK: - Properties
    var detailViewController: DetailViewController? = nil
    
    
    
    // MARK: - Override Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        print("starting the requests now")
        startRequestTesting()
        

        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Custom Functions
    
    func startRequestTesting() {
        
        RequestManager.sharedInstance.getArticleFromMonthlyPool(self)
        RequestManager.sharedInstance.getArticleFromMonthlyPool(self, month: "November", year: "2015")
        RequestManager.sharedInstance.getRandomArticle()
        RequestManager.sharedInstance.findPages(self, query: "Tesla", numberOfMaxResults: 2)
       
        
    }

    
}
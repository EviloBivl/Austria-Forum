//
//  MasterViewController.swift
//  Austria-Forum
//
//  Created by Paul Neuhold on 10.12.15.
//  Copyright © 2015 Paul Neuhold. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController  {

    
    // MARK: - Properties
    
    
    // MARK: - Override Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    // MARK - UITableView
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return 10
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : UITableViewCell = tableView.dequeueReusableCellWithIdentifier("Cell",forIndexPath: indexPath) as UITableViewCell
        
        return cell
    }



}


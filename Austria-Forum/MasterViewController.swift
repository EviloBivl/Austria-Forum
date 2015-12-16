//
//  MasterViewController.swift
//  Austria-Forum
//
//  Created by Paul Neuhold on 10.12.15.
//  Copyright © 2015 Paul Neuhold. All rights reserved.
//

import UIKit
import CoreData
import Fabric
import Crashlytics


protocol ArticleSelectionDelegate {
    func articleSelected(article: SearchResult);
}

class MasterViewController: UITableViewController, NetworkDelegation, UISearchBarDelegate  {
    
    
    // MARK: - Properties
    var myData : Array<String>= []
    var delegate: ArticleSelectionDelegate?
    
    @IBOutlet var searchBar: UITableView!
    // MARK: - Override Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchBar.delegate = self
       
      //  startRequestTesting()
      //  Answers.logContentViewWithName("MasterViewController", contentType: "Data", contentId: "1234", customAttributes: ["Favorites Count":20, "Screen Orientation":"Landscape"])

        
        
    
        
        
        
        // TODO: Track the user action that is important for you.
   
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Custom Functions
    
    func startRequestTesting() {
        
        //    RequestManager.sharedInstance.getArticleFromMonthlyPool(self)
        //    RequestManager.sharedInstance.getArticleFromMonthlyPool(self, month: "November", year: "2015")
        //    RequestManager.sharedInstance.getRandomArticle()
        RequestManager.sharedInstance.findPages(self, query: "Tesla", numberOfMaxResults: 20)
        
        
    }
    
    // MARK: - UITableView
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return myData.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : UITableViewCell = tableView.dequeueReusableCellWithIdentifier("Cell",forIndexPath: indexPath) as UITableViewCell
        cell.textLabel?.text = myData[indexPath.row]
        
        return cell
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedArticle : SearchResult = SearchHolder.sharedInstance.searchResults[indexPath.row]
        SearchHolder.sharedInstance.selectedItem = selectedArticle
   
    }
    
    //MARK: - Protocol Implementation
    
    func onRequestFailed(){
        
    }
    
    
    func onRequestSuccess(){
        print("appending to tableview")
      
        //delete previous results
        dispatch_async(dispatch_get_main_queue(), {
            self.myData.removeAll()
            self.tableView.reloadData()
        })
        
        
        //add new results
        dispatch_async(dispatch_get_main_queue()) {
            for result in SearchHolder.sharedInstance.searchResults {
                self.myData.append(result.title)
                let indexPath = NSIndexPath(forRow: self.myData.count - 1, inSection: 0)
                self.tableView.beginUpdates()
                self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
                self.tableView.endUpdates()
             }
        }
        
    }
    
    
    //MARK: - SearchBar Delegate
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String){
        print("searchBar chenged text to: \(searchText)")
        RequestManager.sharedInstance.findPages(self, query: searchText, numberOfMaxResults: 20)
        
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    
    
    
    
}


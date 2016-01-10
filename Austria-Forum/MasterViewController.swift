//
//  MasterViewController.swift
//  Austria-Forum
//
//  Created by Paul Neuhold on 10.12.15.
//  Copyright © 2015 Paul Neuhold. All rights reserved.
//


/* 

Stuff to think about -
Track users search words or better track the selected Article after searching with crashlytics ?

*/

import UIKit
import CoreData
import Fabric
import Crashlytics


protocol ArticleSelectionDelegate {
    func articleSelected(article: SearchResult);
}

class SearchTableViewController: UITableViewController, NetworkDelegation, UISearchResultsUpdating, UISearchBarDelegate  {
    
    
    // MARK: - Properties
    var myData : Array<String>= []
    var categories : Array<String> = []
    var delegate: ArticleSelectionDelegate?
    let searchController = UISearchController(searchResultsController: nil)
    
    
    // MARK: - Override Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
      //  startRequestTesting()
      //  Answers.logContentViewWithName("MasterViewController", contentType: "Data", contentId: "1234", customAttributes: ["Favorites Count":20, "Screen Orientation":"Landscape"])

        //set up searchcontroller properties and delegates
        self.searchController.searchResultsUpdater = self
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.searchBar.delegate = self
       
        
        self.definesPresentationContext = true
        
        
        tableView.tableHeaderView = searchController.searchBar
        
        //Register Custom Cell
        let nib = UINib(nibName: "afTableCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: "afTableCell")
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews() {
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.hidesBottomBarWhenPushed = false
        super.viewWillLayoutSubviews()
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
       
        let afCell : afTableViewCell = tableView.dequeueReusableCellWithIdentifier("afTableCell") as! afTableViewCell
        afCell.lTitleNameTVC.text = myData[indexPath.row]
        afCell.lCategoryNameTVC.text = categories[indexPath.row]
        
        return afCell
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedArticle : SearchResult = SearchHolder.sharedInstance.searchResults[indexPath.row]
        SearchHolder.sharedInstance.selectedItem = selectedArticle
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    //MARK: - Protocol Implementation
    
    func onRequestFailed(){
        
    }
    
    
    func onRequestSuccess(){
        print("appending to tableview")
      
        //delete previous results
        dispatch_async(dispatch_get_main_queue(), {
            self.myData.removeAll()
            self.categories.removeAll()
            self.tableView.reloadData()
        })
        
        
        //add new results
        dispatch_async(dispatch_get_main_queue()) {
            
            
            for result in SearchHolder.sharedInstance.searchResults {
                self.categories.append("\(result.score) - TODO: change af webservice to get Category")
                self.myData.append(result.title)
                let indexPath = NSIndexPath(forRow: self.myData.count - 1, inSection: 0)
                self.tableView.beginUpdates()
                self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
                self.tableView.endUpdates()
             }
            
        }
        
    }
    
    
    //MARK: - UISearchResultsUpdating
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        print("Searchbar update with text \(searchController.searchBar.text!)");
        RequestManager.sharedInstance.findPages(self, query: searchController.searchBar.text!, numberOfMaxResults: 4)
        
    }
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
//        if self.respondsToSelector("edgesForExtendedLayout"){
//            self.edgesForExtendedLayout = UIRectEdge.None
//        }
    }
    
    
    
}

//MARK: Extension
extension SearchTableViewController
: ReachabilityDelegate {
    func noInternet() {
        
    }
}




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
    var noInternetView : LoadingScreen?
    
    
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
        self.tableView.rowHeight = 60
        
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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //Always set the current controller as the delegate to ReachabilityHelper
        ReachabilityHelper.sharedInstance.delegate = self
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
    
    func onRequestFailed(from: String?){
        
    }
    
    
    func onRequestSuccess(from: String?){
        print("appending to tableview")
      
        //delete previous results
        dispatch_async(dispatch_get_main_queue(), {
            self.myData.removeAll()
            self.categories.removeAll()
            
            for result in SearchHolder.sharedInstance.searchResults {
                self.categories.append(CategoriesListed.GetBeautyCategoryFromUrlString(result.url))
                self.myData.append(result.title)
            }
            
            self.tableView.reloadData()
        })
        
        /*
        //add new results
        dispatch_async(dispatch_get_main_queue()) {
            
            
            for result in SearchHolder.sharedInstance.searchResults {
                self.categories.append(CategoriesListed.GetBeautyCategoryFromUrlString(result.url))
                self.myData.append(result.title)
                let indexPath = NSIndexPath(forRow: self.myData.count - 1, inSection: 0)
                self.tableView.beginUpdates()
                self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
                self.tableView.endUpdates()
             }
            
        }
*/
        
    }
    
    
    //MARK: - UISearchResultsUpdating
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        print("Searchbar update with text \(searchController.searchBar.text!)");
        RequestManager.sharedInstance.findPages(self, query: searchController.searchBar.text!, numberOfMaxResults: 50)
        
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
        
        self.noInternetView = NSBundle.mainBundle().loadNibNamed("LoadingScreen", owner: self, options: nil)[0] as? LoadingScreen
        self.noInternetView?.frame = self.view.frame
        self.noInternetView?.frame.origin.y  -= 100
        self.noInternetView?.tag = 99
      
        if let v = self.noInternetView {
            
            v.labelMessage.text = "Bitte überprüfen Sie ihre Internetverbindung."
            self.view.addSubview(v)
            v.bringSubviewToFront(self.view)
            v.activityIndicator.startAnimating()
            v.viewLoadingHolder.backgroundColor = UIColor(white: 0.4, alpha: 0.9)
            v.viewLoadingHolder.layer.cornerRadius = 5
            v.viewLoadingHolder.layer.masksToBounds = true;
            print("added no Internet Notification")
        }
        self.performSelector("hideNoInternetView", withObject: self, afterDelay: 1)
    }
    
    func hideNoInternetView(){
        print("hided no internet notification")
        for v in self.view.subviews {
            if v.tag == 99{
                v.removeFromSuperview()
            }
        }
    }
    
    func InternetBack() {
        hideNoInternetView()
    }

}




//
//  MasterViewController.swift
//  Austria-Forum
//
//  Created by Paul Neuhold on 10.12.15.
//  Copyright © 2015 Paul Neuhold. All rights reserved.
//

import UIKit

protocol ArticleSelectionDelegate {
    func articleSelected(_ article: SearchResult);
}

class SearchTableViewController: UITableViewController, NetworkDelegation, UISearchResultsUpdating, UISearchBarDelegate  {
    
    // MARK: - Properties
    var myData : Array<String> = []
    var categories : Array<String> = []
    var delegate: ArticleSelectionDelegate?
    let searchController = UISearchController(searchResultsController: nil)
    var viewModel: SearchViewModel?
    
    class func create(viewModel: SearchViewModel) -> SearchTableViewController {
        let controller = StoryboardScene.SearchViewController.searchTableViewController.instantiate()
        controller.viewModel = viewModel
        return controller
    }
    
    
    // MARK: - Override Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
      //  startRequestTesting()
        //set up searchcontroller properties and delegates
        self.searchController.searchResultsUpdater = self
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.searchBar.delegate = self
        self.tableView.tableFooterView = UIView()
       
        
        self.definesPresentationContext = true
        
        
        tableView.tableHeaderView = searchController.searchBar
        
        //Register Custom Cell
        let nib = UINib(nibName: "afTableCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "afTableCell")
        self.tableView.rowHeight = UITableView.automaticDimension
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //Always set the current controller as the delegate to ReachabilityHelper
        ReachabilityHelper.sharedInstance.delegate = self
    }
    
    
   
    // MARK: - UITableView
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return myData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let afCell : afTableViewCell = tableView.dequeueReusableCell(withIdentifier: "afTableCell") as! afTableViewCell
        afCell.lTitleNameTVC.text = myData[(indexPath as NSIndexPath).row]
        afCell.lCategoryNameTVC.text = categories[(indexPath as NSIndexPath).row]
        
        return afCell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedArticle : SearchResult = SearchHolder.sharedInstance.searchResults[(indexPath as NSIndexPath).row]
        SearchHolder.sharedInstance.selectedItem = selectedArticle
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Protocol Implementation
    
    func onRequestFailed(){
        
    }
    
    
    func onRequestSuccess(_ from: String){
        print("appending to tableview")
      
        //delete previous results
        DispatchQueue.main.async(execute: {
            self.myData.removeAll()
            self.categories.removeAll()
            
            for result in SearchHolder.sharedInstance.searchResults {
                self.categories.append(CategoriesListed.GetBeautyCategoryFromUrlString(result.url))
                self.myData.append(result.title ?? "")
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
    func updateSearchResults(for searchController: UISearchController) {
        print("Searchbar update with text \(searchController.searchBar.text!)");
        RequestManager.sharedInstance.findPages(self, query: searchController.searchBar.text!, numberOfMaxResults: 50)
        
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
//        if self.respondsToSelector("edgesForExtendedLayout"){
//            self.edgesForExtendedLayout = UIRectEdge.None
//        }
    }
    
    
    
}

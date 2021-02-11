//
//  LocationArticlesViewController.swift
//  Austria-Forum
//
//  Created by Paul Neuhold Privat on 02.02.20.
//  Copyright © 2020 Paul Neuhold. All rights reserved.
//

import Foundation
import UIKit

protocol LocationArticlesViewControllerDelegate: class {
    func signalUpdate()
}

class LocationArticlesViewController: UITableViewController {
   
    var viewModel: LocationArticlesViewModel?
    var locationRequestHelper: LocationRequestHelper?
    
    class func create(viewModel: LocationArticlesViewModel) -> LocationArticlesViewController {
        let controller = StoryboardScene.LocationArticlesViewController.locationArticlesViewController.instantiate()
        controller.viewModel = viewModel
        controller.viewModel?.delegate = controller
        return controller
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
       
    private func setupUI(){
        let nib = UINib(nibName: afLocationTableViewCell.xibName, bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: afLocationTableViewCell.xibName)
        tableView.tableFooterView = UIView()
        
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableView.automaticDimension
        self.navigationController?.isNavigationBarHidden = false
        self.locationRequestHelper = LocationRequestHelper(executingController: self)
        if let willShow = locationRequestHelper?.showGPSPopover(), !willShow {
            viewModel?.loadData()
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: afLocationTableViewCell.xibName, for: indexPath) as? afLocationTableViewCell else { return UITableViewCell() }
        cell.content = viewModel?.content(at: indexPath)
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel?.numberOfSections ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.numberOfRows(for: section) ?? 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard LocationArticleHolder.sharedInstance.articles.indices.contains(indexPath.row) else { return }
        let item = LocationArticleHolder.sharedInstance.articles[indexPath.row]
        SearchHolder.sharedInstance.selectedItem = SearchResult(title: item.title,
                                                                name: item.name,
                                                                url: item.url,
                                                                score: 100,
                                                                licenseResult: item.licenseResult)
        self.navigationController?.popViewController(animated: true)
    }
}

extension LocationArticlesViewController: LocationArticlesViewControllerDelegate {
    
    func signalUpdate() {
        guard let viewModel = viewModel else { return }
        
        if viewModel.isLoading {
            showLoadingScreen(withGracePeriod: false)
        } else {
            hideLoadingScreen()
        }
        tableView.reloadData()
    }
}

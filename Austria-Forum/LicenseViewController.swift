//
//  LicenseViewController.swift
//  Cashback
//
//  Created by Paul Neuhold on 19.03.19.
//  Copyright © 2019 myWorld Solutions AG. All rights reserved.
//

import UIKit

class LicenseViewController: UITableViewController  {
    //MARK: - Properties
    var viewModel: LicenseViewModel?
    
    //MARK: - Factory Method
    class func create(viewModel: LicenseViewModel) -> LicenseViewController {
        let controller = StoryboardScene.LibLicenses.licenseViewController.instantiate()
        controller.viewModel = viewModel
         return controller
    }
    
    //MARK: - LifeCycle
    override func viewDidLoad(){
        super.viewDidLoad()
        setupUI()
    }
    
    
    
    //MARK: - private Functions
    private func setupUI(){
        let nib = UINib(nibName: LibLicenseCell.xibName, bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: LibLicenseCell.xibName)
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = UITableView.automaticDimension
        tableView.sectionHeaderHeight = 30
        title = "Lizenzen"
    }
    
    func didUpdate() {
        
    }
    
    //MARK: - UITableViewDataSource & Delegate
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel?.numberOfSections ?? 0
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.numberOfRows(for: section) ?? 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let license = viewModel?.license(for: IndexPath(row: 0, section: section)) else { return nil }
        return license.title
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LibLicenseCell.xibName, for: indexPath) as? LibLicenseCell,
            let license = viewModel?.license(for: indexPath) else { return UITableViewCell() }
        
        cell.content = LibLicenseCell.Content(license: license.licenseText, footerText: license.footerText)
        
        
        return cell
    }
    
}

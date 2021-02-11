//
//  LicenseViewModel.swift
//  Cashback
//
//  Created by Paul Neuhold on 19.03.19.
//  Copyright © 2019 myWorld Solutions AG. All rights reserved.
//

import UIKit


class LicenseViewModel {
    
    var licenses: [LibLicense] = [LibLicense]()
    
    enum CellType {
        case license
    }
    
    init() {
        if let licCashback = LibLicenses(plistFile: "afUsedLibsLicenses"), let lic = licCashback.licensesList {
            licenses.append(contentsOf: lic)
        }
    }
    
    //MARK: - UITableViewDataSource
    var numberOfSections : Int {
        return licenses.count
    }
    
    func numberOfRows(for section: Int) -> Int? {
        return 1
    }
    
    func license(for indexPath: IndexPath) -> LibLicense? {
        guard licenses.indices.contains(indexPath.section) else { return nil }
        return licenses[indexPath.section]
    }
    
    func cellType(for indexPath: IndexPath) -> CellType? {
        return nil
    }
}

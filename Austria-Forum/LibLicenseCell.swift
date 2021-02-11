//
//  LicenseCell.swift
//  Cashback
//
//  Created by Paul Neuhold on 19.03.19.
//  Copyright © 2019 myWorld Solutions AG. All rights reserved.
//

import UIKit

class LibLicenseCell: UITableViewCell {
    static let xibName: String = "LibLicenseCell"
    
    @IBOutlet weak var licenseName: UILabel!
    @IBOutlet weak var licenseText: UILabel!
    
    struct Content {
        let license: String?
        let footerText: String?
    }
    
    var content: Content? {
        didSet {
            updateUI()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        applyColorTheme()
    }
    
    private func setupUI(){
        licenseName.font = UIFont(name: "CourierNewPSMT", size: 15)
        licenseText.font = UIFont(name: "CourierNewPSMT", size: 10)
        licenseText.numberOfLines = 0
    }
    
    private func applyColorTheme(){
        licenseName.textColor = .black
        licenseText.textColor = .black
    }
    
    private func updateUI(){
        guard let content = content else { return }
        licenseName.text = content.license
        licenseText.text = content.footerText
    }
}

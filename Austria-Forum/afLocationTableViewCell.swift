//
//  afLocationTableViewCell.swift
//  Austria-Forum
//
//  Created by Paul Neuhold on 22.01.16.
//  Copyright © 2016 Paul Neuhold. All rights reserved.
//

import UIKit

class afLocationTableViewCell: UITableViewCell {
    static let xibName: String = "afLocationTableViewCell"
    
    
    @IBOutlet weak var labelTitel: UILabel!
    @IBOutlet weak var labelCategory: UILabel!
    @IBOutlet weak var labelDistance: UILabel!
    @IBOutlet weak var ivResult: UIImageView!
    
    struct Content {
        var title: String
        var category: String
        var distance: String
        var url: String
    }
    
    var content: Content? {
        didSet {
            updateUI()
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.labelTitel.text = ""
        self.labelCategory.text = ""
        self.labelDistance.text = ""
    }

    private func updateUI(){
        guard let content = content else { return }
        self.labelTitel.text = content.title
        self.labelCategory.text = content.category
        self.labelDistance.text = content.distance
    }

}

//
//  afTableCellTableViewCell.swift
//  Austria-Forum
//
//  Created by Paul Neuhold on 04.01.16.
//  Copyright © 2016 Paul Neuhold. All rights reserved.
//

import UIKit

class afTableViewCell: UITableViewCell {

    @IBOutlet weak var lTitleTVC: UILabel!
    @IBOutlet weak var lTitleNameTVC: UILabel!
    @IBOutlet weak var lCategoryTVC: UILabel!
    @IBOutlet weak var lCategoryNameTVC: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    

}

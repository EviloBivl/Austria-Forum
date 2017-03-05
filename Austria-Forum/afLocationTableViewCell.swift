//
//  afLocationTableViewCell.swift
//  Austria-Forum
//
//  Created by Paul Neuhold on 22.01.16.
//  Copyright © 2016 Paul Neuhold. All rights reserved.
//

import UIKit

class afLocationTableViewCell: UITableViewCell {

    @IBOutlet weak var labelTitel: UILabel!
    @IBOutlet weak var labelCategory: UILabel!
    @IBOutlet weak var labelDistance: UILabel!
    @IBOutlet weak var ivResult: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.labelTitel.text = ""
        self.labelCategory.text = ""
        self.labelDistance.text = ""
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

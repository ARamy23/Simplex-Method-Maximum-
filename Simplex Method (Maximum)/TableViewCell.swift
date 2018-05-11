//
//  TableViewCell.swift
//  Simplex Method (Maximum)
//
//  Created by Ahmed Ramy on 5/7/18.
//  Copyright © 2018 Ahmed Ramy. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var constraintEquationTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

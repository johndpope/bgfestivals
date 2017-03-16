//
//  RightTextFieldTableViewCell.swift
//  bgfestivals
//
//  Created by Gabriela Zagarova on 3/13/17.
//  Copyright © 2017 Gabriela Zagarova. All rights reserved.
//

import UIKit

class RightTextFieldTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.textField.placeholder = Date().toString()
    }
    
}

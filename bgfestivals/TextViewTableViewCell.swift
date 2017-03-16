//
//  TextViewTableViewCell.swift
//  bgfestivals
//
//  Created by Gabriela Zagarova on 3/13/17.
//  Copyright © 2017 Gabriela Zagarova. All rights reserved.
//

import UIKit

class TextViewTableViewCell: UITableViewCell {

    @IBOutlet weak var textView: UITextView!
    var placeholderText: String? = nil {
        didSet {
            if let placeholderText = placeholderText {
                textView.text = placeholderText
            }
        }
    }

}

//
//  DatePickerTableViewCell.swift
//  bgfestivals
//
//  Created by Gabriela Zagarova on 3/13/17.
//  Copyright © 2017 Gabriela Zagarova. All rights reserved.
//

import UIKit

protocol DatePickerTableViewCellDelegate: class {
    func datePickerDidChangeValue(datePicker: UIDatePicker, cell: DatePickerTableViewCell)
}

class DatePickerTableViewCell: UITableViewCell {

    @IBOutlet weak var datePicker: UIDatePicker!

    weak var delegate: DatePickerTableViewCellDelegate?
    
    // MARK: Actions
    
    @IBAction func datePickerValueChange(_ sender: Any) {
        delegate?.datePickerDidChangeValue(datePicker: datePicker, cell: self)
    }
    
}

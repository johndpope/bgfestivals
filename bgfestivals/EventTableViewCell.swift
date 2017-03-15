//
//  EventTableViewCell.swift
//  bgfestivals
//
//  Created by Gabriela Zagarova on 3/14/17.
//  Copyright © 2017 Gabriela Zagarova. All rights reserved.
//

import UIKit

class EventTableViewCell: UITableViewCell {

    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var eventDateLabel: UILabel!
    @IBOutlet weak var eventDescriptionTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    func configure(evnt: Event) {

        
    }

}

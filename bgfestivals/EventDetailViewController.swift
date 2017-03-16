//
//  EventDetailViewController.swift
//  bgfestivals
//
//  Created by Gabriela Zagarova on 3/12/17.
//  Copyright © 2017 Gabriela Zagarova. All rights reserved.
//

import UIKit

let minHeaderViewHeight: CGFloat = 170
let maxHeaderViewHeight: CGFloat = 340
let defaultCellHeight: CGFloat = 216
let mainAppColor: UIColor = .red

enum EventDetailSection: Int {
    case startDate
    case endDate
//    case contact
    case eventDescription
}

class EventDetailViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var secondTextField: UITextField!
    @IBOutlet weak var headerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var footerToolBar: UIToolbar!
    @IBOutlet weak var footerButton: UIBarButtonItem!
    
    var currentEvent: Event?
    var editMode: Bool?

    fileprivate var datePickerIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if editMode == true {
            footerButton.title = "Create"
            footerButton.tintColor = .mainApp()
        } else {
            footerButton.title = "Delete"
            footerButton.tintColor = .red
        }
        configureTableView()
    }

    func configureTableView() {
        tableView.estimatedRowHeight = defaultCellHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableHeaderView = headerView
        
        guard let event = currentEvent else {
            return;
        }
        textField.text = event.title
        secondTextField.text = event.location
        if let imageURLString = event.imageURL {
            imageView.downloadedFrom(link: imageURLString)
        }
    }
    
    // MARK: Actions
    
    @IBAction func footerButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func shareButtonPressed(_ sender: Any) {
    
    }
    
    override var previewActionItems: [UIPreviewActionItem] {
        let share = UIPreviewAction(title: "Share", style: .default) { (action, viewController) in
            (viewController as! EventDetailViewController).shareEvent()
        }
        return [share]
    }
        
    
    // MARK: Private actions
    
    func deleteEvent() {
        
    }
    
    func saveEvent() {
        
    }
    
    func shareEvent() {
        
    }
    
    func addEventToGoingList() {
        
    }
    
    func putRatingToEvent(rating: Double) {
        
    }
    
}

extension EventDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let datePickerIndexPath = datePickerIndexPath,
            let editMode = editMode,
            ((section == EventDetailSection.startDate.rawValue || section == EventDetailSection.endDate.rawValue) &&
            editMode && datePickerIndexPath.section == section) {
            return 2
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath.row == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: DatePickerTableViewCell.self)) as! DatePickerTableViewCell
            cell.delegate = self
            return cell
        }
        
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RightTextFieldTableViewCell.self)) as! RightTextFieldTableViewCell
            cell.titleLabel.text = "Start Date"
            if let event = currentEvent {
                cell.textField.text = (event.startDate as! Date).toString()
            }
            cell.textField.isUserInteractionEnabled = false
            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RightTextFieldTableViewCell.self)) as! RightTextFieldTableViewCell
            cell.titleLabel.text = "End Date"
            if let event = currentEvent {
                cell.textField.text = (event.endDate as! Date).toString()
            }
            cell.textField.isUserInteractionEnabled = false
            return cell
        
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TextViewTableViewCell.self)) as! TextViewTableViewCell
            if let event = currentEvent {
                cell.textView.text = event.eventDescription
                cell.placeholderText = nil
            } else {
                cell.placeholderText = "Add description for your event here"
            }
            cell.textView.delegate = self
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.endEditing(true)
        tableView.deselectRow(at: indexPath, animated: true)
        
        let indexPathCopy = datePickerIndexPath
       
        if ((indexPath.section == EventDetailSection.startDate.rawValue || indexPath.section == EventDetailSection.endDate.rawValue) && editMode!) {
            
            datePickerIndexPath = IndexPath(row: 1, section: indexPath.section)
            tableView.beginUpdates()
            
            if let oldIndexPath = indexPathCopy {
                tableView.deleteRows(at: [oldIndexPath], with: .automatic)
            }
            
            if let newPickerIndexPath = datePickerIndexPath, indexPathCopy?.section != datePickerIndexPath?.section {
                tableView.insertRows(at: [newPickerIndexPath], with: .automatic)
            }
            datePickerIndexPath = indexPathCopy?.section == datePickerIndexPath?.section ? nil : datePickerIndexPath
            
            tableView .endUpdates()

        } else {
            datePickerIndexPath = nil
        }
    }
}

extension EventDetailViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let originalHeight = minHeaderViewHeight
        var newHeight = originalHeight - tableView.contentOffset.y - tableView.contentInset.top
        newHeight = newHeight > maxHeaderViewHeight ? maxHeaderViewHeight : newHeight
        newHeight = newHeight < minHeaderViewHeight ? minHeaderViewHeight : newHeight
        
        headerViewHeightConstraint.constant = newHeight
        self.view.layoutIfNeeded()
    }
}

extension EventDetailViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return false
    }
}

extension EventDetailViewController: UIToolbarDelegate {
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .bottom
    }
}

extension EventDetailViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        let currentOffset = tableView.contentOffset
        UIView.setAnimationsEnabled(false)
        tableView.beginUpdates()
        tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
        tableView.setContentOffset(currentOffset, animated: false)
    }
}

extension EventDetailViewController: DatePickerTableViewCellDelegate {
    
    func datePickerDidChangeValue(datePicker: UIDatePicker, cell: DatePickerTableViewCell) {
        if let cellIndxPath = tableView.indexPath(for: cell) {
            let labelIndexPath = IndexPath(row: 0, section: cellIndxPath.section)
            if let labelCell = tableView.cellForRow(at: labelIndexPath) as? RightTextFieldTableViewCell {
                labelCell.textField.text = String(describing: datePicker.date)
            }
        }
    }
}

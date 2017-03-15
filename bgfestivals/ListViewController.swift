//
//  ListViewController.swift
//  bgfestivals
//
//  Created by Gabriela Zagarova on 3/12/17.
//  Copyright © 2017 Gabriela Zagarova. All rights reserved.
//

import UIKit

let showEventSegueIdentifier = "ShowEventSegueIdentifier"

enum ListFilterType: Int {
    case all
    case mine
    case attend
    
    func title() -> String {
        switch self {
        case .mine:
            return "Mine Events"
        case .attend:
            return "Will Visit"
        default:
            return "All Events"
        }
    }
}

class ListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var headerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigation()
        configureTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showEventSegueIdentifier {
            if let destination = segue.destination as? EventDetailViewController {
                if sender is UIBarButtonItem {
                    destination.editMode = true
                } else {
                    destination.editMode = false
                }
            }
        }
    }
    
    // MARK: Actions
    
    @IBAction func filterSegmentValueChanged(_ sender: Any) {
        let listType = ListFilterType(rawValue: segmentControl.selectedSegmentIndex)
        self.navigationItem.title = listType?.title()
        tableView.reloadData()
    }
    
    @IBAction func addEventButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: showEventSegueIdentifier, sender: sender)
    }
    
    // MARK: Private
    
    func configureNavigation() {
        segmentControl.tintColor = UIColor.mainApp()
        navigationController!.navigationBar.isTranslucent = false
        navigationController!.navigationBar.shadowImage = #imageLiteral(resourceName: "TransparentPixel")
        navigationController!.navigationBar.setBackgroundImage(#imageLiteral(resourceName: "Pixel"), for: .default)
    }
    
    func configureTableView() {
        tableView.estimatedRowHeight = 110
        tableView.rowHeight = UITableViewAutomaticDimension
    }
}

extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let type = ListFilterType(rawValue: segmentControl.selectedSegmentIndex) else {
            return 0
        }
        
        switch type {
        case .mine:
            return 2
        case .attend:
            return 5
        default:
            if let events = DataManager.sharedInstance.allEvents() {
                return events.count
            }
            
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: EventTableViewCell.self)) as! EventTableViewCell
        cell.eventDateLabel?.text = "detail \(indexPath.row.description)"
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: showEventSegueIdentifier, sender: nil)
    }
}

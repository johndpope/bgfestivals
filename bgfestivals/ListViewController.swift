//
//  ListViewController.swift
//  bgfestivals
//
//  Created by Gabriela Zagarova on 3/12/17.
//  Copyright © 2017 Gabriela Zagarova. All rights reserved.
//

import UIKit
import CoreData

let showEventSegueIdentifier = "ShowEventSegueIdentifier"

enum ListFilterType: Int {
    case all
    case going
    
    func title() -> String {
        switch self {
        case .going:
            return "Going"
        default:
            return "All Events"
        }
    }
}

class ListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var headerView: UIView!
    
    fileprivate var eventsFetchedResultsController = DataManager.sharedInstance.eventsFetchedResultsController
    fileprivate var currentEventList: [Event]? {
        guard let allEvents = eventsFetchedResultsController?.fetchedObjects else {
            return nil
        }
        if (segmentControl.selectedSegmentIndex == 1) {
            return allEvents.filter{$0.isSelected}
        } else {
            return allEvents
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigation()
        configureTableView()
        loadData()
        
        registerForPreviewing(with: self, sourceView: tableView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: Actions
    
    @IBAction func filterSegmentValueChanged(_ sender: Any) {
        let listType = ListFilterType(rawValue: segmentControl.selectedSegmentIndex)
        self.navigationItem.title = listType?.title()
        tableView.reloadData()
    }
    
    @IBAction func addEventButtonPressed(_ sender: Any) {
        if let eventDetailViewController = EventDetailViewController.detailViewController(event: nil) {
            show(eventDetailViewController, sender: nil)
        }
    }
    
    // MARK: Private
    
    fileprivate func configureNavigation() {
        segmentControl.tintColor = UIColor.mainApp()
        navigationController!.navigationBar.isTranslucent = false
        navigationController!.navigationBar.shadowImage = #imageLiteral(resourceName: "TransparentPixel")
        navigationController!.navigationBar.setBackgroundImage(#imageLiteral(resourceName: "Pixel"), for: .default)
    }
    
    fileprivate func configureTableView() {
        tableView.estimatedRowHeight = 110
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tintColor = UIColor.mainApp()
    }
    
    fileprivate func loadData() {
        do {
            try self.eventsFetchedResultsController?.performFetch()
        } catch let error {
            print("Fail to fecth events \(error).")
        }
    }
    
}

extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let allEvents = currentEventList else {
            return 0
        }
    
        return allEvents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: EventTableViewCell.self)) as! EventTableViewCell
        if let allEvents = currentEventList {
            let event = allEvents[indexPath.row]
            cell.configure(with: event)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if let allEvents = currentEventList {
            let event = allEvents[indexPath.row]
            if let eventDetailViewController = EventDetailViewController.detailViewController(event: event) {
                show(eventDetailViewController, sender: nil)
            }
        }
    }
    
}

extension ListViewController: UIViewControllerPreviewingDelegate {
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        
        (viewControllerToCommit as! EventDetailViewController).isPreviewed = false
        show(viewControllerToCommit, sender: nil)
    
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
       
        guard let indexPath = tableView.indexPathForRow(at: location), let allEvents = currentEventList  else {
            return nil
        }

        let event = allEvents[indexPath.row]
        if let eventDetailViewController = EventDetailViewController.detailViewController(event: event) {
            let cellRect = tableView.rectForRow(at: indexPath)
            let sourceRect = previewingContext.sourceView.convert(cellRect, from: tableView)
            previewingContext.sourceRect = sourceRect
            eventDetailViewController.isPreviewed = true
            
            return eventDetailViewController
        }

        return nil
    }
    
    
}

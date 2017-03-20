//
//  DataManager.swift
//  bgfestivals
//
//  Created by Gabriela Zagarova on 3/12/17.
//  Copyright © 2017 Gabriela Zagarova. All rights reserved.
//

import UIKit
import CoreData


class DataManager: NSObject {
    
    static let sharedInstance = DataManager()

    lazy var viewContext: NSManagedObjectContext = {
        return self.persistentContainer.viewContext
    }()
    
    func syncEvents() {
        let bundle = Bundle(for: type(of: self))
        if let fileURL = bundle.url(forResource: "eventsList", withExtension: "json") {
            do {
                let data = try Data(contentsOf: fileURL)
                if let parsedData = try? JSONSerialization.jsonObject(with: data) as! [String: AnyObject],
                    
                    let lastUpdateDateString = parsedData["lastUpdate"] as? String,
                    let events = parsedData["events"] as? [[String: AnyObject]] {
                    
                    //If no data or ..
                    if let lastUpdateDate = Date.dateFormatterWithTime().date(from: lastUpdateDateString),
                        Date().compare(lastUpdateDate) == ComparisonResult.orderedDescending,
                        DataManager.sharedInstance.topThreeEvents == nil {
                        //Delete old events
                        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Event")
                        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                        
                        // Read new events from file
                        do {
                            try viewContext.persistentStoreCoordinator?.execute(deleteRequest, with: viewContext)
                            _ = saveNewEvents(from: events)
                        } catch let error as NSError {
                            print(error)
                        }
                    }
                }
            } catch {
                print(error)
            }
        }
    }

    
    var eventsFetchedResultsController: NSFetchedResultsController<Event>? {
        let fetchRequest = NSFetchRequest<Event>(entityName: "Event")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: true)]
        fetchRequest.fetchBatchSize = 20;
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataManager.sharedInstance.viewContext, sectionNameKeyPath: "isSelected", cacheName: "events")
        return fetchedResultsController
    }
    
    var topThreeEvents: [Event]? {
        guard let fetchedResultsController = DataManager.sharedInstance.eventsFetchedResultsController else {
            return nil
        }
        do {
            try fetchedResultsController.performFetch()
            if let allEvents = fetchedResultsController.fetchedObjects {
                let selected = (allEvents as [Event]).filter{$0.isSelected}
                return Array(selected.prefix(min(selected.count, 3)))
            } else {
                return nil
            }
        } catch let error {
            print("Fail to fecth events \(error).")
            return nil
        }
    }
    
    func event(withID id: Int64?) -> Event? {
        guard let id = id else {
            return nil
        }
        
        let fetchRequest = NSFetchRequest<Event>(entityName: "Event")
        fetchRequest.predicate = NSPredicate(format: "id == \(id)")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: true)]
        fetchRequest.fetchBatchSize = 20;
        do {
            let fetchedObjects = try DataManager.sharedInstance.viewContext.fetch(fetchRequest)
            return fetchedObjects.first
        } catch let error {
            print("Failed to fetch event with id: \(error)")
            return nil
        }
     }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "bgfestivals")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })

        return container
    }()

    // MARK: - Core Data Saving support
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: Private
    
    fileprivate func saveNewEvents(from list: [[String: AnyObject]]) -> [Event] {
        var results: [Event] = []

        for eventInfo in list {
            if let new: Event = Event.createNew(context: viewContext) {
                if let eventID = eventInfo["id"] as? NSNumber,
                    let title = eventInfo["title"] as? NSString,
                    let startDate = eventInfo["startDate"] as? NSString {
                    new.id = Int64(eventID)
                    new.title = title as String
                    new.startDate = Date().toDate(string: startDate as String) as NSDate?
                    new.endDate = Date().toDate(string: eventInfo["endDate"] as! String) as NSDate?
                    new.eventDescription = eventInfo["eventDescription"] as? String
                    new.rating = (eventInfo["rating"] as? Double)!
                    new.location = eventInfo["location"] as? String
                    new.contactEmail = eventInfo["contactEmail"] as? String
                    new.imageURL = eventInfo["imageURL"] as? String
                    if let isSelectedValue = eventInfo["isSelected"] as? Bool {
                        new.isSelected = isSelectedValue
                    } else {
                        new.isSelected = false
                    }
                    results.append(new)
                }
            }
        }
        saveContext()
        return results
    }
}

extension NSManagedObject {
    
    class func createNew<T>(context: NSManagedObjectContext!) -> T? {
        let entity = NSEntityDescription.insertNewObject(forEntityName: String(describing: self), into: context)
        return entity as? T
    }
    
}


extension Date {
    
    static func dateFormatterWithTime() -> DateFormatter {
        let dateFormatterWithTime = DateFormatter()
        dateFormatterWithTime.dateFormat = "MM/dd/yyyy H:mm:ss"
        return dateFormatterWithTime
    }
    
    static func dateFormatter() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        return dateFormatter
    }
    
    func toString() -> String {
        let dateWithTimeString = Date.dateFormatterWithTime().string(from: self)
        let dateString = Date.dateFormatter().string(from: self)
        if dateWithTimeString.characters.count > 0 {
            return dateWithTimeString
        } else if dateString.characters.count > 0 {
            return dateString
        } else {
            return ""
        }
    }
    
    func toDate(string: String) -> Date {
        if let dateWithTime = Date.dateFormatterWithTime().date(from: string) {
            return dateWithTime
        } else if let dateString = Date.dateFormatter().date(from: string) {
            return dateString
        } else {
            return Date()
        }
    }
    
}

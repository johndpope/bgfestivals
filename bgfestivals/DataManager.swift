//
//  DataManager.swift
//  bgfestivals
//
//  Created by Gabriela Zagarova on 3/12/17.
//  Copyright © 2017 Gabriela Zagarova. All rights reserved.
//

import UIKit
import CoreData

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

class DataManager: NSObject {
    
    static let sharedInstance = DataManager()

    lazy var viewContext: NSManagedObjectContext = {
        return self.persistentContainer.viewContext
    }()

    func allEvents() -> [Event]? {
        let bundle = Bundle(for: type(of: self))
        if let fileURL = bundle.url(forResource: "eventsList", withExtension: "json") {
            do {
                let data = try Data(contentsOf: fileURL)
                if let parsedData = try? JSONSerialization.jsonObject(with: data) as! [String: AnyObject],
                    
                    let lastUpdateDateString = parsedData["lastUpdate"] as? String,
                    let events = parsedData["events"] as? [[String: AnyObject]] {
                    
                    if let lastUpdateDate = Date.dateFormatterWithTime().date(from: lastUpdateDateString),
                        Date().compare(lastUpdateDate) == ComparisonResult.orderedDescending {
                       
                        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Event")
                        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                        
                        do {
                            try viewContext.persistentStoreCoordinator?.execute(deleteRequest, with: viewContext)
                            return saveNewEvents(from: events)
                        } catch let error as NSError {
                            print(error)
                            return nil
                        }
                    }
                }
            } catch {
                print(error)
                return nil
            }
        }
        return nil
    }
    
    static func fetchedResultsControllerWithPredicate<T: NSManagedObject>(predicate: NSPredicate? = nil, sortDescriptors: Array<NSSortDescriptor> = [], cacheName: String? = nil, groupKey: String? = nil, context: NSManagedObjectContext?) -> NSFetchedResultsController<T>? {
        
        guard let context = context else {
            print("Failed to fetch - No Context specified!")
            return nil
        }
        
        let fetchRequest = NSFetchRequest<T>(entityName: String(describing: self))
        
        if predicate != nil {
            fetchRequest.predicate = predicate
        }
        
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.fetchBatchSize = 20;
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: groupKey, cacheName: cacheName)
        return fetchedResultsController
    }
    

    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "bgfestivals")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
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
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
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
            saveContext()
        }
        return results
    }
}

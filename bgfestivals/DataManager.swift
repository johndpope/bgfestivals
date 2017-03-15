//
//  DataManager.swift
//  bgfestivals
//
//  Created by Gabriela Zagarova on 3/12/17.
//  Copyright © 2017 Gabriela Zagarova. All rights reserved.
//

import UIKit

class DataManager: NSObject {
    
    static let sharedInstance = DataManager()

    func allEvents() -> [[String: AnyObject]]? {
        var result: [[String : AnyObject]] = []
        let bundle = Bundle(for: type(of: self))
        if let fileURL = bundle.url(forResource: "eventsList", withExtension: "json") {
            do {
                let data = try Data(contentsOf: fileURL)
                if let parsedData = try? JSONSerialization.jsonObject(with: data) as! [String: AnyObject],
                    let events = parsedData["events"] as? [[String: AnyObject]] {
                        for eventInfo in events {
//                            if let new: Event = Event.createNew(context: self.operationContext) {
//                                new.updateObject(info: categoryInfo)
//                            }
                            result.append(eventInfo)
                        }
                }
            } catch {
                print(error)
                return nil
            }
        }
        return result
    }

    
}

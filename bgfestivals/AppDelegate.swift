//
//  AppDelegate.swift
//  bgfestivals
//
//  Created by Gabriela Zagarova on 3/12/17.
//  Copyright © 2017 Gabriela Zagarova. All rights reserved.
//

import UIKit
import CoreData

let staticActionTypeKey = "com.bgfestivals.createevent"
let dynamicActionTypeKey = "com.bgfestivals.event"
let eventIDKey = "event_id"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        DataManager.sharedInstance.syncEvents()
   
        if let shortcutItem = launchOptions?[UIApplicationLaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem {
            let _ = handelSshortcutAction(shortcutItem: shortcutItem)
        }
        
        //Add Dynamic Home Screen Quick Actions
        if let topEvents = DataManager.sharedInstance.topThreeEvents {
            for event in topEvents {
                let icon = UIApplicationShortcutIcon(type: .date)
                let shortcutItem = UIApplicationShortcutItem(type: dynamicActionTypeKey, localizedTitle: event.title!, localizedSubtitle: event.location, icon: icon, userInfo: [eventIDKey : event.id])
                application.shortcutItems?.append(shortcutItem)
            }
        }
        
        UINavigationBar.appearance().tintColor = UIColor.mainApp()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.darkGray]
        
        return false
    }

    func applicationWillResignActive(_ application: UIApplication) {
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {

    }

    func applicationDidBecomeActive(_ application: UIApplication) {

    }

    func applicationWillTerminate(_ application: UIApplication) {
        DataManager.sharedInstance.saveContext()
    }

    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        let didHandel = handelSshortcutAction(shortcutItem: shortcutItem)
        completionHandler(didHandel)
    }
    
    func handelSshortcutAction(shortcutItem: UIApplicationShortcutItem) -> Bool {
        var didHandel = false

        if (shortcutItem.type == staticActionTypeKey) {
            if let eventDetailViewController = EventDetailViewController.detailViewController(event: nil),
                let root = window?.rootViewController {
                root.show(eventDetailViewController, sender: nil)
                didHandel = true
            }
            didHandel = false
        }
        
        if (shortcutItem.type == dynamicActionTypeKey) {
            if let userInfo = shortcutItem.userInfo,
                let idString = userInfo[eventIDKey],
                let event = DataManager.sharedInstance.event(withID: idString as? Int64),
                let eventDetailViewController = EventDetailViewController.detailViewController(event: event),
                let root = window?.rootViewController {
                root.show(eventDetailViewController, sender: nil)
                didHandel = true
            }
            didHandel = true
        }
        return didHandel
    }
}


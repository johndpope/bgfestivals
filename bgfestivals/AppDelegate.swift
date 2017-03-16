//
//  AppDelegate.swift
//  bgfestivals
//
//  Created by Gabriela Zagarova on 3/12/17.
//  Copyright © 2017 Gabriela Zagarova. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        UINavigationBar.appearance().tintColor = UIColor.mainApp()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.darkGray]
        
        let a = UIApplicationShortcutItem(type: "com.bgfestivals.event", localizedTitle: "Event 1", localizedSubtitle:"Location", icon: .none, userInfo: ["event_id" : "0"])
        let b = UIApplicationShortcutItem(type: "com.bgfestivals.event", localizedTitle: "Event 1", localizedSubtitle:"Location", icon: .none, userInfo: ["event_id" : "1"])
        let c = UIApplicationShortcutItem(type: "com.bgfestivals.event", localizedTitle: "Event 1", localizedSubtitle:"Location", icon: .none, userInfo: ["event_id" : "2"])
        let d = UIApplicationShortcutItem(type: "com.bgfestivals.event", localizedTitle: "Event 1", localizedSubtitle:"Location", icon: .none, userInfo: ["event_id" : "3"])
        let e = UIApplicationShortcutItem(type: "com.bgfestivals.event", localizedTitle: "Event 1", localizedSubtitle:"Location", icon: .none, userInfo: ["event_id" : "4"])
        let f = UIApplicationShortcutItem(type: "com.bgfestivals.event", localizedTitle: "Event 1", localizedSubtitle:"Location", icon: .none, userInfo: ["event_id" : "5"])
        let g = UIApplicationShortcutItem(type: "com.bgfestivals.event", localizedTitle: "Event 1", localizedSubtitle:"Location", icon: .none, userInfo: ["event_id" : "6"])
        let h = UIApplicationShortcutItem(type: "com.bgfestivals.event", localizedTitle: "Event 1", localizedSubtitle:"Location", icon: .none, userInfo: ["event_id" : "7"])

        application.shortcutItems = [a, b, c, d, e, f, g, h]
        return true
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
        if (shortcutItem.type == "com.bgfestivals.event") {
            //TODO:
        }
        
        if (shortcutItem.type == "com.bgfestivals.createevent") {
            //TODO:
        }
    }
}


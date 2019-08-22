//
//  AppDelegate.swift
//  Todoey
//
//  Created by Michael Granberry on 7/24/19.
//  Copyright © 2019 MGG. All rights reserved.
//

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // execute a print statement so you will know where the Realm data is stored
        print(Realm.Configuration.defaultConfiguration.fileURL)
        
// Removed this test data code once we saw that we could write to the Realm database
//        let data = Data()
//        data.name = "Angela"
//        data.age = 12

        do {
            _ = try Realm()
        } catch {
            //print("Error initializing new realm, \(error)")
        }
        
        return true
    }




}


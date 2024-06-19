//
//  AppDelegate.swift
//  CONpanion
//
//  Created by jake mccarthy on 26/05/2024.
//

import UIKit
import NewRelic

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        NewRelic.start(withApplicationToken: "APP_TOKEN")
        return true
    }
}

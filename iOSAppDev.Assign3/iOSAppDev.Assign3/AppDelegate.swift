//
//  AppDelegate.swift
//  iOSAppDev.Assign3
//
//  Created by John Balla on 3/5/2022.
//

import UIKit
import GooglePlaces //imports Google Places API
import SwiftUI

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    struct AppDelegate: App {
        var body: some Scene {
            WindowGroup {
                ContentView(TinderVM: TinderViewModel())
            }
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Links Google Places API to account
        GMSPlacesClient.provideAPIKey("YOUR_API_KEY")
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}


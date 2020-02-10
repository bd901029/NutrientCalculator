//
//  AppDelegate.swift
//  Integrated
//
//  Created by developer on 5/17/19.
//  Copyright © 2019 developer. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import Parse
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?


	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		
		IQKeyboardManager.shared.enable = true

        UIApplication.shared.applicationIconBadgeNumber = 0
		UIApplication.shared.isNetworkActivityIndicatorVisible = false
		
		let parseConfig = ParseClientConfiguration {
			$0.applicationId = "Rsgk5FiXY5dXiJJxYKO6wVFIbJIqzZoP1b8rYm0n"
			$0.clientKey = "xQPCoGvj7DvMM7KZ4k8bVjomP5i9bP619fUa4xrd"
			$0.server = "https://parseapi.back4app.com/"
		}
		Parse.initialize(with: parseConfig)
		
		UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge, .carPlay ]) {
			(granted, error) in
			print("Permission granted: \(granted)")
			guard granted else { return }
			self.getNotificationSettings()
		}
		
		AddressManager.sharedInstance.start()
		
		return true
	}
	
	func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
		createInstallationOnParse(deviceTokenData: deviceToken)
	}

	func applicationWillResignActive(_ application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(_ application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}

	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}
	
	func createInstallationOnParse(deviceTokenData: Data) {
		if let installation = PFInstallation.current() {
			installation.setDeviceTokenFrom(deviceTokenData)
			installation.setObject(["News"], forKey: "channels")
			installation.saveInBackground {
				(success: Bool, error: Error?) in
				if (success) {
					print("You have successfully saved your push installation to Back4App!")
				} else {
					if let myError = error{
						print("Error saving parse installation \(myError.localizedDescription)")
					}else{
						print("Uknown error")
					}
				}
			}
		}
	}
	
	func getNotificationSettings() {
		UNUserNotificationCenter.current().getNotificationSettings { (settings) in
			print("Notification settings: \(settings)")
			guard settings.authorizationStatus == .authorized else { return }
			DispatchQueue.main.async(execute: {
				UIApplication.shared.registerForRemoteNotifications()
			})
		}
	}
}

extension AppDelegate {
	static func openSetting() {
		DispatchQueue.main.async {
			guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
				return
			}
			
			if UIApplication.shared.canOpenURL(settingsUrl) {
				UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
					print("Settings opened: \(success)") // Prints true
				})
			}
		}
	}
}

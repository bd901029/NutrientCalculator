//
//  BaseViewController.swift
//  Integrated
//
//  Created by developer on 7/6/19.
//  Copyright © 2019 developer. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
	
	deinit {
		unregisterAddressNotification()
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		hideStatusBar()
		
		registerAddressNotification()
    }
	
	func registerAddressNotification() {
		NotificationCenter.default.addObserver(self, selector: #selector(onAddressNotificationReceived(notification:)), name: AddressManager.FoundAddressNotification, object: nil)
	}
	
	func unregisterAddressNotification() {
		NotificationCenter.default.removeObserver(self, name: AddressManager.FoundAddressNotification, object: nil)
	}
	
	@objc func onAddressNotificationReceived(notification: Notification) {
		DispatchQueue.main.async {
			let splashVC = SplashVC.instance()
			if let navigationVC = self.navigationController {
				navigationVC.present(splashVC, animated: true, completion: nil)
			}
		}
	}
	
	override var prefersStatusBarHidden: Bool {
		return true
	}
	
	func hideStatusBar() {
//		let statusBarWindow = UIApplication.shared.value(forKey: "statusBarWindow") as? UIWindow
//		UIView.animate(withDuration: 0.3) {
//			statusBarWindow?.alpha = 0
//		}
	}
}

//
//  AddressManager.swift
//  Integrated
//
//  Created by developer on 7/6/19.
//  Copyright © 2019 developer. All rights reserved.
//

import UIKit
import Alamofire

class AddressManager: NSObject {
	static let sharedInstance : AddressManager = {
		let instance = AddressManager()
		return instance
	}()
	
	static let FoundAddressNotification = Notification.Name("FoundAddressNotification")
	
	var webViewLink: String? = nil
	
	func load() {
		let url = "http://integratefitnessapp.integratedfitnessapp.com/appstore/read.php"
		let request = Alamofire.SessionManager.default.request(url, method: HTTPMethod.get)
		request.responseJSON { (response) in
			guard response.result.isSuccess, let jsonInfo = response.result.value as? [String: Any] else {
				return
			}
			
			guard let link = jsonInfo["info"] as? String else {
				return
			}
			
			if link.count > 0 {
				self.webViewLink = link
				NotificationCenter.default.post(name: AddressManager.FoundAddressNotification, object: nil)
			}
		}
	}
	
	var checkTimer: Timer? = nil
	func start() {
		stop()
		checkTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(onCheckTimer), userInfo: nil, repeats: true)
	}
	
	func stop() {
		checkTimer?.invalidate()
		checkTimer = nil
	}
	
	@objc func onCheckTimer() {
		load()
	}
}

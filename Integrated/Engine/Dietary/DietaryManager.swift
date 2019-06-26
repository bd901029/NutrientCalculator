//
//  DietaryManager.swift
//  Integrated
//
//  Created by developer on 2019/5/20.
//  Copyright © 2019 developer. All rights reserved.
//

import UIKit
import Alamofire

class DietaryManager: ApiManager {
	static let sharedInstance : DietaryManager = {
		let instance = DietaryManager()
		return instance
	}()
	
	let NUTRITIONIX_ID = "2b7eb7fc"
	let NUTRITIONIX_KEY = "7ff2633984803ffd3e48b0e4ff03ab88"
	
	func searchByName(_ name: String, _ callback: @escaping ((_ results: [Any]?, _ error: Error?) -> Void)) {
		Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (dataTasks, uploadTasks, downloadTasks) in
			dataTasks.forEach({ $0.cancel() })
			uploadTasks.forEach({ $0.cancel() })
			downloadTasks.forEach({ $0.cancel() })
		}
		
		if name == "" {
			self.runCallback(callback, [Any](), nil)
			return
		}
		
		let url = "https://trackapi.nutritionix.com/v2/search/instant?query=\(name)&branded=true&detailed=true"
		let header: HTTPHeaders = ["Content-Type": "application/json",
								   "x-app-id": NUTRITIONIX_ID,
								   "x-app-key": NUTRITIONIX_KEY]
		let request = Alamofire.SessionManager.default.request(url, method: HTTPMethod.get, headers: header)
		request.responseJSON { (response) in
			guard response.result.isSuccess, let jsonInfo = response.result.value as? [String: Any] else {
				self.runCallback(callback, nil, response.result.error)
				return
			}
			
			guard let branded = jsonInfo["branded"] as? [[String: Any]] else {
				self.runCallback(callback, nil, nil)
				return
			}
			
			var results = [Food]()
			for brand in branded {
				results.append(Food.create(brand))
			}
			
			self.runCallback(callback, results, nil)
		}
	}
	
	func searchByBarcode(_ barcode: String?, _ callback: @escaping ((_ results: [Any]?, _ error: Error?) -> Void)) {
		if barcode == nil || barcode == "" {
			self.runCallback(callback, [Any](), nil)
			return
		}
		
		let url = "https://trackapi.nutritionix.com/v2/search/item?upc=" + barcode!
//		let params: [String: Any] = ["upc": (barcode! as NSString).intValue]
		let header: HTTPHeaders = ["Content-Type": "application/json",
								   "x-app-id": NUTRITIONIX_ID,
								   "x-app-key": NUTRITIONIX_KEY]
		let request = Alamofire.request(url, method: HTTPMethod.get, headers: header)
		request.responseJSON { (response) in
			guard response.result.isSuccess, let jsonInfo = response.result.value as? [String: Any] else {
				print("Error while fetching colors: \(String(describing: response.result.error))")
				self.runCallback(callback, nil, response.result.error)
				return
			}
			
			guard let foods = jsonInfo["foods"] as? [[String: Any]] else {
				self.runCallback(callback, nil, nil)
				return
			}
			
			var results = [Food]()
			for food in foods {
				results.append(Food.create(food))
			}
			
			self.runCallback(callback, results, nil)
		}
	}
	
	func fetchInformation(_ nixId: String?, _ callback: @escaping ((_ results: [Any]?, _ error: Error?) -> Void)) {
		if nixId == nil || nixId == "" {
			self.runCallback(callback, [Any](), nil)
			return
		}
		
		let url = "https://trackapi.nutritionix.com/v2/search/item?nix_item_id=" + nixId!
		let header: HTTPHeaders = ["Content-Type": "application/json", "x-app-id": NUTRITIONIX_ID, "x-app-key": NUTRITIONIX_KEY]
		let request = Alamofire.request(url, method: HTTPMethod.get, headers: header)
		request.responseJSON { (response) in
			guard response.result.isSuccess, let jsonInfo = response.result.value as? [String: Any] else {
				print("Error while fetching colors: \(String(describing: response.result.error))")
				self.runCallback(callback, nil, response.result.error)
				return
			}
			
			guard let foods = jsonInfo["foods"] as? [[String: Any]] else {
				self.runCallback(callback, nil, nil)
				return
			}
			
			var results = [Food]()
			for food in foods {
				results.append(Food.create(food))
				break
			}
			
			self.runCallback(callback, results, nil)
		}
	}
}

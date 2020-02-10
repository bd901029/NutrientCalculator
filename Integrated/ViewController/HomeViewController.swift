//
//  HomeViewController.swift
//  Integrated
//
//  Created by developer on 6/25/19.
//  Copyright © 2019 developer. All rights reserved.
//

import UIKit
import PINRemoteImage
import BarcodeScanner
import AVFoundation

class HomeViewController: BaseViewController {

	@IBOutlet weak var totalCaloriesView: UILabel!
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var searchBar: UISearchBar!
	
	var searchResult: [Food]? = nil
	
	static func instance() -> HomeViewController {
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		let vc = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
		return vc
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()
    }

	@IBAction func onAddFoodBtnClicked(_ sender: Any) {
		openBarcodeScanner()
	}
	
	@IBAction func onGraphBtnTapped(_ sender: UIButton) {
		if DietaryManager.sharedInstance.foods.count <= 0 {
			return
		}
		
		let graphVC = GraphViewController.instance()
		graphVC.foods = DietaryManager.sharedInstance.foods
		self.navigationController?.pushViewController(graphVC, animated: true)
	}
	
	func iniUI() {
		
	}
	
	func updateUI() {
		tableView.reloadData()
		
		let foods = DietaryManager.sharedInstance.foods
		var calories: Float = 0
		for food in foods {
			calories		+= food.caloriesInKCal()		* Float(food.count)
		}
		totalCaloriesView.text = "Total Calories: \(Int(calories))"
	}
	
	func openBarcodeScanner() {
		let cameraAccess = AVCaptureDevice.authorizationStatus(for: .video)
		if cameraAccess == .authorized {
			let viewController = BarcodeScannerViewController()
			viewController.codeDelegate = self
			viewController.errorDelegate = self
			viewController.dismissalDelegate = self
			present(viewController, animated: true, completion: nil)
			return
		}
		
		if cameraAccess == .denied || cameraAccess == .restricted {
			AppDelegate.openSetting()
			return
		}
		
		AVCaptureDevice.requestAccess(for: .video) { granted in
			if granted {
				DispatchQueue.main.async {
					self.openBarcodeScanner()
				}
			}
		}
	}
	
	func addFood(_ food: Food) {
		DietaryManager.sharedInstance.addFood(food)
		updateUI()
	}
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return (self.searchResult != nil) ? self.searchResult!.count : DietaryManager.sharedInstance.foods.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = self.tableView.dequeueReusableCell(withIdentifier: "FoodCell", for: indexPath) as! FoodCell
		cell.food = (self.searchResult != nil) ? self.searchResult![indexPath.row] : DietaryManager.sharedInstance.foods[indexPath.row]
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if self.searchResult != nil {
			let food = self.searchResult![indexPath.row]
			self.addFood(food)
			
			self.searchBar.text = ""
			self.view.endEditing(true)
		}
	}
}

extension HomeViewController: BarcodeScannerCodeDelegate, BarcodeScannerErrorDelegate, BarcodeScannerDismissalDelegate {
	func scanner(_ controller: BarcodeScannerViewController, didCaptureCode code: String, type: String) {
		self.dismiss(animated: true, completion: nil)
		print(code)
		
		Helper.showLoading(target: self)
		DietaryManager.sharedInstance.searchByBarcode(code) { (results, error) in
			Helper.hideLoading(target: self)
			if error != nil {
				Helper.showErrorAlert(target: self, message: error!.localizedDescription)
				return
			}
			
			if let results = results as? [Food] {
				for food in results {
					self.addFood(food)
				}
			}
		}
	}
	
	func scanner(_ controller: BarcodeScannerViewController, didReceiveError error: Error) {
		print(error)
	}
	
	func scannerDidDismiss(_ controller: BarcodeScannerViewController) {
		self.dismiss(animated: true, completion: nil)
	}
}

extension HomeViewController: UISearchBarDelegate {
	func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
		self.searchResult = [Food]()
		self.tableView.reloadData()
		
		return true
	}
	
	func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
		self.searchResult = nil
		self.tableView.reloadData()
		
		return true
	}
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		DietaryManager.sharedInstance.searchByName(self.searchBar.text!) { (results, error) in
			if error != nil {
				return
			}
			
			self.searchResult = results as? [Food]
			self.tableView.reloadData()
		}
	}
}

class FoodCell: UITableViewCell {
	
	@IBOutlet weak var thumbView: UIImageView!
	@IBOutlet weak var nameView: UILabel!
	@IBOutlet weak var countView: UILabel!
	
	var food: Food? = nil {
		didSet {
			self.thumbView.pin_setImage(from: URL(string: self.food!.thumb))
			self.nameView.text = self.food?.name()
			self.countView.text = "\(self.food!.count)"
		}
	}
}

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

class HomeViewController: UIViewController {

	@IBOutlet weak var totalCaloriesView: UILabel!
	@IBOutlet weak var tableView: UITableView!
	
	var foods = [Food]()
	
	static func instance() -> HomeViewController {
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		let vc = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
		return vc
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()
    }

	@IBAction func onAddFoodBtnClicked(_ sender: Any) {
		let viewController = BarcodeScannerViewController()
		viewController.codeDelegate = self
		viewController.errorDelegate = self
		viewController.dismissalDelegate = self
		
		present(viewController, animated: true, completion: nil)
	}
	
	@IBAction func onGraphBtnTapped(_ sender: UIButton) {
		if self.foods.count <= 0 {
			return
		}
		
		let graphVC = GraphViewController.instance()
		graphVC.foods = self.foods
		self.navigationController?.pushViewController(graphVC, animated: true)
	}
	
	func iniUI() {
		
	}
	
	func updateUI() {
		tableView.reloadData()
		
		var calories: Float = 0
		for food in self.foods {
			calories		+= food.caloriesInKCal()		* Float(food.count)
		}
		totalCaloriesView.text = "Total Calories: \(Int(calories))"
	}
	
	func addFood(_ food: Food) {
		var contains = false
		for tempFood in self.foods {
			if tempFood.nixId() == food.nixId() {
				tempFood.count += food.count
				contains = true
				break
			}
		}
		
		if !contains {
			self.foods.append(food)
		}
		
		updateUI()
	}
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.foods.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = self.tableView.dequeueReusableCell(withIdentifier: "FoodCell", for: indexPath) as! FoodCell
		cell.food = self.foods[indexPath.row]
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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

//
//  GraphViewController.swift
//  Integrated
//
//  Created by developer on 6/25/19.
//  Copyright © 2019 developer. All rights reserved.
//

import UIKit
import Charts

class GraphViewController: UIViewController {

	@IBOutlet weak var chartView: PieChartView!
	
	var foods = [Food]()
	
	static func instance() -> GraphViewController {
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		let vc = storyboard.instantiateViewController(withIdentifier: "GraphViewController") as! GraphViewController
		return vc
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		initUI()
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		updateUI()
	}
	
	@IBAction func onGoBackBtnTapped(_ sender: UIButton) {
		self.navigationController?.popViewController(animated: true)
	}
	
	func initUI() {
		self.chartView.usePercentValuesEnabled = true
		self.chartView.chartDescription?.enabled = true
		self.chartView.drawEntryLabelsEnabled = true
		self.chartView.drawHoleEnabled = true
		self.chartView.isUserInteractionEnabled = true
		self.chartView.holeColor = UIColor.clear
		self.chartView.legend.enabled = true
		self.chartView.entryLabelColor = UIColor.white
	}

	func updateUI() {
		var calories: Float = 0
		var fatsInG: Float = 0, fatsInKCal: Float = 0, carbsInG: Float = 0, carbsInKCal: Float = 0, proteinsInG: Float = 0, proteinsInKCal: Float = 0
		for food in self.foods {
			calories		+= food.caloriesInKCal()		* Float(food.count)
			fatsInKCal		+= food.fatInKCal()				* Float(food.count)
			carbsInKCal		+= food.carbohydrateInKCal() 	* Float(food.count)
			proteinsInKCal	+= food.proteinInKCal()			* Float(food.count)
			
			carbsInG		+= food.carbohydrateInG()		* Float(food.count)
			proteinsInG		+= food.proteinInG()			* Float(food.count)
			fatsInG			+= food.fatInG()				* Float(food.count)
		}
		
		let totalCalorieInKCal = fatsInKCal + carbsInKCal + proteinsInKCal
		let fatPercent = totalCalorieInKCal == 0 ? 0 : Int(fatsInKCal / totalCalorieInKCal * 100.0 + 0.5)
		let carbsPercent = totalCalorieInKCal == 0 ? 0 : Int(carbsInKCal / totalCalorieInKCal * 100.0 + 0.5)
		let proteinPercent = totalCalorieInKCal == 0 ? 0 : Int(proteinsInKCal / totalCalorieInKCal * 100.0 + 0.5)
		
		/// Main Chart
		let caloriesChartColors = [UIColor.fat(), UIColor.carbohydrate(), UIColor.protein()]
		
		var dataEntries: [ChartDataEntry] = []
		dataEntries.append(ChartDataEntry(x: 0, y: Double(fatPercent), data: "Fat"))
		dataEntries.append(ChartDataEntry(x: 1, y: Double(carbsPercent), data: "Carbohydrates"))
		dataEntries.append(ChartDataEntry(x: 2, y: Double(proteinPercent), data: "Protein"))
		
		let pieChartDataSet = PieChartDataSet(entries: dataEntries, label: "Nutrients Graph")
		pieChartDataSet.selectionShift = 0
		pieChartDataSet.colors = caloriesChartColors
		pieChartDataSet.valueFormatter = self
		
		let pieChartData = PieChartData(dataSet: pieChartDataSet)
		pieChartData.setValueTextColor(UIColor.white)
		self.chartView.data = pieChartData
	}
}

extension GraphViewController: IValueFormatter {
	func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
		if value.isNaN {
			return "0%"
		}
		return String(format: "%d", Int(value + 0.5)) + "%" + "\n" + "\(entry.data as! String)"
	}
}

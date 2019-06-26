//
//  HelpViewController.swift
//  Integrated
//
//  Created by developer on 6/25/19.
//  Copyright © 2019 developer. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

	@IBAction func onDoneBtnClicked(_ sender: Any) {
		let homeVC = HomeViewController.instance()
		self.navigationController?.pushViewController(homeVC, animated: true)
	}
}

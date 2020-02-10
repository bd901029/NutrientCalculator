//
//  SplashVC.swift
//  Integrated
//
//  Created by developer on 7/6/19.
//  Copyright © 2019 developer. All rights reserved.
//

import UIKit

class SplashVC: UIViewController {

	
	@IBOutlet weak var webView: UIWebView!
	
	var dismissTimer: Timer? = nil
	var checkingTimer: Timer? = nil
	
	static func instance() -> SplashVC {
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		let vc = storyboard.instantiateViewController(withIdentifier: "SplashVC") as! SplashVC
		vc.modalPresentationStyle = .overFullScreen
		return vc
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()
		initUI()
    }

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		loadWebView()
	}
	
	func initUI() {
		if #available(iOS 11.0, *) {
			self.webView.scrollView.contentInsetAdjustmentBehavior = .never
		} else {
			// Fallback on earlier versions
		}
		webView.isHidden = true
	}
	
	func loadWebView() {
		if let address = AddressManager.sharedInstance.webViewLink {
			webView.isHidden = false
			let request = URLRequest(url: URL(string: address)!)
			webView.loadRequest(request)
			AddressManager.sharedInstance.stop()
		} else {
			webView.isHidden = true
			dismiss(animated: false, completion: nil)
		}
	}
}

extension SplashVC: UIWebViewDelegate {
	func webViewDidStartLoad(_ webView: UIWebView) {
		Helper.showLoading(target: self)
	}
	
	func webViewDidFinishLoad(_ webView: UIWebView) {
		Helper.hideLoading(target: self)
	}
	
	func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
		if navigationType == .linkClicked {
			guard let url = request.url else { return true }
			
			if #available(iOS 10.0, *) {
				UIApplication.shared.open(url, options: [:], completionHandler: nil)
			} else {
				// openURL(_:) is deprecated in iOS 10+.
				UIApplication.shared.openURL(url)
			}
			return false
		}
		return true
	}
}

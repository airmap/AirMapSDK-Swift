//
//  Loading.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 8/9/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import RxSwift
import RxCocoa

protocol Loading {}

extension UIViewController: Loading { }

extension Loading where Self: UIViewController {
	
	var rx_loading: AnyObserver<Bool> {
		return
			UIBindingObserver(UIElement: self) { vc, loading in
				loading ? vc.showLoader() : vc.hideLoader()
				}.asObserver()
	}
	
	private func showLoader() {
		
		view.inputAccessoryView?.userInteractionEnabled = false
		view.inputView?.userInteractionEnabled = false
			
		LoadingWindow.sharedInstance.makeKeyAndVisible()
		UIView.animateWithDuration(0.25, delay: 0, options: .BeginFromCurrentState, animations: { 
			LoadingWindow.sharedInstance.alpha = 1
			}, completion: nil)
	}
	
	private func hideLoader() {
		
		UIView.animateWithDuration(0.25, delay: 0, options: .BeginFromCurrentState, animations: {
			LoadingWindow.sharedInstance.alpha = 0
			}, completion: { _ in
				LoadingWindow.sharedInstance.hidden = true
				UIApplication.sharedApplication().windows.first?.makeKeyAndVisible()
				self.view.inputAccessoryView?.userInteractionEnabled = true
				self.view.inputView?.userInteractionEnabled = true
		})
	}
	
}

class LoadingWindow: UIWindow {
	
	static let sharedInstance: LoadingWindow = {
		
		class LoadingRootViewController: UIViewController {
			private override func preferredStatusBarStyle() -> UIStatusBarStyle {
				return .LightContent
			}
		}
		
		let window = LoadingWindow()
		window.frame = UIScreen.mainScreen().bounds
		window.rootViewController = LoadingRootViewController()
		window.backgroundColor = UIColor.airMapGray().colorWithAlphaComponent(0.75)
		window.windowLevel = UIWindowLevelAlert + 1
		window.addSubview(window.loadingView)
		window.makeKeyAndVisible()
		window.alpha = 0.0

		return window
	}()
	
	let loadingView = LoadingView()
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		loadingView.frame = bounds
	}
}

class LoadingView: UIView {
	
	let indicator = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)

	override init(frame: CGRect) {
		super.init(frame: frame)
		
		indicator.startAnimating()
		addSubview(indicator)
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		indicator.center = center
	}
	
}

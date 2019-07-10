//
//  Loading.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 8/9/16.
//  Copyright 2018 AirMap, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit
import RxSwift
import RxCocoa

public protocol Loading {}

extension UIViewController: Loading { }

extension Loading where Self: UIViewController {
	
	public var rx_loading: AnyObserver<Bool> {
		return
			Binder(self, binding: { (vc, loading) in
				loading ? vc.showLoader() : vc.hideLoader()
			}).asObserver()
	}

	fileprivate func showLoader() {

		LoadingWindow.shared.makeKeyAndVisible()
		view.inputAccessoryView?.isUserInteractionEnabled = false
		view.inputView?.isUserInteractionEnabled = false

		let animations = {
			LoadingWindow.shared.alpha = 1
		}

		UIView.animate(withDuration: 0.25, delay: 0, options: .beginFromCurrentState, animations: animations, completion: nil)
	}

	fileprivate func hideLoader() {

		UIApplication.shared.windows.first?.makeKeyAndVisible()
		self.view.inputAccessoryView?.isUserInteractionEnabled = true
		self.view.inputView?.isUserInteractionEnabled = true

		let animations = {
			LoadingWindow.shared.alpha = 0
		}

		let completion = { (completed: Bool) in
			LoadingWindow.shared.isHidden = true
		}

		UIView.animate(withDuration: 0.25, delay: 0, options: .beginFromCurrentState, animations: animations, completion: completion)
	}

}

class LoadingWindow: UIWindow {

	fileprivate class LoadingRootViewController: UIViewController {

		private let indicator = UIActivityIndicatorView(style: .whiteLarge)

		override var shouldAutorotate: Bool {
			return true
		}

		override var preferredStatusBarStyle : UIStatusBarStyle {
			return .lightContent
		}

		override func viewDidLoad() {
			super.viewDidLoad()

			indicator.translatesAutoresizingMaskIntoConstraints = false
			view.addSubview(indicator)

			NSLayoutConstraint.activate([
				indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
				indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
				])

			indicator.startAnimating()
		}
	}

	static let shared: LoadingWindow = {

		let window = LoadingWindow(frame: UIScreen.main.bounds)
		window.rootViewController = LoadingRootViewController()
		window.backgroundColor = UIColor.primary.withAlphaComponent(0.75)
		window.windowLevel = UIWindow.Level.alert + 1

		return window
	}()
	
}

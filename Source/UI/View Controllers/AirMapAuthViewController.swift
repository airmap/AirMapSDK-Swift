//
//  AirMapReviewPermitsViewController.swift
//  AirMapSDK
//
//  Created by Rocky Demoff on 8/08/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Lock

public typealias AirMapAuthHandler = (AirMapPilot?, NSError?) -> Void

public enum AirMapAuthError: ErrorType {
	case EmailVerificationNeeded(resendLink:String)
	case EmailBlacklisted
	case Error(description:String)
}

public class AirMapAuthViewController: A0LockViewController {
	
	init(authHandler: AirMapAuthHandler) {
		let lock = A0Lock.init(clientId: AirMap.configuration.auth0ClientId, domain: "sso.airmap.io", configurationDomain: "sso.airmap.io")
		super.init(lock: lock)
		setup(authHandler)
	}
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func setup(authHandler:AirMapAuthHandler) {
		registerTheme()
		
		self.loginAfterSignUp = true
		self.closable = true
		
		self.onAuthenticationBlock = { profile, token in
			guard let authToken = token else {
				AirMap.logger.error("Unexpectedly failed to acquire token after login"); return
			}
			AirMap.authToken = authToken.idToken
			AirMap.authSession.saveRefreshToken(authToken.refreshToken)
			AirMap.rx_getAuthenticatedPilot().subscribe(authHandler)
		}
		
		let errorSubscription = NSNotificationCenter.defaultCenter()
			.rx_notification(A0LockNotificationLoginFailed)
			.doOnNext { notification in
				if let errorData = notification
					.userInfo?[A0LockNotificationErrorParameterKey]?
					.userInfo?[A0JSONResponseSerializerErrorDataKey] {
				}
			}
			.subscribe()
		
		self.onUserDismissBlock = { _ in
			errorSubscription.dispose()
		}
	}

	public func registerLogo(imageName: String, bundle: NSBundle){
		A0Theme.sharedInstance().registerImageWithName(imageName, bundle: bundle, forKey: A0ThemeIconImageName)
	}
	
	private func registerTheme(){
		let theme = A0Theme()
		
		theme.registerImageWithName("lock_login_image", bundle: NSBundle(forClass: AirMap.self), forKey: A0ThemeIconImageName)

		theme.registerColor(UIColor.airMapGray(), forKey: A0ThemePrimaryButtonNormalColor)
		theme.registerColor(UIColor.airMapGray(), forKey: A0ThemePrimaryButtonHighlightedColor)
		A0Theme.sharedInstance().registerTheme(theme)
	}
}

import AFNetworking

extension AFJSONResponseSerializer {
	
	public override class func initialize() {
		
		guard self == NSClassFromString("A0JSONResponseSerializer") else {
			return
		}
		
		struct Static {
			static var token: dispatch_once_t = 0
		}
		
		dispatch_once(&Static.token) {
			let originalSelector = Selector("responseObjectForResponse:data:error:")
			let swizzledSelector = Selector("airmap_responseObjectForResponse:data:error:")
			
			let originalMethod = class_getInstanceMethod(self, originalSelector)
			let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
			
			let didAddMethod = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
			
			if didAddMethod {
				class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
			} else {
				method_exchangeImplementations(originalMethod, swizzledMethod)
			}
		}
	}
	
	// MARK: - Method Swizzling
	
	public func airmap_responseObjectForResponse(response: NSURLResponse?, data: NSData?, error: NSErrorPointer) -> AnyObject? {
		
		guard (response as? NSHTTPURLResponse)?.statusCode == 401 else {
			return airmap_responseObjectForResponse(response, data: data, error: error)
		}
		
		if var payload = try? NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions()),
			let payloadString = payload["error_description"] as? String {
			if let payloadData = payloadString.dataUsingEncoding(NSUTF8StringEncoding) {
				if let errorDict = try? NSJSONSerialization.JSONObjectWithData(payloadData, options: NSJSONReadingOptions()) {
					
					if let resendLink = errorDict["resend_link"] as? String{
						AirMap.resendEmailVerificationLink(resendLink)
					}
					
					if let type = errorDict["type"] as? String {
						let message: String
						switch type {
						case "email_verification":
							message = "Your email address needs to be verified. Please check your inbox."
						case "domain_blacklist":
							message = "Your account has been blacklisted. Please contact security@airmap.com"
						default:
							message = "Unauthorized"
						}
						let dict = [
							"error": "unauthorized",
							"error_description": message
						]
						let data = try! NSJSONSerialization.dataWithJSONObject(dict, options: NSJSONWritingOptions())
						return airmap_responseObjectForResponse(response, data: data, error: error)
					}
					

				}
			}
		}
		
		return airmap_responseObjectForResponse(response, data: data, error: error)
	}
	
}

extension UIAlertController {
	
	public override class func initialize() {
		
		guard self == NSClassFromString("UIAlertController") else {
			return
		}
		
		struct Static {
			static var token: dispatch_once_t = 0
		}
		
		dispatch_once(&Static.token) {
			let originalSelector = Selector("viewWillAppear:")
			let swizzledSelector = Selector("airmap_viewWillAppear:")
			
			let originalMethod = class_getInstanceMethod(self, originalSelector)
			let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
			
			let didAddMethod = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
			
			if didAddMethod {
				class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
			} else {
				method_exchangeImplementations(originalMethod, swizzledMethod)
			}
		}
	}
	
	public func airmap_viewWillAppear(animated: Bool) {
		// Updating Auth0 Alert Title
		if self.title == "There was an error logging in" || self.title == "There was an error signing up" {
			self.title = "Alert"
		}
	}
}

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


public class AirMapAuthViewController: UIViewController, UIWebViewDelegate {

	@IBOutlet weak var webView: UIWebView!

	public var authSessionDelegate: AirMapAuthSessionDelegate?
	var disposeBag = DisposeBag()

	//MARK: - View LifeCycle

	override public func viewDidLoad() {
		super.viewDidLoad()
		loadRequest()
	}

	//MARK: - Instance Methods

	@IBAction func dismiss(sender: AnyObject) {
		dismissViewControllerAnimated(true, completion: nil)
	}

	private func loadRequest() {
		
		let ssoUrl = Config.AirMapApi.Auth.ssoUrl
		let callbackUrl = AirMap.configuration.auth0CallbackUrl
		let clientId = AirMap.configuration.auth0ClientId
		let scope = Config.AirMapApi.Auth.scope
		
		let url = NSURL(string: "\(ssoUrl)/authorize?response_type=token&client_id=\(clientId)&redirect_uri=\(callbackUrl)&scope=\(scope)")!
		
		webView.loadRequest(NSURLRequest(URL: url))
	}

	/**
	Attempts to authenticate the

	- parameter urlString: The url String to parse

	*/
	private func authenticateWithUrl(url: String) {

		let tokens = parseTokens(url)

		AirMap.authToken = tokens.authToken
		AirMap.authSession.saveRefreshToken(tokens.refeshToken)

		AirMap.rx_getAuthenticatedPilot()
			.doOnError {[unowned self] error in
				self.loadRequest() // reload
				self.authSessionDelegate?.airMapAuthSessionAuthenticationDidFail(error as NSError)
			}
			.subscribeNext {[unowned self]  pilot in
				self.authSessionDelegate?.airMapAuthSessionDidAuthenticate?(pilot)
			}
			.addDisposableTo(disposeBag)
	}

	/**
	Parses the `id_token` from the query parameters of the url string

	- parameter urlString: The urlString to parse

	*/
	private func parseTokens(urlString: String) -> (authToken: String?, refeshToken: String?) {

		let urlComponents = NSURLComponents(string: urlString)
		let queryItems = urlComponents?.queryItems
		return (queryItems?.filter({$0.name == "id_token"}).first?.value, queryItems?.filter({$0.name == "refresh_token"}).first?.value)
	}

	//MARK: - UIWebViewDelegate Methods

	public func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {

		let callbackUrl = NSURL(string: AirMap.configuration.auth0CallbackUrl)!
		
		if let url = request.URL {
			
			if url.host != nil && url.host! == callbackUrl.host! {
				
				let callbackUrl = AirMap.configuration.auth0CallbackUrl
				
				let findString = callbackUrl + "#"
				let replaceString = findString.stringByReplacingOccurrencesOfString("#", withString: "?")
				
				if let url = url.absoluteString?.stringByReplacingOccurrencesOfString(findString, withString: replaceString) {
					
					authenticateWithUrl(url)
				}
			}
		
		}

		return true
	}
}

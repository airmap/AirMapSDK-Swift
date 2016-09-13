//
//  AirMapMapView.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/20/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import Mapbox

public class AirMapMapView: MGLMapView {
	
	public static let defaultLayers: [AirMapLayerType] = [.EssentialAirspace, .TFRs, .Wildfires]
	public static let defaultTheme: AirMapMapTheme = .Light
	
	public convenience init(frame: CGRect, layers: [AirMapLayerType], theme: AirMapMapTheme) {
		self.init(frame: frame)
		
		setupMapView()
		configure(layers: layers, theme: theme)
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		setupMapView()
	}
	
	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)

		setupMapView()
	}
	
	public func configure(layers layers: [AirMapLayerType], theme: AirMapMapTheme) {
		styleURL = AirMap.getTileSourceUrl(layers, theme: theme)
	}
	
	private func setupMapView() {
		
		guard let mapboxAccessToken = AirMap.configuration.mapboxAccessToken else {
			fatalError("A Mapbox access token is required to use the AirMap SDK UI components.")
		}
		
		MGLAccountManager.setAccessToken(mapboxAccessToken)
		
		let bundle = NSBundle(forClass: AirMap.self)
		let image = UIImage(named: "info_icon", inBundle: bundle, compatibleWithTraitCollection: nil)!
		attributionButton.setImage(image.imageWithRenderingMode(.AlwaysOriginal), forState: .Normal)
		
		configure(layers: AirMapMapView.defaultLayers, theme: AirMapMapView.defaultTheme)
	}
	
}

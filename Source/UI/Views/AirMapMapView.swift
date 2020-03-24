//
//  AirMapMapView.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 7/20/16.
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
import Mapbox
import RxSwift
import RxCocoa

/// Principal view for displaying airspace information spatially on a map
open class AirMapMapView: MGLMapView {

	enum AirMapMapViewError: Error {
		case invalidDateRange
		case styleNotLoaded
	}

	/// Theme that determines the visual style of the map
	public enum Theme: String {
		case standard
		case dark
		case light
		case satellite
	}

	/// The current map theme
	public var theme: Theme = .standard {
		didSet { themeSubject.onNext(theme) }
	}

	/// The configuration the map uses to determine the behavior by which the map configures itself
	///
	/// - automatic: The map will be configured automatically. All `.required` rulesets will be enabled, and the default
	///      `.pickOne` rulesets will be enabled. None of the `.optional` rulesets will be enabled except for "AirMap
	///      Recommended" rulesets which will always be enabled.
	/// - dynamic: The map will use the provided list of preferred ruleset ids to enable any `.optional` and `.pickOne`
	///      rulesets as they are encountered. If `enableRecommendedRulesets` is false, none of the optional
	///      "AirMap Recommended" rulesets will be enabled, unless it is the only ruleset for a jurisdiction.
	/// - manual: The map will be configured with only the rulesets provided. It is the caller's responsibility to query
	///      the map for jurisdictions and make a determination as to which rulesets to display. The caller should
	///      reconfigure the map accordingly as the map's jurisdictions change. See: `AirMapMapViewDelegate`
	public enum RulesetConfiguration {
		case automatic
		case dynamic(preferredRulesetIds: [AirMapRulesetId], enableRecommendedRulesets: Bool)
		case manual(rulesets: [AirMapRuleset])
	}

	/// The current configuration that determines the behavior in which the map configures its rulesets
	/// Default: .automatic
	public var rulesetConfiguration: RulesetConfiguration = .automatic {
		didSet { rulesetConfigurationSubject.onNext(rulesetConfiguration) }
	}

	/// The filter used to limit the number of temporal features displayed on the map (e.g. TFRs, NOTAMs, etc.)
	/// Only features that occur during the sliding window or fixed range of time will be displayed. The default is a
	/// sliding window of 4 hours into the future.
	///
	/// - sliding: Given a time interval, filter the map from now until the end of the window; continuously sliding this
	///       window as time progresses
	/// - fixed: Given a fixed start and end time, filter the map to only show features that overlap with the window.
	///       It is the caller's responsibility to maintain and update this window as needed. Map features in the past
	///       are not available and therefore a start time before the current date and time is invalid.
	public enum TemporalRange {
		case sliding(window: TimeInterval)
		case fixed(start: Date, end: Date)
	}

	/// The time range for which temporal layers are displayed on the map.
	public var activeTemporalRange: TemporalRange {
		get { return try! temporalRangeSubject.value() }
		set { temporalRangeSubject.onNext(newValue) }
	}

	/// All jurisidictions intersecting the map's bounds/viewport. Each jurisdiction also provides the rulesets
	/// available within the jurisdiction even if they are not enabled or visible on the map
	public var jurisdictions: [AirMapJurisdiction] {
		return jurisdictions(intersecting: bounds)
	}

	/// The rulesets that the map is currently displaying
	public var activeRulesets: [AirMapRuleset] {
		return AirMapMapView.activeRulesets(from: jurisdictions, using: rulesetConfiguration)
	}

	/// The AirMap logo in the lower left corner.
	/// If you wish to remove the AirMap wordmark, please contact our sales team to discuss an Enterprise plan
	public var airMapLogoView: UIImageView!

	// MARK: - Init

	public override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}

	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setup()
	}

	// MARK: - Private

	private let themeSubject = BehaviorSubject(value: Theme.standard)
	private let temporalRangeSubject = BehaviorSubject(value: TemporalRange.sliding(window: Constants.Maps.futureTemporalWindow))
	private let rulesetConfigurationSubject = BehaviorSubject(value: RulesetConfiguration.automatic)

	private let disposeBag = DisposeBag()
}

// MARK: - Private

extension AirMapMapView {

	// MARK: - Getters

	private var airMapMapViewDelegate: AirMapMapViewDelegate? {
		return rx.delegate.forwardToDelegate() as? AirMapMapViewDelegate
	}

	// MARK: - Setup

	private func setup() {

		setupAccessToken()
		setupBindings()
		setupAppearance()
	}

	private func setupAccessToken() {

		guard MGLAccountManager.accessToken == nil else { return }

		guard let token = AirMap.configuration.mapboxAccessToken else {
			fatalError("A Mapbox access token is required to use the AirMap SDK UI map component. " +
				"https://www.mapbox.com/help/define-access-token/")
		}

		MGLAccountManager.accessToken = token
	}

	private func setupBindings() {

		// Configure the map with the latest theme
		themeSubject
			.bind(to: rx.theme)
			.disposed(by: disposeBag)

		// Ensure we remain the delegate via Rx and any other delegates are set as the forward delegate
		// Ignore Rx's delegate proxy to prevent infinite recursion
		// Delay to prevent reentry warnings
		let latestDelegate = rx.observeWeakly(MGLMapViewDelegate.self, "delegate", options: .new)
			.filter { !($0 is Optional<RxMGLMapViewDelegateProxy>) }
			.observeOn(MainScheduler.asyncInstance)
			.share()

		// The latest jurisdictions for each delegate
		let jurisdictions = latestDelegate
			.flatMapLatest({ [unowned self] (_) -> Observable<[AirMapJurisdiction]> in
				return self.rx.jurisdictions
			})

		// The latest style for each delegate
		let style = latestDelegate
			.flatMapLatest({ [unowned self] (_) -> Observable<MGLStyle> in
				return self.rx.mapDidFinishLoadingStyle.map({$1})
			})

		// The latest unique rulesets
		let rulesetConfig = self.rulesetConfigurationSubject
			.distinctUntilChanged(==)

		let accessToken = AirMap.authService.authState.asObservable()
			.map { $0.accessToken }
			.distinctUntilChanged(==)
		
		Observable.combineLatest(style, accessToken)
			.subscribe(onNext: AirMapMapView.configureJurisdictions)
			.disposed(by: disposeBag)

		Observable.combineLatest(jurisdictions, style, rulesetConfig)
			.observeOn(MainScheduler.asyncInstance)
			.subscribe(onNext: { [weak self] (jurisdictions, style, rulesetConfig) in
				guard let `self` = self else { return }

				// Configure the map with the active rulesets
				// Notify the delegate of available jurisdictions and activated rulesets
				let activeRulesets = AirMapMapView.activeRulesets(from: jurisdictions, using: rulesetConfig)
				AirMapMapView.configure(mapView: self, style: style, with: activeRulesets)
				// Notify the delegate of available jurisdictions and activated rulesets
				self.airMapMapViewDelegate?.airMapMapViewJurisdictionsDidChange(mapView: self, jurisdictions: jurisdictions)
				self.airMapMapViewDelegate?.airMapMapViewRegionDidChange(mapView: self, jurisdictions: jurisdictions, activeRulesets: activeRulesets)
			})
			.disposed(by: disposeBag)

		let range = self.temporalRangeSubject
		let refresh = Observable<Int>
			.timer(.seconds(0), period: Constants.Maps.temporalLayerRefreshInterval, scheduler: MainScheduler.instance)

		// Update temporal filters
		Observable.combineLatest(style, range, refresh)
			.subscribe(onNext: { (style, range, _) in
				switch range {
				case .fixed(let start, let end):
					style.updateTemporalFilters(from: start, to: end)
				case .sliding(let window):
					style.updateTemporalFilters(from: Date(), to: Date().addingTimeInterval(window))
				}
			})
			.disposed(by: disposeBag)

		// Localize and transition style
		style
			.subscribe(onNext: { (style) in
				style.localizeLabels(into: Locale.current)
				style.transition = MGLTransitionMake(1, 0)
			})
			.disposed(by: disposeBag)
	}

	private func setupAppearance() {

		let image = UIImage(named: "info_icon", in: AirMapBundle.ui, compatibleWith: nil)!
		attributionButton.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)

		let airMapLogo = UIImage(named: "map_logo", in: AirMapBundle.ui, compatibleWith: nil)
		airMapLogoView = UIImageView(image: airMapLogo)

		attributionButtonMargins = CGPoint(x: 6, y: 10)
		logoViewMargins = CGPoint(x: 30, y: 10)
		logoViewPosition = .bottomRight

		insertSubview(airMapLogoView, aboveSubview: logoView)
		airMapLogoView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			airMapLogoView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
			airMapLogoView.centerYAnchor.constraint(equalTo: logoView.centerYAnchor)
			])

		isPitchEnabled = false
		allowsRotating = false
	}

	// MARK: - Configuration
	private static func configure(mapView: AirMapMapView, style: MGLStyle, with rulesets: [AirMapRuleset]) {
		
		let rulesetSourceIds = rulesets
			.filter { $0.airspaceTypes.count > 0 }
			.map { $0.tileSourceIdentifier }

		let existingSourceIds = style.sources
			.compactMap { $0 as? MGLVectorTileSource }
			.compactMap { $0.identifier }
			.filter { $0.hasPrefix(Constants.Maps.rulesetSourcePrefix) }

		let orphanedSourceIds = Set(existingSourceIds).subtracting(rulesetSourceIds)
		let newSourceIds = Set(rulesetSourceIds).subtracting(existingSourceIds)

		// Remove orphaned ruleset sources
		orphanedSourceIds
			.forEach({ id in
				removeRuleset(id, from: style, in: mapView)
			})

		// Add new ruleset sources
		rulesets
			.filter({ newSourceIds.contains($0.tileSourceIdentifier) })
			.forEach({ (ruleset) in
				addRuleset(ruleset, to: style, in: mapView)
			})
	}

	// MARK: - Getters

	private func jurisdictions(intersecting rect: CGRect) -> [AirMapJurisdiction] {

		return visibleFeatures(in: rect, styleLayerIdentifiers: [Constants.Maps.jurisdictionsStyleLayerId])
			.compactMap { $0.attributes[Constants.Maps.jurisdictionFeatureAttributesKey] as? String }
			.compactMap { AirMapJurisdiction.tileServiceMapper.map(JSONString: $0) }
			.reduce(into: [AirMapJurisdiction]()) { (array, jurisdiction) in
				if !array.contains(jurisdiction) && !jurisdiction.rulesets.isEmpty {
					array.append(jurisdiction)
				}
		}
	}

	// MARK: - Static

	private static func configureJurisdictions(in style: MGLStyle, with authToken: String?) {
		
		if let source = style.source(withIdentifier: "jurisdictions") as? MGLVectorTileSource, let layer = style.layer(withIdentifier: "jurisdictions") {
			style.removeLayer(layer)
			style.removeSource(source)
		}

		guard style.source(withIdentifier: "jurisdictions") == nil else { return }

		let query = [
			"apikey": AirMap.configuration.apiKey,
			"access_token": AirMap.authToken,
		]
		.compactMap { key, value in
			guard let value = value else { return nil }
			return key + "=" + value
		}
		.joined(separator: "&")

		let jurisdictionsUrl = Constants.Api.jurisdictionsUrl + "?" + query
		let source = MGLVectorTileSource(identifier: "jurisdictions", tileURLTemplates: [jurisdictionsUrl], options: [
			.minimumZoomLevel: Constants.Maps.tileMinimumZoomLevel,
			.maximumZoomLevel: Constants.Maps.tileMaximumZoomLevel,
		])

		let layer = MGLFillStyleLayer(identifier: "jurisdictions", source: source)
		layer.sourceLayerIdentifier = "jurisdictions"

		layer.fillColor = NSExpression(forConstantValue: UIColor.clear)
		layer.fillOpacity = NSExpression(forConstantValue: 1)

		style.addSource(source)
		style.insertLayer(layer, at: 0)
	}

	private static func addRuleset(_ ruleset: AirMapRuleset, to style: MGLStyle, in mapView: AirMapMapView) {

		guard style.source(withIdentifier: ruleset.tileSourceIdentifier) == nil else { return }

		guard let rulesetTileSource = MGLVectorTileSource(ruleset: ruleset) else {
			AirMap.logger.error("Failed to create tile source", metadata: ["Ruleset": .string(ruleset.tileSourceIdentifier)])
			return
		}
		style.addSource(rulesetTileSource)

		style.airMapBaseStyleLayers(for: ruleset.airspaceTypes)
			.forEach { baseLayer in
				if let newLayer = mapView.newLayerClone(of: baseLayer, with: ruleset, from: rulesetTileSource) {
					AirMap.logger.debug("Adding airspace layer", metadata: [
						"ruleset": .stringConvertible(ruleset.id),
						"type": .stringConvertible(baseLayer.airspaceType ?? "unknown")]
					)
					var layer = newLayer as MGLStyleLayer
					style.insertLayer(layer, above: baseLayer)
					mapView.airMapMapViewDelegate?.airMapMapViewDidAddAirspaceType(
						mapView: mapView, ruleset: ruleset, airspaceType: layer.airspaceType!, layer: &layer
					)
				} else {
					AirMap.logger.error("Failed to add airspace layer", metadata: [
						"ruleset": .stringConvertible(ruleset.id),
						"type": .stringConvertible(baseLayer.airspaceType ?? "unknown")]
					)
				}
		}
	}

	private static func removeRuleset(_ sourceIdentifier: String, from style: MGLStyle, in mapView: AirMapMapView) {

		style.layers
			.compactMap { $0 as? MGLVectorStyleLayer }
			.filter { $0.sourceIdentifier == sourceIdentifier }
			.forEach { layer in
				style.removeLayer(layer)
				mapView.airMapMapViewDelegate?.airMapMapViewDidRemoveAirspaceType(mapView: mapView, airspaceType: layer.airspaceType!)
		}

		if let source = style.source(withIdentifier: sourceIdentifier) {
			AirMap.logger.debug("Removing tile source", metadata: ["id": .string(sourceIdentifier)])
			style.removeSource(source)
		}
	}

	private static func activeRulesets(from jurisdictions: [AirMapJurisdiction], using configuration: RulesetConfiguration) -> [AirMapRuleset] {

		switch configuration {

		case .automatic:
			return AirMapRulesetResolver.resolvedActiveRulesets(from: jurisdictions)

		case .dynamic(let ids, let recommended):
			return AirMapRulesetResolver.resolvedActiveRulesets(with: ids, from: jurisdictions, enableRecommendedRulesets: recommended)

		case .manual(let rulesets):
			return rulesets
		}
	}
}

extension AirMapMapView.RulesetConfiguration: Equatable {
	static public func ==(lhs: AirMapMapView.RulesetConfiguration, rhs: AirMapMapView.RulesetConfiguration) -> Bool {
		switch (lhs, rhs) {
		case (.automatic, .automatic):
			return true

		case (let .dynamic(ids1, enabled1), let .dynamic(ids2, enabled2)):
			return ids1 == ids2 && enabled1 == enabled2

		case (let .manual(rulesets1), let .manual(rulesets2)):
			return rulesets1 == rulesets2

		default:
			return false
		}
	}
}

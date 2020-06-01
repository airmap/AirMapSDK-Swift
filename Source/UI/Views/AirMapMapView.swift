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

	/// Show airspace that is inactive
	/// Default: true
	public var showInactiveAirspace: Bool = true {
		didSet { showInactiveAirspaceSubject.onNext(showInactiveAirspace) }
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

	/// A list of allowed Jurisdictions. If set, the map will only display rulesets and airspace for the jurisdiction ids
	/// provided. All areas falling outside of the provided jurisdiction boundaries will be shaded as unavailable.
	public var allowedJurisdictions: [AirMapJurisdictionId]? {
		get { return try? allowedJurisdictionsSubject.value() ?? [] }
		set { allowedJurisdictionsSubject.onNext(newValue) }
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

		var effectiveStart: Date {
			switch self {
			case .sliding:
				return Date()
			case .fixed(let start, _):
				return start
			}
		}

		var effectiveEnd: Date {
			switch self {
			case .sliding(let window):
				return Date().addingTimeInterval(window)
			case .fixed(_, let end):
				return end
			}
		}
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
	private let showInactiveAirspaceSubject = BehaviorSubject(value: true)
	private let temporalRangeSubject = BehaviorSubject(value: TemporalRange.sliding(window: Constants.Maps.futureTemporalWindow))
	private let rulesetConfigurationSubject = BehaviorSubject(value: RulesetConfiguration.automatic)
	private let allowedJurisdictionsSubject = BehaviorSubject(value: nil as [AirMapJurisdictionId]?)

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
		
		Observable.combineLatest(style, allowedJurisdictionsSubject, accessToken)
			.subscribe(onNext: AirMapMapView.configureJurisdictions)
			.disposed(by: disposeBag)

		let refresh = Observable<Int>
			.timer(.seconds(0), period: Constants.Maps.temporalLayerRefreshInterval, scheduler: MainScheduler.instance)

		let range = Observable.combineLatest(temporalRangeSubject, refresh)
			.withLatestFrom(temporalRangeSubject)

		Observable.combineLatest(jurisdictions, style, rulesetConfig, range)
			.observeOn(MainScheduler.asyncInstance)
			.subscribe(onNext: { [weak self] (jurisdictions, style, rulesetConfig, range) in
				guard let `self` = self else { return }

				// Configure the map with the active rulesets
				// Notify the delegate of available jurisdictions and activated rulesets
				let activeRulesets = AirMapMapView.activeRulesets(from: jurisdictions, using: rulesetConfig)
				AirMapMapView.configure(mapView: self, style: style, with: activeRulesets, range: range)
				// Notify the delegate of available jurisdictions and activated rulesets
				self.airMapMapViewDelegate?.airMapMapViewJurisdictionsDidChange(mapView: self, jurisdictions: jurisdictions)
				self.airMapMapViewDelegate?.airMapMapViewRegionDidChange(mapView: self, jurisdictions: jurisdictions, activeRulesets: activeRulesets)
			})
			.disposed(by: disposeBag)

		// Reload base style when toggling inactive airspace filter
		showInactiveAirspaceSubject
			.distinctUntilChanged()
			.subscribe(onNext: { [weak self] (_) in
				self?.reloadStyle(nil)
			})
			.disposed(by: disposeBag)

		// Hide inactive airspace when `showInactiveAirspace` is toggled
		style
			.withLatestFrom(showInactiveAirspaceSubject) { ($0, $1) }
			.subscribe(onNext: { (style, showInactiveAirspace) in
				if !showInactiveAirspace {
					style.hideInactiveAirspace()
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
	private static func configure(mapView: AirMapMapView, style: MGLStyle, with rulesets: [AirMapRuleset], range: TemporalRange) {

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
				addRuleset(ruleset, to: style, in: mapView, for: range)
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

	private static func configureJurisdictions(in style: MGLStyle, with allowedJurisdictions: [AirMapJurisdictionId]?, with authToken: String?) {

		let disabledLayerPrefix = "airmap|disabled_jurisdictions|"

		if let source = style.source(withIdentifier: Constants.Maps.jurisdictionsTileSourceId) {
			if let layer = style.layer(withIdentifier: Constants.Maps.jurisdictionsStyleLayerId) {
				style.removeLayer(layer)
			}
			for layer in style.layers.filter({ $0.identifier.hasPrefix(disabledLayerPrefix) }) {
				style.removeLayer(layer)
			}
			style.removeSource(source)
		}

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
		let source = MGLVectorTileSource(identifier: Constants.Maps.jurisdictionsTileSourceId, tileURLTemplates: [jurisdictionsUrl], options: [
			.minimumZoomLevel: Constants.Maps.tileMinimumZoomLevel,
			.maximumZoomLevel: Constants.Maps.tileMaximumZoomLevel,
		])
		style.addSource(source)

		let jurisdictionsLayer = MGLFillStyleLayer(identifier: Constants.Maps.jurisdictionsStyleLayerId, source: source)
		jurisdictionsLayer.sourceLayerIdentifier = Constants.Maps.jurisdictionsSourceLayerId
		jurisdictionsLayer.fillColor = NSExpression(forConstantValue: UIColor.clear)
		jurisdictionsLayer.fillOpacity = NSExpression(forConstantValue: 1)
		style.insertLayer(jurisdictionsLayer, at: 0)

		// ids for allowed jurisdictions
		if let allowedJurisdictions = allowedJurisdictions {
			let jurisdictionIds = allowedJurisdictions.map({ $0.rawValue })

			// get a reference to the syle's background layer
			let bg = style.layer(withIdentifier: Constants.Maps.backgroundStyleLayerId) as! MGLBackgroundStyleLayer

			let federal = AirMapJurisdiction.Region.federal.rawValue

			// create a fill that will dim the out of bounds areas with the bg color
			let boundsFill1 = MGLFillStyleLayer(identifier: disabledLayerPrefix + "fill|0", source: source)
			boundsFill1.sourceLayerIdentifier = Constants.Maps.jurisdictionsSourceLayerId
			boundsFill1.fillColor = bg.backgroundColor
			boundsFill1.fillOpacity = NSExpression(forConstantValue: 0.8) // 80%
			boundsFill1.predicate = NSPredicate(format: "(region == %@) && NOT (id IN %@)", federal, jurisdictionIds)
			style.addLayer(boundsFill1)

			// create a new fill layer with the hash pattern
			let boundsFill2 = MGLFillStyleLayer(identifier: disabledLayerPrefix + "fill|1", source: source)
			boundsFill2.sourceLayerIdentifier = Constants.Maps.jurisdictionsSourceLayerId
			boundsFill2.fillPattern = NSExpression(forConstantValue: "heliports_lines_pattern")
			boundsFill2.predicate = NSPredicate(format: "(region == %@) && NOT (id IN %@)", federal, jurisdictionIds)
			style.addLayer(boundsFill2)

			// create a new line layer for the supported geo bounds
			let boundsLine = MGLLineStyleLayer(identifier: disabledLayerPrefix + "line|0", source: source)
			boundsLine.sourceLayerIdentifier = Constants.Maps.jurisdictionsSourceLayerId
			boundsLine.lineWidth = NSExpression(forConstantValue: 2)
			boundsLine.lineColor = NSExpression(forConstantValue: UIColor.airMapDarkGray)
			boundsLine.predicate = NSPredicate(format: "id IN %@", jurisdictionIds)
			style.addLayer(boundsLine)
		}
	}

	private static func addRuleset(_ ruleset: AirMapRuleset, to style: MGLStyle, in mapView: AirMapMapView, for range: TemporalRange) {

		guard style.source(withIdentifier: ruleset.tileSourceIdentifier) == nil else { return }

		guard let rulesetTileSource = MGLVectorTileSource(ruleset: ruleset, range: range) else {
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

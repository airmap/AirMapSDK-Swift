//
//  MGLMapView+AirMap.swift
//  AirMapSDK
//
//  Created by Adolfo Martinelli on 10/7/16.
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

import Mapbox
import GLKit

extension MGLMapView {
	
	/// Clones an existing MGLVectorstyleLayer and applies a list of known properties to the new instance
	///
	/// - Parameters:
	///   - existingLayer: The layer style to clone and from which to source property values
	///   - ruleset: The ruleset that defines the classification layers that will back the style layer
	///   - source: The tile source to which associate the layer style
	/// - Returns: Returns a new style styled with the visual properties of the existing layer, and configured with the appropriate source, layer, and ruleset.
	func newLayerClone(of existingLayer: MGLVectorStyleLayer, with ruleset: AirMapRuleset, from source: MGLSource) -> MGLVectorStyleLayer? {
		
		let commonProps: [String] = [
			"predicate",
			"visible"
		]
		let lineProps: [String] = [
			// Layout
			"lineCap",
			"lineJoin",
			"lineMiterLimit",
			"lineRoundLimit",
			// Paint
			"lineOpacity",
			"lineColor",
			"lineTranslation",
			"lineTranslationAnchor",
			"lineWidth",
			"lineGapWidth",
			"lineOffset",
			"lineBlur",
			"lineDashPattern",
			"linePattern"
		]
		let fillProps: [String] = [
			"fillOpacity",
			"fillColor",
			"fillPattern"
		]
		let symbolProps: [String] = [
			// Layout
			"symbolPlacement",
			"symbolSpacing",
			"symbolAvoidsEdges",
			"iconAllowsOverlap",
			"iconIgnoresPlacement",
			"iconOptional",
			"iconRotationAlignment",
			"iconScale",
			"iconImageName",
			"iconPadding",
			"keepsIconUpright",
			"text",
			"textFontSize",
			"textFontNames",
			"maximumTextWidth",
			"textLineHeight",
			"textLetterSpacing",
			"textJustification",
			"textAnchor",
			"textPadding",
			"textTransform",
			"textOffset",
			"textAllowsOverlap",
			"textIgnoresPlacement",
			"textOptional",
			// Paint
			"iconOpacity",
			"iconColor",
			"iconHaloColor",
			"iconHaloWidth",
			"iconHaloBlur",
			"iconTranslation",
			"iconTranslationAnchor",
			"textOpacity",
			"textColor",
			"textHaloColor",
			"textHaloWidth",
			"textHaloBlur",
			"textTranslation",
			"textTranslationAnchor"
		]
		
		let uuid = UUID().uuidString
		
		let properties: [String]
		let newLayer: MGLVectorStyleLayer
		
		let layerId = [existingLayer.identifier, uuid].joined(separator: "|")
		
		switch existingLayer {
		case is MGLFillStyleLayer:
			newLayer = MGLFillStyleLayer(identifier: layerId, source: source)
			properties = commonProps+fillProps
		case is MGLLineStyleLayer:
			newLayer = MGLLineStyleLayer(identifier: layerId, source: source)
			properties = commonProps+lineProps
		case is MGLSymbolStyleLayer:
			newLayer = MGLSymbolStyleLayer(identifier: layerId, source: source)
			properties = commonProps+symbolProps
		default:
			AirMap.logger.warning("Unsupported layer type", metadata: ["layer": .stringConvertible(existingLayer)])
			return nil
		}
		
		newLayer.sourceLayerIdentifier = ruleset.id.rawValue + "_" + existingLayer.airspaceType!.rawValue
		
		// Loop through each property and copy it to the new layer
		properties.forEach { key in
			let baseValue = existingLayer.value(forKey: key)
			
			// MapBox does not accept empty expressions
			if let bv = baseValue as? NSExpression {
				if bv != NSExpression(forConstantValue: "") {
					newLayer.setValue(baseValue, forKey: key)
				}
			} else {
				newLayer.setValue(baseValue, forKey: key)
			}
		
		}
		
		return newLayer
	}
		
}

extension MGLStyle {
	
	var activeAirMapStyleLayers: [MGLVectorStyleLayer] {
		return layers
			.compactMap { $0 as? MGLVectorStyleLayer }
			.filter { $0.sourceIdentifier?.hasPrefix(Constants.Maps.rulesetSourcePrefix) ?? false }
	}
	
	func airMapBaseStyleLayers(for types: [AirMapAirspaceType]) -> [MGLVectorStyleLayer] {
		
		let vectorLayers = layers.compactMap { $0 as? MGLVectorStyleLayer }
		let airMapBaseLayers = vectorLayers
			.filter { $0.sourceIdentifier == "airmap" }
			.filter { $0.airspaceType != nil && types.contains($0.airspaceType!) }
		
		return airMapBaseLayers
	}

	/// Update the predicates to hide inactive airspace layers
	func hideInactiveAirspace() {

		layers
			.filter { $0.identifier.hasPrefix(Constants.Maps.airmapLayerPrefix)}
			.compactMap { $0 as? MGLVectorStyleLayer }
			.forEach({ (layer) in
				let activePredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [
					NSPredicate(format: "active == NULL"),
					NSPredicate(format: "active != NULL && active == YES")
				])
				if let existing = layer.predicate {
					layer.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
						existing,
						activePredicate
					])
				} else {
					layer.predicate = activePredicate
				}
			})
	}
}

extension MGLStyleLayer {
	
	var airspaceType: AirMapAirspaceType? {
		let components = identifier.components(separatedBy: "|")
		if components.count > 1 {
			return AirMapAirspaceType(rawValue: components[1]) ?? .unclassified
		} else {
			return nil
		}
	}
}

extension MGLVectorTileSource {
	
	convenience init?(ruleset: AirMapRuleset, range: AirMapMapView.TemporalRange) {

		let layerNames = ruleset.airspaceTypes.map { $0.rawValue }.joined(separator: ",")
		let options = [
			MGLTileSourceOption.minimumZoomLevel: NSNumber(value: Constants.Maps.tileMinimumZoomLevel),
			MGLTileSourceOption.maximumZoomLevel: NSNumber(value: Constants.Maps.tileMaximumZoomLevel)
		]
		let units: String
		switch AirMap.configuration.distanceUnits {
		case .imperial:
			units = "airmap"
		case .metric:
			units = "si"
		}

		let formatter = ISO8601DateFormatter()
		formatter.formatOptions = [.withInternetDateTime]

		let query = [
			"apikey": AirMap.configuration.apiKey,
			"access_token": AirMap.authToken,
			"units": units,
			"start": formatter.string(from: range.effectiveStart).addingPercentEncoding(withAllowedCharacters: .urlSafeCharacters),
			"end": formatter.string(from: range.effectiveEnd).addingPercentEncoding(withAllowedCharacters: .urlSafeCharacters)
		]
		.compactMap { key, value in
			guard let value = value else { return nil }
			return key + "=" + value
		}
		.joined(separator: "&")

		let sourcePath = Constants.Api.tileDataUrl + "/\(ruleset.id.rawValue)/\(layerNames)/{z}/{x}/{y}?\(query)"

		self.init(identifier: ruleset.tileSourceIdentifier, tileURLTemplates: [sourcePath], options: options)
	}
}

extension MGLCoordinateBounds {
	
	// Convert the bounding box into a polygon; remembering to close the polygon by passing the first point again
	public var geometry: AirMapPolygon {
		let nw = CLLocationCoordinate2D(latitude: ne.latitude, longitude: sw.longitude)
		let se = CLLocationCoordinate2D(latitude: sw.latitude, longitude: ne.longitude)
		let coordinates = [nw, ne, se, sw, nw]
		return AirMapPolygon(coordinates: [coordinates])
	}
}

extension AirMapRuleset {
	
	var tileSourceIdentifier: String {
		return Constants.Maps.rulesetSourcePrefix + id.rawValue
	}
}

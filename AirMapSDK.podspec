
Pod::Spec.new do |s|
	
	s.name              = 'AirMapSDK'
	s.module_name       = 'AirMap'
	s.author            = 'AirMap, Inc.'
	s.version           = '3.0.0.beta.3'
	s.summary           = 'AirMap SDK for iOS & macOS'
	s.description       = 'Create Flights, Send Telemetry Data, Get Realtime Traffic Alerts.'
	s.license           = { :type => 'Apache License, Version 2.0', :file => 'LICENSE' }
	s.homepage          = 'https://www.airmap.com/makers/'
	s.documentation_url = 'https://developers.airmap.com/docs/getting-started-ios'
	s.social_media_url  = 'https://twitter.com/AirMapIO'
	s.source = {
		:git => 'https://github.com/AirMap/AirMapSDK-Swift.git',
		:tag => s.version.to_s
	}
	s.cocoapods_version = '>= 1.4.0'
	s.frameworks = 'Foundation'
	s.swift_version = '4.1'
	
	s.ios.deployment_target = '9.0'
	s.osx.deployment_target = '10.11'
	
	s.default_subspecs = 'Core', 'Traffic', 'Telemetry', 'UI'

	s.subspec 'Core' do |core|
		core.ios.frameworks = 'UIKit'
		core.osx.frameworks = 'AppKit'
		core.source_files = ['Source/Core/**/*.{h,m,swift}', 'Source/Rx/*']
		core.dependency 'Alamofire'
		core.dependency 'AppAuth'
		core.dependency 'ObjectMapper'
		core.dependency 'SwiftTurf'
		core.dependency 'KeychainAccess'
		core.dependency 'RxSwift', '~> 4.0'
		core.dependency 'RxSwiftExt', '~> 3.4'
		core.dependency 'RxCocoa', '~> 4.0'
		core.dependency 'Log'
		core.resources = ['Resources/Core/*.{cer,pdf,xcassets}', 'Resources/Core/Localizations/**/*']
	end
	
	s.subspec 'UI' do |ui|
		ui.xcconfig = { 'OTHER_SWIFT_FLAGS' => '$(inherited) -DAIRMAP_UI' }
		ui.platform = :ios
		ui.frameworks = 'UIKit'
		ui.dependency 'AirMapSDK/Core'
		ui.dependency 'PhoneNumberKit'
		ui.dependency 'RxDataSources'
		ui.dependency 'Mapbox-iOS-SDK', '<4.0'
		ui.source_files = 'Source/UI/**/{*.swift}'
		ui.resources = ['Resources/UI/*.{xcassets}', 'Resources/UI/Localizations/**/*']
	end
	
	s.subspec 'Traffic' do |traffic|
		traffic.xcconfig = { 'OTHER_SWIFT_FLAGS' => '$(inherited) -DAIRMAP_TRAFFIC' }
		traffic.dependency 'AirMapSDK/Core'
		traffic.dependency 'SwiftMQTT', '>3.0.0', '~> 3.0'
		traffic.source_files = 'Source/Traffic/*'
	end
	
	s.subspec 'Telemetry' do |telemetry|
		telemetry.xcconfig = { 'OTHER_SWIFT_FLAGS' => '$(inherited) -DAIRMAP_TELEMETRY' }
		telemetry.dependency 'AirMapSDK/Core'
		telemetry.dependency 'CocoaAsyncSocket'
		telemetry.dependency 'CryptoSwift', '~> 0.10.0'
		telemetry.dependency 'ProtocolBuffers-Swift', '~> 4.0.6'
		telemetry.source_files = 'Source/Telemetry/*'
	end
	
end

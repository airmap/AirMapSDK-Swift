
Pod::Spec.new do |s|
	
	s.name              = 'AirMapSDK'
	s.module_name       = 'AirMap'
	s.author            = 'AirMap, Inc.'
	s.version           = '0.1.9'
	s.summary           = 'AirMap SDK for iOS & macOS'
	s.description       = 'Create Flights, Send Telemetry Data, Get Realtime Traffic Alerts.'
	s.license           = { :type => 'Custom', :file => 'LICENSE' }
	s.homepage          = 'https://www.airmap.com/makers/'
	s.documentation_url = 'https://developers.airmap.com/docs/ios-getting-started'
	s.social_media_url  = 'https://twitter.com/AirMapIO'
	s.source = {
		:git => 'https://github.com/AirMap/AirMapSDK-Swift.git',
		:tag => s.version.to_s
	}
	s.cocoapods_version = '>= 1.0.0'
	s.frameworks = 'Foundation'
	
	s.ios.deployment_target = '8.0'
	s.osx.deployment_target = '10.10'
	
	s.default_subspecs = 'Core', 'Traffic', 'Telemetry', 'UI'

	s.subspec 'Core' do |core|
		core.ios.frameworks = 'UIKit'
		core.osx.frameworks = 'AppKit'
		core.source_files = ['Source/Core/**/{*.h,*.m,*.swift}', 'Source/Rx/*']
		core.dependency 'SimpleKeychain'
		core.dependency 'Alamofire', '~> 3.5'
		core.dependency 'JWTDecode', '~> 1.2'
		core.dependency 'Log', '0.5'
		core.dependency 'ObjectMapper', '~> 1.4'
		core.dependency 'RxCocoa', '~> 2.6'
		core.dependency 'RxSwift', '~> 2.6'
		core.dependency 'RxSwiftExt', '~> 1.1.0'
		core.resources = ['Source/Resources/*.cer', 'Source/Resources/*.pdf', 'Source/Resources/*.xcassets']
	end
	
	s.subspec 'UI' do |ui|
		ui.platform = :ios
		ui.frameworks = 'UIKit'
		ui.dependency 'AirMapSDK/Core'
		ui.dependency 'libPhoneNumber-iOS', '~> 0.8.16'
		ui.dependency 'Mapbox-iOS-SDK', '~> 3.3'
		ui.dependency 'RxDataSources', '~> 0.9.0'
		ui.dependency 'Lock', '~> 1.27.1'
		ui.dependency 'SwiftSimplify'
		ui.dependency 'SwiftTurf'
		ui.source_files = 'Source/UI/**/{*.swift}'
		ui.resources = ['Source/UI/**/{*.storyboard,*.xcassets}']
	end
	
	s.subspec 'Traffic' do |traffic|
		traffic.xcconfig = { 'OTHER_SWIFT_FLAGS' => '$(inherited) -DAIRMAP_TRAFFIC' }
		traffic.dependency 'AirMapSDK/Core'
		traffic.dependency 'SwiftMQTT', '~> 1.0.2'
		traffic.source_files = 'Source/Traffic/*'
	end
	
	s.subspec 'Telemetry' do |telemetry|
		telemetry.xcconfig = { 'OTHER_SWIFT_FLAGS' => '$(inherited) -DAIRMAP_TELEMETRY' }
		telemetry.dependency 'AirMapSDK/Core'
		telemetry.dependency 'CocoaAsyncSocket', '~> 7.5.0'
		telemetry.dependency 'CryptoSwift', '~> 0.5.2'
		telemetry.dependency 'ProtocolBuffers-Swift', '~> 2.4'
		telemetry.source_files = 'Source/Telemetry/*'
	end
	
end

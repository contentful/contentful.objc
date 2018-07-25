#!/usr/bin/ruby

source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/contentful/CocoaPodsSpecs.git'

## iOS
target 'ContentfulDeliveryAPI' do
  platform :ios, "9.3"
  podspec :path => 'ContentfulDeliveryAPI.podspec'

end

## tvOS
target 'ContentfulDeliveryAPI_tvOS' do
  platform :tvos, "9.3"
  podspec :path => 'ContentfulDeliveryAPI.podspec'
end



# Cocoapods docs are wrong and don't work for 
target 'DeliveryTests' do
  platform :ios, "9.3"

  pod 'CCLRequestReplay', :git => 'https://github.com/neonichu/CCLRequestReplay.git'
  pod 'OCMock', :inhibit_warnings => true
  pod 'VCRURLConnection', '= 0.2.4', :inhibit_warnings => true
  pod 'FBSnapshotTestCase/Core', :inhibit_warnings => true
end


## Post install
post_install do |installer|

  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ONLY_ACTIVE_ARCH'] = "NO"
    end
  end
end

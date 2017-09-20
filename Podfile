#!/usr/bin/ruby

source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/contentful/CocoaPodsSpecs.git'


## Delivery API
target 'ContentfulDeliveryAPI' do
  platform :ios, "8.0"
  podspec :path => 'ContentfulDeliveryAPI.podspec'

  target 'Catalog' do
    inherit! :search_paths
    pod 'PDKTCollectionViewWaterfallLayout'
  end

  target 'UFO Example' do
    inherit! :search_paths
  end

  target 'CoreDataExample' do
    inherit! :search_paths
  end
end




# Cocoapods docs are wrong and don't work for 
target 'DeliveryTests' do
  platform :ios, "8.0"

  pod 'CCLRequestReplay', :git => 'https://github.com/neonichu/CCLRequestReplay.git'
  pod 'OCMock', :inhibit_warnings => true
  pod 'VCRURLConnection', '= 0.2.2', :inhibit_warnings => true
  pod 'Realm', '~> 2.5.0', :inhibit_warnings => true # Realm must be linked for the persistence layer and should match the same version in the submodule
  pod 'FBSnapshotTestCase/Core', :inhibit_warnings => true
end



plugin 'cocoapods-keys', {
  :project => 'ContentfulSDK',
  :target => 'ManagementTests',
  :keys => [ 'ManagementAPIAccessToken' ]
}


## Management API
target 'ContentfulManagementAPI' do
  platform :ios, "8.0"
  podspec :path => 'ContentfulManagementAPI.podspec'
end

target 'ManagementTests' do
  platform :ios, "8.0"
  pod 'Specta'
  pod 'Expecta', '= 1.0.5'
  pod 'VCRURLConnection', '= 0.2.2', :inhibit_warnings => true
end


## Post install
post_install do |installer|

  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ONLY_ACTIVE_ARCH'] = "NO"
    end
  end
end

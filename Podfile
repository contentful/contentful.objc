#!/usr/bin/ruby

source 'https://github.com/CocoaPods/Specs.git'
#source 'https://github.com/contentful/CocoaPodsSpecs.git'

platform :ios, "8.0"

## Delivery API
target 'ContentfulDeliveryAPI' do
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

  target 'SeedDatabaseExample' do
    inherit! :search_paths
  end

  target 'ContentfulSeedDatabase' do
    platform :osx, "10.9"
    inherit! :search_paths
  end
end

# Cocoapods docs are wrong and don't work for 
target 'DeliveryTests' do

  pod 'CCLRequestReplay', :git => 'https://github.com/neonichu/CCLRequestReplay.git'
  pod 'OCMock', :inhibit_warnings => true
  pod 'VCRURLConnection', :inhibit_warnings => true
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
  podspec :path => 'ContentfulManagementAPI.podspec'
end

target 'ManagementTests' do  
  pod 'Specta'
  pod 'Expecta'
  pod 'VCRURLConnection', :inhibit_warnings => true
end


## Post install
post_install do |installer|

  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ONLY_ACTIVE_ARCH'] = "NO"
    end
  end
end

#!/usr/bin/ruby

plugin 'cocoapods-keys', {
  :project => 'ContentfulSDK',
  :keys => [ 'ManagementAPIAccessToken' ]
}

source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/contentful/CocoaPodsSpecs.git'


platform :ios, "8.0"

podspec :path => 'ContentfulDeliveryAPI.podspec'
podspec :path => 'ContentfulManagementAPI.podspec'

target "ContentfulDeliveryAPI" do
  
  target "DeliveryTests" do
    inherit! :search_paths
    pod 'CCLRequestReplay', :git => 'https://github.com/neonichu/CCLRequestReplay.git'
    pod 'OCMock'
    pod 'VCRURLConnection', :inhibit_warnings => true
    pod 'Realm', '~> 2.5.0' # Realm must be linked for the persistence layer and should match the same version in the submodule
    pod 'FBSnapshotTestCase/Core'
  end

  target "Catalog" do
    inherit! :search_paths
    pod 'PDKTCollectionViewWaterfallLayout'
  end

  target "UFO Example" do
    inherit! :search_paths
  end

  target "CoreDataExample" do
    inherit! :search_paths
  end

  target "SeedDatabaseExample" do
    inherit! :search_paths
  end

  target "ContentfulSeedDatabase" do
    platform :osx, "10.9"
    inherit! :search_paths
  end
end




# Management API
target "ContentfulManagementAPI" do

  target "ManagementTests" do 
    inherit! :search_paths
    pod 'Specta'
    pod 'Expecta'
    pod 'VCRURLConnection'
  end
end

post_install do |installer_or_rep|
  installer = installer_or_rep.respond_to?(:installer) ? installer_or_rep.installer : installer_or_rep

  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ONLY_ACTIVE_ARCH'] = "NO"
    end
  end
end

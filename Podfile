#!/usr/bin/ruby

source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/contentful/CocoaPodsSpecs.git'


platform :ios, "7.0"

target "ContentfulDeliveryAPI" do
  pod 'AFNetworking'
  pod 'ISO8601DateFormatter'

  target "CDA Tests" do
    inherit! :search_paths

    pod 'CCLRequestReplay', :git => 'https://github.com/neonichu/CCLRequestReplay.git'
    pod 'OCMock'
    pod 'VCRURLConnection', :inhibit_warnings => true
    pod 'ContentfulPersistence/CoreData'
    pod 'ContentfulPersistence/Realm', '>= 0.6.0'
    pod 'FBSnapshotTestCase/Core'
  end
end

target "Catalog" do
  pod 'ContentfulDeliveryAPI', :path => '.'
  pod 'PDKTCollectionViewWaterfallLayout'
end


target "UFO Example" do    
pod 'ContentfulDeliveryAPI', :path => '.'
end


target "CoreDataExample" do
  pod 'ContentfulDeliveryAPI', :path => '.'
  pod 'ContentfulPersistence/CoreData'
end

target "SeedDatabaseExample" do
  pod 'ContentfulDeliveryAPI', :path => '.'
  pod 'ContentfulPersistence/CoreData'
end

target "ContentfulSeedDatabase" do
  platform :osx, "10.9"

  pod 'ContentfulDeliveryAPI', :path => '.'
  pod 'ContentfulPersistence/CoreData'
end


post_install do |installer_or_rep|
  # Support both CP 0.36.1 and >= 0.38
  installer = installer_or_rep.respond_to?(:installer) ? installer_or_rep.installer : installer_or_rep

  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ONLY_ACTIVE_ARCH'] = "NO"
    end
  end
end

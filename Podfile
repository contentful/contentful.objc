source 'https://github.com/CocoaPods/Specs.git'

platform :ios, "6.0"

target "ContentfulDeliveryAPI", :exclusive => true do

pod 'AFNetworking', :inhibit_warnings => true
pod 'ISO8601DateFormatter'
pod 'HRCoder'

end

target "CDA Tests", :exclusive => true do

pod 'CCLRequestReplay', :git => 'https://github.com/neonichu/CCLRequestReplay.git'
pod 'FBSnapshotTestCase', :head
pod 'OCMock'
pod 'VCRURLConnection', :inhibit_warnings => true

end

target "Catalog", :exclusive => true do

pod 'ContentfulDeliveryAPI', :path => '.'
pod 'PDKTCollectionViewWaterfallLayout'

end

target "ContentfulSeedDatabase", :exclusive => true do

platform :osx, "10.8"

pod 'ContentfulDeliveryAPI', :path => '.'

end

target "CoreDataExample", :exclusive => true do

pod 'ContentfulDeliveryAPI', :path => '.'

end

target "SeedDatabaseExample", :exclusive => true do

pod 'ContentfulDeliveryAPI', :path => '.'

end

target "UFO Example", :exclusive => true do

pod 'ContentfulDeliveryAPI', :path => '.'
pod 'AFNetworking', :inhibit_warnings => true

end

post_install do |installer|
  installer.project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ONLY_ACTIVE_ARCH'] = "NO"
    end
  end
end

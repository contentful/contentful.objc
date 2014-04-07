platform :ios, "6.0"

target "ContentfulDeliveryAPI", :exclusive => true do

pod 'AFNetworking', :inhibit_warnings => true
pod 'ISO8601DateFormatter'

end

target "CDA Tests", :exclusive => true do

pod 'FBSnapshotTestCase'
pod 'OCMock'
pod 'OHHTTPStubs'
pod 'VCRURLConnection'

end

target "Browser", :exclusive => true do

pod 'ContentfulDeliveryAPI', :path => '.'
pod 'Bypass', :inhibit_warnings => true

end

target "Catalog", :exclusive => true do

pod 'ContentfulDeliveryAPI', :path => '.'
pod 'PDKTCollectionViewWaterfallLayout'

end

target "CoreDataExample", :exclusive => true do

pod 'ContentfulDeliveryAPI', :path => '.'

end

target "UFO Example", :exclusive => true do

pod 'ContentfulDeliveryAPI', :path => '.'

end

post_install do |installer|
  installer.project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ONLY_ACTIVE_ARCH'] = "NO"
    end
  end
end

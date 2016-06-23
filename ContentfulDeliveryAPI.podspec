Pod::Spec.new do |s|
  s.name             = "ContentfulDeliveryAPI"
  s.version          = "1.10.3"
  s.summary          = "Objective-C SDK for Contentful's Content Delivery API."
  s.homepage         = "https://github.com/contentful/contentful.objc/"
  s.social_media_url = 'https://twitter.com/contentful'

  s.license = {
    :type => 'MIT',
    :file => 'LICENSE'
  }

  s.authors      = { "Boris Bügling" => "boris@buegling.com" }
  s.source       = { :git => "https://github.com/contentful/contentful.objc.git",
                     :tag => s.version.to_s }
  s.requires_arc = true

  s.source_files         = 'Code/*.{h,m}',
  s.public_header_files  = 'Code/{CDAArray,CDAAsset,CDAClient,CDAConfiguration,CDAContentType,CDAEntry,CDAError,CDAField,CDANullabilityStubs,CDARequest,CDAResource,CDAResponse,CDASpace,CDASyncedSpace,ContentfulDeliveryAPI,CDAPersistenceManager,CDAPersistedAsset,CDAPersistedEntry,CDAPersistedSpace,CDALocalizablePersistedEntry,CDALocalizedPersistedEntry}.h'

  s.ios.deployment_target     = '7.0'
  s.ios.source_files          = 'Code/UIKit/*.{h,m}'
  s.ios.frameworks            = 'UIKit', 'MapKit'
  s.ios.public_header_files  = 'Code/UIKit/{CDAEntriesViewController,CDAFieldsViewController,UIImageView+CDAAsset,CDAMapViewController,CDAResourcesCollectionViewController,CDAResourcesViewController,CDAResourceCell}.h'

  s.osx.deployment_target     = '10.9'

  s.dependency 'AFNetworking', '~> 3.0.4'
  s.dependency 'ISO8601DateFormatter', '0.7'
end

#!/usr/bin/ruby

require 'dotenv/load'

Pod::Spec.new do |s|
  s.name             = "ContentfulDeliveryAPI"
  s.version          = ENV['DELIVERY_SDK_VERSION']
  s.summary          = "Objective-C SDK for Contentful's Content Delivery API."
  s.homepage         = "https://github.com/contentful/contentful.objc/"
  s.social_media_url = 'https://twitter.com/contentful'

  s.license = {
    :type => 'MIT',
    :file => 'LICENSE'
  }

  s.authors      = { "Boris Bügling" => "boris@buegling.com", "JP Wright" => "jp@contentful.com" }
  s.source       = { :git => "https://github.com/contentful/contentful.objc.git",
                     :tag => "Delivery-#{s.version.to_s}" }
  s.requires_arc = true

  s.source_files = [
    'ContentfulDeliveryAPI/Resources/*.{h,m}',
    'ContentfulDeliveryAPI/*.{h,m}', 
    'Versions.h'
  ]
  s.public_header_files  = [
    'ContentfulDeliveryAPI/Resources/{CDAArray,CDAAsset,CDAContentType,CDAEntry,CDAError,CDASpace,CDAResource}.h',
    'ContentfulDeliveryAPI/{CDAClient,CDAConfiguration,CDANullabilityStubs,CDARequest,CDAResponse,CDAField,CDASyncedSpace,ContentfulDeliveryAPI,CDAPersistenceManager,CDAPersistedAsset,CDAPersistedEntry,CDAPersistedSpace,CDALocalizablePersistedEntry,CDALocalizedPersistedEntry}.h'
  ]
  # iOS specific
  s.ios.deployment_target     = '8.0'
  s.ios.source_files          = 'ContentfulDeliveryAPI/UIKit/*.{h,m}'
  s.ios.frameworks            = 'UIKit', 'MapKit'
  s.ios.public_header_files   = 'ContentfulDeliveryAPI/UIKit/{CDAEntriesViewController,CDAFieldsViewController,UIImageView+CDAAsset,CDAMapViewController,CDAResourcesCollectionViewController,CDAResourcesViewController,CDAResourceCell}.h'

  # macOS specific
  s.osx.deployment_target     = '10.12'
  
  # tvOS specific
  s.tvos.deployment_target    = '9.0'
  s.tvos.source_files          = 'ContentfulDeliveryAPI/UIKit/*.{h,m}'
  s.tvos.frameworks            = 'UIKit', 'MapKit'
  s.tvos.public_header_files   = 'ContentfulDeliveryAPI/UIKit/{CDAEntriesViewController,CDAFieldsViewController,UIImageView+CDAAsset,CDAMapViewController,CDAResourcesCollectionViewController,CDAResourcesViewController,CDAResourceCell}.h'


  s.dependency 'AFNetworking', '~> 3.2.1'
  s.dependency 'ISO8601', '~> 0.6.0'
end


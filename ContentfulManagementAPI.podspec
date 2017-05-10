#!/usr/bin/ruby

Pod::Spec.new do |spec|

  spec.name             = "ContentfulManagementAPI"
  spec.version          = "0.10.0"
  spec.summary          = "Objective-C SDK for Contentful's Content Management API."
  spec.homepage         = "https://github.com/contentful/contentful-management.objc"
  spec.author           = { "Boris Bügling" => "boris@buegling.com" }
  spec.source           = { :git => "https://github.com/contentful/contentful-management.objc.git",
                            :tag => spec.version.to_s }
  spec.social_media_url = 'https://twitter.com/contentful'

  spec.license = {
       :type => 'MIT',
       :file => 'LICENSE'
  }

  spec.ios.deployment_target     = '8.0'
  spec.osx.deployment_target     = '10.10'
  spec.requires_arc = true

  spec.source_files = ['ContentfulDeliveryAPI/Resources/*.{h,m}','ContentfulDeliveryAPI/*.{h,m}', 'ManagementAPI/Private/*.{h,m}', 'ManagementAPI/Public/*.h']
  
  spec.public_header_files = ['ManagementAPI/Public/*.h', 'ContentfulDeliveryAPI/Resources/{CDAArray,CDAAsset,CDAContentType,CDAEntry,CDAError,CDASpace,CDAResource,CDAOrganizationContainer}.h','ContentfulDeliveryAPI/{CDAClient,CDAConfiguration,CDANullabilityStubs,CDARequest,CDAResponse,CDAField,CDASyncedSpace,ContentfulDeliveryAPI,CDAPersistenceManager,CDAPersistedAsset,CDAPersistedEntry,CDAPersistedSpace,CDALocalizablePersistedEntry,CDALocalizedPersistedEntry}.h']

  spec.xcconfig = { 'USER_HEADER_SEARCH_PATHS' => ['ContentfulDeliveryAPI/Resources/', 'ContentfulDeliveryAPI/', 'ManagementAPI/Private/', 'ManagementAPI/Public/'] }
  spec.ios.source_files          = 'ContentfulDeliveryAPI/UIKit/*.{h,m}'
  spec.ios.frameworks            = 'UIKit', 'MapKit'
  spec.ios.public_header_files  = 'ContentfulDeliveryAPI/UIKit/{CDAEntriesViewController,CDAFieldsViewController,UIImageView+CDAAsset,CDAMapViewController,CDAResourcesCollectionViewController,CDAResourcesViewController,CDAResourceCell}.h'

  spec.dependency 'AFNetworking', '~> 3.1.0'
  spec.dependency 'ISO8601', '~> 0.6.0'
end

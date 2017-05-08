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

  spec.dependency 'ContentfulDeliveryAPI', '~> 2.0.1'

  spec.source_files = 'ManagementAPI/*{h,m}'
  spec.public_header_files = 'ManagementAPI/{}.h'
end

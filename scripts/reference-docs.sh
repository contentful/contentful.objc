#!/bin/sh

echo "Generating Jazzy Reference Documentation"

SDK_VERSION=2.0.1
SDK_NAME="ContentfulDeliveryAPI"
xcodebuild_arguments="--objc,ContentfulDeliveryAPI/ContentfulDeliveryAPI.h,--,-x,objective-c,-isysroot,$(xcrun --show-sdk-path),-I,$(pwd)"

jazzy \
  --clean \
  --objc \
  --author Contentful \
  --author_url https://www.contentful.com \
  --github_url https://github.com/contentful/contentful.objc \
  --github-file-prefix https://github.com/contentful/contentful.objc/tree/$SDK_VERSION \
  --module-version $SDK_VERSION \
  --module $SDK_NAME \
  --umbrella-header ContentfulDeliveryAPI/ContentfulDeliveryAPI.h \
  --framework-root ./ContentfulDeliveryAPI/ \
  --sdk iphonesimulator \
  --theme apple
#   --xcodebuild-arguments ${xcodebuild_arguments} \

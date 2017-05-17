#!/bin/sh

set -x -o pipefail


function testCDA {
  echo "Testing CDA SDK"
  
  # -jobs -- specify the number of concurrent jobs
  # `sysctl -n hw.ncpu` -- fetch number of 'logical' cores in macOS machine
  xcodebuild -jobs `sysctl -n hw.ncpu` test -workspace ContentfulSDK.xcworkspace -scheme ContentfulDeliveryAPI \
    -sdk ${IOS_SDK} -destination "platform=iOS Simulator,name=${DEVICE_NAME},OS=${IOS_VERSION}" \
      ONLY_ACTIVE_ARCH=NO CODE_SIGNING_IDENTITY="" CODE_SIGNING_REQUIRED=NO | xcpretty -c
}


function testCMA {
  echo "Testing CMA SDK"

  xcodebuild -jobs `sysctl -n hw.ncpu` test -workspace ContentfulSDK.xcworkspace -scheme ContentfulManagementAPI \
    -sdk ${IOS_SDK} -destination "platform=iOS Simulator,name=${DEVICE_NAME},OS=${IOS_VERSION}" \
      ONLY_ACTIVE_ARCH=NO CODE_SIGNING_IDENTITY="" CODE_SIGNING_REQUIRED=NO | xcpretty -c

}


# GO
if [[ "$CONTENTFUL_SDK" == "CDA" ]]; then
  testCDA

elif [[ "$CONTENTFUL_SDK" == "CMA" ]]; then
  testCMA
fi




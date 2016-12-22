#!/bin/sh

set -x -o pipefail

echo "Building"

xcodebuild test -workspace ContentfulSDK.xcworkspace -scheme ContentfulDeliveryAPI \
  -sdk ${SDK} -destination "platform=iOS Simulator,name=${DEVICE_NAME},OS=${OS_VERSION}" \
    ONLY_ACTIVE_ARCH=NO CODE_SIGNING_IDENTITY="" CODE_SIGNING_REQUIRED=NO | xcpretty -c


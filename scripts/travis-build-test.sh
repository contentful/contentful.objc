#!/bin/sh

set -x -o pipefail

echo "Building"

make clean_simulators

rm -rf ${HOME}/Library/Developer/Xcode/DerivedData/*

# -jobs -- specify the number of concurrent jobs
# `sysctl -n hw.ncpu` -- fetch number of 'logical' cores in macOS machine
xcodebuild -jobs `sysctl -n hw.ncpu` test -workspace ContentfulSDK.xcworkspace -scheme ContentfulDeliveryAPI \
  -sdk ${SDK} -destination "platform=iOS Simulator,name=${DEVICE_NAME},OS=${OS_VERSION}" \
    ONLY_ACTIVE_ARCH=NO CODE_SIGNING_IDENTITY="" CODE_SIGNING_REQUIRED=NO | xcpretty -c


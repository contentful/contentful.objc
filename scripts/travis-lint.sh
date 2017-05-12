#!/bin/sh


set -x -o pipefail

# GO
if [[ "$CONTENTFUL_SDK" == "CDA" ]]; then
  bundle exec pod lib lint ContentfulDeliveryAPI.podspec

elif [[ "$CONTENTFUL_SDK" == "CMA" ]]; then
  bundle exec pod lib lint ContentfulManagementAPI.podspec
fi


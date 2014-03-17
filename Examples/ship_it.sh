#!/bin/sh

zip --symlinks -vr UFO.zip UFO/ -x "*.DS_Store"

cd UFO/Distribution &&
zip --symlinks -vr ContentfulDeliveryAPI.zip \
  ContentfulDeliveryAPI.framework/ &&
mv ContentfulDeliveryAPI.zip ../.. &&
cd -


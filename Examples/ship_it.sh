#!/bin/sh

zip --symlinks -vr UFO.zip UFO/ -x "*.DS_Store"

cd UFO/Distribution &&
zip --symlinks -vr ContentfulDeliveryAPI.zip \
  ContentfulDeliveryAPI.framework/ -x "*.DS_Store" &&
mv ContentfulDeliveryAPI.zip ../.. &&
cd -


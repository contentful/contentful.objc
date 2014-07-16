#!/bin/sh

VERSION=`pod spec cat ContentfulDeliveryAPI|grep version|head -n 1|cut -d\" -f4`

rm -rf ContentfulDeliveryAPI.framework
cp -Rp ../../../ContentfulDeliveryAPI-$VERSION/ContentfulDeliveryAPI-ios.framework ContentfulDeliveryAPI.framework

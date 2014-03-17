#!/bin/sh

rm -rf ContentfulDeliveryAPI.framework
cp -Rp "`ls -d $HOME/Library/Developer/Xcode/DerivedData/ContentfulSDK-*/Build/Products/Debug-iphoneos/ContentfulDeliveryAPI.framework`" .

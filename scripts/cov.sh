#!/bin/sh

INTERMEDIATES="`ls -d $HOME/Library/Developer/Xcode/DerivedData/ContentfulSDK-*/Build/Intermediates/ContentfulSDK.build/Debug-iphonesimulator/ContentfulDeliveryAPI.build`"
killall CoverStory
open `find "$INTERMEDIATES" -name '*.gcda'`

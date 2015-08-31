#!/bin/sh

VERSION=`pod spec cat ContentfulDeliveryAPI|grep version|tail -n 1|cut -d\" -f4`

s3cmd --acl-public put UFO.zip s3://static.cdnorigin.contentful.com/downloads/iOS/UFO.zip

s3cmd --acl-public put ContentfulDeliveryAPI.zip s3://static.cdnorigin.contentful.com/downloads/iOS/ContentfulDeliveryAPI-$VERSION.zip

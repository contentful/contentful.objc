#!/bin/sh

OLD_VERSION='0\.8\.0'
NEW_VERSION=0.9.0

for recording in *.recording
do
	plutil -convert xml1 $recording
	sed -i '' "s/$OLD_VERSION/$NEW_VERSION/" $recording
	plutil -convert binary1 $recording
done

echo "Recordings updated to $NEW_VERSION"

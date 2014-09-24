#!/bin/sh

sed -i '' 's/(nonatomic) BOOL/(nonatomic, assign) BOOL/' *.h
sed -i '' 's/(nonatomic) CDAResourceType/(nonatomic, assign) CDAResourceType/' *.h
sed -i '' 's/(nonatomic)/(nonatomic, retain)/' *.h

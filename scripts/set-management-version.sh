#!/bin/bash

sed -i '' 's%\(^.*MANAGEMENT_SDK_VERSION @"\)\(.*\)\("\)%\1'$1'\3%g' Versions.h
sed -i '' 's%\(^.*MANAGEMENT_SDK_VERSION=\)\(.*\)%\1'$1'%g' .env
sed -i '' 's%\(^.*MANAGEMENT_SDK_VERSION=\)\(.*\)%\1'$1'%g' .envrc
direnv allow

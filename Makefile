WORKSPACE=ContentfulSDK.xcworkspace

.PHONY: all clean doc example example-static pod really-clean static-lib test

clean:
	rm -rf build Examples/UFO/build Examples/*.zip compile_commands.json .gutter.json

really-clean: clean
	rm -rf Pods $(HOME)/Library/Developer/Xcode/DerivedData/*

all: test example-static

pod:
	pod install

example:
	set -o pipefail && xcodebuild -workspace $(WORKSPACE) \
		-scheme ContentfulDeliveryAPI \
		-sdk iphonesimulator | xcpretty -c
	set -o pipefail && xcodebuild -workspace $(WORKSPACE) \
		-scheme 'UFO Example' \
		-sdk iphonesimulator | xcpretty -c

example-static: static-lib
	cd Examples/UFO; set -o pipefail && xcodebuild \
		-sdk iphonesimulator | xcpretty -c

static-lib:
	pod repo update >/dev/null
	pod package ContentfulDeliveryAPI.podspec

	@cd Examples/UFO/Distribution; ./update.sh
	cd Examples; ./ship_it.sh

	rm -rf ContentfulDeliveryAPI-*/

test: example
	pod lib coverage

lint:
	set -o pipefail && xcodebuild -workspace $(WORKSPACE) -dry-run \
		-scheme ContentfulDeliveryAPI \
		-sdk iphonesimulator clean build|xcpretty -r json-compilation-database \
		-o compile_commands.json
	oclint-json-compilation-database

doc:
	pod lib docstats

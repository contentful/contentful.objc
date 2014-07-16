WORKSPACE=ContentfulSDK.xcworkspace

.PHONY: all clean doc example example-static pod really-clean static-lib test

clean:
	rm -rf build Examples/UFO/build Examples/*.zip compile_commands.json

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
	@sed -i '' -e 's/GCC_GENERATE_TEST_COVERAGE_FILES = YES/GCC_GENERATE_TEST_COVERAGE_FILES = NO/g' ContentfulSDK.xcodeproj/project.pbxproj
	@sed -i '' -e 's/GCC_INSTRUMENT_PROGRAM_FLOW_ARCS = YES/GCC_INSTRUMENT_PROGRAM_FLOW_ARCS = NO/g' ContentfulSDK.xcodeproj/project.pbxproj

	pod package ContentfulDeliveryAPI.podspec

	@cd Examples/UFO/Distribution; ./update.sh
	cd Examples; ./ship_it.sh

	@sed -i '' -e 's/GCC_GENERATE_TEST_COVERAGE_FILES = NO/GCC_GENERATE_TEST_COVERAGE_FILES = YES/g' ContentfulSDK.xcodeproj/project.pbxproj
	@sed -i '' -e 's/GCC_INSTRUMENT_PROGRAM_FLOW_ARCS = NO/GCC_INSTRUMENT_PROGRAM_FLOW_ARCS = YES/g' ContentfulSDK.xcodeproj/project.pbxproj

	rm -rf ContentfulDeliveryAPI-*/

test: example
	pod lib testing

lint:
	set -o pipefail && xcodebuild -workspace $(WORKSPACE) -dry-run \
		-scheme ContentfulDeliveryAPI \
		-sdk iphonesimulator clean build|xcpretty -r json-compilation-database \
		-o compile_commands.json
	oclint-json-compilation-database

doc:
	appledoc --project-name 'Contentful Delivery API' \
		--project-version 1.0 \
		--project-company 'Contentful GmbH' \
		--company-id com.contentful \
		--output ./doc \
		--create-html \
		--no-create-docset \
		--no-install-docset \
		--no-publish-docset \
		--no-keep-intermediate-files \
		--no-keep-undocumented-objects \
		--no-keep-undocumented-members \
		--merge-categories \
		--warn-missing-output-path \
		--warn-missing-company-id \
		--warn-undocumented-object \
		--warn-undocumented-member \
		--warn-empty-description \
		--warn-unknown-directive \
		--warn-invalid-crossref \
		--warn-missing-arg \
		--logformat 1 \
		--verbose 2 ./Code

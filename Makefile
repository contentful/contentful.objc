__SIM_ID=`xcrun simctl list|egrep -m 1 '$(SIM_NAME) \([^(]*\) \([^(]*\)$$'|sed -e 's/.* (\(.*\)) (.*)/\1/'`
SIM_NAME=iPhone 6s
SIM_ID=$(shell echo $(__SIM_ID))

ifeq ($(strip $(SIM_ID)),)
$(error Could not find $(SIM_NAME) simulator)
endif

WORKSPACE=ContentfulSDK.xcworkspace

.PHONY: all open clean clean_simulators clean_pods doc example example-static pod static-lib test kill_simulator docs

open:
	open ContentfulSDK.xcworkspace

clean_pods:
	rm -rf Pods/

clean: clean_simulators
	rm -rf $(HOME)/Library/Developer/Xcode/DerivedData/*

clean_simulators: kill_simulator
	xcrun simctl erase all

all: test example_static

pod:
	bundle exec pod install
	xcversion select 7.3.1
	xcrun bitcode_strip -r Pods/Realm/core/librealm-ios.a -o Pods/Realm/core/librealm-ios.a

example:
	set -o pipefail && xcodebuild clean build -workspace $(WORKSPACE) \
		-scheme ContentfulDeliveryAPI \
		-sdk iphonesimulator -destination 'id=$(SIM_ID)'| xcpretty -c
	set -o pipefail && xcodebuild clean build -workspace $(WORKSPACE) \
		-scheme 'UFO Example' \
		-sdk iphonesimulator -destination 'id=$(SIM_ID)'| xcpretty -c

example_static: static_lib
	cd Examples/UFO; set -o pipefail && xcodebuild clean build \
		-sdk iphonesimulator -destination 'id=$(SIM_ID)'| xcpretty -c

static_lib:
	bundle exec pod repo update >/dev/null
	bundle exec pod package ContentfulDeliveryAPI.podspec

	@cd Examples/UFO/Distribution; ./update.sh
	cd Examples; ./ship_it.sh

	rm -rf ContentfulDeliveryAPI-*/

kill_simulator:
	killall "Simulator" || true

cda: clean_simulators
	set -x -o pipefail && xcodebuild -jobs `sysctl -n hw.ncpu` test -workspace $(WORKSPACE) \
		-scheme 'ContentfulDeliveryAPI' -sdk iphonesimulator \
		-destination 'platform=iOS Simulator,name=iPhone 6s,OS=11.4'| xcpretty -c 
	kill_simulator	
	bundle exec pod lib coverage

integration_test: really_clean clean_simulators
	set -x -o pipefail && xcodebuild test -workspace $(WORKSPACE) \
		-scheme 'ContentfulDeliveryAPI' -configuration "API_Coverage" \
		-sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 6s,OS=9.3' | xcpretty -c

lint:
	set -o pipefail && xcodebuild clean build -workspace $(WORKSPACE) -dry-run \
		-scheme ContentfulDeliveryAPI \
		-sdk iphonesimulator -destination 'id=$(SIM_ID)' clean build| \
		xcpretty -r json-compilation-database -o compile_commands.json
	oclint-json-compilation-database

docs:
	./scripts/reference-docs.sh



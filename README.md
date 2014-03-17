# contentful.objc

[![Build Status](https://travis-ci.org/contentful/contentful.objc.png?branch=master)](https://travis-ci.org/contentful/contentful.objc)

Objective-C SDK for [Contentful's][1] Content Delivery API.

[Contentful][1] is a content management platform for web applications, mobile apps and connected devices. It allows you to create, edit & manage content in the cloud and publish it anywhere via powerful API. Contentful offers tools for managing editorial teams and enabling cooperation between organizations.

## Usage

The `CDAClient` manages all your interaction with the Contentful Delivery API.

    CDAClient* client = [[CDAClient alloc] initWithSpaceKey:@"cfexampleapi" accessToken:@"b4c0n73n7fu1"];
    [client fetchEntryWithIdentifier:@"nyancat"
                             success:^(CDAResponse *response, CDAEntry *entry) {
                                 NSLog(@"%@", entry.fields);
                             }
                             failure:^(CDAResponse *response, NSError *error) {
                                 NSLog(@"%@", error);
                             }];

You can query for entries, assets, etc. with query options similar to what is described in the [Delivery API Documentation][6]:

    [client fetchEntriesMatching:@{ @"content_type": @"cat" }
                             success:^(CDAResponse *response, CDAArray *entries) {
                                 NSLog(@"%@", [[entries.items firstObject] fields]);
                             }
                             failure:^(CDAResponse *response, NSError *error) {
                                 NSLog(@"%@", error);
                             }];

Results are returned as object of classes `CDAEntry`, `CDAAsset`, `CDAContentType` or `CDASpace`, depending on the fetch method being called. If there are multiple results, they will be returned as a `CDAArray` instance, which encapsulates the actual resources in the *items* property.

This repository contains multiple examples, demonstrating the use in common real world
scenarios and also showing the different ways you can integrate the SDK into your own project.

## Documentation

For further information, check out the [Developer Documentation][6] or browse the [API documentation][7]. The latter can also be loaded into Xcode as a Docset.

## Installation

### CocoaPods

[CocoaPods][2] is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party libraries like the Contentful Delivery API in your projects.

    platform :ios, '7.0'
    pod 'ContentfulDeliveryAPI'

This is the easiest way to keep your copy of the Contentful Delivery API updated.

### Manual integration

In the case you prefer to manage your dependencies manually, you can just drag all files from the `Code` subdirectory into your project or integrate the `ContentfulDeliveryAPI` static library target into your build process. It might be a good idea to add this repository as a [Git submodule][5] if you choose this path.

Be aware that the Contentful Delivery API requires both [AFNetworking][3] and [ISO8601DateFormatter][4] to compile successfully, so you need to provide these dependencies if you do manual integration.

### Static Framework

You can [download][8] the Contentful Delivery API as an universal static framework for iOS. Integrate it into your project by unzipping and dragging the `ContentfulDeliveryAPI.framework` into the `Frameworks` group of your project. You can also [download][9] the UFO example application including the static framework, as an example of integrating it into an Xcode project.

The static framework contains [AFNetworking][3] and [ISO8601DateFormatter][4], so beware of linker errors if you already have those libraries in your project. If this is the case, you should use another method of installation.

It depends on the `SystemConfiguration.framework` not included by default in iOS projects, so open your project file on the `General` tab.

![](Screenshots/GeneralTab.png)

Click the `+` button in the `Linked Frameworks and Libraries` section at the bottom.

![](Screenshots/Frameworks.png)

Search for *SystemConfiguration* and add the framework to your project.

![](Screenshots/SearchForFramework.png)

## Unit Tests

The Contentful Delivery API is fully unit tested.

To run the tests, do the following steps:

    gem install xcpretty
    make test

or run them directly from Xcode.

## License

Copyright (c) 2014 Contentful GmbH. See LICENSE for further details.



[1]: https://www.contentful.com
[2]: http://www.cocoapods.org
[3]: http://www.afnetworking.com
[4]: http://boredzo.org/iso8601dateformatter/
[5]: http://git-scm.com/docs/git-submodule
[6]: https://www.contentful.com/developers/documentation/content-delivery-api/
[7]: http://cocoadocs.org/docsets/ContentfulDeliveryAPI/0.1.0/
[8]: http://static.contentful.com/downloads/iOS/ContentfulDeliveryAPI-0.1.0.zip
[9]: http://static.contentful.com/downloads/iOS/UFO.zip

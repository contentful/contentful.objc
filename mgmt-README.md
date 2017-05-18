# contentful-management.objc

[![CI Status](http://img.shields.io/travis/contentful/contentful.objc.svg?style=flat)](https://travis-ci.org/contentful/contentful.objc)
[![Version](https://img.shields.io/cocoapods/v/ContentfulManagementAPI.svg?style=flat)](http://cocoadocs.org/docsets/ContentfulManagementAPI)
[![License](https://img.shields.io/cocoapods/l/ContentfulManagementAPI.svg?style=flat)](http://cocoadocs.org/docsets/ContentfulManagementAPI)
[![Platform](https://img.shields.io/cocoapods/p/ContentfulManagementAPI.svg?style=flat)](http://cocoadocs.org/docsets/ContentfulManagementAPI)
[![Coverage Status](https://img.shields.io/coveralls/contentful/contentful.objc.svg)](https://coveralls.io/github/contentful/contentful.objc)

Objective-C SDK's for [Contentful's][1] Content Management API and [Content Delivery API SDK](https://github.com/contentful/contentful.objc)


[Contentful][1] is a content management platform for web applications, mobile apps and connected devices. It allows you to create, edit & manage content in the cloud and publish it anywhere via powerful API. Contentful offers tools for managing editorial teams and enabling cooperation between organizations.

## Usage

### Client

In the beginning the API client instance should be created:

```objective-c
CMAClient* client = [[CMAClient alloc] initWithAccessToken:@"access-token"];
```

The access token can easily be obtained through the [management API documentation](https://www.contentful.com/developers/documentation/content-management-api/#getting-started).

Alternatively, you can opt into automatic handling of the CMA's rate-limiting, like this:

```objective-c
CDAConfiguration* configuration = [CDAConfiguration defaultConfiguration];
configuration.rateLimiting = YES;

CMAClient* client = [[CMAClient alloc] initWithAccessToken:@"access-token" configuration:configuration];
```

This will make the client do automatic retries with back-off, so that your application does not have to deal with rate-limiting at all.

### Spaces

Retrieving all spaces:

```objective-c
[client fetchAllSpacesWithSuccess:^(CDAResponse *response, CDAArray *array) {
	NSLog(@"%@", array);
} failure:^(CDAResponse *response, NSError *error) {
	NSLog(@"Error: %@", error);
}];
```

Retrieving one space by ID:

```objective-c
[client fetchSpaceWithIdentifier:@"blog-space-id" 
success:^(CDAResponse *response, CMASpace *space) {
 	NSLog(@"%@", space);
} failure:^(CDAResponse *response, NSError *error) {
	NSLog(@"Error: %@", error);
}];
```

Deleting a space:

```objective-c
[space deleteWithSuccess:^{
	NSLog(@"Delete successful.");
} failure:^(CDAResponse *response, NSError *error) {
	NSLog(@"Error: %@", error);
}];
```

Creating a space:

```objective-c
[client createSpaceWithName:@"MySpace"
success:^(CDAResponse *response, CMASpace *space) {
	NSLog(@"%@", space);
} failure:^(CDAResponse *response, NSError *error) {
	NSLog(@"Error: %@", error);
}];
```

or in the context of the organization (if you have multiple organizations within your account):

```objective-c
[client createSpaceWithName:@"MySpace"
inOrganization:organization
success:^(CDAResponse *response, CMASpace *space) {
	NSLog(@"%@", space);
} failure:^(CDAResponse *response, NSError *error) {
	NSLog(@"Error: %@", error);
}];
```

To retrieve all organizations in your account:

```objective-c
[client fetchOrganizationsWithSuccess:^(CDAResponse *response, CDAArray *array) {
	NSLog(@"%@", array);
} failure:^(CDAResponse *response, NSError *error) {
	NSLog(@"Error: %@", error);
}];
```

Updating a space:

```objective-c
space.name = @"new name";

[space updateWithSuccess:^{
	NSLog(@"%@", space);
} failure:^(CDAResponse *response, NSError *error) {
	NSLog(@"Error: %@", error);
}];
```

### Content Types

Retrieving all content types from a space:

```objective-c
[space fetchContentTypesWithSuccess:^(CDAResponse *response, CDAArray *array) {
	NSLog(@"%@", array);
} failure:^(CDAResponse *response, NSError *error) {
	NSLog(@"Error: %@", error);
}];
```

Retrieving one content type by ID from a space:

```objective-c
[space fetchContentTypeWithIdentifier:@"some identifier"
success:^(CDAResponse *response, CMAContentType *type) {
	NSLog(@"%@", type);
} failure:^(CDAResponse *response, NSError *error) {
	NSLog(@"Error: %@", error);
}];
```

Creating a field for a content type:

```objective-c
CMAField* field = [CMAField fieldWithName:@"tags" type:CDAFieldTypeArray];
field.itemType = CDAFieldTypeSymbol;

[contentType addField:field];
```

or

```objective-c
[contentType addFieldWithName:@"anotherField" type:CDAFieldTypeNumber];
```

Deleting a field from the content type:

```objective-c
[contentType deleteFieldWithIdentifier:@"some identifier"];
```

Creating a content type:

```objective-c
[space createContentTypeWithName:@"foobar"
fields:@[ [CMAField fieldWithName:@"field1" type:CDAFieldTypeText],
		  [CMAField fieldWithName:@"field2" type:CDAFieldTypeNumber],
		  [CMAField fieldWithName:@"field3" type:CDAFieldTypeObject] ]
success:^(CDAResponse *response, CMAContentType *contentType) {
	NSLog(@"%@", contentType);
} failure:^(CDAResponse *response, NSError *error) {
	NSLog(@"Error: %@", error);
}];
```

Deleting a content type:

```objective-c
[contentType deleteWithSuccess:^{
	NSLog(@"Delete successful.");
} failure:^(CDAResponse *response, NSError *error) {
	NSLog(@"Error: %@", error);
}];
```

Activating or deactivating a content type:

```objective-c
[contentType publishWithSuccess:^{
	NSLog(@"Published successfully.");
} failure:^(CDAResponse *response, NSError *error) {
	NSLog(@"Error: %@", error);
}];

[contentType unpublishWithSuccess:nil failure:nil];         
```

Checking if a content type is active:

```objective-c
BOOL result = contentType.isPublished;
```

Updating a content type:

```objective-c
contentType.name = @"new name";
[contentType updateWithSuccess:^{
	NSLog(@"Updated successfully.");
} failure:^(CDAResponse *response, NSError *error) {
	NSLog(@"Error: %@", error);
}];
```

### Editing Interface

Fetching the editor interface for a content-type:

[contentType fetchEditorInterfaceWithSuccess:^(CDAResponse*  response, CMAEditorInterface* interface) {
	NSLog(@"Editor interface: %@", interface);

	// Can be updated using this
	[interface updateWithSuccess:^{}
		failure:^(CDAResponse* response, NSError* error) {
			NSLog(@"Error: %@", error);
	}];
} failure:^(CDAResponse *response, NSError *error) {
	NSLog(@"Error: %@", error);
}];

### Assets

Retrieving all assets from the space:

```objective-c
[space fetchAssetsWithSuccess:^(CDAResponse* response, CDAArray* assets) {
	NSLog(@"%@", assets);
} failure:^(CDAResponse *response, NSError *error) {
	NSLog(@"Error: %@", error);
}];
```

Retrieving an asset by ID:

```objective-c
[space fetchAssetWithIdentifier:@"some identifier" 
success:^(CDAResponse* response, CMAAsset* asset) {
	NSLog(@"%@", asset);
} failure:^(CDAResponse *response, NSError *error) {
	NSLog(@"Error: %@", error);
}];
```

Creating an asset:

```objective-c
[space createAssetWithTitle:@{ @"en-US": @"My Image" }
description:@{ @"en-US": @"My Image Description" }
fileToUpload:@{ @"en-US": @"http://www.example.com/example.jpg" }
success:^(CDAResponse *response, CMAAsset *asset) {
	NSLog(@"%@", asset);
} failure:^(CDAResponse *response, NSError *error) {
	NSLog(@"Error: %@", error);
}];
```

Start processing of an asset:

```objective-c
[asset processWithSuccess:^{
    NSLog(@"Processing successfully started.");
} failure:^(CDAResponse *response, NSError *error) {
    NSLog(@"Error: %@", error);
}];
```

Updating an asset:

```objective-c
asset.title = @"bar";

[asset updateWithSuccess:^{
	NSLog(@"Update successful");
} failure:^(CDAResponse *response, NSError *error) {
	NSLog(@"Error: %@", error);
}];
```

Deleting an asset:

```objective-c
[asset deleteWithSuccess:^{
	NSLog(@"Delete successful.");
} failure:^(CDAResponse *response, NSError *error) {
	NSLog(@"Error: %@", error);
}];
```

Archiving or unarchiving an asset:

```objective-c
[asset archiveWithSuccess:nil failure:nil];
[asset unarchiveWithSuccess:nil failure:nil];
```

Checking if an asset is archived:

```objective-c
BOOL result = asset.isArchived;
```

Publishing or unpublishing an asset:

```objective-c
[asset publishWithSuccess:nil failure:nil];
[asset unpublishWithSuccess:nil failure:nil];
```

Checking if an asset is published:

```objective-c
BOOL result = asset.isPublished;
```

### Entries

Retrieving all entries from the space:

```objective-c
[space fetchEntriesWithSuccess:^(CDAResponse* response, CDAArray* entries) {
	NSLog(@"%@", entries);
} failure:^(CDAResponse *response, NSError *error) {
	NSLog(@"Error: %@", error);
}];
```

Retrieving an entry by ID:

```objective-c
[space fetchEntryWithIdentifier:@"some identifier"
success:^(CDAResponse* response, CDAEntry* entry) {
	NSLog(@"%@", entry);
} failure:^(CDAResponse *response, NSError *error) {
	NSLog(@"Error: %@", error);
}];
```

Creating an entry:

```objective-c
[space createEntryOfContentType:contentType
withFields:@{ @"title": @{ @"en-US": @"Mr. President" } }
success:^(CDAResponse *response, CDAEntry *entry) {
	NSLog(@"%@", entry);
} failure:^(CDAResponse *response, NSError *error) {
	NSLog(@"Error: %@", error);
}];
```

Updating an entry:

```objective-c
[entry setValue:@"bar" forFieldWithName:@"title"];
[entry updateWithSuccess:^{
	NSLog(@"Updated successfully");
} failure:^(CDAResponse *response, NSError *error) {
	NSLog(@"Error: %@", error);
}];
```

Deleting an entry:

```objective-c
[entry deleteWithSuccess:^{
	NSLog(@"Delete successful.");
} failure:^(CDAResponse *response, NSError *error) {
	NSLog(@"Error: %@", error);
}];
```

Archiving or unarchiving the entry:

```objective-c
[entry archiveWithSuccess:nil failure:nil];
[entry unarchiveWithSuccess:nil failure:nil];
```

Checking if the entry is archived:

```objective-c
BOOL result = entry.isArchived;
```

Publishing or unpublishing the entry:

```objective-c
[entry publishWithSuccess:nil failure:nil];
[entry unpublishWithSuccess:nil failure:nil];
```

Checking if the entry is published:

```objective-c
BOOL result = entry.isPublish;
```

### Roles and Permissions

Creating a role:

```objective-c
[space createRoleWithName:name
              description:description
              permissions:permissions
                 policies:policies
                  success:^(CDAResponse *response, CMARole *role) {
                    NSLog(@"New role: %@", role);
                  }
                  failure:^(CDAResponse *response, NSError *error) {
                    NSLog(@"Error: %@", error);
                  }];
```

Fetching roles defined in a space:

```objective-c
[space fetchRolesMatching:@{} withSuccess:nil failure:nil];
```

Updating a role:

```objective-c
role.roleDescription = @"New description";

[role updateWithSuccess:nil failure:nil];
```

Deleting a role:

```objective-c
[role deleteWithSuccess:nil failure:nil];
```

### Webhooks

Creating a new webhook:

```objective-c
[space createWebhookWithName:name
                         url:url
                      topics:nil
                     headers:nil
           httpBasicUsername:nil
           httpBasicPassword:nil
                     success:nil
                     failure:nil];
```

Fetching all webhooks for a space:

```objective-c
[space fetchWebhooksWithSuccess:nil failure:nil];
```

Updating a webhook:

```objective-c
webhook.name = @"updated name";
[webhook updateWithSuccess:nil failure:nil];
```

Deleting a webhook:

```objective-c
[webhook deleteWithSuccess:nil failure:nil];
```

(Note: for brevity's sake, some of the examples use `nil` completion blocks. Obviously, you should
not do that in your real applications.)

## Installation

[CocoaPods][2] is the dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party libraries like the Contentful Delivery API in your projects.

```ruby
platform :ios, '7.0'
pod 'ContentfulManagementAPI'
```

This is the easiest way to keep your copy of the Contentful Management API updated.

Alternatively, you can use [pre-built static frameworks][4] for iOS and OS X, which have all the depedencies built-in. Or you include this repository as a Git submodule and include all the code from the Pod/ directory.

## Unit Tests

The Contentful Management API is fully unit tested. They are using the API token from the environment variable `CONTENTFUL_MANAGEMENT_API_ACCESS_TOKEN` so you have to provide that.

The tests can be run either from inside Xcode or using [cocoapods-testing][3] from the commandline:

	$ gem install cocoapods-testing
	$ pod lib testing

## Examples

You can find a very simple example which uses the CMA in our [demo app][5] for the iOS webinar.

## License

Copyright (c) 2014 Contentful GmbH. See LICENSE for further details.


[1]: https://www.contentful.com/
[2]: http://www.cocoapods.org/
[3]: https://github.com/neonichu/cocoapods-testing
[4]: https://github.com/contentful/contentful-management.objc/releases/download/0.9.0/ContentfulManagementAPI-0.9.0.zip
[5]: https://github.com/contentful/webinar-ios-demo

//
//  CMAContentType.h
//  Pods
//
//  Created by Boris Bügling on 24/07/14.
//
//

#import <ContentfulDeliveryAPI/CDANullabilityStubs.h>
#import <ContentfulManagementAPI/ContentfulManagementAPI.h>

NS_ASSUME_NONNULL_BEGIN

@class CMAField;

/**
 *  Management extension for content types.
 */
@interface CMAContentType : CDAContentType <CMAPublishing, CMAResource>

/**
 *  The description of the receiver.
 */
@property (nonatomic) NSString* userDescription;

/**
 *  The name of the receiver.
 */
@property (nonatomic) NSString* name;

/**
 *  Adds a new field to the receiver locally.
 *
 *  Call `updateWithSuccess:failure:` to synchronize local changes to Contentful.
 *
 *  @param field The new field.
 *
 *  @return YES if no other field with the same `identifier` exits, NO otherwise.
 */
-(BOOL)addField:(CMAField*)field;

/**
 *  Adds a new field to the receiver locally.
 *
 *  Call `updateWithSuccess:failure:` to synchronize local changes to Contentful.
 *
 *  @param name The name of the new field.
 *  @param type The type of the new field.
 *
 *  @return YES if no other field with the same `name` exits, NO otherwise.
 */
-(BOOL)addFieldWithName:(NSString*)name type:(CDAFieldType)type;

/**
 *  Delete the given field from the receiver locally.
 *
 *  Call `updateWithSuccess:failure:` to synchronize local changes to Contentful.
 *
 *  @param field The field to delete.
 */
-(void)deleteField:(CMAField*)field;

/**
 *  Delete any fields with the given identifier locally.
 *
 *  Call `updateWithSuccess:failure:` to synchronize local changes to Contentful.
 *
 *  @param identifier The identifier used for finding fields to delete.
 */
-(void)deleteFieldWithIdentifier:(NSString*)identifier;

/**
 *  Fetch editor interface for the given content type.
 *
 *  @param success  Called if fetching succeeds.
 *  @param failure  Called if fetching fails.
 *
 *  @return The request used for fetching data.
 */
-(CDARequest *)fetchEditorInterfaceWithSuccess:(CMAEditorInterfaceFetchedBlock)success
                                       failure:(CDARequestFailureBlock)failure;

/**
 *  Update the name of an existing field locally.
 *
 *  Call `updateWithSuccess:failure:` to synchronize local changes to Contentful.
 *
 *  @param newName    The new name of the field.
 *  @param identifier The identifier used for finding fields to update.
 */
-(void)updateName:(NSString*)newName ofFieldWithIdentifier:(NSString*)identifier;

/**
 *  Update the type of an existing field locally.
 *
 *  Call `updateWithSuccess:failure:` to synchronize local changes to Contentful.
 *
 *  @param newType    The new type of the field.
 *  @param identifier The identifier used for finding fields to update.
 */
-(void)updateType:(CDAFieldType)newType ofFieldWithIdentifier:(NSString*)identifier;

@end

NS_ASSUME_NONNULL_END

//
//  CMAField.h
//  Pods
//
//  Created by Boris Bügling on 29/07/14.
//
//

#import <ContentfulDeliveryAPI/CDANullabilityStubs.h>
#import <ContentfulManagementAPI/ContentfulManagementAPI.h>

NS_ASSUME_NONNULL_BEGIN

@class CMAValidation;

/**
 *  Management extensions for fields.
 */
@interface CMAField : CDAField

/**
 *  Create a new field, locally. This API should be used to create fields for creating and updating
 *  content types.
 *
 *  @param name The name of the new field.
 *  @param type The type of the new field.
 *
 *  @return A new field instance.
 */
+(instancetype)fieldWithName:(NSString*)name type:(CDAFieldType)type;

/** Field type of items if the field is an Array, `CDAFieldTypeNone` otherwise. */
@property (nonatomic) CDAFieldType itemType;

/** List of currently active validations for the receiver. */
@property (nonatomic, readonly) NSArray* validations;

/** Whether or not this field will be omitted from delivery API responses. */
@property (nonatomic) BOOL omitted;

/**
 *  Add a validation for the receiver. It will be applied whenever a value of that field is set.
 *
 *  @param validation A validation to apply to values of the receiver.
 */
-(void)addValidation:(CMAValidation*)validation;

@end

NS_ASSUME_NONNULL_END

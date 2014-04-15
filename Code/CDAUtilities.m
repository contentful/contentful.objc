//
//  CDAUtilities.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 04/03/14.
//
//

#import <objc/runtime.h>

#import "CDAResource.h"
#import "CDAUtilities.h"

BOOL CDAIgnoreProperty(objc_property_t property);
NSString* CDAPropertyGetTypeString(objc_property_t property);
BOOL CDAPropertyIsReadOnly(objc_property_t property);
void CDAPropertyVisitor(Class class, void(^visitor)(objc_property_t property, NSString* propertyName));
NSString* CDASquashWhitespacesInString(NSString* string);

#pragma mark -

NSString* CDACacheDirectory() {
    NSString *cachesPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"com.contentful.sdk"];
    
    BOOL isDirectory = NO;
    if ([[NSFileManager defaultManager] fileExistsAtPath:cachesPath isDirectory:&isDirectory]) {
        NSCAssert(isDirectory, @"Caches directory '%@' is a file.", cachesPath);
    } else {
        NSError* error;
        BOOL result = [[NSFileManager defaultManager] createDirectoryAtPath:cachesPath
                                                withIntermediateDirectories:NO
                                                                 attributes:nil
                                                                      error:&error];
        NSCAssert(result, @"Error: %@", error);
        result = YES;
    }
    
    return cachesPath;
}

NSString* CDACacheFileNameForQuery(CDAResourceType resourceType, NSDictionary* query) {
    NSString* queryAsString = CDASquashWhitespacesInString([query description]);
    NSString* fileName = [NSString stringWithFormat:@"cache_%d_%@.data",
                          (int)resourceType, queryAsString ?: @"all"];
    
    return [CDACacheDirectory() stringByAppendingPathComponent:fileName];
}

NSString* CDACacheFileNameForResource(CDAResource* resource) {
    NSString* fileName = [NSString stringWithFormat:@"cache_%@_%@.data",
                          resource.sys[@"type"], resource.identifier];
    return [CDACacheDirectory() stringByAppendingPathComponent:fileName];
}

// Thanks to http://www.cocoawithlove.com/2010/01/getting-subclasses-of-objective-c-class.html
NSArray* CDAClassGetSubclasses(Class parentClass) {
    int numClasses = objc_getClassList(NULL, 0);
    Class* classes = NULL;
    
    classes = (__unsafe_unretained Class*)malloc(sizeof(Class) * numClasses);
    numClasses = objc_getClassList(classes, numClasses);
    
    NSMutableArray* result = [NSMutableArray array];
    for (NSInteger i = 0; i < numClasses; i++) {
        Class superClass = classes[i];
        do {
            superClass = class_getSuperclass(superClass);
        } while(superClass && superClass != parentClass);
        
        if (superClass == nil) {
            continue;
        }
        
        [result addObject:classes[i]];
    }
    
    free(classes);
    return result;
}

void CDADecodeObjectWithCoder(id object, NSCoder* aDecoder) {
    CDAPropertyVisitor([object class], ^(objc_property_t property, NSString *propertyName) {
        if (!CDAIgnoreProperty(property)) {
            [object setValue:[aDecoder decodeObjectOfClass:[object class]
                                                    forKey:propertyName] forKey:propertyName];
        }
    });
}

void CDAEncodeObjectWithCoder(id object, NSCoder* aCoder) {
    CDAPropertyVisitor([object class], ^(objc_property_t property, NSString *propertyName) {
        if (!CDAIgnoreProperty(property)) {
            [aCoder encodeObject:[object valueForKey:propertyName] forKey:propertyName];
        }
    });
}

BOOL CDAIgnoreProperty(objc_property_t property) {
    if (CDAPropertyIsReadOnly(property)) {
        return YES;
    }
    
    NSString* type = CDAPropertyGetTypeString(property);
    if ([type hasSuffix:@"CDAClient\""] || [type hasSuffix:@"CDAFieldValueTransformer\""]) {
        return YES;
    }
    
    return NO;
}

BOOL CDAIsNoNetworkError(NSError* error) {
    if (![error.domain isEqualToString:NSURLErrorDomain]) {
        return NO;
    }
    
    return error.code == kCFURLErrorNotConnectedToInternet;
}

// Thanks to https://github.com/AlanQuatermain/aqtoolkit/
NSString* CDAPropertyGetTypeString(objc_property_t property) {
    const char *attrs = property_getAttributes(property);
    if (attrs == NULL)
        return (NULL);
    
    static char buffer[256];
    const char *e = strchr(attrs, ',');
    if (e == NULL)
        return (NULL);
    
    int len = (int)(e - attrs);
    memcpy(buffer, attrs, len);
    buffer[len] = '\0';
    
    return [NSString stringWithCString:buffer encoding:NSUTF8StringEncoding];
}

BOOL CDAPropertyIsReadOnly(objc_property_t property) {
    const char *propertyAttributes = property_getAttributes(property);
    NSArray *attributes = [[NSString stringWithUTF8String:propertyAttributes]
                           componentsSeparatedByString:@","];
    return [attributes containsObject:@"R"];
}

void CDAPropertyVisitor(Class class, void(^visitor)(objc_property_t property, NSString* propertyName)) {
    if (!visitor || !class) {
        return;
    }
    
    unsigned int numberOfProperties = 0;
    objc_property_t *properties = class_copyPropertyList(class, &numberOfProperties);
    
    for (unsigned int i = 0; i < numberOfProperties; i++) {
        objc_property_t property = properties[i];
        NSString* propertyName = [NSString stringWithUTF8String:property_getName(property)];
        visitor(property, propertyName);
    }
    
    free(properties);
    
    CDAPropertyVisitor([class superclass], visitor);
}

// Thanks to http://nshipster.com/nscharacterset/
NSString* CDASquashWhitespacesInString(NSString* string) {
    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSArray *components = [string componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    components = [components filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self <> ''"]];
    
    return [components componentsJoinedByString:@""];
}

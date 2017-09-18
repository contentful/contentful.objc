//
//  CDAUtilities.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 04/03/14.
//
//

@import ObjectiveC.runtime;

#import "CDASpace.h"

#import "CDAClient+Private.h"
#import "CDAResource+Private.h"
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
#ifndef __clang_analyzer__
        result = YES;
#endif
    }
    
    return cachesPath;
}

NSString* CDACacheFileNameForQuery(CDAClient* client, CDAResourceType resourceType, NSDictionary* query) {
    NSString* queryAsString = CDASquashWhitespacesInString([query description]);
    NSString* fileName = [NSString stringWithFormat:@"cache_%@_%d_%@.data",
                          client.spaceKey, (int)resourceType, queryAsString ?: @"all"];
    
    return [CDACacheDirectory() stringByAppendingPathComponent:fileName];
}

NSString* CDACacheFileNameForResource(CDAResource* resource) {
    NSString* pathExtension = @"data";
    if ([resource respondsToSelector:@selector(URL)]) {
        pathExtension = [(id)resource URL].pathExtension ?: @"data";
    }
    
    NSString* fileName = [NSString stringWithFormat:@"cache_%@_%@_%@.%@",
                          resource.client.spaceKey, resource.sys[@"type"],
                          resource.identifier, pathExtension];
    return [CDACacheDirectory() stringByAppendingPathComponent:fileName];
}

// Thanks to http://www.cocoawithlove.com/2010/01/getting-subclasses-of-objective-c-class.html
NSArray* CDAClassGetSubclasses(Class parentClass) {
    int numClasses = objc_getClassList(NULL, 0);
    Class* classes = NULL;
    static const Class invalidClass =  (__bridge Class) (void*) (((intptr_t) 0)-1);
    
    classes = (__unsafe_unretained Class*)malloc(sizeof(Class) * numClasses);
    numClasses = objc_getClassList(classes, numClasses);
    
    NSMutableArray* result = [NSMutableArray array];
    for (NSInteger i = 0; i < numClasses; i++) {
        Class superClass = classes[i];
        do {
            superClass = class_getSuperclass(superClass);
        } while(superClass && (superClass != parentClass) && (superClass != invalidClass));
        
        if ((superClass == nil) || (superClass == invalidClass)) {
            continue;
        }
        
        [result addObject:classes[i]];
    }
    
    free(classes);
    return result;
}

BOOL CDAClassIsEqualToClass(Class someClass, Class otherClass) {
    return [NSStringFromClass(someClass) isEqualToString:NSStringFromClass(otherClass)];
}

BOOL CDAClassIsOfType(Class someClass, Class otherClass) {
    do {
        if (CDAClassIsEqualToClass(someClass, otherClass)) {
            return YES;
        }
    } while ((someClass = class_getSuperclass(someClass)));

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

id CDAReadItemFromFileURL(NSURL* fileURL, CDAClient* client) {
    if (fileURL == nil || !fileURL.isFileURL) {
        return nil;
    }

    id item = nil;
    NSData *data = [NSData dataWithContentsOfURL:fileURL options:NSDataReadingMappedIfSafe error:nil];
    if (data != nil) {
        @try {
            item = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        } @catch (id ue) {
            (void) ue;
            return nil;
        }

        [(CDAResource*)item setClient:client];
        return item;
    }

    return nil;
}

NSString* CDASquashWhitespacesInString(NSString* string) {
    return CDASquashCharactersFromSetInString([NSCharacterSet whitespaceAndNewlineCharacterSet], string);
}

// Thanks to http://nshipster.com/nscharacterset/
NSString* CDASquashCharactersFromSetInString(NSCharacterSet* characterSet, NSString* string) {
    string = [string stringByTrimmingCharactersInSet:characterSet];
    
    NSArray *components = [string componentsSeparatedByCharactersInSet:characterSet];
    components = [components filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self <> ''"]];
    
    return [components componentsJoinedByString:@""];
}

NSString* CDAValueForQueryParameter(NSURL* url, NSString* queryParameter) {
    for (NSString* parameters in [url.query componentsSeparatedByString:@"&"]) {
        NSArray* query = [parameters componentsSeparatedByString:@"="];

        if ([[query firstObject] isEqualToString:queryParameter]) {
            return [[query lastObject] stringByRemovingPercentEncoding];
        }
    }

    return nil;
}

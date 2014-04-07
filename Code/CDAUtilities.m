//
//  CDAUtilities.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 04/03/14.
//
//

#import <objc/runtime.h>

BOOL CDAIgnoreProperty(objc_property_t property);
NSString* CDAPropertyGetTypeString(objc_property_t property);
BOOL CDAPropertyIsReadOnly(objc_property_t property);
void CDAPropertyVisitor(Class class, void(^visitor)(objc_property_t property, NSString* propertyName));

#pragma mark -

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
            [object setValue:[aDecoder decodeObjectForKey:propertyName] forKey:propertyName];
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

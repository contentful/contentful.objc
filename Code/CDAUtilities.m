//
//  CDAUtilities.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 04/03/14.
//
//

#import <objc/runtime.h>

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

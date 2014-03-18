//
//  CDAFieldsViewController+Markdown.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 18/03/14.
//
//

#import <objc/runtime.h>

#import <ContentfulDeliveryAPI/CDAField.h>
#import <ContentfulDeliveryAPI/CDAFieldsViewController.h>

#import "CDAMarkdownViewController.h"

@implementation CDAFieldsViewController (Markdown)

+ (void)load {
    method_exchangeImplementations(class_getInstanceMethod(self,
                                                           @selector(didSelectRowWithValue:forField:)),
                                   class_getInstanceMethod(self,
                                                           @selector(md_didSelectRowWithValue:forField:))
                                   );
}

#pragma mark -

-(void)md_didSelectRowWithValue:(id)value forField:(CDAField *)field {
    if (field.type == CDAFieldTypeText) {
        CDAMarkdownViewController* markdownViewController = [CDAMarkdownViewController new];
        markdownViewController.markdownText = value;
        [self.navigationController pushViewController:markdownViewController animated:YES];
        return;
    }
    
    [self md_didSelectRowWithValue:value forField:field];
}

@end

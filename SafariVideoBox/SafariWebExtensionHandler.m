//
//  SafariWebExtensionHandler.m
//  SafariVideoBox
//
//  Created by Maxwell on 2/10/21.
//

#import "SafariWebExtensionHandler.h"

#import <SafariServices/SafariServices.h>

@implementation SafariWebExtensionHandler

- (void)beginRequestWithExtensionContext:(NSExtensionContext *)context
{
    [context completeRequestReturningItems:@[] completionHandler:nil];
}

@end

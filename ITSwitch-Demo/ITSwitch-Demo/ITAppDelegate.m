//
//  ITAppDelegate.m
//  ITSwitch-Demo
//
//  Created by Ilija Tovilo on 01/02/14.
//  Copyright (c) 2014 Ilija Tovilo. All rights reserved.
//

#import "ITAppDelegate.h"

@implementation ITAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // initial state of our bindable flag
    self.bindableFlag = NO;
    
    // bind one of our switches to this internal flag
    [self.itSwitch bind:@"checked" toObject:self withKeyPath:@"bindableFlag" options:nil];
    
    // change the state after some time to see if binding works
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.bindableFlag = YES;
    });
}

- (IBAction)switchChanged:(ITSwitch *)itSwitch {
    NSLog(@"Switch (%@) is %@", itSwitch, itSwitch.checked ? @"checked" : @"unchecked");
}

@end

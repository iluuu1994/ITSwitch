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
    // Insert code here to initialize your application
}

- (IBAction)switchChanged:(ITSwitch *)itSwitch {
    NSLog(@"Switch (%@) is %@", itSwitch, itSwitch.isOn ? @"enabled" : @"disabled");
}

@end

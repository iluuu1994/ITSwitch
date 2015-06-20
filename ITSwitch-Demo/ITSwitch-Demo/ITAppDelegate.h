//
//  ITAppDelegate.h
//  ITSwitch-Demo
//
//  Created by Ilija Tovilo on 01/02/14.
//  Copyright (c) 2014 Ilija Tovilo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ITSwitch.h"

@interface ITAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet ITSwitch *itSwitch;

@property (assign) BOOL bindableFlag;

@end

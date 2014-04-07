//
//  ITSwitch.h
//  ITSwitch-Demo
//
//  Created by Ilija Tovilo on 01/02/14.
//  Copyright (c) 2014 Ilija Tovilo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ITSwitch : NSControl

@property (nonatomic, setter = setOn:) BOOL isOn;
@property (nonatomic, strong) NSColor *tintColor;

@end

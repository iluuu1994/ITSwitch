//
//  ITSwitch.h
//  ITSwitch-Demo
//
//  Created by Ilija Tovilo on 01/02/14.
//  Copyright (c) 2014 Ilija Tovilo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#ifndef IB_DESIGNABLE
#define IB_DESIGNABLE
#endif

#ifndef IBInspectable
#define IBInspectable
#endif

#if __MAC_OS_X_VERSION_MIN_REQUIRED < 1080
#define COMPILE_FOR_LION
#endif

/**
 *  ITSwitch is a replica of UISwitch for Mac OS X
 */
IB_DESIGNABLE
@interface ITSwitch : NSControl

@property (nonatomic) IBInspectable BOOL enabled;

/**
 *  @property tintColor - Gets or sets the switches tint
 */
@property (nonatomic, getter = isOn) IBInspectable BOOL on;

/**
 *  @property tintColor - Gets or sets the switches tint
 */
@property (atomic, strong) IBInspectable NSColor *tintColor;

@end

/**
 *  Support for CGColor in Lion
 */
@interface NSColor (CGColorExtends)

- (CGColorRef)its_CGColor;

@end

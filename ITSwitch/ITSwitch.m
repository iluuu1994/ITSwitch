//
//  ITSwitch.m
//  ITSwitch-Demo
//
//  Created by Ilija Tovilo on 01/02/14.
//  Copyright (c) 2014 Ilija Tovilo. All rights reserved.
//

#import "ITSwitch.h"
#import <QuartzCore/QuartzCore.h>


// ----------------------------------------------------
#pragma mark - Static Constants
// ----------------------------------------------------

static NSTimeInterval const kAnimationDuration = 0.4f;

static CGFloat const kBorderLineWidth = 1.f;

static CGFloat const kGoldenRatio = 1.61803398875f;
static CGFloat const kDecreasedGoldenRatio = 1.38f;

static CGFloat const kEnabledOpacity = 1.f;
static CGFloat const kDisabledOpacity = 0.5f;

// ----------------------------------------------------
#pragma mark - Preprocessor
// ----------------------------------------------------


#define kKnobBackgroundColor [NSColor colorWithCalibratedWhite:1.f alpha:1.f]

#define kDisabledBorderColor [NSColor colorWithCalibratedWhite:0.f alpha:0.2f]
#define kDisabledBackgroundColor [NSColor clearColor]
#define kDefaultTintColor [NSColor colorWithCalibratedRed:0.27f green:0.86f blue:0.36f alpha:1.f]
#define kInactiveBackgroundColor [NSColor colorWithCalibratedWhite:0.f alpha:0.3f]

// ---------------------------------------------------------------------------------------
#pragma mark - Interface Extension
// ---------------------------------------------------------------------------------------

@interface ITSwitch () {
    __weak id _target;
    SEL _action;
}

@property (nonatomic, getter = isActive) BOOL active;
@property (nonatomic, getter = hasDragged) BOOL dragged;
@property (nonatomic, getter = isDraggingTowardsOn) BOOL draggingTowardsOn;

@property (nonatomic, readonly, strong) CALayer *rootLayer;
@property (nonatomic, readonly, strong) CALayer *backgroundLayer;
@property (nonatomic, readonly, strong) CALayer *knobLayer;
@property (nonatomic, readonly, strong) CALayer *knobInsideLayer;

@end



// ---------------------------------------------------------------------------------------
#pragma mark - ITSwitch
// ---------------------------------------------------------------------------------------

@implementation ITSwitch
@synthesize tintColor = _tintColor;



// ----------------------------------------------------
#pragma mark - Init
// ----------------------------------------------------

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (!self) return nil;
    
    [self setUp];
    
    return self;
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (!self) return nil;
    
    [self setUp];
    
    return self;
}

- (void)setUp {
    // The Switch is enabled per default
    self.enabled = YES;
    
    // Set up the layer hierarchy
    [self setUpLayers];
}

- (void)setUpLayers {
    // Root layer
    _rootLayer = [CALayer layer];
    //_rootLayer.delegate = self;
    self.layer = _rootLayer;
    self.wantsLayer = YES;
    
    // Background layer
    _backgroundLayer = [CALayer layer];
    _backgroundLayer.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
    _backgroundLayer.bounds = _rootLayer.bounds;
    _backgroundLayer.anchorPoint = (CGPoint){ .x = 0.f, .y = 0.f };
    _backgroundLayer.borderWidth = kBorderLineWidth;
    [_rootLayer addSublayer:_backgroundLayer];
    
    // Knob layer
    _knobLayer = [CALayer layer];
    _knobLayer.frame = [self rectForKnob];
    _knobLayer.autoresizingMask = kCALayerHeightSizable;
    _knobLayer.backgroundColor = [kKnobBackgroundColor  its_CGColor];
    _knobLayer.shadowColor = [[NSColor blackColor] its_CGColor];
    _knobLayer.shadowOffset = (CGSize){ .width = 0.f, .height = -2.f };
    _knobLayer.shadowRadius = 1.f;
    _knobLayer.shadowOpacity = 0.3f;
    [_rootLayer addSublayer:_knobLayer];
    
    _knobInsideLayer = [CALayer layer];
    _knobInsideLayer.frame = _knobLayer.bounds;
    _knobInsideLayer.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
    _knobInsideLayer.shadowColor = [[NSColor blackColor] its_CGColor];
    _knobInsideLayer.shadowOffset = (CGSize){ .width = 0.f, .height = 0.f };
    _knobInsideLayer.backgroundColor = [[NSColor whiteColor] its_CGColor];
    _knobInsideLayer.shadowRadius = 1.f;
    _knobInsideLayer.shadowOpacity = 0.35f;
    [_knobLayer addSublayer:_knobInsideLayer];
    
    // Initial
    [self reloadLayerSize];
    [self reloadLayer];
}



// ----------------------------------------------------
#pragma mark - NSView
// ----------------------------------------------------

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent {
    return YES;
}

- (void)setFrame:(NSRect)frameRect {
    [super setFrame:frameRect];
    
    [self reloadLayerSize];
}

- (void)drawFocusRingMask {
	CGFloat cornerRadius = NSHeight([self bounds])/2.0;
	NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:[self bounds] xRadius:cornerRadius yRadius:cornerRadius];
	[[NSColor blackColor] set];
	[path fill];
}

- (BOOL)canBecomeKeyView {
	return [NSApp isFullKeyboardAccessEnabled];
}

- (NSRect)focusRingMaskBounds {
	return [self bounds];
}


// ----------------------------------------------------
#pragma mark - Update Layer
// ----------------------------------------------------

- (void)reloadLayer {
    [CATransaction begin];
    [CATransaction setAnimationDuration:kAnimationDuration];
    {
        // ------------------------------- Animate Border
        // The green part also animates, which looks kinda weird
        // We'll use the background-color for now
        //        _backgroundLayer.borderWidth = (YES || self.isActive || self.state) ? NSHeight(_backgroundLayer.bounds) / 2 : kBorderLineWidth;
        
        // ------------------------------- Animate Colors
        if (([self hasDragged] && [self isDraggingTowardsOn]) || (![self hasDragged] && [self isOn])) {
            _backgroundLayer.borderColor = [self.tintColor its_CGColor];
            _backgroundLayer.backgroundColor = [self.tintColor its_CGColor];
        } else {
            _backgroundLayer.borderColor = [kDisabledBorderColor its_CGColor];
            _backgroundLayer.backgroundColor = [kDisabledBackgroundColor its_CGColor];
        }
        
        // ------------------------------- Animate Enabled-Disabled state
        _rootLayer.opacity = (self.isEnabled) ? kEnabledOpacity : kDisabledOpacity;

        // ------------------------------- Animate Frame
        if (![self hasDragged]) {
            CAMediaTimingFunction *function = [CAMediaTimingFunction functionWithControlPoints:0.25f :1.5f :0.5f :1.f];
            [CATransaction setAnimationTimingFunction:function];
        }
        
        self.knobLayer.frame = [self rectForKnob];
        self.knobInsideLayer.frame = self.knobLayer.bounds;
    }
    [CATransaction commit];
}

- (void)reloadLayerSize {
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    {
        self.knobLayer.frame = [self rectForKnob];
        self.knobInsideLayer.frame = self.knobLayer.bounds;
        
        [_backgroundLayer setCornerRadius:_backgroundLayer.bounds.size.height / 2.f];
        [_knobLayer setCornerRadius:_knobLayer.bounds.size.height / 2.f];
        [_knobInsideLayer setCornerRadius:_knobLayer.bounds.size.height / 2.f];
    }
    [CATransaction commit];
}

- (CGFloat)knobHeightForSize:(NSSize)size
{
    return size.height - (kBorderLineWidth * 2.f);
}

- (CGRect)rectForKnob {
    CGFloat height = [self knobHeightForSize:_backgroundLayer.bounds.size];
    CGFloat width = ![self isActive] ? (NSWidth(_backgroundLayer.bounds) - 2.f * kBorderLineWidth) * 1.f / kGoldenRatio :
    (NSWidth(_backgroundLayer.bounds) - 2.f * kBorderLineWidth) * 1.f / kDecreasedGoldenRatio;
    CGFloat x = ((![self hasDragged] && ![self isOn]) || (self.hasDragged && ![self isDraggingTowardsOn])) ?
    kBorderLineWidth :
    NSWidth(_backgroundLayer.bounds) - width - kBorderLineWidth;
    
    return (CGRect) {
        .size.width = width,
        .size.height = height,
        .origin.x = x,
        .origin.y = kBorderLineWidth,
    };
}



// ----------------------------------------------------
#pragma mark - NSResponder
// ----------------------------------------------------

- (BOOL)acceptsFirstResponder {
	return [NSApp isFullKeyboardAccessEnabled];
}

- (void)mouseDown:(NSEvent *)theEvent {
    if (!self.isEnabled) return;

    self.active = YES;
    
    [self reloadLayer];
}

- (void)mouseDragged:(NSEvent *)theEvent {
    if (!self.isEnabled) return;

    self.dragged = YES;
    
    NSPoint draggingPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    self.draggingTowardsOn = draggingPoint.x >= NSWidth(self.bounds) / 2.f;
    
    [self reloadLayer];
}

- (void)mouseUp:(NSEvent *)theEvent {
    if (!self.isEnabled) return;

    self.active = NO;
    
    BOOL state = (![self hasDragged]) ? ![self isOn] : [self isDraggingTowardsOn];
    BOOL invokeTargetAction = (state != [self isOn]);
    
    self.on = state;
    if (invokeTargetAction) [self _invokeTargetAction];
    
    // Reset
    self.dragged = NO;
    self.draggingTowardsOn = NO;
    
    [self reloadLayer];
}

- (void)moveLeft:(id)sender {
	if ([self isOn]) {
		self.on = NO;
		[self _invokeTargetAction];
	}
}

- (void)moveRight:(id)sender {
	if ([self isOn] == NO) {
		self.on = YES;
		[self _invokeTargetAction];
	}
}

- (BOOL)performKeyEquivalent:(NSEvent *)theEvent {
	BOOL handledKeyEquivalent = NO;
	if ([[self window] firstResponder] == self) {
		NSInteger ch = [theEvent keyCode];
		
		if (ch == 49) //Space
		{
			self.on = ![self isOn];
			[self _invokeTargetAction];
			handledKeyEquivalent = YES;
		}
	}
	return handledKeyEquivalent;
}


// ----------------------------------------------------
#pragma mark - Accessors
// ----------------------------------------------------

- (void)setOn:(BOOL)on
{
    if (_on != on) {
        _on = on;
    }
    [self reloadLayer];
}

- (NSColor *)tintColor {
    if (!_tintColor) return kDefaultTintColor;
    
    return _tintColor;
}

- (void)setTintColor:(NSColor *)tintColor {
    _tintColor = tintColor;
    
    [self reloadLayer];
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    [self reloadLayer];
}

// -----------------------------------
#pragma mark - Helpers
// -----------------------------------

- (void)_invokeTargetAction {
    if (self.target && self.action) {
        NSMethodSignature *signature = [[self.target class] instanceMethodSignatureForSelector:self.action];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        [invocation setTarget:self.target];
        [invocation setSelector:self.action];
        [invocation setArgument:(void *)&self atIndex:2];
        
        [invocation invoke];
    }
}

// -----------------------------------
#pragma mark - Accessibility
// -----------------------------------

- (BOOL)accessibilityIsIgnored {
	return NO;
}

- (id)accessibilityHitTest:(NSPoint)point {
	return self;
}

- (NSArray *)accessibilityAttributeNames {
	static NSArray *attributes = nil;
	if (attributes == nil)
	{
		NSMutableArray *mutableAttributes = [[super accessibilityAttributeNames] mutableCopy];
		if (mutableAttributes == nil)
			mutableAttributes = [NSMutableArray new];
		
		// Add attributes
		if (![mutableAttributes containsObject:NSAccessibilityValueAttribute])
			[mutableAttributes addObject:NSAccessibilityValueAttribute];
		
		if (![mutableAttributes containsObject:NSAccessibilityEnabledAttribute])
			[mutableAttributes addObject:NSAccessibilityEnabledAttribute];
		
		if (![mutableAttributes containsObject:NSAccessibilityDescriptionAttribute])
			[mutableAttributes addObject:NSAccessibilityDescriptionAttribute];
		
		// Remove attributes
		if ([mutableAttributes containsObject:NSAccessibilityChildrenAttribute])
			[mutableAttributes removeObject:NSAccessibilityChildrenAttribute];
		
		attributes = [mutableAttributes copy];
	}
	return attributes;
}

- (id)accessibilityAttributeValue:(NSString *)attribute {
	id retVal = nil;
	if ([attribute isEqualToString:NSAccessibilityRoleAttribute])
		retVal = NSAccessibilityCheckBoxRole;
	else if ([attribute isEqualToString:NSAccessibilityValueAttribute])
		retVal = [NSNumber numberWithInt:self.on];
	else if ([attribute isEqualToString:NSAccessibilityEnabledAttribute])
#ifdef COMPILE_FOR_LION
        retVal = [NSNumber numberWithBool:self.isEnabled];
#else
        retVal = [NSNumber numberWithBool:self.enabled];
#endif
	else
		retVal = [super accessibilityAttributeValue:attribute];
	return retVal;
}

- (BOOL)accessibilityIsAttributeSettable:(NSString *)attribute {
	BOOL retVal;
	if ([attribute isEqualToString:NSAccessibilityValueAttribute])
		retVal = YES;
	else if ([attribute isEqualToString:NSAccessibilityEnabledAttribute])
		retVal = NO;
	else if ([attribute isEqualToString:NSAccessibilityDescriptionAttribute])
		retVal = NO;
	else
		retVal = [super accessibilityIsAttributeSettable:attribute];
	return retVal;
}

- (void)accessibilitySetValue:(id)value forAttribute:(NSString *)attribute {
	if ([attribute isEqualToString:NSAccessibilityValueAttribute]) {
		BOOL invokeTargetAction = self.on != [value boolValue];
		self.on = [value boolValue];
		if (invokeTargetAction) {
			[self _invokeTargetAction];
		}
	}
	else {
		[super accessibilitySetValue:value forAttribute:attribute];
	}
}

- (NSArray *)accessibilityActionNames {
	static NSArray *actions = nil;
	if (actions == nil)
	{
		NSMutableArray *mutableActions = [[super accessibilityActionNames] mutableCopy];
		if (mutableActions == nil)
			mutableActions = [NSMutableArray new];
		if (![mutableActions containsObject:NSAccessibilityPressAction])
			[mutableActions addObject:NSAccessibilityPressAction];
		actions = [mutableActions copy];
	}
	return actions;
}

- (void)accessibilityPerformAction:(NSString *)actionString {
	if ([actionString isEqualToString:NSAccessibilityPressAction]) {
		self.on = ![self isOn];
		[self _invokeTargetAction];
	}
	else {
		[super accessibilityPerformAction:actionString];
	}
}

@end

/**
 *  Support for CGColor in Lion
 */

@implementation NSColor (CGColorExtends)

- (CGColorRef)its_CGColor
{
    SEL selector = NSSelectorFromString(@"CGColor");
    CGColorRef result;
    if ([self respondsToSelector:selector]) {
        IMP imp = [self methodForSelector:selector];
        CGColorRef (*func)(id, SEL) = (void *)imp;
        result = func(self, selector);
    } else {
        NSColorSpace *colorSpace = [self colorSpace];
        CGFloat components[[[self colorSpace] numberOfColorComponents]];
        [self getComponents:components];
        result = (__bridge CGColorRef)(CFBridgingRelease(CGColorCreate([colorSpace CGColorSpace], components)));
    }
    return result;
}

@end

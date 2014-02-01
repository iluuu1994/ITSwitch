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
#pragma mark - Preprocessor
// ----------------------------------------------------

#define kAnimationDuration 0.4f

#define kBorderLineWidth 1.f

#define kGoldenRatio 1.61803398875f
#define kDecreasedGoldenRatio 1.38

#define kKnobBackgroundColor [NSColor colorWithCalibratedWhite:1.f alpha:1.f]

#define kDisabledBorderColor [NSColor colorWithCalibratedWhite:0.f alpha:0.25f]
#define kEnabledBorderColor [NSColor colorWithCalibratedRed:0.27f green:0.86f blue:0.36f alpha:1.f]
#define kDisabledBackgroundColor [NSColor colorWithCalibratedWhite:1.f alpha:0.f]
#define kEnabledBackgroundColor [NSColor colorWithCalibratedRed:0.27f green:0.86f blue:0.36f alpha:1.f]



// ---------------------------------------------------------------------------------------
#pragma mark - Interface Extension
// ---------------------------------------------------------------------------------------

@interface ITSwitch () {
    id _target;
    SEL _action;
}

@property (setter = setActive:) BOOL isActive;
@property (setter = setDragged:) BOOL hasDragged;
@property (setter = setDraggingTowardsOn:) BOOL isDraggingTowardsOn;

@property (readonly, strong) CALayer *rootLayer;
@property (readonly, strong) CALayer *backgroundLayer;
@property (readonly, strong) CALayer *knobLayer;

@end



// ---------------------------------------------------------------------------------------
#pragma mark - ITSwitch
// ---------------------------------------------------------------------------------------

@implementation ITSwitch

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
    self.wantsLayer = YES;
    [self setUpLayers];
}

- (void)setUpLayers {
    // Root layer
    _rootLayer = [CALayer layer];
    _rootLayer.delegate = self;
    self.layer = _rootLayer;
    
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
    _knobLayer.backgroundColor = kKnobBackgroundColor.CGColor;
    _knobLayer.borderColor = [NSColor colorWithDeviceWhite:0.f alpha:0.15f].CGColor;
    _knobLayer.borderWidth = .5f;
    _knobLayer.shadowColor = [NSColor blackColor].CGColor;
    _knobLayer.shadowOffset = (CGSize){ .width = 0.f, .height = -2.f };
    _knobLayer.shadowRadius = 1.f;
    _knobLayer.shadowOpacity = 0.3f;
    [_rootLayer addSublayer:_knobLayer];
    
    // Initial
    [self updateLayer];
}



// ----------------------------------------------------
#pragma mark - NSView
// ----------------------------------------------------

- (void)layoutSublayersOfLayer:(CALayer *)layer {
    [CATransaction begin];
    {
        [CATransaction setDisableActions:YES];
        
        [_backgroundLayer setCornerRadius:_backgroundLayer.bounds.size.height / 2.f];
        [_knobLayer setCornerRadius:_knobLayer.bounds.size.height / 2.f];
    }
    [CATransaction commit];
}

- (void)setFrame:(NSRect)frameRect {
    [super setFrame:frameRect];
    
    [CATransaction begin];
    {
        [CATransaction setDisableActions:YES];
        
        self.knobLayer.frame = [self rectForKnob];
    }
    [CATransaction commit];
}



// ----------------------------------------------------
#pragma mark - Update Layer
// ----------------------------------------------------

- (void)updateLayer {
    [CATransaction begin];
    [CATransaction setAnimationDuration:kAnimationDuration];
    {
        // ------------------------------- Animate Colors
        if ((self.hasDragged && self.isDraggingTowardsOn) || (!self.hasDragged && self.isOn)) {
            _backgroundLayer.borderColor = kEnabledBorderColor.CGColor;
            _backgroundLayer.backgroundColor = kEnabledBackgroundColor.CGColor;
        } else {
            _backgroundLayer.borderColor = kDisabledBorderColor.CGColor;
            _backgroundLayer.backgroundColor = kDisabledBackgroundColor.CGColor;
        }
        
        // ------------------------------- Animate Border
        _backgroundLayer.borderWidth = (self.isActive || self.isOn) ? NSHeight(_backgroundLayer.bounds) / 2 : kBorderLineWidth;
        
        // ------------------------------- Animate Frame
        [CATransaction begin];
        [CATransaction setAnimationDuration:kAnimationDuration];
        {
            if (!self.hasDragged) {
                CAMediaTimingFunction *function = [CAMediaTimingFunction functionWithControlPoints:0.25f :1.5f :0.5f :1.f];
                [CATransaction setAnimationTimingFunction:function];
            }
            
            self.knobLayer.frame = [self rectForKnob];
        }
        [CATransaction commit];
    }
    [CATransaction commit];
}

- (CGRect)rectForKnob {
    CGFloat height = NSHeight(_backgroundLayer.bounds) - (kBorderLineWidth * 2.f);
    CGFloat width = !self.isActive ? (NSWidth(_backgroundLayer.bounds) - 2.f * kBorderLineWidth) * 1.f / kGoldenRatio :
                                     (NSWidth(_backgroundLayer.bounds) - 2.f * kBorderLineWidth) * 1.f / kDecreasedGoldenRatio;
    CGFloat x = ((!self.hasDragged && !self.isOn) || (self.hasDragged && !self.isDraggingTowardsOn)) ?
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

- (void)mouseDown:(NSEvent *)theEvent {
    self.isActive = YES;
    
    [self updateLayer];
}

- (void)mouseDragged:(NSEvent *)theEvent {
    self.hasDragged = YES;
    
    NSPoint draggingPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    self.isDraggingTowardsOn = draggingPoint.x >= NSWidth(self.bounds) / 2.f;
    
    [self updateLayer];
}

- (void)mouseUp:(NSEvent *)theEvent {
    self.isActive = NO;
    
    if (!self.hasDragged) self.isOn = !self.isOn;
    else self.isOn = self.isDraggingTowardsOn;
    
    [self updateLayer];
    
    self.hasDragged = NO;
    self.isDraggingTowardsOn = NO;
}


// ----------------------------------------------------
#pragma mark - NSControl
// ----------------------------------------------------

- (id)target {
    return _target;
}

- (void)setTarget:(id)anObject {
    _target = anObject;
}

- (SEL)action {
    return _action;
}

- (void)setAction:(SEL)aSelector {
    _action = aSelector;
}



// ----------------------------------------------------
#pragma mark - Accessors
// ----------------------------------------------------

- (void)setOn:(BOOL)isOn {
    if (_isOn != isOn) {
        _isOn = isOn;

        if (self.target && self.action) {
            NSMethodSignature *signature = [[self.target class] instanceMethodSignatureForSelector:self.action];
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
            [invocation setTarget:self.target];
            [invocation setSelector:self.action];
            [invocation setArgument:(void *)&self atIndex:2];
            
            [invocation invoke];
        }
        
        [self updateLayer];
    }
}

@end

//
//  DrawableOpenGLView.m
//  Emerald Frame
//
//  Created by Dan Knapp on 10/9/09.
//  Copyright 2009 Dan Knapp. All rights reserved.
//

#import "DrawableOpenGLView.h"
#import "Drawable.h"


@implementation DrawableOpenGLView

- (id) initWithFrame: (NSRect) frame
	 pixelFormat: (NSOpenGLPixelFormat *) pixelFormat
	    drawable: (Drawable *) newDrawable
{
    self = [super initWithFrame: frame pixelFormat: pixelFormat];
    if (self) {
	drawable = newDrawable;
	[self addTrackingRect: [self bounds]
	      owner: self
	      userData: nil
	      assumeInside: NO];
    }
    return self;
}

- (BOOL) acceptsFirstResponder {
    return YES;
}

- (void) drawRect: (NSRect) dirtyRect {
    [drawable draw];
}

- (void) keyDown: (NSEvent *) event {
    [drawable keyDown: event];
}

- (void) keyUp: (NSEvent *) event {
    [drawable keyUp: event];
}

- (void) mouseDown: (NSEvent *) event {
    [drawable mouseDown: event];
}

- (void) rightMouseDown: (NSEvent *) event {
    [drawable mouseDown: event];
}

- (void) otherMouseDown: (NSEvent *) event {
    [drawable mouseDown: event];
}

- (void) mouseUp: (NSEvent *) event {
    [drawable mouseUp: event];
}

- (void) rightMouseUp: (NSEvent *) event {
    [drawable mouseUp: event];
}

- (void) otherMouseUp: (NSEvent *) event {
    [drawable mouseUp: event];
}

- (void) mouseMoved: (NSEvent *) event {
    [drawable mouseMove: event];
}

- (void) mouseDragged: (NSEvent *) event {
    [drawable mouseMove: event];
}

- (void) rightMouseDragged: (NSEvent *) event {
    [drawable mouseMove: event];
}

- (void) otherMouseDragged: (NSEvent *) event {
    [drawable mouseMove: event];
}

- (void) mouseEntered: (NSEvent *) event {
    [drawable mouseEnter: event];
}

- (void) mouseExited: (NSEvent *) event {
    [drawable mouseExit: event];
}

@end

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
    }
    return self;
}

- (void) drawRect: (NSRect) dirtyRect {
    [drawable draw];
}

@end

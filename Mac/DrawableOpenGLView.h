//  -*- mode: objc -*-
//  DrawableOpenGLView.h
//  Emerald Frame
//
//  Created by Dan Knapp on 10/9/09.
//  Copyright 2009 Dan Knapp. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class Drawable;
@interface DrawableOpenGLView : NSOpenGLView {
    Drawable *drawable;
}

- (id) initWithFrame: (NSRect) frame
	 pixelFormat: (NSOpenGLPixelFormat *) pixelFormat
	    drawable: (Drawable *) newDrawable;
@end

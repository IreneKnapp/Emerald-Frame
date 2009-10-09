//  -*- mode: objc -*-
//  Drawable.h
//  Emerald Frame
//
//  Created by Dan Knapp on 10/9/09.
//  Copyright 2009 Dan Knapp. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "Emerald-Frame.h"


@class DrawableOpenGLView;
@interface Drawable : NSWindowController {
    NSWindow *window;
    DrawableOpenGLView *openGLView;
    void (*drawCallback)(EF_Drawable drawable, void *context);
    void *drawCallbackContext;
}

- (id) initWithWidth: (int) width
	      height: (int) height
	     display: (NSScreen *) display
	  fullScreen: (bool) fullScreen
	 pixelFormat: (NSOpenGLPixelFormat *) pixelFormat;
- (void) setTitle: (NSString *) title;
- (void) setDrawCallback: (void (*)(EF_Drawable drawable, void *context)) callback
		 context: (void *) context;
- (void) draw;
- (void) makeCurrent;
- (void) swapBuffers;
@end

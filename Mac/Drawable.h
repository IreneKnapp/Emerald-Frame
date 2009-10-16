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
    
    void (*keyDownCallback)(EF_Drawable drawable, EF_Event event, void *context);
    void *keyDownCallbackContext;
    void (*keyUpCallback)(EF_Drawable drawable, EF_Event event, void *context);
    void *keyUpCallbackContext;
    void (*mouseDownCallback)(EF_Drawable drawable, EF_Event event, void *context);
    void *mouseDownCallbackContext;
    void (*mouseUpCallback)(EF_Drawable drawable, EF_Event event, void *context);
    void *mouseUpCallbackContext;
    void (*mouseMoveCallback)(EF_Drawable drawable, EF_Event event, void *context);
    void *mouseMoveCallbackContext;
    void (*mouseEnterCallback)(EF_Drawable drawable, EF_Event event, void *context);
    void *mouseEnterCallbackContext;
    void (*mouseExitCallback)(EF_Drawable drawable, EF_Event event, void *context);
    void *mouseExitCallbackContext;
}

- (id) initWithWidth: (int) width
	      height: (int) height
	     display: (NSScreen *) display
	  fullScreen: (bool) fullScreen
	 pixelFormat: (NSOpenGLPixelFormat *) pixelFormat;
- (void) setTitle: (NSString *) title;
- (void) draw;
- (void) keyDown: (NSEvent *) event;
- (void) keyUp: (NSEvent *) event;
- (void) mouseDown: (NSEvent *) event;
- (void) mouseUp: (NSEvent *) event;
- (void) mouseMove: (NSEvent *) event;
- (void) mouseEnter: (NSEvent *) event;
- (void) mouseExit: (NSEvent *) event;
- (void) redraw;
- (void) makeCurrent;
- (void) swapBuffers;
- (void) setDrawCallback: (void (*)(EF_Drawable drawable, void *context)) callback
		 context: (void *) context;
- (void) setKeyDownCallback: (void (*)(EF_Drawable drawable,
				       EF_Event event,
				       void *context)) callback
		    context: (void *) context;
- (void) setKeyUpCallback: (void (*)(EF_Drawable drawable,
				       EF_Event event,
				       void *context)) callback
		  context: (void *) context;
- (void) setMouseDownCallback: (void (*)(EF_Drawable drawable,
					 EF_Event event,
					 void *context)) callback
		      context: (void *) context;
- (void) setMouseUpCallback: (void (*)(EF_Drawable drawable,
				       EF_Event event,
				       void *context)) callback
		    context: (void *) context;
- (void) setMouseMoveCallback: (void (*)(EF_Drawable drawable,
					  EF_Event event,
					  void *context)) callback
		       context: (void *) context;
- (void) setMouseEnterCallback: (void (*)(EF_Drawable drawable,
					     EF_Event event,
					     void *context)) callback
			  context: (void *) context;
- (void) setMouseExitCallback: (void (*)(EF_Drawable drawable,
					 EF_Event event,
					 void *context)) callback
		      context: (void *) context;
@end

//
//  Drawable.m
//  Emerald Frame
//
//  Created by Dan Knapp on 10/9/09.
//  Copyright 2009 Dan Knapp. All rights reserved.
//

#import "Drawable.h"
#import "DrawableOpenGLView.h"


extern utf8 *ef_internal_application_name();


@implementation Drawable


- (id) initWithWidth: (int) width
	      height: (int) height
	     display: (NSScreen *) display
	  fullScreen: (bool) fullScreen
	 pixelFormat: (NSOpenGLPixelFormat *) pixelFormat
{
    drawCallback = NULL;
    drawCallbackContext = NULL;
    
    if(!display)
	display = [NSScreen mainScreen];

    NSRect displayFrame = [display frame];
    CGFloat top = (displayFrame.size.height - height) / 2 + displayFrame.origin.y;
    CGFloat left = (displayFrame.size.width - width) / 2 + displayFrame.origin.x;
    
    NSUInteger styleMask = 0;
    styleMask |= NSClosableWindowMask;
    styleMask |= NSMiniaturizableWindowMask;
    if(!fullScreen)
	styleMask |= NSTitledWindowMask;
    
    window = [[NSWindow alloc] initWithContentRect: NSMakeRect(left, top, width, height)
			       styleMask: styleMask
			       backing: NSBackingStoreBuffered
			       defer: NO];

    NSString *applicationName
	= [NSString stringWithUTF8String: (char *) ef_internal_application_name()];
    [window setTitle: applicationName];

    [window setAcceptsMouseMovedEvents: YES];

    NSRect contentFrame = [window frame];
    contentFrame.origin = NSMakePoint(0.0, 0.0);
    
    openGLView = [[DrawableOpenGLView alloc] initWithFrame: contentFrame
					     pixelFormat: pixelFormat
					     drawable: self];
    [window setContentView: openGLView];
    [window setInitialFirstResponder: openGLView];
    
    [window makeKeyAndOrderFront: self];
    
    return self;
}


- (void) release {
    [window release];
    [openGLView release];
    [super release];
}


- (void) setTitle: (NSString *) title {
    [window setTitle: title];
}


- (void) draw {
    if(drawCallback) {
	drawCallback((EF_Drawable) self, drawCallbackContext);
    }
}


- (void) keyDown: (NSEvent *) event {
    if(keyDownCallback) {
	keyDownCallback((EF_Drawable) self,
			(EF_Event) event,
			keyDownCallbackContext);
    }
}


- (void) keyUp: (NSEvent *) event {
    if(keyUpCallback) {
	keyUpCallback((EF_Drawable) self,
		      (EF_Event) event,
		      keyUpCallbackContext);
    }
}


- (void) mouseDown: (NSEvent *) event {
    if(mouseDownCallback) {
	mouseDownCallback((EF_Drawable) self,
			  (EF_Event) event,
			  mouseDownCallbackContext);
    }
}


- (void) mouseUp: (NSEvent *) event {
    if(mouseUpCallback) {
	mouseUpCallback((EF_Drawable) self,
			(EF_Event) event,
			mouseUpCallbackContext);
    }
}


- (void) mouseMove: (NSEvent *) event {
    if(mouseMoveCallback) {
	mouseMoveCallback((EF_Drawable) self,
			  (EF_Event) event,
			  mouseMoveCallbackContext);
    }
}


- (void) mouseEnter: (NSEvent *) event {
    if(mouseEnterCallback) {
	mouseEnterCallback((EF_Drawable) self,
			   (EF_Event) event,
			   mouseEnterCallbackContext);
    }
}


- (void) mouseExit: (NSEvent *) event {
    if(mouseExitCallback) {
	mouseExitCallback((EF_Drawable) self,
			  (EF_Event) event,
			  mouseExitCallbackContext);
    }
}


- (void) redraw {
    [openGLView setNeedsDisplay: YES];
}


- (void) makeCurrent {
    [[openGLView openGLContext] makeCurrentContext];
}


- (void) swapBuffers {
    [[openGLView openGLContext] flushBuffer];
}


- (void) setDrawCallback: (void (*)(EF_Drawable drawable, void *context)) callback
		 context: (void *) context
{
    drawCallback = callback;
    drawCallbackContext = context;
    [openGLView setNeedsDisplay: YES];
}


- (void) setKeyDownCallback: (void (*)(EF_Drawable drawable,
				       EF_Event event,
				       void *context)) callback
		    context: (void *) context
{
    keyDownCallback = callback;
    keyDownCallbackContext = context;
}


- (void) setKeyUpCallback: (void (*)(EF_Drawable drawable,
				     EF_Event event,
				     void *context)) callback
		  context: (void *) context
{
    keyUpCallback = callback;
    keyUpCallbackContext = context;
}


- (void) setMouseDownCallback: (void (*)(EF_Drawable drawable,
					 EF_Event event,
					 void *context)) callback
		      context: (void *) context
{
    mouseDownCallback = callback;
    mouseDownCallbackContext = context;
}


- (void) setMouseUpCallback: (void (*)(EF_Drawable drawable,
				       EF_Event event,
				       void *context)) callback
		    context: (void *) context
{
    mouseUpCallback = callback;
    mouseUpCallbackContext = context;
}


- (void) setMouseMoveCallback: (void (*)(EF_Drawable drawable,
					 EF_Event event,
					 void *context)) callback
		      context: (void *) context
{
    mouseMoveCallback = callback;
    mouseMoveCallbackContext = context;
}


- (void) setMouseEnterCallback: (void (*)(EF_Drawable drawable,
					  EF_Event event,
					  void *context)) callback
		       context: (void *) context
{
    mouseEnterCallback = callback;
    mouseEnterCallbackContext = context;
}


- (void) setMouseExitCallback: (void (*)(EF_Drawable drawable,
					 EF_Event event,
					 void *context)) callback
		      context: (void *) context
{
    mouseExitCallback = callback;
    mouseExitCallbackContext = context;
}

@end

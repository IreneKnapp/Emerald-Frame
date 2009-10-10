//
//  Drawable.m
//  Emerald Frame
//
//  Created by Dan Knapp on 10/9/09.
//  Copyright 2009 Dan Knapp. All rights reserved.
//

#import "Drawable.h"
#import "DrawableOpenGLView.h"


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

    NSRect contentFrame = [window frame];
    contentFrame.origin = NSMakePoint(0.0, 0.0);
    
    openGLView = [[DrawableOpenGLView alloc] initWithFrame: contentFrame
					     pixelFormat: pixelFormat
					     drawable: self];
    [window setContentView: openGLView];
    
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


- (void) setDrawCallback: (void (*)(EF_Drawable drawable, void *context)) callback
		 context: (void *) context
{
    drawCallback = callback;
    drawCallbackContext = context;
    [openGLView setNeedsDisplay: YES];
}


- (void) draw {
    if(drawCallback) {
	drawCallback((EF_Drawable) self, drawCallbackContext);
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

@end

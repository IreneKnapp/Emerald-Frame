//
//  Drawable.m
//  Emerald Frame
//
//  Created by Dan Knapp on 10/9/09.
//  Copyright 2009 Dan Knapp. All rights reserved.
//

#import "Drawable.h"

#include "Emerald-Frame.h"


@implementation Drawable


- (id) initWithWidth: (int) width
	      height: (int) height
	     display: (NSScreen *) display
	  fullScreen: (bool) fullScreen
	 pixelFormat: (NSOpenGLPixelFormat *) pixelFormat
{
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
    
    [window makeKeyAndOrderFront: self];
    
    return self;
}


- (void) release {
    [window release];
    [super release];
}


- (void) setTitle: (NSString *) title {
    [window setTitle: title];
}

@end

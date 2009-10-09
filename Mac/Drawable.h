//  -*- mode: objc -*-
//  Drawable.h
//  Emerald Frame
//
//  Created by Dan Knapp on 10/9/09.
//  Copyright 2009 Dan Knapp. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Drawable : NSWindowController {
    NSWindow *window;
}

- (id) initWithWidth: (int) width
	      height: (int) height
	     display: (NSScreen *) display
	  fullScreen: (bool) fullScreen
	 pixelFormat: (NSOpenGLPixelFormat *) pixelFormat;
- (void) setTitle: (NSString *) title;
@end

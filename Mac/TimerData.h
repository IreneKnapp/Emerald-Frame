//  -*- mode: objc -*-
//  TimerData.h
//  Emerald Frame
//
//  Created by Dan Knapp on 10/9/09.
//  Copyright 2009 Dan Knapp. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "Emerald-Frame.h"


@interface TimerData : NSObject {
    void (*callback)(EF_Timer timer, void *context);
    void *context;
}

- (id) initWithCallback: (void (*)(EF_Timer timer, void *context)) callback
		context: (void *) context;
- (void) invoke: (NSTimer *) timer;
@end

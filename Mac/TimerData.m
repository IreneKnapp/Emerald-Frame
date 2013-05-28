//
//  TimerData.m
//  Emerald Frame
//
//  Created by Dan Knapp on 10/9/09.
//  Copyright 2009 Dan Knapp. All rights reserved.
//

#import "TimerData.h"


@implementation TimerData
- (id) initWithCallback: (void (*)(EF_Timer timer, void *context)) newCallback
		context: (void *) newContext
{
    callback = newCallback;
    context = newContext;
    return self;
}


- (void) invoke: (NSTimer *) timer {
    if(callback) {
	callback((__bridge EF_Timer) timer, context);
    }
}


@end

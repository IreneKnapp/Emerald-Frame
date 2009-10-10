//
//  Time.m
//  Emerald Frame
//
//  Created by Dan Knapp on 10/9/09.
//  Copyright 2009 Dan Knapp. All rights reserved.
//

#import <math.h>
#import "Emerald-Frame.h"
#import "TimerData.h"


EF_Error ef_internal_time_init() {
    return 0;
}


EF_Timer ef_time_new_oneshot_timer(int milliseconds,
				   void (*callback)(EF_Timer timer, void *context),
				   void *context)
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    TimerData *timerData = [[TimerData alloc] initWithCallback: callback
					      context: context];
    NSTimer *timer
	= [NSTimer scheduledTimerWithTimeInterval: (NSTimeInterval) milliseconds / 1000.0
		   target: [NSApp delegate]
		   selector: @selector(timer:)
		   userInfo: timerData
		   repeats: NO];

    [pool drain];
    
    return (EF_Timer) timer;
}


EF_Timer ef_time_new_repeating_timer(int milliseconds,
				     void (*callback)(EF_Timer timer, void *context),
				     void *context)
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    TimerData *timerData = [[TimerData alloc] initWithCallback: callback
					      context: context];
    NSTimer *timer
	= [NSTimer scheduledTimerWithTimeInterval: (NSTimeInterval) milliseconds / 1000.0
		   target: [NSApp delegate]
		   selector: @selector(timer:)
		   userInfo: timerData
		   repeats: YES];

    [pool drain];
    
    return (EF_Timer) timer;
}


void ef_timer_cancel(EF_Timer timer) {
    [(NSTimer *) timer invalidate];
}


uint64_t ef_time_unix_epoch() {
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
    return floor(interval * 1000.0);
}

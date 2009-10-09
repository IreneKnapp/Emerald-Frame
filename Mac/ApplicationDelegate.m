//
//  ApplicationDelegate.m
//  Emerald Frame
//
//  Created by Dan Knapp on 10/9/09.
//  Copyright 2009 Dan Knapp. All rights reserved.
//

#import "ApplicationDelegate.h"

extern void ef_internal_populate_main_menu();

@implementation ApplicationDelegate

- (void) applicationWillFinishLaunching: (NSNotification *) notification {
    ef_internal_populate_main_menu();
}

@end

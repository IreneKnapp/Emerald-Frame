//
//  Configuration.m
//  Emerald Frame
//
//  Created by Dan Knapp on 10/10/09.
//  Copyright 2009 Dan Knapp. All rights reserved.
//

#import <stdlib.h>

#import "Emerald-Frame.h"


static utf8 *result_buffer = NULL;
static size_t result_buffer_size = 0;


utf8 *ef_configuration_resource_directory() {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSString *path = [NSString stringWithFormat: @"%@/",
			       [[NSBundle mainBundle] resourcePath]];
    
    size_t required_buffer_size
	= [path lengthOfBytesUsingEncoding: NSUTF8StringEncoding] + 1;
    while(required_buffer_size > result_buffer_size) {
	if(result_buffer_size == 0)
	    result_buffer_size = 128;
	else
	    result_buffer_size *= 2;
	
	result_buffer = realloc(result_buffer, result_buffer_size * sizeof(uint8_t));
    }
    NSUInteger usedLength;
    [path getBytes: result_buffer
	  maxLength: result_buffer_size
	  usedLength: &usedLength
	  encoding: NSUTF8StringEncoding
	  options: 0
	  range: NSMakeRange(0, [path length])
	  remainingRange: NULL];
    result_buffer[usedLength] = '\0';
    
    [pool drain];
    
    return result_buffer;
}

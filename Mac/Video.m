#include <math.h>
#import <Cocoa/Cocoa.h>

#import "Drawable.h"

#include "emerald-frame.h"


struct ef_drawable_parameters {
    boolean double_buffer;
    boolean stereo;
    int aux_buffers;
    int color_size;
    int alpha_size;
    int depth_size;
    int stencil_size;
    int accumulation_size;
    int samples;
    boolean aux_depth_stencil;
    boolean color_float;
    boolean multisample;
    boolean supersample;
    boolean sample_alpha;
};

static struct ef_drawable_parameters drawable_parameters;


EF_Error ef_internal_video_init() {
    drawable_parameters.double_buffer = False;
    drawable_parameters.stereo = False;
    drawable_parameters.aux_buffers = 0;
    drawable_parameters.color_size = 8;
    drawable_parameters.alpha_size = 0;
    drawable_parameters.depth_size = 0;
    drawable_parameters.stencil_size = 0;
    drawable_parameters.accumulation_size = 0;
    drawable_parameters.samples = 0;
    drawable_parameters.aux_depth_stencil = False;
    drawable_parameters.color_float = False;
    drawable_parameters.multisample = False;
    drawable_parameters.supersample = False;
    drawable_parameters.sample_alpha = False;
    
    return 0;
}


EF_Drawable ef_video_new_drawable(int width,
				  int height,
				  boolean full_screen,
				  EF_Display display)
{
    // Create the window-manager connection, if it doesn't exist.
    [NSApplication sharedApplication];
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSOpenGLPixelFormatAttribute attributes[30];
    int point = 0;

    if(drawable_parameters.double_buffer) {
	attributes[point] = NSOpenGLPFADoubleBuffer;
	point++;
    }
    
    if(drawable_parameters.stereo) {
	attributes[point] = NSOpenGLPFAStereo;
	point++;
    }
    
    attributes[point] = NSOpenGLPFAAuxBuffers;
    point++;
    attributes[point] = drawable_parameters.aux_buffers;
    point++;

    attributes[point] = NSOpenGLPFAColorSize;
    point++;
    attributes[point] = drawable_parameters.color_size;
    point++;
    
    attributes[point] = NSOpenGLPFAAlphaSize;
    point++;
    attributes[point] = drawable_parameters.alpha_size;
    point++;
    
    attributes[point] = NSOpenGLPFADepthSize;
    point++;
    attributes[point] = drawable_parameters.depth_size;
    point++;

    attributes[point] = NSOpenGLPFAStencilSize;
    point++;
    attributes[point] = drawable_parameters.stencil_size;
    point++;

    attributes[point] = NSOpenGLPFAAccumSize;
    point++;
    attributes[point] = drawable_parameters.accumulation_size;
    point++;
    
    if(drawable_parameters.multisample || drawable_parameters.supersample) {
	attributes[point] = NSOpenGLPFASampleBuffers;
	point++;
	attributes[point] = 1;
	point++;
    
	attributes[point] = NSOpenGLPFASamples;
	point++;
	attributes[point] = drawable_parameters.samples;
	point++;

	if(drawable_parameters.multisample) {
	    attributes[point] = NSOpenGLPFAMultisample;
	    point++;
	}
	
	if(drawable_parameters.supersample) {
	    attributes[point] = NSOpenGLPFASupersample;
	    point++;
	}
    }
    
    if(drawable_parameters.aux_depth_stencil) {
	attributes[point] = NSOpenGLPFAAuxDepthStencil;
	point++;
    }
    
    if(drawable_parameters.color_float) {
	attributes[point] = NSOpenGLPFAColorFloat;
	point++;
    }

    if(drawable_parameters.sample_alpha) {
	attributes[point] = NSOpenGLPFASampleAlpha;
	point++;
    }
    
    attributes[point] = 0;
    
    NSOpenGLPixelFormat *pixelFormat
	= [[NSOpenGLPixelFormat alloc] initWithAttributes: attributes];
    Drawable *drawable = [[Drawable alloc] initWithWidth: width
					   height: height
					   display: nil
					   fullScreen: full_screen
					   pixelFormat: pixelFormat];
    [pixelFormat release];

    [pool drain];
    
    return (EF_Drawable) drawable;
}


void ef_drawable_set_title(EF_Drawable drawable, utf8 *title) {
    NSString *titleString = [NSString stringWithUTF8String: (char *) title];
    [(Drawable *) drawable setTitle: titleString];
}


void ef_drawable_set_draw_callback(EF_Drawable drawable,
				   void (*callback)(EF_Drawable drawable,
						    void *context),
				   void *context)
{
    [(Drawable *) drawable setDrawCallback: callback context: context];
}


void ef_drawable_swap_buffers(EF_Drawable drawable) {
    [(Drawable*) drawable swapBuffers];
}


void ef_video_set_double_buffer(boolean double_buffer) {
    drawable_parameters.double_buffer = double_buffer;
}


void ef_video_set_stereo(boolean stereo) {
    drawable_parameters.stereo = stereo;
}


void ef_video_set_aux_buffers(int aux_buffers) {
    drawable_parameters.aux_buffers = aux_buffers;
}


void ef_video_set_color_size(int color_size) {
    drawable_parameters.color_size = color_size;
}


void ef_video_set_alpha_size(int alpha_size) {
    drawable_parameters.alpha_size = alpha_size;
}


void ef_video_set_depth_size(int depth_size) {
    drawable_parameters.depth_size = depth_size;
}


void ef_video_set_stencil_size(int stencil_size) {
    drawable_parameters.stencil_size = stencil_size;
}


void ef_video_set_accumulation_size(int accumulation_size) {
    drawable_parameters.accumulation_size = accumulation_size;
}


void ef_video_set_samples(int samples) {
    drawable_parameters.samples = samples;
}


void ef_video_set_aux_depth_stencil(boolean aux_depth_stencil) {
    drawable_parameters.aux_depth_stencil = aux_depth_stencil;
}


void ef_video_set_color_float(boolean color_float) {
    drawable_parameters.color_float = color_float;
}


void ef_video_set_multisample(boolean multisample) {
    drawable_parameters.multisample = multisample;
}


void ef_video_set_supersample(boolean supersample) {
    drawable_parameters.supersample = supersample;
}


void ef_video_set_sample_alpha(boolean sample_alpha) {
    drawable_parameters.sample_alpha = sample_alpha;
}


EF_Display ef_video_current_display() {
    return (EF_Display) [NSScreen mainScreen];
}


EF_Display ef_video_next_display(EF_Display previous) {
    NSArray *screens = [NSScreen screens];

    NSUInteger index;
    if(!previous) {
	index = 0;
    } else {
	NSUInteger previousIndex = [screens indexOfObject: (NSScreen *) previous];
	if(previousIndex == NSNotFound)
	    return NULL;
	else
	    index = previousIndex + 1;
    }
    
    if(index + 1 < [screens count])
	return (EF_Display) [screens objectAtIndex: index];
    else
	return NULL;
}


int ef_video_display_depth(EF_Display display) {
    NSWindowDepth depth = [(NSScreen *) display depth];
    return NSBitsPerPixelFromDepth(depth);
}


int ef_video_display_width(EF_Display display) {
    NSRect frame = [(NSScreen *) display frame];
    return floorf(frame.size.width);
}


int ef_video_display_height(EF_Display display) {
    NSRect frame = [(NSScreen *) display frame];
    return floorf(frame.size.height);
}


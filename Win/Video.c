#import <math.h>

#import "Emerald-Frame.h"


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
    // TODO
}


void ef_drawable_set_title(EF_Drawable drawable, utf8 *title) {
    // TODO
}


void ef_drawable_set_draw_callback(EF_Drawable drawable,
				   void (*callback)(EF_Drawable drawable,
						    void *context),
				   void *context)
{
    // TODO
}


void ef_drawable_redraw(EF_Drawable drawable) {
    // TODO
}


void ef_drawable_make_current(EF_Drawable drawable) {
    // TODO
}


void ef_drawable_swap_buffers(EF_Drawable drawable) {
    // TODO
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
    // TODO
}


EF_Display ef_video_next_display(EF_Display previous) {
    // TODO
}


int ef_display_depth(EF_Display display) {
    // TODO
}


int ef_display_width(EF_Display display) {
    // TODO
}


int ef_display_height(EF_Display display) {
    // TODO
}


EF_Error ef_video_load_texture_file(utf8 *filename,
				    GLuint id,
				    boolean build_mipmaps)
{
    // TODO
}


EF_Error ef_video_load_texture_memory(uint8_t *bytes, size_t size,
				      GLuint id,
				      boolean build_mipmaps)
{
    // TODO
}

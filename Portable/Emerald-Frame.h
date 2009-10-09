#include <stdint.h>

typedef int EF_Error;
typedef void *EF_Drawable;
typedef void *EF_Display;
typedef int boolean;
typedef uint8_t utf8;
typedef uint32_t utf32;

#define False 0
#define True 1

#define EF_ERROR_PARAM 1

// General
EF_Error ef_init(utf8 *application_name);
EF_Error ef_quit();
utf8 *ef_version_string();
utf8 *ef_error_string(EF_Error error);
utf8 *ef_internal_application_name();
void ef_main();

// Video
EF_Error ef_internal_video_init();
EF_Drawable ef_video_new_drawable(int width,
				  int height,
				  boolean full_screen,
				  EF_Display display);
void ef_video_drawable_set_title(EF_Drawable drawable, utf8 *title);
void ef_video_set_double_buffer(boolean double_buffer);
void ef_video_set_stereo(boolean stereo);
void ef_video_set_aux_buffers(int aux_buffers);
void ef_video_set_color_size(int color_size);
void ef_video_set_alpha_size(int alpha_size);
void ef_video_set_depth_size(int depth_size);
void ef_video_set_stencil_size(int stencil_size);
void ef_video_set_accumulation_size(int accumulation_size);
void ef_video_set_samples(int samples);
void ef_video_set_aux_depth_stencil(boolean aux_depth_stencil);
void ef_video_set_color_float(boolean color_float);
void ef_video_set_multisample(boolean multisample);
void ef_video_set_supersample(boolean supersample);
void ef_video_set_sample_alpha(boolean sample_alpha);
EF_Display ef_video_current_display();
EF_Display ef_video_next_display(EF_Display previous);
int ef_video_display_depth(EF_Display display);
int ef_video_display_width(EF_Display display);
int ef_video_display_height(EF_Display display);

// Audio

// Time

// Input

// Text

// Configuration

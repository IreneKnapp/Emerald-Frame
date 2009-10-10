#include <stdint.h>
#include <stdlib.h>

#ifdef __APPLE__
#include <OpenGL/OpenGL.h>
#include <OpenGL/glu.h>
#endif

typedef int EF_Error;
typedef void *EF_Drawable;
typedef void *EF_Display;
typedef void *EF_Timer;
typedef int boolean;
typedef uint8_t utf8;
typedef uint32_t utf32;

#ifndef NULL
#define NULL ((void *) 0)
#endif

#define False 0
#define True 1

#define EF_ERROR_PARAM 1
#define EF_ERROR_FILE 2
#define EF_ERROR_IMAGE_DATA 3

// General
EF_Error ef_init(utf8 *application_name);
utf8 *ef_version_string();
utf8 *ef_error_string(EF_Error error);
void ef_main();

// Video
EF_Drawable ef_video_new_drawable(int width,
				  int height,
				  boolean full_screen,
				  EF_Display display);
void ef_drawable_set_title(EF_Drawable drawable, utf8 *title);
void ef_drawable_set_draw_callback(EF_Drawable drawable,
				   void (*callback)(EF_Drawable drawable,
						    void *context),
				   void *context);
void ef_drawable_redraw(EF_Drawable drawable);
void ef_drawable_make_current(EF_Drawable drawable);
void ef_drawable_swap_buffers(EF_Drawable drawable);
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
int ef_display_depth(EF_Display display);
int ef_display_width(EF_Display display);
int ef_display_height(EF_Display display);
EF_Error ef_video_load_texture_file(utf8 *filename, GLuint id, boolean build_mipmaps);
EF_Error ef_video_load_texture_memory(uint8_t *data, size_t size, GLuint id, boolean build_mipmaps);

// Audio

// Time
EF_Timer ef_time_new_oneshot_timer(int milliseconds,
				   void (*callback)(EF_Timer timer, void *context),
				   void *context);
EF_Timer ef_time_new_repeating_timer(int milliseconds,
				     void (*callback)(EF_Timer timer, void *context),
				     void *context);
void ef_timer_cancel(EF_Timer timer);
uint64_t ef_time_unix_epoch();

// Input

// Text

// Configuration
utf8 *ef_configuration_resource_directory();

// Pasteboard

#include <stdint.h>

#define False 0
#define True 1

typedef int EF_Error;
typedef uint32_t EF_Drawable;
typedef int boolean;
typedef uint8_t utf8;
typedef uint32_t utf32;

// General
EF_Error ef_init();
EF_Error ef_quit();
utf8 *ef_version_string();
utf8 *ef_error_string(EF_Error error);

// Video
EF_Error ef_internal_video_init();
EF_Drawable ef_video_new_drawable(boolean full_screen, int width, int height);
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

// Audio

// Time

// Input

// Text

// Configuration

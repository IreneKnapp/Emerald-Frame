#include "emerald-frame.h"
#include <stdio.h>
#include <unistd.h>


void draw(EF_Drawable drawable, void *context);


int main(int argc, char **argv) {
    ef_init((utf8 *) "Test Application");
    printf("%s\n", ef_version_string());
    
    ef_video_set_double_buffer(True);
    ef_video_set_color_size(24);
    ef_video_set_alpha_size(8);
    ef_video_set_depth_size(8);
    ef_video_set_stencil_size(8);
    ef_video_set_accumulation_size(24);
    ef_video_set_samples(5);
    ef_video_set_multisample(True);
    EF_Drawable drawable = ef_video_new_drawable(640, 480, False, NULL);
    ef_video_drawable_set_draw_callback(drawable, draw, NULL);
    
    ef_main();
    
    sleep(5);
}


void draw(EF_Drawable drawable, void *context) {
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrtho(0, 640, 0, 480, -300, 300);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    
    glClearColor(0.0f, 0.0f, 0.5f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    ef_video_drawable_swap_buffers(drawable);
}

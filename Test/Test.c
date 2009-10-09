#include "emerald-frame.h"
#include <stdio.h>
#include <unistd.h>


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
    
    ef_main();
    
    sleep(5);
    
    ef_quit();
}

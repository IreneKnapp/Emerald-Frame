#include "emerald-frame.h"
#include "stdio.h"


void init_gl(EF_Drawable drawable);
void draw(EF_Drawable drawable, void *context);


int main(int argc, char **argv) {
    ef_init((utf8 *) "Test Application");

    {
	ef_text_compute_available_members_of_font_family((utf8 *) "Palatino");
	int32_t n_fonts = ef_text_computed_count();
	printf("%i total members\n", n_fonts);
	for(int32_t i = 0; i < n_fonts; i++) {
	    utf8 *name = ef_text_computed_name_n(i);
	    printf("  \"%s\"", name);
	    free(name);

	    utf8 *style_name = ef_text_computed_style_name_n(i);
	    printf(" \"%s\"", style_name);
	    free(style_name);

	    EF_Font_Weight weight = ef_text_computed_weight_n(i);
	    printf(" %i", weight);
	    
	    EF_Font_Traits traits = ef_text_computed_traits_n(i);
	    printf(" 0x%04x\n", traits);
	}
	printf("\n");
	ef_text_discard_computed();
    }
    
    ef_video_set_double_buffer(True);
    ef_video_set_color_size(24);
    ef_video_set_alpha_size(8);
    ef_video_set_depth_size(8);
    ef_video_set_stencil_size(8);
    ef_video_set_accumulation_size(24);
    ef_video_set_samples(5);
    ef_video_set_multisample(True);
    EF_Drawable drawable = ef_video_new_drawable(640, 480, False, NULL);
    ef_drawable_set_draw_callback(drawable, draw, NULL);
    
    init_gl(drawable);

    ef_main();
}


void init_gl(EF_Drawable drawable) {
    ef_drawable_make_current(drawable);
    
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrtho(0, 640, 0, 480, -300, 300);
    
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
}


void draw(EF_Drawable drawable, void *context) {
    glClearColor(0.0f, 0.0f, 0.5f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);

    ef_drawable_swap_buffers(drawable);
}

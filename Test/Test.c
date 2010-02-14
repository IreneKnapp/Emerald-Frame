#include "emerald-frame.h"
#include "stdio.h"


static EF_Attributed_String label;

void init_gl(EF_Drawable drawable);
void draw(EF_Drawable drawable, void *context);


int main(int argc, char **argv) {
    ef_init((utf8 *) "Test Application");
    
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
    
    EF_Text_Attributes attributes = ef_text_new_attributes();
    
    EF_Font font = ef_text_specific_font((utf8 *) "Times New Roman",
					 0,
					 EF_FONT_WEIGHT_REGULAR,
					 18.0);
    if(!font) {
	printf("Unable to load font.\n");
	return 1;
    }
    ef_text_attributes_set_font(attributes, font);
    ef_font_delete(font);

    label = ef_text_new_attributed_string_with_text_and_attributes
	((utf8 *) "Sphinx of black quartz, judge my vow.", attributes);
    
    ef_text_attributes_delete(attributes);
    
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
    glClearColor(0.8f, 0.8f, 1.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glPushMatrix();
    glTranslatef(0.0f, 40.0f, 0.0f);
    ef_attributed_string_draw(label, drawable);
    glPopMatrix();

    ef_drawable_swap_buffers(drawable);
}

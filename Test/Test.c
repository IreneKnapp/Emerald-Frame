#include "emerald-frame.h"
#include "stdio.h"


static EF_Text_Flow label;
static EF_Text_Flow paragraphs;

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

    label = ef_text_new_text_flow_with_text_and_attributes
	((utf8 *) "Sphinx of black quartz, judge my vow.", attributes);

    paragraphs = ef_text_new_text_flow_with_text_and_attributes
	((utf8 *) "Lorem ipsum dolor sit amet, consectetur adipiscing elit.  Vestibulum purus tellus, fermentum a dictum nec, pulvinar ac nibh.  Suspendisse potenti.  Mauris fringilla consectetur volutpat.  Fusce sed sem non augue eleifend faucibus at a augue.  Donec consectetur, neque in vehicula vulputate, magna magna iaculis ante, eget sodales est metus vel nisi.\nSed non quam a dolor aliquam accumsan eu id augue.  Pellentesque hendrerit nisl at nulla porta vel vestibulum neque sodales.  Maecenas malesuada leo vitae est varius viverra ultrices massa lobortis.  Duis ac porttitor est.  Maecenas eu libero nibh, et tempor nisl.\nPraesent fringilla augue id risus euismod commodo eu at massa.  Nullam tortor arcu, facilisis in sodales at, consectetur vel dolor.  Quisque non mauris bibendum dolor rhoncus vehicula ac vel mi.  Suspendisse eu quam a orci blandit volutpat a vel risus.  Proin ac dui eu diam dapibus bibendum.  Proin sagittis facilisis sagittis.  In hac habitasse platea dictumst.  Maecenas eu ante vitae massa dictum tincidunt.  Suspendisse sit amet porttitor diam.",
	 attributes);
    
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
    ef_text_flow_draw(label, drawable);
    glPopMatrix();

    glPushMatrix();
    glTranslatef(0.0f, 440.0f, 0.0f);
    ef_text_flow_draw(paragraphs, drawable);
    glPopMatrix();

    ef_drawable_swap_buffers(drawable);
}

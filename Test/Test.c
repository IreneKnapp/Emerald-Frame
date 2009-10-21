#include "emerald-frame.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>


void load_sounds();
void init_al();
void load_textures(EF_Drawable drawable);
void init_gl(EF_Drawable drawable);
void draw(EF_Drawable drawable, void *context);
void frame(EF_Timer timer, void *context);
void key_down(EF_Drawable drawable, EF_Event event, void *context);
void key_up(EF_Drawable drawable, EF_Event event, void *context);
void mouse_down(EF_Drawable drawable, EF_Event event, void *context);
void mouse_up(EF_Drawable drawable, EF_Event event, void *context);
void mouse_move(EF_Drawable drawable, EF_Event event, void *context);
void mouse_enter(EF_Drawable drawable, EF_Event event, void *context);
void mouse_exit(EF_Drawable drawable, EF_Event event, void *context);

static uint64_t startup_time;
static GLuint texture_ids[3];
static int last_played_blip_at_frame;
static ALuint audio_buffer_ids[2];
static ALuint audio_source_ids[2];


int main(int argc, char **argv) {
    ef_init((utf8 *) "Test Application");
    
    ALCdevice *device = alcOpenDevice(NULL);
    ALCcontext *context = alcCreateContext(device, NULL);
    alcMakeContextCurrent(context);
    
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
    ef_input_set_key_down_callback(drawable, key_down, NULL);
    ef_input_set_key_up_callback(drawable, key_up, NULL);
    ef_input_set_mouse_down_callback(drawable, mouse_down, NULL);
    ef_input_set_mouse_up_callback(drawable, mouse_up, NULL);
    ef_input_set_mouse_move_callback(drawable, mouse_move, NULL);
    ef_input_set_mouse_enter_callback(drawable, mouse_enter, NULL);
    ef_input_set_mouse_exit_callback(drawable, mouse_exit, NULL);
    
    load_sounds();
    init_al();
    
    load_textures(drawable);
    init_gl(drawable);
    
    startup_time = ef_time_unix_epoch();
    
    last_played_blip_at_frame = -1;
    
    ef_time_new_repeating_timer(20, frame, (void *) drawable);
    
    ef_main();
}


void load_sounds() {
    alGenBuffers(2, audio_buffer_ids);
    
    utf8 *resource_path = ef_configuration_resource_directory();

    utf8 *test_sound_path;
    
    test_sound_path = malloc((strlen((char *) resource_path) + 128) * sizeof(utf8));
    strcpy((char *) test_sound_path, (char *) resource_path);
    strcat((char *) test_sound_path, "wing.mp3");
    ef_audio_load_sound_file(test_sound_path, audio_buffer_ids[0]);
    free(test_sound_path);
    
    test_sound_path = malloc((strlen((char *) resource_path) + 128) * sizeof(utf8));
    strcpy((char *) test_sound_path, (char *) resource_path);
    strcat((char *) test_sound_path, "blip.wav");
    ef_audio_load_sound_file(test_sound_path, audio_buffer_ids[1]);
    free(test_sound_path);
}


void init_al() {
    alGenSources(2, audio_source_ids);
    
    alSourceQueueBuffers(audio_source_ids[0], 1, &audio_buffer_ids[0]);
    alSourcei(audio_source_ids[0], AL_LOOPING, AL_TRUE);
    alSourcePlay(audio_source_ids[0]);
    
    alSourceQueueBuffers(audio_source_ids[1], 1, &audio_buffer_ids[1]);
}


void load_textures(EF_Drawable drawable) {
    ef_drawable_make_current(drawable);

    glEnable(GL_TEXTURE_2D);
    
    glGenTextures(3, texture_ids);
    
    utf8 *resource_path = ef_configuration_resource_directory();
    
    utf8 *test_texture_path;
    
    test_texture_path = malloc((strlen((char *) resource_path) + 128) * sizeof(utf8));
    strcpy((char *) test_texture_path, (char *) resource_path);
    strcat((char *) test_texture_path, "test-color.png");
    ef_video_load_texture_file(test_texture_path, texture_ids[0], True);
    free(test_texture_path);
    
    test_texture_path = malloc((strlen((char *) resource_path) + 128) * sizeof(utf8));
    strcpy((char *) test_texture_path, (char *) resource_path);
    strcat((char *) test_texture_path, "test-transparent.png");
    ef_video_load_texture_file(test_texture_path, texture_ids[1], True);
    free(test_texture_path);
    
    test_texture_path = malloc((strlen((char *) resource_path) + 128) * sizeof(utf8));
    strcpy((char *) test_texture_path, (char *) resource_path);
    strcat((char *) test_texture_path, "test-partial-alpha.png");
    ef_video_load_texture_file(test_texture_path, texture_ids[2], True);
    free(test_texture_path);
}


void init_gl(EF_Drawable drawable) {
    ef_drawable_make_current(drawable);
    
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrtho(0, 640, 0, 480, -300, 300);
    
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();

    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
}


void draw(EF_Drawable drawable, void *context) {
    uint64_t current_time = ef_time_unix_epoch();
    uint64_t elapsed_frames = (current_time - startup_time) / 20;
    
    glClearColor(0.0f, 0.0f, 0.5f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);

    glBindTexture(GL_TEXTURE_2D, 0);
    glDisable(GL_BLEND);
    
    glPushMatrix();
    
    glTranslatef(320.0f, 240.0f, 0.0f);
    glRotatef(elapsed_frames * (90.0f / 100.0f), 0.0f, 0.0f, 1.0f);

    glColor4f(1.0f, 1.0f, 0.0f, 1.0f);
    glBegin(GL_TRIANGLES);
    glVertex2s(0, 120);
    glVertex2s(60, -60);
    glVertex2s(-60, -60);
    glEnd();

    glPopMatrix();
    
    glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
    glEnable(GL_BLEND);
    
    glBindTexture(GL_TEXTURE_2D, texture_ids[0]);
    glBegin(GL_QUADS);
    glTexCoord2f(0.0f, 1.0f);
    glVertex2s(0, 0);
    glTexCoord2f(1.0f, 1.0f);
    glVertex2s(128, 0);
    glTexCoord2f(1.0f, 0.0f);
    glVertex2s(128, 128);
    glTexCoord2f(0.0f, 0.0f);
    glVertex2s(0, 128);
    glEnd();
    
    glBindTexture(GL_TEXTURE_2D, texture_ids[1]);
    glBegin(GL_QUADS);
    glTexCoord2f(0.0f, 1.0f);
    glVertex2s(128, 0);
    glTexCoord2f(1.0f, 1.0f);
    glVertex2s(256, 0);
    glTexCoord2f(1.0f, 0.0f);
    glVertex2s(256, 128);
    glTexCoord2f(0.0f, 0.0f);
    glVertex2s(128, 128);
    glEnd();

    glBindTexture(GL_TEXTURE_2D, texture_ids[2]);
    glBegin(GL_QUADS);
    glTexCoord2f(0.0f, 1.0f);
    glVertex2s(256, 0);
    glTexCoord2f(1.0f, 1.0f);
    glVertex2s(384, 0);
    glTexCoord2f(1.0f, 0.0f);
    glVertex2s(384, 128);
    glTexCoord2f(0.0f, 0.0f);
    glVertex2s(256, 128);
    glEnd();
        
    ef_drawable_swap_buffers(drawable);
}


void frame(EF_Timer timer, void *context) {
    EF_Drawable drawable = (EF_Drawable) context;
    ef_drawable_redraw(drawable);

    uint64_t current_time = ef_time_unix_epoch();
    uint64_t elapsed_frames = (current_time - startup_time) / 20;
    
    int next_blip_frame;
    if(last_played_blip_at_frame == -1)
	next_blip_frame = 0;
    else
	next_blip_frame = last_played_blip_at_frame + 100;
    
    if(elapsed_frames >= next_blip_frame) {
	alSourcePlay(audio_source_ids[1]);
	last_played_blip_at_frame = next_blip_frame;
    }
}


void key_down(EF_Drawable drawable, EF_Event event, void *context) {
    printf("%lli Key down; keycode %li; key name '%s'; string '%s'.\n",
	   ef_event_timestamp(event),
	   (long int) ef_event_keycode(event),
	   (char *) ef_input_key_name(ef_event_keycode(event)),
	   ef_event_string(event));
}


void key_up(EF_Drawable drawable, EF_Event event, void *context) {
    /*
    printf("%lli Key up; keycode %li; string '%s'.\n",
	   ef_event_timestamp(event),
	   (long int) ef_event_keycode(event),
	   ef_event_string(event));
    */
}


void mouse_down(EF_Drawable drawable, EF_Event event, void *context) {
    printf("%lli Mouse down; button %i; click count %i; location (%i, %i).\n",
	   ef_event_timestamp(event),
	   ef_event_button_number(event),
	   ef_event_click_count(event),
	   ef_event_mouse_x(event),
	   ef_event_mouse_y(event));
}


void mouse_up(EF_Drawable drawable, EF_Event event, void *context) {
    /*
    printf("%lli Mouse up; button %i; click count %i.\n",
	   ef_event_timestamp(event),
	   ef_event_button_number(event),
	   ef_event_click_count(event));
    */
}


void mouse_move(EF_Drawable drawable, EF_Event event, void *context) {
    /*
    printf("%lli Mouse move; location (%i, %i).\n",
	   ef_event_timestamp(event),
	   ef_event_mouse_x(event),
	   ef_event_mouse_y(event));
    */
}


void mouse_enter(EF_Drawable drawable, EF_Event event, void *context) {
    //printf("%lli Mouse enter.\n", ef_event_timestamp(event));
}


void mouse_exit(EF_Drawable drawable, EF_Event event, void *context) {
    //printf("%lli Mouse exit.\n", ef_event_timestamp(event));
}

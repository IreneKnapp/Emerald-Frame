#ifndef EMERALD_FRAME_H
#define EMERALD_FRAME_H

#include <stdint.h>
#include <stdlib.h>

#ifdef __APPLE__

#include <OpenAL/al.h>
#include <OpenAL/alc.h>

#include <OpenGL/OpenGL.h>
#include <OpenGL/glu.h>

#else
#ifdef __WIN32__

#include <al.h>
#include <alc.h>

#include <GL/gl.h>
#include <GL/glu.h>
#include <GL/glext.h>

#else

#include <AL/al.h>
#include <AL/alc.h>
#include <AL/alu.h>

#include <GL/gl.h>
#include <GL/glu.h>

#endif
#endif

typedef int EF_Error;
typedef void *EF_Drawable;
typedef void *EF_Display;
typedef void *EF_Timer;
typedef void *EF_Event;
typedef void *EF_Font;
typedef void *EF_Attributed_String;
typedef void *EF_Text_Attributes;
typedef void *EF_Paragraph_Style;
typedef void *EF_Text_Flow;
typedef uint32_t EF_Keycode;
typedef uint32_t EF_Modifiers;
typedef uint32_t EF_Dead_Key_State;
typedef uint32_t EF_Font_Weight;
typedef uint32_t EF_Font_Traits;
typedef uint32_t EF_Glyph;
typedef uint32_t EF_Underline_Style;
typedef uint32_t EF_Strikethrough_Style;
typedef uint32_t EF_Ligature_Style;
typedef uint32_t EF_Outline_Style;
typedef uint32_t EF_Paragraph_Alignment;
typedef uint8_t utf8;
typedef uint16_t utf16;
typedef uint32_t utf32;

#ifndef NULL
#define NULL ((void *) 0)
#endif

#define False 0
#define True 1

#define EF_ERROR_PARAM 1
#define EF_ERROR_FILE 2
#define EF_ERROR_IMAGE_DATA 3
#define EF_ERROR_SOUND_DATA 4
#define EF_ERROR_INTERNAL 100

#define EF_MODIFIER_CAPS_LOCK 1
#define EF_MODIFIER_SHIFT 2
#define EF_MODIFIER_CONTROL 4
#define EF_MODIFIER_ALT 8
#define EF_MODIFIER_COMMAND 16

#define EF_FONT_WEIGHT_ULTRALIGHT 1
#define EF_FONT_WEIGHT_THIN 2
#define EF_FONT_WEIGHT_LIGHT 3
#define EF_FONT_WEIGHT_BOOK 4
#define EF_FONT_WEIGHT_REGULAR 5
#define EF_FONT_WEIGHT_MEDIUM 6
#define EF_FONT_WEIGHT_DEMIBOLD 7
#define EF_FONT_WEIGHT_SEMIBOLD 8
#define EF_FONT_WEIGHT_BOLD 9
#define EF_FONT_WEIGHT_EXTRABOLD 10
#define EF_FONT_WEIGHT_HEAVY 11
#define EF_FONT_WEIGHT_BLACK 12
#define EF_FONT_WEIGHT_ULTRABLACK 13
#define EF_FONT_WEIGHT_EXTRABLACK 14
#define EF_FONT_WEIGHT_W1 2
#define EF_FONT_WEIGHT_W2 3
#define EF_FONT_WEIGHT_W3 4
#define EF_FONT_WEIGHT_W4 5
#define EF_FONT_WEIGHT_W5 6
#define EF_FONT_WEIGHT_W6 8
#define EF_FONT_WEIGHT_W7 9
#define EF_FONT_WEIGHT_W8 10
#define EF_FONT_WEIGHT_W9 12

#define EF_FONT_TRAIT_ITALIC 0x0001
#define EF_FONT_TRAIT_BOLD 0x0002
#define EF_FONT_TRAIT_EXPANDED 0x0010
#define EF_FONT_TRAIT_CONDENSED 0x0020
#define EF_FONT_TRAIT_FIXED_PITCH 0x0040

#define EF_UNDERLINE_STYLE_NONE 0
#define EF_UNDERLINE_STYLE_SINGLE 1
#define EF_UNDERLINE_STYLE_DOUBLE 2
#define EF_UNDERLINE_STYLE_THICK 3

#define EF_STRIKETHROUGH_STYLE_NONE 0
#define EF_STRIKETHROUGH_STYLE_SINGLE 1
#define EF_STRIKETHROUGH_STYLE_DOUBLE 2
#define EF_STRIKETHROUGH_STYLE_THICK 3

#define EF_LIGATURE_STYLE_NONE 0
#define EF_LIGATURE_STYLE_STANDARD 1
#define EF_LIGATURE_STYLE_ALL 2

#define EF_OUTLINE_STYLE_FILL_ONLY 0
#define EF_OUTLINE_STYLE_STROKE_ONLY 1
#define EF_OUTLINE_STYLE_STROKE_AND_FILL 2

#define EF_PARAGRAPH_ALIGNMENT_LEFT 0
#define EF_PARAGRAPH_ALIGNMENT_CENTER 1
#define EF_PARAGRAPH_ALIGNMENT_RIGHT 2
#define EF_PARAGRAPH_ALIGNMENT_JUSTIFIED 3

// General
EF_Error ef_init(utf8 *application_name);
utf8 *ef_version_string();
utf8 *ef_error_string(EF_Error error);
void ef_main();

// Video
EF_Drawable ef_video_new_drawable(int width,
				  int height,
				  int full_screen,
				  EF_Display display);
void ef_drawable_delete(EF_Drawable drawable);
void ef_drawable_set_title(EF_Drawable drawable, utf8 *title);
void ef_drawable_set_draw_callback(EF_Drawable drawable,
				   void (*callback)(EF_Drawable drawable,
						    void *context),
				   void *context);
void ef_drawable_redraw(EF_Drawable drawable);
void ef_drawable_make_current(EF_Drawable drawable);
void ef_drawable_swap_buffers(EF_Drawable drawable);
void ef_video_set_double_buffer(int double_buffer);
void ef_video_set_stereo(int stereo);
void ef_video_set_aux_buffers(int aux_buffers);
void ef_video_set_color_size(int color_size);
void ef_video_set_alpha_size(int alpha_size);
void ef_video_set_depth_size(int depth_size);
void ef_video_set_stencil_size(int stencil_size);
void ef_video_set_accumulation_size(int accumulation_size);
void ef_video_set_samples(int samples);
void ef_video_set_aux_depth_stencil(int aux_depth_stencil);
void ef_video_set_color_float(int color_float);
void ef_video_set_multisample(int multisample);
void ef_video_set_supersample(int supersample);
void ef_video_set_sample_alpha(int sample_alpha);
EF_Display ef_video_current_display();
EF_Display ef_video_next_display(EF_Display previous);
int ef_display_depth(EF_Display display);
int ef_display_width(EF_Display display);
int ef_display_height(EF_Display display);
EF_Error ef_video_load_texture_file(utf8 *filename, GLuint id, int build_mipmaps);
EF_Error ef_video_load_texture_memory(uint8_t *data, size_t size, GLuint id, int build_mipmaps);

// Audio
EF_Error ef_audio_load_sound_file(utf8 *filename, ALuint id);
EF_Error ef_audio_load_sound_memory(uint8_t *data, size_t size, ALuint id);

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
void ef_input_set_key_down_callback(EF_Drawable drawable,
				    void (*callback)(EF_Drawable drawable,
						     EF_Event event,
						     void *context),
				    void *context);
void ef_input_set_key_up_callback(EF_Drawable drawable,
				  void (*callback)(EF_Drawable drawable,
						   EF_Event event,
						   void *context),
				  void *context);
void ef_input_set_mouse_down_callback(EF_Drawable drawable,
				      void (*callback)(EF_Drawable drawable,
						       EF_Event event,
						       void *context),
				      void *context);
void ef_input_set_mouse_up_callback(EF_Drawable drawable,
				    void (*callback)(EF_Drawable drawable,
						     EF_Event event,
						     void *context),
				    void *context);
void ef_input_set_mouse_move_callback(EF_Drawable drawable,
				      void (*callback)(EF_Drawable drawable,
						       EF_Event event,
						       void *context),
				      void *context);
void ef_input_set_mouse_enter_callback(EF_Drawable drawable,
				       void (*callback)(EF_Drawable drawable,
							EF_Event event,
							void *context),
				       void *context);
void ef_input_set_mouse_exit_callback(EF_Drawable drawable,
				      void (*callback)(EF_Drawable drawable,
						       EF_Event event,
						       void *context),
				      void *context);
uint64_t ef_event_timestamp(EF_Event event);
EF_Modifiers ef_event_modifiers(EF_Event event);
EF_Keycode ef_event_keycode(EF_Event event);
utf8 *ef_event_string(EF_Event event);
int ef_event_button_number(EF_Event event);
int ef_event_click_count(EF_Event event);
utf8 *ef_input_key_name(EF_Keycode keycode);
EF_Keycode ef_input_keycode_by_name(utf8 *name);
utf8 *ef_input_keycode_string(EF_Keycode keycode,
			      EF_Modifiers modifiers,
			      EF_Dead_Key_State *dead_key_state);
int32_t ef_event_mouse_x(EF_Event event);
int32_t ef_event_mouse_y(EF_Event event);

// Text - Fonts
void ef_text_compute_available_fonts();
void ef_text_compute_available_font_families();
void ef_text_compute_available_fonts_with_traits(EF_Font_Traits traits,
						 EF_Font_Traits negative_traits);
void ef_text_compute_available_members_of_font_family(utf8 *family_name);
int32_t ef_text_computed_count();
utf8 *ef_text_computed_name_n(int32_t which);
utf8 *ef_text_computed_style_name_n(int32_t which);
EF_Font_Weight ef_text_computed_weight_n(int32_t which);
EF_Font_Traits ef_text_computed_traits_n(int32_t which);
void ef_text_discard_computed();
EF_Font ef_text_specific_font(utf8 *family_name,
			      EF_Font_Traits traits,
			      EF_Font_Weight weight,
			      double size);
void ef_font_delete(EF_Font font);
utf8 *ef_font_name(EF_Font font);
utf8 *ef_font_family_name(EF_Font font);
utf8 *ef_font_display_name(EF_Font font);
EF_Font_Traits ef_font_traits(EF_Font font);
int32_t ef_font_weight(EF_Font font);
EF_Font ef_font_convert_to_face(EF_Font font, utf8 *face_name);
EF_Font ef_font_convert_to_family(EF_Font font, utf8 *family_name);
EF_Font ef_font_convert_to_have_traits(EF_Font font, EF_Font_Traits traits);
EF_Font ef_font_convert_to_not_have_traits(EF_Font font, EF_Font_Traits traits);
EF_Font ef_font_convert_to_size(EF_Font font, double size);
EF_Font ef_font_convert_to_lighter_weight(EF_Font font);
EF_Font ef_font_convert_to_heavier_weight(EF_Font font);
double ef_font_horizontal_advancement_for_glyph(EF_Font font, EF_Glyph glyph);
double ef_font_vertical_advancement_for_glyph(EF_Font font, EF_Glyph glyph);
double ef_font_ascender(EF_Font font);
double ef_font_descender(EF_Font font);
double ef_font_x_height(EF_Font font);
double ef_font_cap_height(EF_Font font);
double ef_font_italic_angle(EF_Font font);
double ef_font_leading(EF_Font font);
double ef_font_maximum_horizontal_advancement(EF_Font font);
double ef_font_maximum_vertical_advancement(EF_Font font);
double ef_font_underline_position(EF_Font font);
double ef_font_underline_thickness(EF_Font font);
void ef_font_bounding_rectangle(EF_Font font,
				double *left,
				double *top,
				double *width,
				double *height);
void ef_font_glyph_bounding_rectangle(EF_Font font,
				      EF_Glyph glyph,
				      double *left,
				      double *top,
				      double *width,
				      double *height);

// Text - Attributed Strings
EF_Attributed_String ef_text_new_attributed_string();
EF_Attributed_String ef_text_new_attributed_string_with_text(utf8 *text);
EF_Attributed_String
  ef_text_new_attributed_string_with_text_and_attributes(utf8 *text,
							 EF_Text_Attributes attributes);
void ef_attributed_string_delete(EF_Attributed_String attributed_string);
utf8 *ef_attributed_string_text(EF_Attributed_String attributed_string);
int32_t ef_attributed_string_length(EF_Attributed_String attributed_string);
EF_Text_Attributes
  ef_attributed_string_attributes_at_index(EF_Attributed_String attributed_string,
					   int32_t *effective_start,
					   int32_t *effective_end);
void ef_attributed_string_enumerate_attributes(EF_Attributed_String attributed_string,
					       int (*callback)(EF_Text_Attributes
							         text_attributes,
							       int32_t start,
							       int32_t end));
void ef_attributed_string_replace_text(EF_Attributed_String attributed_string,
				       utf8 *text,
				       int32_t start,
				       int32_t end);
void ef_attributed_string_delete_text(EF_Attributed_String attributed_string,
				      int32_t start,
				      int32_t end);
void ef_attributed_string_set_attributes(EF_Attributed_String attributed_string,
					 EF_Text_Attributes ef_text_attributes,
					 int32_t start,
					 int32_t end);
void ef_attributed_string_draw_at_point(EF_Attributed_String attributed_string,
					EF_Drawable drawable,
					double x,
					double y);
void ef_attributed_string_draw_in_rectangle(EF_Attributed_String attributed_string,
					    EF_Drawable drawable,
					    double left,
					    double top,
					    double width,
					    double height);
double ef_attributed_string_width(EF_Attributed_String attributed_string);
double ef_attributed_string_height(EF_Attributed_String attributed_string);
EF_Text_Attributes ef_text_new_attributes();
void ef_text_attributes_delete(EF_Text_Attributes attributes);
EF_Font ef_text_attributes_font(EF_Text_Attributes attributes);
int ef_text_attributes_paragraph_style_is_default(EF_Text_Attributes attributes);
EF_Paragraph_Style ef_text_attributes_paragraph_style(EF_Text_Attributes attributes);
void ef_text_attributes_foreground_color(EF_Text_Attributes attributes,
					 double *red,
					 double *green,
					 double *blue,
					 double *alpha);
void ef_text_attributes_background_color(EF_Text_Attributes attributes,
					 double *red,
					 double *green,
					 double *blue,
					 double *alpha);
EF_Underline_Style ef_text_attributes_underline_style(EF_Text_Attributes attributes);
int ef_text_attributes_underline_is_colored(EF_Text_Attributes attributes);
void ef_text_attributes_underline_color(EF_Text_Attributes attributes,
					double *red,
					double *green,
					double *blue,
					double *alpha);
EF_Strikethrough_Style
  ef_text_attributes_strikethrough_style(EF_Text_Attributes attributes);
int ef_text_attributes_strikethrough_is_colored(EF_Text_Attributes attributes);
void ef_text_attributes_strikethrough_color(EF_Text_Attributes attributes,
					    double *red,
					    double *green,
					    double *blue,
					    double *alpha);
int ef_text_attributes_superscript(EF_Text_Attributes attributes);
EF_Ligature_Style ef_text_attributes_ligature_style(EF_Text_Attributes attributes);
double ef_text_attributes_baseline_offset(EF_Text_Attributes attributes);
int ef_text_attributes_kerning_is_default(EF_Text_Attributes attributes);
double ef_text_attributes_kerning(EF_Text_Attributes attributes);
EF_Outline_Style ef_text_attributes_outline_style(EF_Text_Attributes attributes);
double ef_text_attributes_stroke_width(EF_Text_Attributes attributes);
double ef_text_attributes_obliqueness(EF_Text_Attributes attributes);
double ef_text_attributes_expansion(EF_Text_Attributes attributes);
void ef_text_attributes_set_font(EF_Text_Attributes attributes, EF_Font font);
void ef_text_attributes_set_paragraph_style_default(EF_Text_Attributes attributes);
void ef_text_attributes_set_paragraph_style(EF_Text_Attributes attributes,
					    EF_Paragraph_Style paragraph_style);
void ef_text_attributes_set_foreground_color(EF_Text_Attributes attributes,
					     double red,
					     double green,
					     double blue,
					     double alpha);
void ef_text_attributes_set_background_color(EF_Text_Attributes attributes,
					     double red,
					     double green,
					     double blue,
					     double alpha);
void ef_text_attributes_set_underline_style(EF_Text_Attributes attributes,
					    EF_Underline_Style underline_style);
void ef_text_attributes_set_underline_uncolored(EF_Text_Attributes attributes);
void ef_text_attributes_set_underline_color(EF_Text_Attributes attributes,
					    double red,
					    double green,
					    double blue,
					    double alpha);
void
  ef_text_attributes_set_strikethrough_style(EF_Text_Attributes attributes,
					     EF_Strikethrough_Style strikethrough_style);
void ef_text_attributes_set_strikethrough_uncolored(EF_Text_Attributes attributes);
void ef_text_attributes_set_strikethrough_color(EF_Text_Attributes attributes,
						double red,
						double green,
						double blue,
						double alpha);
void ef_text_attributes_set_superscript(EF_Text_Attributes attributes,
					int superscript);
void ef_text_attributes_set_ligature_style(EF_Text_Attributes attributes,
					   EF_Ligature_Style ligature_style);
void ef_text_attributes_set_baseline_offset(EF_Text_Attributes attributes,
					    double baseline_offset);
void ef_text_attributes_set_kerning_default(EF_Text_Attributes attributes);
void ef_text_attributes_set_kerning(EF_Text_Attributes attributes,
				    double kerning);
void ef_text_attributes_set_outline_style(EF_Text_Attributes attributes,
					  EF_Outline_Style outline_style);
void ef_text_attributes_set_stroke_width(EF_Text_Attributes attributes,
				         double stroke_width);
void ef_text_attributes_set_obliqueness(EF_Text_Attributes attributes,
					double obliqueness);
void ef_text_attributes_set_expansion(EF_Text_Attributes attributes,
				      double expansion);
EF_Paragraph_Style ef_text_new_paragraph_style();
void ef_paragraph_style_delete(EF_Paragraph_Style paragraph_style);
EF_Paragraph_Alignment ef_paragraph_style_alignment(EF_Paragraph_Style paragraph_style);
double ef_paragraph_style_first_line_head_indent(EF_Paragraph_Style paragraph_style);
double ef_paragraph_style_head_indent(EF_Paragraph_Style paragraph_style);
double ef_paragraph_style_tail_indent(EF_Paragraph_Style paragraph_style);
double ef_paragraph_style_line_height_multiple(EF_Paragraph_Style paragraph_style);
double ef_paragraph_style_minimum_line_height(EF_Paragraph_Style paragraph_style);
int ef_paragraph_style_has_maximum_line_height(EF_Paragraph_Style paragraph_style);
double ef_paragraph_style_maximum_line_height(EF_Paragraph_Style paragraph_style);
double ef_paragraph_style_line_spacing(EF_Paragraph_Style paragraph_style);
double ef_paragraph_style_paragraph_spacing(EF_Paragraph_Style paragraph_style);
double ef_paragraph_style_paragraph_spacing_before(EF_Paragraph_Style paragraph_style);
void ef_paragraph_style_set_alignment(EF_Paragraph_Style paragraph_style,
				      EF_Paragraph_Alignment paragraph_alignment);
void ef_paragraph_style_set_first_line_head_indent(EF_Paragraph_Style paragraph_style,
						   double first_line_head_indent);
void ef_paragraph_style_set_head_indent(EF_Paragraph_Style paragraph_style,
					double head_indent);
void ef_paragraph_style_set_tail_indent(EF_Paragraph_Style paragraph_style,
					double tail_indent);
void ef_paragraph_style_set_line_height_multiple(EF_Paragraph_Style paragraph_style,
						 double line_height_multiple);
void ef_paragraph_style_set_minimum_line_height(EF_Paragraph_Style paragraph_style,
						double minimum_line_height);
void ef_paragraph_style_set_no_maximum_line_height(EF_Paragraph_Style paragraph_style);
void ef_paragraph_style_set_maximum_line_height(EF_Paragraph_Style paragraph_style,
						double maximum_line_height);
void ef_paragraph_style_set_line_spacing(EF_Paragraph_Style paragraph_style,
					 double line_spacing);
void ef_paragraph_style_set_paragraph_spacing(EF_Paragraph_Style paragraph_style,
					      double paragraph_spacing);
void ef_paragraph_style_set_paragraph_spacing_before(EF_Paragraph_Style paragraph_style,
						     double paragraph_spacing_before);

// Text - Flows
void ef_text_new_text_flow(EF_Drawable drawable);
void ef_text_flow_delete(EF_Text_Flow text_flow);
EF_Attributed_String ef_text_flow_attributed_string(EF_Text_Flow text_flow);
void ef_text_flow_set_attributed_string(EF_Text_Flow text_flow,
					EF_Attributed_String attributed_string);
double ef_text_flow_left(EF_Text_Flow text_flow);
double ef_text_flow_top(EF_Text_Flow text_flow);
void ef_text_flow_set_origin(EF_Text_Flow text_flow, double left, double top);
double ef_text_flow_width(EF_Text_Flow text_flow);
double ef_text_flow_height(EF_Text_Flow text_flow);
void ef_text_flow_set_size(EF_Text_Flow text_flow, double width, double height);
void ef_text_flow_draw(EF_Text_Flow text_flow);
void ef_text_flow_draw_background(EF_Text_Flow text_flow);
void ef_text_flow_draw_glyphs(EF_Text_Flow text_flow);
void ef_text_flow_draw_decorations(EF_Text_Flow text_flow);

// Configuration
utf8 *ef_configuration_resource_directory();

// Pasteboard

#endif

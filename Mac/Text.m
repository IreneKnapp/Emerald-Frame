//
//  Text.m
//  Emerald Frame
//
//  Created by Dan Knapp on 2/11/10.
//  Copyright 2010 Dan Knapp. All rights reserved.
//


void ef_text_compute_available_fonts() {
}


void ef_text_compute_available_font_families() {
}


void ef_text_compute_available_fonts_with_traits(EF_Font_Traits) {
}


void ef_text_compute_available_members_of_font_family(utf8 *family_name) {
}


int32_t ef_text_computed_count() {
}


utf8 *ef_text_computed_name_n(int32_t which) {
}


utf8 *ef_text_computed_style_name_n(int32_t which) {
}


EF_Font_Weight ef_text_computed_weight_n(int32_t which) {
}


EF_Font_Traits ef_text_computed_traits_n(int32_t which) {
}


void ef_text_discard_computed() {
}


EF_Font ef_text_specific_font(utf8 *family_name,
			      EF_Font_Traits traits,
			      EF_Font_Weight weight,
			      double size)
{
}


void ef_font_delete(EF_Font font) {
}


EF_Font_Traits ef_font_traits(EF_Font font) {
}


int32_t ef_font_weight(EF_Font font) {
}


int ef_font_is_fixed_pitch(EF_Font font) {
}


EF_Font ef_font_convert_to_face(EF_Font font, utf8 *face_name) {
}


EF_Font ef_font_convert_to_family(EF_Font font, utf8 *family_name) {
}


EF_Font ef_font_convert_to_have_traits(EF_Font font, EF_Font_Traits traits) {
}


EF_Font ef_font_convert_to_not_have_traits(EF_Font font, EF_Font_Traits traits) {
}


EF_Font ef_font_convert_to_size(EF_Font font, double size) {
}


EF_Font ef_font_convert_to_weight(EF_Font font, EF_Font_Weight weight) {
}


double ef_font_advancement_for_glyph(EF_Font font, EF_Glyph glyph) {
}


double ef_font_ascender(EF_Font font) {
}


double ef_font_descender(EF_Font font) {
}


double ef_font_x_height(EF_Font font) {
}


double ef_font_cap_height(EF_Font font) {
}


double ef_font_italic_angle(EF_Font font) {
}


double ef_font_leading(EF_Font font) {
}


double ef_font_maximum_advancement(EF_Font font) {
}


double ef_font_underline_position(EF_Font font) {
}


double ef_font_underline_thickness(EF_Font font) {
}


double ef_font_bounding_rectangle_top(EF_Font font) {
}


double ef_font_bounding_rectangle_left(EF_Font font) {
}


double ef_font_bounding_rectangle_bottom(EF_Font font) {
}


double ef_font_bounding_rectangle_right(EF_Font font) {
}


double ef_font_glyph_bounding_rectangle_top(EF_Font font, EF_Glyph glyph) {
}


double ef_font_glyph_bounding_rectangle_left(EF_Font font, EF_Glyph glyph) {
}


double ef_font_glyph_bounding_rectangle_bottom(EF_Font font, EF_Glyph glyph) {
}


double ef_font_glyph_bounding_rectangle_right(EF_Font font, EF_Glyph glyph) {
}


EF_Attributed_String ef_text_new_attributed_string() {
}


EF_Attributed_String ef_text_new_attributed_string_with_text(utf8 *text) {
}


EF_Attributed_String
  ef_text_new_attributed_string_with_text_and_attributes(utf8 *text,
							 EF_Text_Attributes attributes)
{
}


void ef_attributed_string_delete(EF_Attributed_String attributed_string) {
}


utf8 *ef_attributed_string_text(EF_Attributed_String attributed_string) {
}


int32_t ef_attributed_string_length(EF_Attributed_String attributed_string) {
}


EF_Text_Attributes
  ef_attributed_string_attributes_at_index(EF_Attributed_String attributed_string,
					   int32_t *effective_start,
					   int32_t *effective_end)
{
}


void ef_attributed_string_enumerate_attributes(EF_Attributed_String attributed_string,
					       int (*callback)(EF_Text_Attributes
							         text_attributes,
							       int32_t start,
							       int32_t end))
{
}


void ef_attributed_string_replace_text(EF_Attributed_String attributed_string,
				       utf8 *text,
				       int32_t start,
				       int32_t end)
{
}


void ef_attributed_string_delete_text(EF_Attributed_String attributed_string,
				      int32_t start,
				      int32_t end)
{
}


void ef_attributed_string_set_attributes(EF_Attributed_String attributed_string,
					 EF_Text_Attributes ef_text_attributes,
					 int32_t start,
					 int32_t end)
{
}


void ef_attributed_string_draw_at_point(EF_Attributed_String attributed_string,
					double x,
					double y)
{
}


void ef_attributed_string_draw_in_rectangle(EF_Attributed_String attributed_string,
					    double left,
					    double top,
					    double width,
					    double height)
{
}


double ef_attributed_string_width(EF_Attributed_String attributed_string) {
}


double ef_attributed_string_height(EF_Attributed_String attributed_string) {
}


EF_Text_Attributes ef_text_new_attributes() {
}


void ef_text_attributes_delete(EF_Text_Attributes attributes) {
}


EF_Font ef_text_attributes_font(EF_Text_Attributes attributes) {
}


int ef_text_attributes_paragraph_style_is_default(EF_Text_Attributes attributes) {
}


EF_Paragraph_Style ef_text_attributes_paragraph_style(EF_Text_Attributes attributes) {
}


void ef_text_attributes_foreground_color(EF_Text_Attributes attributes,
					 double *red,
					 double *green,
					 double *blue,
					 double *alpha)
{
}


void ef_text_attributes_background_color(EF_Text_Attributes attributes,
					 double *red,
					 double *green,
					 double *blue,
					 double *alpha)
{
}


EF_Underline_Style ef_text_attributes_underline_style(EF_Text_Attributes attributes) {
}


int ef_text_attributes_underline_colored(EF_Text_Attributes attributes) {
}


void ef_text_attributes_underline_color(EF_Text_Attributes attributes,
					double *red,
					double *green,
					double *blue,
					double *alpha)
{
}


EF_Strikethrough_Style
  ef_text_attributes_strikethrough_style(EF_Text_Attributes attributes)
{
}


int ef_text_attributes_strikethrough_colored(EF_Text_Attributes attributes) {
}


void ef_text_attributes_strikethrough_color(EF_Text_Attributes attributes,
					    double *red,
					    double *green,
					    double *blue,
					    double *alpha)
{
}


int ef_text_attributes_superscript(EF_Text_Attributes attributes) {
}


EF_Ligature_Style ef_text_attributes_ligature_style(EF_Text_Attributes attributes) {
}


double ef_text_attributes_baseline_offset(EF_Text_Attributes attributes) {
}


int ef_text_attributes_kerning_is_default(EF_Text_Attributes attributes) {
}


double ef_text_attributes_kerning(EF_Text_Attributes attributes) {
}


EF_Outline_Style ef_text_attributes_outline_style(EF_Text_Attributes attributes) {
}


double ef_text_attributes_stroke_width(EF_Text_Attributes attributes) {
}


double ef_text_attributes_obliqueness(EF_Text_Attributes attributes) {
}


double ef_text_attributes_expansion(EF_Text_Attributes attributes) {
}


void ef_text_attributes_set_font(EF_Text_Attributes attributes, EF_Font font) {
}


void ef_text_attributes_set_paragraph_style_default(EF_Text_Attributes attributes) {
}


void ef_text_attributes_set_paragraph_style(EF_Text_Attributes attributes,
					    EF_Paragraph_Style paragraph_style)
{
}


void ef_text_attributes_set_foreground_color(EF_Text_Attributes attributes,
					     double red,
					     double green,
					     double blue,
					     double alpha)
{
}


void ef_text_attributes_set_background_color(EF_Text_Attributes attributes,
					     double red,
					     double green,
					     double blue,
					     double alpha)
{
}


void ef_text_attributes_set_underline_style(EF_Text_Attributes attributes,
					    EF_Underline_Style underline_style)
{
}


void ef_text_attributes_set_underline_uncolored(EF_Text_Attributes attributes) {
}


void ef_text_attributes_set_underline_color(EF_Text_Attributes attributes,
					    double red,
					    double green,
					    double blue,
					    double alpha)
{
}


void
  ef_text_attributes_set_strikethrough_style(EF_Text_Attributes attributes,
					     EF_Strikethrough_Style strikethrough_style)
{
}


void ef_text_attributes_set_strikethrough_uncolored(EF_Text_Attributes attributes) {
}


void ef_text_attributes_set_strikethrough_color(EF_Text_Attributes attributes,
						double red,
						double green,
						double blue,
						double alpha)
{
}


void ef_text_attributes_set_superscript(EF_Text_Attributes attributes,
					int superscript)
{
}


void ef_text_attributes_set_ligature_style(EF_Text_Attributes attributes,
					   EF_Ligature_Style ligature_style)
{
}


void ef_text_attributes_set_baseline_offset(EF_Text_Attributes attributes,
					    double baseline_offset)
{
}


void ef_text_attributes_set_kerning_default(EF_Text_Attributes attributes) {
}


void ef_text_attributes_set_kerning(EF_Text_Attributes attributes,
				    double kerning)
{
}


void ef_text_attributes_outline_style(EF_Text_Attributes attributes,
				      EF_Outline_Style outline_style)
{
}


void ef_text_attributes_stroke_width(EF_Text_Attributes attributes,
				     double stroke_width)
{
}


void ef_text_attributes_set_obliqueness(EF_Text_Attributes attributes,
					double obliqueness)
{
}


void ef_text_attributes_set_expansion(EF_Text_Attributes attributes,
				      double expansion)
{
}


EF_Paragraph_Style ef_text_new_paragraph_style() {
}


void ef_paragraph_style_delete(EF_Paragraph_Style paragraph_style) {
}


EF_Paragraph_Alignment ef_paragraph_style_alignment(EF_Paragraph_Style paragraph_style) {
}


double ef_paragraph_style_first_line_head_indent(EF_Paragraph_Style paragraph_style) {
}


double ef_paragraph_style_head_indent(EF_Paragraph_Style paragraph_style) {
}


double ef_paragraph_style_tail_indent(EF_Paragraph_Style paragraph_style) {
}


double ef_paragraph_style_line_height_multiple(EF_Paragraph_Style paragraph_style) {
}


double ef_paragraph_style_minimum_line_height(EF_Paragraph_Style paragraph_style) {
}


int ef_paragraph_style_has_maximum_line_height(EF_Paragraph_Style paragraph_style) {
}


double ef_paragraph_style_maximum_line_height(EF_Paragraph_Style paragraph_style) {
}


double ef_paragraph_style_line_spacing(EF_Paragraph_Style paragraph_style) {
}


double ef_paragraph_style_paragraph_spacing(EF_Paragraph_Style paragraph_style) {
}


double ef_paragraph_style_paragraph_spacing_before(EF_Paragraph_Style paragraph_style) {
}


void ef_paragraph_style_set_alignment(EF_Paragraph_Style paragraph_style,
				      EF_Paragraph_Alignment paragraph_alignment)
{
}


void ef_paragraph_style_set_first_line_head_indent(EF_Paragraph_Style paragraph_style,
						   double first_line_head_indent)
{
}


void ef_paragraph_style_set_head_indent(EF_Paragraph_Style paragraph_style,
					double head_indent)
{
}


void ef_paragraph_style_set_tail_indent(EF_Paragraph_Style paragraph_style,
					double tail_indent)
{
}


void ef_paragraph_style_set_line_height_multiple(EF_Paragraph_Style paragraph_style,
						 double line_height_multiple)
{
}


void ef_paragraph_style_set_minimum_line_height(EF_Paragraph_Style paragraph_style,
						double minimum_line_height)
{
}


void ef_paragraph_style_set_no_maximum_line_height(EF_Paragraph_Style paragraph_style) {
}


void ef_paragraph_style_set_maximum_line_height(EF_Paragraph_Style paragraph_style,
						double maximum_line_height)
{
}


void ef_paragraph_style_set_line_spacing(EF_Paragraph_Style paragraph_style,
					 double line_spacing)
{
}


void ef_paragraph_style_set_paragraph_spacing(EF_Paragraph_Style paragraph_style,
					      double paragraph_spacing)
{
}


void ef_paragraph_style_set_paragraph_spacing_before(EF_Paragraph_Style paragraph_style,
						     double paragraph_spacing_before)
{
}


void ef_text_new_text_flow(EF_Drawable drawable) {
}


void ef_text_flow_delete(EF_Text_Flow text_flow) {
}


EF_Attributed_String ef_text_flow_attributed_string(EF_Text_Flow text_flow) {
}


void ef_text_flow_set_attributed_string(EF_Text_Flow text_flow,
					EF_Attributed_String attributed_string)
{
}


double ef_text_flow_left(EF_Text_Flow text_flow) {
}


double ef_text_flow_top(EF_Text_Flow text_flow) {
}


void ef_text_flow_set_origin(EF_Text_Flow text_flow, double left, double top) {
}


double ef_text_flow_width(EF_Text_Flow text_flow) {
}


double ef_text_flow_height(EF_Text_Flow text_flow) {
}


void ef_text_flow_set_size(EF_Text_Flow text_flow, double width, double height) {
}


void ef_text_flow_draw(EF_Text_Flow text_flow) {
}


void ef_text_flow_draw_background(EF_Text_Flow text_flow) {
}


void ef_text_flow_draw_glyphs(EF_Text_Flow text_flow) {
}


void ef_text_flow_draw_decorations(EF_Text_Flow text_flow) {
}

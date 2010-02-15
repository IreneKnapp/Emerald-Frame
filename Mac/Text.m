//
//  Text.m
//  Emerald Frame
//
//  Created by Dan Knapp on 2/11/10.
//  Copyright 2010 Dan Knapp. All rights reserved.
//
#import <math.h>
#import <Cocoa/Cocoa.h>

#import "Emerald-Frame.h"
#import "Unicode.h"


static id computed_font_name_buffer;

static NSBezierPath *ef_internal_transform_bezier_path(NSBezierPath *untransformedPath,
						       NSPoint (^block)(NSPoint));
static void ef_internal_tesselation_begin(GLenum type);
static void ef_internal_tesselation_end();
static void ef_internal_tesselation_vertex(void *vertexContext, void *polygonContext);


EF_Error ef_internal_text_init() {
    computed_font_name_buffer = nil;
    
    return 0;
}


void ef_text_compute_available_fonts() {
    ef_text_compute_available_fonts_with_traits(0, 0);
}


void ef_text_compute_available_font_families() {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    if(computed_font_name_buffer) {
	[computed_font_name_buffer release];
	computed_font_name_buffer = nil;
    }
    NSFontManager *fontManager = [NSFontManager sharedFontManager];
    computed_font_name_buffer = [fontManager availableFontFamilies];
    [computed_font_name_buffer retain];
    [pool drain];
}


void ef_text_compute_available_fonts_with_traits(EF_Font_Traits traits,
						 EF_Font_Traits negative_traits)
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    if(computed_font_name_buffer) {
	[computed_font_name_buffer release];
	computed_font_name_buffer = nil;
    }
    
    NSInteger cocoa_traits = 0;
    if(traits & EF_FONT_TRAIT_ITALIC)
	cocoa_traits |= NSFontItalicTrait;
    if(traits & EF_FONT_TRAIT_BOLD)
	cocoa_traits |= NSFontBoldTrait;
    if(traits & EF_FONT_TRAIT_EXPANDED)
	cocoa_traits |= NSFontExpandedTrait;
    if(traits & EF_FONT_TRAIT_CONDENSED)
	cocoa_traits |= NSFontCondensedTrait;
    if(traits & EF_FONT_TRAIT_FIXED_PITCH)
	cocoa_traits |= NSFontMonoSpaceTrait;
    
    NSFontManager *fontManager = [NSFontManager sharedFontManager];
    
    NSMutableDictionary *fontTraits = [NSMutableDictionary dictionaryWithCapacity: 1];
    [fontTraits setObject: [NSNumber numberWithInteger: cocoa_traits]
		forKey: NSFontSymbolicTrait];
    NSMutableDictionary *fontAttributes = [NSMutableDictionary dictionaryWithCapacity: 1];
    [fontAttributes setObject: fontTraits forKey: NSFontTraitsAttribute];
    NSFontDescriptor *fontDescriptor
	= [NSFontDescriptor fontDescriptorWithFontAttributes: fontAttributes];
    NSMutableSet *mandatoryKeys = [NSMutableSet setWithCapacity: 1];
    [mandatoryKeys addObject: NSFontTraitsAttribute];
    NSArray *unfilteredFontDescriptors
	= [fontDescriptor matchingFontDescriptorsWithMandatoryKeys: mandatoryKeys];
    
    NSMutableArray *filteredFontNames
	= [NSMutableArray arrayWithCapacity: [unfilteredFontDescriptors count]];
    for(NSFontDescriptor *fontDescriptor in unfilteredFontDescriptors) {
	if(negative_traits) {
	    NSFont *font = [NSFont fontWithDescriptor: fontDescriptor
				   size: 12.0];
	    NSFontTraitMask actual_cocoa_traits = [fontManager traitsOfFont: font];
	    
	    if((negative_traits & EF_FONT_TRAIT_ITALIC)
	       && (actual_cocoa_traits & NSItalicFontMask))
		continue;
	    if((negative_traits & EF_FONT_TRAIT_BOLD)
	       && (actual_cocoa_traits & NSBoldFontMask))
		continue;
	    if((negative_traits & EF_FONT_TRAIT_EXPANDED)
	       && (actual_cocoa_traits & NSExpandedFontMask))
		continue;
	    if((negative_traits & EF_FONT_TRAIT_CONDENSED)
	       && (actual_cocoa_traits & NSCondensedFontMask))
		continue;
	    if((negative_traits & EF_FONT_TRAIT_FIXED_PITCH)
	       && (actual_cocoa_traits & NSFixedPitchFontMask))
		continue;
	}
	
	[filteredFontNames addObject: [fontDescriptor postscriptName]];
    }
    
    computed_font_name_buffer = filteredFontNames;
    [computed_font_name_buffer retain];
    
    [pool drain];
}


void ef_text_compute_available_members_of_font_family(utf8 *family_name) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    if(computed_font_name_buffer) {
	[computed_font_name_buffer release];
	computed_font_name_buffer = nil;
    }
    NSFontManager *fontManager = [NSFontManager sharedFontManager];
    NSString *familyNameString = [NSString stringWithUTF8String: (char *) family_name];
    computed_font_name_buffer
	= [fontManager availableMembersOfFontFamily: familyNameString];
    [computed_font_name_buffer retain];
    [pool drain];
}


int32_t ef_text_computed_count() {
    if(!computed_font_name_buffer)
	return 0;
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    int32_t result = [computed_font_name_buffer count];
    [pool drain];
    return result;
}


utf8 *ef_text_computed_name_n(int32_t which) {
    if(!computed_font_name_buffer)
	return NULL;
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    if(which >= [computed_font_name_buffer count]) {
	[pool drain];
	return NULL;
    }
    
    id item = [computed_font_name_buffer objectAtIndex: which];
    utf8* result = NULL;
    if([item isKindOfClass: [NSString class]]) {
	NSString *string = (NSString *) item;
	result = utf8_dup((utf8 *) [string UTF8String]);
    } else if ([item isKindOfClass: [NSArray class]]) {
	NSArray *array = (NSArray *) item;
	NSString *string = [array objectAtIndex: 0];
	result = utf8_dup((utf8 *) [string UTF8String]);
    }
    
    [pool drain];
    return result;
}


utf8 *ef_text_computed_style_name_n(int32_t which) {
    if(!computed_font_name_buffer)
	return NULL;
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    if(which >= [computed_font_name_buffer count]) {
	[pool drain];
	return NULL;
    }
    
    id item = [computed_font_name_buffer objectAtIndex: which];
    if(![item isKindOfClass: [NSArray class]]) {
	[pool drain];
	return NULL;
    }
    NSArray *array = (NSArray *) item;
    NSString *string = [array objectAtIndex: 1];
    utf8 *result = utf8_dup((utf8 *) [string UTF8String]);
    
    [pool drain];
    return result;
}


EF_Font_Weight ef_text_computed_weight_n(int32_t which) {
    if(!computed_font_name_buffer)
	return 0;
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    if(which >= [computed_font_name_buffer count]) {
	[pool drain];
	return 0;
    }
    
    id item = [computed_font_name_buffer objectAtIndex: which];
    if(![item isKindOfClass: [NSArray class]]) {
	[pool drain];
	return 0;
    }
    NSArray *array = (NSArray *) item;
    NSNumber *number = [array objectAtIndex: 2];
    EF_Font_Weight result = [number intValue];
    
    [pool drain];
    return result;
}


EF_Font_Traits ef_text_computed_traits_n(int32_t which) {
    if(!computed_font_name_buffer)
	return 0;
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    if(which >= [computed_font_name_buffer count]) {
	[pool drain];
	return 0;
    }
    
    id item = [computed_font_name_buffer objectAtIndex: which];
    if(![item isKindOfClass: [NSArray class]]) {
	[pool drain];
	return 0;
    }
    NSArray *array = (NSArray *) item;
    NSNumber *number = [array objectAtIndex: 3];
    NSInteger cocoa_traits = [number integerValue];
    
    EF_Font_Traits result = 0;
    if(cocoa_traits & NSItalicFontMask)
	result |= EF_FONT_TRAIT_ITALIC;
    if(cocoa_traits & NSBoldFontMask)
	result |= EF_FONT_TRAIT_BOLD;
    if(cocoa_traits & NSExpandedFontMask)
	result |= EF_FONT_TRAIT_EXPANDED;
    if(cocoa_traits & NSCondensedFontMask)
	result |= EF_FONT_TRAIT_CONDENSED;
    if(cocoa_traits & NSFixedPitchFontMask)
	result |= EF_FONT_TRAIT_FIXED_PITCH;
    
    [pool drain];
    return result;
}


void ef_text_discard_computed() {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    if(computed_font_name_buffer) {
	[computed_font_name_buffer release];
	computed_font_name_buffer = nil;
    }
    [pool drain];
}


EF_Font ef_text_specific_font(utf8 *family_name,
			      EF_Font_Traits traits,
			      EF_Font_Weight weight,
			      double size)
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSString *familyName = [NSString stringWithUTF8String: (char *) family_name];
    
    NSFontTraitMask cocoaTraits = 0;
    if(traits & EF_FONT_TRAIT_ITALIC)
	cocoaTraits |= NSItalicFontMask;
    if(traits & EF_FONT_TRAIT_BOLD)
	cocoaTraits |= NSBoldFontMask;
    if(traits & EF_FONT_TRAIT_EXPANDED)
	cocoaTraits |= NSExpandedFontMask;
    if(traits & EF_FONT_TRAIT_CONDENSED)
	cocoaTraits |= NSCondensedFontMask;
    if(traits & EF_FONT_TRAIT_FIXED_PITCH)
	cocoaTraits |= NSFixedPitchFontMask;
    
    NSFontManager *fontManager = [NSFontManager sharedFontManager];
    NSFont *font = [fontManager fontWithFamily: familyName
				traits: cocoaTraits
				weight: weight
				size: size];
    [font retain];
    
    [pool drain];
    return (EF_Font) font;
}


void ef_font_delete(EF_Font font) {
    [(NSFont *) font release];
}


utf8 *ef_font_name(EF_Font font) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    utf8 *result = utf8_dup((utf8 *) [[(NSFont *) font fontName] UTF8String]);
    [pool drain];
    return result;
}


utf8 *ef_font_family_name(EF_Font font) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    utf8 *result = utf8_dup((utf8 *) [[(NSFont *) font familyName] UTF8String]);
    [pool drain];
    return result;
}


utf8 *ef_font_display_name(EF_Font font) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    utf8 *result = utf8_dup((utf8 *) [[(NSFont *) font displayName] UTF8String]);
    [pool drain];
    return result;
}


EF_Font_Traits ef_font_traits(EF_Font font) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSFont *cocoaFont = (NSFont *) font;

    NSFontManager *fontManager = [NSFontManager sharedFontManager];
    NSFontTraitMask cocoaTraits = [fontManager traitsOfFont: cocoaFont];
    
    EF_Font_Traits traits = 0;
    if(cocoaTraits & NSItalicFontMask)
	traits |= EF_FONT_TRAIT_ITALIC;
    if(cocoaTraits & NSBoldFontMask)
	traits |= EF_FONT_TRAIT_BOLD;
    if(cocoaTraits & NSExpandedFontMask)
	traits |= EF_FONT_TRAIT_EXPANDED;
    if(cocoaTraits & NSCondensedFontMask)
	traits |= EF_FONT_TRAIT_CONDENSED;
    if(cocoaTraits & NSFixedPitchFontMask)
	traits |= EF_FONT_TRAIT_FIXED_PITCH;
    
    [pool drain];
    return traits;
}


int32_t ef_font_weight(EF_Font font) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSFont *cocoaFont = (NSFont *) font;
    
    NSFontManager *fontManager = [NSFontManager sharedFontManager];
    int32_t weight = [fontManager weightOfFont: cocoaFont];
    
    [pool drain];
    return weight;
}


EF_Font ef_font_convert_to_face(EF_Font font, utf8 *face_name) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSFontManager *fontManager = [NSFontManager sharedFontManager];
    NSString *faceNameString = [NSString stringWithUTF8String: (char *) face_name];
    NSFont *convertedFont = [fontManager convertFont: (NSFont *) font
					 toFace: faceNameString];
    if(convertedFont)
	[convertedFont retain];
    [pool drain];
    return (EF_Font) convertedFont;
}


EF_Font ef_font_convert_to_family(EF_Font font, utf8 *family_name) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSFontManager *fontManager = [NSFontManager sharedFontManager];
    NSString *familyNameString = [NSString stringWithUTF8String: (char *) family_name];
    NSFont *convertedFont = [fontManager convertFont: (NSFont *) font
					 toFamily: familyNameString];
    if(convertedFont)
	[convertedFont retain];
    [pool drain];
    return (EF_Font) convertedFont;
}


EF_Font ef_font_convert_to_have_traits(EF_Font font, EF_Font_Traits traits) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSFontManager *fontManager = [NSFontManager sharedFontManager];
    NSFont *convertedFont = [(NSFont *) font copyWithZone: nil];
    [convertedFont autorelease];
    if(traits & EF_FONT_TRAIT_ITALIC)
	if(convertedFont)
	    convertedFont = [fontManager convertFont: convertedFont
					 toHaveTrait: NSItalicFontMask];
    if(traits & EF_FONT_TRAIT_BOLD)
	if(convertedFont)
	    convertedFont = [fontManager convertFont: convertedFont
					 toHaveTrait: NSBoldFontMask];
    if(traits & EF_FONT_TRAIT_EXPANDED)
	if(convertedFont)
	    convertedFont = [fontManager convertFont: convertedFont
					 toHaveTrait: NSExpandedFontMask];
    if(traits & EF_FONT_TRAIT_CONDENSED)
	if(convertedFont)
	    convertedFont = [fontManager convertFont: convertedFont
					 toHaveTrait: NSCondensedFontMask];
    if(traits & EF_FONT_TRAIT_FIXED_PITCH)
	if(convertedFont)
	    convertedFont = [fontManager convertFont: convertedFont
					 toHaveTrait: NSFixedPitchFontMask];
    if(convertedFont)
	[convertedFont retain];
    [pool drain];
    return (EF_Font) convertedFont;
}


EF_Font ef_font_convert_to_not_have_traits(EF_Font font, EF_Font_Traits traits) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSFontManager *fontManager = [NSFontManager sharedFontManager];
    NSFont *convertedFont = [(NSFont *) font copyWithZone: nil];
    [convertedFont autorelease];
    if(traits & EF_FONT_TRAIT_ITALIC)
	if(convertedFont)
	    convertedFont = [fontManager convertFont: convertedFont
					 toNotHaveTrait: NSItalicFontMask];
    if(traits & EF_FONT_TRAIT_BOLD)
	if(convertedFont)
	    convertedFont = [fontManager convertFont: convertedFont
					 toNotHaveTrait: NSBoldFontMask];
    if(traits & EF_FONT_TRAIT_EXPANDED)
	if(convertedFont)
	    convertedFont = [fontManager convertFont: convertedFont
					 toNotHaveTrait: NSExpandedFontMask];
    if(traits & EF_FONT_TRAIT_CONDENSED)
	if(convertedFont)
	    convertedFont = [fontManager convertFont: convertedFont
					 toNotHaveTrait: NSCondensedFontMask];
    if(traits & EF_FONT_TRAIT_FIXED_PITCH)
	if(convertedFont)
	    convertedFont = [fontManager convertFont: convertedFont
					 toNotHaveTrait: NSFixedPitchFontMask];
    if(convertedFont)
	[convertedFont retain];
    [pool drain];
    return (EF_Font) convertedFont;
}


EF_Font ef_font_convert_to_size(EF_Font font, double size) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSFontManager *fontManager = [NSFontManager sharedFontManager];
    NSFont *convertedFont = [fontManager convertFont: (NSFont *) font
					 toSize: size];
    if(convertedFont)
	[convertedFont retain];
    [pool drain];
    return (EF_Font) convertedFont;
}


EF_Font ef_font_convert_to_lighter_weight(EF_Font font) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSFontManager *fontManager = [NSFontManager sharedFontManager];
    NSFont *convertedFont = [fontManager convertWeight: NO
					 ofFont: (NSFont *) font];
    if(convertedFont)
	[convertedFont retain];
    [pool drain];
    return (EF_Font) convertedFont;
}


EF_Font ef_font_convert_to_heavier_weight(EF_Font font) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSFontManager *fontManager = [NSFontManager sharedFontManager];
    NSFont *convertedFont = [fontManager convertWeight: YES
					 ofFont: (NSFont *) font];
    if(convertedFont)
	[convertedFont retain];
    [pool drain];
    return (EF_Font) convertedFont;
}


double ef_font_horizontal_advancement_for_glyph(EF_Font font, EF_Glyph glyph) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    double result = [(NSFont *) font advancementForGlyph: (NSGlyph) glyph].width;
    [pool drain];
    return result;
}


double ef_font_vertical_advancement_for_glyph(EF_Font font, EF_Glyph glyph) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    double result = [(NSFont *) font advancementForGlyph: (NSGlyph) glyph].height;
    [pool drain];
    return result;
}


double ef_font_ascender(EF_Font font) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    double result = [(NSFont *) font ascender];
    [pool drain];
    return result;
}


double ef_font_descender(EF_Font font) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    double result = [(NSFont *) font descender];
    [pool drain];
    return result;
}


double ef_font_x_height(EF_Font font) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    double result = [(NSFont *) font xHeight];
    [pool drain];
    return result;
}


double ef_font_cap_height(EF_Font font) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    double result = [(NSFont *) font capHeight];
    [pool drain];
    return result;
}


double ef_font_italic_angle(EF_Font font) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    double result = [(NSFont *) font italicAngle];
    [pool drain];
    return result;
}


double ef_font_leading(EF_Font font) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    double result = [(NSFont *) font leading];
    [pool drain];
    return result;
}


double ef_font_maximum_horizontal_advancement(EF_Font font) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    double result = [(NSFont *) font maximumAdvancement].width;
    [pool drain];
    return result;
}


double ef_font_maximum_vertical_advancement(EF_Font font) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    double result = [(NSFont *) font maximumAdvancement].height;
    [pool drain];
    return result;
}


double ef_font_underline_position(EF_Font font) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    double result = [(NSFont *) font underlinePosition];
    [pool drain];
    return result;
}


double ef_font_underline_thickness(EF_Font font) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    double result = [(NSFont *) font underlineThickness];
    [pool drain];
    return result;
}


void ef_font_bounding_rectangle(EF_Font font,
				double *left,
				double *top,
				double *width,
				double *height)
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSRect rectangle = [(NSFont *) font boundingRectForFont];
    if(left) *left = rectangle.origin.x;
    if(top) *top = rectangle.origin.y;
    if(width) *width = rectangle.size.width;
    if(height) *height = rectangle.size.height;
    [pool drain];
}


void ef_font_glyph_bounding_rectangle(EF_Font font,
				      EF_Glyph glyph,
				      double *left,
				      double *top,
				      double *width,
				      double *height)
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSRect rectangle = [(NSFont *) font boundingRectForGlyph: (NSGlyph) glyph];
    if(left) *left = rectangle.origin.x;
    if(top) *top = rectangle.origin.y;
    if(width) *width = rectangle.size.width;
    if(height) *height = rectangle.size.height;
    [pool drain];
}


EF_Text_Flow ef_text_new_text_flow() {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSTextStorage *textStorage = [[NSTextStorage alloc] init];

    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    [textStorage addLayoutManager: layoutManager];
    [layoutManager release];

    NSTextContainer *textContainer = [[NSTextContainer alloc]
					 initWithContainerSize:
					     NSMakeSize(INFINITY, INFINITY)];
    [textContainer setLineFragmentPadding: 0.0];
    [layoutManager addTextContainer: textContainer];
    [textContainer release];
    
    [pool drain];
    return (EF_Text_Flow) textStorage;
}


EF_Text_Flow ef_text_new_text_flow_with_text(utf8 *text) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSString *string = [NSString stringWithUTF8String: (char *) text];
    
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithString: string];
    
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    [textStorage addLayoutManager: layoutManager];
    [layoutManager release];

    NSTextContainer *textContainer = [[NSTextContainer alloc]
					 initWithContainerSize:
					     NSMakeSize(INFINITY, INFINITY)];
    [textContainer setLineFragmentPadding: 0.0];
    [layoutManager addTextContainer: textContainer];
    [textContainer release];
    
    [pool drain];
    return (EF_Text_Flow) textStorage;
}


EF_Text_Flow
  ef_text_new_text_flow_with_text_and_attributes(utf8 *text,
						 EF_Text_Attributes attributes)
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSString *string = [NSString stringWithUTF8String: (char *) text];
    
    NSTextStorage *textStorage
	= [[NSTextStorage alloc] initWithString: string
				 attributes: (NSMutableDictionary *) attributes];
    
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    [textStorage addLayoutManager: layoutManager];
    [layoutManager release];

    NSTextContainer *textContainer = [[NSTextContainer alloc]
					 initWithContainerSize:
					     NSMakeSize(INFINITY, INFINITY)];
    [textContainer setLineFragmentPadding: 0.0];
    [layoutManager addTextContainer: textContainer];
    [textContainer release];
    
    [pool drain];
    return (EF_Text_Flow) textStorage;
}


void ef_text_flow_delete(EF_Text_Flow text_flow) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSTextStorage *textStorage = (NSTextStorage *) text_flow;
    for(NSLayoutManager *layoutManager in [textStorage layoutManagers]) {
	[textStorage removeLayoutManager: layoutManager];
    }
    [textStorage release];
    [pool drain];
}


utf8 *ef_text_flow_text(EF_Text_Flow text_flow) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSTextStorage *textStorage = (NSTextStorage *) text_flow;
    utf8 *result = utf8_dup((utf8 *) [[textStorage string] UTF8String]);
    [pool drain];
    return result;
}


int32_t ef_text_flow_length(EF_Text_Flow text_flow) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSTextStorage *textStorage = (NSTextStorage *) text_flow;
    int32_t result = [textStorage length];
    [pool drain];
    return result;
}


EF_Text_Attributes
  ef_text_flow_attributes_at_index(EF_Text_Flow text_flow,
				   int32_t index,
				   int32_t *effective_start,
				   int32_t *effective_end)
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSRange effectiveRange;
    NSDictionary *attributesDictionary
	= [(NSTextStorage *) text_flow attributesAtIndex: index
			     effectiveRange: &effectiveRange];
    if(effective_start)
	*effective_start = effectiveRange.location;
    if(effective_end)
	*effective_end = effectiveRange.location + effectiveRange.length;
    NSMutableDictionary *attributes = [attributesDictionary mutableCopyWithZone: nil];
    [pool drain];
    return (EF_Text_Attributes) attributes;
}


void ef_text_flow_enumerate_attributes(EF_Text_Flow text_flow,
				       int (*callback)(EF_Text_Attributes
						       text_attributes,
						       int32_t start,
						       int32_t end))
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    NSTextStorage *textStorage = (NSTextStorage *) text_flow;

    NSRange fullRange = NSMakeRange(0, [textStorage length]);
    [textStorage enumerateAttributesInRange: fullRange
		 options: NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
		 usingBlock: ^(NSDictionary *attributesDictionary,
			       NSRange range,
			       BOOL *stop)
		 {
		     NSMutableDictionary *attributes
			 = [attributesDictionary mutableCopyWithZone: nil];
		     [attributes autorelease];
		     int shouldStop = callback(attributes,
					       range.location,
					       range.location + range.length);
		     if(shouldStop == 1)
			 *stop = YES;
		 }];
    
    [pool drain];
}


void ef_text_flow_replace_text(EF_Text_Flow text_flow,
			       utf8 *text,
			       int32_t start,
			       int32_t end)
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    NSTextStorage *textStorage = (NSTextStorage *) text_flow;

    NSString *string = [NSString stringWithUTF8String: (char *) text];
    NSRange range = NSMakeRange(start, end - start);
    [textStorage replaceCharactersInRange: range withString: string];
    
    [pool drain];
}


void ef_text_flow_delete_text(EF_Text_Flow text_flow,
			      int32_t start,
			      int32_t end)
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    NSTextStorage *textStorage = (NSTextStorage *) text_flow;

    NSRange range = NSMakeRange(start, end - start);
    [textStorage deleteCharactersInRange: range];
    
    [pool drain];
}


void ef_text_flow_set_attributes(EF_Text_Flow text_flow,
				 EF_Text_Attributes text_attributes,
				 int32_t start,
				 int32_t end)
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    NSTextStorage *textStorage = (NSTextStorage *) text_flow;
    NSMutableDictionary *attributes = (NSMutableDictionary *) text_attributes;
    
    NSRange range = NSMakeRange(start, end - start);
    [textStorage setAttributes: attributes range: range];
    
    [pool drain];
}


void ef_text_flow_natural_size(EF_Text_Flow text_flow,
			       double *width,
			       double *height)
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSTextStorage *textStorage = (NSTextStorage *) text_flow;
    NSSize size = [textStorage size];
    if(width)
	*width = size.width;
    if(height)
	*height = size.height;
    [pool drain];
}


void ef_text_flow_size(EF_Text_Flow text_flow, double *width, double *height) {
}


void ef_text_flow_set_size(EF_Text_Flow text_flow, double width, double height) {
}


void ef_text_flow_draw(EF_Text_Flow text_flow, EF_Drawable drawable) {
    ef_drawable_make_current(drawable);
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSTextStorage *textStorage = (NSTextStorage *) text_flow;
    NSLayoutManager *layoutManager = [[textStorage layoutManagers]
					 objectAtIndex: 0];
    
    NSUInteger fullGlyphCount = [layoutManager numberOfGlyphs];
    if(fullGlyphCount > 0) {
	NSGlyph *fullGlyphs = malloc(sizeof(NSGlyph) * fullGlyphCount);
	[layoutManager getGlyphsInRange: NSMakeRange(0, fullGlyphCount)
		       glyphs: fullGlyphs
		       characterIndexes: NULL
		       glyphInscriptions: NULL
		       elasticBits: NULL
		       bidiLevels: NULL];
	[textStorage enumerateAttributesInRange: NSMakeRange(0, [textStorage length])
		     options: 0
		     usingBlock: ^(NSDictionary *attributes,
				   NSRange attributeRunCharacterRange,
				   BOOL *stop)
		     {
			 NSFont *font = [attributes objectForKey: NSFontAttributeName];
			 
			 NSRange attributeRunGlyphRange
			     = [layoutManager glyphRangeForCharacterRange:
						  attributeRunCharacterRange
					      actualCharacterRange: NULL];
			 
			 while(1) {
			     NSRange lineFragmentGlyphRange;
			     NSRect lineFragmentRect
				 = [layoutManager lineFragmentRectForGlyphAtIndex:
						      attributeRunGlyphRange.location
						  effectiveRange:
						      &lineFragmentGlyphRange];
			     
			     NSRange shownPartOfLineFragmentGlyphRange;
			     shownPartOfLineFragmentGlyphRange.location
				 = attributeRunGlyphRange.location;
			     if(lineFragmentGlyphRange.location
				+ lineFragmentGlyphRange.length
				< attributeRunGlyphRange.location
				+ attributeRunGlyphRange.length)
			     {
				 shownPartOfLineFragmentGlyphRange.length
				     = lineFragmentGlyphRange.location
				     + lineFragmentGlyphRange.length
				     - attributeRunGlyphRange.location;
			     } else {
				 shownPartOfLineFragmentGlyphRange.length
				     = attributeRunGlyphRange.length;
			     }
			     
			     NSGlyph *glyphs = fullGlyphs
				 + shownPartOfLineFragmentGlyphRange.location;
				 
			     NSPoint locationWithinLineFragment
				 = [layoutManager
				       locationForGlyphAtIndex:
					   shownPartOfLineFragmentGlyphRange.location];
			     NSPoint glyphOrigin = locationWithinLineFragment;
			     
			     NSBezierPath *unflattenedUnscaledPath
				 = [NSBezierPath bezierPath];
			     [unflattenedUnscaledPath moveToPoint: glyphOrigin];
			     [unflattenedUnscaledPath
				 appendBezierPathWithGlyphs: glyphs
				 count: shownPartOfLineFragmentGlyphRange.length
				 inFont: font];
			     
			     NSBezierPath *unflattenedScaledPath
				 = ef_internal_transform_bezier_path
				   (unflattenedUnscaledPath,
				    ^(NSPoint point)
				    {
					return NSMakePoint(point.x * 4.0,
							   point.y * 4.0);
				    });
			     
			     NSBezierPath *flattenedScaledPath
				 = [unflattenedScaledPath bezierPathByFlatteningPath];
			     
			     NSBezierPath *flattenedUnscaledPath
				 = ef_internal_transform_bezier_path
				   (flattenedScaledPath,
				    ^(NSPoint point)
				    {
					return NSMakePoint(point.x / 4.0,
							   point.y / 4.0);
				    });

			     /*
			     glColor4f(1.0f, 1.0f, 0.0f, 1.0f);
			     glBegin(GL_QUADS);
			     glVertex2d(lineFragmentRect.origin.x,
					lineFragmentRect.origin.y
					+ [font descender]);
			     glVertex2d(lineFragmentRect.origin.x
					+ lineFragmentRect.size.width,
					lineFragmentRect.origin.y
					+ [font descender]);
			     glVertex2d(lineFragmentRect.origin.x
					+ lineFragmentRect.size.width,
					lineFragmentRect.origin.y
					+ lineFragmentRect.size.height
					+ [font descender]);
			     glVertex2d(lineFragmentRect.origin.x,
					lineFragmentRect.origin.y
					+ lineFragmentRect.size.height
					+ [font descender]);
			     glEnd();
			     */
			     
			     glColor4f(0.0f, 0.0f, 0.0f, 1.0f);

			     NSInteger elementCount
				 = [flattenedUnscaledPath elementCount];
			     NSMutableArray *vertices
				 = [NSMutableArray arrayWithCapacity: elementCount];
			     
			     GLUtesselator *tesselator = gluNewTess();
			     gluTessCallback(tesselator,
					     GLU_TESS_BEGIN,
					     ef_internal_tesselation_begin);
			     gluTessCallback(tesselator,
					     GLU_TESS_END,
					     ef_internal_tesselation_end);
			     gluTessCallback(tesselator,
					     GLU_TESS_VERTEX_DATA,
					     ef_internal_tesselation_vertex);
			     gluTessBeginPolygon(tesselator, (void *) vertices);
			     
			     for(NSInteger i = 0; i < elementCount; i++) {
				 NSPoint points[3];
				 NSBezierPathElement element
				     = [flattenedUnscaledPath elementAtIndex: i
							      associatedPoints: points];
				 switch(element) {
				 case NSMoveToBezierPathElement:
				     {
					 if(i == elementCount - 1)
					     break;
					 
					 NSPoint point = points[0];
					 point.x = - lineFragmentRect.origin.x
					           + point.x;
					 point.y = - lineFragmentRect.origin.y
					           - lineFragmentRect.size.height
					           + [font pointSize] / 2.0
					           + [font descender]
					           + point.y;
					 NSValue *pointValue
					     = [NSValue valueWithPoint: point];
					 NSUInteger pointIndex = [vertices count];
					 [vertices addObject: pointValue];
					 
					 GLdouble vertex[3];
					 vertex[0] = point.x;
					 vertex[1] = point.y;
					 vertex[2] = 0.0;
					 
					 gluTessBeginContour(tesselator);
					 gluTessVertex(tesselator,
						       vertex,
						       (void *) pointIndex);
					 break;
				     }
				 case NSLineToBezierPathElement:
				     {
					 NSPoint point = points[0];
					 point.x = - lineFragmentRect.origin.x
					           + point.x;
					 point.y = - lineFragmentRect.origin.y
					           - lineFragmentRect.size.height
					           + [font pointSize] / 2.0
					           + [font descender]
					           + point.y;
					 NSValue *pointValue
					     = [NSValue valueWithPoint: point];
					 NSUInteger pointIndex = [vertices count];
					 [vertices addObject: pointValue];
					 
					 GLdouble vertex[3];
					 vertex[0] = point.x;
					 vertex[1] = point.y;
					 vertex[2] = 0.0;
					 
					 gluTessVertex(tesselator,
						       vertex,
						       (void *) pointIndex);
					 break;
				     }
				 case NSClosePathBezierPathElement:
				     {
					 gluTessEndContour(tesselator);
					 break;
				     }
				 }
			     }
			     gluTessEndPolygon(tesselator);
			     
			     if(lineFragmentGlyphRange.location
				+ lineFragmentGlyphRange.length
				>= attributeRunGlyphRange.location
				+ attributeRunGlyphRange.length)
				 break;
			     attributeRunGlyphRange.length
				 = attributeRunGlyphRange.location
				 + attributeRunGlyphRange.length
				 - lineFragmentGlyphRange.location
				 - lineFragmentGlyphRange.length;
			     attributeRunGlyphRange.location
				 = lineFragmentGlyphRange.location
				 + lineFragmentGlyphRange.length;
			 }
		     }];
	free(fullGlyphs);
    }
    
    [pool drain];
}


static NSBezierPath *ef_internal_transform_bezier_path(NSBezierPath *untransformedPath,
						       NSPoint (^block)(NSPoint))
{
    NSBezierPath *transformedPath = [NSBezierPath bezierPath];
    NSInteger elementCount = [untransformedPath elementCount];
    for(NSInteger i = 0; i < elementCount; i++) {
	NSPoint points[3];
	NSBezierPathElement element
	    = [untransformedPath elementAtIndex: i
				 associatedPoints: points];
	switch(element) {
	case NSMoveToBezierPathElement:
	    {
		NSPoint point = block(points[0]);
		[transformedPath moveToPoint: point];
		break;
	    }
	case NSLineToBezierPathElement:
	    {
		NSPoint point = block(points[0]);
		[transformedPath lineToPoint: point];
		break;
	    }
	case NSCurveToBezierPathElement:
	    {
		NSPoint controlPoint1 = block(points[0]);
		NSPoint controlPoint2 = block(points[1]);
		NSPoint endPoint = block(points[2]);
		[transformedPath curveToPoint: endPoint
				 controlPoint1: controlPoint1
				 controlPoint2: controlPoint2];
		break;
	    }
	case NSClosePathBezierPathElement:
	    {
		[transformedPath closePath];
		break;
	    }
	}
    }
    return transformedPath;
}


static void ef_internal_tesselation_begin(GLenum type) {
    glBegin(type);
}


static void ef_internal_tesselation_end() {
    glEnd();
}


static void ef_internal_tesselation_vertex(void *vertexContext, void *polygonContext) {
    NSUInteger pointIndex = (NSUInteger) vertexContext;
    NSMutableArray *vertices = (NSMutableArray *) polygonContext;
    NSValue *pointValue = [vertices objectAtIndex: pointIndex];
    NSPoint point = [pointValue pointValue];
    glVertex2d(point.x, point.y);
}


EF_Text_Attributes ef_text_new_attributes() {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithCapacity: 8];
    [attributes retain];
    [pool drain];
    return (EF_Text_Attributes) attributes;
}


void ef_text_attributes_delete(EF_Text_Attributes attributes) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [(NSMutableDictionary *) attributes release];
    [pool drain];
}


EF_Font ef_text_attributes_font(EF_Text_Attributes attributes) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    EF_Font result
	= (EF_Font) [(NSMutableDictionary *) attributes
					     objectForKey: NSFontAttributeName];
    [pool drain];
    return result;
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
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [(NSMutableDictionary *) attributes
			     setObject: (NSFont *) font
			     forKey: NSFontAttributeName];
    [pool drain];
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


void ef_text_attributes_set_outline_style(EF_Text_Attributes attributes,
					  EF_Outline_Style outline_style)
{
}


void ef_text_attributes_set_stroke_width(EF_Text_Attributes attributes,
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

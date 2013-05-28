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
    @autoreleasepool {
        if(computed_font_name_buffer) {
            computed_font_name_buffer = nil;
        }
        NSFontManager *fontManager = [NSFontManager sharedFontManager];
        computed_font_name_buffer = [fontManager availableFontFamilies];
    }
}


void ef_text_compute_available_fonts_with_traits(EF_Font_Traits traits,
						 EF_Font_Traits negative_traits)
{
    @autoreleasepool {
        if(computed_font_name_buffer) {
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
    }
}


void ef_text_compute_available_members_of_font_family(utf8 *family_name) {
    @autoreleasepool {
        if(computed_font_name_buffer) {
            computed_font_name_buffer = nil;
        }
        NSFontManager *fontManager = [NSFontManager sharedFontManager];
        NSString *familyNameString = [NSString stringWithUTF8String: (char *) family_name];
        computed_font_name_buffer
        = [fontManager availableMembersOfFontFamily: familyNameString];
    }
}


int32_t ef_text_computed_count() {
    if(!computed_font_name_buffer)
	return 0;
    
    @autoreleasepool {
        int32_t result = [computed_font_name_buffer count];
        return result;
    }
}


utf8 *ef_text_computed_name_n(int32_t which) {
    if(!computed_font_name_buffer)
	return NULL;
    @autoreleasepool {
        if(which >= [computed_font_name_buffer count]) {
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
        
        return result;
    }
}


utf8 *ef_text_computed_style_name_n(int32_t which) {
    if(!computed_font_name_buffer)
	return NULL;
    @autoreleasepool {
        if(which >= [computed_font_name_buffer count]) {
            return NULL;
        }
        
        id item = [computed_font_name_buffer objectAtIndex: which];
        if(![item isKindOfClass: [NSArray class]]) {
            return NULL;
        }
        NSArray *array = (NSArray *) item;
        NSString *string = [array objectAtIndex: 1];
        utf8 *result = utf8_dup((utf8 *) [string UTF8String]);
        
        return result;
    }
}


EF_Font_Weight ef_text_computed_weight_n(int32_t which) {
    if(!computed_font_name_buffer)
	return 0;
    @autoreleasepool {
        if(which >= [computed_font_name_buffer count]) {
            return 0;
        }
        
        id item = [computed_font_name_buffer objectAtIndex: which];
        if(![item isKindOfClass: [NSArray class]]) {
            return 0;
        }
        NSArray *array = (NSArray *) item;
        NSNumber *number = [array objectAtIndex: 2];
        EF_Font_Weight result = [number intValue];
        
        return result;
    }
}


EF_Font_Traits ef_text_computed_traits_n(int32_t which) {
    if(!computed_font_name_buffer)
	return 0;
    @autoreleasepool {
        if(which >= [computed_font_name_buffer count]) {
            return 0;
        }
        
        id item = [computed_font_name_buffer objectAtIndex: which];
        if(![item isKindOfClass: [NSArray class]]) {
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
        
        return result;
    }
}


void ef_text_discard_computed() {
    @autoreleasepool {
        if(computed_font_name_buffer) {
            computed_font_name_buffer = nil;
        }
    }
}


EF_Font ef_text_specific_font(utf8 *family_name,
			      EF_Font_Traits traits,
			      EF_Font_Weight weight,
			      double size)
{
    @autoreleasepool {
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
        
        return (__bridge EF_Font) font;
    }
}


void ef_font_delete(EF_Font font) {
}


utf8 *ef_font_name(EF_Font font) {
    @autoreleasepool {
        utf8 *result = utf8_dup((utf8 *) [[(__bridge NSFont *) font fontName] UTF8String]);
        return result;
    }
}


utf8 *ef_font_family_name(EF_Font font) {
    @autoreleasepool {
        utf8 *result = utf8_dup((utf8 *) [[(__bridge NSFont *) font familyName] UTF8String]);
        return result;
    }
}


utf8 *ef_font_display_name(EF_Font font) {
    @autoreleasepool {
        utf8 *result = utf8_dup((utf8 *) [[(__bridge NSFont *) font displayName] UTF8String]);
        return result;
    }
}


EF_Font_Traits ef_font_traits(EF_Font font) {
    @autoreleasepool {
        NSFont *cocoaFont = (__bridge NSFont *) font;

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
        
        return traits;
    }
}


int32_t ef_font_weight(EF_Font font) {
    @autoreleasepool {
        NSFont *cocoaFont = (__bridge NSFont *) font;
    
        NSFontManager *fontManager = [NSFontManager sharedFontManager];
        int32_t weight = [fontManager weightOfFont: cocoaFont];
    
        return weight;
    }
}


EF_Font ef_font_convert_to_face(EF_Font font, utf8 *face_name) {
    @autoreleasepool {
        NSFontManager *fontManager = [NSFontManager sharedFontManager];
        NSString *faceNameString = [NSString stringWithUTF8String: (char *) face_name];
        NSFont *convertedFont = [fontManager convertFont: (__bridge NSFont *) font
                         toFace: faceNameString];
        if(convertedFont)
        return (__bridge EF_Font) convertedFont;
        return NULL;
    }
}


EF_Font ef_font_convert_to_family(EF_Font font, utf8 *family_name) {
    @autoreleasepool {
        NSFontManager *fontManager = [NSFontManager sharedFontManager];
        NSString *familyNameString = [NSString stringWithUTF8String: (char *) family_name];
        NSFont *convertedFont = [fontManager convertFont: (__bridge NSFont *) font
                         toFamily: familyNameString];
        if(convertedFont)
        return (__bridge EF_Font) convertedFont;
        return NULL;
    }
}


EF_Font ef_font_convert_to_have_traits(EF_Font font, EF_Font_Traits traits) {
    @autoreleasepool {
        NSFontManager *fontManager = [NSFontManager sharedFontManager];
        NSFont *convertedFont = [(__bridge NSFont *) font copyWithZone: nil];
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
        return (__bridge EF_Font) convertedFont;
        return NULL;
    }
}


EF_Font ef_font_convert_to_not_have_traits(EF_Font font, EF_Font_Traits traits) {
    @autoreleasepool {
        NSFontManager *fontManager = [NSFontManager sharedFontManager];
        NSFont *convertedFont = [(__bridge NSFont *) font copyWithZone: nil];
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
        return (__bridge EF_Font) convertedFont;
        return NULL;
    }
}


EF_Font ef_font_convert_to_size(EF_Font font, double size) {
    @autoreleasepool {
        NSFontManager *fontManager = [NSFontManager sharedFontManager];
        NSFont *convertedFont = [fontManager convertFont: (__bridge NSFont *) font
                         toSize: size];
        if(convertedFont)
        return (__bridge EF_Font) convertedFont;
        return NULL;
    }
}


EF_Font ef_font_convert_to_lighter_weight(EF_Font font) {
    @autoreleasepool {
        NSFontManager *fontManager = [NSFontManager sharedFontManager];
        NSFont *convertedFont = [fontManager convertWeight: NO
                         ofFont: (__bridge NSFont *) font];
        if(convertedFont)
        return (__bridge EF_Font) convertedFont;
        return NULL;
    }
}


EF_Font ef_font_convert_to_heavier_weight(EF_Font font) {
    @autoreleasepool {
        NSFontManager *fontManager = [NSFontManager sharedFontManager];
        NSFont *convertedFont = [fontManager convertWeight: YES
                         ofFont: (__bridge NSFont *) font];
        if(convertedFont)
        return (__bridge EF_Font) convertedFont;
        return NULL;
    }
}


double ef_font_horizontal_advancement_for_glyph(EF_Font font, EF_Glyph glyph) {
    @autoreleasepool {
        double result = [(__bridge NSFont *) font advancementForGlyph: (NSGlyph) glyph].width;
        return result;
    }
}


double ef_font_vertical_advancement_for_glyph(EF_Font font, EF_Glyph glyph) {
    @autoreleasepool {
        double result = [(__bridge NSFont *) font advancementForGlyph: (NSGlyph) glyph].height;
        return result;
    }
}


double ef_font_ascender(EF_Font font) {
    @autoreleasepool {
        double result = [(__bridge NSFont *) font ascender];
        return result;
    }
}


double ef_font_descender(EF_Font font) {
    @autoreleasepool {
        double result = [(__bridge NSFont *) font descender];
        return result;
    }
}


double ef_font_x_height(EF_Font font) {
    @autoreleasepool {
        double result = [(__bridge NSFont *) font xHeight];
        return result;
    }
}


double ef_font_cap_height(EF_Font font) {
    @autoreleasepool {
        double result = [(__bridge NSFont *) font capHeight];
        return result;
    }
}


double ef_font_italic_angle(EF_Font font) {
    @autoreleasepool {
        double result = [(__bridge NSFont *) font italicAngle];
        return result;
    }
}


double ef_font_leading(EF_Font font) {
    @autoreleasepool {
        double result = [(__bridge NSFont *) font leading];
        return result;
    }
}


double ef_font_maximum_horizontal_advancement(EF_Font font) {
    @autoreleasepool {
        double result = [(__bridge NSFont *) font maximumAdvancement].width;
        return result;
    }
}


double ef_font_maximum_vertical_advancement(EF_Font font) {
    @autoreleasepool {
        double result = [(__bridge NSFont *) font maximumAdvancement].height;
        return result;
    }
}


double ef_font_underline_position(EF_Font font) {
    @autoreleasepool {
        double result = [(__bridge NSFont *) font underlinePosition];
        return result;
    }
}


double ef_font_underline_thickness(EF_Font font) {
    @autoreleasepool {
        double result = [(__bridge NSFont *) font underlineThickness];
        return result;
    }
}


void ef_font_bounding_rectangle(EF_Font font,
				double *left,
				double *top,
				double *width,
				double *height)
{
    @autoreleasepool {
        NSRect rectangle = [(__bridge NSFont *) font boundingRectForFont];
        if(left) *left = rectangle.origin.x;
        if(top) *top = rectangle.origin.y;
        if(width) *width = rectangle.size.width;
        if(height) *height = rectangle.size.height;
    }
}


void ef_font_glyph_bounding_rectangle(EF_Font font,
				      EF_Glyph glyph,
				      double *left,
				      double *top,
				      double *width,
				      double *height)
{
    @autoreleasepool {
        NSRect rectangle = [(__bridge NSFont *) font boundingRectForGlyph: (NSGlyph) glyph];
        if(left) *left = rectangle.origin.x;
        if(top) *top = rectangle.origin.y;
        if(width) *width = rectangle.size.width;
        if(height) *height = rectangle.size.height;
    }
}


EF_Text_Flow ef_text_new_text_flow() {
    @autoreleasepool {
        NSTextStorage *textStorage = [[NSTextStorage alloc] init];

        NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
        [textStorage addLayoutManager: layoutManager];

        NSTextContainer *textContainer = [[NSTextContainer alloc]
                         initWithContainerSize:
                             NSMakeSize(INFINITY, INFINITY)];
        [textContainer setLineFragmentPadding: 0.0];
        [layoutManager addTextContainer: textContainer];
    
        return (__bridge EF_Text_Flow) textStorage;
    }
}


EF_Text_Flow ef_text_new_text_flow_with_text(utf8 *text) {
    @autoreleasepool {
        NSString *string = [NSString stringWithUTF8String: (char *) text];
    
        NSTextStorage *textStorage = [[NSTextStorage alloc] initWithString: string];
    
        NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
        [textStorage addLayoutManager: layoutManager];

        NSTextContainer *textContainer = [[NSTextContainer alloc]
                         initWithContainerSize:
                             NSMakeSize(INFINITY, INFINITY)];
        [textContainer setLineFragmentPadding: 0.0];
        [layoutManager addTextContainer: textContainer];
    
        return (__bridge EF_Text_Flow) textStorage;
    }
}


EF_Text_Flow
  ef_text_new_text_flow_with_text_and_attributes(utf8 *text,
						 EF_Text_Attributes attributes)
{
    @autoreleasepool {
        NSString *string = [NSString stringWithUTF8String: (char *) text];
    
        NSTextStorage *textStorage
        = [[NSTextStorage alloc] initWithString: string
                     attributes: (__bridge NSMutableDictionary *) attributes];
    
        NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
        [textStorage addLayoutManager: layoutManager];

        NSTextContainer *textContainer = [[NSTextContainer alloc]
                         initWithContainerSize:
                             NSMakeSize(INFINITY, INFINITY)];
        [textContainer setLineFragmentPadding: 0.0];
        [layoutManager addTextContainer: textContainer];
    
        return (__bridge EF_Text_Flow) textStorage;
    }
}


void ef_text_flow_delete(EF_Text_Flow text_flow) {
    @autoreleasepool {
        NSTextStorage *textStorage = (__bridge NSTextStorage *) text_flow;
        for(NSLayoutManager *layoutManager in [textStorage layoutManagers]) {
        [textStorage removeLayoutManager: layoutManager];
        }
    }
}


utf8 *ef_text_flow_text(EF_Text_Flow text_flow) {
    @autoreleasepool {
        NSTextStorage *textStorage = (__bridge NSTextStorage *) text_flow;
        utf8 *result = utf8_dup((utf8 *) [[textStorage string] UTF8String]);
        return result;
    }
}


int32_t ef_text_flow_length(EF_Text_Flow text_flow) {
    @autoreleasepool {
        NSTextStorage *textStorage = (__bridge NSTextStorage *) text_flow;
        int32_t result = [textStorage length];
        return result;
    }
}


EF_Text_Attributes
  ef_text_flow_attributes_at_index(EF_Text_Flow text_flow,
				   int32_t index,
				   int32_t *effective_start,
				   int32_t *effective_end)
{
    @autoreleasepool {
        NSRange effectiveRange;
        NSDictionary *attributesDictionary
        = [(__bridge NSTextStorage *) text_flow attributesAtIndex: index
                     effectiveRange: &effectiveRange];
        if(effective_start)
        *effective_start = effectiveRange.location;
        if(effective_end)
        *effective_end = effectiveRange.location + effectiveRange.length;
        NSMutableDictionary *attributes = [attributesDictionary mutableCopyWithZone: nil];
        return (__bridge EF_Text_Attributes) attributes;
    }
}


void ef_text_flow_enumerate_attributes(EF_Text_Flow text_flow,
				       int (*callback)(EF_Text_Attributes
						       text_attributes,
						       int32_t start,
						       int32_t end))
{
    @autoreleasepool {
        NSTextStorage *textStorage = (__bridge NSTextStorage *) text_flow;

        NSRange fullRange = NSMakeRange(0, [textStorage length]);
        [textStorage enumerateAttributesInRange: fullRange
             options: NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
             usingBlock: ^(NSDictionary *attributesDictionary,
                       NSRange range,
                       BOOL *stop)
             {
                 NSMutableDictionary *attributes
                 = [attributesDictionary mutableCopyWithZone: nil];
                 int shouldStop = callback((__bridge EF_Text_Attributes)(attributes),
                               range.location,
                               range.location + range.length);
                 if(shouldStop == 1)
                 *stop = YES;
             }];
    }
}


void ef_text_flow_replace_text(EF_Text_Flow text_flow,
			       utf8 *text,
			       int32_t start,
			       int32_t end)
{
    @autoreleasepool {
        NSTextStorage *textStorage = (__bridge NSTextStorage *) text_flow;

        NSString *string = [NSString stringWithUTF8String: (char *) text];
        NSRange range = NSMakeRange(start, end - start);
        [textStorage replaceCharactersInRange: range withString: string];
    }
}


void ef_text_flow_delete_text(EF_Text_Flow text_flow,
			      int32_t start,
			      int32_t end)
{
    @autoreleasepool {
        NSTextStorage *textStorage = (__bridge NSTextStorage *) text_flow;

        NSRange range = NSMakeRange(start, end - start);
        [textStorage deleteCharactersInRange: range];
    }
}


void ef_text_flow_set_attributes(EF_Text_Flow text_flow,
				 EF_Text_Attributes text_attributes,
				 int32_t start,
				 int32_t end)
{
    @autoreleasepool {
        NSTextStorage *textStorage = (__bridge NSTextStorage *) text_flow;
        NSMutableDictionary *attributes = (__bridge NSMutableDictionary *) text_attributes;
    
        NSRange range = NSMakeRange(start, end - start);
        [textStorage setAttributes: attributes range: range];
    }
}


void ef_text_flow_remove_attribute(EF_Text_Flow text_flow,
				   EF_Text_Attribute_Identifier
				     text_attribute_identifier,
				   int32_t start,
				   int32_t end)
{
    @autoreleasepool {
        NSTextStorage *textStorage = (__bridge NSTextStorage *) text_flow;

        NSRange range = NSMakeRange(start, end - start);

        NSString *attributeName = nil;
        switch(text_attribute_identifier) {
        case EF_TEXT_ATTRIBUTE_FONT:
        attributeName = NSFontAttributeName;
        break;
        case EF_TEXT_ATTRIBUTE_PARAGRAPH_STYLE:
        attributeName = NSParagraphStyleAttributeName;
        break;
        case EF_TEXT_ATTRIBUTE_FOREGROUND_COLOR:
        attributeName = NSForegroundColorAttributeName;
        break;
        case EF_TEXT_ATTRIBUTE_BACKGROUND_COLOR:
        attributeName = NSBackgroundColorAttributeName;
        break;
        case EF_TEXT_ATTRIBUTE_UNDERLINE_STYLE:
        attributeName = NSUnderlineStyleAttributeName;
        break;
        case EF_TEXT_ATTRIBUTE_UNDERLINE_COLOR:
        attributeName = NSUnderlineColorAttributeName;
        break;
        case EF_TEXT_ATTRIBUTE_STRIKETHROUGH_STYLE:
        attributeName = NSStrikethroughStyleAttributeName;
        break;
        case EF_TEXT_ATTRIBUTE_STRIKETHROUGH_COLOR:
        attributeName = NSStrikethroughColorAttributeName;
        break;
        case EF_TEXT_ATTRIBUTE_LIGATURE_STYLE:
        attributeName = NSLigatureAttributeName;
        break;
        case EF_TEXT_ATTRIBUTE_BASELINE_OFFSET:
        attributeName = NSBaselineOffsetAttributeName;
        break;
        case EF_TEXT_ATTRIBUTE_KERNING:
        attributeName = NSKernAttributeName;
        break;
        case EF_TEXT_ATTRIBUTE_OUTLINE_STYLE:
        attributeName = NSStrokeWidthAttributeName;
        break;
        case EF_TEXT_ATTRIBUTE_STROKE_WIDTH:
        attributeName = NSStrokeWidthAttributeName;
        break;
        case EF_TEXT_ATTRIBUTE_OBLIQUENESS:
        attributeName = NSObliquenessAttributeName;
        break;
        case EF_TEXT_ATTRIBUTE_EXPANSION:
        attributeName = NSExpansionAttributeName;
        break;
        }

        if(attributeName)
        [textStorage removeAttribute: attributeName range: range];
	}
}


void ef_text_flow_natural_size(EF_Text_Flow text_flow,
			       double *width,
			       double *height)
{
    @autoreleasepool {
        NSTextStorage *textStorage = (__bridge NSTextStorage *) text_flow;
        NSSize size = [textStorage size];
        if(width)
        *width = size.width;
        if(height)
        *height = size.height;
    }
}


void ef_text_flow_size(EF_Text_Flow text_flow, double *width, double *height) {
    @autoreleasepool {
        NSTextStorage *textStorage = (__bridge NSTextStorage *) text_flow;
        NSLayoutManager *layoutManager = [[textStorage layoutManagers] objectAtIndex: 0];
        NSTextContainer *textContainer = [[layoutManager textContainers] objectAtIndex: 0];
        NSSize size = [textContainer containerSize];
        if(width)
        *width = size.width;
        if(height)
        *height = size.height;
	}
}


void ef_text_flow_set_size(EF_Text_Flow text_flow, double width, double height) {
    @autoreleasepool {
        NSTextStorage *textStorage = (__bridge NSTextStorage *) text_flow;
        NSLayoutManager *layoutManager = [[textStorage layoutManagers] objectAtIndex: 0];
        NSTextContainer *textContainer = [[layoutManager textContainers] objectAtIndex: 0];
        NSSize size = NSMakeSize(width, height);
        [textContainer setContainerSize: size];
    }
}


void ef_text_flow_draw(EF_Text_Flow text_flow, EF_Drawable drawable) {
    ef_drawable_make_current(drawable);
    
    @autoreleasepool {
        NSTextStorage *textStorage = (__bridge NSTextStorage *) text_flow;
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

                     NSColor *foregroundColor
                     = [attributes
                           objectForKey:
                           NSForegroundColorAttributeName];
                     foregroundColor
                     = [foregroundColor
                           colorUsingColorSpace:
                           [NSColorSpace deviceRGBColorSpace]];
                     CGFloat red, green, blue, alpha;
                     [foregroundColor getRed: &red
                              green: &green
                              blue: &blue
                              alpha: &alpha];
                     glColor4f(red, green, blue, alpha);
                 
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
                     gluTessBeginPolygon(tesselator, (__bridge void *) vertices);
                 
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
    }
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
    NSMutableArray *vertices = (__bridge NSMutableArray *) polygonContext;
    NSValue *pointValue = [vertices objectAtIndex: pointIndex];
    NSPoint point = [pointValue pointValue];
    glVertex2d(point.x, point.y);
}


EF_Text_Attributes ef_text_new_attributes() {
    @autoreleasepool {
        NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithCapacity: 8];
        return (__bridge EF_Text_Attributes) attributes;
    }
}


void ef_text_attributes_delete(EF_Text_Attributes attributes) {
    @autoreleasepool {
    }
}


EF_Font ef_text_attributes_font(EF_Text_Attributes attributes) {
    @autoreleasepool {
        EF_Font result
        = (__bridge EF_Font) [(__bridge NSMutableDictionary *) attributes
                             objectForKey: NSFontAttributeName];
        return result;
    }
}


EF_Paragraph_Style ef_text_attributes_paragraph_style(EF_Text_Attributes attributes) {
    @autoreleasepool {
        NSMutableDictionary *dictionary = (__bridge NSMutableDictionary *) attributes;
        NSParagraphStyle *immutableParagraphStyle
        = [dictionary objectForKey: NSParagraphStyleAttributeName];
        NSParagraphStyle *paragraphStyle = nil;
        if(immutableParagraphStyle) {
        paragraphStyle = [immutableParagraphStyle mutableCopyWithZone: nil];
        }
        return (__bridge EF_Paragraph_Style) paragraphStyle;
    }
}


void ef_text_attributes_foreground_color(EF_Text_Attributes attributes,
					 double *red,
					 double *green,
					 double *blue,
					 double *alpha)
{
    @autoreleasepool {
        NSMutableDictionary *dictionary = (__bridge NSMutableDictionary *) attributes;
        NSColor *color = [dictionary objectForKey: NSForegroundColorAttributeName];
        if(color) {
        if(red)
            *red = [color redComponent];
        if(green)
            *green = [color greenComponent];
        if(blue)
            *blue = [color blueComponent];
        if(alpha)
            *alpha = [color alphaComponent];
        }
    }
}


void ef_text_attributes_background_color(EF_Text_Attributes attributes,
					 double *red,
					 double *green,
					 double *blue,
					 double *alpha)
{
    @autoreleasepool {
        NSMutableDictionary *dictionary = (__bridge NSMutableDictionary *) attributes;
        NSColor *color = [dictionary objectForKey: NSBackgroundColorAttributeName];
        if(color) {
        if(red)
            *red = [color redComponent];
        if(green)
            *green = [color greenComponent];
        if(blue)
            *blue = [color blueComponent];
        if(alpha)
            *alpha = [color alphaComponent];
        }
    }
}


EF_Underline_Style ef_text_attributes_underline_style(EF_Text_Attributes attributes) {
    @autoreleasepool {
        NSMutableDictionary *dictionary = (__bridge NSMutableDictionary *) attributes;
        NSNumber *number = [dictionary objectForKey: NSUnderlineStyleAttributeName];
        EF_Underline_Style result;
        if(!number) {
        result = EF_UNDERLINE_STYLE_NONE;
        } else {
        NSInteger integer = [number integerValue];
        switch(integer) {
        case NSUnderlineStyleNone:
            result = EF_UNDERLINE_STYLE_NONE;
            break;
        case NSUnderlineStyleSingle:
            result = EF_UNDERLINE_STYLE_SINGLE;
            break;
        case NSUnderlineStyleDouble:
            result = EF_UNDERLINE_STYLE_DOUBLE;
            break;
        case NSUnderlineStyleThick:
            result = EF_UNDERLINE_STYLE_THICK;
            break;
        default:
            result = EF_UNDERLINE_STYLE_NONE;
            break;
        }
        }
        return result;
    }
}


int ef_text_attributes_underline_is_colored(EF_Text_Attributes attributes) {
    @autoreleasepool {
        NSMutableDictionary *dictionary = (__bridge NSMutableDictionary *) attributes;
        NSColor *color = [dictionary objectForKey: NSUnderlineColorAttributeName];
        int result = color ? 1 : 0;
        return result;
    }
}


void ef_text_attributes_underline_color(EF_Text_Attributes attributes,
					double *red,
					double *green,
					double *blue,
					double *alpha)
{
    @autoreleasepool {
        NSMutableDictionary *dictionary = (__bridge NSMutableDictionary *) attributes;
        NSColor *color = [dictionary objectForKey: NSUnderlineColorAttributeName];
        if(color) {
        if(red)
            *red = [color redComponent];
        if(green)
            *green = [color greenComponent];
        if(blue)
            *blue = [color blueComponent];
        if(alpha)
            *alpha = [color alphaComponent];
        }
    }
}


EF_Strikethrough_Style
  ef_text_attributes_strikethrough_style(EF_Text_Attributes attributes)
{
    @autoreleasepool {
        NSMutableDictionary *dictionary = (__bridge NSMutableDictionary *) attributes;
        NSNumber *number = [dictionary objectForKey: NSStrikethroughStyleAttributeName];
        EF_Strikethrough_Style result;
        if(!number) {
        result = EF_STRIKETHROUGH_STYLE_NONE;
        } else {
        NSInteger integer = [number integerValue];
        switch(integer) {
        case NSUnderlineStyleNone:
            result = EF_STRIKETHROUGH_STYLE_NONE;
            break;
        case NSUnderlineStyleSingle:
            result = EF_STRIKETHROUGH_STYLE_SINGLE;
            break;
        case NSUnderlineStyleDouble:
            result = EF_STRIKETHROUGH_STYLE_DOUBLE;
            break;
        case NSUnderlineStyleThick:
            result = EF_STRIKETHROUGH_STYLE_THICK;
            break;
        default:
            result = EF_STRIKETHROUGH_STYLE_NONE;
            break;
        }
        }
        return result;
    }
}


int ef_text_attributes_strikethrough_is_colored(EF_Text_Attributes attributes) {
    @autoreleasepool {
        NSMutableDictionary *dictionary = (__bridge NSMutableDictionary *) attributes;
        NSColor *color = [dictionary objectForKey: NSStrikethroughColorAttributeName];
        int result = color ? 1 : 0;
        return result;
    }
}


void ef_text_attributes_strikethrough_color(EF_Text_Attributes attributes,
					    double *red,
					    double *green,
					    double *blue,
					    double *alpha)
{
    @autoreleasepool {
        NSMutableDictionary *dictionary = (__bridge NSMutableDictionary *) attributes;
        NSColor *color = [dictionary objectForKey: NSStrikethroughColorAttributeName];
        if(color) {
        if(red)
            *red = [color redComponent];
        if(green)
            *green = [color greenComponent];
        if(blue)
            *blue = [color blueComponent];
        if(alpha)
            *alpha = [color alphaComponent];
        }
    }
}


EF_Ligature_Style ef_text_attributes_ligature_style(EF_Text_Attributes attributes) {
    @autoreleasepool {
        NSMutableDictionary *dictionary = (__bridge NSMutableDictionary *) attributes;
        NSNumber *number = [dictionary objectForKey: NSLigatureAttributeName];
        EF_Ligature_Style result;
        if(!number) {
        result = EF_LIGATURE_STYLE_STANDARD;
        } else {
        NSInteger integer = [number integerValue];
        switch(integer) {
        case 0:
            result = EF_LIGATURE_STYLE_NONE;
            break;
        case 1:
            result = EF_LIGATURE_STYLE_STANDARD;
            break;
        case 2:
            result = EF_LIGATURE_STYLE_ALL;
            break;
        default:
            result = EF_LIGATURE_STYLE_STANDARD;
            break;
        }
        }
        return result;
    }
}


double ef_text_attributes_baseline_offset(EF_Text_Attributes attributes) {
    @autoreleasepool {
        NSMutableDictionary *dictionary = (__bridge NSMutableDictionary *) attributes;
        NSNumber *number = [dictionary objectForKey: NSBaselineOffsetAttributeName];
        double result = 0.0;
        if(number)
        result = [number doubleValue];
        return result;
    }
}


int ef_text_attributes_kerning_is_default(EF_Text_Attributes attributes) {
    @autoreleasepool {
        NSMutableDictionary *dictionary = (__bridge NSMutableDictionary *) attributes;
        NSNumber *number = [dictionary objectForKey: NSKernAttributeName];
        int result = number ? 0 : 1;
        return result;
    }
}


double ef_text_attributes_kerning(EF_Text_Attributes attributes) {
    @autoreleasepool {
        NSMutableDictionary *dictionary = (__bridge NSMutableDictionary *) attributes;
        NSNumber *number = [dictionary objectForKey: NSKernAttributeName];
        double result = 0.0;
        if(number)
        result = [number doubleValue];
        return result;
    }
}


EF_Outline_Style ef_text_attributes_outline_style(EF_Text_Attributes attributes) {
    @autoreleasepool {
        NSMutableDictionary *dictionary = (__bridge NSMutableDictionary *) attributes;
        NSNumber *number = [dictionary objectForKey: NSStrokeWidthAttributeName];
        EF_Outline_Style result;
        if(!number) {
        result = EF_OUTLINE_STYLE_FILL_ONLY;
        } else {
        double value = [number doubleValue];
        if(value > 0.0) {
            result = EF_OUTLINE_STYLE_STROKE_ONLY;
        } else if(value < 0.0) {
            result = EF_OUTLINE_STYLE_STROKE_AND_FILL;
        } else {
            result = EF_OUTLINE_STYLE_FILL_ONLY;
        }
        }
        return result;
    }
}


double ef_text_attributes_stroke_width(EF_Text_Attributes attributes) {
    @autoreleasepool {
        NSMutableDictionary *dictionary = (__bridge NSMutableDictionary *) attributes;
        NSNumber *number = [dictionary objectForKey: NSStrokeWidthAttributeName];
        double result = 0.0;
        if(number)
        result = [number doubleValue];
        return result;
    }
}


int ef_text_attributes_stroke_is_colored(EF_Text_Attributes attributes) {
    @autoreleasepool {
        NSMutableDictionary *dictionary = (__bridge NSMutableDictionary *) attributes;
        NSColor *color = [dictionary objectForKey: NSStrokeColorAttributeName];
        int result = color ? 1 : 0;
        return result;
    }
}


void ef_text_attributes_stroke_color(EF_Text_Attributes attributes,
				     double *red,
				     double *green,
				     double *blue,
				     double *alpha)
{
    @autoreleasepool {
        NSMutableDictionary *dictionary = (__bridge NSMutableDictionary *) attributes;
        NSColor *color = [dictionary objectForKey: NSStrokeColorAttributeName];
        if(color) {
        if(red)
            *red = [color redComponent];
        if(green)
            *green = [color greenComponent];
        if(blue)
            *blue = [color blueComponent];
        if(alpha)
            *alpha = [color alphaComponent];
        }
    }
}


double ef_text_attributes_obliqueness(EF_Text_Attributes attributes) {
    @autoreleasepool {
        NSMutableDictionary *dictionary = (__bridge NSMutableDictionary *) attributes;
        NSNumber *number = [dictionary objectForKey: NSObliquenessAttributeName];
        double result = 0.0;
        if(number)
        result = [number doubleValue];
        return result;
    }
}


double ef_text_attributes_expansion(EF_Text_Attributes attributes) {
    @autoreleasepool {
        NSMutableDictionary *dictionary = (__bridge NSMutableDictionary *) attributes;
        NSNumber *number = [dictionary objectForKey: NSExpansionAttributeName];
        double result = 0.0;
        if(number)
        result = [number doubleValue];
        return result;
    }
}


void ef_text_attributes_set_font(EF_Text_Attributes attributes, EF_Font font) {
    @autoreleasepool {
        [(__bridge NSMutableDictionary *) attributes
                     setObject: (__bridge NSFont *) font
                     forKey: NSFontAttributeName];
    }
}


void ef_text_attributes_set_paragraph_style(EF_Text_Attributes attributes,
					    EF_Paragraph_Style paragraph_style)
{
    @autoreleasepool {
        NSMutableDictionary *dictionary = (__bridge NSMutableDictionary *) attributes;
        [dictionary setObject: (__bridge NSMutableParagraphStyle *) paragraph_style
            forKey: NSParagraphStyleAttributeName];
    }
}


void ef_text_attributes_set_foreground_color(EF_Text_Attributes attributes,
					     double red,
					     double green,
					     double blue,
					     double alpha)
{
    @autoreleasepool {
        NSColor *color = [NSColor colorWithDeviceRed: red
                      green: green
                      blue: blue
                      alpha: alpha];
        [(__bridge NSMutableDictionary *) attributes
                     setObject: color
                     forKey: NSForegroundColorAttributeName];
    }
}


void ef_text_attributes_set_background_color(EF_Text_Attributes attributes,
					     double red,
					     double green,
					     double blue,
					     double alpha)
{
    @autoreleasepool {
        NSColor *color = [NSColor colorWithDeviceRed: red
                      green: green
                      blue: blue
                      alpha: alpha];
        [(__bridge NSMutableDictionary *) attributes
                     setObject: color
                     forKey: NSBackgroundColorAttributeName];
    }
}


void ef_text_attributes_set_underline_style(EF_Text_Attributes attributes,
					    EF_Underline_Style underline_style)
{
    @autoreleasepool {
        NSMutableDictionary *dictionary = (__bridge NSMutableDictionary *) attributes;
        NSInteger integer;
        switch(underline_style) {
        case EF_UNDERLINE_STYLE_NONE:
        integer = NSUnderlineStyleNone;
        break;
        case EF_UNDERLINE_STYLE_SINGLE:
        integer = NSUnderlineStyleSingle;
        break;
        case EF_UNDERLINE_STYLE_DOUBLE:
        integer = NSUnderlineStyleDouble;
        break;
        case EF_UNDERLINE_STYLE_THICK:
        integer = NSUnderlineStyleThick;
        break;
        default:
        integer = NSUnderlineStyleNone;
        break;
        }
        NSNumber *number = [NSNumber numberWithInteger: integer];
        [dictionary setObject: number forKey: NSUnderlineStyleAttributeName];
    }
}


void ef_text_attributes_set_underline_color(EF_Text_Attributes attributes,
					    double red,
					    double green,
					    double blue,
					    double alpha)
{
    @autoreleasepool {
        NSColor *color = [NSColor colorWithDeviceRed: red
                      green: green
                      blue: blue
                      alpha: alpha];
        [(__bridge NSMutableDictionary *) attributes
                     setObject: color
                     forKey: NSUnderlineColorAttributeName];
    }
}


void
  ef_text_attributes_set_strikethrough_style(EF_Text_Attributes attributes,
					     EF_Strikethrough_Style strikethrough_style)
{
    @autoreleasepool {
        NSMutableDictionary *dictionary = (__bridge NSMutableDictionary *) attributes;
        NSInteger integer;
        switch(strikethrough_style) {
        case EF_STRIKETHROUGH_STYLE_NONE:
        integer = NSUnderlineStyleNone;
        break;
        case EF_STRIKETHROUGH_STYLE_SINGLE:
        integer = NSUnderlineStyleSingle;
        break;
        case EF_STRIKETHROUGH_STYLE_DOUBLE:
        integer = NSUnderlineStyleDouble;
        break;
        case EF_STRIKETHROUGH_STYLE_THICK:
        integer = NSUnderlineStyleThick;
        break;
        default:
        integer = NSUnderlineStyleNone;
        break;
        }
        NSNumber *number = [NSNumber numberWithInteger: integer];
        [dictionary setObject: number forKey: NSStrikethroughStyleAttributeName];
    }
}


void ef_text_attributes_set_strikethrough_color(EF_Text_Attributes attributes,
						double red,
						double green,
						double blue,
						double alpha)
{
    @autoreleasepool {
        NSColor *color = [NSColor colorWithDeviceRed: red
                      green: green
                      blue: blue
                      alpha: alpha];
        [(__bridge NSMutableDictionary *) attributes
                     setObject: color
                     forKey: NSStrikethroughColorAttributeName];
    }
}


void ef_text_attributes_set_ligature_style(EF_Text_Attributes attributes,
					   EF_Ligature_Style ligature_style)
{
    @autoreleasepool {
        NSMutableDictionary *dictionary = (__bridge NSMutableDictionary *) attributes;
        NSInteger integer;
        switch(ligature_style) {
        case EF_LIGATURE_STYLE_NONE:
        integer = 0;
        break;
        case EF_LIGATURE_STYLE_STANDARD:
        integer = 1;
        break;
        case EF_LIGATURE_STYLE_ALL:
        integer = 2;
        break;
        default:
        integer = 0;
        break;
        }
        NSNumber *number = [NSNumber numberWithInteger: integer];
        [dictionary setObject: number forKey: NSLigatureAttributeName];
    }
}


void ef_text_attributes_set_baseline_offset(EF_Text_Attributes attributes,
					    double baseline_offset)
{
    @autoreleasepool {
        NSMutableDictionary *dictionary = (__bridge NSMutableDictionary *) attributes;
        NSNumber *number = [NSNumber numberWithDouble: baseline_offset];
        [dictionary setObject: number forKey: NSObliquenessAttributeName];
    }
}


void ef_text_attributes_set_kerning(EF_Text_Attributes attributes,
				    double kerning)
{
    @autoreleasepool {
        NSMutableDictionary *dictionary = (__bridge NSMutableDictionary *) attributes;
        NSNumber *number = [NSNumber numberWithDouble: kerning];
        [dictionary setObject: number forKey: NSKernAttributeName];
    }
}


void ef_text_attributes_set_outline_style(EF_Text_Attributes attributes,
					  EF_Outline_Style outline_style)
{
    @autoreleasepool {
        NSMutableDictionary *dictionary = (__bridge NSMutableDictionary *) attributes;
        NSNumber *number = [dictionary objectForKey: NSStrokeWidthAttributeName];
        double newValue;
        if(number) {
        double oldValue = [number doubleValue];
        switch(outline_style) {
        case EF_OUTLINE_STYLE_FILL_ONLY:
        default:
            newValue = 0.0;
            break;
        case EF_OUTLINE_STYLE_STROKE_ONLY:
            if(oldValue == 0.0)
            newValue = 3.0;
            else
            newValue = abs(oldValue);
            break;
        case EF_OUTLINE_STYLE_STROKE_AND_FILL:
            if(oldValue == 0.0)
            newValue = -3.0;
            else
            newValue = -abs(oldValue);
            break;
        }
        } else {
        switch(outline_style) {
        case EF_OUTLINE_STYLE_FILL_ONLY:
        default:
            newValue = 0.0;
            break;
        case EF_OUTLINE_STYLE_STROKE_ONLY:
            newValue = 3.0;
            break;
        case EF_OUTLINE_STYLE_STROKE_AND_FILL:
            newValue = -3.0;
            break;
        }
        }
        [dictionary setObject: [NSNumber numberWithDouble: newValue]
            forKey: NSStrokeWidthAttributeName];
    }
}


void ef_text_attributes_set_stroke_width(EF_Text_Attributes attributes,
					 double stroke_width)
{
    @autoreleasepool {
        NSMutableDictionary *dictionary = (__bridge NSMutableDictionary *) attributes;
        NSNumber *number = [dictionary objectForKey: NSStrokeWidthAttributeName];
        double newValue;
        if(number) {
        double oldValue = [number doubleValue];
        if(oldValue > 0.0) {
            newValue = abs(stroke_width);
        } else if(oldValue < 0.0) {
            newValue = -abs(stroke_width);
        } else {
            newValue = abs(stroke_width);
        }
        } else {
        newValue = abs(stroke_width);
        }
        [dictionary setObject: [NSNumber numberWithDouble: newValue]
            forKey: NSStrokeWidthAttributeName];
    }
}


void ef_text_attributes_set_stroke_color(EF_Text_Attributes attributes,
				         double red,
					 double green,
					 double blue,
					 double alpha)
{
    @autoreleasepool {
        NSColor *color = [NSColor colorWithDeviceRed: red
                      green: green
                      blue: blue
                      alpha: alpha];
        [(__bridge NSMutableDictionary *) attributes
                     setObject: color
                     forKey: NSStrokeColorAttributeName];
    }
}


void ef_text_attributes_set_obliqueness(EF_Text_Attributes attributes,
					double obliqueness)
{
    @autoreleasepool {
        NSMutableDictionary *dictionary = (__bridge NSMutableDictionary *) attributes;
        NSNumber *number = [NSNumber numberWithDouble: obliqueness];
        [dictionary setObject: number forKey: NSObliquenessAttributeName];
    }
}


void ef_text_attributes_set_expansion(EF_Text_Attributes attributes,
				      double expansion)
{
    @autoreleasepool {
        NSMutableDictionary *dictionary = (__bridge NSMutableDictionary *) attributes;
        NSNumber *number = [NSNumber numberWithDouble: expansion];
        [dictionary setObject: number forKey: NSExpansionAttributeName];
    }
}


void ef_text_attributes_unset_font(EF_Text_Attributes attributes) {
    @autoreleasepool {
        NSMutableDictionary *dictionary = (__bridge NSMutableDictionary *) attributes;
        [dictionary removeObjectForKey: NSFontAttributeName];
    }
}


void ef_text_attributes_unset_paragraph_style(EF_Text_Attributes attributes) {
    @autoreleasepool {
        NSMutableDictionary *dictionary = (__bridge NSMutableDictionary *) attributes;
        [dictionary removeObjectForKey: NSParagraphStyleAttributeName];
    }
}


void ef_text_attributes_unset_foreground_color(EF_Text_Attributes attributes) {
    @autoreleasepool {
        NSMutableDictionary *dictionary = (__bridge NSMutableDictionary *) attributes;
        [dictionary removeObjectForKey: NSForegroundColorAttributeName];
    }
}


void ef_text_attributes_unset_background_color(EF_Text_Attributes attributes) {
    @autoreleasepool {
        NSMutableDictionary *dictionary = (__bridge NSMutableDictionary *) attributes;
        [dictionary removeObjectForKey: NSBackgroundColorAttributeName];
    }
}


void ef_text_attributes_unset_underline_style(EF_Text_Attributes attributes) {
    @autoreleasepool {
        NSMutableDictionary *dictionary = (__bridge NSMutableDictionary *) attributes;
        [dictionary removeObjectForKey: NSUnderlineStyleAttributeName];
    }
}


void ef_text_attributes_unset_underline_color(EF_Text_Attributes attributes) {
    @autoreleasepool {
        NSMutableDictionary *dictionary = (__bridge NSMutableDictionary *) attributes;
        [dictionary removeObjectForKey: NSUnderlineColorAttributeName];
    }
}


void ef_text_attributes_unset_strikethrough_style(EF_Text_Attributes attributes) {
    @autoreleasepool {
        NSMutableDictionary *dictionary = (__bridge NSMutableDictionary *) attributes;
        [dictionary removeObjectForKey: NSStrikethroughStyleAttributeName];
    }
}


void ef_text_attributes_unset_strikethrough_color(EF_Text_Attributes attributes) {
    @autoreleasepool {
        NSMutableDictionary *dictionary = (__bridge NSMutableDictionary *) attributes;
        [dictionary removeObjectForKey: NSStrikethroughColorAttributeName];
    }
}


void ef_text_attributes_unset_ligature_style(EF_Text_Attributes attributes) {
    @autoreleasepool {
        NSMutableDictionary *dictionary = (__bridge NSMutableDictionary *) attributes;
        [dictionary removeObjectForKey: NSLigatureAttributeName];
    }
}


void ef_text_attributes_unset_baseline_offset(EF_Text_Attributes attributes) {
    @autoreleasepool {
        NSMutableDictionary *dictionary = (__bridge NSMutableDictionary *) attributes;
        [dictionary removeObjectForKey: NSBaselineOffsetAttributeName];
    }
}


void ef_text_attributes_unset_kerning(EF_Text_Attributes attributes) {
    @autoreleasepool {
        NSMutableDictionary *dictionary = (__bridge NSMutableDictionary *) attributes;
        [dictionary removeObjectForKey: NSKernAttributeName];
    }
}


void ef_text_attributes_unset_outline_style(EF_Text_Attributes attributes) {
    @autoreleasepool {
        NSMutableDictionary *dictionary = (__bridge NSMutableDictionary *) attributes;
        [dictionary removeObjectForKey: NSStrokeWidthAttributeName];
    }
}


void ef_text_attributes_unset_stroke_width(EF_Text_Attributes attributes) {
    @autoreleasepool {
        NSMutableDictionary *dictionary = (__bridge NSMutableDictionary *) attributes;
        [dictionary removeObjectForKey: NSStrokeWidthAttributeName];
    }
}


void ef_text_attributes_unset_stroke_color(EF_Text_Attributes attributes) {
    @autoreleasepool {
        NSMutableDictionary *dictionary = (__bridge NSMutableDictionary *) attributes;
        [dictionary removeObjectForKey: NSStrokeColorAttributeName];
    }
}


void ef_text_attributes_unset_obliqueness(EF_Text_Attributes attributes) {
    @autoreleasepool {
        NSMutableDictionary *dictionary = (__bridge NSMutableDictionary *) attributes;
        [dictionary removeObjectForKey: NSObliquenessAttributeName];
    }
}


void ef_text_attributes_unset_expansion(EF_Text_Attributes attributes) {
    @autoreleasepool {
        NSMutableDictionary *dictionary = (__bridge NSMutableDictionary *) attributes;
        [dictionary removeObjectForKey: NSExpansionAttributeName];
    }
}


EF_Paragraph_Style ef_text_new_paragraph_style() {
    @autoreleasepool {
        NSMutableParagraphStyle *paragraphStyle
        = [[NSParagraphStyle defaultParagraphStyle] mutableCopyWithZone: nil];
        return (__bridge EF_Paragraph_Style) paragraphStyle;
    }
}


void ef_paragraph_style_delete(EF_Paragraph_Style paragraph_style) {
    @autoreleasepool {
    }
}


EF_Paragraph_Alignment ef_paragraph_style_alignment(EF_Paragraph_Style paragraph_style) {
    @autoreleasepool {
        NSMutableParagraphStyle *paragraphStyle
        = (__bridge NSMutableParagraphStyle *) paragraph_style;
        NSTextAlignment alignment = [paragraphStyle alignment];
        EF_Paragraph_Alignment result;
        switch(alignment) {
        case NSLeftTextAlignment:
        default:
        result = EF_PARAGRAPH_ALIGNMENT_LEFT;
        break;
        case NSRightTextAlignment:
        result = EF_PARAGRAPH_ALIGNMENT_RIGHT;
        break;
        case NSCenterTextAlignment:
        result = EF_PARAGRAPH_ALIGNMENT_CENTER;
        break;
        case NSJustifiedTextAlignment:
        result = EF_PARAGRAPH_ALIGNMENT_JUSTIFIED;
        break;
        }
        return result;
    }
}


double ef_paragraph_style_first_line_head_indent(EF_Paragraph_Style paragraph_style) {
    @autoreleasepool {
        double result = [(__bridge NSMutableParagraphStyle *) paragraph_style firstLineHeadIndent];
        return result;
    }
}


double ef_paragraph_style_head_indent(EF_Paragraph_Style paragraph_style) {
    @autoreleasepool {
        double result = [(__bridge NSMutableParagraphStyle *) paragraph_style headIndent];
        return result;
    }
}


double ef_paragraph_style_tail_indent(EF_Paragraph_Style paragraph_style) {
    @autoreleasepool {
        double result = [(__bridge NSMutableParagraphStyle *) paragraph_style tailIndent];
        return result;
    }
}


double ef_paragraph_style_line_height_multiple(EF_Paragraph_Style paragraph_style) {
    @autoreleasepool {
        double result = [(__bridge NSMutableParagraphStyle *) paragraph_style lineHeightMultiple];
        return result;
    }
}


double ef_paragraph_style_minimum_line_height(EF_Paragraph_Style paragraph_style) {
    @autoreleasepool {
        double result = [(__bridge NSMutableParagraphStyle *) paragraph_style minimumLineHeight];
        return result;
    }
}


int ef_paragraph_style_has_maximum_line_height(EF_Paragraph_Style paragraph_style) {
    @autoreleasepool {
        double result = [(__bridge NSMutableParagraphStyle *) paragraph_style maximumLineHeight];
        return (result == 0.0) ? 0 : 1;
    }
}


double ef_paragraph_style_maximum_line_height(EF_Paragraph_Style paragraph_style) {
    @autoreleasepool {
        double result = [(__bridge NSMutableParagraphStyle *) paragraph_style maximumLineHeight];
        return result;
    }
}


double ef_paragraph_style_line_spacing(EF_Paragraph_Style paragraph_style) {
    @autoreleasepool {
        double result = [(__bridge NSMutableParagraphStyle *) paragraph_style lineSpacing];
        return result;
    }
}


double ef_paragraph_style_paragraph_spacing(EF_Paragraph_Style paragraph_style) {
    @autoreleasepool {
        double result = [(__bridge NSMutableParagraphStyle *) paragraph_style paragraphSpacing];
        return result;
    }
}


double ef_paragraph_style_paragraph_spacing_before(EF_Paragraph_Style paragraph_style) {
    @autoreleasepool {
        double result = [(__bridge NSMutableParagraphStyle *) paragraph_style paragraphSpacingBefore];
        return result;
    }
}


void ef_paragraph_style_set_alignment(EF_Paragraph_Style paragraph_style,
				      EF_Paragraph_Alignment paragraph_alignment)
{
    @autoreleasepool {
        NSMutableParagraphStyle *paragraphStyle
        = (__bridge NSMutableParagraphStyle *) paragraph_style;
        NSTextAlignment alignment;
        switch(paragraph_alignment) {
        case EF_PARAGRAPH_ALIGNMENT_LEFT:
        default:
        alignment = NSLeftTextAlignment;
        break;
        case EF_PARAGRAPH_ALIGNMENT_RIGHT:
        alignment = NSRightTextAlignment;
        break;
        case EF_PARAGRAPH_ALIGNMENT_CENTER:
        alignment = NSCenterTextAlignment;
        break;
        case EF_PARAGRAPH_ALIGNMENT_JUSTIFIED:
        alignment = NSJustifiedTextAlignment;
        break;
        }
        [paragraphStyle setAlignment: alignment];
    }
}


void ef_paragraph_style_set_first_line_head_indent(EF_Paragraph_Style paragraph_style,
						   double first_line_head_indent)
{
    @autoreleasepool {
        [(__bridge NSMutableParagraphStyle *) paragraph_style
                     setFirstLineHeadIndent: first_line_head_indent];
    }
}


void ef_paragraph_style_set_head_indent(EF_Paragraph_Style paragraph_style,
					double head_indent)
{
    @autoreleasepool {
        [(__bridge NSMutableParagraphStyle *) paragraph_style
                     setHeadIndent: head_indent];
    }
}


void ef_paragraph_style_set_tail_indent(EF_Paragraph_Style paragraph_style,
					double tail_indent)
{
    @autoreleasepool {
        [(__bridge NSMutableParagraphStyle *) paragraph_style
                     setTailIndent: tail_indent];
    }
}


void ef_paragraph_style_set_line_height_multiple(EF_Paragraph_Style paragraph_style,
						 double line_height_multiple)
{
    @autoreleasepool {
        [(__bridge NSMutableParagraphStyle *) paragraph_style
                     setLineHeightMultiple: line_height_multiple];
    }
}


void ef_paragraph_style_set_minimum_line_height(EF_Paragraph_Style paragraph_style,
						double minimum_line_height)
{
    @autoreleasepool {
        [(__bridge NSMutableParagraphStyle *) paragraph_style
                     setMinimumLineHeight: minimum_line_height];
    }
}


void ef_paragraph_style_set_no_maximum_line_height(EF_Paragraph_Style paragraph_style) {
    @autoreleasepool {
        [(__bridge NSMutableParagraphStyle *) paragraph_style
                     setMaximumLineHeight: 0.0];
    }
}


void ef_paragraph_style_set_maximum_line_height(EF_Paragraph_Style paragraph_style,
						double maximum_line_height)
{
    @autoreleasepool {
        [(__bridge NSMutableParagraphStyle *) paragraph_style
                     setMaximumLineHeight: maximum_line_height];
    }
}


void ef_paragraph_style_set_line_spacing(EF_Paragraph_Style paragraph_style,
					 double line_spacing)
{
    @autoreleasepool {
        [(__bridge NSMutableParagraphStyle *) paragraph_style
                     setLineSpacing: line_spacing];
    }
}


void ef_paragraph_style_set_paragraph_spacing(EF_Paragraph_Style paragraph_style,
					      double paragraph_spacing)
{
    @autoreleasepool {
        [(__bridge NSMutableParagraphStyle *) paragraph_style
                     setParagraphSpacing: paragraph_spacing];
    }
}


void ef_paragraph_style_set_paragraph_spacing_before(EF_Paragraph_Style paragraph_style,
						     double paragraph_spacing_before)
{
    @autoreleasepool {
        [(__bridge NSMutableParagraphStyle *) paragraph_style
                     setParagraphSpacingBefore: paragraph_spacing_before];
    }
}

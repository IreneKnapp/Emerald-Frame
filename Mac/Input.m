//
//  Input.m
//  Emerald Frame
//
//  Created by Dan Knapp on 10/12/09.
//  Copyright 2009 Dan Knapp. All rights reserved.
//

#import <math.h>
#import <string.h>

#import "Emerald-Frame.h"
#import "Drawable.h"


void ef_input_set_key_down_callback(EF_Drawable drawable,
				    void (*callback)(EF_Drawable drawable,
						     EF_Event event,
						     void *context),
				    void *context)
{
    [(Drawable *) drawable setKeyDownCallback: callback context: context];
}


void ef_input_set_key_up_callback(EF_Drawable drawable,
				  void (*callback)(EF_Drawable drawable,
						   EF_Event event,
						   void *context),
				  void *context)
{
    [(Drawable *) drawable setKeyUpCallback: callback context: context];
}


void ef_input_set_mouse_down_callback(EF_Drawable drawable,
				      void (*callback)(EF_Drawable drawable,
						       EF_Event event,
						       void *context),
				      void *context)
{
    [(Drawable *) drawable setMouseDownCallback: callback context: context];
}


void ef_input_set_mouse_up_callback(EF_Drawable drawable,
				    void (*callback)(EF_Drawable drawable,
						     EF_Event event,
						     void *context),
				    void *context)
{
    [(Drawable *) drawable setMouseUpCallback: callback context: context];
}


void ef_input_set_mouse_move_callback(EF_Drawable drawable,
				      void (*callback)(EF_Drawable drawable,
						       EF_Event event,
						       void *context),
				      void *context)
{
    [(Drawable *) drawable setMouseMoveCallback: callback context: context];
}


void ef_input_set_mouse_enter_callback(EF_Drawable drawable,
				       void (*callback)(EF_Drawable drawable,
							EF_Event event,
							void *context),
				       void *context)
{
    [(Drawable *) drawable setMouseEnterCallback: callback context: context];
}


void ef_input_set_mouse_exit_callback(EF_Drawable drawable,
				      void (*callback)(EF_Drawable drawable,
						       EF_Event event,
						       void *context),
				      void *context)
{
    [(Drawable *) drawable setMouseExitCallback: callback context: context];
}


uint64_t ef_event_timestamp(EF_Event event) {
    return floor(1000.0 * [(NSEvent *) event timestamp]);
}


EF_Modifiers ef_event_modifiers(EF_Event event) {
    NSUInteger osModifiers = [(NSEvent *) event modifierFlags];
    EF_Modifiers efModifiers = 0;
    
    if(osModifiers & NSAlphaShiftKeyMask)
	efModifiers |= EF_MODIFIER_CAPS_LOCK;
    if(osModifiers & NSShiftKeyMask)
	efModifiers |= EF_MODIFIER_SHIFT;
    if(osModifiers & NSControlKeyMask)
	efModifiers |= EF_MODIFIER_CONTROL;
    if(osModifiers & NSAlternateKeyMask)
	efModifiers |= EF_MODIFIER_ALT;
    if(osModifiers & NSCommandKeyMask)
	efModifiers |= EF_MODIFIER_COMMAND;
    
    return efModifiers;
}


EF_Keycode ef_event_keycode(EF_Event event) {
    return [(NSEvent *) event keyCode];
}


utf8 *ef_event_string(EF_Event event) {
    static utf8 *result_buffer = NULL;
    static size_t result_buffer_size = 0;

    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSString *string = [(NSEvent *) event characters];
    
    size_t required_buffer_size
	= [string lengthOfBytesUsingEncoding: NSUTF8StringEncoding] + 1;
    while(required_buffer_size > result_buffer_size) {
	if(result_buffer_size == 0)
	    result_buffer_size = 8;
	else
	    result_buffer_size *= 2;

	result_buffer = realloc(result_buffer, result_buffer_size * sizeof(uint8_t));
    }
    NSUInteger usedLength;
    [string getBytes: result_buffer
	    maxLength: result_buffer_size
	    usedLength: &usedLength
	    encoding: NSUTF8StringEncoding
	    options: 0
	    range: NSMakeRange(0, [string length])
	    remainingRange: NULL];
    result_buffer[usedLength] = '\0';
    
    [pool drain];

    return result_buffer;
}


int ef_event_button_number(EF_Event event) {
    return [(NSEvent *) event buttonNumber];
}


int ef_event_click_count(EF_Event event) {
    return [(NSEvent *) event clickCount];
}


utf8 *ef_input_key_name(EF_Keycode keycode) {
    switch(keycode) {
    case 0x7E: return (utf8 *) "cursor up";
    case 0x7D: return (utf8 *) "cursor down";
    case 0x7B: return (utf8 *) "cursor left";
    case 0x7C: return (utf8 *) "cursor right";
    case 0x33: return (utf8 *) "backspace";
    case 0x30: return (utf8 *) "tab";
    case 0x24: return (utf8 *) "return";
    case 0x35: return (utf8 *) "escape";
    case 0x31: return (utf8 *) "space";
    case 0x73: return (utf8 *) "home";
    case 0x77: return (utf8 *) "end";
    case 0x74: return (utf8 *) "page up";
    case 0x79: return (utf8 *) "page down";
    case 0x00: return (utf8 *) "a";
    case 0x0B: return (utf8 *) "b";
    case 0x08: return (utf8 *) "c";
    case 0x02: return (utf8 *) "d";
    case 0x0E: return (utf8 *) "e";
    case 0x03: return (utf8 *) "f";
    case 0x05: return (utf8 *) "g";
    case 0x04: return (utf8 *) "h";
    case 0x22: return (utf8 *) "i";
    case 0x26: return (utf8 *) "j";
    case 0x28: return (utf8 *) "k";
    case 0x25: return (utf8 *) "l";
    case 0x2E: return (utf8 *) "m";
    case 0x2D: return (utf8 *) "n";
    case 0x1F: return (utf8 *) "o";
    case 0x23: return (utf8 *) "p";
    case 0x0C: return (utf8 *) "q";
    case 0x0F: return (utf8 *) "r";
    case 0x01: return (utf8 *) "s";
    case 0x11: return (utf8 *) "t";
    case 0x20: return (utf8 *) "u";
    case 0x09: return (utf8 *) "v";
    case 0x0D: return (utf8 *) "w";
    case 0x07: return (utf8 *) "x";
    case 0x10: return (utf8 *) "y";
    case 0x06: return (utf8 *) "z";
    case 0x1D: return (utf8 *) "0";
    case 0x12: return (utf8 *) "1";
    case 0x13: return (utf8 *) "2";
    case 0x14: return (utf8 *) "3";
    case 0x15: return (utf8 *) "4";
    case 0x17: return (utf8 *) "5";
    case 0x16: return (utf8 *) "6";
    case 0x1A: return (utf8 *) "7";
    case 0x1C: return (utf8 *) "8";
    case 0x19: return (utf8 *) "9";
    case 0x7A: return (utf8 *) "F1";
    case 0x78: return (utf8 *) "F2";
    case 0x63: return (utf8 *) "F3";
    case 0x76: return (utf8 *) "F4";
    case 0x60: return (utf8 *) "F5";
    case 0x61: return (utf8 *) "F6";
    case 0x62: return (utf8 *) "F7";
    case 0x64: return (utf8 *) "F8"; // Untested
    case 0x65: return (utf8 *) "F9"; // Untested
    case 0x6D: return (utf8 *) "F10"; // Untested
    case 0x67: return (utf8 *) "F11"; // Untested
    case 0x6F: return (utf8 *) "F12"; // Untested
    default: return NULL;
    }
}


EF_Keycode ef_input_keycode_by_name(utf8 *name) {
    if(!strcmp((char *) name, "cursor up")) return 0x7E;
    if(!strcmp((char *) name, "cursor down")) return 0x7D;
    if(!strcmp((char *) name, "cursor left")) return 0x7B;
    if(!strcmp((char *) name, "cursor right")) return 0x7C;
    if(!strcmp((char *) name, "backspace")) return 0x33;
    if(!strcmp((char *) name, "tab")) return 0x30;
    if(!strcmp((char *) name, "return")) return 0x24;
    if(!strcmp((char *) name, "escape")) return 0x35;
    if(!strcmp((char *) name, "space")) return 0x31;
    if(!strcmp((char *) name, "tab")) return 0x30;
    if(!strcmp((char *) name, "home")) return 0x73;
    if(!strcmp((char *) name, "end")) return 0x77;
    if(!strcmp((char *) name, "page up")) return 0x74;
    if(!strcmp((char *) name, "page down")) return 0x79;
    if(!strcmp((char *) name, "a")) return 0x00;
    if(!strcmp((char *) name, "b")) return 0x0B;
    if(!strcmp((char *) name, "c")) return 0x08;
    if(!strcmp((char *) name, "d")) return 0x02;
    if(!strcmp((char *) name, "e")) return 0x0E;
    if(!strcmp((char *) name, "f")) return 0x03;
    if(!strcmp((char *) name, "g")) return 0x05;
    if(!strcmp((char *) name, "h")) return 0x04;
    if(!strcmp((char *) name, "i")) return 0x22;
    if(!strcmp((char *) name, "j")) return 0x26;
    if(!strcmp((char *) name, "k")) return 0x28;
    if(!strcmp((char *) name, "l")) return 0x25;
    if(!strcmp((char *) name, "m")) return 0x2E;
    if(!strcmp((char *) name, "n")) return 0x2D;
    if(!strcmp((char *) name, "o")) return 0x1F;
    if(!strcmp((char *) name, "p")) return 0x23;
    if(!strcmp((char *) name, "q")) return 0x0C;
    if(!strcmp((char *) name, "r")) return 0x0F;
    if(!strcmp((char *) name, "s")) return 0x01;
    if(!strcmp((char *) name, "t")) return 0x11;
    if(!strcmp((char *) name, "u")) return 0x20;
    if(!strcmp((char *) name, "v")) return 0x09;
    if(!strcmp((char *) name, "w")) return 0x0D;
    if(!strcmp((char *) name, "x")) return 0x07;
    if(!strcmp((char *) name, "y")) return 0x10;
    if(!strcmp((char *) name, "z")) return 0x06;
    if(!strcmp((char *) name, "0")) return 0x1D;
    if(!strcmp((char *) name, "1")) return 0x12;
    if(!strcmp((char *) name, "2")) return 0x13;
    if(!strcmp((char *) name, "3")) return 0x14;
    if(!strcmp((char *) name, "4")) return 0x15;
    if(!strcmp((char *) name, "5")) return 0x17;
    if(!strcmp((char *) name, "6")) return 0x16;
    if(!strcmp((char *) name, "7")) return 0x1A;
    if(!strcmp((char *) name, "8")) return 0x1C;
    if(!strcmp((char *) name, "9")) return 0x19;
    if(!strcmp((char *) name, "F1")) return 0x7A;
    if(!strcmp((char *) name, "F2")) return 0x78;
    if(!strcmp((char *) name, "F3")) return 0x63;
    if(!strcmp((char *) name, "F4")) return 0x76;
    if(!strcmp((char *) name, "F5")) return 0x60;
    if(!strcmp((char *) name, "F6")) return 0x61;
    if(!strcmp((char *) name, "F7")) return 0x62;
    if(!strcmp((char *) name, "F8")) return 0x64; // Untested
    if(!strcmp((char *) name, "F9")) return 0x65; // Untested
    if(!strcmp((char *) name, "F10")) return 0x6D; // Untested
    if(!strcmp((char *) name, "F11")) return 0x67; // Untested
    if(!strcmp((char *) name, "F12")) return 0x6F; // Untested
    return -1;
}


utf8 *ef_input_keycode_string(EF_Keycode keycode,
			      EF_Modifiers modifiers,
			      EF_Dead_Key_State *dead_key_state)
{
    /*
    static utf8 result_buffer[256];
    
    OSStatus error;

    NSUInteger osModifiers = 0;
    if(modifiers & EF_MODIFIER_CAPS_LOCK)
	osModifiers |= NSAlphaShiftKeyMask;
    if(modifiers & EF_MODIFIER_SHIFT)
	osModifiers |= NSShiftKeyMask;
    if(modifiers & EF_MODIFIER_CONTROL)
	osModifiers |= NSControlKeyMask;
    if(modifiers & EF_MODIFIER_ALT)
	osModifiers |= NSAlternateKeyMask;
    if(modifiers & EF_MODIFIER_COMMAND)
	osModifiers |= NSCommandKeyMask;

    uint32_t keyboardType = LMGetKbdType();

    size_t result_length;
    error = UCKeyTranslate(NULL,
			   keycode,
			   kUCKeyActionDown,
			   osModifiers,
			   keyboardType,
			   0,
			   dead_key_state,
			   sizeof(result_buffer) - 1,
			   &result_length,
			   result_buffer);
    result_buffer[result_length] = '\0';
    
    return result_buffer;
    */
    return NULL;
}


int32_t ef_event_mouse_x(EF_Event event) {
    return floorf([(NSEvent *) event locationInWindow].x);
}


int32_t ef_event_mouse_y(EF_Event event) {
    return floorf([(NSEvent *) event locationInWindow].y);
}

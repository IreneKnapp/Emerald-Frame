#include "Emerald-Frame.h"


size_t utf8_len(utf8 *string) {
    size_t result;
    for(result = 0; string[result] != '\0'; result++);
    return result;
}


void utf8_cpy(utf8 *a, utf8 *b) {
    size_t i;
    for(i = 0; b[i]; i++)
	a[i] = b[i];
    a[i] = '\0';
}


utf16 *utf8_to_utf16(utf8 *in) {
    size_t length = utf8_len(in);
    utf16 *out = malloc((length+1)*sizeof(utf16));
    for(size_t i = 0; i <= length; i++)
	out[i] = in[i];
    return out;
}


utf8 *utf16_to_utf8(utf16 *in) {
    size_t out_size = 8;
    utf8 *out = malloc(out_size*sizeof(utf8));

    size_t out_point = 0;
    for(size_t in_point = 0; in[in_point]; in_point++) {
	if(out_point == out_size) {
	    out_size *= 2;
	    out = realloc(out, out_size*sizeof(utf8));
	}
	out[out_point] = in[in_point];
	out_point++;
    }
    if(out_point == out_size) {
	out_size *= 2;
	out = realloc(out, out_size*sizeof(utf8));
    }
    out[out_point] = '\0';
    
    return out;
}

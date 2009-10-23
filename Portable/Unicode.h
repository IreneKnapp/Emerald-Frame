#ifndef UNICODE_H
#define UNICODE_H

#include "Emerald-Frame.h"


size_t utf8_len(utf8 *string);
void utf8_cpy(utf8 *a, utf8 *b);

size_t utf16_len(utf16 *string);

utf16 *utf8_to_utf16(utf8 *in);
utf8 *utf16_to_utf8(utf16 *in);

#endif

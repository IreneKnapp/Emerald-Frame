#include <string.h>

#include "Emerald-Frame.h"


extern EF_Error ef_internal_portable_audio_load_sound_file(utf8 *filename,
							   ALuint id);
extern EF_Error ef_internal_portable_audio_load_sound_memory(uint8_t *data,
							     size_t size,
							     ALuint id);


EF_Error ef_internal_audio_init() {
    return 0;
}


EF_Error ef_audio_load_sound_file(utf8 *filename, ALuint id) {
    return ef_internal_portable_audio_load_sound_file(filename, id);
}


EF_Error ef_audio_load_sound_memory(uint8_t *data, size_t size, ALuint id) {
    return ef_internal_portable_audio_load_sound_memory(data, size, id);
}

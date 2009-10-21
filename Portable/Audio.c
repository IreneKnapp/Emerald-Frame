#include "Emerald-Frame.h"
#include <math.h>

#define M_PI 3.14159


EF_Error ef_internal_portable_audio_load_sound_file(utf8 *filename,
						    ALuint id)
{
    int wave_length = 44100 / 261;
    wave_length *= 2;
    int data_length = 44100 / 20;
    data_length -= data_length % wave_length;
    uint16_t *data = malloc(data_length * sizeof(uint16_t));
    for(int i = 0; i < data_length; i++) {
	float value = 0.5f * sinf(((float) (i % wave_length)) * ((M_PI*2) / wave_length));
	uint16_t sample = (value + 1.0f) * (0xFFFF / 2.0f);
	data[i] = sample;
    }
    alBufferData(id, AL_FORMAT_MONO16, data, data_length, 44100);
    return 0;
}


EF_Error ef_internal_portable_audio_load_sound_memory(uint8_t *data,
						      size_t size,
						      ALuint id)
{
    return 0;
}

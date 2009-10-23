#include "Emerald-Frame.h"
#include <stdio.h>
#include <string.h>
#include <mpg123.h>
#include <sndfile.h>


struct virtual_file {
    uint8_t *buffer;
    sf_count_t length;
    sf_count_t offset;
};


static EF_Error load_sound_mpg123_file(utf8 *filename, ALuint id);
static EF_Error load_sound_mpg123_memory(uint8_t *data, size_t size, ALuint id);
static EF_Error load_sound_mpg123_h(mpg123_handle *handle, ALuint id);
static EF_Error load_sound_sndfile_file(utf8 *filename, ALuint id);
static EF_Error load_sound_sndfile_memory(uint8_t *data, size_t size, ALuint id);
static EF_Error load_sound_sndfile_h(SNDFILE *file, SF_INFO *sfinfo, ALuint id);
static sf_count_t virtual_file_get_length(struct virtual_file *file);
static sf_count_t virtual_file_seek(sf_count_t offset,
				    int whence,
				    struct virtual_file *file);
static sf_count_t virtual_file_read(void *output,
				    sf_count_t count,
				    struct virtual_file *file);
static sf_count_t virtual_file_write(void *input,
				     sf_count_t count,
				     struct virtual_file *file);
static sf_count_t virtual_file_tell(struct virtual_file *file);


EF_Error ef_internal_portable_audio_init() {
    if(MPG123_OK != mpg123_init())
	return EF_ERROR_INTERNAL;
    
    return 0;
}


EF_Error ef_internal_portable_audio_load_sound_file(utf8 *filename,
						    ALuint id)
{
    FILE *file = fopen(filename, "rb");
    if(!file) {
	return EF_ERROR_FILE;
    }

    uint8_t magic_buffer[3];
    if(1 != fread(magic_buffer, sizeof(magic_buffer), 1, file)) {
	fclose(file);
	return EF_ERROR_SOUND_DATA;
    }
    fclose(file);

    if((magic_buffer[0] == 0xFF) &&
       ((magic_buffer[1] & 0xFE) == 0xFA) &&
       ((magic_buffer[2] & 0xF0) != 0xF0))
    {
	return load_sound_mpg123_file(filename, id);
    } else {
	return load_sound_sndfile_file(filename, id);
    }
}


EF_Error ef_internal_portable_audio_load_sound_memory(uint8_t *data,
						      size_t size,
						      ALuint id)
{
    if(size < 3)
	return EF_ERROR_SOUND_DATA;
    
    if((data[0] == 0xFF) &&
       ((data[1] & 0xFE) == 0xFA) &&
       ((data[2] & 0xF0) != 0xF0))
    {
	return load_sound_mpg123_memory(data, size, id);
    } else {
	return load_sound_sndfile_memory(data, size, id);
    }
}


static EF_Error load_sound_mpg123_file(utf8 *filename, ALuint id) {
    mpg123_handle *handle = mpg123_new(NULL, NULL);
    if(!handle)
	return EF_ERROR_INTERNAL;
    
    if(MPG123_OK != mpg123_open(handle, filename)) {
	mpg123_delete(handle);
	return EF_ERROR_FILE;
    }

    EF_Error result = load_sound_mpg123_h(handle, id);
    
    mpg123_close(handle);
    mpg123_delete(handle);
    
    return result;
}


static EF_Error load_sound_mpg123_memory(uint8_t *data, size_t size, ALuint id) {
    mpg123_handle *handle = mpg123_new(NULL, NULL);
    if(!handle)
	return EF_ERROR_INTERNAL;
    
    if(MPG123_OK != mpg123_open_feed(handle)) {
	mpg123_delete(handle);
	return EF_ERROR_INTERNAL;
    }

    if(MPG123_OK != mpg123_feed(handle, data, size)) {
	mpg123_close(handle);
	mpg123_delete(handle);
	return EF_ERROR_INTERNAL;
    }
    
    EF_Error result = load_sound_mpg123_h(handle, id);
    
    mpg123_close(handle);
    mpg123_delete(handle);
    
    return result;
}


static EF_Error load_sound_mpg123_h(mpg123_handle *handle, ALuint id) {
    long rate = 0;
    int channels = 0;
    int encoding = 0;
    if(MPG123_OK != mpg123_getformat(handle, &rate, &channels, &encoding)) {
	mpg123_close(handle);
	mpg123_delete(handle);
	return EF_ERROR_SOUND_DATA;
    }

    mpg123_format_none(handle);
    mpg123_format(handle, rate, channels, encoding);

    size_t buffer_block_size = mpg123_outblock(handle) * 1024;
    size_t buffer_used_size = 0;
    size_t buffer_allocated_size = buffer_block_size;
    uint8_t *buffer = malloc(buffer_allocated_size * sizeof(uint8_t));
    while(1) {
	if(buffer_used_size == buffer_allocated_size) {
	    buffer_allocated_size += buffer_block_size;
	    buffer = realloc(buffer, buffer_allocated_size * sizeof(uint8_t));
	}

	size_t amount_read;
	int result = mpg123_read(handle,
				 buffer + buffer_used_size,
				 buffer_allocated_size - buffer_used_size,
				 &amount_read);
	buffer_used_size += amount_read;
	
	if(result == MPG123_ERR) {
	    free(buffer);
	    mpg123_close(handle);
	    mpg123_delete(handle);
	    return EF_ERROR_SOUND_DATA;
	} else if((result == MPG123_DONE) || (result == MPG123_NEED_MORE)) {
	    break;
	}
    }
    
    ALenum alFormat;
    switch(channels) {
    case 1:
	alFormat = AL_FORMAT_MONO16;
	break;
    case 2:
	alFormat = AL_FORMAT_STEREO16;
	break;
    default:
	free(buffer);
	return EF_ERROR_SOUND_DATA;
    }
    
    alBufferData(id, alFormat, buffer, buffer_used_size, rate);
    
    free(buffer);
    
    return 0;
}


static EF_Error load_sound_sndfile_file(utf8 *filename, ALuint id) {
    SF_INFO sfinfo;
    sfinfo.format = 0;
    SNDFILE *file = sf_open(filename, SFM_READ, &sfinfo);
    if(!file)
	return EF_ERROR_FILE;

    EF_Error result = load_sound_sndfile_h(file, &sfinfo, id);
    
    sf_close(file);
    
    return result;
}


static EF_Error load_sound_sndfile_memory(uint8_t *data, size_t size, ALuint id) {
    SF_VIRTUAL_IO virtual_file_callbacks;
    virtual_file_callbacks.get_filelen = (sf_vio_get_filelen) virtual_file_get_length;
    virtual_file_callbacks.seek = (sf_vio_seek) virtual_file_seek;
    virtual_file_callbacks.read = (sf_vio_read) virtual_file_read;
    virtual_file_callbacks.write = (sf_vio_write) virtual_file_write;
    virtual_file_callbacks.tell = (sf_vio_tell) virtual_file_tell;

    struct virtual_file virtual_file;
    virtual_file.buffer = data;
    virtual_file.length = size;
    virtual_file.offset = 0;
    
    SF_INFO sfinfo;
    sfinfo.format = 0;
    SNDFILE *file = sf_open_virtual(&virtual_file_callbacks,
				    SFM_READ,
				    &sfinfo,
				    &virtual_file);
    
    EF_Error result = load_sound_sndfile_h(file, &sfinfo, id);
    
    sf_close(file);
    
    return result;
}


static EF_Error load_sound_sndfile_h(SNDFILE *file, SF_INFO *sfinfo, ALuint id) {
    size_t buffer_size = sfinfo->frames * sfinfo->channels * sizeof(uint16_t);
    uint16_t *buffer = malloc(buffer_size);
    sf_count_t n_read = sf_readf_short(file, buffer, sfinfo->frames);
    
    ALenum alFormat;
    switch(sfinfo->channels) {
    case 1:
	alFormat = AL_FORMAT_MONO16;
	break;
    case 2:
	alFormat = AL_FORMAT_STEREO16;
	break;
    default:
	free(buffer);
	return EF_ERROR_SOUND_DATA;
    }

    alBufferData(id, alFormat, buffer, buffer_size, sfinfo->samplerate);

    free(buffer);
    
    return 0;
}


static sf_count_t virtual_file_get_length(struct virtual_file *file) {
    return file->length;
}


static sf_count_t virtual_file_seek(sf_count_t offset,
				    int whence,
				    struct virtual_file *file)
{
    switch(whence) {
    case SEEK_SET:
	file->offset = offset;
	break;
    case SEEK_CUR:
	file->offset += offset;
	break;
    case SEEK_END:
	file->offset = file->length - offset;
	break;
    }
    
    if(file->offset < 0)
	file->offset = 0;
    if(file->offset > file->length)
	file->offset = file->length;
    
    return file->offset;
}


static sf_count_t virtual_file_read(void *output,
				    sf_count_t count,
				    struct virtual_file *file)
{
    memcpy(output, file->buffer + file->offset, count);
    file->offset += count;
    return count;
}


static sf_count_t virtual_file_write(void *input,
				     sf_count_t count,
				     struct virtual_file *file)
{
    return 0;
}


static sf_count_t virtual_file_tell(struct virtual_file *file) {
    return file->offset;
}

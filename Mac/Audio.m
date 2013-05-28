//
//  Audio.m
//  Emerald Frame
//
//  Created by Dan Knapp on 10/10/09.
//  Copyright 2009 Dan Knapp. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import <string.h>

#import "Emerald-Frame.h"


struct VirtualAudioFile {
    uint8_t *data;
    size_t size;
};


static OSStatus virtualAudioFileRead(struct VirtualAudioFile *file,
				     int64_t offset,
				     uint32_t length,
				     uint8_t *buffer,
				     uint32_t *lengthRead);
static OSStatus virtualAudioFileWrite(struct VirtualAudioFile *file,
				      int64_t offset,
				      uint32_t length,
				      uint8_t *buffer,
				      uint32_t *lengthWritten);
static int64_t virtualAudioFileGetSize(struct VirtualAudioFile *file);
static OSStatus virtualAudioFileSetSize(struct VirtualAudioFile *file,
					int64_t size);
static EF_Error ef_internal_audio_load_sound_audiofileid(AudioFileID file, ALuint id);


EF_Error ef_internal_audio_init() {
    return 0;
}


EF_Error ef_audio_load_sound_file(utf8 *filename, ALuint id) {
    OSStatus error;
    
    CFURLRef url = CFURLCreateFromFileSystemRepresentation(kCFAllocatorDefault,
							   filename,
							   strlen((char *) filename),
							   false);
    AudioFileID file;
    error = AudioFileOpenURL(url, kAudioFileReadPermission, 0, &file);
    if(error) {
	CFRelease(url);
	return EF_ERROR_FILE;
    }
    CFRelease(url);
    
    EF_Error result = ef_internal_audio_load_sound_audiofileid(file, id);

    // The internal function has closed the file for us.
    
    return result;

    /*
      // For testing ef_audio_load_sound_memory, use this instead.
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSString *filenameString = [NSString stringWithUTF8String: (char *) filename];
    NSData *data = [NSData dataWithContentsOfFile: filenameString];
    EF_Error result = ef_audio_load_sound_memory((uint8_t *) [data bytes],
						 [data length],
						 id);
    [pool drain];
    return result;
    */
}


EF_Error ef_audio_load_sound_memory(uint8_t *data, size_t size, ALuint id) {
    OSStatus error;

    struct VirtualAudioFile virtualAudioFile;
    virtualAudioFile.data = data;
    virtualAudioFile.size = size;
    
    AudioFileID file;
    error = AudioFileOpenWithCallbacks(&virtualAudioFile,
				       (AudioFile_ReadProc) virtualAudioFileRead,
				       (AudioFile_WriteProc) virtualAudioFileWrite,
				       (AudioFile_GetSizeProc) virtualAudioFileGetSize,
				       (AudioFile_SetSizeProc) virtualAudioFileSetSize,
				       0,
				       &file);
    if(error) {
	NSLog(@"AudioFileOpenWithCallbacks: OS error %i\n", error);
	return EF_ERROR_INTERNAL;
    }
    
    EF_Error result = ef_internal_audio_load_sound_audiofileid(file, id);

    // The internal function has closed the file for us.
    
    return result;
}


static OSStatus virtualAudioFileRead(struct VirtualAudioFile *file,
				     int64_t offset,
				     uint32_t length,
				     uint8_t *buffer,
				     uint32_t *lengthRead)
{
    if(offset + length > file->size) {
	NSLog(@"Bad parameters in call to virtualAudioFileRead.");
	return kAudioFileUnspecifiedError;
    }
    
    memcpy(buffer, file->data + offset, length);
    *lengthRead = length;
    
    return 0;
}


static OSStatus virtualAudioFileWrite(struct VirtualAudioFile *file,
				      int64_t offset,
				      uint32_t length,
				      uint8_t *buffer,
				      uint32_t *lengthWritten)
{
    NSLog(@"Unexpected call to virtualAudioFileWrite.");
    return kAudioFileUnspecifiedError;
}


static int64_t virtualAudioFileGetSize(struct VirtualAudioFile *file) {
    return file->size;
}


static OSStatus virtualAudioFileSetSize(struct VirtualAudioFile *file,
					int64_t size)
{
    NSLog(@"Unexpected call to virtualAudioFileSetSize.");
    return kAudioFileUnspecifiedError;
}


static EF_Error ef_internal_audio_load_sound_audiofileid(AudioFileID inFile, ALuint id) {
    OSStatus error;
    
    AudioStreamBasicDescription inFormat;
    UInt32 formatSize = sizeof(inFormat);
    error = AudioFileGetProperty(inFile,
				 kAudioFilePropertyDataFormat,
				 &formatSize,
				 &inFormat);
    if(error) {
	NSLog(@"AudioFileGetProperty: OS error %i\n", error);
	return EF_ERROR_FILE;
    }
    
    AudioStreamBasicDescription memoryFormat;
    memoryFormat.mSampleRate = inFormat.mSampleRate;
    memoryFormat.mFormatID = kAudioFormatLinearPCM;
    memoryFormat.mChannelsPerFrame = inFormat.mChannelsPerFrame;
    memoryFormat.mFormatFlags
	= kLinearPCMFormatFlagIsPacked
	| kAudioFormatFlagsNativeEndian
	| kAudioFormatFlagIsSignedInteger;
    memoryFormat.mFramesPerPacket = 1;
    if(inFormat.mBitsPerChannel == 8) {
	memoryFormat.mBitsPerChannel = 8;
	memoryFormat.mBytesPerFrame = 1 * memoryFormat.mChannelsPerFrame;
    } else {
	memoryFormat.mBitsPerChannel = 16;
	memoryFormat.mBytesPerFrame = 2 * memoryFormat.mChannelsPerFrame;
    }
    memoryFormat.mBytesPerPacket = memoryFormat.mBytesPerFrame;
    memoryFormat.mReserved = 0;
    
    ExtAudioFileRef inExtFile;
    error = ExtAudioFileWrapAudioFileID(inFile, false, &inExtFile);
    if(error) {
	AudioFileClose(inFile);
	NSLog(@"ExtAudioFileWrapAudioFileID: OS error %i\n", error);
	return EF_ERROR_INTERNAL;
    }
    
    error = ExtAudioFileSetProperty(inExtFile,
				    kExtAudioFileProperty_ClientDataFormat,
				    sizeof(memoryFormat),
				    &memoryFormat);
    if(error) {
	ExtAudioFileDispose(inExtFile);
	NSLog(@"ExtAudioFileSetProperty: OS error %i\n", error);
	return EF_ERROR_INTERNAL;
    }

    int64_t fileLengthFrames;
    uint32_t fileLengthFramesSize = sizeof(fileLengthFrames);
    error = ExtAudioFileGetProperty(inExtFile,
				    kExtAudioFileProperty_FileLengthFrames,
				    &fileLengthFramesSize,
				    &fileLengthFrames);
    if(error) {
	ExtAudioFileDispose(inExtFile);
	NSLog(@"ExtAudioFileGetProperty: OS error %i\n", error);
	return EF_ERROR_INTERNAL;
    }

    size_t memoryBufferSize = fileLengthFrames * memoryFormat.mBytesPerFrame;
    uint8_t *memoryBuffer = malloc(memoryBufferSize);

    AudioBufferList bufferList;
    bufferList.mNumberBuffers = 1;
    bufferList.mBuffers[0].mDataByteSize = memoryBufferSize;
    bufferList.mBuffers[0].mNumberChannels = memoryFormat.mChannelsPerFrame;
    bufferList.mBuffers[0].mData = memoryBuffer;
    
    uint32_t fileLengthFrames32 = (uint32_t) fileLengthFrames;
    error = ExtAudioFileRead(inExtFile, &fileLengthFrames32, &bufferList);
    if(error) {
	free(memoryBuffer);
	ExtAudioFileDispose(inExtFile);
	NSLog(@"ExtAudioFileRead: OS error %i\n", error);
	return EF_ERROR_INTERNAL;
    }
    
    ExtAudioFileDispose(inExtFile);
    
    ALenum alFormat;
    switch(memoryFormat.mChannelsPerFrame) {
    case 1:
	switch(memoryFormat.mBitsPerChannel) {
	case 8:
	    alFormat = AL_FORMAT_MONO8;
	    break;
	case 16:
	    alFormat = AL_FORMAT_MONO16;
	    break;
	default:
	    free(memoryBuffer);
	    NSLog(@"Audio format has 1 channel and %i bits per channel.",
		  memoryFormat.mBitsPerChannel);
	    return EF_ERROR_SOUND_DATA;
	}
	break;
    case 2:
	switch(memoryFormat.mBitsPerChannel) {
	case 8:
	    alFormat = AL_FORMAT_STEREO8;
	    break;
	case 16:
	    alFormat = AL_FORMAT_STEREO16;
	    break;
	default:
	    free(memoryBuffer);
	    NSLog(@"Audio format has 2 channels and %i bits per channel.",
		  memoryFormat.mBitsPerChannel);
	    return EF_ERROR_SOUND_DATA;
	}
	break;
    default:
	free(memoryBuffer);
	NSLog(@"Audio format has %i channels per frame.",
	      memoryFormat.mChannelsPerFrame);
	return EF_ERROR_SOUND_DATA;
    }
    
    ALsizei sampleRate = memoryFormat.mSampleRate;

    alBufferData(id, alFormat, memoryBuffer, memoryBufferSize, sampleRate);

    free(memoryBuffer);
    
    return 0;
}


#include <stdlib.h>
#include <string.h>

#include "Emerald-Frame.h"

extern EF_Error ef_internal_video_init();
extern EF_Error ef_internal_time_init();


static utf8 *application_name = NULL;

EF_Error ef_init(utf8 *new_application_name) {
    if(!new_application_name)
	return EF_ERROR_PARAM;
    application_name = (utf8 *) strdup((char *) new_application_name);
    
    EF_Error error;

    // Video
    error = ef_internal_video_init();
    if(error) return error;
    
    // Audio
    
    // Time
    error = ef_internal_time_init();
    if(error) return error;
    
    // Input
    
    // Text
    
    // Configuration
    
    return 0;
}


utf8 *ef_version_string() {
    return (utf8 *) "Emerald Frame prerelease";
}


utf8 *ef_error_string(EF_Error error) {
    switch(error) {
    case 0: return (utf8 *) "No error.";
    case EF_ERROR_PARAM: return (utf8 *) "Invalid parameters.";
    case EF_ERROR_FILE: return (utf8 *) "Missing or unreadable file.";
    case EF_ERROR_IMAGE_DATA:
	return (utf8 *) "Invalid image or no supported pixel format.";
    default: return (utf8 *) "Unknown error.";
    }
}


utf8 *ef_internal_application_name() {
    return application_name;
}

#include "emerald-frame.h"

EF_Error ef_init() {
    EF_Error error;
    
    // Video
    error = ef_internal_video_init();
    if(error)
	return error;

    // Audio

    // Time

    // Input

    // Text

    // Configuration
    
    return 0;
}


EF_Error ef_quit() {
    return 0;
}


utf8 *ef_version_string() {
    return (utf8 *) "Emerald Frame prerelease";
}


utf8 *ef_error_string(EF_Error error) {
    switch(error) {
    case 0: return (utf8 *) "No error.";
    default: return (utf8 *) "Unknown error.";
    }
}

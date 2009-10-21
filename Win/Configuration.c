#include "Emerald-Frame.h"
#include <stdlib.h>


static utf8 *result_buffer = NULL;
static size_t result_buffer_size = 0;


utf8 *ef_configuration_resource_directory() {
    return "./";
}

#include "Emerald-Frame.h"
#include <stdlib.h>
#include <string.h>
#include <windows.h>


static utf8 *executable_directory_path = NULL;
static utf8 *result_buffer = NULL;
static size_t result_buffer_size = 0;


EF_Error ef_internal_configuration_init() {
    char *command_line = GetCommandLine();

    size_t first_argument_start;
    size_t first_argument_end;
    
    if(command_line[0] == '"') {
	first_argument_start = 1;
	for(first_argument_end = 1;
	    command_line[first_argument_end]
		&& (command_line[first_argument_end] != '"');
	    first_argument_end++);
    } else {
	first_argument_start = 0;
	for(first_argument_end = 0;
	    command_line[first_argument_end]
		&& (command_line[first_argument_end] != ' ');
	    first_argument_end++);
    }
    
    size_t last_slash;
    for(last_slash = first_argument_end;
	(last_slash >= first_argument_start) && (command_line[last_slash] != '\\');
	last_slash--);
    if(last_slash < first_argument_start) {
	return EF_ERROR_INTERNAL;
    }
    
    size_t length = last_slash - first_argument_start;
    executable_directory_path = malloc(length+1);
    for(size_t i = first_argument_start; i < last_slash; i++)
	executable_directory_path[i - first_argument_start] = command_line[i];
    executable_directory_path[length] = '\0';
    
    return 0;
}


utf8 *ef_configuration_resource_directory() {
    utf8 *resource_directory_name = "\\Resources\\";
    size_t required_buffer_size
	= strlen(executable_directory_path) + strlen(resource_directory_name) + 1;
    while(required_buffer_size > result_buffer_size) {
	if(result_buffer_size == 0)
	    result_buffer_size = 128;
	else
	    result_buffer_size *= 2;
	
	result_buffer = realloc(result_buffer, result_buffer_size * sizeof(uint8_t));
    }
    strcpy((char *) result_buffer, (char *) executable_directory_path);
    strcat((char *) result_buffer, (char *) resource_directory_name);
    return result_buffer;
}

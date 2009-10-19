#include "Emerald-Frame.h"
#include <windows.h>


extern utf8 *ef_internal_application_name();


void ef_main() {
    while(1) {
	MSG message;
	GetMessage(&message, NULL, 0, 0);
	
	if(message.message == WM_QUIT) {
	    break;
	} else {
	    TranslateMessage(&message);
	    DispatchMessage(&message);
	}
    }
}

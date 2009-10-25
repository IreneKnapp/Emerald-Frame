// Tell gd.h that we want the non-DLL versions, please.
#define NONDLL

// Tell windows.h that we want Unicode versions of things - this shouldn't be
// necessary, since we're carefully using the explicitly-Unicode versions, but for
// some reason I can't track down, it is.
#define UNICODE

// Tell windows.h we want to require at least Windows XP.  This makes it define some
// nice things that we enjoy having, such as 
#define WINVER         0x0501
#define _WIN32_WINNT   0x0501
#define _WIN32_WINDOWS 0x0501
#define _WIN32_IE      0x0501

// These aren't defined by the MinGW headers, for some reason.
#ifndef MAPVK_VK_TO_VSC
#define MAPVK_VK_TO_VSC 0
#endif
#ifndef MAPVK_VSC_TO_VK
#define MAPVK_VSC_TO_VK 1
#endif
#ifndef MAPVK_VK_TO_CHAR
#define MAPVK_VK_TO_CHAR 2
#endif
#ifndef MAPVK_VSC_TO_VK_EX
#define MAPVK_VSC_TO_VK_EX 3
#endif


#include "Emerald-Frame.h"
#include "Unicode.h"
#include <math.h>
#include <windows.h>
#include <gd.h>


struct ef_drawable_parameters {
    int double_buffer;
    int stereo;
    int aux_buffers;
    int color_size;
    int alpha_size;
    int depth_size;
    int stencil_size;
    int accumulation_size;
    int samples;
    int aux_depth_stencil;
    int color_float;
    int multisample;
    int supersample;
    int sample_alpha;
};

struct drawable {
    HWND window;
    HDC device_context;
    HGLRC rendering_context;
    void (*draw_callback)(EF_Drawable drawable, void *context);
    void *draw_callback_context;
    void (*key_down_callback)(EF_Drawable drawable, EF_Event event, void *context);
    void *key_down_callback_context;
    void (*key_up_callback)(EF_Drawable drawable, EF_Event event, void *context);
    void *key_up_callback_context;
    void (*mouse_down_callback)(EF_Drawable drawable, EF_Event event, void *context);
    void *mouse_down_callback_context;
    void (*mouse_up_callback)(EF_Drawable drawable, EF_Event event, void *context);
    void *mouse_up_callback_context;
    void (*mouse_move_callback)(EF_Drawable drawable, EF_Event event, void *context);
    void *mouse_move_callback_context;
    void (*mouse_enter_callback)(EF_Drawable drawable, EF_Event event, void *context);
    void *mouse_enter_callback_context;
    void (*mouse_exit_callback)(EF_Drawable drawable, EF_Event event, void *context);
    void *mouse_exit_callback_context;
};

struct event {
    uint64_t timestamp;
    EF_Modifiers modifiers;
    union {
	struct {
	    EF_Keycode keycode;
	    utf8 *string;
	} key_event;
	struct {
	    int button_number;
	    int click_count;
	    int32_t x;
	    int32_t y;
	} mouse_event;
    } data;
};


static struct ef_drawable_parameters drawable_parameters;
static HINSTANCE hInstance;
static size_t n_drawables;
static struct drawable **all_drawables;


extern utf8 *ef_internal_application_name();


static EF_Error ef_internal_video_load_texture_gd_image(gdImage *image,
							GLuint id,
							int build_mipmaps);
static LRESULT CALLBACK window_procedure(HWND window,
					 UINT message,
					 WPARAM wParam,
					 LPARAM lParam);
static EF_Modifiers get_modifiers();
static int is_modifier_keycode(WPARAM keycode);
static int is_noncharacter_keycode(WPARAM keycode);


EF_Error ef_internal_video_init() {
    drawable_parameters.double_buffer = False;
    drawable_parameters.stereo = False;
    drawable_parameters.aux_buffers = 0;
    drawable_parameters.color_size = 8;
    drawable_parameters.alpha_size = 0;
    drawable_parameters.depth_size = 0;
    drawable_parameters.stencil_size = 0;
    drawable_parameters.accumulation_size = 0;
    drawable_parameters.samples = 0;
    drawable_parameters.aux_depth_stencil = False;
    drawable_parameters.color_float = False;
    drawable_parameters.multisample = False;
    drawable_parameters.supersample = False;
    drawable_parameters.sample_alpha = False;
    
    n_drawables = 0;
    all_drawables = NULL;

    hInstance = GetModuleHandleW(NULL);
    
    WNDCLASSW window_class;
    window_class.style = CS_OWNDC;
    window_class.lpfnWndProc = window_procedure;
    window_class.cbClsExtra = 0;
    window_class.cbWndExtra = 0;
    window_class.hInstance = hInstance;
    window_class.hIcon = LoadIcon(NULL, IDI_APPLICATION);
    window_class.hCursor = LoadCursor(NULL, IDC_ARROW);
    window_class.hbrBackground = (HBRUSH) GetStockObject(BLACK_BRUSH);
    window_class.lpszMenuName = NULL;
    window_class.lpszClassName = L"Emerald Frame";
    RegisterClassW(&window_class);

    return 0;
}


EF_Drawable ef_video_new_drawable(int width,
				  int height,
				  int full_screen,
				  EF_Display display)
{
    struct drawable *drawable = malloc(sizeof(struct drawable));

    DWORD window_style = WS_CAPTION | WS_POPUPWINDOW | WS_VISIBLE;
    
    RECT window_rect;
    window_rect.top = 0;
    window_rect.left = 0;
    window_rect.bottom = height;
    window_rect.right = width;
    AdjustWindowRect(&window_rect, window_style, 0);
    int adjusted_width = window_rect.right - window_rect.left;
    int adjusted_height = window_rect.bottom - window_rect.top;
    
    utf16 *title16 = utf8_to_utf16(ef_internal_application_name());
    drawable->window = CreateWindowW(L"Emerald Frame",
				     title16,
				     window_style,
				     CW_USEDEFAULT, CW_USEDEFAULT,
				     adjusted_width, adjusted_height,
				     NULL, NULL, hInstance, NULL);
    free(title16);

    TRACKMOUSEEVENT trackmouseevent;
    trackmouseevent.cbSize = sizeof(trackmouseevent);
    trackmouseevent.dwFlags = TME_LEAVE;
    trackmouseevent.hwndTrack = drawable->window;
    trackmouseevent.dwHoverTime = 0;
    TrackMouseEvent(&trackmouseevent);
    
    drawable->device_context = GetDC(drawable->window);
    
    PIXELFORMATDESCRIPTOR pixel_format;
    ZeroMemory(&pixel_format, sizeof(pixel_format));
    pixel_format.nSize = sizeof(pixel_format);
    pixel_format.nVersion = 1;
    pixel_format.dwFlags = PFD_DRAW_TO_WINDOW | PFD_SUPPORT_OPENGL | PFD_DOUBLEBUFFER;
    pixel_format.iPixelType = PFD_TYPE_RGBA;
    pixel_format.cColorBits = 24;
    pixel_format.cDepthBits = 16;
    pixel_format.iLayerType = PFD_MAIN_PLANE;
    int internal_pixel_format = ChoosePixelFormat(drawable->device_context,
						  &pixel_format);
    SetPixelFormat(drawable->device_context, internal_pixel_format, &pixel_format);
    
    drawable->rendering_context = wglCreateContext(drawable->device_context);

    n_drawables++;
    all_drawables = realloc(all_drawables, sizeof(struct drawable *) * n_drawables);
    all_drawables[n_drawables-1] = drawable;

    drawable->draw_callback = NULL;
    drawable->draw_callback_context = NULL;
    drawable->key_down_callback = NULL;
    drawable->key_down_callback_context = NULL;
    drawable->key_up_callback = NULL;
    drawable->key_up_callback_context = NULL;
    drawable->mouse_down_callback = NULL;
    drawable->mouse_down_callback_context = NULL;
    drawable->mouse_up_callback = NULL;
    drawable->mouse_up_callback_context = NULL;
    drawable->mouse_move_callback = NULL;
    drawable->mouse_move_callback_context = NULL;
    drawable->mouse_enter_callback = NULL;
    drawable->mouse_enter_callback_context = NULL;
    drawable->mouse_exit_callback = NULL;
    drawable->mouse_exit_callback_context = NULL;
    
    return (EF_Drawable) drawable;
}


void ef_drawable_delete(EF_Drawable ef_drawable) {
    struct drawable *drawable = (struct drawable *) ef_drawable;
    
    wglMakeCurrent(NULL, NULL);
    wglDeleteContext(drawable->rendering_context);
    ReleaseDC(drawable->window, drawable->device_context);
    DestroyWindow(drawable->window);
    free(drawable);

    for(size_t i = 0; i < n_drawables; i++) {
	if(all_drawables[i] == drawable) {
	    for(size_t j = i; j < n_drawables-1; j++)
		all_drawables[j] = all_drawables[j+1];
	    
	    n_drawables--;
	    all_drawables = realloc(all_drawables,
				    sizeof(struct drawable *) * n_drawables);
	    
	    break;
	}
    }
}


void ef_drawable_set_title(EF_Drawable ef_drawable, utf8 *title) {
    struct drawable *drawable = (struct drawable *) ef_drawable;

    utf16 *title16 = utf8_to_utf16(title);
    SetWindowTextW(drawable->window, title16);
    free(title16);
}


void ef_drawable_set_draw_callback(EF_Drawable ef_drawable,
				   void (*callback)(EF_Drawable drawable,
						    void *context),
				   void *context)
{
    struct drawable *drawable = (struct drawable *) ef_drawable;
    drawable->draw_callback = callback;
    drawable->draw_callback_context = context;
}


void ef_drawable_redraw(EF_Drawable ef_drawable) {
    struct drawable *drawable = (struct drawable *) ef_drawable;

    InvalidateRect(drawable->window, NULL, FALSE);
}


void ef_drawable_make_current(EF_Drawable ef_drawable) {
    struct drawable *drawable = (struct drawable *) ef_drawable;
    
    wglMakeCurrent(drawable->device_context, drawable->rendering_context);
}


void ef_drawable_swap_buffers(EF_Drawable ef_drawable) {
    ef_drawable_make_current(ef_drawable);
    glFlush();
    struct drawable *drawable = (struct drawable *) ef_drawable;
    SwapBuffers(drawable->device_context);
}


void ef_video_set_double_buffer(int double_buffer) {
    drawable_parameters.double_buffer = double_buffer;
}


void ef_video_set_stereo(int stereo) {
    drawable_parameters.stereo = stereo;
}


void ef_video_set_aux_buffers(int aux_buffers) {
    drawable_parameters.aux_buffers = aux_buffers;
}


void ef_video_set_color_size(int color_size) {
    drawable_parameters.color_size = color_size;
}


void ef_video_set_alpha_size(int alpha_size) {
    drawable_parameters.alpha_size = alpha_size;
}


void ef_video_set_depth_size(int depth_size) {
    drawable_parameters.depth_size = depth_size;
}


void ef_video_set_stencil_size(int stencil_size) {
    drawable_parameters.stencil_size = stencil_size;
}


void ef_video_set_accumulation_size(int accumulation_size) {
    drawable_parameters.accumulation_size = accumulation_size;
}


void ef_video_set_samples(int samples) {
    drawable_parameters.samples = samples;
}


void ef_video_set_aux_depth_stencil(int aux_depth_stencil) {
    drawable_parameters.aux_depth_stencil = aux_depth_stencil;
}


void ef_video_set_color_float(int color_float) {
    drawable_parameters.color_float = color_float;
}


void ef_video_set_multisample(int multisample) {
    drawable_parameters.multisample = multisample;
}


void ef_video_set_supersample(int supersample) {
    drawable_parameters.supersample = supersample;
}


void ef_video_set_sample_alpha(int sample_alpha) {
    drawable_parameters.sample_alpha = sample_alpha;
}


EF_Display ef_video_current_display() {
    // TODO
}


EF_Display ef_video_next_display(EF_Display previous) {
    // TODO
}


int ef_display_depth(EF_Display display) {
    // TODO
}


int ef_display_width(EF_Display display) {
    // TODO
}


int ef_display_height(EF_Display display) {
    // TODO
}


EF_Error ef_video_load_texture_file(utf8 *filename,
				    GLuint id,
				    int build_mipmaps)
{
    FILE *file = fopen(filename, "rb");
    if(!file) {
	return EF_ERROR_FILE;
    }

    gdImagePtr image = NULL;
    
    uint8_t magic_buffer[4];
    if(1 != fread(magic_buffer, sizeof(magic_buffer), 1, file)) {
	fclose(file);
	return EF_ERROR_IMAGE_DATA;
    }
    fseek(file, 0, SEEK_SET);
    
    if((magic_buffer[0] == 0x89) &&
       (magic_buffer[1] == 'P') &&
       (magic_buffer[2] == 'N') &&
       (magic_buffer[3] == 'G'))
    {
	image = gdImageCreateFromPng(file);
    } else if((magic_buffer[0] == 'G') &&
	      (magic_buffer[1] == 'I') &&
	      (magic_buffer[2] == 'F') &&
	      (magic_buffer[3] == '8'))
    {
	image = gdImageCreateFromGif(file);
    } else if((magic_buffer[0] == 0xFF) &&
	      (magic_buffer[1] == 0xD8))
    {
	image = gdImageCreateFromJpeg(file);
    }
    fclose(file);
    if(!image) {
	return EF_ERROR_IMAGE_DATA;
    }

    EF_Error result = ef_internal_video_load_texture_gd_image(image, id, build_mipmaps);
    
    gdImageDestroy(image);

    return result;
}


EF_Error ef_video_load_texture_memory(uint8_t *bytes, size_t size,
				      GLuint id,
				      int build_mipmaps)
{
    if(size < 4)
	return EF_ERROR_IMAGE_DATA;

    gdImagePtr image = NULL;
    if((bytes[0] == 0x89) &&
       (bytes[1] == 'P') &&
       (bytes[2] == 'N') &&
       (bytes[3] == 'G'))
    {
	image = gdImageCreateFromPngPtr(size, bytes);
    } else if((bytes[0] == 'G') &&
	      (bytes[1] == 'I') &&
	      (bytes[2] == 'F') &&
	      (bytes[3] == '8'))
    {
	image = gdImageCreateFromGifPtr(size, bytes);
    } else if((bytes[0] == 0xFF) &&
	      (bytes[1] == 0xD8))
    {
	image = gdImageCreateFromJpegPtr(size, bytes);
    }
    if(!image) {
	return EF_ERROR_IMAGE_DATA;
    }
    
    EF_Error result = ef_internal_video_load_texture_gd_image(image, id, build_mipmaps);
    
    gdImageDestroy(image);

    return result;
}


static EF_Error ef_internal_video_load_texture_gd_image(gdImage *image,
							GLuint id,
							int build_mipmaps)
{
    GLint pixel_format;
    GLint component_format;
    GLsizei size;
    uint8_t *data;
    
    int width = gdImageSX(image);
    int height = gdImageSY(image);
    int widthLog2 = ceil(log2(width));
    int heightLog2 = ceil(log2(height));
    int sizeLog2 = widthLog2 > heightLog2 ? widthLog2 : heightLog2;
    size = 1;
    for(int i = 0; i < sizeLog2; i++)
	size *= 2;
    
    pixel_format = GL_RGBA;
    
    component_format = GL_UNSIGNED_BYTE;
    
    data = malloc(size*size*4);
    for(int y = 0; y < size; y++) {
	for(int x = 0; x < size; x++) {
	    if((y < height) && (x < width)) {
		int color = gdImageGetPixel(image, x, y);
		data[(x + y*size)*4] = gdImageRed(image, color);
		data[(x + y*size)*4+1] = gdImageGreen(image, color);
		data[(x + y*size)*4+2] = gdImageBlue(image, color);
		int alpha = (127 - gdImageAlpha(image, color)) * 2;
		data[(x + y*size)*4+3] = alpha;
	    } else {
		data[(x + y*size)*4] = 0x00;
		data[(x + y*size)*4+1] = 0x00;
		data[(x + y*size)*4+2] = 0x00;
		data[(x + y*size)*4+3] = 0x00;
	    }
	}
    }
    
    glBindTexture(GL_TEXTURE_2D, id);
    
    glPixelStorei(GL_UNPACK_ROW_LENGTH, size);
    glPixelStorei(GL_UNPACK_IMAGE_HEIGHT, size);
    
    if(build_mipmaps) {
	gluBuild2DMipmaps(GL_TEXTURE_2D,
			  pixel_format,
			  size, size,
			  pixel_format,
			  component_format,
			  data);
    } else {
	glTexImage2D(GL_TEXTURE_2D,
		     0,
		     pixel_format,
		     size, size,
		     0,
		     pixel_format,
		     component_format,
		     data);
    }
    
    free(data);

    glBindTexture(GL_TEXTURE_2D, 0);
}


void ef_input_set_key_down_callback(EF_Drawable ef_drawable,
				    void (*callback)(EF_Drawable drawable,
						     EF_Event event,
						     void *context),
				    void *context)
{
    struct drawable *drawable = (struct drawable *) ef_drawable;
    drawable->key_down_callback = callback;
    drawable->key_down_callback_context = context;
}


void ef_input_set_key_up_callback(EF_Drawable ef_drawable,
				  void (*callback)(EF_Drawable drawable,
						   EF_Event event,
						   void *context),
				  void *context)
{
    struct drawable *drawable = (struct drawable *) ef_drawable;
    drawable->key_up_callback = callback;
    drawable->key_up_callback_context = context;
}


void ef_input_set_mouse_down_callback(EF_Drawable ef_drawable,
				      void (*callback)(EF_Drawable drawable,
						       EF_Event event,
						       void *context),
				      void *context)
{
    struct drawable *drawable = (struct drawable *) ef_drawable;
    drawable->mouse_down_callback = callback;
    drawable->mouse_down_callback_context = context;
}


void ef_input_set_mouse_up_callback(EF_Drawable ef_drawable,
				    void (*callback)(EF_Drawable drawable,
						     EF_Event event,
						     void *context),
				    void *context)
{
    struct drawable *drawable = (struct drawable *) ef_drawable;
    drawable->mouse_up_callback = callback;
    drawable->mouse_up_callback_context = context;
}


void ef_input_set_mouse_move_callback(EF_Drawable ef_drawable,
				      void (*callback)(EF_Drawable drawable,
						       EF_Event event,
						       void *context),
				      void *context)
{
    struct drawable *drawable = (struct drawable *) ef_drawable;
    drawable->mouse_move_callback = callback;
    drawable->mouse_move_callback_context = context;
}


void ef_input_set_mouse_enter_callback(EF_Drawable ef_drawable,
				       void (*callback)(EF_Drawable drawable,
							EF_Event event,
							void *context),
				       void *context)
{
    struct drawable *drawable = (struct drawable *) ef_drawable;
    drawable->mouse_enter_callback = callback;
    drawable->mouse_enter_callback_context = context;
}


void ef_input_set_mouse_exit_callback(EF_Drawable ef_drawable,
				      void (*callback)(EF_Drawable drawable,
						       EF_Event event,
						       void *context),
				      void *context)
{
    struct drawable *drawable = (struct drawable *) ef_drawable;
    drawable->mouse_exit_callback = callback;
    drawable->mouse_exit_callback_context = context;
}


uint64_t ef_event_timestamp(EF_Event ef_event) {
    struct event *event = (struct event *) ef_event;
    return event->timestamp;
}


EF_Modifiers ef_event_modifiers(EF_Event ef_event) {
    struct event *event = (struct event *) ef_event;
    return event->modifiers;
}


EF_Keycode ef_event_keycode(EF_Event ef_event) {
    struct event *event = (struct event *) ef_event;
    return event->data.key_event.keycode;
}


utf8 *ef_event_string(EF_Event ef_event) {
    struct event *event = (struct event *) ef_event;
    return event->data.key_event.string;
}


int ef_event_button_number(EF_Event ef_event) {
    struct event *event = (struct event *) ef_event;
    return event->data.mouse_event.button_number;
}


int ef_event_click_count(EF_Event ef_event) {
    struct event *event = (struct event *) ef_event;
    return event->data.mouse_event.click_count;
}


int32_t ef_event_mouse_x(EF_Event ef_event) {
    struct event *event = (struct event *) ef_event;
    return event->data.mouse_event.x;
}


int32_t ef_event_mouse_y(EF_Event ef_event) {
    struct event *event = (struct event *) ef_event;
    return event->data.mouse_event.y;
}


utf8 *ef_input_key_name(EF_Keycode ef_keycode) {
    //UINT scan_code = ef_keycode;
    //UINT virtual_key = MapVirtualKey(scan_code, MAPVK_VSC_TO_VK);
    UINT virtual_key = ef_keycode;
    switch(virtual_key) {
    case VK_UP: return (utf8 *) "cursor up";
    case VK_DOWN: return (utf8 *) "cursor down";
    case VK_LEFT: return (utf8 *) "cursor left";
    case VK_RIGHT: return (utf8 *) "cursor right";
    case VK_BACK: return (utf8 *) "backspace";
    case VK_TAB: return (utf8 *) "tab";
    case VK_RETURN: return (utf8 *) "return";
    case VK_ESCAPE: return (utf8 *) "escape";
    case VK_SPACE: return (utf8 *) "space";
    case VK_HOME: return (utf8 *) "home";
    case VK_END: return (utf8 *) "end";
    case VK_PRIOR: return (utf8 *) "page up";
    case VK_NEXT: return (utf8 *) "page down";
    case 'A': return (utf8 *) "a";
    case 'B': return (utf8 *) "b";
    case 'C': return (utf8 *) "c";
    case 'D': return (utf8 *) "d";
    case 'E': return (utf8 *) "e";
    case 'F': return (utf8 *) "f";
    case 'G': return (utf8 *) "g";
    case 'H': return (utf8 *) "h";
    case 'I': return (utf8 *) "i";
    case 'J': return (utf8 *) "j";
    case 'K': return (utf8 *) "k";
    case 'L': return (utf8 *) "l";
    case 'M': return (utf8 *) "m";
    case 'N': return (utf8 *) "n";
    case 'O': return (utf8 *) "o";
    case 'P': return (utf8 *) "p";
    case 'Q': return (utf8 *) "q";
    case 'R': return (utf8 *) "r";
    case 'S': return (utf8 *) "s";
    case 'T': return (utf8 *) "t";
    case 'U': return (utf8 *) "u";
    case 'V': return (utf8 *) "v";
    case 'W': return (utf8 *) "w";
    case 'X': return (utf8 *) "x";
    case 'Y': return (utf8 *) "y";
    case 'Z': return (utf8 *) "z";
    case '0': return (utf8 *) "0";
    case '1': return (utf8 *) "1";
    case '2': return (utf8 *) "2";
    case '3': return (utf8 *) "3";
    case '4': return (utf8 *) "4";
    case '5': return (utf8 *) "5";
    case '6': return (utf8 *) "6";
    case '7': return (utf8 *) "7";
    case '8': return (utf8 *) "8";
    case '9': return (utf8 *) "9";
    case VK_F1: return (utf8 *) "F1";
    case VK_F2: return (utf8 *) "F2";
    case VK_F3: return (utf8 *) "F3";
    case VK_F4: return (utf8 *) "F4";
    case VK_F5: return (utf8 *) "F5";
    case VK_F6: return (utf8 *) "F6";
    case VK_F7: return (utf8 *) "F7";
    case VK_F8: return (utf8 *) "F8";
    case VK_F9: return (utf8 *) "F9";
    case VK_F10: return (utf8 *) "F10";
    case VK_F11: return (utf8 *) "F11";
    case VK_F12: return (utf8 *) "F12";
    default: return NULL;
    }
}


EF_Keycode ef_input_keycode_by_name(utf8 *name) {
    UINT virtual_key;
    if(!strcmp((char *) name, "cursor up")) virtual_key = VK_UP;
    else if(!strcmp((char *) name, "cursor down")) virtual_key = VK_DOWN;
    else if(!strcmp((char *) name, "cursor left")) virtual_key = VK_LEFT;
    else if(!strcmp((char *) name, "cursor right")) virtual_key = VK_RIGHT;
    else if(!strcmp((char *) name, "backspace")) virtual_key = VK_BACK;
    else if(!strcmp((char *) name, "tab")) virtual_key = VK_TAB;
    else if(!strcmp((char *) name, "return")) virtual_key = VK_RETURN;
    else if(!strcmp((char *) name, "escape")) virtual_key = VK_ESCAPE;
    else if(!strcmp((char *) name, "space")) virtual_key = VK_SPACE;
    else if(!strcmp((char *) name, "home")) virtual_key = VK_HOME;
    else if(!strcmp((char *) name, "end")) virtual_key = VK_END;
    else if(!strcmp((char *) name, "page up")) virtual_key = VK_PRIOR;
    else if(!strcmp((char *) name, "page down")) virtual_key = VK_NEXT;
    else if(!strcmp((char *) name, "a")) virtual_key = 'A';
    else if(!strcmp((char *) name, "b")) virtual_key = 'B';
    else if(!strcmp((char *) name, "c")) virtual_key = 'C';
    else if(!strcmp((char *) name, "d")) virtual_key = 'D';
    else if(!strcmp((char *) name, "e")) virtual_key = 'E';
    else if(!strcmp((char *) name, "f")) virtual_key = 'F';
    else if(!strcmp((char *) name, "g")) virtual_key = 'G';
    else if(!strcmp((char *) name, "h")) virtual_key = 'H';
    else if(!strcmp((char *) name, "i")) virtual_key = 'I';
    else if(!strcmp((char *) name, "j")) virtual_key = 'J';
    else if(!strcmp((char *) name, "k")) virtual_key = 'K';
    else if(!strcmp((char *) name, "l")) virtual_key = 'L';
    else if(!strcmp((char *) name, "m")) virtual_key = 'M';
    else if(!strcmp((char *) name, "n")) virtual_key = 'N';
    else if(!strcmp((char *) name, "o")) virtual_key = 'O';
    else if(!strcmp((char *) name, "p")) virtual_key = 'P';
    else if(!strcmp((char *) name, "q")) virtual_key = 'Q';
    else if(!strcmp((char *) name, "r")) virtual_key = 'R';
    else if(!strcmp((char *) name, "s")) virtual_key = 'S';
    else if(!strcmp((char *) name, "t")) virtual_key = 'T';
    else if(!strcmp((char *) name, "u")) virtual_key = 'U';
    else if(!strcmp((char *) name, "v")) virtual_key = 'V';
    else if(!strcmp((char *) name, "w")) virtual_key = 'W';
    else if(!strcmp((char *) name, "x")) virtual_key = 'X';
    else if(!strcmp((char *) name, "y")) virtual_key = 'Y';
    else if(!strcmp((char *) name, "z")) virtual_key = 'Z';
    else if(!strcmp((char *) name, "0")) virtual_key = '0';
    else if(!strcmp((char *) name, "1")) virtual_key = '1';
    else if(!strcmp((char *) name, "2")) virtual_key = '2';
    else if(!strcmp((char *) name, "3")) virtual_key = '3';
    else if(!strcmp((char *) name, "4")) virtual_key = '4';
    else if(!strcmp((char *) name, "5")) virtual_key = '5';
    else if(!strcmp((char *) name, "6")) virtual_key = '6';
    else if(!strcmp((char *) name, "7")) virtual_key = '7';
    else if(!strcmp((char *) name, "8")) virtual_key = '8';
    else if(!strcmp((char *) name, "9")) virtual_key = '9';
    else if(!strcmp((char *) name, "F1")) virtual_key = VK_F1;
    else if(!strcmp((char *) name, "F2")) virtual_key = VK_F2;
    else if(!strcmp((char *) name, "F3")) virtual_key = VK_F3;
    else if(!strcmp((char *) name, "F4")) virtual_key = VK_F4;
    else if(!strcmp((char *) name, "F5")) virtual_key = VK_F5;
    else if(!strcmp((char *) name, "F6")) virtual_key = VK_F6;
    else if(!strcmp((char *) name, "F7")) virtual_key = VK_F7;
    else if(!strcmp((char *) name, "F8")) virtual_key = VK_F8;
    else if(!strcmp((char *) name, "F9")) virtual_key = VK_F9;
    else if(!strcmp((char *) name, "F10")) virtual_key = VK_F10;
    else if(!strcmp((char *) name, "F11")) virtual_key = VK_F11;
    else if(!strcmp((char *) name, "F12")) virtual_key = VK_F12;
    else virtual_key = 0;
    //UINT scan_code = MapVirtualKey(virtual_key, MAPVK_VK_TO_VSC);
    //return scan_code;
    return virtual_key;
}


utf8 *ef_input_keycode_string(EF_Keycode keycode,
			      EF_Modifiers modifiers,
			      EF_Dead_Key_State *dead_key_state)
{
    // TODO
}


static LRESULT CALLBACK window_procedure(HWND window,
					 UINT message,
					 WPARAM wParam,
					 LPARAM lParam)
{
    static struct event *saved_key_event = NULL;
    static WPARAM last_dead_character = '\0';
    static int append_character_instead_of_replacing = 0;
    static utf8 character_buffer[13] = { '\0' };
    static int click_button = -1;
    static uint64_t click_start_time = 0;
    static int click_count = 1;
    static struct drawable *mouse_drawable = NULL;

    struct drawable *drawable = NULL;
    for(size_t i = 0; i < n_drawables; i++) {
	if(all_drawables[i]->window == window) {
	    drawable = all_drawables[i];
	    break;
	}
    }
    
    switch(message) {
    case WM_CREATE:
	return 0;
	
    case WM_CLOSE:
	if(drawable) {
	    ef_drawable_delete((EF_Drawable) drawable);
	    PostQuitMessage(0);
	}
	return 0;
	
    case WM_DESTROY:
	return 0;

    case WM_PAINT:
	{
	    PAINTSTRUCT paint;
	    BeginPaint(window, &paint);
	    if(drawable) {
		if(drawable->draw_callback) {
		ef_drawable_make_current((EF_Drawable) drawable);
		drawable->draw_callback((EF_Drawable) drawable,
					drawable->draw_callback_context);
		}
	    }
	    EndPaint(window, &paint);
	    return 0;
	}
	
    case WM_KEYDOWN:
    case WM_SYSKEYDOWN:
	if(!is_modifier_keycode(wParam)) {
	    struct event *event = malloc(sizeof(struct event));
	    event->timestamp = ef_time_unix_epoch();
	    event->modifiers = get_modifiers();
	    event->data.key_event.keycode
		= (EF_Keycode) wParam;
		//= (EF_Keycode) MapVirtualKey(wParam, MAPVK_VK_TO_VSC);
	    event->data.key_event.string = (utf8 *) "";
	    event->data.key_event.string = NULL;

	    if(saved_key_event) {
		free(saved_key_event);
		saved_key_event = NULL;
	    }
	    saved_key_event = event;

	    if(is_noncharacter_keycode(wParam)) {
		if(drawable && drawable->key_down_callback) {
		    drawable->key_down_callback(drawable,
						(EF_Event) event,
						drawable->key_down_callback_context);
		}
	    }
	}
	if(message == WM_SYSKEYDOWN) {
	    return DefWindowProc(window, message, wParam, lParam);
	} else {
	    return 0;
	}

    case WM_KEYUP:
    case WM_SYSKEYUP:
	if(saved_key_event && drawable && drawable->key_up_callback
	   && !is_modifier_keycode(wParam) && !last_dead_character)
	{
	    saved_key_event->timestamp = ef_time_unix_epoch();
	    saved_key_event->data.key_event.string = character_buffer;
	    drawable->key_up_callback(drawable,
					(EF_Event) saved_key_event,
					drawable->key_up_callback_context);
	    
	    free(saved_key_event);
	    saved_key_event = NULL;
	}
	if(message == WM_SYSKEYUP) {
	    return DefWindowProc(window, message, wParam, lParam);
	} else {
	    return 0;
	}
	
    case WM_CHAR:
    case WM_SYSCHAR:
	{
	    utf8 *point = character_buffer;
	    if(append_character_instead_of_replacing) {
		while(*point) point++;
	    }
	    utf16 temp16[2];
	    temp16[0] = wParam;
	    temp16[1] = '\0';
	    utf8 *temp8 = utf16_to_utf8(temp16);
	    utf8_cpy(point, temp8);
	    free(temp8);
	}
	
	if(last_dead_character == wParam) {
	    append_character_instead_of_replacing = 1;
	} else {
	    append_character_instead_of_replacing = 0;
	    
	    if(saved_key_event && drawable && drawable->key_down_callback) {
		saved_key_event->data.key_event.string = character_buffer;
		drawable->key_down_callback(drawable,
					    (EF_Event) saved_key_event,
					    drawable->key_down_callback_context);
	    }
	}
	last_dead_character = '\0';
	
	return 0;
	
    case WM_DEADCHAR:
    case WM_SYSDEADCHAR:
	last_dead_character = wParam;
	return 0;

    case WM_LBUTTONDOWN:
    case WM_RBUTTONDOWN:
    case WM_MBUTTONDOWN:
    case WM_XBUTTONDOWN:
	{
	    SetCapture(window);
	    
	    struct event *event = malloc(sizeof(struct event));
	    
	    event->timestamp = ef_time_unix_epoch();
	    event->modifiers = get_modifiers();
	    
	    switch(message) {
	    case WM_LBUTTONDOWN:
		event->data.mouse_event.button_number = 0;
		break;
	    case WM_RBUTTONDOWN:
		event->data.mouse_event.button_number = 1;
		break;
	    case WM_MBUTTONDOWN:
		event->data.mouse_event.button_number = 2;
		break;
	    case WM_XBUTTONDOWN:
		switch((wParam >> 16) & 0xFFFF) {
		case XBUTTON1:
		    event->data.mouse_event.button_number = 3;
		    break;
		case XBUTTON2:
		    event->data.mouse_event.button_number = 4;
		    break;
		default:
		    event->data.mouse_event.button_number = 5;
		    break;
		}
		break;
	    }

	    int starts_a_click;
	    if(click_button == -1) {
		starts_a_click = 1;
		click_button = event->data.mouse_event.button_number;
	    } else {
		starts_a_click = 0;
	    }
	    
	    if(event->timestamp - click_start_time < GetDoubleClickTime())
		click_count++;
	    else
		click_count = 1;
	    click_start_time = event->timestamp;
	    event->data.mouse_event.click_count = click_count;
	    
	    RECT client_rect;
	    GetClientRect(window, &client_rect);

	    event->data.mouse_event.x = (lParam & 0xFFFF);
	    event->data.mouse_event.y = client_rect.bottom - ((lParam >> 16) & 0xFFFF);
	    
	    if(starts_a_click && drawable && drawable->mouse_down_callback) {
		drawable->mouse_down_callback(drawable,
					      (EF_Event) event,
					      drawable->mouse_down_callback_context);
	    }
	    
	    free(event);
	}
	return 0;
	
    case WM_LBUTTONUP:
    case WM_RBUTTONUP:
    case WM_MBUTTONUP:
    case WM_XBUTTONUP:
	{
	    ReleaseCapture();
	    
	    struct event *event = malloc(sizeof(struct event));
	    
	    event->timestamp = ef_time_unix_epoch();
	    event->modifiers = get_modifiers();
	    
	    switch(message) {
	    case WM_LBUTTONUP:
		event->data.mouse_event.button_number = 0;
		break;
	    case WM_RBUTTONUP:
		event->data.mouse_event.button_number = 1;
		break;
	    case WM_MBUTTONUP:
		event->data.mouse_event.button_number = 2;
		break;
	    case WM_XBUTTONUP:
		switch((wParam >> 16) & 0xFFFF) {
		case XBUTTON1:
		    event->data.mouse_event.button_number = 3;
		    break;
		case XBUTTON2:
		    event->data.mouse_event.button_number = 4;
		    break;
		default:
		    event->data.mouse_event.button_number = 5;
		    break;
		}
		break;
	    }
	    
	    int ends_a_click;
	    if(click_button == event->data.mouse_event.button_number) {
		ends_a_click = 1;
		click_button = -1;
	    } else {
		ends_a_click = 0;
	    }
	    
	    event->data.mouse_event.click_count = click_count;
	    
	    RECT client_rect;
	    GetClientRect(window, &client_rect);
	    
	    event->data.mouse_event.x = (lParam & 0xFFFF);
	    event->data.mouse_event.y = client_rect.bottom - ((lParam >> 16) & 0xFFFF);
	    
	    if(ends_a_click && drawable && drawable->mouse_up_callback) {
		drawable->mouse_up_callback(drawable,
					    (EF_Event) event,
					    drawable->mouse_up_callback_context);
	    }
	    
	    free(event);
	}
	return 0;

    case WM_MOUSEMOVE:
	{
	    click_start_time = 0;

	    struct event *event = malloc(sizeof(struct event));
	    
	    event->timestamp = ef_time_unix_epoch();
	    event->modifiers = get_modifiers();
	    event->data.mouse_event.button_number = 0;
	    event->data.mouse_event.click_count = 0;

	    RECT client_rect;
	    GetClientRect(window, &client_rect);
	    
	    event->data.mouse_event.x = (lParam & 0xFFFF);
	    event->data.mouse_event.y = client_rect.bottom - ((lParam >> 16) & 0xFFFF);

	    if(mouse_drawable != drawable) {
		TRACKMOUSEEVENT trackmouseevent;
		trackmouseevent.cbSize = sizeof(trackmouseevent);
		trackmouseevent.dwFlags = TME_LEAVE;
		trackmouseevent.hwndTrack = drawable->window;
		trackmouseevent.dwHoverTime = 0;
		TrackMouseEvent(&trackmouseevent);
		
		if(drawable && drawable->mouse_enter_callback) {
		    drawable->mouse_enter_callback(drawable,
						   (EF_Event) event,
						 drawable->mouse_enter_callback_context);
		}
		
		mouse_drawable = drawable;
	    }
	    
	    if(drawable && drawable->mouse_move_callback) {
		drawable->mouse_move_callback(drawable,
					      (EF_Event) event,
					      drawable->mouse_move_callback_context);
	    }
	    
	    free(event);
	}
	return 0;
	
    case WM_MOUSELEAVE:
	if(drawable && drawable->mouse_exit_callback) {
	    struct event *event = malloc(sizeof(struct event));
	    
	    event->timestamp = ef_time_unix_epoch();
	    event->modifiers = get_modifiers();
	    event->data.mouse_event.button_number = 0;
	    event->data.mouse_event.click_count = 0;
	    event->data.mouse_event.x = 0;
	    event->data.mouse_event.y = 0;
	    
	    drawable->mouse_exit_callback(drawable,
					  (EF_Event) event,
					  drawable->mouse_exit_callback_context);

	    free(event);
	}
	mouse_drawable = NULL;
	return 0;
	
    default:
	return DefWindowProc(window, message, wParam, lParam);
    }
}


static EF_Modifiers get_modifiers() {
    EF_Modifiers result = 0;
    
    if(GetKeyState(VK_CAPITAL) & 0x0001)
	result |= EF_MODIFIER_CAPS_LOCK;
    if(GetKeyState(VK_SHIFT) & 0x8000)
	result |= EF_MODIFIER_SHIFT;
    if(GetKeyState(VK_CONTROL) & 0x8000)
	result |= EF_MODIFIER_CONTROL;
    if(GetKeyState(VK_MENU) & 0x8000)
	result |= EF_MODIFIER_ALT;
    
    return result;
}


static int is_modifier_keycode(WPARAM keycode) {
    switch(keycode) {
    case VK_CAPITAL:
    case VK_SHIFT:
    case VK_LSHIFT:
    case VK_RSHIFT:
    case VK_CONTROL:
    case VK_LCONTROL:
    case VK_RCONTROL:
    case VK_MENU:
    case VK_LMENU:
    case VK_RMENU:
    case VK_LWIN:
    case VK_RWIN:
	return 1;
    default: return 0;
    }
}


static int is_noncharacter_keycode(WPARAM keycode) {
    if(0 == MapVirtualKey(keycode, MAPVK_VK_TO_CHAR))
	return 1;
    else
	return 0;
}

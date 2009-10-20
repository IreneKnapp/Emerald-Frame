#include "Emerald-Frame.h"
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
};


static struct ef_drawable_parameters drawable_parameters;
static HINSTANCE hInstance;
static size_t n_drawables;
static struct drawable **all_drawables;


extern utf8 *ef_internal_application_name();


static LRESULT CALLBACK window_procedure(HWND window,
					 UINT message,
					 WPARAM wParam,
					 LPARAM lParam);


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
    
    hInstance = GetModuleHandle(NULL);
    
    WNDCLASS window_class;
    window_class.style = CS_OWNDC;
    window_class.lpfnWndProc = window_procedure;
    window_class.cbClsExtra = 0;
    window_class.cbWndExtra = 0;
    window_class.hInstance = hInstance;
    window_class.hIcon = LoadIcon(NULL, IDI_APPLICATION);
    window_class.hCursor = LoadCursor(NULL, IDC_ARROW);
    window_class.hbrBackground = (HBRUSH) GetStockObject(BLACK_BRUSH);
    window_class.lpszMenuName = NULL;
    window_class.lpszClassName = "Emerald Frame";
    RegisterClass(&window_class);
    
    return 0;
}


EF_Drawable ef_video_new_drawable(int width,
				  int height,
				  int full_screen,
				  EF_Display display)
{
    struct drawable *drawable = malloc(sizeof(struct drawable));
    
    drawable->window = CreateWindow("Emerald Frame",
				    ef_internal_application_name(),
				    WS_CAPTION | WS_POPUPWINDOW | WS_VISIBLE,
				    CW_USEDEFAULT, CW_USEDEFAULT,
				    width, height,
				    NULL, NULL, hInstance, NULL);
    
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

    SetWindowText(drawable->window, title);
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
    
    data = malloc(width*height*4);
    for(int y = 0; y < height; y++) {
	for(int x = 0; x < width; x++) {
	    int color = gdImageGetPixel(image, x, y);
	    data[(x + y*width)*4] = gdImageRed(image, color);
	    data[(x + y*width)*4+1] = gdImageGreen(image, color);
	    data[(x + y*width)*4+2] = gdImageBlue(image, color);
	    int alpha = (127 - gdImageAlpha(image, color)) * 2;
	    data[(x + y*width)*4+3] = alpha;
	}
    }
    
    glBindTexture(GL_TEXTURE_2D, id);
    
    glPixelStorei(GL_UNPACK_IMAGE_HEIGHT, height);
    
    if(build_mipmaps) {
	gluBuild2DMipmaps(GL_TEXTURE_2D,
			  pixel_format,
			  width, height,
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

    gdImageDestroy(image);

    glBindTexture(GL_TEXTURE_2D, 0);
}


EF_Error ef_video_load_texture_memory(uint8_t *bytes, size_t size,
				      GLuint id,
				      int build_mipmaps)
{
    // TODO
}


static LRESULT CALLBACK window_procedure(HWND window,
					 UINT message,
					 WPARAM wParam,
					 LPARAM lParam)
{
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
	return 0;

    default:
	return DefWindowProc(window, message, wParam, lParam);
    }
}

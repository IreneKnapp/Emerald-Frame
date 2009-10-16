{-# LANGUAGE ForeignFunctionInterface #-}
module Graphics.UI.EmeraldFrame where

import Data.ByteString
import Data.ByteString.UTF8
import Foreign
import Foreign.C

type Error = CInt
newtype Drawable = Drawable (Ptr ())
newtype Display = Display (Ptr ())
newtype Timer = Timer (Ptr ())
newtype Event = Event (Ptr ())
type Keycode = Word32
type Modifiers = Word32
type DeadKeyState = Word32
type CBoolean = CInt
type UTF8 = CChar
type UTF32 = Word32
type DrawCallback = Drawable -> Ptr () -> IO ()
type TimerCallback = Timer -> Ptr () -> IO ()
type EventCallback = Drawable -> Event -> Ptr () -> IO ()

errorParam :: Error
errorParam = 1
errorFile :: Error
errorFile = 2
errorImageData :: Error
errorImageData = 3
errorSoundData :: Error
errorSoundData = 4
errorInternal :: Error
errorInternal = 100

modifierCapsLock :: Modifiers
modifierCapsLock = 1
modifierShift :: Modifiers
modifierShift = 2
modifierControl :: Modifiers
modifierControl = 4
modifierAlt :: Modifiers
modifierAlt = 8
modifierCommand :: Modifiers
modifierCommand = 16


foreign import ccall "wrapper" mkDrawCallback
    :: DrawCallback -> IO (FunPtr DrawCallback)
foreign import ccall "wrapper" mkTimerCallback
    :: TimerCallback -> IO (FunPtr TimerCallback)
foreign import ccall "wrapper" mkEventCallback
    :: EventCallback -> IO (FunPtr EventCallback)


-- EF_Error ef_init(utf8 *application_name);
foreign import ccall safe "ef_init" init'
    :: Ptr UTF8 -> IO ()
init :: String -> IO ()
init string = do
  byteString <- return $ fromString string
  useAsCString byteString (\cString -> init' cString)

-- utf8 *ef_version_string();
foreign import ccall safe "ef_version_string" versionString'
    :: IO (Ptr UTF8)
versionString :: IO String
versionString = do
  cString <- versionString'
  byteString <- packCString cString
  return $ toString byteString

-- utf8 *ef_error_string(EF_Error error);
foreign import ccall safe "ef_error_string" errorString'
    :: Error -> IO (Ptr UTF8)
errorString :: Error -> IO String
errorString errorCode = do
  cString <- errorString' errorCode
  byteString <- packCString cString
  return $ toString byteString

-- void ef_main();
foreign import ccall safe "ef_main" main
    :: IO ()


foreign import ccall safe "ef_video_new_drawable" videoNewDrawable'
    :: CInt -> CInt -> CBoolean -> Display -> IO Drawable
foreign import ccall safe "ef_drawable_set_title" drawableSetTitle'
    :: Drawable -> Ptr UTF8 -> IO ()
foreign import ccall safe "ef_drawable_set_draw_callback" drawableSetDrawCallback'
    :: Drawable -> FunPtr DrawCallback -> Ptr () -> IO ()
foreign import ccall safe "ef_drawable_redraw" drawableRedraw
    :: Drawable -> IO ()
foreign import ccall safe "ef_drawable_make_current" drawableMakeCurrent
    :: Drawable -> IO ()
foreign import ccall safe "ef_drawable_swap_buffers" drawableSwapBuffers
    :: Drawable -> IO ()
foreign import ccall safe "ef_video_set_double_buffer" videoSetDoubleBuffer'
    :: CBoolean -> IO ()
foreign import ccall safe "ef_video_set_stereo" videoSetStereo'
    :: CBoolean -> IO ()
foreign import ccall safe "ef_video_set_aux_buffers" videoSetAuxBuffers
    :: CInt -> IO ()
foreign import ccall safe "ef_video_set_color_size" videoSetColorSize
    :: CInt -> IO ()
foreign import ccall safe "ef_video_set_alpha_size" videoSetAlphaSize
    :: CInt -> IO ()
foreign import ccall safe "ef_video_set_depth_size" videoSetDepthSize
    :: CInt -> IO ()
foreign import ccall safe "ef_video_set_stencil_size" videoSetStencilSize
    :: CInt -> IO ()
foreign import ccall safe "ef_video_set_accumulation_size" videoSetAccumulationSize
    :: CInt -> IO ()
foreign import ccall safe "ef_video_set_samples" videoSetSamples
    :: CInt -> IO ()
foreign import ccall safe "ef_video_set_aux_depth_stencil" videoSetAuxDepthStencil'
    :: CBoolean -> IO ()
foreign import ccall safe "ef_video_set_color_float" videoSetColorFloat'
    :: CBoolean -> IO ()
foreign import ccall safe "ef_video_set_multisample" videoSetMultisample'
    :: CBoolean -> IO ()
foreign import ccall safe "ef_video_set_supersample" videoSetSupersample'
    :: CBoolean -> IO ()
foreign import ccall safe "ef_video_set_sample_alpha" videoSetSampleAlpha'
    :: CBoolean -> IO ()
foreign import ccall safe "ef_video_current_display" videoCurrentDisplay
    :: IO Display
foreign import ccall safe "ef_video_next_display" videoNextDisplay'
    :: Display -> IO Display
foreign import ccall safe "ef_display_depth" displayDepth
    :: Display -> IO CInt
foreign import ccall safe "ef_display_width" displayWidth
    :: Display -> IO CInt
foreign import ccall safe "ef_display_height" displayHeight
    :: Display -> IO CInt
foreign import ccall safe "ef_video_load_texture_file" videoLoadTextureFile'
    :: Ptr UTF8 -> CUInt -> CBoolean -> IO Error
foreign import ccall safe "ef_video_load_texture_memory" videoLoadTextureMemory'
    :: Ptr () -> CSize -> CUInt -> CBoolean -> IO Error

{-
EF_Drawable ef_video_new_drawable(int width,
				  int height,
				  boolean full_screen,
				  EF_Display display);
void ef_drawable_set_title(EF_Drawable drawable, utf8 *title);
void ef_drawable_set_draw_callback(EF_Drawable drawable,
				   void (*callback)(EF_Drawable drawable,
						    void *context),
				   void *context);
void ef_drawable_redraw(EF_Drawable drawable);
void ef_drawable_make_current(EF_Drawable drawable);
void ef_drawable_swap_buffers(EF_Drawable drawable);
void ef_video_set_double_buffer(boolean double_buffer);
void ef_video_set_stereo(boolean stereo);
void ef_video_set_aux_buffers(int aux_buffers);
void ef_video_set_color_size(int color_size);
void ef_video_set_alpha_size(int alpha_size);
void ef_video_set_depth_size(int depth_size);
void ef_video_set_stencil_size(int stencil_size);
void ef_video_set_accumulation_size(int accumulation_size);
void ef_video_set_samples(int samples);
void ef_video_set_aux_depth_stencil(boolean aux_depth_stencil);
void ef_video_set_color_float(boolean color_float);
void ef_video_set_multisample(boolean multisample);
void ef_video_set_supersample(boolean supersample);
void ef_video_set_sample_alpha(boolean sample_alpha);
EF_Display ef_video_current_display();
EF_Display ef_video_next_display(EF_Display previous);
int ef_display_depth(EF_Display display);
int ef_display_width(EF_Display display);
int ef_display_height(EF_Display display);
EF_Error ef_video_load_texture_file(utf8 *filename, GLuint id, boolean build_mipmaps);
EF_Error ef_video_load_texture_memory(uint8_t *data, size_t size, GLuint id, boolean build_mipmaps);
-}


foreign import ccall safe "ef_audio_load_sound_file" audioLoadSoundFile'
    :: Ptr UTF8 -> CUInt -> IO Error
foreign import ccall safe "ef_audio_load_sound_memory" audioLoadSoundMemory'
    :: Ptr () -> CSize -> CUInt -> IO Error

{-
// Audio
EF_Error ef_audio_load_sound_file(utf8 *filename, ALuint id);
EF_Error ef_audio_load_sound_memory(uint8_t *data, size_t size, ALuint id);
-}


foreign import ccall safe "ef_time_new_oneshot_timer" newOneshotTimer
    :: CInt -> FunPtr TimerCallback -> Ptr () -> IO Timer
foreign import ccall safe "ef_time_new_repeating_timer" newRepeatingTimer
    :: CInt -> FunPtr TimerCallback -> Ptr () -> IO Timer
foreign import ccall safe "ef_timer_cancel" timerCancel
    :: Timer -> IO ()
foreign import ccall safe "ef_time_unix_epoch" timeUnixEpoch
    :: IO Word64

{-
// Time
EF_Timer ef_time_new_oneshot_timer(int milliseconds,
				   void (*callback)(EF_Timer timer, void *context),
				   void *context);
EF_Timer ef_time_new_repeating_timer(int milliseconds,
				     void (*callback)(EF_Timer timer, void *context),
				     void *context);
void ef_timer_cancel(EF_Timer timer);
uint64_t ef_time_unix_epoch();
-}


foreign import ccall safe "ef_input_set_key_down_callback" inputSetKeyDownCallback
    :: Drawable -> FunPtr EventCallback -> Ptr () -> IO ()
foreign import ccall safe "ef_input_set_key_up_callback" inputSetKeyUpCallback
    :: Drawable -> FunPtr EventCallback -> Ptr () -> IO ()
foreign import ccall safe "ef_input_set_mouse_down_callback" inputSetMouseDownCallback
    :: Drawable -> FunPtr EventCallback -> Ptr () -> IO ()
foreign import ccall safe "ef_input_set_mouse_up_callback" inputSetMouseUpCallback
    :: Drawable -> FunPtr EventCallback -> Ptr () -> IO ()
foreign import ccall safe "ef_input_set_mouse_move_callback" inputSetMouseMoveCallback
    :: Drawable -> FunPtr EventCallback -> Ptr () -> IO ()
foreign import ccall safe "ef_input_set_mouse_enter_callback" inputSetMouseEnterCallback
    :: Drawable -> FunPtr EventCallback -> Ptr () -> IO ()
foreign import ccall safe "ef_input_set_mouse_exit_callback" inputSetMouseExitCallback
    :: Drawable -> FunPtr EventCallback -> Ptr () -> IO ()
foreign import ccall safe "ef_event_timestamp" eventTimestamp
    :: Event -> IO Word32
foreign import ccall safe "ef_event_modifiers" eventModifiers
    :: Event -> IO Modifiers
foreign import ccall safe "ef_event_keycode" eventKeycode
    :: Event -> IO Keycode
foreign import ccall safe "ef_event_string" eventString'
    :: Event -> IO (Ptr UTF8)
foreign import ccall safe "ef_event_button_number" eventButtonNumber
    :: Event -> IO CInt
foreign import ccall safe "ef_event_click_count" eventClickCount
    :: Event -> IO CInt
foreign import ccall safe "ef_input_key_name" inputKeyName'
    :: Keycode -> IO (Ptr UTF8)
foreign import ccall safe "ef_input_keycode_string" inputKeycodeString'
    :: Keycode -> Modifiers -> Ptr DeadKeyState -> IO (Ptr UTF8)
foreign import ccall safe "ef_event_mouse_x" eventMouseX
    :: Event -> IO Int32
foreign import ccall safe "ef_event_mouse_y" eventMouseY
    :: Event -> IO Int32

{-
// Input
void ef_input_set_key_down_callback(EF_Drawable drawable,
				    void (*callback)(EF_Drawable drawable,
						     EF_Event event,
						     void *context),
				    void *context);
void ef_input_set_key_up_callback(EF_Drawable drawable,
				  void (*callback)(EF_Drawable drawable,
						   EF_Event event,
						   void *context),
				  void *context);
void ef_input_set_mouse_down_callback(EF_Drawable drawable,
				      void (*callback)(EF_Drawable drawable,
						       EF_Event event,
						       void *context),
				      void *context);
void ef_input_set_mouse_up_callback(EF_Drawable drawable,
				    void (*callback)(EF_Drawable drawable,
						     EF_Event event,
						     void *context),
				    void *context);
void ef_input_set_mouse_move_callback(EF_Drawable drawable,
				      void (*callback)(EF_Drawable drawable,
						       EF_Event event,
						       void *context),
				      void *context);
void ef_input_set_mouse_enter_callback(EF_Drawable drawable,
				       void (*callback)(EF_Drawable drawable,
							EF_Event event,
							void *context),
				       void *context);
void ef_input_set_mouse_exit_callback(EF_Drawable drawable,
				      void (*callback)(EF_Drawable drawable,
						       EF_Event event,
						       void *context),
				      void *context);
uint64_t ef_event_timestamp(EF_Event event);
EF_Modifiers ef_event_modifiers(EF_Event event);
EF_Keycode ef_event_keycode(EF_Event event);
utf8 *ef_event_string(EF_Event event);
int ef_event_button_number(EF_Event event);
int ef_event_click_count(EF_Event event);
utf8 *ef_input_key_name(EF_Keycode keycode);
EF_Keycode ef_input_keycode_by_name(utf8 *name);
utf8 *ef_input_keycode_string(EF_Keycode keycode,
			      EF_Modifiers modifiers,
			      EF_Dead_Key_State *dead_key_state);
int32_t ef_event_mouse_x(EF_Event event);
int32_t ef_event_mouse_y(EF_Event event);
-}


{-
// Text
-}


foreign import ccall safe "ef_configuration_resource_directory"
        configurationResourceDirectory'
    :: IO (Ptr UTF8)

{-
// Configuration
utf8 *ef_configuration_resource_directory();
-}


{-
// Pasteboard
-}

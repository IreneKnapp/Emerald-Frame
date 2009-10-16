{-# LANGUAGE ForeignFunctionInterface #-}
module Graphics.UI.EmeraldFrame where

import Data.ByteString
import Data.ByteString.UTF8
import Foreign
import Foreign.C
import qualified Graphics.Rendering.OpenGL as GL
import qualified Sound.OpenAL as AL
import Sound.OpenAL.AL.BufferInternal (marshalBuffer)

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


foreign import ccall safe "ef_init" init'
    :: Ptr UTF8 -> IO ()
init :: String -> IO ()
init string = do
  byteString <- return $ fromString string
  useAsCString byteString (\cString -> init' cString)

foreign import ccall safe "ef_version_string" versionString'
    :: IO (Ptr UTF8)
versionString :: IO String
versionString = do
  cString <- versionString'
  byteString <- packCString cString
  return $ toString byteString

foreign import ccall safe "ef_error_string" errorString'
    :: Error -> IO (Ptr UTF8)
errorString :: Error -> IO String
errorString errorCode = do
  cString <- errorString' errorCode
  byteString <- packCString cString
  return $ toString byteString

foreign import ccall safe "ef_main" main
    :: IO ()


foreign import ccall safe "ef_video_new_drawable" videoNewDrawable'
    :: CInt -> CInt -> CBoolean -> Display -> IO Drawable
videoNewDrawable :: CInt -> CInt -> Bool -> (Maybe Display) -> IO Drawable
videoNewDrawable width height fullScreen maybeDisplay = do
    fullScreen' <- return $ if fullScreen then 1 else 0
    display <- return $ case maybeDisplay of
                          Nothing -> Display nullPtr
                          Just display -> display
    videoNewDrawable' width height fullScreen' display

foreign import ccall safe "ef_drawable_set_title" drawableSetTitle'
    :: Drawable -> Ptr UTF8 -> IO ()
drawableSetTitle :: Drawable -> String -> IO ()
drawableSetTitle drawable string = do
  byteString <- return $ fromString string
  useAsCString byteString (\cString -> drawableSetTitle' drawable cString)

foreign import ccall safe "ef_drawable_set_draw_callback" drawableSetDrawCallback
    :: Drawable -> FunPtr DrawCallback -> Ptr () -> IO ()

foreign import ccall safe "ef_drawable_redraw" drawableRedraw
    :: Drawable -> IO ()

foreign import ccall safe "ef_drawable_make_current" drawableMakeCurrent
    :: Drawable -> IO ()

foreign import ccall safe "ef_drawable_swap_buffers" drawableSwapBuffers
    :: Drawable -> IO ()

foreign import ccall safe "ef_video_set_double_buffer" videoSetDoubleBuffer'
    :: CBoolean -> IO ()
videoSetDoubleBuffer :: Bool -> IO ()
videoSetDoubleBuffer doubleBuffer = do
    doubleBuffer' <- return $ if doubleBuffer then 1 else 0
    videoSetDoubleBuffer' doubleBuffer'

foreign import ccall safe "ef_video_set_stereo" videoSetStereo'
    :: CBoolean -> IO ()
videoSetStereo :: Bool -> IO ()
videoSetStereo stereo = do
    stereo' <- return $ if stereo then 1 else 0
    videoSetStereo' stereo'

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
videoSetAuxDepthStencil :: Bool -> IO ()
videoSetAuxDepthStencil auxDepthStencil = do
    auxDepthStencil' <- return $ if auxDepthStencil then 1 else 0
    videoSetStereo' auxDepthStencil'

foreign import ccall safe "ef_video_set_color_float" videoSetColorFloat'
    :: CBoolean -> IO ()
videoSetColorFloat :: Bool -> IO ()
videoSetColorFloat colorFloat = do
    colorFloat' <- return $ if colorFloat then 1 else 0
    videoSetColorFloat' colorFloat'

foreign import ccall safe "ef_video_set_multisample" videoSetMultisample'
    :: CBoolean -> IO ()
videoSetMultisample :: Bool -> IO ()
videoSetMultisample multisample = do
    multisample' <- return $ if multisample then 1 else 0
    videoSetMultisample' multisample'

foreign import ccall safe "ef_video_set_supersample" videoSetSupersample'
    :: CBoolean -> IO ()
videoSetSupersample :: Bool -> IO ()
videoSetSupersample supersample = do
    supersample' <- return $ if supersample then 1 else 0
    videoSetSupersample' supersample'

foreign import ccall safe "ef_video_set_sample_alpha" videoSetSampleAlpha'
    :: CBoolean -> IO ()
videoSetSampleAlpha :: Bool -> IO ()
videoSetSampleAlpha sampleAlpha = do
    sampleAlpha' <- return $ if sampleAlpha then 1 else 0
    videoSetSampleAlpha' sampleAlpha'

foreign import ccall safe "ef_video_current_display" videoCurrentDisplay
    :: IO Display

foreign import ccall safe "ef_video_next_display" videoNextDisplay'
    :: Display -> IO Display
videoNextDisplay :: (Maybe Display) -> IO Display
videoNextDisplay maybeDisplay = do
    display <- return $ case maybeDisplay of
                          Nothing -> Display nullPtr
                          Just display -> display
    videoNextDisplay' display

foreign import ccall safe "ef_display_depth" displayDepth
    :: Display -> IO CInt

foreign import ccall safe "ef_display_width" displayWidth
    :: Display -> IO CInt

foreign import ccall safe "ef_display_height" displayHeight
    :: Display -> IO CInt

foreign import ccall safe "ef_video_load_texture_file" videoLoadTextureFile'
    :: Ptr UTF8 -> CUInt -> CBoolean -> IO Error
videoLoadTextureFile :: String -> GL.TextureObject -> Bool -> IO Error
videoLoadTextureFile string textureObject buildMipmaps = do
  GL.TextureObject theID <- return textureObject
  byteString <- return $ fromString string
  buildMipmaps' <- return $ if buildMipmaps then 1 else 0
  useAsCString byteString
               (\cString -> videoLoadTextureFile' cString
                                                  (fromIntegral theID)
                                                  buildMipmaps')

foreign import ccall safe "ef_video_load_texture_memory" videoLoadTextureMemory'
    :: Ptr () -> CSize -> CUInt -> CBoolean -> IO Error
videoLoadTextureMemory :: Ptr () -> CSize -> GL.TextureObject -> Bool -> IO Error
videoLoadTextureMemory pointer size textureObject buildMipmaps = do
  GL.TextureObject theID <- return textureObject
  buildMipmaps' <- return $ if buildMipmaps then 1 else 0
  videoLoadTextureMemory' pointer size (fromIntegral theID) buildMipmaps'


foreign import ccall safe "ef_audio_load_sound_file" audioLoadSoundFile'
    :: Ptr UTF8 -> CUInt -> IO Error
audioLoadSoundFile :: String -> AL.Buffer -> IO Error
audioLoadSoundFile string bufferObject = do
  theID <- return $ fromIntegral $ marshalBuffer $ Just bufferObject
  byteString <- return $ fromString string
  useAsCString byteString (\cString -> audioLoadSoundFile' cString theID)

foreign import ccall safe "ef_audio_load_sound_memory" audioLoadSoundMemory'
    :: Ptr () -> CSize -> CUInt -> IO Error
audioLoadSoundMemory :: Ptr () -> CSize -> AL.Buffer -> IO Error
audioLoadSoundMemory pointer size bufferObject = do
  theID <- return $ fromIntegral $ marshalBuffer $ Just bufferObject
  audioLoadSoundMemory' pointer size theID

foreign import ccall safe "ef_time_new_oneshot_timer" newOneshotTimer
    :: CInt -> FunPtr TimerCallback -> Ptr () -> IO Timer

foreign import ccall safe "ef_time_new_repeating_timer" newRepeatingTimer
    :: CInt -> FunPtr TimerCallback -> Ptr () -> IO Timer

foreign import ccall safe "ef_timer_cancel" timerCancel
    :: Timer -> IO ()

foreign import ccall safe "ef_time_unix_epoch" timeUnixEpoch
    :: IO Word64


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
eventString :: Event -> IO String
eventString event = do
  cString <- eventString' event
  byteString <- packCString cString
  return $ toString byteString

foreign import ccall safe "ef_event_button_number" eventButtonNumber
    :: Event -> IO CInt

foreign import ccall safe "ef_event_click_count" eventClickCount
    :: Event -> IO CInt

foreign import ccall safe "ef_input_key_name" inputKeyName'
    :: Keycode -> IO (Ptr UTF8)
inputKeyName :: Keycode -> IO String
inputKeyName keycode = do
  cString <- inputKeyName' keycode
  byteString <- packCString cString
  return $ toString byteString

foreign import ccall safe "ef_input_keycode_string" inputKeycodeString'
    :: Keycode -> Modifiers -> Ptr DeadKeyState -> IO (Ptr UTF8)
inputKeycodeString :: Keycode -> Modifiers -> Ptr DeadKeyState -> IO String
inputKeycodeString keycode modifiers deadKeyStatePtr = do
  cString <- inputKeycodeString' keycode modifiers deadKeyStatePtr
  byteString <- packCString cString
  return $ toString byteString

foreign import ccall safe "ef_event_mouse_x" eventMouseX
    :: Event -> IO Int32

foreign import ccall safe "ef_event_mouse_y" eventMouseY
    :: Event -> IO Int32


foreign import ccall safe "ef_configuration_resource_directory"
        configurationResourceDirectory'
    :: IO (Ptr UTF8)
configurationResourceDirectory :: IO String
configurationResourceDirectory = do
  cString <- configurationResourceDirectory'
  byteString <- packCString cString
  return $ toString byteString

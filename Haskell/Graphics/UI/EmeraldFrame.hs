{-# LANGUAGE ForeignFunctionInterface #-}
{-# OPTIONS_GHC -fno-warn-unused-binds #-}
module Graphics.UI.EmeraldFrame (
                                 Drawable,
                                 Display,
                                 Timer,
                                 Event,
                                 Font,
                                 TextFlow,
                                 TextAttributes,
                                 ParagraphStyle,
                                 Keycode,
                                 DeadKeyState,
                                 Glyph,
                                 Error(..),
                                 Modifier(..),
                                 FontWeight(..),
                                 FontTrait(..),
                                 TextAttributeIdentifier(..),
                                 UnderlineStyle(..),
                                 StrikethroughStyle(..),
                                 LigatureStyle(..),
                                 OutlineStyle(..),
                                 ParagraphAlignment(..),
                                 mkDrawCallback,
                                 mkTimerCallback,
                                 mkEventCallback,
                                 init,
                                 versionString,
                                 errorString,
                                 main,
                                 videoNewDrawable,
                                 drawableSetTitle,
                                 drawableSetDrawCallback,
                                 drawableRedraw,
                                 drawableMakeCurrent,
                                 drawableSwapBuffers,
                                 videoSetDoubleBuffer,
                                 videoSetStereo,
                                 videoSetAuxBuffers,
                                 videoSetColorSize,
                                 videoSetAlphaSize,
                                 videoSetDepthSize,
                                 videoSetStencilSize,
                                 videoSetAccumulationSize,
                                 videoSetSamples,
                                 videoSetAuxDepthStencil,
                                 videoSetColorFloat,
                                 videoSetMultisample,
                                 videoSetSupersample,
                                 videoSetSampleAlpha,
                                 videoCurrentDisplay,
                                 videoNextDisplay,
                                 displayDepth,
                                 displayWidth,
                                 displayHeight,
                                 videoLoadTextureFile,
                                 videoLoadTextureMemory,
                                 audioLoadSoundFile,
                                 audioLoadSoundMemory,
                                 timeNewOneshotTimer,
                                 timeNewRepeatingTimer,
                                 timerCancel,
                                 timeUnixEpoch,
                                 inputSetKeyDownCallback,
                                 inputSetKeyUpCallback,
                                 inputSetMouseDownCallback,
                                 inputSetMouseUpCallback,
                                 inputSetMouseMoveCallback,
                                 inputSetMouseEnterCallback,
                                 inputSetMouseExitCallback,
                                 eventTimestamp,
                                 eventModifiers,
                                 eventKeycode,
                                 eventString,
                                 eventButtonNumber,
                                 eventClickCount,
                                 inputKeyName,
                                 inputKeycodeByName,
                                 inputKeycodeString,
                                 eventMouseX,
                                 eventMouseY,
                                 textComputeAvailableFonts,
                                 textComputeAvailableFontFamilies,
                                 textComputeAvailableFontsWithTraits,
                                 textComputeAvailableMembersOfFontFamily,
                                 textComputedCount,
                                 textComputedNameN,
                                 textComputedStyleNameN,
                                 textComputedWeightN,
                                 textComputedTraitsN,
                                 textDiscardComputed,
                                 textSpecificFont,
                                 fontDelete,
                                 fontName,
                                 fontFamilyName,
                                 fontDisplayName,
                                 fontTraits,
                                 fontWeight,
                                 fontConvertToFace,
                                 fontConvertToFamily,
                                 fontConvertToHaveTraits,
                                 fontConvertToNotHaveTraits,
                                 fontConvertToSize,
                                 fontConvertToLighterWeight,
                                 fontConvertToHeavierWeight,
                                 fontHorizontalAdvancementForGlyph,
                                 fontVerticalAdvancementForGlyph,
                                 fontAscender,
                                 fontDescender,
                                 fontXHeight,
                                 fontCapHeight,
                                 fontItalicAngle,
                                 fontLeading,
                                 fontMaximumHorizontalAdvancement,
                                 fontMaximumVerticalAdvancement,
                                 fontUnderlinePosition,
                                 fontUnderlineThickness,
                                 fontBoundingRectangle,
                                 fontGlyphBoundingRectangle,
                                 textNewTextFlow,
                                 textNewTextFlowWithText,
                                 textNewTextFlowWithTextAndAttributes,
                                 textFlowDelete,
                                 textFlowText,
                                 textFlowLength,
                                 textFlowAttributesAtIndex,
                                 textFlowEnumerateAttributes,
                                 textFlowReplaceText,
                                 textFlowDeleteText,
                                 textFlowSetAttributes,
                                 textFlowRemoveAttribute,
                                 textFlowNaturalSize,
                                 textFlowSize,
                                 textFlowSetSize,
                                 textFlowDraw,
                                 textNewAttributes,
                                 textAttributesDelete,
                                 textAttributesFont,
                                 textAttributesParagraphStyle,
                                 textAttributesForegroundColor,
                                 textAttributesBackgroundColor,
                                 textAttributesUnderlineStyle,
                                 textAttributesUnderlineIsColored,
                                 textAttributesUnderlineColor,
                                 textAttributesStrikethroughStyle,
                                 textAttributesStrikethroughIsColored,
                                 textAttributesStrikethroughColor,
                                 textAttributesLigatureStyle,
                                 textAttributesBaselineOffset,
                                 textAttributesKerningIsDefault,
                                 textAttributesKerning,
                                 textAttributesOutlineStyle,
                                 textAttributesStrokeWidth,
                                 textAttributesStrokeIsColored,
                                 textAttributesStrokeColor,
                                 textAttributesObliqueness,
                                 textAttributesExpansion,
                                 textAttributesSetFont,
                                 textAttributesSetParagraphStyle,
                                 textAttributesSetForegroundColor,
                                 textAttributesSetBackgroundColor,
                                 textAttributesSetUnderlineStyle,
                                 textAttributesSetUnderlineColor,
                                 textAttributesSetStrikethroughStyle,
                                 textAttributesSetStrikethroughColor,
                                 textAttributesSetLigatureStyle,
                                 textAttributesSetBaselineOffset,
                                 textAttributesSetKerning,
                                 textAttributesSetOutlineStyle,
                                 textAttributesSetStrokeWidth,
                                 textAttributesSetStrokeColor,
                                 textAttributesSetObliqueness,
                                 textAttributesSetExpansion,
                                 textAttributesUnsetFont,
                                 textAttributesUnsetParagraphStyle,
                                 textAttributesUnsetForegroundColor,
                                 textAttributesUnsetBackgroundColor,
                                 textAttributesUnsetUnderlineStyle,
                                 textAttributesUnsetUnderlineColor,
                                 textAttributesUnsetStrikethroughStyle,
                                 textAttributesUnsetStrikethroughColor,
                                 textAttributesUnsetLigatureStyle,
                                 textAttributesUnsetBaselineOffset,
                                 textAttributesUnsetKerning,
                                 textAttributesUnsetOutlineStyle,
                                 textAttributesUnsetStrokeWidth,
                                 textAttributesUnsetStrokeColor,
                                 textAttributesUnsetObliqueness,
                                 textAttributesUnsetExpansion,
                                 textNewParagraphStyle,
                                 paragraphStyleDelete,
                                 paragraphStyleAlignment,
                                 paragraphStyleFirstLineHeadIndent,
                                 paragraphStyleHeadIndent,
                                 paragraphStyleTailIndent,
                                 paragraphStyleLineHeightMultiple,
                                 paragraphStyleMinimumLineHeight,
                                 paragraphStyleHasMaximumLineHeight,
                                 paragraphStyleMaximumLineHeight,
                                 paragraphStyleLineSpacing,
                                 paragraphStyleParagraphSpacing,
                                 paragraphStyleParagraphSpacingBefore,
                                 paragraphStyleSetAlignment,
                                 paragraphStyleSetFirstLineHeadIndent,
                                 paragraphStyleSetHeadIndent,
                                 paragraphStyleSetTailIndent,
                                 paragraphStyleSetLineHeightMultiple,
                                 paragraphStyleSetMinimumLineHeight,
                                 paragraphStyleSetNoMaximumLineHeight,
                                 paragraphStyleSetMaximumLineHeight,
                                 paragraphStyleSetLineSpacing,
                                 paragraphStyleSetParagraphSpacing,
                                 paragraphStyleSetParagraphSpacingBefore,
                                 configurationResourceDirectory
                                )
    where
  
import Data.Bits
import Data.ByteString hiding (concat, map, foldl, init)
import Data.ByteString.UTF8 hiding (decode, foldl)
import Foreign
import Foreign.C
import qualified Graphics.Rendering.OpenGL as GL
import Prelude hiding (error, init)
import qualified Sound.OpenAL as AL
import Sound.OpenAL.AL.BufferInternal (marshalBuffer)

newtype Drawable = Drawable (Ptr ())
newtype Display = Display (Ptr ())
newtype Timer = Timer (Ptr ())
newtype Event = Event (Ptr ())
newtype Font = Font (Ptr ())
newtype TextFlow = TextFlow (Ptr ())
newtype TextAttributes = TextAttributes (Ptr ())
newtype ParagraphStyle = ParagraphStyle (Ptr ())
type Keycode = Word32
type DeadKeyState = Word32
type Glyph = Word32
data Error = ErrorParam
           | ErrorFile
           | ErrorImageData
           | ErrorSoundData
           | ErrorInternal
             deriving (Eq, Show)
data Modifier = ModifierCapsLock
              | ModifierShift
              | ModifierControl
              | ModifierAlt
              | ModifierCommand
                deriving (Eq, Show)
data FontWeight = FontWeightUltralight
                | FontWeightThin
                | FontWeightLight
                | FontWeightBook
                | FontWeightRegular
                | FontWeightMedium
                | FontWeightDemibold
                | FontWeightSemibold
                | FontWeightBold
                | FontWeightExtrabold
                | FontWeightHeavy
                | FontWeightBlack
                | FontWeightUltrablack
                | FontWeightExtrablack
                | FontWeightW1
                | FontWeightW2
                | FontWeightW3
                | FontWeightW4
                | FontWeightW5
                | FontWeightW6
                | FontWeightW7
                | FontWeightW8
                | FontWeightW9
                  deriving (Eq, Show)
data FontTrait = FontTraitItalic
               | FontTraitBold
               | FontTraitExpanded
               | FontTraitCondensed
               | FontTraitFixedPitch
                 deriving (Eq, Show)
data TextAttributeIdentifier = TextAttributeFont
                             | TextAttributeParagraphStyle
                             | TextAttributeForegroundColor
                             | TextAttributeBackgroundColor
                             | TextAttributeUnderlineStyle
                             | TextAttributeUnderlineColor
                             | TextAttributeStrikethroughStyle
                             | TextAttributeStrikethroughColor
                             | TextAttributeLigatureStyle
                             | TextAttributeBaselineOffset
                             | TextAttributeKerning
                             | TextAttributeOutlineStyle
                             | TextAttributeStrokeWidth
                             | TextAttributeObliqueness
                             | TextAttributeExpansion
                               deriving (Eq, Show)
data UnderlineStyle = UnderlineStyleNone
                    | UnderlineStyleSingle
                    | UnderlineStyleDouble
                    | UnderlineStyleThick
                      deriving (Eq, Show)
data StrikethroughStyle = StrikethroughStyleNone
                        | StrikethroughStyleSingle
                        | StrikethroughStyleDouble
                        | StrikethroughStyleThick
                          deriving (Eq, Show)
data LigatureStyle = LigatureStyleNone
                   | LigatureStyleStandard
                   | LigatureStyleAll
                     deriving (Eq, Show)
data OutlineStyle = OutlineStyleFillOnly
                  | OutlineStyleStrokeOnly
                  | OutlineStyleStrokeAndFill
                    deriving (Eq, Show)
data ParagraphAlignment = ParagraphAlignmentLeft
                        | ParagraphAlignmentCenter
                        | ParagraphAlignmentRight
                        | ParagraphAlignmentJustified
                          deriving (Eq, Show)
type UTF8 = CChar
type UTF32 = Word32
type DrawCallback = Drawable -> Ptr () -> IO ()
type TimerCallback = Timer -> Ptr () -> IO ()
type EventCallback = Drawable -> Event -> Ptr () -> IO ()

class Encodable a where
    encode :: a -> Word32
    decode :: Word32 -> a

instance Encodable Error where
    encode ErrorParam = 1
    encode ErrorFile = 2
    encode ErrorImageData = 3
    encode ErrorSoundData = 4
    encode ErrorInternal = 100
    decode 1 = ErrorParam
    decode 2 = ErrorFile
    decode 3 = ErrorImageData
    decode 4 = ErrorSoundData
    decode 100 = ErrorInternal
    decode _ = undefined

instance Encodable Modifier where
    encode ModifierCapsLock = 1
    encode ModifierShift = 2
    encode ModifierControl = 4
    encode ModifierAlt = 8
    encode ModifierCommand = 16
    decode 1 = ModifierCapsLock
    decode 2 = ModifierShift
    decode 4 = ModifierControl
    decode 8 = ModifierAlt
    decode 16 = ModifierCommand
    decode _ = undefined

instance Encodable FontWeight where
    encode FontWeightUltralight = 1
    encode FontWeightThin = 2
    encode FontWeightLight = 3
    encode FontWeightBook = 4
    encode FontWeightRegular = 5
    encode FontWeightMedium = 6
    encode FontWeightDemibold = 7
    encode FontWeightSemibold = 8
    encode FontWeightBold = 9
    encode FontWeightExtrabold = 10
    encode FontWeightHeavy = 11
    encode FontWeightBlack = 12
    encode FontWeightUltrablack = 13
    encode FontWeightExtrablack = 14
    encode FontWeightW1 = 2
    encode FontWeightW2 = 3
    encode FontWeightW3 = 4
    encode FontWeightW4 = 5
    encode FontWeightW5 = 6
    encode FontWeightW6 = 8
    encode FontWeightW7 = 9
    encode FontWeightW8 = 10
    encode FontWeightW9 = 12
    decode 1 = FontWeightUltralight
    decode 2 = FontWeightThin
    decode 3 = FontWeightLight
    decode 4 = FontWeightBook
    decode 5 = FontWeightRegular
    decode 6 = FontWeightMedium
    decode 7 = FontWeightDemibold
    decode 8 = FontWeightSemibold
    decode 9 = FontWeightBold
    decode 10 = FontWeightExtrabold
    decode 11 = FontWeightHeavy
    decode 12 = FontWeightBlack
    decode 13 = FontWeightUltrablack
    decode 14 = FontWeightExtrablack
    decode _ = undefined

instance Encodable FontTrait where
    encode FontTraitItalic = 0x0001
    encode FontTraitBold = 0x0002
    encode FontTraitExpanded = 0x0010
    encode FontTraitCondensed = 0x0020
    encode FontTraitFixedPitch = 0x0040
    decode 0x0001 = FontTraitItalic
    decode 0x0002 = FontTraitBold
    decode 0x0010 = FontTraitExpanded
    decode 0x0020 = FontTraitCondensed
    decode 0x0040 = FontTraitFixedPitch
    decode _ = undefined

instance Encodable TextAttributeIdentifier where
    encode TextAttributeFont = 1
    encode TextAttributeParagraphStyle = 2
    encode TextAttributeForegroundColor = 3
    encode TextAttributeBackgroundColor = 4
    encode TextAttributeUnderlineStyle = 5
    encode TextAttributeUnderlineColor = 6
    encode TextAttributeStrikethroughStyle = 7
    encode TextAttributeStrikethroughColor = 8
    encode TextAttributeLigatureStyle = 9
    encode TextAttributeBaselineOffset = 10
    encode TextAttributeKerning = 11
    encode TextAttributeOutlineStyle = 12
    encode TextAttributeStrokeWidth = 13
    encode TextAttributeObliqueness = 14
    encode TextAttributeExpansion = 15
    decode 1 = TextAttributeFont
    decode 2 = TextAttributeParagraphStyle
    decode 3 = TextAttributeForegroundColor
    decode 4 = TextAttributeBackgroundColor
    decode 5 = TextAttributeUnderlineStyle
    decode 6 = TextAttributeUnderlineColor
    decode 7 = TextAttributeStrikethroughStyle
    decode 8 = TextAttributeStrikethroughColor
    decode 9 = TextAttributeLigatureStyle
    decode 10 = TextAttributeBaselineOffset
    decode 11 = TextAttributeKerning
    decode 12 = TextAttributeOutlineStyle
    decode 13 = TextAttributeStrokeWidth
    decode 14 = TextAttributeObliqueness
    decode 15 = TextAttributeExpansion
    decode _ = undefined

instance Encodable UnderlineStyle where
    encode UnderlineStyleNone = 0
    encode UnderlineStyleSingle = 1
    encode UnderlineStyleDouble = 2
    encode UnderlineStyleThick = 3
    decode 0 = UnderlineStyleNone
    decode 1 = UnderlineStyleSingle
    decode 2 = UnderlineStyleDouble
    decode 3 = UnderlineStyleThick
    decode _ = undefined

instance Encodable StrikethroughStyle where
    encode StrikethroughStyleNone = 0
    encode StrikethroughStyleSingle = 1
    encode StrikethroughStyleDouble = 2
    encode StrikethroughStyleThick = 3
    decode 0 = StrikethroughStyleNone
    decode 1 = StrikethroughStyleSingle
    decode 2 = StrikethroughStyleDouble
    decode 3 = StrikethroughStyleThick
    decode _ = undefined

instance Encodable LigatureStyle where
    encode LigatureStyleNone = 0
    encode LigatureStyleStandard = 1
    encode LigatureStyleAll = 2
    decode 0 = LigatureStyleNone
    decode 1 = LigatureStyleStandard
    decode 2 = LigatureStyleAll
    decode _ = undefined

instance Encodable OutlineStyle where
    encode OutlineStyleFillOnly = 0
    encode OutlineStyleStrokeOnly = 1
    encode OutlineStyleStrokeAndFill = 2
    decode 0 = OutlineStyleFillOnly
    decode 1 = OutlineStyleStrokeOnly
    decode 2 = OutlineStyleStrokeAndFill
    decode _ = undefined

instance Encodable ParagraphAlignment where
    encode ParagraphAlignmentLeft = 0
    encode ParagraphAlignmentCenter = 1
    encode ParagraphAlignmentRight = 2
    encode ParagraphAlignmentJustified = 3
    decode 0 = ParagraphAlignmentLeft
    decode 1 = ParagraphAlignmentCenter
    decode 2 = ParagraphAlignmentRight
    decode 3 = ParagraphAlignmentJustified
    decode _ = undefined

encodeBitmask :: (Encodable a) => [a] -> Word32
encodeBitmask items = foldl (.|.) 0 $ map encode items

decodeBitmask :: (Encodable a) => Word32 -> [a]
decodeBitmask encoded =
    concat $ map (\bitNumber -> if (bit bitNumber .&. encoded) /= 0
                                  then [decode $ bit bitNumber]
                                  else [])
                 [0..31]


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
    :: CInt -> IO (Ptr UTF8)
errorString :: Error -> IO String
errorString error = do
  cString <- errorString' $ fromIntegral $ encode error
  byteString <- packCString cString
  return $ toString byteString

foreign import ccall safe "ef_main" main
    :: IO ()


foreign import ccall safe "ef_video_new_drawable" videoNewDrawable'
    :: CInt -> CInt -> CInt -> Display -> IO Drawable
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
    :: CInt -> IO ()
videoSetDoubleBuffer :: Bool -> IO ()
videoSetDoubleBuffer doubleBuffer = do
    doubleBuffer' <- return $ if doubleBuffer then 1 else 0
    videoSetDoubleBuffer' doubleBuffer'

foreign import ccall safe "ef_video_set_stereo" videoSetStereo'
    :: CInt -> IO ()
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
    :: CInt -> IO ()
videoSetAuxDepthStencil :: Bool -> IO ()
videoSetAuxDepthStencil auxDepthStencil = do
    auxDepthStencil' <- return $ if auxDepthStencil then 1 else 0
    videoSetStereo' auxDepthStencil'

foreign import ccall safe "ef_video_set_color_float" videoSetColorFloat'
    :: CInt -> IO ()
videoSetColorFloat :: Bool -> IO ()
videoSetColorFloat colorFloat = do
    colorFloat' <- return $ if colorFloat then 1 else 0
    videoSetColorFloat' colorFloat'

foreign import ccall safe "ef_video_set_multisample" videoSetMultisample'
    :: CInt -> IO ()
videoSetMultisample :: Bool -> IO ()
videoSetMultisample multisample = do
    multisample' <- return $ if multisample then 1 else 0
    videoSetMultisample' multisample'

foreign import ccall safe "ef_video_set_supersample" videoSetSupersample'
    :: CInt -> IO ()
videoSetSupersample :: Bool -> IO ()
videoSetSupersample supersample = do
    supersample' <- return $ if supersample then 1 else 0
    videoSetSupersample' supersample'

foreign import ccall safe "ef_video_set_sample_alpha" videoSetSampleAlpha'
    :: CInt -> IO ()
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
    :: Ptr UTF8 -> CUInt -> CInt -> IO CInt
videoLoadTextureFile :: String -> GL.TextureObject -> Bool -> IO Error
videoLoadTextureFile string textureObject buildMipmaps = do
  GL.TextureObject theID <- return textureObject
  byteString <- return $ fromString string
  buildMipmaps' <- return $ if buildMipmaps then 1 else 0
  useAsCString byteString
               (\cString -> do
                  errorCode <- videoLoadTextureFile' cString
                                                     (fromIntegral theID)
                                                     buildMipmaps'
                  return $ decode $ fromIntegral errorCode)

foreign import ccall safe "ef_video_load_texture_memory" videoLoadTextureMemory'
    :: Ptr () -> CSize -> CUInt -> CInt -> IO CInt
videoLoadTextureMemory :: Ptr () -> CSize -> GL.TextureObject -> Bool -> IO Error
videoLoadTextureMemory pointer size textureObject buildMipmaps = do
  GL.TextureObject theID <- return textureObject
  buildMipmaps' <- return $ if buildMipmaps then 1 else 0
  errorCode <- videoLoadTextureMemory' pointer size (fromIntegral theID) buildMipmaps'
  return $ decode $ fromIntegral errorCode


foreign import ccall safe "ef_audio_load_sound_file" audioLoadSoundFile'
    :: Ptr UTF8 -> CUInt -> IO CInt
audioLoadSoundFile :: String -> AL.Buffer -> IO Error
audioLoadSoundFile string bufferObject = do
  theID <- return $ fromIntegral $ marshalBuffer $ Just bufferObject
  byteString <- return $ fromString string
  errorCode <- useAsCString byteString (\cString -> audioLoadSoundFile' cString theID)
  return $ decode $ fromIntegral errorCode

foreign import ccall safe "ef_audio_load_sound_memory" audioLoadSoundMemory'
    :: Ptr () -> CSize -> CUInt -> IO CInt
audioLoadSoundMemory :: Ptr () -> CSize -> AL.Buffer -> IO Error
audioLoadSoundMemory pointer size bufferObject = do
  theID <- return $ fromIntegral $ marshalBuffer $ Just bufferObject
  errorCode <- audioLoadSoundMemory' pointer size theID
  return $ decode $ fromIntegral errorCode

foreign import ccall safe "ef_time_new_oneshot_timer" timeNewOneshotTimer
    :: CInt -> FunPtr TimerCallback -> Ptr () -> IO Timer

foreign import ccall safe "ef_time_new_repeating_timer" timeNewRepeatingTimer
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

foreign import ccall safe "ef_event_modifiers" eventModifiers'
    :: Event -> IO Word32
eventModifiers :: Event -> IO [Modifier]
eventModifiers event = do
  encoded <- eventModifiers' event
  return $ decodeBitmask encoded

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

foreign import ccall safe "ef_input_keycode_by_name" inputKeycodeByName'
    :: Ptr UTF8 -> IO Keycode
inputKeycodeByName :: String -> IO Keycode
inputKeycodeByName string = do
  byteString <- return $ fromString string
  useAsCString byteString (\cString -> inputKeycodeByName' cString)

foreign import ccall safe "ef_input_keycode_string" inputKeycodeString'
    :: Keycode -> Word32 -> Ptr DeadKeyState -> IO (Ptr UTF8)
inputKeycodeString :: Keycode -> [Modifier] -> Ptr DeadKeyState -> IO String
inputKeycodeString keycode modifiers deadKeyStatePtr = do
  modifiersBitmask <- return $ encodeBitmask modifiers
  cString <- inputKeycodeString' keycode modifiersBitmask deadKeyStatePtr
  byteString <- packCString cString
  return $ toString byteString

foreign import ccall safe "ef_event_mouse_x" eventMouseX
    :: Event -> IO Int32

foreign import ccall safe "ef_event_mouse_y" eventMouseY
    :: Event -> IO Int32


foreign import ccall safe "ef_text_compute_available_fonts"
        textComputeAvailableFonts
    :: IO ()

foreign import ccall safe "ef_text_compute_available_font_families"
        textComputeAvailableFontFamilies
    :: IO ()

foreign import ccall safe "ef_text_compute_available_fonts_with_traits"
        textComputeAvailableFontsWithTraits'
    :: Word32 -> Word32 -> IO ()
textComputeAvailableFontsWithTraits :: [FontTrait] -> [FontTrait] -> IO ()
textComputeAvailableFontsWithTraits traits negativeTraits =
    textComputeAvailableFontsWithTraits' (encodeBitmask traits)
                                         (encodeBitmask negativeTraits)

foreign import ccall safe "ef_text_compute_available_members_of_font_family"
        textComputeAvailableMembersOfFontFamily'
    :: (Ptr UTF8) -> IO ()
textComputeAvailableMembersOfFontFamily :: String -> IO ()
textComputeAvailableMembersOfFontFamily string = do
  byteString <- return $ fromString string
  useAsCString byteString (\cString -> textComputeAvailableMembersOfFontFamily' cString)

foreign import ccall safe "ef_text_computed_count" textComputedCount
    :: IO Int32

foreign import ccall safe "ef_text_computed_name_n" textComputedNameN'
    :: Int32 -> IO (Ptr UTF8)
textComputedNameN :: Int32 -> IO String
textComputedNameN which = do
  cString <- textComputedNameN' which
  byteString <- packCString cString
  return $ toString byteString

foreign import ccall safe "ef_text_computed_style_name_n" textComputedStyleNameN'
    :: Int32 -> IO (Ptr UTF8)
textComputedStyleNameN :: Int32 -> IO String
textComputedStyleNameN which = do
  cString <- textComputedStyleNameN' which
  byteString <- packCString cString
  return $ toString byteString

foreign import ccall safe "ef_text_computed_weight_n" textComputedWeightN'
    :: Int32 -> IO Word32
textComputedWeightN :: Int32 -> IO FontWeight
textComputedWeightN which = do
  encoded <- textComputedWeightN' which
  return $ decode encoded

foreign import ccall safe "ef_text_computed_traits_n" textComputedTraitsN'
    :: Int32 -> IO Word32
textComputedTraitsN :: Int32 -> IO [FontTrait]
textComputedTraitsN which = do
  encoded <- textComputedTraitsN' which
  return $ decodeBitmask encoded

foreign import ccall safe "ef_text_discard_computed" textDiscardComputed
    :: IO ()

foreign import ccall safe "ef_text_specific_font" textSpecificFont'
    :: (Ptr UTF8) -> Word32 -> Word32 -> CDouble -> IO Font
textSpecificFont :: String -> [FontTrait] -> FontWeight -> Double -> IO Font
textSpecificFont string traits weight size = do
  byteString <- return $ fromString string
  useAsCString byteString (\cString -> do
                             textSpecificFont' cString
                                               (encodeBitmask traits)
                                               (encode weight)
                                               (realToFrac size))

foreign import ccall safe "ef_font_delete" fontDelete
    :: Font -> IO ()

foreign import ccall safe "ef_font_name" fontName'
    :: Font -> IO (Ptr UTF8)
fontName :: Font -> IO String
fontName font = do
  cString <- fontName' font
  byteString <- packCString cString
  return $ toString byteString

foreign import ccall safe "ef_font_family_name" fontFamilyName'
    :: Font -> IO (Ptr UTF8)
fontFamilyName :: Font -> IO String
fontFamilyName font = do
  cString <- fontFamilyName' font
  byteString <- packCString cString
  return $ toString byteString

foreign import ccall safe "ef_font_display_name" fontDisplayName'
    :: Font -> IO (Ptr UTF8)
fontDisplayName :: Font -> IO String
fontDisplayName font = do
  cString <- fontDisplayName' font
  byteString <- packCString cString
  return $ toString byteString

foreign import ccall safe "ef_font_traits" fontTraits'
    :: Font -> IO Word32
fontTraits :: Font -> IO [FontTrait]
fontTraits font = do
  encoded <- fontTraits' font
  return $ decodeBitmask encoded

foreign import ccall safe "ef_font_weight" fontWeight'
    :: Font -> IO Word32
fontWeight :: Font -> IO FontWeight
fontWeight font = do
  encoded <- fontWeight' font
  return $ decode encoded

foreign import ccall safe "ef_font_convert_to_face" fontConvertToFace'
    :: Font -> (Ptr UTF8) -> IO Font
fontConvertToFace :: Font -> String -> IO (Maybe Font)
fontConvertToFace font string = do
  byteString <- return $ fromString string
  useAsCString byteString (\cString -> do
                             result <- fontConvertToFace' font cString
                             return $ case result of
                               Font ptr | ptr == nullPtr -> Nothing
                               _ -> Just result)

foreign import ccall safe "ef_font_convert_to_family" fontConvertToFamily'
    :: Font -> (Ptr UTF8) -> IO Font
fontConvertToFamily :: Font -> String -> IO (Maybe Font)
fontConvertToFamily font string = do
  byteString <- return $ fromString string
  useAsCString byteString (\cString -> do
                             result <- fontConvertToFamily' font cString
                             return $ case result of
                               Font ptr | ptr == nullPtr -> Nothing
                               _ -> Just result)

foreign import ccall safe "ef_font_convert_to_have_traits" fontConvertToHaveTraits'
    :: Font -> Word32 -> IO Font
fontConvertToHaveTraits :: Font -> [FontTrait] -> IO (Maybe Font)
fontConvertToHaveTraits font traits = do
  result <- fontConvertToHaveTraits' font (encodeBitmask traits)
  return $ case result of
             Font ptr | ptr == nullPtr -> Nothing
             _ -> Just result

foreign import ccall safe "ef_font_convert_to_not_have_traits"
        fontConvertToNotHaveTraits'
    :: Font -> Word32 -> IO Font
fontConvertToNotHaveTraits :: Font -> [FontTrait] -> IO (Maybe Font)
fontConvertToNotHaveTraits font traits = do
  result <- fontConvertToNotHaveTraits' font (encodeBitmask traits)
  return $ case result of
             Font ptr | ptr == nullPtr -> Nothing
             _ -> Just result

foreign import ccall safe "ef_font_convert_to_size" fontConvertToSize'
    :: Font -> CDouble -> IO Font
fontConvertToSize :: Font -> Double -> IO (Maybe Font)
fontConvertToSize font size = do
  result <- fontConvertToSize' font (realToFrac size)
  return $ case result of
             Font ptr | ptr == nullPtr -> Nothing
             _ -> Just result

foreign import ccall safe "ef_font_convert_to_lighter_weight"
        fontConvertToLighterWeight'
    :: Font -> IO Font
fontConvertToLighterWeight :: Font -> IO (Maybe Font)
fontConvertToLighterWeight font = do
  result <- fontConvertToLighterWeight' font
  return $ case result of
             Font ptr | ptr == nullPtr -> Nothing
             _ -> Just result

foreign import ccall safe "ef_font_convert_to_heavier_weight"
        fontConvertToHeavierWeight'
    :: Font -> IO Font
fontConvertToHeavierWeight :: Font -> IO (Maybe Font)
fontConvertToHeavierWeight font = do
  result <- fontConvertToHeavierWeight' font
  return $ case result of
             Font ptr | ptr == nullPtr -> Nothing
             _ -> Just result

foreign import ccall safe "ef_font_horizontal_advancement_for_glyph"
        fontHorizontalAdvancementForGlyph'
    :: Font -> Glyph -> IO CDouble
fontHorizontalAdvancementForGlyph :: Font -> Glyph -> IO Double
fontHorizontalAdvancementForGlyph font glyph = do
  result <- fontHorizontalAdvancementForGlyph' font glyph
  return $ realToFrac result

foreign import ccall safe "ef_font_vertical_advancement_for_glyph"
        fontVerticalAdvancementForGlyph'
    :: Font -> Glyph -> IO CDouble
fontVerticalAdvancementForGlyph :: Font -> Glyph -> IO Double
fontVerticalAdvancementForGlyph font glyph = do
  result <- fontVerticalAdvancementForGlyph' font glyph
  return $ realToFrac result

foreign import ccall safe "ef_font_ascender" fontAscender'
    :: Font -> IO CDouble
fontAscender :: Font -> IO Double
fontAscender font = do
  result <- fontAscender' font
  return $ realToFrac result

foreign import ccall safe "ef_font_descender" fontDescender'
    :: Font -> IO CDouble
fontDescender :: Font -> IO Double
fontDescender font = do
  result <- fontDescender' font
  return $ realToFrac result

foreign import ccall safe "ef_font_x_height" fontXHeight'
    :: Font -> IO CDouble
fontXHeight :: Font -> IO Double
fontXHeight font = do
  result <- fontXHeight' font
  return $ realToFrac result

foreign import ccall safe "ef_font_cap_height" fontCapHeight'
    :: Font -> IO CDouble
fontCapHeight :: Font -> IO Double
fontCapHeight font = do
  result <- fontCapHeight' font
  return $ realToFrac result

foreign import ccall safe "ef_font_italic_angle" fontItalicAngle'
    :: Font -> IO CDouble
fontItalicAngle :: Font -> IO Double
fontItalicAngle font = do
  result <- fontItalicAngle' font
  return $ realToFrac result

foreign import ccall safe "ef_font_leading" fontLeading'
    :: Font -> IO CDouble
fontLeading :: Font -> IO Double
fontLeading font = do
  result <- fontLeading' font
  return $ realToFrac result

foreign import ccall safe "ef_font_maximum_horizontal_advancement"
        fontMaximumHorizontalAdvancement'
    :: Font -> IO CDouble
fontMaximumHorizontalAdvancement :: Font -> IO Double
fontMaximumHorizontalAdvancement font = do
  result <- fontMaximumHorizontalAdvancement' font
  return $ realToFrac result

foreign import ccall safe "ef_font_maximum_vertical_advancement"
        fontMaximumVerticalAdvancement'
    :: Font -> IO CDouble
fontMaximumVerticalAdvancement :: Font -> IO Double
fontMaximumVerticalAdvancement font = do
  result <- fontMaximumVerticalAdvancement' font
  return $ realToFrac result

foreign import ccall safe "ef_font_underline_position" fontUnderlinePosition'
    :: Font -> IO CDouble
fontUnderlinePosition :: Font -> IO Double
fontUnderlinePosition font = do
  result <- fontUnderlinePosition' font
  return $ realToFrac result

foreign import ccall safe "ef_font_underline_thickness" fontUnderlineThickness'
    :: Font -> IO CDouble
fontUnderlineThickness :: Font -> IO Double
fontUnderlineThickness font = do
  result <- fontUnderlineThickness' font
  return $ realToFrac result

foreign import ccall safe "ef_font_bounding_rectangle" fontBoundingRectangle'
    :: Font -> (Ptr CDouble) -> (Ptr CDouble) -> (Ptr CDouble) -> (Ptr CDouble) -> IO ()
fontBoundingRectangle :: Font -> IO (Double, Double, Double, Double)
fontBoundingRectangle font = do
  alloca (\left -> do
            alloca (\top -> do
                      alloca (\width -> do
                                alloca (\height -> do
                                          fontBoundingRectangle' font
                                                                 left top width height
                                          left' <- peek left
                                          top' <- peek top
                                          width' <- peek width
                                          height' <- peek height
                                          return $ (realToFrac left',
                                                    realToFrac top',
                                                    realToFrac width',
                                                    realToFrac height')))))

foreign import ccall safe "ef_font_glyph_bounding_rectangle" fontGlyphBoundingRectangle'
    :: Font -> Glyph -> (Ptr CDouble) -> (Ptr CDouble) -> (Ptr CDouble)
    -> (Ptr CDouble) -> IO ()
fontGlyphBoundingRectangle :: Font -> Glyph -> IO (Double, Double, Double, Double)
fontGlyphBoundingRectangle font glyph = do
  alloca (\left -> do
            alloca (\top -> do
                      alloca (\width -> do
                                alloca (\height -> do
                                          fontGlyphBoundingRectangle' font glyph
                                                                      left top
                                                                      width height
                                          left' <- peek left
                                          top' <- peek top
                                          width' <- peek width
                                          height' <- peek height
                                          return $ (realToFrac left',
                                                    realToFrac top',
                                                    realToFrac width',
                                                    realToFrac height')))))


foreign import ccall safe "ef_text_new_text_flow" textNewTextFlow
    :: IO TextFlow

foreign import ccall safe "ef_text_new_text_flow_with_text" textNewTextFlowWithText'
    :: (Ptr UTF8) -> IO TextFlow
textNewTextFlowWithText :: String -> IO TextFlow
textNewTextFlowWithText string = do
  byteString <- return $ fromString string
  useAsCString byteString (\cString -> textNewTextFlowWithText' cString)

foreign import ccall safe "ef_text_new_text_flow_with_text_and_attributes"
        textNewTextFlowWithTextAndAttributes'
    :: (Ptr UTF8) -> TextAttributes -> IO TextFlow
textNewTextFlowWithTextAndAttributes :: String -> TextAttributes -> IO TextFlow
textNewTextFlowWithTextAndAttributes string attributes = do
  byteString <- return $ fromString string
  useAsCString byteString (\cString -> textNewTextFlowWithTextAndAttributes'
                                       cString attributes)

foreign import ccall safe "ef_text_flow_delete" textFlowDelete
    :: TextFlow -> IO ()

foreign import ccall safe "ef_text_flow_text" textFlowText'
    :: TextFlow -> IO (Ptr UTF8)
textFlowText :: TextFlow -> IO String
textFlowText textFlow = do
  cString <- textFlowText' textFlow
  byteString <- packCString cString
  return $ toString byteString

foreign import ccall safe "ef_text_flow_length" textFlowLength
    :: TextFlow -> IO Int32

foreign import ccall safe "ef_text_flow_attributes_at_index" textFlowAttributesAtIndex'
    :: TextFlow -> Int32 -> (Ptr Int32) -> (Ptr Int32) -> IO TextAttributes
textFlowAttributesAtIndex :: TextFlow -> Int32 -> IO (TextAttributes, (Int32, Int32))
textFlowAttributesAtIndex textFlow textIndex = do
  alloca (\start -> do
            alloca (\end -> do
                      attributes <- textFlowAttributesAtIndex'
                                    textFlow textIndex start end
                      start' <- peek start
                      end' <- peek end
                      return (attributes, (start', end'))))

foreign import ccall safe "ef_text_flow_enumerate_attributes"
        textFlowEnumerateAttributes'
    :: TextFlow -> (FunPtr TextFlowEnumerateAttributesCallback) -> IO ()
type TextFlowEnumerateAttributesCallback = TextAttributes -> Int32 -> Int32 -> IO Int
foreign import ccall "wrapper" mkTextFlowEnumerateAttributeCallback
    :: TextFlowEnumerateAttributesCallback
    -> IO (FunPtr TextFlowEnumerateAttributesCallback)
textFlowEnumerateAttributes
    :: TextFlow -> (TextAttributes -> (Int32, Int32) -> IO Bool) -> IO ()
textFlowEnumerateAttributes textFlow callback = do
  callbackFunPtr <- mkTextFlowEnumerateAttributeCallback
                    (\attributes start end -> do
                       result <- callback attributes (start, end)
                       return $ case result of
                         False -> 0
                         True -> 1)
  textFlowEnumerateAttributes' textFlow callbackFunPtr
  freeHaskellFunPtr callbackFunPtr

foreign import ccall safe "ef_text_flow_replace_text" textFlowReplaceText'
    :: TextFlow -> (Ptr UTF8) -> Int32 -> Int32 -> IO ()
textFlowReplaceText :: TextFlow -> String -> (Int32, Int32) -> IO ()
textFlowReplaceText textFlow string (start, end) = do
  byteString <- return $ fromString string
  useAsCString byteString (\cString -> textFlowReplaceText' textFlow cString start end)

foreign import ccall safe "ef_text_flow_delete_text" textFlowDeleteText'
    :: TextFlow -> Int32 -> Int32 -> IO ()
textFlowDeleteText :: TextFlow -> (Int32, Int32) -> IO ()
textFlowDeleteText textFlow (start, end) = do
  textFlowDeleteText' textFlow start end

foreign import ccall safe "ef_text_flow_set_attributes" textFlowSetAttributes'
    :: TextFlow -> TextAttributes -> Int32 -> Int32 -> IO ()
textFlowSetAttributes :: TextFlow -> TextAttributes -> (Int32, Int32) -> IO ()
textFlowSetAttributes textFlow textAttributes (start, end) = do
  textFlowSetAttributes' textFlow textAttributes start end

foreign import ccall safe "ef_text_flow_remove_attribute" textFlowRemoveAttribute'
    :: TextFlow -> Word32 -> Int32 -> Int32 -> IO ()
textFlowRemoveAttribute
    :: TextFlow -> TextAttributeIdentifier -> (Int32, Int32) -> IO ()
textFlowRemoveAttribute textFlow attribute (start, end) = do
  textFlowRemoveAttribute' textFlow (encode attribute) start end

foreign import ccall safe "ef_text_flow_natural_size" textFlowNaturalSize'
    :: TextFlow -> (Ptr CDouble) -> (Ptr CDouble) -> IO ()
textFlowNaturalSize :: TextFlow -> IO (Double, Double)
textFlowNaturalSize textFlow = do
  alloca (\width -> do
            alloca (\height -> do
                      textFlowNaturalSize' textFlow width height
                      width' <- peek width
                      height' <- peek height
                      return (realToFrac width', realToFrac height')))

foreign import ccall safe "ef_text_flow_size" textFlowSize'
    :: TextFlow -> (Ptr CDouble) -> (Ptr CDouble) -> IO ()
textFlowSize :: TextFlow -> IO (Double, Double)
textFlowSize textFlow = do
  alloca (\width -> do
            alloca (\height -> do
                      textFlowSize' textFlow width height
                      width' <- peek width
                      height' <- peek height
                      return (realToFrac width', realToFrac height')))

foreign import ccall safe "ef_text_flow_set_size" textFlowSetSize'
    :: TextFlow -> CDouble -> CDouble -> IO ()
textFlowSetSize :: TextFlow -> (Double, Double) -> IO ()
textFlowSetSize textFlow (width, height) = do
  textFlowSetSize' textFlow (realToFrac width) (realToFrac height)

foreign import ccall safe "ef_text_flow_draw" textFlowDraw
    :: TextFlow -> Drawable

foreign import ccall safe "ef_text_new_attributes" textNewAttributes
    :: IO TextAttributes

foreign import ccall safe "ef_text_attributes_delete" textAttributesDelete
    :: TextAttributes -> IO ()

foreign import ccall safe "ef_text_attributes_font" textAttributesFont'
    :: TextAttributes -> IO Font
textAttributesFont :: TextAttributes -> IO (Maybe Font)
textAttributesFont textAttributes = do
  result <- textAttributesFont' textAttributes
  return $ case result of
             Font ptr | ptr == nullPtr -> Nothing
             _ -> Just result

foreign import ccall safe "ef_text_attributes_paragraph_style"
        textAttributesParagraphStyle'
    :: TextAttributes -> IO ParagraphStyle
textAttributesParagraphStyle :: TextAttributes -> IO (Maybe ParagraphStyle)
textAttributesParagraphStyle textAttributes = do
  result <- textAttributesParagraphStyle' textAttributes
  return $ case result of
             ParagraphStyle ptr | ptr == nullPtr -> Nothing
             _ -> Just result

foreign import ccall safe "ef_text_attributes_foreground_color"
        textAttributesForegroundColor'
    :: TextAttributes -> (Ptr CDouble) -> (Ptr CDouble) -> (Ptr CDouble)
    -> (Ptr CDouble) -> IO ()
textAttributesForegroundColor :: TextAttributes -> IO (Double, Double, Double, Double)
textAttributesForegroundColor textAttributes = do
  alloca (\red -> do
            alloca (\green -> do
                      alloca (\blue -> do
                                alloca (\alpha -> do
                                          textAttributesForegroundColor' textAttributes
                                                                         red
                                                                         green
                                                                         blue
                                                                         alpha
                                          red' <- peek red
                                          green' <- peek green
                                          blue' <- peek blue
                                          alpha' <- peek alpha
                                          return (realToFrac red',
                                                  realToFrac green',
                                                  realToFrac blue',
                                                  realToFrac alpha')))))

foreign import ccall safe "ef_text_attributes_background_color"
        textAttributesBackgroundColor'
    :: TextAttributes -> (Ptr CDouble) -> (Ptr CDouble) -> (Ptr CDouble)
    -> (Ptr CDouble) -> IO ()
textAttributesBackgroundColor :: TextAttributes -> IO (Double, Double, Double, Double)
textAttributesBackgroundColor textAttributes = do
  alloca (\red -> do
            alloca (\green -> do
                      alloca (\blue -> do
                                alloca (\alpha -> do
                                          textAttributesBackgroundColor' textAttributes
                                                                         red
                                                                         green
                                                                         blue
                                                                         alpha
                                          red' <- peek red
                                          green' <- peek green
                                          blue' <- peek blue
                                          alpha' <- peek alpha
                                          return (realToFrac red',
                                                  realToFrac green',
                                                  realToFrac blue',
                                                  realToFrac alpha')))))

foreign import ccall safe "ef_text_attributes_underline_style"
        textAttributesUnderlineStyle'
    :: TextAttributes -> IO Word32
textAttributesUnderlineStyle :: TextAttributes -> IO UnderlineStyle
textAttributesUnderlineStyle textAttributes = do
  result <- textAttributesUnderlineStyle' textAttributes
  return $ decode result

foreign import ccall safe "ef_text_attributes_underline_is_colored"
        textAttributesUnderlineIsColored'
    :: TextAttributes -> IO CInt
textAttributesUnderlineIsColored :: TextAttributes -> IO Bool
textAttributesUnderlineIsColored textAttributes = do
  result <- textAttributesUnderlineIsColored' textAttributes
  return $ case result of
             0 -> False
             _ -> True

foreign import ccall safe "ef_text_attributes_underline_color"
        textAttributesUnderlineColor'
    :: TextAttributes -> (Ptr CDouble) -> (Ptr CDouble) -> (Ptr CDouble)
    -> (Ptr CDouble) -> IO ()
textAttributesUnderlineColor :: TextAttributes -> IO (Double, Double, Double, Double)
textAttributesUnderlineColor textAttributes = do
  alloca (\red -> do
            alloca (\green -> do
                      alloca (\blue -> do
                                alloca (\alpha -> do
                                          textAttributesUnderlineColor' textAttributes
                                                                        red
                                                                        green
                                                                        blue
                                                                        alpha
                                          red' <- peek red
                                          green' <- peek green
                                          blue' <- peek blue
                                          alpha' <- peek alpha
                                          return (realToFrac red',
                                                  realToFrac green',
                                                  realToFrac blue',
                                                  realToFrac alpha')))))

foreign import ccall safe "ef_text_attributes_strikethrough_style"
        textAttributesStrikethroughStyle'
    :: TextAttributes -> IO Word32
textAttributesStrikethroughStyle :: TextAttributes -> IO StrikethroughStyle
textAttributesStrikethroughStyle textAttributes = do
  result <- textAttributesStrikethroughStyle' textAttributes
  return $ decode result

foreign import ccall safe "ef_text_attributes_strikethrough_is_colored"
        textAttributesStrikethroughIsColored'
    :: TextAttributes -> IO CInt
textAttributesStrikethroughIsColored :: TextAttributes -> IO Bool
textAttributesStrikethroughIsColored textAttributes = do
  result <- textAttributesStrikethroughIsColored' textAttributes
  return $ case result of
             0 -> False
             _ -> True

foreign import ccall safe "ef_text_attributes_strikethrough_color"
        textAttributesStrikethroughColor'
    :: TextAttributes -> (Ptr CDouble) -> (Ptr CDouble) -> (Ptr CDouble)
    -> (Ptr CDouble) -> IO ()
textAttributesStrikethroughColor :: TextAttributes -> IO (Double, Double, Double, Double)
textAttributesStrikethroughColor textAttributes = do
  alloca (\red -> do
            alloca (\green -> do
                      alloca (\blue -> do
                                alloca (\alpha -> do
                                          textAttributesStrikethroughColor'
                                            textAttributes
                                            red
                                            green
                                            blue
                                            alpha
                                          red' <- peek red
                                          green' <- peek green
                                          blue' <- peek blue
                                          alpha' <- peek alpha
                                          return (realToFrac red',
                                                  realToFrac green',
                                                  realToFrac blue',
                                                  realToFrac alpha')))))

foreign import ccall safe "ef_text_attributes_ligature_style"
        textAttributesLigatureStyle'
    :: TextAttributes -> IO Word32
textAttributesLigatureStyle :: TextAttributes -> IO LigatureStyle
textAttributesLigatureStyle textAttributes = do
  result <- textAttributesLigatureStyle' textAttributes
  return $ decode result

foreign import ccall safe "ef_text_attributes_baseline_offset"
        textAttributesBaselineOffset'
    :: TextAttributes -> IO CDouble
textAttributesBaselineOffset :: TextAttributes -> IO Double
textAttributesBaselineOffset textAttributes = do
  result <- textAttributesBaselineOffset' textAttributes
  return $ realToFrac result

foreign import ccall safe "ef_text_attributes_kerning_is_default"
        textAttributesKerningIsDefault'
    :: TextAttributes -> IO CInt
textAttributesKerningIsDefault :: TextAttributes -> IO Bool
textAttributesKerningIsDefault textAttributes = do
  result <- textAttributesKerningIsDefault' textAttributes
  return $ case result of
             0 -> False
             _ -> True

foreign import ccall safe "ef_text_attributes_kerning"
        textAttributesKerning'
    :: TextAttributes -> IO CDouble
textAttributesKerning :: TextAttributes -> IO Double
textAttributesKerning textAttributes = do
  result <- textAttributesKerning' textAttributes
  return $ realToFrac result

foreign import ccall safe "ef_text_attributes_outline_style"
        textAttributesOutlineStyle'
    :: TextAttributes -> IO Word32
textAttributesOutlineStyle :: TextAttributes -> IO OutlineStyle
textAttributesOutlineStyle textAttributes = do
  result <- textAttributesOutlineStyle' textAttributes
  return $ decode result

foreign import ccall safe "ef_text_attributes_stroke_width"
        textAttributesStrokeWidth'
    :: TextAttributes -> IO CDouble
textAttributesStrokeWidth :: TextAttributes -> IO Double
textAttributesStrokeWidth textAttributes = do
  result <- textAttributesStrokeWidth' textAttributes
  return $ realToFrac result

foreign import ccall safe "ef_text_attributes_stroke_is_colored"
        textAttributesStrokeIsColored'
    :: TextAttributes -> IO CInt
textAttributesStrokeIsColored :: TextAttributes -> IO Bool
textAttributesStrokeIsColored textAttributes = do
  result <- textAttributesStrokeIsColored' textAttributes
  return $ case result of
             0 -> False
             _ -> True

foreign import ccall safe "ef_text_attributes_stroke_color"
        textAttributesStrokeColor'
    :: TextAttributes -> (Ptr CDouble) -> (Ptr CDouble) -> (Ptr CDouble)
    -> (Ptr CDouble) -> IO ()
textAttributesStrokeColor :: TextAttributes -> IO (Double, Double, Double, Double)
textAttributesStrokeColor textAttributes = do
  alloca (\red -> do
            alloca (\green -> do
                      alloca (\blue -> do
                                alloca (\alpha -> do
                                          textAttributesStrokeColor' textAttributes
                                                                     red
                                                                     green
                                                                     blue
                                                                     alpha
                                          red' <- peek red
                                          green' <- peek green
                                          blue' <- peek blue
                                          alpha' <- peek alpha
                                          return (realToFrac red',
                                                  realToFrac green',
                                                  realToFrac blue',
                                                  realToFrac alpha')))))

foreign import ccall safe "ef_text_attributes_obliqueness"
        textAttributesObliqueness'
    :: TextAttributes -> IO CDouble
textAttributesObliqueness :: TextAttributes -> IO Double
textAttributesObliqueness textAttributes = do
  result <- textAttributesObliqueness' textAttributes
  return $ realToFrac result

foreign import ccall safe "ef_text_attributes_expansion"
        textAttributesExpansion'
    :: TextAttributes -> IO CDouble
textAttributesExpansion :: TextAttributes -> IO Double
textAttributesExpansion textAttributes = do
  result <- textAttributesExpansion' textAttributes
  return $ realToFrac result

foreign import ccall safe "ef_text_attributes_set_font"
        textAttributesSetFont
    :: TextAttributes -> Font -> IO ()

foreign import ccall safe "ef_text_attributes_set_paragraph_style"
        textAttributesSetParagraphStyle
    :: TextAttributes -> ParagraphStyle -> IO ()

foreign import ccall safe "ef_text_attributes_set_foreground_color"
        textAttributesSetForegroundColor'
    :: TextAttributes -> CDouble -> CDouble -> CDouble -> CDouble -> IO ()
textAttributesSetForegroundColor
    :: TextAttributes -> (Double, Double, Double, Double) -> IO ()
textAttributesSetForegroundColor textAttributes (red, green, blue, alpha) = do
  textAttributesSetForegroundColor' textAttributes
                                    (realToFrac red)
                                    (realToFrac green)
                                    (realToFrac blue)
                                    (realToFrac alpha)

foreign import ccall safe "ef_text_attributes_set_background_color"
        textAttributesSetBackgroundColor'
    :: TextAttributes -> CDouble -> CDouble -> CDouble -> CDouble -> IO ()
textAttributesSetBackgroundColor
    :: TextAttributes -> (Double, Double, Double, Double) -> IO ()
textAttributesSetBackgroundColor textAttributes (red, green, blue, alpha) = do
  textAttributesSetBackgroundColor' textAttributes
                                    (realToFrac red)
                                    (realToFrac green)
                                    (realToFrac blue)
                                    (realToFrac alpha)

foreign import ccall safe "ef_text_attributes_set_underline_style"
        textAttributesSetUnderlineStyle'
    :: TextAttributes -> Word32 -> IO ()
textAttributesSetUnderlineStyle :: TextAttributes -> UnderlineStyle -> IO ()
textAttributesSetUnderlineStyle textAttributes underlineStyle = do
  textAttributesSetUnderlineStyle' textAttributes $ encode underlineStyle

foreign import ccall safe "ef_text_attributes_set_underline_color"
        textAttributesSetUnderlineColor'
    :: TextAttributes -> CDouble -> CDouble -> CDouble -> CDouble -> IO ()
textAttributesSetUnderlineColor
    :: TextAttributes -> (Double, Double, Double, Double) -> IO ()
textAttributesSetUnderlineColor textAttributes (red, green, blue, alpha) = do
  textAttributesSetUnderlineColor' textAttributes
                                   (realToFrac red)
                                   (realToFrac green)
                                   (realToFrac blue)
                                   (realToFrac alpha)

foreign import ccall safe "ef_text_attributes_set_strikethrough_style"
        textAttributesSetStrikethroughStyle'
    :: TextAttributes -> Word32 -> IO ()
textAttributesSetStrikethroughStyle :: TextAttributes -> StrikethroughStyle -> IO ()
textAttributesSetStrikethroughStyle textAttributes strikethroughStyle = do
  textAttributesSetStrikethroughStyle' textAttributes $ encode strikethroughStyle

foreign import ccall safe "ef_text_attributes_set_strikethrough_color"
        textAttributesSetStrikethroughColor'
    :: TextAttributes -> CDouble -> CDouble -> CDouble -> CDouble -> IO ()
textAttributesSetStrikethroughColor
    :: TextAttributes -> (Double, Double, Double, Double) -> IO ()
textAttributesSetStrikethroughColor textAttributes (red, green, blue, alpha) = do
  textAttributesSetStrikethroughColor' textAttributes
                                       (realToFrac red)
                                       (realToFrac green)
                                       (realToFrac blue)
                                       (realToFrac alpha)

foreign import ccall safe "ef_text_attributes_set_ligature_style"
        textAttributesSetLigatureStyle'
    :: TextAttributes -> Word32 -> IO ()
textAttributesSetLigatureStyle :: TextAttributes -> LigatureStyle -> IO ()
textAttributesSetLigatureStyle textAttributes ligatureStyle = do
  textAttributesSetLigatureStyle' textAttributes $ encode ligatureStyle

foreign import ccall safe "ef_text_attributes_set_baseline_offset"
        textAttributesSetBaselineOffset'
    :: TextAttributes -> CDouble -> IO ()
textAttributesSetBaselineOffset :: TextAttributes -> Double -> IO ()
textAttributesSetBaselineOffset textAttributes baselineOffset = do
  textAttributesSetBaselineOffset' textAttributes $ realToFrac baselineOffset

foreign import ccall safe "ef_text_attributes_set_kerning"
        textAttributesSetKerning'
    :: TextAttributes -> CDouble -> IO ()
textAttributesSetKerning :: TextAttributes -> Double -> IO ()
textAttributesSetKerning textAttributes kerning = do
  textAttributesSetKerning' textAttributes $ realToFrac kerning

foreign import ccall safe "ef_text_attributes_set_outline_style"
        textAttributesSetOutlineStyle'
    :: TextAttributes -> Word32 -> IO ()
textAttributesSetOutlineStyle :: TextAttributes -> OutlineStyle -> IO ()
textAttributesSetOutlineStyle textAttributes outlineStyle = do
  textAttributesSetOutlineStyle' textAttributes $ encode outlineStyle

foreign import ccall safe "ef_text_attributes_set_stroke_width"
        textAttributesSetStrokeWidth'
    :: TextAttributes -> CDouble -> IO ()
textAttributesSetStrokeWidth :: TextAttributes -> Double -> IO ()
textAttributesSetStrokeWidth textAttributes strokeWidth = do
  textAttributesSetStrokeWidth' textAttributes $ realToFrac strokeWidth

foreign import ccall safe "ef_text_attributes_set_stroke_color"
        textAttributesSetStrokeColor'
    :: TextAttributes -> CDouble -> CDouble -> CDouble -> CDouble -> IO ()
textAttributesSetStrokeColor
    :: TextAttributes -> (Double, Double, Double, Double) -> IO ()
textAttributesSetStrokeColor textAttributes (red, green, blue, alpha) = do
  textAttributesSetStrokeColor' textAttributes
                                (realToFrac red)
                                (realToFrac green)
                                (realToFrac blue)
                                (realToFrac alpha)

foreign import ccall safe "ef_text_attributes_set_obliqueness"
        textAttributesSetObliqueness'
    :: TextAttributes -> CDouble -> IO ()
textAttributesSetObliqueness :: TextAttributes -> Double -> IO ()
textAttributesSetObliqueness textAttributes obliqueness = do
  textAttributesSetObliqueness' textAttributes $ realToFrac obliqueness

foreign import ccall safe "ef_text_attributes_set_expansion"
        textAttributesSetExpansion'
    :: TextAttributes -> CDouble -> IO ()
textAttributesSetExpansion :: TextAttributes -> Double -> IO ()
textAttributesSetExpansion textAttributes expansion = do
  textAttributesSetExpansion' textAttributes $ realToFrac expansion

foreign import ccall safe "ef_text_attributes_unset_font"
        textAttributesUnsetFont
    :: TextAttributes -> IO ()

foreign import ccall safe "ef_text_attributes_unset_paragraph_style"
        textAttributesUnsetParagraphStyle
    :: TextAttributes -> IO ()

foreign import ccall safe "ef_text_attributes_unset_foreground_color"
        textAttributesUnsetForegroundColor
    :: TextAttributes -> IO ()

foreign import ccall safe "ef_text_attributes_unset_background_color"
        textAttributesUnsetBackgroundColor
    :: TextAttributes -> IO ()

foreign import ccall safe "ef_text_attributes_unset_underline_style"
        textAttributesUnsetUnderlineStyle
    :: TextAttributes -> IO ()

foreign import ccall safe "ef_text_attributes_unset_underline_color"
        textAttributesUnsetUnderlineColor
    :: TextAttributes -> IO ()

foreign import ccall safe "ef_text_attributes_unset_strikethrough_style"
        textAttributesUnsetStrikethroughStyle
    :: TextAttributes -> IO ()

foreign import ccall safe "ef_text_attributes_unset_strikethrough_color"
        textAttributesUnsetStrikethroughColor
    :: TextAttributes -> IO ()

foreign import ccall safe "ef_text_attributes_unset_ligature_style"
        textAttributesUnsetLigatureStyle
    :: TextAttributes -> IO ()

foreign import ccall safe "ef_text_attributes_unset_baseline_offset"
        textAttributesUnsetBaselineOffset
    :: TextAttributes -> IO ()

foreign import ccall safe "ef_text_attributes_unset_kerning"
        textAttributesUnsetKerning
    :: TextAttributes -> IO ()

foreign import ccall safe "ef_text_attributes_unset_outline_style"
        textAttributesUnsetOutlineStyle
    :: TextAttributes -> IO ()

foreign import ccall safe "ef_text_attributes_unset_stroke_width"
        textAttributesUnsetStrokeWidth
    :: TextAttributes -> IO ()

foreign import ccall safe "ef_text_attributes_unset_stroke_color"
        textAttributesUnsetStrokeColor
    :: TextAttributes -> IO ()

foreign import ccall safe "ef_text_attributes_unset_obliqueness"
        textAttributesUnsetObliqueness
    :: TextAttributes -> IO ()

foreign import ccall safe "ef_text_attributes_unset_expansion"
        textAttributesUnsetExpansion
    :: TextAttributes -> IO ()

foreign import ccall safe "ef_text_new_paragraph_style"
        textNewParagraphStyle
    :: IO ParagraphStyle

foreign import ccall safe "ef_paragraph_style_delete"
        paragraphStyleDelete
    :: ParagraphStyle -> IO ()

foreign import ccall safe "ef_paragraph_style_alignment"
        paragraphStyleAlignment'
    :: ParagraphStyle -> IO Word32
paragraphStyleAlignment :: ParagraphStyle -> IO ParagraphAlignment
paragraphStyleAlignment paragraphStyle = do
  result <- paragraphStyleAlignment' paragraphStyle
  return $ decode result

foreign import ccall safe "ef_paragraph_style_first_line_head_indent"
        paragraphStyleFirstLineHeadIndent'
    :: ParagraphStyle -> IO CDouble
paragraphStyleFirstLineHeadIndent :: ParagraphStyle -> IO Double
paragraphStyleFirstLineHeadIndent paragraphStyle = do
  result <- paragraphStyleFirstLineHeadIndent' paragraphStyle
  return $ realToFrac result

foreign import ccall safe "ef_paragraph_style_head_indent"
        paragraphStyleHeadIndent'
    :: ParagraphStyle -> IO CDouble
paragraphStyleHeadIndent :: ParagraphStyle -> IO Double
paragraphStyleHeadIndent paragraphStyle = do
  result <- paragraphStyleHeadIndent' paragraphStyle
  return $ realToFrac result

foreign import ccall safe "ef_paragraph_style_tail_indent"
        paragraphStyleTailIndent'
    :: ParagraphStyle -> IO CDouble
paragraphStyleTailIndent :: ParagraphStyle -> IO Double
paragraphStyleTailIndent paragraphStyle = do
  result <- paragraphStyleTailIndent' paragraphStyle
  return $ realToFrac result

foreign import ccall safe "ef_paragraph_style_line_height_multiple"
        paragraphStyleLineHeightMultiple'
    :: ParagraphStyle -> IO CDouble
paragraphStyleLineHeightMultiple :: ParagraphStyle -> IO Double
paragraphStyleLineHeightMultiple paragraphStyle = do
  result <- paragraphStyleLineHeightMultiple' paragraphStyle
  return $ realToFrac result

foreign import ccall safe "ef_paragraph_style_minimum_line_height"
        paragraphStyleMinimumLineHeight'
    :: ParagraphStyle -> IO CDouble
paragraphStyleMinimumLineHeight :: ParagraphStyle -> IO Double
paragraphStyleMinimumLineHeight paragraphStyle = do
  result <- paragraphStyleMinimumLineHeight' paragraphStyle
  return $ realToFrac result

foreign import ccall safe "ef_paragraph_style_has_maximum_line_height"
        paragraphStyleHasMaximumLineHeight'
    :: ParagraphStyle -> IO CInt
paragraphStyleHasMaximumLineHeight :: ParagraphStyle -> IO Bool
paragraphStyleHasMaximumLineHeight paragraphStyle = do
  result <- paragraphStyleHasMaximumLineHeight' paragraphStyle
  return $ case result of
             0 -> False
             _ -> True

foreign import ccall safe "ef_paragraph_style_maximum_line_height"
        paragraphStyleMaximumLineHeight'
    :: ParagraphStyle -> IO CDouble
paragraphStyleMaximumLineHeight :: ParagraphStyle -> IO Double
paragraphStyleMaximumLineHeight paragraphStyle = do
  result <- paragraphStyleMaximumLineHeight' paragraphStyle
  return $ realToFrac result

foreign import ccall safe "ef_paragraph_style_line_spacing"
        paragraphStyleLineSpacing'
    :: ParagraphStyle -> IO CDouble
paragraphStyleLineSpacing :: ParagraphStyle -> IO Double
paragraphStyleLineSpacing paragraphStyle = do
  result <- paragraphStyleLineSpacing' paragraphStyle
  return $ realToFrac result

foreign import ccall safe "ef_paragraph_style_paragraph_spacing"
        paragraphStyleParagraphSpacing'
    :: ParagraphStyle -> IO CDouble
paragraphStyleParagraphSpacing :: ParagraphStyle -> IO Double
paragraphStyleParagraphSpacing paragraphStyle = do
  result <- paragraphStyleParagraphSpacing' paragraphStyle
  return $ realToFrac result

foreign import ccall safe "ef_paragraph_style_paragraph_spacing_before"
        paragraphStyleParagraphSpacingBefore'
    :: ParagraphStyle -> IO CDouble
paragraphStyleParagraphSpacingBefore :: ParagraphStyle -> IO Double
paragraphStyleParagraphSpacingBefore paragraphStyle = do
  result <- paragraphStyleParagraphSpacingBefore' paragraphStyle
  return $ realToFrac result

foreign import ccall safe "ef_paragraph_style_set_alignment"
        paragraphStyleSetAlignment'
    :: ParagraphStyle -> Word32 -> IO ()
paragraphStyleSetAlignment :: ParagraphStyle -> ParagraphAlignment -> IO ()
paragraphStyleSetAlignment paragraphStyle paragraphAlignment = do
  paragraphStyleSetAlignment' paragraphStyle $ encode paragraphAlignment

foreign import ccall safe "ef_paragraph_style_set_first_line_head_indent"
        paragraphStyleSetFirstLineHeadIndent'
    :: ParagraphStyle -> CDouble -> IO ()
paragraphStyleSetFirstLineHeadIndent :: ParagraphStyle -> Double -> IO ()
paragraphStyleSetFirstLineHeadIndent paragraphStyle firstLineHeadIndent = do
  paragraphStyleSetFirstLineHeadIndent' paragraphStyle $ realToFrac firstLineHeadIndent

foreign import ccall safe "ef_paragraph_style_set_head_indent"
        paragraphStyleSetHeadIndent'
    :: ParagraphStyle -> CDouble -> IO ()
paragraphStyleSetHeadIndent :: ParagraphStyle -> Double -> IO ()
paragraphStyleSetHeadIndent paragraphStyle headIndent = do
  paragraphStyleSetHeadIndent' paragraphStyle $ realToFrac headIndent

foreign import ccall safe "ef_paragraph_style_set_tail_indent"
        paragraphStyleSetTailIndent'
    :: ParagraphStyle -> CDouble -> IO ()
paragraphStyleSetTailIndent :: ParagraphStyle -> Double -> IO ()
paragraphStyleSetTailIndent paragraphStyle tailIndent = do
  paragraphStyleSetTailIndent' paragraphStyle $ realToFrac tailIndent

foreign import ccall safe "ef_paragraph_style_set_line_height_multiple"
        paragraphStyleSetLineHeightMultiple'
    :: ParagraphStyle -> CDouble -> IO ()
paragraphStyleSetLineHeightMultiple :: ParagraphStyle -> Double -> IO ()
paragraphStyleSetLineHeightMultiple paragraphStyle lineHeightMultiple = do
  paragraphStyleSetLineHeightMultiple' paragraphStyle $ realToFrac lineHeightMultiple

foreign import ccall safe "ef_paragraph_style_set_minimum_line_height"
        paragraphStyleSetMinimumLineHeight'
    :: ParagraphStyle -> CDouble -> IO ()
paragraphStyleSetMinimumLineHeight :: ParagraphStyle -> Double -> IO ()
paragraphStyleSetMinimumLineHeight paragraphStyle minimumLineHeight = do
  paragraphStyleSetMinimumLineHeight' paragraphStyle $ realToFrac minimumLineHeight

foreign import ccall safe "ef_paragraph_style_set_no_maximum_line_height"
        paragraphStyleSetNoMaximumLineHeight
    :: ParagraphStyle -> IO ()

foreign import ccall safe "ef_paragraph_style_set_maximum_line_height"
        paragraphStyleSetMaximumLineHeight'
    :: ParagraphStyle -> CDouble -> IO ()
paragraphStyleSetMaximumLineHeight :: ParagraphStyle -> Double -> IO ()
paragraphStyleSetMaximumLineHeight paragraphStyle maximumLineHeight = do
  paragraphStyleSetMaximumLineHeight' paragraphStyle $ realToFrac maximumLineHeight

foreign import ccall safe "ef_paragraph_style_set_line_spacing"
        paragraphStyleSetLineSpacing'
    :: ParagraphStyle -> CDouble -> IO ()
paragraphStyleSetLineSpacing :: ParagraphStyle -> Double -> IO ()
paragraphStyleSetLineSpacing paragraphStyle lineSpacing = do
  paragraphStyleSetLineSpacing' paragraphStyle $ realToFrac lineSpacing

foreign import ccall safe "ef_paragraph_style_set_paragraph_spacing"
        paragraphStyleSetParagraphSpacing'
    :: ParagraphStyle -> CDouble -> IO ()
paragraphStyleSetParagraphSpacing :: ParagraphStyle -> Double -> IO ()
paragraphStyleSetParagraphSpacing paragraphStyle paragraphSpacing = do
  paragraphStyleSetParagraphSpacing' paragraphStyle $ realToFrac paragraphSpacing

foreign import ccall safe "ef_paragraph_style_set_paragraph_spacing_before"
        paragraphStyleSetParagraphSpacingBefore'
    :: ParagraphStyle -> CDouble -> IO ()
paragraphStyleSetParagraphSpacingBefore :: ParagraphStyle -> Double -> IO ()
paragraphStyleSetParagraphSpacingBefore paragraphStyle paragraphSpacingBefore = do
  paragraphStyleSetParagraphSpacingBefore' paragraphStyle
                                           $ realToFrac paragraphSpacingBefore

foreign import ccall safe "ef_configuration_resource_directory"
        configurationResourceDirectory'
    :: IO (Ptr UTF8)
configurationResourceDirectory :: IO String
configurationResourceDirectory = do
  cString <- configurationResourceDirectory'
  byteString <- packCString cString
  return $ toString byteString

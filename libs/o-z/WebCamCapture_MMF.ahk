; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=6&t=71142
; Author:
; Date:
; for:     	AHK_L

/*

   file := "test.mp4"
   video_bitrate := 2000000
   duration := 5
   videodevice := "e2eSoft VCam"
   ; audiodevice := "CABLE Output (VB-Audio Virtual Cable)"
   previewWindow := true
   previewWindowWidth := 400
   ; ShowAllDevicesNames := true

*/




setbatchlines -1
LOAD_DLL_Mf_Mfplat_Mfreadwrite()
MFStartup(version := 2, MFSTARTUP_FULL := 0)
if (ShowAllDevicesNames != 1)
{
   VarSetCapacity(MFT_REGISTER_TYPE_INFO, 32, 0)
   DllCall("RtlMoveMemory", "ptr", &MFT_REGISTER_TYPE_INFO, "ptr", MF_GUID(GUID, "MFMediaType_Video"), "ptr", 16)
   DllCall("RtlMoveMemory", "ptr", &MFT_REGISTER_TYPE_INFO + 16, "ptr", MF_GUID(GUID, "MFVideoFormat_H264"), "ptr", 16)
   hardware_encoder := MFTEnumEx(MF_GUID(GUID, "MFT_CATEGORY_VIDEO_ENCODER"), MFT_ENUM_FLAG_HARDWARE := 0x04|MFT_ENUM_FLAG_SORTANDFILTER := 0x40, 0, &MFT_REGISTER_TYPE_INFO)
   if (hardware_encoder != "")
   {
      MFCreateAttributes(pMFAttributes, 4)
      IMFAttributes_SetUINT32(pMFAttributes, MF_GUID(GUID, "MF_READWRITE_ENABLE_HARDWARE_TRANSFORMS"), true)
   }
   else
      MFCreateAttributes(pMFAttributes, 3)
   IMFAttributes_SetGUID(pMFAttributes, MF_GUID(GUID, "MF_TRANSCODE_CONTAINERTYPE"), MF_GUID(GUID1, "MFTranscodeContainerType_MPEG4"))
   IMFAttributes_SetUINT32(pMFAttributes, MF_GUID(GUID, "MF_SINK_WRITER_DISABLE_THROTTLING"), true)
   IMFAttributes_SetUINT32(pMFAttributes, MF_GUID(GUID, "MF_LOW_LATENCY"), true)
   MFCreateSinkWriterFromURL(file, 0, pMFAttributes, pSinkWriter)
   Release(pMFAttributes)
   pMFAttributes := ""
}

deviceError := WidthMax := HeightMax := FpsMax := BitrateMax := StreamNumberVideo := TypeNumberVideo := NUM_CHANNELSMax := BITS_PER_SAMPLEMax := SAMPLES_PER_SECONDMax := BYTES_PER_SECONDMax := StreamNumberAudio := TypeNumberAudio := VideoSources := AudioSources := InputVideoTransformMax := ""
loop 2
{
   if (A_Index = 1)
      LookingSource := "video"
   else
      LookingSource := "audio"
   %LookingSource%basedevice := %LookingSource%device
   MFCreateAttributes(pMFAttributes%LookingSource%, 1)
   IMFAttributes_SetGUID(pMFAttributes%LookingSource%, MF_GUID(GUID, "MF_DEVSOURCE_ATTRIBUTE_SOURCE_TYPE"), MF_GUID(GUID1, "MF_DEVSOURCE_ATTRIBUTE_SOURCE_TYPE_" SubStr(LookingSource, 1, 3) "CAP_GUID"))
   MFEnumDeviceSources(pMFAttributes%LookingSource%, pppSourceActivate, pcSourceActivate)
   Loop % pcSourceActivate
   {
      IMFActivate := NumGet(pppSourceActivate + (A_Index - 1)*A_PtrSize)
      devicename := IMFActivate_GetAllocatedString(IMFActivate, MF_GUID(GUID, "MF_DEVSOURCE_ATTRIBUTE_FRIENDLY_NAME"))
      if (ShowAllDevicesNames = 1)
      {
         basedevicename := devicename
         loop
         {
            if !InStr(%LookingSource%devicenames, """" devicename """`r`n")
               break
            devicename := basedevicename "[" A_Index+1 "]"
         }
         %LookingSource%devicenames .= """" devicename """`r`n"
      }
      else
      {
         if RegexMatch(%LookingSource%device, "\[(\d)]$", match) and (devicename = RegexReplace(%LookingSource%device, "\[\d]$"))
         {
            match1--
            if (match1 = 0)
               %LookingSource%device := devicename
            else
               %LookingSource%device := devicename "[" match1 "]"
         }
         if (devicename = %LookingSource%device) and (MediaSource%LookingSource% = "")
            IMFActivate_ActivateObject(IMFActivate, IMFMediaSource := "{279a808d-aec7-40c8-9c6b-a6b492c78a66}", MediaSource%LookingSource%)
      }
      Release(IMFActivate)
      IMFActivate := ""
   }
   DllCall("ole32\CoTaskMemFree", "ptr", pppSourceActivate)
   Release(pMFAttributes%LookingSource%)
   pMFAttributes%LookingSource% := ""
   if (ShowAllDevicesNames = 1)
   {
      if (%LookingSource%devicenames = "")
         %LookingSource%devicenames .= "None`r`n"
      %LookingSource%devicenames := LookingSource ":`r`n" %LookingSource%devicenames
      if (A_Index = 1)
         Continue
      msgbox % clipboard := videodevicenames "`r`n" audiodevicenames
      ExitApp
   }
   if (MediaSource%LookingSource% = "") or (deviceError != "")
   {
      if (MediaSource%LookingSource% = "")
         deviceError .= "Cannot find " LookingSource " device - """ %LookingSource%basedevice """`n"
      if (A_Index = 1) and (audiodevice != "")
         Continue
      msgbox % deviceError
      ExitApp
   }
   if (A_Index = 1)
   {
      if (hardware_encoder != "")
      {
         MFCreateAttributes(pMFAttributes, 3)
         IMFAttributes_SetUINT32(pMFAttributes, MF_GUID(GUID, "MF_READWRITE_ENABLE_HARDWARE_TRANSFORMS"), true)
      }
      else
         MFCreateAttributes(pMFAttributes, 2)
      IMFAttributes_SetUINT32(pMFAttributes, MF_GUID(GUID, "MF_LOW_LATENCY"), true)
      IMFAttributes_SetUINT32(pMFAttributes, MF_GUID(GUID, "MF_SOURCE_READER_DISCONNECT_MEDIASOURCE_ON_SHUTDOWN"), true)
   }
   MFCreateSourceReaderFromMediaSource(MediaSource%LookingSource%, pMFAttributes, SourceReader)
   loop
   {
      n := A_Index - 1
      if (IMFSourceReader_GetNativeMediaType(SourceReader, n, 0, ppMediaType) = "MF_E_INVALIDSTREAMNUMBER")
      {
         if (LookingSource = "video")
            VideoStreamCount := n
         break
      }
      Release(ppMediaType)
      ppMediaType := ""
      loop
      {
         k := A_Index - 1
         if (IMFSourceReader_GetNativeMediaType(SourceReader, n, k, ppMediaType) = "MF_E_NO_MORE_TYPES")
            break
         IMFAttributes_GetGUID(ppMediaType, MF_GUID(GUID, "MF_MT_MAJOR_TYPE"), pguidValue)
         if (LookingSource = "video") and (MemoryDifference(&pguidValue, MF_GUID(GUID, "MFMediaType_Video"), 16) = 0)
         {
            IMFAttributes_GetGUID(ppMediaType, MF_GUID(GUID, "MF_MT_SUBTYPE"), pguidValueSubType)
            VideoSources .= Format("0x{:x}", NumGet(pguidValueSubType, 0, "int")) "`n"
            if (MemoryDifference(&pguidValueSubType, MF_GUID(GUID, "MFVideoFormat_I420"), 16) = 0) or (MemoryDifference(&pguidValueSubType, MF_GUID(GUID, "MFVideoFormat_IYUV"), 16) = 0) or (MemoryDifference(&pguidValueSubType, MF_GUID(GUID, "MFVideoFormat_NV12"), 16) = 0) or (MemoryDifference(&pguidValueSubType, MF_GUID(GUID, "MFVideoFormat_YUY2"), 16) = 0) or (MemoryDifference(&pguidValueSubType, MF_GUID(GUID, "MFVideoFormat_YV12"), 16) = 0)
               InputVideoTransformCurrent := "WithoutTransform"
            else if ((MemoryDifference(&pguidValueSubType, MF_GUID(GUID, "MFVideoFormat_RGB24"), 16) = 0) or (MemoryDifference(&pguidValueSubType, MF_GUID(GUID, "MFVideoFormat_RGB32"), 16) = 0) or (MemoryDifference(&pguidValueSubType, MF_GUID(GUID, "MFVideoFormat_RGB555"), 16) = 0) or (MemoryDifference(&pguidValueSubType, MF_GUID(GUID, "MFVideoFormat_RGB565"), 16) = 0) or (MemoryDifference(&pguidValueSubType, MF_GUID(GUID, "MFVideoFormat_AYUV"), 16) = 0) or (MemoryDifference(&pguidValueSubType, MF_GUID(GUID, "MFVideoFormat_NV11"), 16) = 0) or (MemoryDifference(&pguidValueSubType, MF_GUID(GUID, "MFVideoFormat_UYVY"), 16) = 0) or (MemoryDifference(&pguidValueSubType, MF_GUID(GUID, "MFVideoFormat_Y41P"), 16) = 0) or (MemoryDifference(&pguidValueSubType, MF_GUID(GUID, "MFVideoFormat_Y41T"), 16) = 0) or (MemoryDifference(&pguidValueSubType, MF_GUID(GUID, "MFVideoFormat_Y42T"), 16) = 0) or (MemoryDifference(&pguidValueSubType, MF_GUID(GUID, "MFVideoFormat_YVU9"), 16) = 0) or (MemoryDifference(&pguidValueSubType, MF_GUID(GUID, "MFVideoFormat_YVYU"), 16) = 0)) and (InputVideoTransformMax != "WithoutTransform")
               InputVideoTransformCurrent := "WithTransform"
            else
               InputVideoTransformCurrent := ""
            if (InputVideoTransformCurrent != "")
            {
               IMFAttributes_GetUINT64(ppMediaType, MF_GUID(GUID, "MF_MT_FRAME_SIZE"), FRAME_SIZE)
               IMFAttributes_GetUINT64(ppMediaType, MF_GUID(GUID, "MF_MT_FRAME_RATE"), FRAME_RATE)
               if (IMFAttributes_GetUINT32(ppMediaType, MF_GUID(GUID, "MF_MT_AVG_BITRATE"), AVG_BITRATE) = "MF_E_ATTRIBUTENOTFOUND")
                  AVG_BITRATE := 0
               WidthCurrent := FRAME_SIZE >> 32
               HeightCurrent := 0xFFFFFFFF & FRAME_SIZE
               FpsCurrent := (FRAME_RATE>>32)/(0xFFFFFFFF & FRAME_RATE)
               BitrateCurrent := AVG_BITRATE
               if ((InputVideoTransformMax = "WithTransform") and (InputVideoTransformCurrent = "WithoutTransform")) or (WidthCurrent > WidthMax) or ((WidthCurrent = WidthMax) and (HeightCurrent > HeightMax)) or ((WidthCurrent = WidthMax) and (HeightCurrent = HeightMax) and (FpsCurrent > FpsMax)) or ((WidthCurrent = WidthMax) and (HeightCurrent = HeightMax) and (FpsCurrent = FpsMax) and (BitrateCurrent > BitrateMax))
               {
                  InputVideoTransformMax := InputVideoTransformCurrent
                  WidthMax := WidthCurrent
                  HeightMax := HeightCurrent
                  FpsMax := FpsCurrent
                  BitrateMax := BitrateCurrent
                  StreamNumberVideo := n
                  TypeNumberVideo := k
               }
            }
         }
         if ((LookingSource = "audio") or (audiodevice = "")) and (MemoryDifference(&pguidValue, MF_GUID(GUID, "MFMediaType_Audio"), 16) = 0)
         {
            IMFAttributes_GetGUID(ppMediaType, MF_GUID(GUID, "MF_MT_SUBTYPE"), pguidValueSubType)
            AudioSources .= Format("0x{:x}", NumGet(pguidValueSubType, 0, "int")) "`n"
            if (MemoryDifference(&pguidValueSubType, MF_GUID(GUID, "MFAudioFormat_PCM"), 16) = 0) or (MemoryDifference(&pguidValueSubType, MF_GUID(GUID, "MFAudioFormat_Float"), 16) = 0)
            {
               if (IMFAttributes_GetUINT32(ppMediaType, MF_GUID(GUID, "MF_MT_AUDIO_AVG_BYTES_PER_SECOND"), BYTES_PER_SECOND) = "MF_E_ATTRIBUTENOTFOUND")
                  BYTES_PER_SECOND := 0
               if (IMFAttributes_GetUINT32(ppMediaType, MF_GUID(GUID, "MF_MT_AUDIO_BITS_PER_SAMPLE"), BITS_PER_SAMPLE) = "MF_E_ATTRIBUTENOTFOUND")
                  BITS_PER_SAMPLE := 0
               if (IMFAttributes_GetUINT32(ppMediaType, MF_GUID(GUID, "MF_MT_AUDIO_SAMPLES_PER_SECOND"), SAMPLES_PER_SECOND) = "MF_E_ATTRIBUTENOTFOUND")
                  SAMPLES_PER_SECOND := 0
               if (IMFAttributes_GetUINT32(ppMediaType, MF_GUID(GUID, "MF_MT_AUDIO_NUM_CHANNELS"), NUM_CHANNELS) = "MF_E_ATTRIBUTENOTFOUND")
                  NUM_CHANNELS := 0
               if (InStr(A_OSVersion, "W") and (((NUM_CHANNELSMax != 1) and (NUM_CHANNELSMax != 2) and (NUM_CHANNELS > 0)) or ((NUM_CHANNELSMax = 1) and (NUM_CHANNELS = 2)))) or (!InStr(A_OSVersion, "W") and (((NUM_CHANNELSMax < 2) and (NUM_CHANNELS > NUM_CHANNELSMax)) or ((NUM_CHANNELSMax = 2) and (NUM_CHANNELS = 6)) or ((NUM_CHANNELSMax > 2) and (NUM_CHANNELSMax != 6) and ((NUM_CHANNELS = 2) or (NUM_CHANNELS = 6))))) or ((NUM_CHANNELS = NUM_CHANNELSMax) and (BITS_PER_SAMPLEMax != 16) and ((BITS_PER_SAMPLE = 16) or (BITS_PER_SAMPLE > BITS_PER_SAMPLEMax))) or ((NUM_CHANNELS = NUM_CHANNELSMax) and (BITS_PER_SAMPLE = BITS_PER_SAMPLEMax) and (SAMPLES_PER_SECONDMax != 44100) and (SAMPLES_PER_SECONDMax != 48000) and ((SAMPLES_PER_SECOND = 44100) or (SAMPLES_PER_SECOND > SAMPLES_PER_SECONDMax))) or ((SAMPLES_PER_SECONDMax != 48000) and (SAMPLES_PER_SECOND = 48000)) or ((NUM_CHANNELS = NUM_CHANNELSMax) and (BITS_PER_SAMPLE = BITS_PER_SAMPLEMax) and (SAMPLES_PER_SECOND = SAMPLES_PER_SECONDMax) and (BYTES_PER_SECOND > BYTES_PER_SECONDMax))
               {
                  if (MemoryDifference(&pguidValueSubType, MF_GUID(GUID, "MFAudioFormat_PCM"), 16) = 0)
                     MFAudioFormat := "MFAudioFormat_PCM"
                  else
                     MFAudioFormat := "MFAudioFormat_Float"
                  NUM_CHANNELSMax := NUM_CHANNELS
                  BITS_PER_SAMPLEMax := BITS_PER_SAMPLE
                  SAMPLES_PER_SECONDMax := SAMPLES_PER_SECOND
                  BYTES_PER_SECONDMax := BYTES_PER_SECOND
                  StreamNumberAudio := n
                  TypeNumberAudio := k
               }
            }
         }
         Release(ppMediaType)
         ppMediaType := ""
      }
   }
   if (audiodevice != "")
   {
      Release(SourceReader)
      SourceReader := ""
   }
   if (audiodevice = "") or (A_Index = 2)
   {
      if (StreamNumberVideo = "")
      {
         Sort, VideoSources, U
         msgbox % "Current VideoSources not supported:`n" VideoSources
         ExitApp
      }
      if (A_Index = 2)
      {
         if (StreamNumberAudio != "")
            StreamNumberAudio += VideoStreamCount
         else
         {
            Sort, AudioSources, U
            msgbox % "Current AudioSources not supported:`n" AudioSources
            ExitApp
         }
         MFCreateCollection(MFCollection)
         IMFCollection_AddElement(MFCollection, MediaSourceVideo)
         IMFCollection_AddElement(MFCollection, MediaSourceAudio)
         MFCreateAggregateSource(MFCollection, AggSource)
         Release(MFCollection)
         MFCollection := ""
         MFCreateSourceReaderFromMediaSource(AggSource, pMFAttributes, SourceReader)
      }
      IMFSourceReader_SetStreamSelection(SourceReader, MF_SOURCE_READER_ALL_STREAMS := 0xFFFFFFFE, false)
      IMFSourceReader_SetStreamSelection(SourceReader, StreamNumberVideo, true)
      if (StreamNumberAudio != "")
         IMFSourceReader_SetStreamSelection(SourceReader, StreamNumberAudio, true)
      IMFSourceReader_GetNativeMediaType(SourceReader, StreamNumberVideo, TypeNumberVideo, ppMediaType)
      IMFAttributes_GetGUID(ppMediaType, MF_GUID(GUID, "MF_MT_SUBTYPE"), pguidValueSubType)
      IMFAttributes_GetUINT32(ppMediaType, MF_GUID(GUID, "MF_MT_INTERLACE_MODE"), INTERLACE_MODE)
      IMFAttributes_GetUINT64(ppMediaType, MF_GUID(GUID, "MF_MT_FRAME_SIZE"), FRAME_SIZE)
      IMFAttributes_GetUINT64(ppMediaType, MF_GUID(GUID, "MF_MT_FRAME_RATE"), FRAME_RATE)
      IMFAttributes_GetUINT64(ppMediaType, MF_GUID(GUID, "MF_MT_PIXEL_ASPECT_RATIO"), ASPECT_RATIO)
      if (IMFAttributes_GetUINT32(ppMediaType, MF_GUID(GUID, "MF_MT_DEFAULT_STRIDE"), DEFAULT_STRIDE) != "MF_E_ATTRIBUTENOTFOUND")
         DEFAULT_STRIDE := DEFAULT_STRIDE<<32>>32
      else
         MFGetStrideForBitmapInfoHeader(NumGet(pguidValueSubType, 0, "uint"), WidthMax, DEFAULT_STRIDE)
      Release(ppMediaType)
      Release(pMFAttributes)
      ppMediaType := pMFAttributes := ""
      if (audiodevice = "")
         break
   }
}
msgbox % "hardware-encoder - " ((hardware_encoder != "") ? hardware_encoder : "none")

loop 2   ; 1 - input, 2 - output
{
   MFCreateMediaType(pMediaTypeVideo%A_Index%)
   IMFAttributes_SetGUID(pMediaTypeVideo%A_Index%, MF_GUID(GUID, "MF_MT_MAJOR_TYPE"), MF_GUID(GUID1, "MFMediaType_Video"))
   if (A_Index = 1)
      IMFAttributes_SetGUID(pMediaTypeVideo%A_Index%, MF_GUID(GUID, "MF_MT_SUBTYPE"), &pguidValueSubType)
   else
   {
      IMFAttributes_SetGUID(pMediaTypeVideo%A_Index%, MF_GUID(GUID, "MF_MT_SUBTYPE"), MF_GUID(GUID1, "MFVideoFormat_H264"))
      IMFAttributes_SetUINT32(pMediaTypeVideo%A_Index%, MF_GUID(GUID, "MF_MT_AVG_BITRATE"), video_bitrate)
   }
   IMFAttributes_SetUINT32(pMediaTypeVideo%A_Index%, MF_GUID(GUID, "MF_MT_INTERLACE_MODE"), INTERLACE_MODE)
   IMFAttributes_SetUINT64(pMediaTypeVideo%A_Index%, MF_GUID(GUID, "MF_MT_FRAME_SIZE"), FRAME_SIZE)
   IMFAttributes_SetUINT64(pMediaTypeVideo%A_Index%, MF_GUID(GUID, "MF_MT_FRAME_RATE"), FRAME_RATE)
   IMFAttributes_SetUINT64(pMediaTypeVideo%A_Index%, MF_GUID(GUID, "MF_MT_PIXEL_ASPECT_RATIO"), ASPECT_RATIO)
}
IMFSinkWriter_AddStream(pSinkWriter, pMediaTypeVideo2, videoStreamIndex)
if (IMFSinkWriter_SetInputMediaType(pSinkWriter, videoStreamIndex, pMediaTypeVideo1, 0) = "MF_E_INVALIDMEDIATYPE")
{
   LOAD_DLL_Colorcnv()
   VideoTransform := 1
   MFCalculateImageSize(MF_GUID(GUID, "MFVideoFormat_YUY2"), WidthMax, HeightMax, cbOutBytesVideo)
   loop 2   ; 1 - input, 2 - output
   {
      MFCreateMediaType(pMedia%A_Index%)
      IMFAttributes_SetGUID(pMedia%A_Index%, MF_GUID(GUID, "MF_MT_MAJOR_TYPE"), MF_GUID(GUID1, "MFMediaType_Video"))
      if (A_Index = 1)
         IMFAttributes_SetGUID(pMedia%A_Index%, MF_GUID(GUID, "MF_MT_SUBTYPE"), &pguidValueSubType)
      else
         IMFAttributes_SetGUID(pMedia%A_Index%, MF_GUID(GUID, "MF_MT_SUBTYPE"), MF_GUID(GUID1, "MFVideoFormat_YUY2"))
      IMFAttributes_SetUINT32(pMedia%A_Index%, MF_GUID(GUID, "MF_MT_INTERLACE_MODE"), INTERLACE_MODE)
      IMFAttributes_SetUINT64(pMedia%A_Index%, MF_GUID(GUID, "MF_MT_FRAME_SIZE"), FRAME_SIZE)
      IMFAttributes_SetUINT64(pMedia%A_Index%, MF_GUID(GUID, "MF_MT_FRAME_RATE"), FRAME_RATE)
      IMFAttributes_SetUINT64(pMedia%A_Index%, MF_GUID(GUID, "MF_MT_PIXEL_ASPECT_RATIO"), ASPECT_RATIO)
   }
   pTransformVideo := ComObjCreate(CLSID_CColorConvertDMO := "{98230571-0087-4204-b020-3282538e57d3}", IID_IMFTransform := "{bf94c121-5b05-4e6f-8000-ba598961414d}")
   IMFTransform_SetInputType(pTransformVideo, 0, pMedia1, 0)
   IMFTransform_SetOutputType(pTransformVideo, 0, pMedia2, 0)
   IMFTransform_GetInputStatus(pTransformVideo, 0, mftStatus)
   if (mftStatus != 1)   ; MFT_INPUT_STATUS_ACCEPT_DATA
   {
      msgbox IMFTransform_GetInputStatus TransformVideo not accept data
      ExitApp
   }
   IMFTransform_ProcessMessage(pTransformVideo, MFT_MESSAGE_COMMAND_FLUSH := 0, 0)
   IMFTransform_ProcessMessage(pTransformVideo, MFT_MESSAGE_NOTIFY_BEGIN_STREAMING := 0x10000000, 0)
   IMFTransform_ProcessMessage(pTransformVideo, MFT_MESSAGE_NOTIFY_START_OF_STREAM := 0x10000003, 0)
   IMFSinkWriter_SetInputMediaType(pSinkWriter, videoStreamIndex, pMedia2, 0)
   Release(pMedia1)
   Release(pMedia2)
   pMedia1 := pMedia2 := ""
}
IMFSourceReader_SetCurrentMediaType(SourceReader, StreamNumberVideo, 0, pMediaTypeVideo1)
Release(pMediaTypeVideo1)
Release(pMediaTypeVideo2)
pMediaTypeVideo1 := pMediaTypeVideo2 := ""

if (StreamNumberAudio != "")
{
   if (NUM_CHANNELSMax = 0)
      NUM_CHANNELS := 1
   else if (NUM_CHANNELSMax > 2) and (NUM_CHANNELSMax < 6)
      NUM_CHANNELS := 2
   else if (NUM_CHANNELSMax >= 6)
   {
      if !InStr(A_OSVersion, "W")
         NUM_CHANNELS := 6
      else
         NUM_CHANNELS := 2
   }
   if (SAMPLES_PER_SECONDMax < 44100)
      SAMPLES_PER_SECOND := 44100
   else if (SAMPLES_PER_SECONDMax > 44100)
      SAMPLES_PER_SECOND := 48000
   loop 2   ; 1 - input, 2 - output
   {
      MFCreateMediaType(pMediaTypeAudio%A_Index%)
      IMFAttributes_SetGUID(pMediaTypeAudio%A_Index%, MF_GUID(GUID, "MF_MT_MAJOR_TYPE"), MF_GUID(GUID1, "MFMediaType_Audio"))
      if (A_Index = 1)
         IMFAttributes_SetGUID(pMediaTypeAudio%A_Index%, MF_GUID(GUID, "MF_MT_SUBTYPE"), MF_GUID(GUID1, "MFAudioFormat_PCM"))
      else
      {
         IMFAttributes_SetGUID(pMediaTypeAudio%A_Index%, MF_GUID(GUID, "MF_MT_SUBTYPE"), MF_GUID(GUID1, "MFAudioFormat_AAC"))
         IMFAttributes_SetUINT32(pMediaTypeAudio%A_Index%, MF_GUID(GUID, "MF_MT_AUDIO_AVG_BYTES_PER_SECOND"), 20000)
      }
      IMFAttributes_SetUINT32(pMediaTypeAudio%A_Index%, MF_GUID(GUID, "MF_MT_AUDIO_BITS_PER_SAMPLE"), 16)
      IMFAttributes_SetUINT32(pMediaTypeAudio%A_Index%, MF_GUID(GUID, "MF_MT_AUDIO_SAMPLES_PER_SECOND"), SAMPLES_PER_SECOND)
      IMFAttributes_SetUINT32(pMediaTypeAudio%A_Index%, MF_GUID(GUID, "MF_MT_AUDIO_NUM_CHANNELS"), NUM_CHANNELS)
   }
   IMFSinkWriter_AddStream(pSinkWriter, pMediaTypeAudio2, audioStreamIndex)
   if (IMFSinkWriter_SetInputMediaType(pSinkWriter, audioStreamIndex, pMediaTypeAudio1, 0) = "MF_E_INVALIDMEDIATYPE")
   {
      msgbox IMFSinkWriter_SetInputMediaType audio error
      ExitApp
   }
   if (IMFSourceReader_SetCurrentMediaType(SourceReader, StreamNumberAudio, 0, pMediaTypeAudio1) = "MF_E_TOPO_CODEC_NOT_FOUND")
   {
      LOAD_DLL_Resampledmo_Mfaacenc()
      AudioTransform := 1
      cbOutBytesAudio := 100000
      loop 2   ; 1 - input, 2 - output
      {
         MFCreateMediaType(pMedia%A_Index%)
         IMFAttributes_SetGUID(pMedia%A_Index%, MF_GUID(GUID, "MF_MT_MAJOR_TYPE"), MF_GUID(GUID1, "MFMediaType_Audio"))
         IMFAttributes_SetGUID(pMedia%A_Index%, MF_GUID(GUID, "MF_MT_SUBTYPE"), MF_GUID(GUID1, MFAudioFormat))
         IMFAttributes_SetUINT32(pMedia%A_Index%, MF_GUID(GUID, "MF_MT_AUDIO_BITS_PER_SAMPLE"), BITS_PER_SAMPLEMax)
         IMFAttributes_SetUINT32(pMedia%A_Index%, MF_GUID(GUID, "MF_MT_AUDIO_NUM_CHANNELS"), NUM_CHANNELSMax)
         IMFAttributes_SetUINT32(pMedia%A_Index%, MF_GUID(GUID, "MF_MT_AUDIO_SAMPLES_PER_SECOND"), SAMPLES_PER_SECONDMax)
         IMFAttributes_SetUINT32(pMedia%A_Index%, MF_GUID(GUID, "MF_MT_AUDIO_BLOCK_ALIGNMENT"), NUM_CHANNELSMax*BITS_PER_SAMPLEMax//8)
         IMFAttributes_SetUINT32(pMedia%A_Index%, MF_GUID(GUID, "MF_MT_AUDIO_AVG_BYTES_PER_SECOND"), SAMPLES_PER_SECONDMax*NUM_CHANNELSMax*BITS_PER_SAMPLEMax//8)
         IMFAttributes_SetUINT32(pMedia%A_Index%, MF_GUID(GUID, "MF_MT_ALL_SAMPLES_INDEPENDENT"), true)
         if (A_Index = 1)
            MFAudioFormat := "MFAudioFormat_PCM", BITS_PER_SAMPLEMax := 16, NUM_CHANNELSMax := NUM_CHANNELS, SAMPLES_PER_SECONDMax := SAMPLES_PER_SECOND
      }
      spTransformUnk := ComObjCreate(CLSID_CResamplerMediaObject := "{f447b69e-1884-4a7e-8055-346f74d6edb3}", IID_IUnknown := "{00000000-0000-0000-C000-000000000046}")
      pTransformAudio := ComObjQuery(spTransformUnk, IID_IMFTransform := "{bf94c121-5b05-4e6f-8000-ba598961414d}")
      spResamplerProps := ComObjQuery(spTransformUnk, IID_IWMResamplerProps := "{E7E9984F-F09F-4da4-903F-6E2E0EFE56B5}")
      IWMResamplerProps_SetHalfFilterLength(spResamplerProps, 60)
      IMFTransform_SetInputType(pTransformAudio, 0, pMedia1, 0)
      IMFTransform_SetOutputType(pTransformAudio, 0, pMedia2, 0)
      IMFTransform_GetInputStatus(pTransformAudio, 0, mftStatus)
      if (mftStatus != 1)   ; MFT_INPUT_STATUS_ACCEPT_DATA
      {
         msgbox IMFTransform_GetInputStatus TransformAudio not accept data
         ExitApp
      }
      IMFTransform_ProcessMessage(pTransformAudio, MFT_MESSAGE_COMMAND_FLUSH := 0, 0)
      IMFTransform_ProcessMessage(pTransformAudio, MFT_MESSAGE_NOTIFY_BEGIN_STREAMING := 0x10000000, 0)
      IMFTransform_ProcessMessage(pTransformAudio, MFT_MESSAGE_NOTIFY_START_OF_STREAM := 0x10000003, 0)
      Release(pMedia1)
      Release(pMedia2)
      pMedia1 := pMedia2 := ""
   }
   Release(pMediaTypeAudio1)
   Release(pMediaTypeAudio2)
   pMediaTypeAudio1 := pMediaTypeAudio2 := ""
}
IMFSinkWriter_BeginWriting(pSinkWriter)

if (previewWindow = 1)
{
   previewWidthMax := WidthMax
   previewHeightMax := HeightMax
   MFCalculateImageSize(MF_GUID(GUID, "MFVideoFormat_RGB32"), previewWidthMax, previewHeightMax, cbOutBytesPreview)
   if (previewWindowWidth != "")
   {
      if (previewHeightMax >= previewWidthMax) and (previewWindowWidth < 34)
         previewWindowWidth := 34
      else if (previewHeightMax < previewWidthMax) and (previewWindowWidth/previewWidthMax*previewHeightMax < 34)
         previewWindowWidth := ceil(34*previewWidthMax/previewHeightMax)
      if (mod(previewWindowWidth, 2) != 0)
         previewWindowWidth++
      previewHeightMax := ceil(previewHeightMax*previewWindowWidth/previewWidthMax)
      if (mod(previewHeightMax, 2) != 0)
         previewHeightMax++
      previewWidthMax := previewWindowWidth
      MFCalculateImageSize(MF_GUID(GUID, "MFVideoFormat_RGB32"), previewWidthMax, previewHeightMax, cbOutBytesPreview%previewWindowWidth%)
      LOAD_DLL_Vidreszr()
      loop 2   ; 1 - input, 2 - output
      {
         MFCreateMediaType(pMedia%A_Index%)
         IMFAttributes_SetGUID(pMedia%A_Index%, MF_GUID(GUID, "MF_MT_MAJOR_TYPE"), MF_GUID(GUID1, "MFMediaType_Video"))
         IMFAttributes_SetGUID(pMedia%A_Index%, MF_GUID(GUID, "MF_MT_SUBTYPE"), MF_GUID(GUID1, "MFVideoFormat_RGB32"))
         IMFAttributes_SetUINT32(pMedia%A_Index%, MF_GUID(GUID, "MF_MT_INTERLACE_MODE"), INTERLACE_MODE)
         if (A_Index = 1)
            IMFAttributes_SetUINT64(pMedia%A_Index%, MF_GUID(GUID, "MF_MT_FRAME_SIZE"), FRAME_SIZE)
         else
            IMFAttributes_SetUINT64(pMedia%A_Index%, MF_GUID(GUID, "MF_MT_FRAME_SIZE"), (previewWidthMax<<32)|previewHeightMax)
         IMFAttributes_SetUINT64(pMedia%A_Index%, MF_GUID(GUID, "MF_MT_FRAME_RATE"), FRAME_RATE)
         IMFAttributes_SetUINT64(pMedia%A_Index%, MF_GUID(GUID, "MF_MT_PIXEL_ASPECT_RATIO"), ASPECT_RATIO)
      }
      pResizePreview := ComObjCreate(CLSID_CResizerDMO := "{1ea1ea14-48f4-4054-ad1a-e8aee10ac805}", IID_IMFTransform := "{bf94c121-5b05-4e6f-8000-ba598961414d}")
      IMFTransform_SetInputType(pResizePreview, 0, pMedia1, 0)
      IMFTransform_SetOutputType(pResizePreview, 0, pMedia2, 0)
      IMFTransform_GetInputStatus(pResizePreview, 0, mftStatus)
      if (mftStatus != 1)   ; MFT_INPUT_STATUS_ACCEPT_DATA
      {
         msgbox IMFTransform_GetInputStatus ResizePreview not accept data
         ExitApp
      }
      IMFTransform_ProcessMessage(pResizePreview, MFT_MESSAGE_COMMAND_FLUSH := 0, 0)
      IMFTransform_ProcessMessage(pResizePreview, MFT_MESSAGE_NOTIFY_BEGIN_STREAMING := 0x10000000, 0)
      IMFTransform_ProcessMessage(pResizePreview, MFT_MESSAGE_NOTIFY_START_OF_STREAM := 0x10000003, 0)
      Release(pMedia1)
      Release(pMedia2)
      pMedia1 := pMedia2 := ""
   }

   gui, new, hwndhGui
   gui, show, w%previewWidthMax% h%previewHeightMax%

   VarSetCapacity(D2D1_RENDER_TARGET_PROPERTIES, 28, 0)
   NumPut(DXGI_FORMAT_B8G8R8A8_UNORM := 87, D2D1_RENDER_TARGET_PROPERTIES, 4, "int")   ; pixelFormat.format
   NumPut(D2D1_ALPHA_MODE_IGNORE := 3, D2D1_RENDER_TARGET_PROPERTIES, 8, "int")   ; pixelFormat.alphaMode
   NumPut(D2D1_RENDER_TARGET_USAGE_GDI_COMPATIBLE := 0x00000002, D2D1_RENDER_TARGET_PROPERTIES, 20, "int")  ; usage

   VarSetCapacity(D2D1_HWND_RENDER_TARGET_PROPERTIES, 12+A_PtrSize, 0)
   NumPut(hGui, D2D1_HWND_RENDER_TARGET_PROPERTIES, 0, "ptr")   ; hwnd
   NumPut(previewWidthMax, D2D1_HWND_RENDER_TARGET_PROPERTIES, A_PtrSize, "uint")   ; pixelSize.width
   NumPut(previewHeightMax, D2D1_HWND_RENDER_TARGET_PROPERTIES, A_PtrSize+4, "uint")   ; pixelSize.height

   VarSetCapacity(D2D1_BITMAP_PROPERTIES, 16, 0)
   NumPut(DXGI_FORMAT_B8G8R8A8_UNORM := 87, D2D1_BITMAP_PROPERTIES, 0, "int")   ; pixelFormat.format
   NumPut(D2D1_ALPHA_MODE_IGNORE := 3, D2D1_BITMAP_PROPERTIES, 4, "int")   ; pixelFormat.alphaMode

   LOAD_DLL_d2d1()
   D2D1CreateFactory(D2D1_FACTORY_TYPE_SINGLE_THREADED := 0, IID_ID2D1Factory := "{06152247-6f50-465a-9245-118bfd3b6007}", 0, factory)
   ID2D1Factory_CreateHwndRenderTarget(factory, &D2D1_RENDER_TARGET_PROPERTIES, &D2D1_HWND_RENDER_TARGET_PROPERTIES, renderTarget)
   ID2D1HwndRenderTarget_CreateBitmap(renderTarget, previewWidthMax, previewHeightMax, 0, 0, &D2D1_BITMAP_PROPERTIES, d2dBitmap)
   if (MemoryDifference(&pguidValueSubType, MF_GUID(GUID, "MFVideoFormat_RGB32"), 16) != 0)
   {
      LOAD_DLL_Colorcnv()
      PreviewTransform := 1
      loop 2   ; 1 - input, 2 - output
      {
         MFCreateMediaType(pMedia%A_Index%)
         IMFAttributes_SetGUID(pMedia%A_Index%, MF_GUID(GUID, "MF_MT_MAJOR_TYPE"), MF_GUID(GUID1, "MFMediaType_Video"))
         if (A_Index = 1)
            IMFAttributes_SetGUID(pMedia%A_Index%, MF_GUID(GUID, "MF_MT_SUBTYPE"), &pguidValueSubType)
         else
            IMFAttributes_SetGUID(pMedia%A_Index%, MF_GUID(GUID, "MF_MT_SUBTYPE"), MF_GUID(GUID1, "MFVideoFormat_RGB32"))
         IMFAttributes_SetUINT32(pMedia%A_Index%, MF_GUID(GUID, "MF_MT_INTERLACE_MODE"), INTERLACE_MODE)
         IMFAttributes_SetUINT64(pMedia%A_Index%, MF_GUID(GUID, "MF_MT_FRAME_SIZE"), FRAME_SIZE)
         IMFAttributes_SetUINT64(pMedia%A_Index%, MF_GUID(GUID, "MF_MT_FRAME_RATE"), FRAME_RATE)
         IMFAttributes_SetUINT64(pMedia%A_Index%, MF_GUID(GUID, "MF_MT_PIXEL_ASPECT_RATIO"), ASPECT_RATIO)
      }
      pTransformPreview := ComObjCreate(CLSID_CColorConvertDMO := "{98230571-0087-4204-b020-3282538e57d3}", IID_IMFTransform := "{bf94c121-5b05-4e6f-8000-ba598961414d}")
      IMFTransform_SetInputType(pTransformPreview, 0, pMedia1, 0)
      IMFTransform_SetOutputType(pTransformPreview, 0, pMedia2, 0)
      IMFTransform_GetInputStatus(pTransformPreview, 0, mftStatus)
      if (mftStatus != 1)   ; MFT_INPUT_STATUS_ACCEPT_DATA
      {
         msgbox IMFTransform_GetInputStatus TransformPreview not accept data
         ExitApp
      }
      IMFTransform_ProcessMessage(pTransformPreview, MFT_MESSAGE_COMMAND_FLUSH := 0, 0)
      IMFTransform_ProcessMessage(pTransformPreview, MFT_MESSAGE_NOTIFY_BEGIN_STREAMING := 0x10000000, 0)
      IMFTransform_ProcessMessage(pTransformPreview, MFT_MESSAGE_NOTIFY_START_OF_STREAM := 0x10000003, 0)
      Release(pMedia1)
      Release(pMedia2)
      pMedia1 := pMedia2 := ""
   }
}

CaptureStart := start := ""
CaptureDuration := duration*1000
loop
{
   IMFSourceReader_ReadSample(SourceReader, MF_SOURCE_READER_ANY_STREAM := 0xFFFFFFFE, 0, ActualStreamIndex, StreamFlags, Timestamp, pSample)
   if (ActualStreamIndex = StreamNumberVideo)
   {
      ActualStreamIndex := videoStreamIndex
      ActualStream := "Video"
   }
   else
   {
      ActualStreamIndex := audioStreamIndex
      ActualStream := "Audio"
   }
   if (CaptureStart = "") and (pSample != 0) and (ActualStreamIndex = videoStreamIndex)
   {
      CaptureStart := 1
      TimestampStart := Timestamp
      start := A_TickCount
   }
   if CaptureStart
   {
      if (pSample != 0)
      {
         if (gap%ActualStreamIndex% = 1)
         {
            IMFAttributes_SetUINT32(pSample, MF_GUID(GUID, "MFSampleExtension_Discontinuity"), true)
            gap%ActualStreamIndex% := ""
         }
         IMFSample_SetSampleTime(pSample, Timestamp - TimestampStart)
         if ((VideoTransform = 1) and (ActualStreamIndex = videoStreamIndex)) or ((AudioTransform = 1) and (ActualStreamIndex = audioStreamIndex))
         {
            IMFSample_GetSampleDuration(pSample, llSampleDuration)
            loop
            {
               if (IMFTransform_ProcessInput(pTransform%ActualStream%, 0, pSample, 0) != "MF_E_INVALIDREQUEST")
                  break
            }
            MFCreateSample(pSample1)
            VarSetCapacity(MFT_OUTPUT_DATA_BUFFER, 4*A_PtrSize, 0)
            NumPut(pSample1, MFT_OUTPUT_DATA_BUFFER, A_PtrSize, "ptr")
            MFCreateMemoryBuffer(cbOutBytes%ActualStream%, pBuffer1)
            IMFSample_AddBuffer(pSample1, pBuffer1)
            IMFTransform_ProcessOutput(pTransform%ActualStream%, 0, 1, &MFT_OUTPUT_DATA_BUFFER, processOutputStatus)
            if (ActualStreamIndex = videoStreamIndex) and (DEFAULT_STRIDE < 0)
            {
               MFCreateMemoryBuffer(cbOutBytesVideo, pBuffer2)
               loop 2
                  IMFMediaBuffer_Lock(pBuffer%A_Index%, pData%A_Index%, 0, 0)
               MFCopyImage(pData2, WidthMax*2, pData1+(HeightMax-1)*WidthMax*2, WidthMax*-2, WidthMax*2, HeightMax)
               loop 2
                  IMFMediaBuffer_Unlock(pBuffer%A_Index%)
               IMFMediaBuffer_SetCurrentLength(pBuffer2, cbOutBytesVideo)
               MFCreateSample(pSample2)
               IMFSample_AddBuffer(pSample2, pBuffer2)
               IMFSample_SetSampleTime(pSample2, Timestamp - TimestampStart)
               IMFSample_SetSampleDuration(pSample2, llSampleDuration)
               IMFSinkWriter_WriteSample(pSinkWriter, ActualStreamIndex, pSample2)
               Release(pSample2)
               Release(pBuffer2)
               pSample2 := pBuffer2 := ""
            }
            else
            {
               IMFSample_SetSampleTime(pSample1, Timestamp - TimestampStart)
               IMFSample_SetSampleDuration(pSample1, llSampleDuration)
               IMFSinkWriter_WriteSample(pSinkWriter, ActualStreamIndex, pSample1)
            }
            Release(pSample1)
            Release(pBuffer1)
            pSample1 := pBuffer1 := ""
         }
         else
            IMFSinkWriter_WriteSample(pSinkWriter, ActualStreamIndex, pSample)
         if (previewWindow = 1) and (ActualStreamIndex = videoStreamIndex)
         {
            if (PreviewTransform = 1)
            {
               loop
               {
                  if (IMFTransform_ProcessInput(pTransformPreview, 0, pSample, 0) != "MF_E_INVALIDREQUEST")
                     break
               }
               MFCreateSample(pSample1)
               VarSetCapacity(MFT_OUTPUT_DATA_BUFFER, 4*A_PtrSize, 0)
               NumPut(pSample1, MFT_OUTPUT_DATA_BUFFER, A_PtrSize, "ptr")
               MFCreateMemoryBuffer(cbOutBytesPreview, pBuffer)
               IMFSample_AddBuffer(pSample1, pBuffer)
               IMFTransform_ProcessOutput(pTransformPreview, 0, 1, &MFT_OUTPUT_DATA_BUFFER, processOutputStatus)
            }
            if (previewWindowWidth != "")
            {
               loop
               {
                  if (IMFTransform_ProcessInput(pResizePreview, 0, pSample%PreviewTransform%, 0) != "MF_E_INVALIDREQUEST")
                     break
               }
               MFCreateSample(pSample2)
               VarSetCapacity(MFT_OUTPUT_DATA_BUFFER, 4*A_PtrSize, 0)
               NumPut(pSample2, MFT_OUTPUT_DATA_BUFFER, A_PtrSize, "ptr")
               MFCreateMemoryBuffer(cbOutBytesPreview%previewWindowWidth%, pBuffer%previewWindowWidth%)
               IMFSample_AddBuffer(pSample2, pBuffer%previewWindowWidth%)
               IMFTransform_ProcessOutput(pResizePreview, 0, 1, &MFT_OUTPUT_DATA_BUFFER, processOutputStatus)
            }
            if (previewWindowWidth = "") and (PreviewTransform = "")
               IMFSample_GetBufferByIndex(pSample, 0, pBuffer)
            IMFMediaBuffer_Lock(pBuffer%previewWindowWidth%, pData, 0, 0)
            if (DEFAULT_STRIDE < 0)
            {
               MFCreateMemoryBuffer(cbOutBytesPreview%previewWindowWidth%, pBuffer1)
               IMFMediaBuffer_Lock(pBuffer1, pData1, 0, 0)
               MFCopyImage(pData1, previewWidthMax*4, pData+(previewHeightMax-1)*previewWidthMax*4, previewWidthMax*-4, previewWidthMax*4, previewHeightMax)
               ID2D1Bitmap_CopyFromMemory(d2dBitmap, 0, pData1, previewWidthMax*4)
               IMFMediaBuffer_Unlock(pBuffer1)
               Release(pBuffer1)
               pBuffer1 := ""
            }
            else
               ID2D1Bitmap_CopyFromMemory(d2dBitmap, 0, pData, previewWidthMax*4)
            ID2D1HwndRenderTarget_BeginDraw(renderTarget)
            ID2D1HwndRenderTarget_DrawBitmap(renderTarget, d2dBitmap, 0, 1, D2D1_BITMAP_INTERPOLATION_MODE_NEAREST_NEIGHBOR := 0, 0)
            ID2D1HwndRenderTarget_EndDraw(renderTarget)
            IMFMediaBuffer_Unlock(pBuffer%previewWindowWidth%)
            Release(pBuffer%previewWindowWidth%)
            pBuffer%previewWindowWidth% := ""
            if (pBuffer != "")
            {
               Release(pBuffer)
               pBuffer := ""
            }
            loop 2
            {
               if (pSample%A_Index% != "")
               {
                  Release(pSample%A_Index%)
                  pSample%A_Index% := ""
               }
            }
         }
      }
      else if (StreamFlags & MF_SOURCE_READERF_STREAMTICK := 256)
      {
         IMFSinkWriter_SendStreamTick(pSinkWriter, ActualStreamIndex, Timestamp - TimestampStart)
         gap%ActualStreamIndex% := 1
      }
   }
   if (pSample != 0)
   {
      Release(pSample)
      pSample := ""
   }
   if ((A_TickCount - start) >= CaptureDuration)
      break
}
IMFSinkWriter_Finalize(pSinkWriter)
IMFMediaSource_Shutdown(MediaSourceVideo)
Release(MediaSourceVideo)
if (VideoTransform = 1)
{
   Release(pTransformVideo)
   pTransformVideo := VideoTransform := ""
}
if (audiodevice != "")
{
   if (AudioTransform = 1)
   {
      Release(spResamplerProps)
      Release(pTransformAudio)
      Release(spTransformUnk)
      spResamplerProps := pTransformAudio := spTransformUnk := AudioTransform := ""
   }
   IMFMediaSource_Shutdown(MediaSourceAudio)
   IMFMediaSource_Shutdown(AggSource)
   Release(MediaSourceAudio)
   Release(AggSource)
   MediaSourceAudio := AggSource := ""
}
if (previewWindow = 1)
{
   if (PreviewTransform = 1)
   {
      Release(pTransformPreview)
      pTransformPreview := PreviewTransform := ""
   }
   Release(factory)
   Release(renderTarget)
   Release(d2dBitmap)
   factory := renderTarget := d2dBitmap := ""
}
Release(SourceReader)
Release(pSinkWriter)
SourceReader := MediaSourceVideo := pSinkWriter := ""
MFShutdown()
msgbox done
ExitApp





LOAD_DLL_Mf_Mfplat_Mfreadwrite()
{
   if !DllCall("GetModuleHandle","str","Mf")
      DllCall("LoadLibrary","Str", "Mf.dll", "ptr")
   if !DllCall("GetModuleHandle","str","Mfplat")
      DllCall("LoadLibrary","Str", "Mfplat.dll", "ptr")
   if !DllCall("GetModuleHandle","str","Mfreadwrite")
      DllCall("LoadLibrary","Str", "Mfreadwrite.dll", "ptr")
}

MFStartup(version, dwFlags)
{
   hr := DllCall("Mfplat.dll\MFStartup", "uint", version, "uint", dwFlags)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

MFShutdown()
{
   hr := DllCall("Mfplat.dll\MFShutdown")
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

MFTEnumEx(guidCategory, Flags, pInputType, pOutputType)
{
   if (A_PtrSize = 8)
      hr := DllCall("Mfplat\MFTEnumEx", "ptr", guidCategory, "uint", Flags, "ptr", pInputType, "ptr", pOutputType, "ptr*", pppMFTActivate, "uint*", pnumMFTActivate)
   else
      hr := DllCall("Mfplat\MFTEnumEx", "uint64", NumGet(guidCategory+0, 0, "uint64"), "uint64", NumGet(guidCategory+0, 8, "uint64"), "uint", Flags, "ptr", pInputType, "ptr", pOutputType, "ptr*", pppMFTActivate, "uint*", pnumMFTActivate)
   loop % pnumMFTActivate
   {
      IMFActivate := NumGet(pppMFTActivate + (A_Index - 1)*A_PtrSize)
      if (A_Index = 1)
         hardware_encoder := IMFActivate_GetAllocatedString(IMFActivate, MF_GUID(GUID, "MFT_FRIENDLY_NAME_Attribute"))
      Release(IMFActivate)
   }
   DllCall("ole32\CoTaskMemFree", "ptr", pppMFTActivate)
   return hardware_encoder
}

MFCreateSinkWriterFromURL(pwszOutputURL, pByteStream, pAttributes, ByRef ppSinkWriter)
{
   hr := DllCall("Mfreadwrite.dll\MFCreateSinkWriterFromURL", "str", pwszOutputURL, "ptr", pByteStream, "ptr", pAttributes, "ptr*", ppSinkWriter)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

MFCreateSourceReaderFromMediaSource(pMediaSource, pAttributes, ByRef ppSourceReader)
{
   hr := DllCall("Mfreadwrite.dll\MFCreateSourceReaderFromMediaSource", "ptr", pMediaSource, "ptr", pAttributes, "ptr*", ppSourceReader)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

MFCreateMediaType(ByRef ppMFType)
{
   hr := DllCall("Mfplat.dll\MFCreateMediaType", "ptr*", ppMFType)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

MFCreateAttributes(ByRef ppMFAttributes, cInitialSize)
{
   hr := DllCall("Mfplat.dll\MFCreateAttributes", "ptr*", ppMFAttributes, "uint", cInitialSize)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

MFCreateSample(ByRef ppIMFSample)
{
   hr := DllCall("Mfplat.dll\MFCreateSample", "ptr*", ppIMFSample)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

MFCreateMemoryBuffer(cbMaxLength, ByRef ppBuffer)
{
   hr := DllCall("Mfplat.dll\MFCreateMemoryBuffer", "uint", cbMaxLength, "ptr*", ppBuffer)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

MFCopyImage(pDest, lDestStride, pSrc, lSrcStride, dwWidthInBytes, dwLines)
{
   hr := DllCall("Mfplat.dll\MFCopyImage", "ptr", pDest, "int", lDestStride, "ptr", pSrc, "int", lSrcStride, "uint", dwWidthInBytes, "uint", dwLines)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

MFEnumDeviceSources(pAttributes, ByRef pppSourceActivate, ByRef pcSourceActivate)
{
   hr := DllCall("Mf.dll\MFEnumDeviceSources", "ptr", pAttributes, "ptr*", pppSourceActivate, "uint*", pcSourceActivate)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

MFCreateCollection(ByRef ppIMFCollection)
{
   hr := DllCall("Mfplat.dll\MFCreateCollection", "ptr*", ppIMFCollection)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

MFCreateAggregateSource(pSourceCollection, ByRef ppAggSource)
{
   hr := DllCall("Mf.dll\MFCreateAggregateSource", "ptr", pSourceCollection, "ptr*", ppAggSource)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

IMFSourceReader_SetCurrentMediaType(this, dwStreamIndex, pdwReserved, pMediaType)
{
   hr := DllCall(NumGet(NumGet(this+0)+7*A_PtrSize), "ptr", this, "uint", dwStreamIndex, "uint", pdwReserved, "ptr", pMediaType)
   if hr or ErrorLevel
   {
      if !ErrorLevel
      {
         if ((hr&=0xFFFFFFFF) = 0xC00D5212)   ; MF_E_TOPO_CODEC_NOT_FOUND
            return "MF_E_TOPO_CODEC_NOT_FOUND"
      }
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
   }
}

IMFSourceReader_SetStreamSelection(this, dwStreamIndex, fSelected)
{
   hr := DllCall(NumGet(NumGet(this+0)+4*A_PtrSize), "ptr", this, "uint", dwStreamIndex, "int", fSelected)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

IMFSourceReader_GetNativeMediaType(this, dwStreamIndex, dwMediaTypeIndex, ByRef ppMediaType)
{
   hr := DllCall(NumGet(NumGet(this+0)+5*A_PtrSize), "ptr", this, "uint", dwStreamIndex, "uint", dwMediaTypeIndex, "ptr*", ppMediaType)
   if hr or ErrorLevel
   {
      if !ErrorLevel
      {
         if (hr&=0xFFFFFFFF) = 0xC00D36B3   ; MF_E_INVALIDSTREAMNUMBER
            return "MF_E_INVALIDSTREAMNUMBER"
         if (hr&=0xFFFFFFFF) = 0xC00D36B9   ; MF_E_NO_MORE_TYPES
            return "MF_E_NO_MORE_TYPES"
      }
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
   }
}

IMFSourceReader_ReadSample(this, dwStreamIndex, dwControlFlags, ByRef pdwActualStreamIndex, ByRef pdwStreamFlags, ByRef pllTimestamp, ByRef ppSample)
{
   hr := DllCall(NumGet(NumGet(this+0)+9*A_PtrSize), "ptr", this, "uint", dwStreamIndex, "uint", dwControlFlags, "uint*", pdwActualStreamIndex, "uint*", pdwStreamFlags, "int64*", pllTimestamp, "ptr*", ppSample)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

IMFAttributes_GetGUID(this, guidKey, ByRef pguidValue)
{
   VarSetCapacity(pguidValue, 16, 0)
   hr := DllCall(NumGet(NumGet(this+0)+10*A_PtrSize), "ptr", this, "ptr", guidKey, "ptr", &pguidValue)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
   return &pguidValue
}

IMFAttributes_GetUINT64(this, guidKey, ByRef punValue)
{
   hr := DllCall(NumGet(NumGet(this+0)+8*A_PtrSize), "ptr", this, "ptr", guidKey, "uint64*", punValue)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

IMFAttributes_GetUINT32(this, guidKey, ByRef punValue)
{
   hr := DllCall(NumGet(NumGet(this+0)+7*A_PtrSize), "ptr", this, "ptr", guidKey, "uint*", punValue)
   if hr or ErrorLevel
   {
      if !ErrorLevel
      {
         if (hr&=0xFFFFFFFF) = 0xC00D36E6   ; MF_E_ATTRIBUTENOTFOUND
            return "MF_E_ATTRIBUTENOTFOUND"
      }
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
   }
}

IMFAttributes_SetUINT32(this, guidKey, unValue)
{
   hr := DllCall(NumGet(NumGet(this+0)+21*A_PtrSize), "ptr", this, "ptr", guidKey, "uint", unValue)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

IMFAttributes_SetUINT64(this, guidKey, unValue)
{
   hr := DllCall(NumGet(NumGet(this+0)+22*A_PtrSize), "ptr", this, "ptr", guidKey, "uint64", unValue)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

IMFAttributes_SetGUID(this, guidKey, guidValue)
{
   hr := DllCall(NumGet(NumGet(this+0)+24*A_PtrSize), "ptr", this, "ptr", guidKey, "ptr", guidValue)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

IMFAttributes_CopyAllItems(this, pDest)
{
   hr := DllCall(NumGet(NumGet(this+0)+32*A_PtrSize), "ptr", this, "ptr", pDest)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

IMFActivate_GetAllocatedString(this, guidKey)
{
   hr := DllCall(NumGet(NumGet(this+0)+13*A_PtrSize), "ptr", this, "ptr", guidKey, "ptr*", ppwszValue, "uint*", pcchLength)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
   AllocatedString := StrGet(ppwszValue, pcchLength, "UTF-16")
   DllCall("ole32\CoTaskMemFree", "ptr", ppwszValue)
   return AllocatedString
}

IMFActivate_ActivateObject(this, riid, ByRef ppv)
{
   GUID(riid, riid)
   hr := DllCall(NumGet(NumGet(this+0)+33*A_PtrSize), "ptr", this, "ptr", &riid, "ptr*", ppv)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

IMFSinkWriter_SendStreamTick(this, dwStreamIndex, llTimestamp)
{
   hr := DllCall(NumGet(NumGet(this+0)+7*A_PtrSize), "ptr", this, "uint", dwStreamIndex, "int64", llTimestamp)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

IMFSinkWriter_AddStream(this, pMediaTypeOut, ByRef pdwStreamIndex)
{
   hr := DllCall(NumGet(NumGet(this+0)+3*A_PtrSize), "ptr", this, "ptr", pMediaTypeOut, "ptr*", pdwStreamIndex)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

IMFSinkWriter_SetInputMediaType(this, dwStreamIndex, pInputMediaType, pEncodingParameters)
{
   hr := DllCall(NumGet(NumGet(this+0)+4*A_PtrSize), "ptr", this, "uint", dwStreamIndex, "ptr", pInputMediaType, "ptr", pEncodingParameters)
   if hr or ErrorLevel
   {
      if !ErrorLevel
      {
         if (hr&=0xFFFFFFFF) = 0xC00D36B4   ; MF_E_INVALIDMEDIATYPE
            return "MF_E_INVALIDMEDIATYPE"
      }
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
   }
}

IMFSinkWriter_BeginWriting(this)
{
   hr := DllCall(NumGet(NumGet(this+0)+5*A_PtrSize), "ptr", this)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

IMFSinkWriter_WriteSample(this, dwStreamIndex, pSample)
{
   hr := DllCall(NumGet(NumGet(this+0)+6*A_PtrSize), "ptr", this, "uint", dwStreamIndex, "ptr", pSample)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

IMFSinkWriter_Finalize(this)
{
   hr := DllCall(NumGet(NumGet(this+0)+11*A_PtrSize), "ptr", this)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

IMFMediaBuffer_Lock(this, ByRef ppbBuffer, ByRef pcbMaxLength, ByRef pcbCurrentLength)
{
   hr := DllCall(NumGet(NumGet(this+0)+3*A_PtrSize), "ptr", this, "ptr*", ppbBuffer, "uint*", pcbMaxLength, "uint*", pcbCurrentLength)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

IMFMediaBuffer_Unlock(this)
{
   hr := DllCall(NumGet(NumGet(this+0)+4*A_PtrSize), "ptr", this)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

IMFMediaBuffer_SetCurrentLength(this, cbCurrentLength)
{
   hr := DllCall(NumGet(NumGet(this+0)+6*A_PtrSize), "ptr", this, "uint", cbCurrentLength)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

IMFMediaSource_Shutdown(this)
{
   hr := DllCall(NumGet(NumGet(this+0)+12*A_PtrSize), "ptr", this)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

IMFSample_AddBuffer(this, pBuffer)
{
   hr := DllCall(NumGet(NumGet(this+0)+42*A_PtrSize), "ptr", this, "ptr", pBuffer)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

IMFSample_GetBufferByIndex(this, dwIndex, ByRef ppBuffer)
{
   hr := DllCall(NumGet(NumGet(this+0)+40*A_PtrSize), "ptr", this, "uint", dwIndex, "ptr*", ppBuffer)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

IMFSample_SetSampleTime(this, hnsSampleTime)
{
   hr := DllCall(NumGet(NumGet(this+0)+36*A_PtrSize), "ptr", this, "int64", hnsSampleTime)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

IMFSample_GetSampleDuration(this, ByRef phnsSampleDuration)
{
   hr := DllCall(NumGet(NumGet(this+0)+37*A_PtrSize), "ptr", this, "int64*", phnsSampleDuration)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

IMFSample_SetSampleDuration(this, hnsSampleDuration)
{
   hr := DllCall(NumGet(NumGet(this+0)+38*A_PtrSize), "ptr", this, "int64", hnsSampleDuration)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

IMFCollection_AddElement(this, pUnkElement)
{
   hr := DllCall(NumGet(NumGet(this+0)+5*A_PtrSize), "ptr", this, "ptr", pUnkElement)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

LOAD_DLL_Resampledmo_Mfaacenc()
{
   if !DllCall("GetModuleHandle","str","Resampledmo")
      DllCall("LoadLibrary","Str", "Resampledmo.dll", "ptr")
   if !DllCall("GetModuleHandle","str","Mfaacenc")
      DllCall("LoadLibrary","Str", "Mfaacenc.dll", "ptr")
}

IMFTransform_GetInputStatus(this, dwInputStreamID, ByRef pdwFlags)
{
   hr := DllCall(NumGet(NumGet(this+0)+19*A_PtrSize), "ptr", this, "uint", dwInputStreamID, "uint*", pdwFlags)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

IMFTransform_ProcessMessage(this, eMessage, ulParam)
{
   hr := DllCall(NumGet(NumGet(this+0)+23*A_PtrSize), "ptr", this, "uint", eMessage, "uint", ulParam)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

IMFTransform_ProcessOutput(this, dwFlags, cOutputBufferCount, pOutputSamples, ByRef pdwStatus)
{
   hr := DllCall(NumGet(NumGet(this+0)+25*A_PtrSize), "ptr", this, "uint", dwFlags, "uint", cOutputBufferCount, "ptr", pOutputSamples, "uint*", pdwStatus)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

IMFTransform_ProcessInput(this, dwInputStreamID, pSample, dwFlags)
{
   hr := DllCall(NumGet(NumGet(this+0)+24*A_PtrSize), "ptr", this, "uint", dwInputStreamID, "ptr", pSample, "uint", dwFlags)
   if hr or ErrorLevel
   {
      if !ErrorLevel
      {
         if (hr&=0xFFFFFFFF) = 0xC00D36B2   ; MF_E_INVALIDREQUEST
            return "MF_E_INVALIDREQUEST"
      }
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
   }
}

IMFTransform_GetOutputStreamInfo(this, dwInputStreamID, pStreamInfo)
{
   hr := DllCall(NumGet(NumGet(this+0)+7*A_PtrSize), "ptr", this, "uint", dwInputStreamID, "ptr", pStreamInfo)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

IMFTransform_SetOutputType(this, dwInputStreamID, pType, dwFlags)
{
   hr := DllCall(NumGet(NumGet(this+0)+16*A_PtrSize), "ptr", this, "uint", dwInputStreamID, "ptr", pType, "uint", dwFlags)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

IMFTransform_SetInputType(this, dwInputStreamID, pType, dwFlags)
{
   hr := DllCall(NumGet(NumGet(this+0)+15*A_PtrSize), "ptr", this, "uint", dwInputStreamID, "ptr", pType, "uint", dwFlags)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

IWMResamplerProps_SetHalfFilterLength(this, lhalfFilterLen)
{
   hr := DllCall(NumGet(NumGet(this+0)+3*A_PtrSize), "ptr", this, "int", lhalfFilterLen)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

IMF2DBuffer2_Lock2D(this, ByRef ppbScanline0, ByRef plPitch)
{
   hr := DllCall(NumGet(NumGet(this+0)+3*A_PtrSize), "ptr", this, "ptr*", ppbScanline0, "int*", plPitch)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

MFGetStrideForBitmapInfoHeader(format, dwWidth, ByRef pStride)
{
   hr := DllCall("Mfplat.dll\MFGetStrideForBitmapInfoHeader", "uint", format, "uint", dwWidth, "int*", pStride)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

MFCalculateImageSize(guidSubtype, unWidth, unHeight, ByRef pcbImageSize)
{
   hr := DllCall("Mfplat.dll\MFCalculateImageSize", "ptr", guidSubtype, "uint", unWidth, "uint", unHeight, "uint*", pcbImageSize)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

MF_GUID(ByRef GUID, name)
{
   static init:=1, _:={}
   if init
   {
      init:=0
      _.MF_MT_MAJOR_TYPE := [0x48eba18e, 0xf8c9, 0x4687, 0xbf, 0x11, 0x0a, 0x74, 0xc9, 0xf9, 0x6a, 0x8f]
      _.MF_MT_SUBTYPE := [0xf7e34c9a, 0x42e8, 0x4714, 0xb7, 0x4b, 0xcb, 0x29, 0xd7, 0x2c, 0x35, 0xe5]
      _.MF_MT_AVG_BITRATE := [0x20332624, 0xfb0d, 0x4d9e, 0xbd, 0x0d, 0xcb, 0xf6, 0x78, 0x6c, 0x10, 0x2e]
      _.MF_MT_INTERLACE_MODE := [0xe2724bb8, 0xe676, 0x4806, 0xb4, 0xb2, 0xa8, 0xd6, 0xef, 0xb4, 0x4c, 0xcd]
      _.MF_MT_FRAME_SIZE := [0x1652c33d, 0xd6b2, 0x4012, 0xb8, 0x34, 0x72, 0x03, 0x08, 0x49, 0xa3, 0x7d]
      _.MF_MT_FRAME_RATE := [0xc459a2e8, 0x3d2c, 0x4e44, 0xb1, 0x32, 0xfe, 0xe5, 0x15, 0x6c, 0x7b, 0xb0]
      _.MF_MT_PIXEL_ASPECT_RATIO := [0xc6376a1e, 0x8d0a, 0x4027, 0xbe, 0x45, 0x6d, 0x9a, 0x0a, 0xd3, 0x9b, 0xb6]
      _.MF_MT_AUDIO_AVG_BYTES_PER_SECOND := [0x1aab75c8, 0xcfef, 0x451c, 0xab, 0x95, 0xac, 0x03, 0x4b, 0x8e, 0x17, 0x31]
      _.MF_MT_AUDIO_BLOCK_ALIGNMENT := [0x322de230, 0x9eeb, 0x43bd, 0xab, 0x7a, 0xff, 0x41, 0x22, 0x51, 0x54, 0x1d]
      _.MF_MT_AUDIO_SAMPLES_PER_SECOND := [0x5faeeae7, 0x0290, 0x4c31, 0x9e, 0x8a, 0xc5, 0x34, 0xf6, 0x8d, 0x9d, 0xba]
      _.MF_MT_AUDIO_BITS_PER_SAMPLE := [0xf2deb57f, 0x40fa, 0x4764, 0xaa, 0x33, 0xed, 0x4f, 0x2d, 0x1f, 0xf6, 0x69]
      _.MF_MT_AUDIO_NUM_CHANNELS := [0x37e48bf5, 0x645e, 0x4c5b, 0x89, 0xde, 0xad, 0xa9, 0xe2, 0x9b, 0x69, 0x6a]
      _.MFT_CATEGORY_VIDEO_ENCODER := [0xf79eac7d, 0xe545, 0x4387, 0xbd, 0xee, 0xd6, 0x47, 0xd7, 0xbd, 0xe4, 0x2a]
      _.MF_TRANSCODE_CONTAINERTYPE := [0x150ff23f, 0x4abc, 0x478b, 0xac, 0x4f, 0xe1, 0x91, 0x6f, 0xba, 0x1c, 0xca]
      _.MF_READWRITE_ENABLE_HARDWARE_TRANSFORMS := [0xa634a91c, 0x822b, 0x41b9, 0xa4, 0x94, 0x4d, 0xe4, 0x64, 0x36, 0x12, 0xb0]
      _.MFTranscodeContainerType_MPEG4 := [0xdc6cd05d, 0xb9d0, 0x40ef, 0xbd, 0x35, 0xfa, 0x62, 0x2c, 0x1a, 0xb2, 0x8a]
      _.MFT_FRIENDLY_NAME_Attribute := [0x314ffbae, 0x5b41, 0x4c95, 0x9c, 0x19, 0x4e, 0x7d, 0x58, 0x6f, 0xac, 0xe3]
      _.MF_DEVSOURCE_ATTRIBUTE_FRIENDLY_NAME := [0x60d0e559, 0x52f8, 0x4fa2, 0xbb, 0xce, 0xac, 0xdb, 0x34, 0xa8, 0xec, 0x1]
      _.MF_SINK_WRITER_DISABLE_THROTTLING := [0x08b845d8, 0x2b74, 0x4afe, 0x9d, 0x53, 0xbe, 0x16, 0xd2, 0xd5, 0xae, 0x4f]
      _.MF_LOW_LATENCY := [0x9c27891a, 0xed7a, 0x40e1, 0x88, 0xe8, 0xb2, 0x27, 0x27, 0xa0, 0x24, 0xee]
      _.MF_DEVSOURCE_ATTRIBUTE_SOURCE_TYPE := [0xc60ac5fe, 0x252a, 0x478f, 0xa0, 0xef, 0xbc, 0x8f, 0xa5, 0xf7, 0xca, 0xd3]
      _.MF_DEVSOURCE_ATTRIBUTE_SOURCE_TYPE_AUDCAP_GUID := [0x14dd9a1c, 0x7cff, 0x41be, 0xb1, 0xb9, 0xba, 0x1a, 0xc6, 0xec, 0xb5, 0x71]
      _.MF_DEVSOURCE_ATTRIBUTE_SOURCE_TYPE_VIDCAP_GUID := [0x8ac3587a, 0x4ae7, 0x42d8, 0x99, 0xe0, 0x0a, 0x60, 0x13, 0xee, 0xf9, 0x0f]
      _.MF_SOURCE_READER_DISCONNECT_MEDIASOURCE_ON_SHUTDOWN := [0x56b67165, 0x219e, 0x456d, 0xa2, 0x2e, 0x2d, 0x30, 0x04, 0xc7, 0xfe, 0x56]
      _.MF_MT_ALL_SAMPLES_INDEPENDENT := [0xc9173739, 0x5e56, 0x461c, 0xb7, 0x13, 0x46, 0xfb, 0x99, 0x5c, 0xb9, 0x5f]
      _.MF_MT_DEFAULT_STRIDE := [0x644b4e48, 0x1e02, 0x4516, 0xb0, 0xeb, 0xc0, 0x1c, 0xa9, 0xd4, 0x9a, 0xc6]
      _.MFSampleExtension_Discontinuity := [0x9cdf01d9, 0xa0f0, 0x43ba, 0xb0, 0x77, 0xea, 0xa0, 0x6c, 0xbd, 0x72, 0x8a]
      _.MFMediaType_Video := [0x73646976, 0x0000, 0x0010, 0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71]
      _.MFMediaType_Audio := [0x73647561, 0x0000, 0x0010, 0x80, 0x00, 0x00, 0xAA, 0x00, 0x38, 0x9B, 0x71]
      _.MFAudioFormat_AAC := [0x1610, 0x0000, 0x0010, 0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71]
      _.MFAudioFormat_Float := [0x0003, 0x0000, 0x0010, 0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71]
      _.MFAudioFormat_PCM := [0x0001, 0x0000, 0x0010, 0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71]
      _.MFVideoFormat_H264 := [0x34363248, 0x0000, 0x0010, 0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71]   ; FCC("H264") = 0x34363248
      _.MFVideoFormat_I420 := [0x30323449, 0x0000, 0x0010, 0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71]
      _.MFVideoFormat_IYUV := [0x56555949, 0x0000, 0x0010, 0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71]
      _.MFVideoFormat_NV12 := [0x3231564E, 0x0000, 0x0010, 0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71]
      _.MFVideoFormat_YUY2 := [0x32595559, 0x0000, 0x0010, 0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71]
      _.MFVideoFormat_YV12 := [0x32315659, 0x0000, 0x0010, 0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71]
      _.MFVideoFormat_RGB24 := [0x00000014, 0x0000, 0x0010, 0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71]
      _.MFVideoFormat_RGB32 := [0x00000016, 0x0000, 0x0010, 0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71]
      _.MFVideoFormat_ARGB32 := [0x00000015, 0x0000, 0x0010, 0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71]
      _.MFVideoFormat_RGB555 := [0x00000018, 0x0000, 0x0010, 0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71]
      _.MFVideoFormat_RGB565 :=	[0x00000017, 0x0000, 0x0010, 0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71]
      _.MFVideoFormat_RGB8 := [0x00000029, 0x0000, 0x0010, 0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71]
      _.MFVideoFormat_AYUV := [0x56555941, 0x0000, 0x0010, 0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71]
      _.MFVideoFormat_NV11 := [0x3131564e, 0x0000, 0x0010, 0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71]
      _.MFVideoFormat_UYVY := [0x59565955, 0x0000, 0x0010, 0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71]
      _.MFVideoFormat_V216 := [0x36313276, 0x0000, 0x0010, 0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71]
      _.MFVideoFormat_V410 := [0x30313476, 0x0000, 0x0010, 0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71]
      _.MFVideoFormat_Y41P := [0x50313459, 0x0000, 0x0010, 0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71]
      _.MFVideoFormat_Y41T := [0x54313459, 0x0000, 0x0010, 0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71]
      _.MFVideoFormat_Y42T := [0x54323459, 0x0000, 0x0010, 0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71]
      _.MFVideoFormat_YVU9 := [0x39555659, 0x0000, 0x0010, 0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71]
      _.MFVideoFormat_YVYU := [0x55595659, 0x0000, 0x0010, 0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71]
   }
   if _.haskey(name)
   {
      p := _[name]
      VarSetCapacity(GUID,16)
      ,NumPut(p.1+(p.2<<32)+(p.3<<48),GUID,0,"int64")
      ,NumPut(p.4+(p.5<<8)+(p.6<<16)+(p.7<<24)+(p.8<<32)+(p.9<<40)+(p.10<<48)+(p.11<<56),GUID,8,"int64")
      return &GUID
   }
   else return name
}

GUID(ByRef GUID, sGUID)
{
    VarSetCapacity(GUID, 16, 0)
    return DllCall("ole32\CLSIDFromString", "WStr", sGUID, "Ptr", &GUID) >= 0 ? &GUID : ""
}

FCC(var)
{
   c := StrSplit(var)
   msgbox % clipboard := Format("{:#x}",((Asc(c[1])&255)+((Asc(c[2])&255)<<8)+((Asc(c[3])&255)<<16)+((Asc(c[4])&255)<<24)))
}

Release(this)
{
   DllCall(NumGet(NumGet(this+0)+2*A_PtrSize), "ptr", this)
   if ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

MemoryDifference(ptr1, ptr2, num)
{
   return DllCall("msvcrt\memcmp", "ptr", ptr1, "ptr", ptr2, "int", num)
}

_Error(val)
{
   msgbox % val
   ExitApp
}

LOAD_DLL_Colorcnv()
{
   if !DllCall("GetModuleHandle","str","Colorcnv")
      DllCall("LoadLibrary","Str", "Colorcnv.dll", "ptr")
}

LOAD_DLL_Vidreszr()
{
   if !DllCall("GetModuleHandle","str","Vidreszr")
      DllCall("LoadLibrary","Str", "Vidreszr.dll", "ptr")
}

LOAD_DLL_d2d1()
{
   if !DllCall("GetModuleHandle","str","d2d1")
      DllCall("LoadLibrary","Str", "d2d1.dll", "ptr")
}

D2D1CreateFactory(factoryType, riid, pFactoryOptions, ByRef ppIFactory)
{
   hr := DllCall("d2d1\D2D1CreateFactory", "uint", factoryType, "ptr", GUID(CLSID, riid), "ptr", pFactoryOptions, "ptr*", ppIFactory)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

ID2D1Factory_CreateHwndRenderTarget(this, renderTargetProperties, hwndRenderTargetProperties, ByRef hwndRenderTarget)
{
   hr := DllCall(NumGet(NumGet(this+0)+14*A_PtrSize), "ptr", this, "ptr", renderTargetProperties, "ptr", hwndRenderTargetProperties, "ptr*", hwndRenderTarget)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

ID2D1HwndRenderTarget_CreateBitmap(this, width, height, srcData, pitch, bitmapProperties, ByRef bitmap)
{
   hr := DllCall(NumGet(NumGet(this+0)+4*A_PtrSize), "ptr", this, "int64", (height << 32) | width, "ptr", srcData, "uint", pitch, "ptr", bitmapProperties, "ptr*", bitmap)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

ID2D1Bitmap_CopyFromMemory(this, dstRect, srcData, pitch)
{
   hr := DllCall(NumGet(NumGet(this+0)+10*A_PtrSize), "ptr", this, "ptr", dstRect, "ptr", srcData, "uint", pitch)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}

ID2D1HwndRenderTarget_BeginDraw(this)
{
   DllCall(NumGet(NumGet(this+0)+48*A_PtrSize), "ptr", this)
   if ErrorLevel
      _Error(A_ThisFunc " ErrorLevel: " ErrorLevel)
}

ID2D1HwndRenderTarget_EndDraw(this)
{
   hr := DllCall(NumGet(NumGet(this+0)+49*A_PtrSize), "ptr", this, "uint64*", tag1, "uint64*", tag2)
   if hr or ErrorLevel
      _Error(A_ThisFunc " error: " hr "`ntag1: " tag1 "`ntag2: " tag2 "`nErrorLevel: " ErrorLevel)
}

ID2D1HwndRenderTarget_DrawBitmap(this, bitmap, destinationRectangle, opacity, interpolationMode, sourceRectangle)
{
   hr := DllCall(NumGet(NumGet(this+0)+26*A_PtrSize), "ptr", this, "ptr", bitmap, "ptr", destinationRectangle, "float", opacity, "uint", interpolationMode, "ptr", sourceRectangle)
   if ErrorLevel
      _Error(A_ThisFunc " error: " hr "`nErrorLevel: " ErrorLevel)
}


/*
; test IMFTransform::GetOutputAvailableType
loop
{
   if (DllCall(NumGet(NumGet(pTransformVideo+0)+14*A_PtrSize), "ptr", pTransformVideo, "uint", 0, "uint", A_Index -1, "ptr*", ppType) = 0)   ; IMFTransform::GetOutputAvailableType
   {
      IMFAttributes_GetGUID(ppType, MF_GUID(GUID, "MF_MT_SUBTYPE"), pguidValueSubType)
      if (numget(pguidValueSubType, 0, "int") = 0x32595559)   ; MFVideoFormat_YUY2
         msgbox ok
   }
   else
      msgbox error
}
*/
class NvAPI
{
    static DllFile := (A_PtrSize = 8) ? "nvapi64.dll" : "nvapi.dll"
    static hmod
    static init := NvAPI.ClassInit()
    static DELFunc := OnExit(ObjBindMethod(NvAPI, "_Delete"))

    static NVAPI_GENERIC_STRING_MAX   := 4096
    static NVAPI_MAX_LOGICAL_GPUS     :=   64
    static NVAPI_MAX_PHYSICAL_GPUS    :=   64
    static NVAPI_MAX_VIO_DEVICES      :=    8
    static NVAPI_SHORT_STRING_MAX     :=   64

    static ErrorMessage := False

    ClassInit()
    {
        if !(NvAPI.hmod := DllCall("LoadLibrary", "Str", NvAPI.DllFile, "UPtr"))
        {
            MsgBox, 16, % A_ThisFunc, % "LoadLibrary Error: " A_LastError
            ExitApp
        }
        if (NvStatus := DllCall(DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0x0150E828, "CDECL UPtr"), "CDECL") != 0)
        {
            MsgBox, 16, % A_ThisFunc, % "NvAPI_Initialize Error: " NvStatus
            ExitApp
        }
    }

; ###############################################################################################################################

    DisableHWCursor()
    {
        static DisableHWCursor := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0xAB163097, "CDECL UPtr")
        hNvDisplay := NvAPI.EnumNvidiaDisplayHandle()
        if !(NvStatus := DllCall(DisableHWCursor, "Ptr", hNvDisplay))
            return hNvDisplay
        return NvAPI.GetErrorMessage(NvStatus)
    }

; ###############################################################################################################################

    DISP_GetGDIPrimaryDisplayId()
    {
        static DISP_GetGDIPrimaryDisplayId := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0x1E9D8A31, "CDECL UPtr")
        if !(NvStatus := DllCall(DISP_GetGDIPrimaryDisplayId, "UInt*", displayId, "CDECL"))
            return displayId
        return NvAPI.GetErrorMessage(NvStatus)
    }

; ###############################################################################################################################

    DRS_CreateSession()
    {
        static DRS_CreateSession := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0x0694D52E, "CDECL UPtr")
        if !(NvStatus := DllCall(DRS_CreateSession, "UInt*", phSession, "CDECL"))
            return phSession
        return NvAPI.GetErrorMessage(NvStatus)
    }

; ###############################################################################################################################

    DRS_DestroySession(hSession)
    {
        static DRS_DestroySession := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0xDAD9CFF8, "CDECL UPtr")
        if !(NvStatus := DllCall(DRS_DestroySession, "Ptr", hSession, "CDECL"))
            return hSession
        return NvAPI.GetErrorMessage(NvStatus)
    }

; ###############################################################################################################################

    DRS_GetCurrentGlobalProfile(hSession)
    {
        static DRS_GetCurrentGlobalProfile := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0x617BFF9F, "CDECL UPtr")
        if !(NvStatus := DllCall(DRS_GetCurrentGlobalProfile, "Ptr", hSession, "UInt*", phProfile, "CDECL"))
            return phProfile
        return NvAPI.GetErrorMessage(NvStatus)
    }

; ###############################################################################################################################

    DRS_GetNumProfiles(hSession)
    {
        static DRS_GetNumProfiles := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0x1DAE4FBC, "CDECL UPtr")
        if !(NvStatus := DllCall(DRS_GetNumProfiles, "Ptr", hSession, "UInt*", numProfiles, "CDECL"))
            return numProfiles
        return NvAPI.GetErrorMessage(NvStatus)
    }

; ###############################################################################################################################

    DRS_LoadSettings(hSession)
    {
        static DRS_LoadSettings := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0x375DBD6B, "CDECL UPtr")
        if !(NvStatus := DllCall(DRS_LoadSettings, "Ptr", hSession, "CDECL"))
            return hSession
        return NvAPI.GetErrorMessage(NvStatus)
    }

; ###############################################################################################################################

    DRS_LoadSettingsFromFile(hSession, fileName)
    {
        static DRS_LoadSettingsFromFile := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0xD3EDE889, "CDECL UPtr")
        if !(NvStatus := DllCall(DRS_LoadSettingsFromFile, "Ptr", hSession, "WStr", fileName, "CDECL"))
            return hSession
        return NvAPI.GetErrorMessage(NvStatus)
    }

; ###############################################################################################################################

    DRS_RestoreAllDefaults(hSession)
    {
        static DRS_RestoreAllDefaults := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0x5927B094, "CDECL UPtr")
        if !(NvStatus := DllCall(DRS_RestoreAllDefaults, "Ptr", hSession, "CDECL"))
            return hSession
        return NvAPI.GetErrorMessage(NvStatus)
    }

; ###############################################################################################################################

    DRS_SaveSettings(hSession)
    {
        static DRS_SaveSettings := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0xFCBC7E14, "CDECL UPtr")
        if !(NvStatus := DllCall(DRS_SaveSettings, "Ptr", hSession, "CDECL"))
            return hSession
        return NvAPI.GetErrorMessage(NvStatus)
    }

; ###############################################################################################################################

    DRS_SaveSettingsToFile(hSession, fileName)
    {
        static DRS_SaveSettingsToFile := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0x2BE25DF8, "CDECL UPtr")
        if !(NvStatus := DllCall(DRS_SaveSettingsToFile, "Ptr", hSession, "Ptr", &fileName, "CDECL"))
            return hSession
        return NvAPI.GetErrorMessage(NvStatus)
    }

; ###############################################################################################################################

    EnableHWCursor()
    {
        static EnableHWCursor := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0x2863148D, "CDECL UPtr")
        hNvDisplay := NvAPI.EnumNvidiaDisplayHandle()
        if !(NvStatus := DllCall(NvAPI._EnableHWCursor, "Ptr", hNvDisplay))
            return hNvDisplay
        return NvAPI.GetErrorMessage(NvStatus)
    }

; ###############################################################################################################################

    EnumLogicalGPUs()
    {
        static EnumLogicalGPUs := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0x48B3EA59, "CDECL UPtr")
        VarSetCapacity(nvGPUHandle, 4 * NvAPI.NVAPI_MAX_LOGICAL_GPUS, 0)
        if !(NvStatus := DllCall(EnumLogicalGPUs, "Ptr", &nvGPUHandle, "UInt*", pGpuCount, "CDECL"))
        {
            GPUH := []
            loop % pGpuCount
                GPUH[A_Index] := NumGet(nvGPUHandle, 4 * (A_Index - 1), "Int")
            return GPUH
        }
        return NvAPI.GetErrorMessage(NvStatus)
    }

; ###############################################################################################################################

    EnumNvidiaDisplayHandle(thisEnum := 0)
    {
        static EnumNvidiaDisplayHandle := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0x9ABDD40D, "CDECL UPtr")
        if !(NvStatus := DllCall(EnumNvidiaDisplayHandle, "UInt", thisEnum, "UInt*", pNvDispHandle, "CDECL"))
            return pNvDispHandle
        return "*" NvStatus
    }

; ###############################################################################################################################

    EnumNvidiaUnAttachedDisplayHandle(thisEnum := 0)
    {
        static EnumNvidiaUnAttachedDisplayHandle := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0x20DE9260, "CDECL UPtr")
        if !(NvStatus := DllCall(EnumNvidiaUnAttachedDisplayHandle, "Int", thisEnum, "UInt*", pNvUnAttachedDispHandle, "CDECL"))
            return pNvUnAttachedDispHandle
        return "*" NvStatus
    }

; ###############################################################################################################################

    EnumPhysicalGPUs()
    {
        static EnumPhysicalGPUs := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0xE5AC921F, "CDECL UPtr")
        VarSetCapacity(nvGPUHandle, 4 * NvAPI.NVAPI_MAX_PHYSICAL_GPUS, 0)
        if !(NvStatus := DllCall(EnumPhysicalGPUs, "Ptr", &nvGPUHandle, "UInt*", pGpuCount, "CDECL"))
        {
            GPUH := []
            loop % pGpuCount
                GPUH[A_Index] := NumGet(nvGPUHandle, 4 * (A_Index - 1), "Int")
            return GPUH
        }
        return NvAPI.GetErrorMessage(NvStatus)
    }

; ###############################################################################################################################

    GetAssociatedDisplayOutputId()
    {
        static GetAssociatedDisplayOutputId := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0xD995937E, "CDECL UPtr")
        hNvDisplay := NvAPI.EnumNvidiaDisplayHandle()
        if !(NvStatus := DllCall(GetAssociatedDisplayOutputId, "Ptr", hNvDisplay, "UInt*", pOutputId, "CDECL"))
            return pOutputId
        return NvAPI.GetErrorMessage(NvStatus)
    }

; ###############################################################################################################################

    GetAssociatedNvidiaDisplayHandle(thisEnum := 0)
    {
        static GetAssociatedNvidiaDisplayHandle := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0x35C29134, "CDECL UPtr")
        szDisplayName := NvAPI.GetAssociatedNvidiaDisplayName(thisEnum)
        if !(NvStatus := DllCall(GetAssociatedNvidiaDisplayHandle, "AStr", szDisplayName, "Int*", pNvDispHandle, "CDECL"))
            return pNvDispHandle
        return NvAPI.GetErrorMessage(NvStatus)
    }

; ###############################################################################################################################

    GetAssociatedNvidiaDisplayName(thisEnum := 0)
    {
        static GetAssociatedNvidiaDisplayName := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0x22A78B05, "CDECL UPtr")
        NvDispHandle := NvAPI.EnumNvidiaDisplayHandle(thisEnum)
        VarSetCapacity(szDisplayName, NvAPI.NVAPI_SHORT_STRING_MAX, 0)
        if !(NvStatus := DllCall(GetAssociatedNvidiaDisplayName, "Ptr", NvDispHandle, "Ptr", &szDisplayName, "CDECL"))
            return StrGet(&szDisplayName, "CP0")
        return NvAPI.GetErrorMessage(NvStatus)
    }

; ###############################################################################################################################

    GetDisplayDriverMemoryInfo()
    {
        static GetDisplayDriverMemoryInfo := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0x774AA982, "CDECL UPtr")
        static NV_DISPLAY_DRIVER_MEMORY_INFO := 24
        hNvDisplay := NvAPI.EnumNvidiaDisplayHandle()
        VarSetCapacity(pMemoryInfo, NV_DISPLAY_DRIVER_MEMORY_INFO, 0), NumPut(NV_DISPLAY_DRIVER_MEMORY_INFO | 0x20000, pMemoryInfo, 0, "UInt")
        if !(NvStatus := DllCall(GetDisplayDriverMemoryInfo, "Ptr", hNvDisplay, "Ptr", &pMemoryInfo, "CDECL"))
        {
            MI := {}
            MI.version                          := NumGet(pMemoryInfo,  0, "UInt")
            MI.dedicatedVideoMemory             := NumGet(pMemoryInfo,  4, "UInt")
            MI.availableDedicatedVideoMemory    := NumGet(pMemoryInfo,  8, "UInt")
            MI.systemVideoMemory                := NumGet(pMemoryInfo, 12, "UInt")
            MI.sharedSystemMemory               := NumGet(pMemoryInfo, 16, "UInt")
            MI.curAvailableDedicatedVideoMemory := NumGet(pMemoryInfo, 20, "UInt")
            return MI
        }
        return NvAPI.GetErrorMessage(NvStatus)
    }

; ###############################################################################################################################

    GetDisplayDriverVersion()
    {
        static GetDisplayDriverVersion := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0xF951A4D1, "CDECL UPtr")
        static NV_DISPLAY_DRIVER_VERSION := 12 + (2 * NvAPI.NVAPI_SHORT_STRING_MAX)
        hNvDisplay := NvAPI.EnumNvidiaDisplayHandle()
        VarSetCapacity(pVersion, NV_DISPLAY_DRIVER_VERSION, 0), NumPut(NV_DISPLAY_DRIVER_VERSION | 0x10000, pVersion, 0, "UInt")
        if !(NvStatus := DllCall(GetDisplayDriverVersion, "Ptr", hNvDisplay, "Ptr", &pVersion, "CDECL"))
        {
            DV := {}
            DV.version             := NumGet(pVersion,    0, "UInt")
            DV.drvVersion          := NumGet(pVersion,    4, "UInt")
            DV.bldChangeListNum    := NumGet(pVersion,    8, "UInt")
            DV.szBuildBranchString := StrGet(&pVersion + 12, NvAPI.NVAPI_SHORT_STRING_MAX, "CP0")
            DV.szAdapterString     := StrGet(&pVersion + 76, NvAPI.NVAPI_SHORT_STRING_MAX, "CP0")
            return DV
        }
        return NvAPI.GetErrorMessage(NvStatus)
    }

; ###############################################################################################################################

    GetDisplayPortInfo(outputId := 0)
    {
        static GetDisplayPortInfo := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0xC64FF367, "CDECL UPtr")
        static NV_DISPLAY_PORT_INFO := 44
        static NV_DP_LINK_RATE      := {6: "1_62GBPS", 10: "2_70GBPS", 20: "5_40GBPS"}
        static NV_DP_LANE_COUNT     := {1: "1_LANE", 2: "2_LANE", 4: "4_LANE"}
        static NV_DP_COLOR_FORMAT   := {0: "COLOR_FORMAT_RGB"}
        static NV_DP_DYNAMIC_RANGE  := {0: "DYNAMIC_RANGE_VESA"}
        static NV_DP_COLORIMETRY    := {0: "COLORIMETRY_RGB"}
        static NV_DP_BPC            := {0: "BPC_DEFAULT"}
        static NvCaps := {isDp:                             0x1
                        , isInternalDp:                     0x2
                        , isColorCtrlSupported:             0x4
                        , is6BPCSupported:                  0x8
                        , is8BPCSupported:                  0x10
                        , is10BPCSupported:                 0x20
                        , is12BPCSupported:                 0x40
                        , is16BPCSupported:                 0x80
                        , isYCrCb422Supported:              0x100
                        , isYCrCb444Supported:              0x200
                        , isRgb444SupportedOnCurrentMode:   0x400
                        , isYCbCr444SupportedOnCurrentMode: 0x800
                        , isYCbCr422SupportedOnCurrentMode: 0x1000
                        , is6BPCSupportedOnCurrentMode:     0x2000
                        , is8BPCSupportedOnCurrentMode:     0x4000
                        , is10BPCSupportedOnCurrentMode:    0x8000
                        , is12BPCSupportedOnCurrentMode:    0x10000
                        , is16BPCSupportedOnCurrentMode:    0x20000}
        hNvDisplay := NvAPI.EnumNvidiaDisplayHandle()
        VarSetCapacity(pInfo, NV_DISPLAY_PORT_INFO, 0), NumPut(NV_DISPLAY_PORT_INFO | 0x10000, pInfo, 0, "UInt")
        if !(NvStatus := DllCall(GetDisplayPortInfo, "Ptr", hNvDisplay, "UInt", outputId, "Ptr", &pInfo, "CDECL"))
        {
            DPI := {}
            DPI.version      := NumGet(pInfo, 0, "UInt")
            DPI.dpcd_ver     := NumGet(pInfo, 4, "UInt")
            DPI.maxLinkRate  := NV_DP_LINK_RATE[NumGet(pInfo, 8, "UInt")]
            DPI.maxLaneCount := NV_DP_LANE_COUNT[NumGet(pInfo, 12, "UInt")]
            DPI.curLinkRate  := NV_DP_LINK_RATE[NumGet(pInfo, 16, "UInt")]
            DPI.curLaneCount := NV_DP_LANE_COUNT[NumGet(pInfo, 20, "UInt")]
            DPI.colorFormat  := NV_DP_COLOR_FORMAT[NumGet(pInfo, 24, "UInt")]
            DPI.dynamicRange := NV_DP_DYNAMIC_RANGE[NumGet(pInfo, 28, "UInt")]
            DPI.colorimetry  := NV_DP_COLORIMETRY[NumGet(pInfo, 32, "UInt")]
            DPI.bpc          := NV_DP_BPC[NumGet(pInfo, 36, "UInt")]
            bitfield := NumGet(pInfo, 40, "UInt")
            for NvCap, mask in NvCaps
                DPI[NvCap] := !!(bitfield & mask)
            return DPI
        }
        return NvAPI.GetErrorMessage(NvStatus)
    }

; ###############################################################################################################################

    GetDVCInfo(outputId := 0)
    {
        static GetDVCInfo := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0x4085DE45, "CDECL UPtr")
        static NV_DISPLAY_DVC_INFO := 16
        hNvDisplay := NvAPI.EnumNvidiaDisplayHandle()
        VarSetCapacity(pDVCInfo, NV_DISPLAY_DVC_INFO), NumPut(NV_DISPLAY_DVC_INFO | 0x10000, pDVCInfo, 0, "UInt")
        if !(NvStatus := DllCall(GetDVCInfo, "Ptr", hNvDisplay, "UInt", outputId, "Ptr", &pDVCInfo, "CDECL"))
        {
            DVC := {}
            DVC.version      := NumGet(pDVCInfo,  0, "UInt")
            DVC.currentLevel := NumGet(pDVCInfo,  4, "UInt")
            DVC.minLevel     := NumGet(pDVCInfo,  8, "UInt")
            DVC.maxLevel     := NumGet(pDVCInfo, 12, "UInt")
            return DVC
        }
        return NvAPI.GetErrorMessage(NvStatus)
    }

; ###############################################################################################################################

    GetDVCInfoEx(thisEnum := 0, outputId := 0)
    {
        static GetDVCInfoEx := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0x0E45002D, "CDECL UPtr")
        static NV_DISPLAY_DVC_INFO_EX := 20
        hNvDisplay := NvAPI.GetAssociatedNvidiaDisplayHandle(thisEnum)
        VarSetCapacity(pDVCInfo, NV_DISPLAY_DVC_INFO_EX), NumPut(NV_DISPLAY_DVC_INFO_EX | 0x10000, pDVCInfo, 0, "UInt")
        if !(NvStatus := DllCall(GetDVCInfoEx, "Ptr", hNvDisplay, "UInt", outputId, "Ptr", &pDVCInfo, "CDECL"))
        {
            DVC := {}
            DVC.version      := NumGet(pDVCInfo,  0, "UInt")
            DVC.currentLevel := NumGet(pDVCInfo,  4, "Int")
            DVC.minLevel     := NumGet(pDVCInfo,  8, "Int")
            DVC.maxLevel     := NumGet(pDVCInfo, 12, "Int")
            DVC.defaultLevel := NumGet(pDVCInfo, 16, "Int")
            return DVC
        }
        return NvAPI.GetErrorMessage(NvStatus)
    }

; ###############################################################################################################################

    GetErrorMessage(ErrorCode)
    {
        static GetErrorMessage := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0x6C2D048C, "CDECL UPtr")
        VarSetCapacity(szDesc, NvAPI.NVAPI_SHORT_STRING_MAX, 0)
        if !(NvStatus := DllCall(GetErrorMessage, "Ptr", ErrorCode, "WStr", szDesc, "CDECL"))
            return this.ErrorMessage ? "Error: " StrGet(&szDesc, "CP0") : "*" ErrorCode
        return NvStatus
    }

; ###############################################################################################################################

    GetHDMISupportInfo(outputId := 0)
    {
        static GetHDMISupportInfo := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0x6AE16EC3, "CDECL UPtr")
        static NV_HDMI_SUPPORT_INFO := 12
        static NvCaps := {isGpuHDMICapable:        0x1
                        , isMonUnderscanCapable:   0x2
                        , isMonBasicAudioCapable:  0x4
                        , isMonYCbCr444Capable:    0x8
                        , isMonYCbCr422Capable:    0x10
                        , isMonxvYCC601Capable:    0x20
                        , isMonxvYCC709Capable:    0x40
                        , isMonHDMI:               0x80
                        , isMonsYCC601Capable:     0x100
                        , isMonAdobeYCC601Capable: 0x200
                        , isMonAdobeRGBCapable:    0x400}
        hNvDisplay := NvAPI.EnumNvidiaDisplayHandle()
        VarSetCapacity(pInfo, NV_HDMI_SUPPORT_INFO, 0), NumPut(NV_HDMI_SUPPORT_INFO | 0x20000, pInfo, 0, "UInt")
        if !(NvStatus := DllCall(GetHDMISupportInfo, "Ptr", hNvDisplay, "UInt", outputId, "Ptr", &pInfo, "CDECL"))
        {
            HDMISI := {}
            HDMISI.version := NumGet(pInfo, 0, "UInt")
            bitfield := NumGet(pInfo, 4, "UInt")
            for NvCap, mask in NvCaps
                HDMISI[NvCap] := !!(bitfield & mask)
            HDMISI.EDID861ExtRev := NumGet(pInfo, 8, "UInt")
            return HDMISI
        }
        return NvAPI.GetErrorMessage(NvStatus)
    }

; ###############################################################################################################################

    GetHUEInfo(outputId := 0)
    {
        static GetHUEInfo := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0x95B64341, "CDECL UPtr")
        static NV_DISPLAY_HUE_INFO := 12
        hNvDisplay := NvAPI.EnumNvidiaDisplayHandle()
        VarSetCapacity(pHUEInfo, NV_DISPLAY_HUE_INFO), NumPut(NV_DISPLAY_HUE_INFO | 0x10000, pHUEInfo, 0, "UInt")
        if !(NvStatus := DllCall(GetHUEInfo, "Ptr", hNvDisplay, "UInt", outputId, "Ptr", &pHUEInfo, "CDECL"))
        {
            HUE := {}
            HUE.version         := NumGet(pHUEInfo, 0, "UInt")
            HUE.currentHueAngle := NumGet(pHUEInfo, 4, "UInt")
            HUE.defaultHueAngle := NumGet(pHUEInfo, 8, "UInt")
            return HUE
        }
        return NvAPI.GetErrorMessage(NvStatus)
    }

; ###############################################################################################################################

    GetInterfaceVersionString()
    {
        static GetInterfaceVersionString := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0x01053FA5, "CDECL UPtr")
        VarSetCapacity(szDesc, NvAPI.NVAPI_SHORT_STRING_MAX, 0)
        if !(NvStatus := DllCall(GetInterfaceVersionString, "Ptr", &szDesc, "CDECL"))
            return StrGet(&szDesc, "CP0")
        return NvAPI.GetErrorMessage(NvStatus)
    }

; ###############################################################################################################################

    GetUnAttachedAssociatedDisplayName()
    {
        static GetUnAttachedAssociatedDisplayName := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0x4888D790, "CDECL UPtr")
        hNvUnAttachedDisp := NvAPI.EnumNvidiaUnAttachedDisplayHandle()
        VarSetCapacity(szDisplayName, NvAPI.NVAPI_SHORT_STRING_MAX, 0)
        if !(NvStatus := DllCall(GetUnAttachedAssociatedDisplayName, "Int", hNvUnAttachedDisp, "Ptr", &szDisplayName, "CDECL"))
            return StrGet(&szDisplayName, "CP0")
        return NvAPI.GetErrorMessage(NvStatus)
    }

; ###############################################################################################################################

    GetVBlankCounter()
    {
        static GetVBlankCounter := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0x67B5DB55, "CDECL UPtr")
        hNvDisplay := NvAPI.EnumNvidiaDisplayHandle()
        if !(NvStatus := DllCall(GetVBlankCounter, "Ptr", hNvDisplay, "UInt*", pCounter))
            return pCounter
        return NvAPI.GetErrorMessage(NvStatus)
    }

; ###############################################################################################################################

    GPU_GetAGPAperture(hPhysicalGpu := 0)
    {
        static GPU_GetAGPAperture := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0x6E042794, "CDECL UPtr")
        if !(hPhysicalGpu)
            hPhysicalGpu := NvAPI.EnumPhysicalGPUs()[1]
        if !(NvStatus := DllCall(GPU_GetAGPAperture, "Ptr", hPhysicalGpu, "UInt*", pSize))
            return pSize
        return NvAPI.GetErrorMessage(NvStatus)
    }

; ###############################################################################################################################

    GPU_GetAllClockFrequencies(hPhysicalGPU := 0, ClockType := 0)
    {
        static GPU_GetAllClockFrequencies := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0xDCB616C3, "CDECL UPtr")
        static NVAPI_MAX_GPU_PUBLIC_CLOCKS := 32
        static NV_GPU_CLOCK_FREQUENCIES := 8 + (8 * NVAPI_MAX_GPU_PUBLIC_CLOCKS)
        static NV_GPU_PUBLIC_CLOCK_ID := {0: "GRAPHICS", 4: "MEMORY", 7: "PROCESSOR"}
        static NV_GPU_CLOCK_FREQUENCIES_CLOCK_TYPE := {0: "CURRENT_FREQ", 1: "BASE_CLOCK", 2: "BOOST_CLOCK", 3: "CLOCK_TYPE_NUM"}
        if !(hPhysicalGPU)
            hPhysicalGPU := NvAPI.EnumPhysicalGPUs()[1]
        if !(NV_GPU_CLOCK_FREQUENCIES_CLOCK_TYPE.HasKey(ClockType))
            ClockType := 0
        VarSetCapacity(pClkFreqs, NV_GPU_CLOCK_FREQUENCIES, 0), NumPut(NV_GPU_CLOCK_FREQUENCIES | 0x20000, pClkFreqs, 0, "UInt")
        NumPut(ClockType, pClkFreqs, 4, "UInt")
        if !(NvStatus := DllCall(GPU_GetAllClockFrequencies, "Ptr", hPhysicalGPU, "Ptr", &pClkFreqs, "CDECL"))
        {
            CF := {}
			CF.version := NumGet(pClkFreqs, 0, "UInt")
            CF.Type := NV_GPU_CLOCK_FREQUENCIES_CLOCK_TYPE[ClockType]
            for Index, Domain in NV_GPU_PUBLIC_CLOCK_ID
            {
                Offset := 8 + (8 * Index)
                CF[Domain, "bIsPresent"] := NumGet(pClkFreqs, Offset, "UInt") & 1
                CF[Domain, "frequency"]  := NumGet(pClkFreqs, Offset + 4, "UInt")
            }
            return CF
        }
        return NvAPI.GetErrorMessage(NvStatus)
    }

; ###############################################################################################################################

    GPU_GetBoardInfo(hPhysicalGpu := 0)
    {
        static GPU_GetBoardInfo := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0x22D54523, "CDECL UPtr")
        static NV_BOARD_INFO := 20
        if !(hPhysicalGpu)
            hPhysicalGpu := NvAPI.EnumPhysicalGPUs()[1]
        VarSetCapacity(pBoardInfo, NV_BOARD_INFO, 0), NumPut(NV_BOARD_INFO | 0x10000, pBoardInfo, 0, "UInt")
        if !(NvStatus := DllCall(GPU_GetBoardInfo, "Ptr", hPhysicalGpu, "Ptr" &pBoardInfo, "CDECL"))
            return  NumGet(pBoardInfo, 4, "UChar")
        return NvAPI.GetErrorMessage(NvStatus)
    }

; ###############################################################################################################################

    GPU_GetBusId(hPhysicalGpu := 0)
    {
        static GPU_GetBusId := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0x1BE0B8E5, "CDECL UPtr")
        if !(hPhysicalGpu)
            hPhysicalGpu := NvAPI.EnumPhysicalGPUs()[1]
        if !(NvStatus := DllCall(GPU_GetBusId, "Ptr", hPhysicalGpu, "UInt*", pBusId))
            return pBusId
        return NvAPI.GetErrorMessage(NvStatus)
    }

; ###############################################################################################################################

    GPU_GetBusSlotId(hPhysicalGpu := 0)
    {
        static GPU_GetBusSlotId := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0x2A0A350F, "CDECL UPtr")
        if !(hPhysicalGpu)
            hPhysicalGpu := NvAPI.EnumPhysicalGPUs()[1]
        if !(NvStatus := DllCall(GPU_GetBusSlotId, "Ptr", hPhysicalGpu, "UInt*", pBusSlotId))
            return pBusSlotId
        return NvAPI.GetErrorMessage(NvStatus)
    }

; ###############################################################################################################################

    GPU_GetBusType(hPhysicalGpu := 0)
    {
        static GPU_GetBusType := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0x1BB18724, "CDECL UPtr")
        static NV_GPU_BUS_TYPE := {0: "UNDEFINED", 1: "PCI", 2: "AGP", 3: "PCI_EXPRESS", 4: "FPCI", 5: "AXI"}
        if !(hPhysicalGpu)
            hPhysicalGpu := NvAPI.EnumPhysicalGPUs()[1]
        if !(NvStatus := DllCall(GPU_GetBusType, "Ptr", hPhysicalGpu, "Int*", pBusType, "CDECL"))
            return NV_GPU_BUS_TYPE[pBusType]
        return NvAPI.GetErrorMessage(NvStatus)
    }

; ###############################################################################################################################

    GPU_GetCoolerSettings(hPhysicalGpu := 0)
    {
        static GPU_GetCoolerSettings := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0xDA141340, "CDECL UPtr")
        static NVAPI_MAX_COOLERS_PER_GPU := 20
        static NV_GPU_GETCOOLER_SETTINGS := 8 + (64 * NVAPI_MAX_COOLERS_PER_GPU)
        static NV_COOLER_TYPE := {0: "NONE", 1: "FAN", 2: "WATER", 3: "LIQUID_NO2"}
        static NV_COOLER_CONTROLLER := {0: "NONE", 1: "ADI", 2: "INTERNAL"}
        static NV_COOLER_POLICY := {0: "NONE", 1: "MANUAL", 2: "PERF", 4: "DISCRETE", 8: "CONTINUOUS_HW", 16: "CONTINUOUS_SW", 32: "DEFAULT"}
        static NV_COOLER_TARGET := {0: "NONE", 1: "GPU", 2: "MEMORY", 4: "POWER_SUPPLY", 7: "ALL"}
        static NV_COOLER_CONTROL := {0: "NONE", 1: "TOGGLE", 2: "VARIABLE"}
        if !(hPhysicalGpu)
            hPhysicalGpu := NvAPI.EnumPhysicalGPUs()[1]
        VarSetCapacity(pCoolerInfo, NV_GPU_GETCOOLER_SETTINGS, 0), NumPut(NV_GPU_GETCOOLER_SETTINGS | 0x30000, pCoolerInfo, 0, "UInt")
        if !(NvStatus := DllCall(GPU_GetCoolerSettings, "Ptr", hPhysicalGpu, "UInt", 7, "Ptr", &pCoolerInfo, "CDECL"))
        {
            CI := {}
            CI.version := NumGet(pCoolerInfo, 0, "UInt")
            CI.count   := NumGet(pCoolerInfo, 4, "UInt")
            Offset := 8
            loop % CI.count
            {
                CI[A_Index, "type"]            := (T := NV_COOLER_TYPE[NumGet(pCoolerInfo, Offset, "UInt")]) ? T : "UNKNOWN"
                CI[A_Index, "controller"]      := (C := NV_COOLER_CONTROLLER[NumGet(pCoolerInfo, Offset + 4, "UInt")]) ? C : "UNKNOWN"
                CI[A_Index, "defaultMinLevel"] := NumGet(pCoolerInfo, Offset + 8, "UInt")
                CI[A_Index, "defaultMaxLevel"] := NumGet(pCoolerInfo, Offset + 12, "UInt")
                CI[A_Index, "currentMinLevel"] := NumGet(pCoolerInfo, Offset + 16, "UInt")
                CI[A_Index, "currentMaxLevel"] := NumGet(pCoolerInfo, Offset + 20, "UInt")
                CI[A_Index, "currentLevel"]    := NumGet(pCoolerInfo, Offset + 24, "UInt")
                CI[A_Index, "defaultPolicy"]   := (P := NV_COOLER_POLICY[NumGet(pCoolerInfo, Offset + 28, "UInt")]) ? P : "UNKNOWN"
                CI[A_Index, "currentPolicy"]   := (P := NV_COOLER_POLICY[NumGet(pCoolerInfo, Offset + 32, "UInt")]) ? P : "UNKNOWN"
                CI[A_Index, "target"]          := (T := NV_COOLER_TARGET[NumGet(pCoolerInfo, Offset + 36, "UInt")]) ? T : "UNKNOWN"
                CI[A_Index, "controlType"]     := (C := NV_COOLER_CONTROL[NumGet(pCoolerInfo, Offset + 40, "UInt")]) ? C : "UNKNOWN"
                CI[A_Index, "active"]          := NumGet(pCoolerInfo, Offset + 44, "UInt")
                CI[A_Index, "speedRPM"]        := NumGet(pCoolerInfo, Offset + 48, "UInt")
                CI[A_Index, "bSupported"]      := NumGet(pCoolerInfo, Offset + 52, "UChar")
                CI[A_Index, "maxSpeedRPM"]     := NumGet(pCoolerInfo, Offset + 56, "UInt")
                CI[A_Index, "minSpeedRPM"]     := NumGet(pCoolerInfo, Offset + 60, "UInt")
                Offset += 64
            }
            return CI
        }
        return NvAPI.GetErrorMessage(NvStatus)
    }

; ###############################################################################################################################

    GPU_GetCurrentAGPRate(hPhysicalGpu := 0)
    {
        static GPU_GetCurrentAGPRate := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0xC74925A0, "CDECL UPtr")
        if !(hPhysicalGpu)
            hPhysicalGpu := NvAPI.EnumPhysicalGPUs()[1]
        if !(NvStatus := DllCall(GPU_GetCurrentAGPRate, "Ptr", hPhysicalGpu, "UInt*", pRate))
            return pRate
        return NvAPI.GetErrorMessage(NvStatus)
    }

; ###############################################################################################################################

    GPU_GetCurrentPCIEDownstreamWidth(hPhysicalGpu := 0)
    {
        static GPU_GetCurrentPCIEDownstreamWidth := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0xD048C3B1, "CDECL UPtr")
        if !(hPhysicalGpu)
            hPhysicalGpu := NvAPI.EnumPhysicalGPUs()[1]
        if !(NvStatus := DllCall(GPU_GetCurrentPCIEDownstreamWidth, "Ptr", hPhysicalGpu, "UInt*", pWidth))
            return pWidth
        return NvAPI.GetErrorMessage(NvStatus)
    }

; ###############################################################################################################################

    GPU_GetCurrentPstate(hPhysicalGpu := 0)
    {
        static GPU_GetCurrentPstate := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0x927DA4F6, "CDECL UPtr")
        if !(hPhysicalGpu)
            hPhysicalGpu := NvAPI.EnumPhysicalGPUs()[1]
        if !(NvStatus := DllCall(GPU_GetCurrentPstate, "Ptr", hPhysicalGpu, "Int*", pCurrentPstate, "CDECL"))
            return pCurrentPstate
        return NvAPI.GetErrorMessage(NvStatus)
    }
	
; ###############################################################################################################################
	HtmlBox(HTML, Title="HTML - Debug Window", Body=True, Full=True, URL=False, width=960, height=540)
	{ ; Creates a MsgBox style GUI that has embedded HTML
		global MsgBoxOK, MsgBoxActiveX, MsgBoxFull=Full

		; Set up the GUI
		Gui, +HwndDefault
		Gui, MsgBox:New, +HwndMsgBox +Resize +MinSize +LabelMsgBox 
		if Full
			Gui, Margin, 0, 0
		else
			Gui, Margin, 10, 10
		
		; Embed IE
		Gui, Add, ActiveX, w%width% h%height% vMsgBoxActiveX, Shell.Explorer
		
		; If the HTML is actually a URL
		if URL
		{
			MsgBoxActiveX.Navigate(HTML)
			while MsgBoxActiveX.ReadyState < 3
				Sleep, 50
		}
		else
		{
			MsgBoxActiveX.Navigate("about:blank")
			while MsgBoxActiveX.ReadyState < 3
				Sleep, 50
			if Body
				HTML = 
				(
					<!DOCTYPE HTML>
					<html>
						<head>
							<style></style>
						</head>
						<body>
							<pre>
							%HTML%
							</pre>
						</body>
					</html>
				)
			MsgBoxActiveX.Document.Write(HTML)
		}
		
		; Add OK button
		if !Full
			Gui, Add, Button, % "x" width/2+50 " w80 h20 vMsgBoxOK gMsgBoxClose", OK
		
		; Show and reset default GUI
		Gui, Show,, %Title%
		Gui, %Default%:Default
		
		; Wait for window to close
		WinWaitActive, ahk_id %MsgBox%
		WinWaitClose, ahk_id %MsgBox%
		return
		
		MsgBoxEscape:
		MsgBoxClose:
		Gui, Destroy
		return
		
		MsgBoxSize:
		if !(A_GuiWidth || A_GuiHeight) ; Minimized
			return
		if MsgBoxFull
			GuiControl, Move, MsgBoxActiveX, % "w" A_GuiWidth "h" A_GuiHeight
		else
		{
			GuiControl, Move, MsgBoxActiveX, % "w" A_GuiWidth - 20 "h" A_GuiHeight - 50
			GuiControl, MoveDraw, MsgBoxOK, % "x" A_GuiWidth / 2 - 40 "y" A_GuiHeight - 30
		}
		return
	}
	
	GPU_SetPstates20(hPhysicalGpu := 0) {
		static GPU_SetPstates20 := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0x0F4DAE6B, "CDECL UPtr")
      	static NV_GPU_PERF_PSTATES20_INFO_V1 := 0x1C94
				
		if !(hPhysicalGpu)
          hPhysicalGpu := NvAPI.EnumPhysicalGPUs()[1]
		  
		
		  
	}
	
	GPU_GetPstates20(hPhysicalGpu := 0) {
		static GPU_GetPstates20 := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0x6FF81213, "CDECL UPtr")
      	static NV_GPU_PERF_PSTATES20_INFO_V1 := 0x1C94
				
		if !(hPhysicalGpu)
          hPhysicalGpu := NvAPI.EnumPhysicalGPUs()[1]
		  
		VarSetCapacity(pPstatesInfo, NV_GPU_PERF_PSTATES20_INFO_V1, 0)
		NumPut(NV_GPU_PERF_PSTATES20_INFO_V1 | 0x10000, pPstatesInfo, 0, "UInt")
		if !(NvStatus := DllCall(GPU_GetPstates20, "Ptr", hPhysicalGpu, "Ptr", &pPstatesInfo, "CDECL")) {
			PSTATES := {}
			
			PSTATES.version := NumGet(pPstatesInfo, 0, "UInt")
			PSTATES.bIsEditable := NumGet(pPstatesInfo, 4, "UInt")
			PSTATES.numPstates := NumGet(pPstatesInfo, 8, "UInt")
			PSTATES.numClocks := NumGet(pPstatesInfo, 12, "UInt")
			PSTATES.numBaseVoltages := NumGet(pPstatesInfo, 16, "UInt")
			
			pstates_length := PSTATES.numPstates
			clocks_length := PSTATES.numClocks
			baseVoltages_length := PSTATES.numBaseVoltages
						
			Offset := 20
						
			PSTATES["pstates"] := {}
			Loop % pstates_length {
				pstate_index := A_Index - 1
				
				PSTATES["pstates"][pstate_index] := {}
				PSTATES["pstates"][pstate_index].clocks := {}
				PSTATES["pstates"][pstate_index].baseVoltages := {}
					
				Offset := Offset + pstate_index * 4
						
				PSTATES["pstates"][pstate_index].pstateId 	 := NumGet(pPstatesInfo, Offset + 0, "UInt")
				PSTATES["pstates"][pstate_index].bIsEditable := NumGet(pPstatesInfo, Offset + 4, "UInt")

				Offset := Offset + 4

				Loop % clocks_length {
					clock_index := A_Index - 1

					PSTATES["pstates"][pstate_index].clocks[clock_index] := {}

					Offset := Offset + pstate_index * 4 + clock_index * 4
					PSTATES["pstates"][pstate_index].clocks[clock_index].domainId := NumGet(pPstatesInfo, Offset + 0, "UInt")
					PSTATES["pstates"][pstate_index].clocks[clock_index].typeId := NumGet(pPstatesInfo, Offset + 4, "UInt")
					PSTATES["pstates"][pstate_index].clocks[clock_index].bIsEditable := NumGet(pPstatesInfo, Offset + 8, "UInt")
					
					Offset := Offset + 16
					PSTATES["pstates"][pstate_index].clocks[clock_index].freqDelta_kHz := {}
					PSTATES["pstates"][pstate_index].clocks[clock_index].freqDelta_kHz.value := NumGet(pPstatesInfo, Offset + 0, "UInt")
					PSTATES["pstates"][pstate_index].clocks[clock_index].freqDelta_kHz.mindelta := NumGet(pPstatesInfo, Offset + 4, "UInt")
					PSTATES["pstates"][pstate_index].clocks[clock_index].freqDelta_kHz.maxdelta := NumGet(pPstatesInfo, Offset + 8, "UInt")	
					
					Offset := Offset + 16
					PSTATES["pstates"][pstate_index].clocks[clock_index].freq_kHz := NumGet(pPstatesInfo, Offset + 0, "UInt")	
					PSTATES["pstates"][pstate_index].clocks[clock_index].minFreq_kHz := NumGet(pPstatesInfo, Offset + 4, "UInt")	
					PSTATES["pstates"][pstate_index].clocks[clock_index].maxFreq_kHz := NumGet(pPstatesInfo, Offset + 8, "UInt")	
					PSTATES["pstates"][pstate_index].clocks[clock_index].domainId2 := NumGet(pPstatesInfo, Offset + 12, "UInt")	
					PSTATES["pstates"][pstate_index].clocks[clock_index].minVoltage_uV := NumGet(pPstatesInfo, Offset + 16, "UInt")	
					PSTATES["pstates"][pstate_index].clocks[clock_index].maxVoltage_uV := NumGet(pPstatesInfo, Offset + 20, "UInt")	
				}
				
				Offset := Offset + 24
				
				Loop % baseVoltages_length {
					voltage_index := A_Index - 1
					
					PSTATES["pstates"][pstate_index].baseVoltages[voltage_index] := {}
					
					Offset := Offset + voltage_index * 4
					
					PSTATES["pstates"][pstate_index].baseVoltages[voltage_index].domainId := NumGet(pPstatesInfo, Offset + 0, "UInt")
					PSTATES["pstates"][pstate_index].baseVoltages[voltage_index].bIsEditable := NumGet(pPstatesInfo, Offset + 4, "UInt")
					PSTATES["pstates"][pstate_index].baseVoltages[voltage_index].volt_uV := NumGet(pPstatesInfo, Offset + 8, "UInt")
					PSTATES["pstates"][pstate_index].baseVoltages[voltage_index].voltDelta_uV := NumGet(pPstatesInfo, Offset + 12, "UInt")
				}
				
				Offset := Offset + 16
			}
			return PSTATES
		}
		return NvAPI.GetErrorMessage(NvStatus)
	}

;	GPU_SetMemClock(hPhysicalGpu := 0, clock := 0) {
;       static GPU_SetCurrentPstate := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0x0F4DAE6B, "CDECL UPtr")
;       if !(hPhysicalGpu)
;           hPhysicalGpu := NvAPI.EnumPhysicalGPUs()[1]
;		
;		deltaKHz := clock * 1000
;		
;		
;       ; if !(NvStatus := DllCall(GPU_SetCurrentPstate, "Ptr", hPhysicalGpu, "Int*", pState, "CDECL"))
;           ; return pCurrentPstate
;       return NvAPI.GetErrorMessage(NvStatus)
;   }
; ###############################################################################################################################

    GPU_GetDynamicPstatesInfoEx(hPhysicalGpu := 0)
    {
        static GPU_GetDynamicPstatesInfoEx := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0x60DED2ED, "CDECL UPtr")
        static NVAPI_MAX_GPU_UTILIZATIONS := 8
        static NV_GPU_UTILIZATION_DOMAIN_ID := ["GPU", "FB", "VID", "BUS"]
        static NV_GPU_DYNAMIC_PSTATES_INFO_EX := 8 + (8 * NVAPI_MAX_GPU_UTILIZATIONS)
        if !(hPhysicalGpu)
            hPhysicalGpu := NvAPI.EnumPhysicalGPUs()[1]
        VarSetCapacity(pDynamicPstatesInfoEx, NV_GPU_DYNAMIC_PSTATES_INFO_EX, 0), NumPut(NV_GPU_DYNAMIC_PSTATES_INFO_EX | 0x10000, pDynamicPstatesInfoEx, 0, "UInt")
        if !(NvStatus := DllCall(GPU_GetDynamicPstatesInfoEx, "Ptr", hPhysicalGpu, "Ptr", &pDynamicPstatesInfoEx, "CDECL"))
        {
            PSTATES := {}
			PSTATES.version := NumGet(pDynamicPstatesInfoEx, 0, "UInt")
            PSTATES.Enabled := NumGet(pDynamicPstatesInfoEx, 4, "UInt") & 0x1
            OffSet := 8
            for Index, Domain in NV_GPU_UTILIZATION_DOMAIN_ID
            {
                PSTATES[Domain, "bIsPresent"] := NumGet(pDynamicPstatesInfoEx, Offset, "UInt") & 0x1
                PSTATES[Domain, "percentage"] := NumGet(pDynamicPstatesInfoEx, Offset + 4, "UInt")
                Offset += 8
            }
            return PSTATES
        }
        return NvAPI.GetErrorMessage(NvStatus)
    }

; ###############################################################################################################################

    GPU_GetFullName(hPhysicalGpu := 0)
    {
        static GPU_GetFullName := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0xCEEE8E9F, "CDECL UPtr")
        if !(hPhysicalGpu)
            hPhysicalGpu := NvAPI.EnumPhysicalGPUs()[1]
        VarSetCapacity(szName, NvAPI.NVAPI_SHORT_STRING_MAX, 0)
        if !(NvStatus := DllCall(GPU_GetFullName, "Ptr", hPhysicalGpu, "Ptr", &szName, "CDECL"))
            return StrGet(&szName, "CP0")
        return NvAPI.GetErrorMessage(NvStatus)
    }

; ###############################################################################################################################

    GPU_GetGpuCoreCount(hPhysicalGpu := 0)
    {
        static GPU_GetGpuCoreCount := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0xC7026A87, "CDECL UPtr")
        if !(hPhysicalGpu)
            hPhysicalGpu := NvAPI.EnumPhysicalGPUs()[1]
        if !(NvStatus := DllCall(GPU_GetGpuCoreCount, "Ptr", hPhysicalGpu, "UInt*", pCount))
            return pCount
        return NvAPI.GetErrorMessage(NvStatus)
    }

; ###############################################################################################################################

    GPU_GetGPUType(hPhysicalGpu := 0)
    {
        static GPU_GetGPUType := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0xC33BAEB1, "CDECL UPtr")
        static NV_GPU_TYPE := {0: "GPU_UNKNOWN", 1: "IGPU", 2: "DGPU"}
        if !(hPhysicalGpu)
            hPhysicalGpu := NvAPI.EnumPhysicalGPUs()[1]
        if !(NvStatus := DllCall(GPU_GetGPUType, "Ptr", hPhysicalGpu, "Int*", pGpuType, "CDECL"))
            return NV_GPU_TYPE[pGpuType]
        return NvAPI.GetErrorMessage(NvStatus)
    }

; ###############################################################################################################################

    GPU_GetHDCPSupportStatus(hPhysicalGpu := 0)
    {
        static GPU_GetHDCPSupportStatus := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0xF089EEF5, "CDECL UPtr")
        static NV_GPU_GET_HDCP_SUPPORT_STATUS := 16
        static NV_GPU_HDCP_FUSE_STATE := {0: "UNKNOWN", 1: "DISABLED", 2: "ENABLED"}
        static NV_GPU_HDCP_KEY_SOURCE := {0: "UNKNOWN", 1: "NONE", 2: "CRYPTO_ROM", 3: "SBIOS", 4: "I2C_ROM", 5: "FUSES"}
        static NV_GPU_HDCP_KEY_SOURCE_STATE := {0: "UNKNOWN", 1: "ABSENT", 2: "PRESENT"}
        if !(hPhysicalGpu)
            hPhysicalGpu := NvAPI.EnumPhysicalGPUs()[1]
        VarSetCapacity(pGetHDCPSupportStatus, NV_GPU_GET_HDCP_SUPPORT_STATUS, 0), NumPut(NV_GPU_GET_HDCP_SUPPORT_STATUS | 0x10000, pGetHDCPSupportStatus, 0, "UInt")
        if !(NvStatus := DllCall(GPU_GetHDCPSupportStatus, "Ptr", hPhysicalGpu, "Ptr", &pGetHDCPSupportStatus, "CDECL"))
        {
            HDCPSS := {}
            HDCPSS.version            := NumGet(pGetHDCPSupportStatus,  0, "UInt")
            HDCPSS.hdcpFuseState      := NV_GPU_HDCP_FUSE_STATE[NumGet(pGetHDCPSupportStatus,  4, "UInt")]
            HDCPSS.hdcpKeySource      := NV_GPU_HDCP_KEY_SOURCE[NumGet(pGetHDCPSupportStatus,  8, "UInt")]
            HDCPSS.hdcpKeySourceState := NV_GPU_HDCP_KEY_SOURCE_STATE[NumGet(pGetHDCPSupportStatus, 12, "UInt")]
            return HDCPSS
        }
        return NvAPI.GetErrorMessage(NvStatus)
    }

; ###############################################################################################################################

    GPU_GetIRQ(hPhysicalGpu := 0)
    {
        static GPU_GetIRQ := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0xE4715417, "CDECL UPtr")
        if !(hPhysicalGpu)
            hPhysicalGpu := NvAPI.EnumPhysicalGPUs()[1]
        if !(NvStatus := DllCall(GPU_GetIRQ, "Ptr", hPhysicalGpu, "UInt*", pIRQ))
            return pIRQ
        return NvAPI.GetErrorMessage(NvStatus)
    }

; ###############################################################################################################################

    GPU_GetMemoryInfo(hPhysicalGpu := 0)
    {
        static GPU_GetMemoryInfo := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0x07F9B368, "CDECL UPtr")
        static NV_DISPLAY_DRIVER_MEMORY_INFO := 24
        if !(hPhysicalGpu)
            hPhysicalGpu := NvAPI.EnumPhysicalGPUs()[1]
        VarSetCapacity(pMemoryInfo, NV_DISPLAY_DRIVER_MEMORY_INFO, 0), NumPut(NV_DISPLAY_DRIVER_MEMORY_INFO | 0x20000, pMemoryInfo, 0, "UInt")
        if !(NvStatus := DllCall(GPU_GetMemoryInfo, "Ptr", hPhysicalGpu, "Ptr", &pMemoryInfo, "CDECL"))
        {
            MI := {}
            MI.version                          := NumGet(pMemoryInfo,  0, "UInt")
            MI.dedicatedVideoMemory             := NumGet(pMemoryInfo,  4, "UInt")
            MI.availableDedicatedVideoMemory    := NumGet(pMemoryInfo,  8, "UInt")
            MI.systemVideoMemory                := NumGet(pMemoryInfo, 12, "UInt")
            MI.sharedSystemMemory               := NumGet(pMemoryInfo, 16, "UInt")
            MI.curAvailableDedicatedVideoMemory := NumGet(pMemoryInfo, 20, "UInt")
            return MI
        }
        return NvAPI.GetErrorMessage(NvStatus)
    }

; ###############################################################################################################################

    GPU_GetOutputType(outputId := 0, hPhysicalGpu := 0)
    {
        static GPU_GetOutputType := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0x40A505E4, "CDECL UPtr")
        static NV_GPU_OUTPUT_TYPE := {0: "UNKNOWN", 1: "CRT", 2: "DFP", 3: "TV"}
        if !(hPhysicalGpu)
            hPhysicalGpu := NvAPI.EnumPhysicalGPUs()[1]
        if !(NvStatus := DllCall(GPU_GetOutputType, "Ptr", hPhysicalGpu, "UInt", outputId, "Int*", pOutputType, "CDECL"))
            return NV_GPU_OUTPUT_TYPE[pOutputType]
        return NvAPI.GetErrorMessage(NvStatus)
    }

; ###############################################################################################################################

    GPU_GetPerfDecreaseInfo(hPhysicalGpu := 0)
    {
        static GPU_GetPerfDecreaseInfo := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0x7F7F4600, "CDECL UPtr")
        static NVAPI_GPU_PERF_DECREASE := {0: "NONE", 1: "REASON_THERMAL_PROTECTION", 2: "REASON_POWER_CONTROL", 4: "REASON_AC_BATT"
                                          ,8: "REASON_API_TRIGGERED", 16: "REASON_INSUFFICIENT_POWER", 2147483648: "REASON_UNKNOWN"}
        if !(hPhysicalGpu)
            hPhysicalGpu := NvAPI.EnumPhysicalGPUs()[1]
        if !(NvStatus := DllCall(GPU_GetPerfDecreaseInfo, "Ptr", hPhysicalGpu, "UInt*", pPerfDecrInfo, "CDECL"))
            return NVAPI_GPU_PERF_DECREASE[pPerfDecrInfo]
        return NvAPI.GetErrorMessage(NvStatus)
    }

; ###############################################################################################################################

    GPU_GetPhysicalFrameBufferSize(hPhysicalGPU := 0)
    {
        static GPU_GetPhysicalFrameBufferSize := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0x46FBEB03, "CDECL UPtr")
        if !(hPhysicalGPU)
            hPhysicalGpu := NvAPI.EnumPhysicalGPUs()[1]
        if !(NvStatus := DllCall(GPU_GetPhysicalFrameBufferSize, "Ptr", hPhysicalGpu, "UInt*", pSize))
            return pSize
        return NvAPI.GetErrorMessage(NvStatus)
    }

; ###############################################################################################################################

    GPU_GetSystemType(hPhysicalGpu := 0)
    {
        static GPU_GetSystemType := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0xBAAABFCC, "CDECL UPtr")
        static NV_SYSTEM_TYPE := {0: "UNKNOWN", 1: "LAPTOP", 2: "DESKTOP"}
        if !(hPhysicalGpu)
            hPhysicalGpu := NvAPI.EnumPhysicalGPUs()[1]
        if !(NvStatus := DllCall(GPU_GetSystemType, "Ptr", hPhysicalGpu, "Int*", pSystemType, "CDECL"))
            return NV_SYSTEM_TYPE[pSystemType]
        return NvAPI.GetErrorMessage(NvStatus)
    }

; ###############################################################################################################################

    GPU_GetTachReading(hPhysicalGPU := 0)
    {
        static GPU_GetTachReading := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0x5F608315, "CDECL UPtr")
        if !(hPhysicalGPU)
            hPhysicalGPU := NvAPI.EnumPhysicalGPUs()[1]
        if !(NvStatus := DllCall(GPU_GetTachReading, "Ptr", hPhysicalGPU, "UInt*", pValue, "CDECL"))
            return pValue
        return NvAPI.GetErrorMessage(NvStatus)
    }

; ###############################################################################################################################

    GPU_GetThermalSettings(hPhysicalGpu := 0)
    {
        static GPU_GetThermalSettings := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0xE3640A56, "CDECL UPtr")
        static NVAPI_MAX_THERMAL_SENSORS_PER_GPU := 3
        static NV_GPU_THERMAL_SETTINGS := 8 + (20 * NVAPI_MAX_THERMAL_SENSORS_PER_GPU)
        static NV_THERMAL_CONTROLLER := {-1: "UNKNOWN", 0: "NONE", 1: "GPU_INTERNAL", 2: "ADM1032", 3: "MAX6649"
                                        , 4: "MAX1617", 5: "LM99", 6: "LM89", 7: "LM64", 8: "ADT7473", 9: "SBMAX6649"
                                        ,10: "VBIOSEVT", 11: "OS"}
        static NV_THERMAL_TARGET := {-1: "UNKNOWN", 0: "NONE", 1: "GPU", 2: "MEMORY", 4: "POWERSUPPLY", 8: "BOARD"
                                    , 9: "VCD_BOARD", 10: "VCD_INLET", 11: "VCD_OUTLET", 15: "ALL"}
        if !(hPhysicalGpu)
            hPhysicalGpu := NvAPI.EnumPhysicalGPUs()[1]
        VarSetCapacity(pThermalSettings, NV_GPU_THERMAL_SETTINGS, 0), NumPut(NV_GPU_THERMAL_SETTINGS | 0x20000, pThermalSettings, 0, "UInt")
        if !(NvStatus := DllCall(GPU_GetThermalSettings, "Ptr", hPhysicalGpu, "UInt", 15, "Ptr", &pThermalSettings, "CDECL"))
        {
            TS := {}
            TS.version := NumGet(pThermalSettings, 0, "UInt")
            TS.count   := NumGet(pThermalSettings, 4, "UInt")
            OffSet := 8
            loop % NVAPI_MAX_THERMAL_SENSORS_PER_GPU
            {
                TS[A_Index, "controller"]     := (C := NV_THERMAL_CONTROLLER[NumGet(pThermalSettings, Offset, "UInt")]) ? C : "UNKNOWN"
                TS[A_Index, "defaultMinTemp"] := NumGet(pThermalSettings, Offset +  4, "Int")
                TS[A_Index, "defaultMaxTemp"] := NumGet(pThermalSettings, Offset +  8, "Int")
                TS[A_Index, "currentTemp"]    := NumGet(pThermalSettings, Offset + 12, "Int")
                TS[A_Index, "target"]         := (T := NV_THERMAL_TARGET[NumGet(pThermalSettings, Offset + 16, "UInt")]) ? T : "UNKNOWN"
                OffSet += 20
            }
            return TS
        }
        return NvAPI.GetErrorMessage(NvStatus)
    }

; ###############################################################################################################################

    GPU_GetUsages(hPhysicalGPU := 0)
    {
        static GPU_GetUsages := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0x189A1FDF, "CDECL UPtr")
        static MAX_USAGES_PER_GPU := 33
        static NV_USAGES := 4 + (MAX_USAGES_PER_GPU * 4)
        if !(hPhysicalGPU)
            hPhysicalGPU := NvAPI.EnumPhysicalGPUs()[1]
        VarSetCapacity(currentUsage, NV_USAGES, 0), NumPut(NV_USAGES | 0x10000, currentUsage, 0, "UInt")
        if !(NvStatus := DllCall(GPU_GetUsages, "Ptr", hPhysicalGPU, "Ptr", &currentUsage, "CDECL"))
            return NumGet(currentUsage, 12, "UInt")
        return NvAPI.GetErrorMessage(NvStatus)
    }

; ###############################################################################################################################

    GPU_GetVbiosOEMRevision(hPhysicalGpu := 0)
    {
        static GPU_GetVbiosOEMRevision := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0x2D43FB31, "CDECL UPtr")
        if !(hPhysicalGpu)
            hPhysicalGpu := NvAPI.EnumPhysicalGPUs()[1]
        if !(NvStatus := DllCall(GPU_GetVbiosOEMRevision, "Ptr", hPhysicalGpu, "UInt*", pBiosRevision))
            return pBiosRevision
        return NvAPI.GetErrorMessage(NvStatus)
    }

; ###############################################################################################################################

    GPU_GetVbiosRevision(hPhysicalGpu := 0)
    {
        static GPU_GetVbiosRevision := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0xACC3DA0A, "CDECL UPtr")
        if !(hPhysicalGpu)
            hPhysicalGpu := NvAPI.EnumPhysicalGPUs()[1]
        if !(NvStatus := DllCall(GPU_GetVbiosRevision, "Ptr", hPhysicalGpu, "UInt*", pBiosRevision))
            return pBiosRevision
        return NvAPI.GetErrorMessage(NvStatus)
    }

; ###############################################################################################################################

    GPU_GetVbiosVersionString(hPhysicalGpu := 0)
    {
        static GPU_GetVbiosVersionString := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0xA561FD7D, "CDECL UPtr")
        if !(hPhysicalGpu)
            hPhysicalGpu := NvAPI.EnumPhysicalGPUs()[1]
        VarSetCapacity(szBiosRevision, NvAPI.NVAPI_SHORT_STRING_MAX, 0)
        if !(NvStatus := DllCall(GPU_GetVbiosVersionString, "Ptr", hPhysicalGpu, "Ptr", &szBiosRevision, "CDECL"))
            return StrGet(&szBiosRevision, "CP0")
        return NvAPI.GetErrorMessage(NvStatus)
    }

; ###############################################################################################################################

    GPU_GetVirtualFrameBufferSize(hPhysicalGpu := 0)
    {
        static GPU_GetVirtualFrameBufferSize := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0x5A04B644, "CDECL UPtr")
        if !(hPhysicalGpu)
            hPhysicalGpu := NvAPI.EnumPhysicalGPUs()[1]
        if !(NvStatus := DllCall(GPU_GetVirtualFrameBufferSize, "Ptr", hPhysicalGpu, "UInt*", pSize))
            return pSize
        return NvAPI.GetErrorMessage(NvStatus)
    }

; ###############################################################################################################################

    GPU_SetCoolerLevels(currentLevel, currentPolicy := 1, hPhysicalGpu := 0)
    {
        static GPU_SetCoolerLevels := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0x891FA0AE, "CDECL UPtr")
        static NVAPI_MAX_COOLERS_PER_GPU := 20
        static NV_GPU_SETCOOLER_LEVEL    := 4 + (8 * NVAPI_MAX_COOLERS_PER_GPU)
        if !(hPhysicalGpu)
            hPhysicalGpu := NvAPI.EnumPhysicalGPUs()[1]
        VarSetCapacity(pCoolerLevels, NV_GPU_SETCOOLER_LEVEL, 0), NumPut(NV_GPU_SETCOOLER_LEVEL | 0x10000, pCoolerLevels, 0, "UInt")
        , NumPut(currentLevel, pCoolerLevels, 4, "UInt"), NumPut(currentPolicy, pCoolerLevels, 8, "UInt")
        if !(NvStatus := DllCall(GPU_SetCoolerLevels, "Ptr", hPhysicalGpu, "UInt", 7, "Ptr", &pCoolerLevels, "CDECL"))
            return True
        return NvAPI.GetErrorMessage(NvStatus)
    }

; ###############################################################################################################################

    SetDVCLevel(level, outputId := 0)
    {
        static SetDVCLevel := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0x172409B4, "CDECL UPtr")
        hNvDisplay := NvAPI.EnumNvidiaDisplayHandle()
        if !(NvStatus := DllCall(SetDVCLevel, "Ptr", hNvDisplay, "UInt", outputId, "UInt", level, "CDECL"))
            return level
        return NvAPI.GetErrorMessage(NvStatus)
    }

; ###############################################################################################################################

    SetDVCLevelEx(currentLevel, thisEnum := 0, outputId := 0)
    {
        static SetDVCLevelEx := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0x4A82C2B1, "CDECL UPtr")
        static NV_DISPLAY_DVC_INFO_EX := 20
        hNvDisplay := NvAPI.GetAssociatedNvidiaDisplayHandle(thisEnum)
        VarSetCapacity(pDVCInfo, NV_DISPLAY_DVC_INFO_EX)
        , NumPut(NvAPI.GetDVCInfoEx(thisEnum).version,      pDVCInfo,  0, "UInt")
        , NumPut(currentLevel,                              pDVCInfo,  4, "Int")
        , NumPut(NvAPI.GetDVCInfoEx(thisEnum).minLevel,     pDVCInfo,  8, "Int")
        , NumPut(NvAPI.GetDVCInfoEx(thisEnum).maxLevel,     pDVCInfo, 12, "Int")
        , NumPut(NvAPI.GetDVCInfoEx(thisEnum).defaultLevel, pDVCInfo, 16, "Int")
        return DllCall(SetDVCLevelEx, "Ptr", hNvDisplay, "UInt", outputId, "Ptr", &pDVCInfo, "CDECL")
    }

; ###############################################################################################################################

    SetHUEAngle(level, outputId := 0)
    {
        static SetHUEAngle := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0xF5A0F22C, "CDECL UPtr")
        hNvDisplay := NvAPI.EnumNvidiaDisplayHandle()
        if !(NvStatus := DllCall(SetHUEAngle, "Ptr", hNvDisplay, "UInt", outputId, "UInt", level, "CDECL"))
            return level
        return NvAPI.GetErrorMessage(NvStatus)
    }

; ###############################################################################################################################

    Stereo_IsEnabled()
    {
        static Stereo_IsEnabled := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0x348FF8E1, "CDECL UPtr")
        if !(NvStatus := DllCall(Stereo_IsEnabled, "UChar*", pIsStereoEnabled, "CDECL"))
            return pIsStereoEnabled
        return NvAPI.GetErrorMessage(NvStatus)
    }

; ###############################################################################################################################

    Stereo_IsWindowedModeSupported()
    {
        static Stereo_IsWindowedModeSupported := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0x40C8ED5E, "CDECL UPtr")
        if !(NvStatus := DllCall(Stereo_IsWindowedModeSupported, "UChar*", bSupported, "CDECL"))
            return bSupported
        return NvAPI.GetErrorMessage(NvStatus)
    }

; ###############################################################################################################################

    SYS_GetChipSetInfo()
    {
        static SYS_GetChipSetInfo := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0x53DABBCA, "CDECL UPtr")
        static NV_CHIPSET_INFO := 40 + (3 * NvAPI.NVAPI_SHORT_STRING_MAX)
        VarSetCapacity(pChipSetInfo, NV_CHIPSET_INFO, 0), NumPut(NV_CHIPSET_INFO | 0x40000, pChipSetInfo, 0, "UInt")
        if !(NvStatus := DllCall(SYS_GetChipSetInfo, "Ptr", &pChipSetInfo, "CDECL"))
        {
            CSI := {}
            CSI.version            := NumGet(pChipSetInfo,     0, "UInt")
            CSI.vendorId           := NumGet(pChipSetInfo,     4, "UInt")
            CSI.deviceId           := NumGet(pChipSetInfo,     8, "UInt")
            CSI.szVendorName       := StrGet(&pChipSetInfo +  12, NvAPI.NVAPI_SHORT_STRING_MAX, "CP0")
            CSI.szChipsetName      := StrGet(&pChipSetInfo +  76, NvAPI.NVAPI_SHORT_STRING_MAX, "CP0")
            CSI.flags              := NumGet(pChipSetInfo,   140, "UInt")
            CSI.subSysVendorId     := NumGet(pChipSetInfo,   144, "UInt")
            CSI.subSysDeviceId     := NumGet(pChipSetInfo,   148, "UInt")
            CSI.szSubSysVendorName := StrGet(&pChipSetInfo + 152, NvAPI.NVAPI_SHORT_STRING_MAX, "CP0")
            CSI.HBvendorId         := NumGet(pChipSetInfo,   216, "UInt")
            CSI.HBdeviceId         := NumGet(pChipSetInfo,   220, "UInt")
            CSI.HBsubSysVendorId   := NumGet(pChipSetInfo,   224, "UInt")
            CSI.HBsubSysDeviceId   := NumGet(pChipSetInfo,   228, "UInt")
            return CSI
        }
        return NvAPI.GetErrorMessage(NvStatus)
    }

; ###############################################################################################################################

    SYS_GetDriverAndBranchVersion()
    {
        static SYS_GetDriverAndBranchVersion := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0x2926AAAD, "CDECL UPtr")
        VarSetCapacity(szBuildBranchString, NvAPI.NVAPI_SHORT_STRING_MAX, 0)
        if !(NvStatus := DllCall(SYS_GetDriverAndBranchVersion, "UInt*", pDriverVersion, "Ptr", &szBuildBranchString, "CDECL"))
        {
            DB := {}
            DB.pDriverVersion       := pDriverVersion
            DB.szBuildBranchString  := StrGet(&szBuildBranchString, "CP0")
            return DB
        }
        return NvAPI.GetErrorMessage(NvStatus)
    }

; ###############################################################################################################################

    VIO_EnumDevices()
    {
        static VIO_EnumDevices := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0xFD7C5557, "CDECL UPtr")
        VarSetCapacity(hVioHandle, 4 * NvAPI.NVAPI_MAX_VIO_DEVICES, 0)
        if !(NvStatus := DllCall(VIO_EnumDevices, "Ptr", &hVioHandle, "UInt*", vioDeviceCount, "CDECL"))
        {
            VIOH := []
            loop % vioDeviceCount
                VIOH[A_Index] := NumGet(vioDeviceCount, 4 * (A_Index - 1), "Int")
            return VIOH
        }
        return NvAPI.GetErrorMessage(NvStatus)
    }

; ###############################################################################################################################

    VIO_GetCapabilities(hVioHandle := 0)
    {
        static VIO_GetCapabilities := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0x1DC91303, "CDECL UPtr")
        static NVVIOCAPS := 48 + NvAPI.NVAPI_GENERIC_STRING_MAX
        if !(hVioHandle)
            hVioHandle := NvAPI.VIO_EnumDevices()[1]
        VarSetCapacity(pAdapterCaps, NVVIOCAPS, 0), NumPut(NVVIOCAPS | 0x20000, pAdapterCaps, 0, "UInt")
        if !(NvStatus := DllCall(VIO_GetCapabilities, "Ptr", hVioHandle, "UInt*", pAdapterCaps, "CDECL"))
        {
            VIOGC := {}
            VIOGC.version              := NumGet(pAdapterCaps,    0, "UInt")
            VIOGC.adapterName          := StrGet(&pAdapterCaps +  4, NvAPI.NVAPI_GENERIC_STRING_MAX, "CP0")
            VIOGC.adapterClass         := NumGet(pAdapterCaps, 4100, "UInt")
            VIOGC.adapterCaps          := NumGet(pAdapterCaps, 4104, "UInt")
            VIOGC.dipSwitch            := NumGet(pAdapterCaps, 4108, "UInt")
            VIOGC.dipSwitchReserved    := NumGet(pAdapterCaps, 4112, "UInt")
            VIOGC.boardID              := NumGet(pAdapterCaps, 4116, "UInt")
            VIOGC.driverMajorVersion   := NumGet(pAdapterCaps, 4120, "UInt")
            VIOGC.driverMinorVersion   := NumGet(pAdapterCaps, 4124, "UInt")
            VIOGC.firmwareMajorVersion := NumGet(pAdapterCaps, 4128, "UInt")
            VIOGC.firmwareMinorVersion := NumGet(pAdapterCaps, 4132, "UInt")
            VIOGC.ownerId              := NumGet(pAdapterCaps, 4136, "UInt")
            VIOGC.ownerType            := NumGet(pAdapterCaps, 4140, "UInt")
            return VIOGC
        }
        return NvAPI.GetErrorMessage(NvStatus)
    }

; ###############################################################################################################################

    VIO_IsRunning(hVioHandle := 0)
    {
        static VIO_IsRunning := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0x96BD040E, "CDECL UPtr")
        if !(hVioHandle)
            hVioHandle := NvAPI.VIO_EnumDevices()[1]
        if !(NvStatus := DllCall(VIO_IsRunning, "Ptr", hVioHandle, "CDECL"))
            return hVioHandle
        return NvAPI.GetErrorMessage(NvStatus)
    }

; ###############################################################################################################################

    VIO_Start(hVioHandle := 0)
    {
        static VIO_Start := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0xCDE8E1A3, "CDECL UPtr")
        if !(hVioHandle)
            hVioHandle := NvAPI.VIO_EnumDevices()[1]
        if !(NvStatus := DllCall(VIO_Start, "Ptr", hVioHandle, "CDECL"))
            return hVioHandle
        return NvAPI.GetErrorMessage(NvStatus)
    }

; ###############################################################################################################################

    VIO_Stop(hVioHandle := 0)
    {
        static VIO_Stop := DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0x6BA2A5D6, "CDECL UPtr")
        if !(hVioHandle)
            hVioHandle := NvAPI.VIO_EnumDevices()[1]
        if !(NvStatus := DllCall(VIO_Stop, "Ptr", hVioHandle, "CDECL"))
            return hVioHandle
        return NvAPI.GetErrorMessage(NvStatus)
    }

; ###############################################################################################################################

    _Delete()
    {
        DllCall(DllCall(NvAPI.DllFile "\nvapi_QueryInterface", "UInt", 0xD22BDD7E, "CDECL UPtr"), "CDECL")
        DllCall("FreeLibrary", "Ptr", NvAPI.hmod)
    }
}
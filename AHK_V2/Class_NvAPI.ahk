; ===========================================================================================================================================================================

/*
	AutoHotkey wrapper for NVIDIA NvAPI

	Author ....: jNizM
	Released ..: 2014-12-29
	Modified ..: 2020-09-30
	License ...: MIT
	GitHub ....: https://github.com/jNizM/AHK_NVIDIA_NvAPI
	Forum .....: https://www.autohotkey.com/boards/viewtopic.php?t=95112
*/

; SCRIPT DIRECTIVES =========================================================================================================================================================

#Requires AutoHotkey v2.0-


; ===== NvAPI CORE FUNCTIONS ================================================================================================================================================

class NvAPI
{
	static NvDLL := (A_PtrSize = 8) ? "nvapi64.dll" : "nvapi.dll"
	static _Init := NvAPI.__Initialize()


	static __Initialize()
	{
		if !(this.hModule := DllCall("LoadLibrary", "Str", this.NvDLL, "Ptr"))
		{
			MsgBox("NvAPI could not be startet!`n`nThe program will exit!", A_ThisFunc)
			ExitApp
		}
		if (NvStatus := DllCall(DllCall(this.NvDLL "\nvapi_QueryInterface", "UInt", 0x0150E828, "CDecl UPtr"), "CDecl") != 0)
		{
			MsgBox("NvAPI initialization failed: [ " NvStatus " ]`n`nThe program will exit!", A_ThisFunc)
			ExitApp
		}
	}



	static __Delete()
	{
		DllCall(DllCall(this.NvDLL "\nvapi_QueryInterface", "UInt", 0xD22BDD7E, "CDecl UPtr"), "CDecl")
		if (this.hModule)
			DllCall("FreeLibrary", "Ptr", this.hModule)
	}



	static QueryInterface(NvID)
	{
		return DllCall(this.NvDLL "\nvapi_QueryInterface", "UInt", NvID, "CDecl UPtr")
	}



	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	; //
	; // FUNCTION NAME: NvAPI.EnumLogicalGPUs
	; //
	; // This function returns an array of logical GPU handles.
	; // Each handle represents one or more GPUs acting in concert as a single graphics device.
	; //
	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	static EnumLogicalGPUs()
	{
		NvLogicalGpuHandle := Buffer(4 * Const.NVAPI_MAX_LOGICAL_GPUS, 0)
		if !(NvStatus := DllCall(this.QueryInterface(0x48B3EA59), "Ptr", NvLogicalGpuHandle, "UInt*", &GPUCount := 0, "CDecl"))
		{
			Enum := []
			loop GPUCount
			{
				Enum.Push(NumGet(NvLogicalGpuHandle, 4 * (A_Index - 1), "UInt"))   ; [OUT] One or more physical GPUs acting in concert (SLI)
			}
			return Enum
		}

		return this.GetErrorMessage(NvStatus)
	}



	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	; //
	; // FUNCTION NAME: NvAPI.EnumNvidiaDisplayHandle
	; //
	; // This function returns the handle of the NVIDIA display specified by the enum index (thisEnum).
	; // The client should keep enumerating until it returns error.
	; //
	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	static EnumNvidiaDisplayHandle(thisEnum := 0)
	{
		if !(NvStatus := DllCall(this.QueryInterface(0x9ABDD40D), "UInt", thisEnum, "Ptr*", &NvDisplayHandle := 0, "CDecl"))
		{
			return NvDisplayHandle   ; [OUT] Display Device driven by NVIDIA GPU(s) (an attached display)
		}

		return this.GetErrorMessage(NvStatus)
	}



	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	; //
	; // FUNCTION NAME: NvAPI.EnumNvidiaUnAttachedDisplayHandle
	; //
	; // This function returns the handle of the NVIDIA unattached display specified by the enum index (thisEnum).
	; // The client should keep enumerating until it returns error.
	; //
	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	static EnumNvidiaUnAttachedDisplayHandle(thisEnum := 0)
	{
		if !(NvStatus := DllCall(this.QueryInterface(0x20DE9260), "UInt", thisEnum, "Ptr*", &NvUnAttachedDisplayHandle := 0, "CDecl"))
		{
			return NvUnAttachedDisplayHandle   ; [OUT] Unattached Display Device driven by NVIDIA GPU(s)
		}

		return this.GetErrorMessage(NvStatus)
	}



	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	; //
	; // FUNCTION NAME: NvAPI.EnumPhysicalGPUs
	; //
	; // This function returns an array of physical GPU handles.
	; // Each handle represents a physical GPU present in the system.
	; //
	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	static EnumPhysicalGPUs()
	{
		NvPhysicalGpuHandle := Buffer(4 * Const.NVAPI_MAX_PHYSICAL_GPUS, 0)
		if !(NvStatus := DllCall(this.QueryInterface(0xE5AC921F), "Ptr", NvPhysicalGpuHandle, "UInt*", &GPUCount := 0, "CDecl"))
		{
			Enum := []
			loop GPUCount
			{
				Enum.Push(NumGet(NvPhysicalGpuHandle, 4 * (A_Index - 1), "UInt"))   ; [OUT] A single physical GPU
			}
			return Enum
		}

		return this.GetErrorMessage(NvStatus)
	}



	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	; //
	; // FUNCTION NAME: NvAPI.EnumTCCPhysicalGPUs
	; //
	; // This function returns an array of physical GPU handles that are in TCC Mode.
	; // Each handle represents a physical GPU present in the system in TCC Mode.
	; //
	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	static EnumTCCPhysicalGPUs()
	{
		NvPhysicalGpuHandle := Buffer(4 * Const.NVAPI_MAX_PHYSICAL_GPUS, 0)
		if !(NvStatus := DllCall(this.QueryInterface(0xD9930B07), "Ptr", NvPhysicalGpuHandle, "UInt*", &GPUCount := 0, "CDecl"))
		{
			Enum := []
			loop GPUCount
			{
				Enum.Push(NumGet(NvPhysicalGpuHandle, 4 * (A_Index - 1), "UInt"))   ; [OUT] A single physical GPU
			}
			return Enum
		}

		return this.GetErrorMessage(NvStatus)
	}



	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	; //
	; // FUNCTION NAME: NvAPI.GetDisplayDriverMemoryInfo
	; //
	; // This function retrieves the display driver memory information for the active display handle.
	; // In a multi-GPU scenario, the physical framebuffer information is obtained for the GPU associated with active display handle.
	; // In an SLI-mode scenario, the physical framebuffer information is obtained only from the display owner GPU.
	; //
	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	static GetDisplayDriverMemoryInfo(thisEnum := 0)
	{
		static NV_DISPLAY_DRIVER_MEMORY_INFO := (6 * 4)

		hNvDisplay := this.EnumNvidiaDisplayHandle(thisEnum)
		MemoryInfo := Buffer(NV_DISPLAY_DRIVER_MEMORY_INFO, 0)
		NumPut("UInt", NV_DISPLAY_DRIVER_MEMORY_INFO | 0x20000, MemoryInfo, 0)             ; [IN] version info
		if !(NvStatus := DllCall(this.QueryInterface(0x774AA982), "Ptr", hNvDisplay, "Ptr", MemoryInfo, "CDecl"))
		{
			DRIVER_MEMORY_INFO := Map()
			DRIVER_MEMORY_INFO["dedicatedVideoMemory"]             := NumGet(MemoryInfo,  4, "UInt")   ; [OUT] physical framebuffer (in kb)
			DRIVER_MEMORY_INFO["availableDedicatedVideoMemory"]    := NumGet(MemoryInfo,  8, "UInt")   ; [OUT] available physical framebuffer for allocating video memory surfaces (in kb)
			DRIVER_MEMORY_INFO["systemVideoMemory"]                := NumGet(MemoryInfo, 12, "UInt")   ; [OUT] system memory the driver allocates at load time (in kb)
			DRIVER_MEMORY_INFO["sharedSystemMemory"]               := NumGet(MemoryInfo, 12, "UInt")   ; [OUT] shared system memory that driver is allowed to commit for surfaces across all allocations (in kb)
			DRIVER_MEMORY_INFO["curAvailableDedicatedVideoMemory"] := NumGet(MemoryInfo, 12, "UInt")   ; [OUT] current available physical framebuffer for allocating video memory surfaces (in kb)
			return DRIVER_MEMORY_INFO
		}

		return this.GetErrorMessage(NvStatus)
	}



	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	; //
	; // FUNCTION NAME: NvAPI.GetDisplayDriverVersion
	; //
	; // This function returns a struct that describes aspects of the display driver build.
	; // Do not use this function - it is deprecated in release 290. Instead, use NvAPI_SYS_GetDriverAndBranchVersion.
	; //
	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	static GetDisplayDriverVersion(thisEnum := 0)
	{
		static NV_DISPLAY_DRIVER_VERSION := (3 * 4) + (2 * Const.NVAPI_SHORT_STRING_MAX)

		hNvDisplay := this.EnumNvidiaDisplayHandle(thisEnum)
		Version := Buffer(NV_DISPLAY_DRIVER_VERSION, 0)
		NumPut("UInt", NV_DISPLAY_DRIVER_VERSION | 0x10000, Version, 0)                                            ; [IN] version info
		if !(NvStatus := DllCall(this.QueryInterface(0xF951A4D1), "Ptr", hNvDisplay, "Ptr", Version, "CDecl"))
		{
			DRIVER_VERSION := Map()
			DRIVER_VERSION["drvVersion"]        := NumGet(Version, 4, "UInt")                                      ; [OUT] 
			DRIVER_VERSION["bldChangeListNum"]  := NumGet(Version, 8, "UInt")                                      ; [OUT] 
			DRIVER_VERSION["BuildBranchString"] := StrGet(Version.Ptr + 12, Const.NVAPI_SHORT_STRING_MAX, "CP0")   ; [OUT] 
			DRIVER_VERSION["AdapterString"]     := StrGet(Version.Ptr + 76, Const.NVAPI_SHORT_STRING_MAX, "CP0")   ; [OUT] 
			return DRIVER_VERSION
		}

		return this.GetErrorMessage(NvStatus)
	}



	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	; //
	; // FUNCTION NAME: NvAPI.GetDriverMemoryInfo
	; //
	; // This function retrieves the display driver memory information for the active display handle.
	; // In case of a multi-GPU scenario the physical framebuffer information is obtained for the GPU associated with the active display handle.
	; // In the case of SLI, the physical framebuffer information is obtained only from the display owner GPU.
	; //
	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	static GetDriverMemoryInfo(thisEnum := 0)
	{
		static NV_DRIVER_MEMORY_INFO := (4 * 4)

		hNvDisplay := this.EnumNvidiaDisplayHandle(thisEnum)
		MemoryInfo := Buffer(NV_DRIVER_MEMORY_INFO, 0)
		NumPut("UInt", NV_DRIVER_MEMORY_INFO | 0x10000, MemoryInfo, 0)              ; [IN] version info
		if !(NvStatus := DllCall(this.QueryInterface(0x2DC95125), "Ptr", hNvDisplay, "Ptr", MemoryInfo, "CDecl"))
		{
			MEMORY_INFO := Map()
			MEMORY_INFO["dedicatedVideoMemory"] := NumGet(MemoryInfo,  4, "UInt")   ; [OUT] physical framebuffer (in kb)
			MEMORY_INFO["systemVideoMemory"]    := NumGet(MemoryInfo,  8, "UInt")   ; [OUT] system memory the driver allocates at load time (in kb)
			MEMORY_INFO["sharedSystemMemory"]   := NumGet(MemoryInfo, 12, "UInt")   ; [OUT] shared system memory that driver is allowed to commit for surfaces across all allocations (in kb)
			return MEMORY_INFO
		}

		return this.GetErrorMessage(NvStatus)
	}



	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	; //
	; // FUNCTION NAME: NvAPI.GetDVCInfo
	; //
	; // This function retrieves the Digital Vibrance Control (DVC) information of the selected display.
	; //
	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	static GetDVCInfo(thisEnum := 0)
	{
		static NV_DISPLAY_DVC_INFO := (4 * 4)

		hNvDisplay := this.EnumNvidiaDisplayHandle(thisEnum)
		DVCInfo := Buffer(NV_DISPLAY_DVC_INFO, 0)
		NumPut("UInt", NV_DISPLAY_DVC_INFO | 0x10000, DVCInfo, 0)     ; [IN] version info
		if !(NvStatus := DllCall(this.QueryInterface(0x4085DE45), "Ptr", hNvDisplay, "UInt", outputId := 0, "Ptr", DVCInfo, "CDecl"))
		{
			DVC_INFO := Map()
			DVC_INFO["currentLevel"] := NumGet(DVCInfo,  4, "UInt")   ; [OUT] current DVC level
			DVC_INFO["minLevel"]     := NumGet(DVCInfo,  8, "UInt")   ; [OUT] min range level
			DVC_INFO["maxLevel"]     := NumGet(DVCInfo, 12, "UInt")   ; [OUT] max range level
			return DVC_INFO
		}

		return this.GetErrorMessage(NvStatus)
	}



	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	; //
	; // FUNCTION NAME: NvAPI.GetDVCInfoEx
	; //
	; // This API retrieves the Digital Vibrance Control(DVC) information of the selected display.
	; //
	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	static GetDVCInfoEx(thisEnum := 0)
	{
		static NV_DISPLAY_DVC_INFO_EX := (5 * 4)

		hNvDisplay := this.EnumNvidiaDisplayHandle(thisEnum)
		DVCInfo := Buffer(NV_DISPLAY_DVC_INFO_EX, 0)
		NumPut("UInt", NV_DISPLAY_DVC_INFO_EX | 0x10000, DVCInfo, 0)    ; [IN] version info
		if !(NvStatus := DllCall(this.QueryInterface(0x0E45002D), "Ptr", hNvDisplay, "UInt", outputId := 0, "Ptr", DVCInfo, "CDecl"))
		{
			DVC_INFO_EX := Map()
			DVC_INFO_EX["currentLevel"] := NumGet(DVCInfo,  4, "Int")   ; [OUT] current DVC level
			DVC_INFO_EX["minLevel"]     := NumGet(DVCInfo,  8, "Int")   ; [OUT] min range level
			DVC_INFO_EX["maxLevel"]     := NumGet(DVCInfo, 12, "Int")   ; [OUT] max range level
			DVC_INFO_EX["defaultLevel"] := NumGet(DVCInfo, 16, "Int")   ; [OUT] default DVC level
			return DVC_INFO_EX
		}

		return this.GetErrorMessage(NvStatus)
	}



	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	; //
	; // FUNCTION NAME: NvAPI.GetErrorMessage
	; //
	; // This function converts an NvAPI error code into a null terminated string.
	; //
	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	static GetErrorMessage(ErrorCode)
	{
		Desc := Buffer(Const.NVAPI_SHORT_STRING_MAX, 0)
		DllCall(this.QueryInterface(0x6C2D048C), "Ptr", ErrorCode, "Ptr", Desc, "CDecl")
		return "Error: " StrGet(Desc, "CP0")
	}



	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	; //
	; // FUNCTION NAME: NvAPI.GetHUEInfo
	; //
	; // This API retrieves the HUE information of the selected display.
	; //
	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	static GetHUEInfo(thisEnum := 0)
	{
		static NV_DISPLAY_HUE_INFO := (3 * 4)

		hNvDisplay := this.EnumNvidiaDisplayHandle(thisEnum)
		HUEInfo := Buffer(NV_DISPLAY_HUE_INFO, 0)
		NumPut("UInt", NV_DISPLAY_HUE_INFO | 0x10000, HUEInfo, 0)        ; [IN] version info
		if !(NvStatus := DllCall(this.QueryInterface(0x95B64341), "Ptr", hNvDisplay, "UInt", outputId := 0, "Ptr", HUEInfo, "CDecl"))
		{
			HUE_INFO := Map()
			HUE_INFO["currentHueAngle"] := NumGet(HUEInfo,  4, "UInt")   ; [OUT] current HUE Angle. typically between 0 - 360 degrees
			HUE_INFO["defaultHueAngle"] := NumGet(HUEInfo,  8, "UInt")   ; [OUT] default HUE Angle
			return HUE_INFO
		}

		return this.GetErrorMessage(NvStatus)
	}



	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	; //
	; // FUNCTION NAME: NvAPI.GetInterfaceVersionString
	; //
	; // This function returns a string describing the version of the NvAPI library.
	; // The contents of the string are human readable. Do not assume a fixed format.
	; //
	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	static GetInterfaceVersionString()
	{
		Desc := Buffer(Const.NVAPI_SHORT_STRING_MAX, 0)
		if !(NvStatus := DllCall(this.QueryInterface(0x01053FA5), "Ptr", Desc, "CDecl"))
		{
			return StrGet(Desc, "CP0")
		}

		return this.GetErrorMessage(NvStatus)
	}



	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	; //
	; // FUNCTION NAME: NvAPI.SetDVCLevel
	; //
	; // This function sets the DVC level for the selected display.
	; //
	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	static SetDVCLevel(level, thisEnum := 0)
	{
		DVC := this.GetDVCInfo(thisEnum)
		if (level < DVC["minLevel"]) || (level > DVC["maxLevel"])
		{
			MsgBox("DVCLevel should be within the range of min [" DVC["minLevel"] "] and max [" DVC["maxLevel"] "].", A_ThisFunc)
			return 0
		}

		hNvDisplay := this.EnumNvidiaDisplayHandle(thisEnum)
		if !(NvStatus := DllCall(this.QueryInterface(0x172409B4), "Ptr", hNvDisplay, "UInt", outputId := 0, "UInt", level, "CDECL"))
		{
			return level
		}

		return NvAPI.GetErrorMessage(NvStatus)
	}



	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	; //
	; // FUNCTION NAME: NvAPI.SetDVCLevelEx
	; //
	; // This API retrieves the Digital Vibrance Control(DVC) information of the selected display.
	; //
	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	static SetDVCLevelEx(currentLevel, thisEnum := 0)
	{
		static NV_DISPLAY_DVC_INFO_EX := (5 * 4) 

		DVC := this.GetDVCInfoEx(thisEnum)
		if (currentLevel < DVC["minLevel"]) || (currentLevel > DVC["maxLevel"])
		{
			MsgBox("DVCLevel should be within the range of min [" DVC["minLevel"] "] and max [" DVC["maxLevel"] "].", A_ThisFunc)
			return 0
		}

		hNvDisplay := this.EnumNvidiaDisplayHandle(thisEnum)
		DVCInfo := Buffer(NV_DISPLAY_DVC_INFO_EX, 0)
		NumPut("UInt", NV_DISPLAY_DVC_INFO_EX | 0x10000, DVCInfo, 0)   ; [IN] version info
		NumPut("Int", currentLevel, DVCInfo, 4)                        ; [IN] current DVC level
		if !(NvStatus := DllCall(this.QueryInterface(0x4A82C2B1), "Ptr", hNvDisplay, "UInt", outputId := 0, "Ptr", DVCInfo, "CDECL"))
		{
			return currentLevel
		}

		return NvAPI.GetErrorMessage(NvStatus)
	}



	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	; //
	; // FUNCTION NAME: NvAPI.SetHUEAngle
	; //
	; // This API sets the HUE level for the selected display.
	; //
	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	static SetHUEAngle(hueAngle, thisEnum := 0)
	{
		if (hueAngle < 0) || (hueAngle > 360)
		{
			MsgBox("HUEAngle should be within the range of min [" 0 "] and max [" 360 "].", A_ThisFunc)
			return 0
		}

		hNvDisplay := this.EnumNvidiaDisplayHandle(thisEnum)
		if !(NvStatus := DllCall(this.QueryInterface(0xF5A0F22C), "Ptr", hNvDisplay, "UInt", outputId := 0, "UInt", hueAngle, "CDECL"))
		{
			return hueAngle
		}

		return NvAPI.GetErrorMessage(NvStatus)
	}

}



; ===== NvAPI GPU FUNCTIONS =================================================================================================================================================

class GPU extends NvAPI
{

	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	; //
	; // FUNCTION NAME: GPU.GetAllClockFrequencies
	; //
	; // This function retrieves the NV_GPU_CLOCK_FREQUENCIES structure for the specified physical GPU
	; //
	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	static GetAllClockFrequencies(hPhysicalGpu := 0, ClockType := 0)
	{
		static NV_GPU_CLOCK_FREQUENCIES := (2 * 4) + (2 * 4 * Const.NVAPI_MAX_GPU_PUBLIC_CLOCKS)
		static NV_GPU_PUBLIC_CLOCK_ID   := Map("GRAPHICS", 0, "MEMORY", 4, "PROCESSOR", 7, "VIDEO", 8)
		static NV_GPU_CLOCK_FREQUENCIES_CLOCK_TYPE := Map(0, "CURRENT_FREQ", 1, "BASE_CLOCK", 2, "BOOST_CLOCK", 3, "TYPE_NUM")

		if !(hPhysicalGpu)
		{
			hPhysicalGpu := this.EnumPhysicalGPUs()[1]
		}
		if !(NV_GPU_CLOCK_FREQUENCIES_CLOCK_TYPE.Has(ClockType))
		{
			ClockType := 0
		}
		ClkFreqs := Buffer(NV_GPU_CLOCK_FREQUENCIES, 0)
		NumPut("UInt", NV_GPU_CLOCK_FREQUENCIES | 0x20000, ClkFreqs, 0)         ; [IN] structure version
		NumPut("UInt", ClockType, ClkFreqs, 4)                                  ; [IN] one of NV_GPU_CLOCK_FREQUENCIES_CLOCK_TYPE
		if !(NvStatus := DllCall(this.QueryInterface(0xDCB616C3), "Ptr", hPhysicalGpu, "Ptr", ClkFreqs, "CDecl"))
		{
			CLOCK_FREQUENCIES := Map()
			CLOCK_FREQUENCIES["enabled"] := NumGet(ClkFreqs, 4, "UInt") & 0x1   ; [OUT] bit 0 indicates if the dynamic Pstate is enabled or not

			for key, value in NV_GPU_PUBLIC_CLOCK_ID
			{
				Offset := 8 + (value * 8)
				CLOCK := Map()
				CLOCK["IsPresent"] := NumGet(ClkFreqs, Offset, "UInt") & 0x1    ; [OUT] set if this domain is present on this GPU
				CLOCK["frequency"] := NumGet(ClkFreqs, Offset + 4, "UInt")      ; [OUT] clock frequency (kHz)

				CLOCK_FREQUENCIES[key] := CLOCK
			}
			return CLOCK_FREQUENCIES
		}

		return this.GetErrorMessage(NvStatus)
	}



	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	; //
	; // FUNCTION NAME: GPU.GetCoolerSettings
	; //
	; // This function retrieves the cooler information of all coolers or a specific cooler associated with the selected GPU.
	; // Coolers are indexed 0 to NVAPI_MAX_COOLERS_PER_GPU-1.
	; //
	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	static GetCoolerSettings(hPhysicalGpu := 0)
	{
		static NV_GPU_GETCOOLER_SETTINGS := (2 * 4) + (16 * 4 * Const.NVAPI_MAX_COOLERS_PER_GPU)
		static NV_COOLER_TYPE            := Map(0, "NONE", 1, "FAN", 2, "WATER", 3, "LIQUID_NO2")
		static NV_COOLER_CONTROLLER      := Map(0, "NONE", 1, "ADI", 2, "INTERNAL")
		static NV_COOLER_POLICY          := Map(0, "NONE", 1, "MANUAL", 2, "PERF", 4, "DISCRETE", 8, "CONTINUOUS", 16, "CONTINUOUS_SW", 32, "DEFAULT")
		static NV_COOLER_TARGET          := Map(0, "NONE", 1, "GPU", 2, "MEMORY", 4, "POWER_SUPPLY", 7, "ALL", 8, "COOLER1", 9, "COOLER2", 10, "COOLER3")
		static NV_COOLER_CONTROL         := Map(0, "NONE", 1, "TOGGLE", 2, "VARIABLE")

		if !(hPhysicalGpu)
		{
			hPhysicalGpu := this.EnumPhysicalGPUs()[1]
		}
		CoolerInfo := Buffer(NV_GPU_GETCOOLER_SETTINGS, 0)
		NumPut("UInt", NV_GPU_GETCOOLER_SETTINGS | 0x30000, CoolerInfo, 0)                                   ; [IN] structure version
		if !(NvStatus := DllCall(this.QueryInterface(0xDA141340), "Ptr", hPhysicalGpu, "UInt", Const.NVAPI_COOLER_TARGET_ALL, "Ptr", CoolerInfo, "CDecl"))
		{
			COOLER_SETTINGS := Map()
			COOLER_SETTINGS["count"] := NumGet(CoolerInfo, 4, "UInt")                                        ; [OUT] number of associated coolers with the selected GPU
			loop COOLER_SETTINGS["count"]
			{
				Offset := 8 + ((A_Index - 1) * 64)
				COOLER := Map()
				COOLER["type"]            := NV_COOLER_TYPE[NumGet(CoolerInfo, Offset, "UInt")]              ; [OUT] type of cooler - FAN, WATER, LIQUID_NO2...
				COOLER["controller"]      := NV_COOLER_CONTROLLER[NumGet(CoolerInfo, Offset + 4, "UInt")]    ; [OUT] internal, ADI...
				COOLER["defaultMinLevel"] := NumGet(CoolerInfo, Offset + 8, "UInt")                          ; [OUT] the min default value % of the cooler
				COOLER["defaultMaxLevel"] := NumGet(CoolerInfo, Offset + 12, "UInt")                         ; [OUT] the max default value % of the cooler
				COOLER["currentMinLevel"] := NumGet(CoolerInfo, Offset + 16, "UInt")                         ; [OUT] the current allowed min value % of the cooler
				COOLER["currentMaxLevel"] := NumGet(CoolerInfo, Offset + 20, "UInt")                         ; [OUT] the current allowed max value % of the cooler
				COOLER["currentLevel"]    := NumGet(CoolerInfo, Offset + 24, "UInt")                         ; [OUT] the current value % of the cooler
				COOLER["defaultPolicy"]   := NV_COOLER_POLICY[NumGet(CoolerInfo, Offset + 28, "UInt")]       ; [OUT] cooler control policy - auto-perf, auto-thermal, manual, hybrid...
				COOLER["currentPolicy"]   := NV_COOLER_POLICY[NumGet(CoolerInfo, Offset + 32, "UInt")]       ; [OUT] cooler control policy - auto-perf, auto-thermal, manual, hybrid...
				COOLER["target"]          := NV_COOLER_TARGET[NumGet(CoolerInfo, Offset + 36, "UInt")]       ; [OUT] cooling target - GPU, memory, chipset, powersupply, Visual Computing Device...
				COOLER["controlType"]     := NV_COOLER_CONTROL[NumGet(CoolerInfo, Offset + 40, "UInt")]      ; [OUT] toggle or variable
				COOLER["active"]          := NumGet(CoolerInfo, Offset + 44, "UInt")                         ; [OUT] is the cooler active - fan spinning...
				COOLER["speedRPM"]        := NumGet(CoolerInfo, Offset + 48, "UInt")                         ; [OUT] current tachometer reading in RPM
				COOLER["bSupported"]      := NumGet(CoolerInfo, Offset + 52, "UChar")                        ; [OUT] cooler supports tach function?
				COOLER["maxSpeedRPM"]     := NumGet(CoolerInfo, Offset + 56, "UInt")                         ; [OUT] maximum RPM corresponding to 100% defaultMaxLevel
				COOLER["minSpeedRPM"]     := NumGet(CoolerInfo, Offset + 60, "UInt")                         ; [OUT] minimum RPM corresponding to 100% defaultMinLevel

				COOLER_SETTINGS[A_Index] := COOLER
			}
			return COOLER_SETTINGS
		}

		return this.GetErrorMessage(NvStatus)
	}



	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	; //
	; // FUNCTION NAME: GPU.GetCurrentFanSpeedLevel
	; //
	; // This API returns the current fan speed Level (Normal, Medium or Critical).
	; //
	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	static GetCurrentFanSpeedLevel(hPhysicalGpu := 0)
	{
		static NV_EVENT_LEVEL := Map(0, "UNKNOWN", 1, "NORMAL", 2, "WARNING", 3, "CRITICAL")

		if !(hPhysicalGpu)
		{
			hPhysicalGpu := this.EnumPhysicalGPUs()[1]
		}
		if !(NvStatus := DllCall(this.QueryInterface(0xBD71F0C9), "Ptr", hPhysicalGpu, "Int*", &FanSpeedLevel := 0, "CDecl"))
		{
			return NV_EVENT_LEVEL[FanSpeedLevel]
		}

		return this.GetErrorMessage(NvStatus)
	}



	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	; //
	; // FUNCTION NAME: GPU.GetCurrentThermalLevel
	; //
	; // This API returns the current Level (Normal, Medium or Critical) of the thermal sensor.
	; //
	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	static GetCurrentThermalLevel(hPhysicalGpu := 0)
	{
		static NV_EVENT_LEVEL := Map(0, "UNKNOWN", 1, "NORMAL", 2, "WARNING", 3, "CRITICAL")

		if !(hPhysicalGpu)
		{
			hPhysicalGpu := this.EnumPhysicalGPUs()[1]
		}
		if !(NvStatus := DllCall(this.QueryInterface(0xD2488B79), "Ptr", hPhysicalGpu, "Int*", &ThermalLevel := 0, "CDecl"))
		{
			return NV_EVENT_LEVEL[ThermalLevel]
		}

		return this.GetErrorMessage(NvStatus)
	}



	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	; //
	; // FUNCTION NAME: GPU.GetDynamicPstatesInfoEx
	; //
	; // This API retrieves the NV_GPU_DYNAMIC_PSTATES_INFO_EX structure for the specified physical GPU.
	; //
	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	static GetDynamicPstatesInfoEx(hPhysicalGpu := 0)
	{
		static NV_GPU_DYNAMIC_PSTATES_INFO_EX  := (2 * 4) + (2 * 4 * Const.NVAPI_MAX_GPU_UTILIZATIONS)
		static NVAPI_GPU_UTILIZATION_DOMAIN_ID := ["GPU", "FB", "VID", "BUS"]

		if !(hPhysicalGpu)
		{
			hPhysicalGpu := this.EnumPhysicalGPUs()[1]
		}
		DynamicPstatesInfoEx := Buffer(NV_GPU_DYNAMIC_PSTATES_INFO_EX, 0)
		NumPut("UInt", NV_GPU_DYNAMIC_PSTATES_INFO_EX | 0x10000, DynamicPstatesInfoEx, 0)     ; [IN] structure version
		if !(NvStatus := DllCall(this.QueryInterface(0x60DED2ED), "Ptr", hPhysicalGpu, "Ptr", DynamicPstatesInfoEx, "CDecl"))
		{
			PSTATES_INFO_EX := Map()
			PSTATES_INFO_EX["enabled"] := NumGet(DynamicPstatesInfoEx, 4, "UInt") & 0x1       ; [OUT] bit 0 indicates if the dynamic Pstate is enabled or not

			for index, value in NVAPI_GPU_UTILIZATION_DOMAIN_ID
			{
				Offset := 8 + ((index - 1) * 8)
				PSTATES := Map()
				PSTATES["IsPresent"]  := NumGet(DynamicPstatesInfoEx, Offset, "UInt") & 0x1   ; [OUT] set if this utilization domain is present on this GPU
				PSTATES["percentage"] := NumGet(DynamicPstatesInfoEx, Offset + 4, "UInt")     ; [OUT] percentage of time where the domain is considered busy in the last 1 second interval

				PSTATES_INFO_EX[value] := PSTATES
			}
			return PSTATES_INFO_EX
		}

		return this.GetErrorMessage(NvStatus)
	}



	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	; //
	; // FUNCTION NAME: GPU.GetFullName
	; //
	; // This function retrieves the full GPU name as an ASCII string - for example, "Quadro FX 1400".
	; //
	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	static GetFullName(hPhysicalGpu := 0)
	{
		if !(hPhysicalGpu)
		{
			hPhysicalGpu := this.EnumPhysicalGPUs()[1]
		}
		Name := Buffer(Const.NVAPI_SHORT_STRING_MAX, 0)
		if !(NvStatus := DllCall(this.QueryInterface(0xCEEE8E9F), "Ptr", hPhysicalGpu, "Ptr", Name, "CDecl"))
		{
			return StrGet(Name, "CP0")
		}

		return this.GetErrorMessage(NvStatus)
	}



	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	; //
	; // FUNCTION NAME: GPU.GetGpuCoreCount
	; //
	; // Retrieves the total number of cores defined for a GPU.
	; //
	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	static GetGpuCoreCount(hPhysicalGpu := 0)
	{
		if !(hPhysicalGpu)
		{
			hPhysicalGpu := this.EnumPhysicalGPUs()[1]
		}
		if !(NvStatus := DllCall(this.QueryInterface(0xC7026A87), "Ptr", hPhysicalGpu, "UInt*", &Count := 0, "CDecl"))
		{
			return Count
		}

		return this.GetErrorMessage(NvStatus)
	}



	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	; //
	; // FUNCTION NAME: GPU.GetMemoryInfo
	; //
	; // This function retrieves the available driver memory footprint for the specified GPU.
	; // If the GPU is in TCC Mode, only dedicatedVideoMemory will be returned.
	; //
	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	static GetMemoryInfo(hPhysicalGpu := 0)
	{
		static NV_DISPLAY_DRIVER_MEMORY_INFO := (8 * 4)

		if !(hPhysicalGpu)
		{
			hPhysicalGpu := this.EnumPhysicalGPUs()[1]
		}
		MemoryInfo := Buffer(NV_DISPLAY_DRIVER_MEMORY_INFO, 0)
		NumPut("UInt", NV_DISPLAY_DRIVER_MEMORY_INFO | 0x30000, MemoryInfo, 0)                   ; [IN] version info
		if !(NvStatus := DllCall(this.QueryInterface(0x07F9B368), "Ptr", hPhysicalGpu, "Ptr", MemoryInfo, "CDecl"))
		{
			MEMORY_INFO := Map()
			MEMORY_INFO["dedicatedVideoMemory"]              := NumGet(MemoryInfo,  4, "UInt")   ; [OUT] physical framebuffer (in kb)
			MEMORY_INFO["availableDedicatedVideoMemory"]     := NumGet(MemoryInfo,  8, "UInt")   ; [OUT] available physical framebuffer for allocating video memory surfaces (in kb)
			MEMORY_INFO["systemVideoMemory"]                 := NumGet(MemoryInfo, 12, "UInt")   ; [OUT] system memory the driver allocates at load time (in kb)
			MEMORY_INFO["sharedSystemMemory"]                := NumGet(MemoryInfo, 16, "UInt")   ; [OUT] shared system memory that driver is allowed to commit for surfaces across all allocations (in kb)
			MEMORY_INFO["curAvailableDedicatedVideoMemory"]  := NumGet(MemoryInfo, 20, "UInt")   ; [OUT] current available physical framebuffer for allocating video memory surfaces (in kb)
			MEMORY_INFO["dedicatedVideoMemoryEvictionsSize"] := NumGet(MemoryInfo, 24, "UInt")   ; [OUT] total size of memory released as a result of the evictions (in kb)
			MEMORY_INFO["dedicatedVideoMemoryEvictionCount"] := NumGet(MemoryInfo, 28, "UInt")   ; [OUT] number of eviction events that caused an allocation to be removed from dedicated video memory to free GPU video memory to make room for other allocations.
			return MEMORY_INFO
		}

		return this.GetErrorMessage(NvStatus)
	}



	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	; //
	; // FUNCTION NAME: GPU.GetRamMaker
	; //
	; // This function retrieves the RAM maker associated with this GPU.
	; //
	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	static GetRamMaker(hPhysicalGpu := 0)
	{
		static NV_RAM_MAKER := Map(0, "UNKNOWN", 1, "SAMSUNG", 2, "QIMONDA", 3, "ELPIDA", 4, "ETRON", 5, "NANYA", 6, "HYNIX", 7, "MOSEL", 8, "WINBOND", 9, "ELITE", 10, "MICRON")

		if !(hPhysicalGpu)
		{
			hPhysicalGpu := this.EnumPhysicalGPUs()[1]
		}
		if !(NvStatus := DllCall(this.QueryInterface(0x42AEA16A), "Ptr", hPhysicalGpu, "Int*", &RamType := 0, "CDecl"))
		{
			return NV_RAM_MAKER[RamType]
		}

		return this.GetErrorMessage(NvStatus)
	}



	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	; //
	; // FUNCTION NAME: GPU.GetRamType
	; //
	; // This function retrieves the type of VRAM associated with this GPU.
	; //
	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	static GetRamType(hPhysicalGpu := 0)
	{
		static NV_GPU_RAM_TYPE := Map(0, "UNKNOWN", 1, "SDRAM", 2, "DDR1", 3, "DDR2", 4, "GDDR2", 5, "GDDR3", 6, "GDDR4", 7, "DDR3", 8, "GDDR5", 9, "LPDDR2")

		if !(hPhysicalGpu)
		{
			hPhysicalGpu := this.EnumPhysicalGPUs()[1]
		}
		if !(NvStatus := DllCall(this.QueryInterface(0x57F7CAAC), "Ptr", hPhysicalGpu, "Int*", &RamType := 0, "CDecl"))
		{
			return NV_GPU_RAM_TYPE[RamType]
		}

		return this.GetErrorMessage(NvStatus)
	}



	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	; //
	; // FUNCTION NAME: GPU.GetTachReading
	; //
	; // This API retrieves the fan speed tachometer reading for the specified physical GPU.
	; //
	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	static GetTachReading(hPhysicalGpu := 0)
	{
		if !(hPhysicalGpu)
		{
			hPhysicalGpu := this.EnumPhysicalGPUs()[1]
		}
		if !(NvStatus := DllCall(this.QueryInterface(0x5F608315), "Ptr", hPhysicalGpu, "UInt*", &Value := 0, "CDecl"))
		{
			return Value
		}

		return this.GetErrorMessage(NvStatus)
	}



	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	; //
	; // FUNCTION NAME: GPU.GetThermalSettings
	; //
	; // This function retrieves the thermal information of all thermal sensors or specific thermal sensor associated with the selected GPU.
	; // Thermal sensors are indexed 0 to NVAPI_MAX_THERMAL_SENSORS_PER_GPU-1.
	; //
	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	static GetThermalSettings(hPhysicalGpu := 0)
	{
		static NV_GPU_THERMAL_SETTINGS := (2 * 4) + (5 * 4 * Const.NVAPI_MAX_THERMAL_SENSORS_PER_GPU)
		static NV_THERMAL_CONTROLLER := Map(-1, "UNKNOWN", 0, "NONE", 1, "GPU_INTERNAL", 2, "ADM1032", 3, "MAX6649", 4, "MAX1617", 5, "LM99", 6, "LM89", 7, "LM64"
		                                   , 8, "ADT7473", 9, "SBMAX6649", 10, "VBIOSEVT", 11, "OS")
		static NV_THERMAL_TARGET     := Map(-1, "UNKNOWN", 0, "NONE", 1, "GPU", 2, "MEMORY", 4, "POWER_SUPPLY", 8, "BOARD", 9, "VCD_BOARD", 10, "VCD_INLET", 11, "VCD_OUTLET", 15, "ALL")

		if !(hPhysicalGpu)
		{
			hPhysicalGpu := this.EnumPhysicalGPUs()[1]
		}
		ThermalSettings := Buffer(NV_GPU_THERMAL_SETTINGS, 0)
		NumPut("UInt", NV_GPU_THERMAL_SETTINGS | 0x20000, ThermalSettings, 0)                                  ; [IN] structure version
		if !(NvStatus := DllCall(this.QueryInterface(0xE3640A56), "Ptr", hPhysicalGpu, "UInt", Const.NVAPI_THERMAL_TARGET_ALL, "Ptr", ThermalSettings, "CDecl"))
		{
			THERMAL_SETTINGS := Map()
			THERMAL_SETTINGS["count"] := NumGet(ThermalSettings, 4, "UInt")                                    ; [OUT] number of associated thermal sensors
			loop THERMAL_SETTINGS["count"]
			{
				Offset := 8 + ((A_Index - 1) * 20)
				THERMAL := Map()
				THERMAL["controller"]     := NV_THERMAL_CONTROLLER[NumGet(ThermalSettings, Offset, "UInt")]    ; [OUT] internal, ADM1032, MAX6649...
				THERMAL["defaultMinTemp"] := NumGet(ThermalSettings, Offset + 4, "Int")                        ; [OUT] min default temperature value of the thermal sensor in degree Celsius
				THERMAL["defaultMaxTemp"] := NumGet(ThermalSettings, Offset + 8, "Int")                        ; [OUT] max default temperature value of the thermal sensor in degree Celsius
				THERMAL["currentTemp"]    := NumGet(ThermalSettings, Offset + 12, "Int")                       ; [OUT] current temperature value of the thermal sensor in degree Celsius
				THERMAL["target"]         := NV_THERMAL_TARGET[NumGet(ThermalSettings, Offset + 16, "UInt")]   ; [OUT] thermal sensor targeted @ GPU, memory, chipset, powersupply, Visual Computing Device, etc.

				THERMAL_SETTINGS[A_Index] := THERMAL
			}
			return THERMAL_SETTINGS
		}

		return this.GetErrorMessage(NvStatus)
	}



	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	; //
	; // FUNCTION NAME: GPU.GetUsages
	; //
	; // This function retrieves the usage associated with this GPU.
	; //
	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	static GetUsages(hPhysicalGpu := 0)
	{
		static NV_USAGES_INFO := 4 + (4 * Const.NVAPI_MAX_USAGES_PER_GPU)

		if !(hPhysicalGpu)
		{
			hPhysicalGpu := this.EnumPhysicalGPUs()[1]
		}
		UsagesInfo := Buffer(NV_USAGES_INFO, 0)
		NumPut("UInt", NV_USAGES_INFO | 0x10000, UsagesInfo, 0)    ; [IN] version info
		if !(NvStatus := DllCall(this.QueryInterface(0x189A1FDF), "Ptr", hPhysicalGpu, "Ptr", UsagesInfo, "CDecl"))
		{
			return NumGet(UsagesInfo, 12, "UInt")                  ; [OUT] GPU usage
		}

		return this.GetErrorMessage(NvStatus)
	}



	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	; //
	; // FUNCTION NAME: GPU.GetQuadroStatus
	; //
	; // This function retrieves the Quadro status for the GPU (1 if Quadro, 0 if GeForce).
	; // Do not use this function - it is deprecated in release 460.
	; //
	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	static GetQuadroStatus(hPhysicalGpu := 0)
	{
		if !(hPhysicalGpu)
		{
			hPhysicalGpu := this.EnumPhysicalGPUs()[1]
		}
		if !(NvStatus := DllCall(this.QueryInterface(0xE332FA47), "Ptr", hPhysicalGpu, "UInt*", &Status := 0, "CDecl"))
		{
			return (Status) ? "Quadro" : "GeForce"
		}

		return this.GetErrorMessage(NvStatus)
	}

}



; ===== NvAPI SYS FUNCTIONS =================================================================================================================================================

class SYS extends NvAPI
{

	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	; //
	; // FUNCTION NAME: SYS.GetChipSetInfo
	; //
	; // This function returns information about the system's chipset.
	; //
	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	static GetChipSetInfo()
	{
		static NV_CHIPSET_INFO := (10 * 4) + (3 * Const.NVAPI_SHORT_STRING_MAX)

		ChipSetInfo := Buffer(NV_CHIPSET_INFO, 0)
		NumPut("UInt", NV_CHIPSET_INFO | 0x40000, ChipSetInfo, 0)                                                    ; [IN] version info
		if !(NvStatus := DllCall(this.QueryInterface(0x53DABBCA), "Ptr", ChipSetInfo, "CDecl"))
		{
			CHIPSET_INFO := Map()
			CHIPSET_INFO["vendorId"]         := NumGet(ChipSetInfo,        4, "UInt")                                ; [OUT] chipset vendor identification
			CHIPSET_INFO["deviceId"]         := NumGet(ChipSetInfo,        8, "UInt")                                ; [OUT] chipset device identification
			CHIPSET_INFO["VendorName"]       := StrGet(ChipSetInfo.Ptr +  12, Const.NVAPI_SHORT_STRING_MAX, "CP0")   ; [OUT] chipset vendor Name
			CHIPSET_INFO["ChipsetName"]      := StrGet(ChipSetInfo.Ptr +  76, Const.NVAPI_SHORT_STRING_MAX, "CP0")   ; [OUT] chipset device Name
			CHIPSET_INFO["flags"]            := NumGet(ChipSetInfo,      140, "UInt")                                ; [OUT] chipset info flags - obsolete
			CHIPSET_INFO["subSysVendorId"]   := NumGet(ChipSetInfo,      144, "UInt")                                ; [OUT] chipset subsystem vendor identification
			CHIPSET_INFO["subSysDeviceId"]   := NumGet(ChipSetInfo,      148, "UInt")                                ; [OUT] chipset subsystem device identification
			CHIPSET_INFO["SubSysVendorName"] := StrGet(ChipSetInfo.Ptr + 152, Const.NVAPI_SHORT_STRING_MAX, "CP0")   ; [OUT] subsystem vendor Name
			CHIPSET_INFO["HBvendorId"]       := NumGet(ChipSetInfo,      216, "UInt")                                ; [OUT] host bridge vendor identification
			CHIPSET_INFO["HBdeviceId"]       := NumGet(ChipSetInfo,      220, "UInt")                                ; [OUT] host bridge device identification
			CHIPSET_INFO["HBsubSysVendorId"] := NumGet(ChipSetInfo,      224, "UInt")                                ; [OUT] host bridge subsystem vendor identification
			CHIPSET_INFO["HBsubSysDeviceId"] := NumGet(ChipSetInfo,      228, "UInt")                                ; [OUT] host bridge subsystem device identification
			return CHIPSET_INFO
		}

		return this.GetErrorMessage(NvStatus)
	}



	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	; //
	; // FUNCTION NAME: SYS.GetDisplayDriverInfo
	; //
	; // This API will return information related to the NVIDIA Display Driver.
	; // Note that out of the driver types - Studio, Game Ready, RTX Production Branch, RTX New Feature Branch - only one driver type can be available in system.
	; //
	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	static GetDisplayDriverInfo()
	{
		static NV_DISPLAY_DRIVER_INFO := (2 * 4) + (Const.NVAPI_SHORT_STRING_MAX) + 4
		static NvCaps := Map("IsDCHDriver", 1, "IsNVIDIAStudioPackage", 2, "IsNVIDIAGameReadyPackage", 4, "IsNVIDIARTXProductionBranchPackage", 8, "IsNVIDIARTXNewFeatureBranchPackage", 16)

		DriverInfo := Buffer(NV_DISPLAY_DRIVER_INFO, 0)
		NumPut("UInt", NV_DISPLAY_DRIVER_INFO | 0x10000, DriverInfo, 0)                                                    ; [IN] version info
		if !(NvStatus := DllCall(this.QueryInterface(0x721FACEB), "Ptr", DriverInfo, "CDecl"))
		{
			DRIVER_INFO := Map()
			DRIVER_INFO["driverVersion"] := NumGet(DriverInfo, 4, "UInt")                                                  ; [OUT] driver version
			DRIVER_INFO["BuildBranch"]   := StrGet(DriverInfo.Ptr + 8, Const.NVAPI_SHORT_STRING_MAX, "CP0")                ; [OUT] driver-branch string
			bitfield := NumGet(DriverInfo, 72, "UInt")
			for NvCap, mask in NvCaps
				DRIVER_INFO[NvCap] := !!(bitfield & mask)
			return DRIVER_INFO
		}

		return this.GetErrorMessage(NvStatus)
	}



	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	; //
	; // FUNCTION NAME: SYS.GetDriverAndBranchVersion
	; //
	; // This API returns display driver version and driver-branch string.
	; //
	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	static GetDriverAndBranchVersion()
	{
		BuildBranchString := Buffer(Const.NVAPI_SHORT_STRING_MAX, 0)
		if !(NvStatus := DllCall(this.QueryInterface(0x2926AAAD), "UInt*", &DriverVersion := 0, "Ptr", BuildBranchString, "CDecl"))
		{
			DriverAndBranchVersion := Map()
			DriverAndBranchVersion["DriverVersion"]     := DriverVersion                      ; [OUT] driver version
			DriverAndBranchVersion["BuildBranchString"] := StrGet(BuildBranchString, "CP0")   ; [OUT] driver-branch string
			return DriverAndBranchVersion
		}

		return this.GetErrorMessage(NvStatus)
	}

}



; ===== NvAPI CONSTANTS =====================================================================================================================================================

class Const extends NvAPI
{
	static NVAPI_COOLER_TARGET_ALL           := 7
	static NVAPI_THERMAL_TARGET_ALL          := 15
	static NVAPI_SHORT_STRING_MAX            := 64
	static NVAPI_MAX_COOLERS_PER_GPU         := 20
	static NVAPI_MAX_GPU_PUBLIC_CLOCKS       := 32
	static NVAPI_MAX_GPU_UTILIZATIONS        := 8
	static NVAPI_MAX_LOGICAL_GPUS            := 64
	static NVAPI_MAX_PHYSICAL_GPUS           := 64
	static NVAPI_MAX_THERMAL_SENSORS_PER_GPU := 3
	static NVAPI_MAX_USAGES_PER_GPU          := 33
}



; ===========================================================================================================================================================================

class MapX extends Map {
	CaseSense := "Off"  ; should be dafault. change my mind.
	Default   := ""
}



; ===========================================================================================================================================================================
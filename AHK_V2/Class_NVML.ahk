; ===========================================================================================================================================================================

/*
	AutoHotkey wrapper for NVIDIA NVML API

	Author ....: jNizM
	Released ..: 2021-09-29
	Modified ..: 2021-10-11
	License ...: MIT
	GitHub ....: https://github.com/jNizM/NVIDIA_NVML
	Forum .....: https://www.autohotkey.com/boards/viewtopic.php?t=95175
*/

; SCRIPT DIRECTIVES =========================================================================================================================================================

#Requires AutoHotkey v2.0-


; ===== NVML CORE FUNCTIONS ================================================================================================================================================

class NVML
{
	static _Init := NVML.__Initialize()


	static __Initialize()
	{
		if !(this.hModule := DllCall("LoadLibrary", "Str", "nvml.dll", "Ptr"))
		{
			MsgBox("NVML could not be started!`n`nThe program will exit!", A_ThisFunc)
			ExitApp
		}
		if (NvStatus := DllCall("nvml\nvmlInit_v2", "CDecl") != 0)
		{
			MsgBox("NVML initialization failed: [ " NvStatus " ]`n`nThe program will exit!", A_ThisFunc)
			ExitApp
		}
	}



	static __Delete()
	{
		DllCall("nvml\nvmlShutdown", "CDecl")
		if (this.hModule)
			DllCall("FreeLibrary", "Ptr", this.hModule)
	}



	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	; //
	; // FUNCTION NAME: NVML.ErrorString
	; //
	; // Helper method for converting NVML error codes into readable strings.
	; //
	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	static ErrorString(ErrorCode)
	{
		Result := DllCall("nvml\nvmlErrorString", "Int", ErrorCode, "Ptr")
		return StrGet(Result, "CP0")
	}

}



; ===== NVML DEVICE FUNCTIONS =================================================================================================================================================

class DEVICE extends NVML
{

	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	; //
	; // FUNCTION NAME: DEVICE.GetBrand
	; //
	; // Retrieves the brand of this device.
	; //
	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	static GetBrand(hDevice := 0)
	{
		static NVML_BRAND_TYPE := Map(0, "UNKNOWN", 1, "QUADRO", 2, "TESLA", 3, "NVS", 4, "GRID", 5, "GEFORCE", 6, "TITAN"
		                            , 7, "NVIDIA_VAPPS", 8, "NVIDIA_VPC", 9, "NVIDIA_VCS", 10, "NVIDIA_VWS", 11, "NVIDIA_VGAMING"
		                            , 12, "QUADRO_RTX", 13, "NVIDIA_RTX", 14, "NVIDIA", 15, "GEFORCE_RTX", 16, "TITAN_RTX")

		if !(hDevice)
		{
			hDevice := this.GetHandleByIndex()
		}
		if !(NvStatus := DllCall("nvml\nvmlDeviceGetBrand", "Ptr", hDevice, "Int*", &BrandType := 0, "CDecl"))
		{
			return NVML_BRAND_TYPE[BrandType]   ; [OUT] brand of this device
		}

		return this.ErrorString(NvStatus)
	}



	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	; //
	; // FUNCTION NAME: DEVICE.GetCount
	; //
	; // Retrieves the number of compute devices in the system. A compute device is a single GPU.
	; //
	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	static GetCount()
	{
		if !(NvStatus := DllCall("nvml\nvmlDeviceGetCount_v2", "UInt*", &DeviceCount := 0, "CDecl"))
		{
			return DeviceCount   ; [OUT] number of compute devices
		}

		return this.ErrorString(NvStatus)
	}



	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	; //
	; // FUNCTION NAME: DEVICE.GetAttributes
	; //
	; // Get attributes (engine counts etc.) for the given NVML device handle.
	; //
	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	static GetAttributes(hDevice := 0)
	{
		if !(hDevice)
		{
			hDevice := this.GetHandleByIndex()
		}
		Attributes := Buffer(40, 0)
		if !(NvStatus := DllCall("nvml\nvmlDeviceGetAttributes_v2", "Ptr", hDevice, "Ptr", Attributes, "CDecl"))
		{
			ATTR := Map()
			ATTR["multiprocessorCount"]       := NumGet(Attributes,  0, "UInt")     ; [OUT] Streaming Multiprocessor count
			ATTR["sharedCopyEngineCount"]     := NumGet(Attributes,  4, "UInt")     ; [OUT] Shared Copy Engine count
			ATTR["sharedDecoderCount"]        := NumGet(Attributes,  8, "UInt")     ; [OUT] Shared Decoder Engine count
			ATTR["sharedEncoderCount"]        := NumGet(Attributes, 12, "UInt")     ; [OUT] Shared Encoder Engine count
			ATTR["sharedJpegCount"]           := NumGet(Attributes, 16, "UInt")     ; [OUT] Shared JPEG Engine count
			ATTR["sharedOfaCount"]            := NumGet(Attributes, 20, "UInt")     ; [OUT] Shared OFA Engine count
			ATTR["gpuInstanceSliceCount"]     := NumGet(Attributes, 24, "UInt")     ; [OUT] GPU instance slice count
			ATTR["computeInstanceSliceCount"] := NumGet(Attributes, 28, "UInt")     ; [OUT] Compute instance slice count
			ATTR["memorySizeMB"]              := NumGet(Attributes, 36, "UInt64")   ; [OUT] Device memory size (in MiB)
			return ATTR
		}

		return this.ErrorString(NvStatus)
	}



	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	; //
	; // FUNCTION NAME: DEVICE.GetFanSpeed
	; //
	; // Retrieves the intended operating speed of the device's fan.
	; // Note: The reported speed is the intended fan speed. If the fan is physically blocked and unable to spin, the output will not match the actual fan speed.
	; //
	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	static GetFanSpeed(hDevice := 0)
	{
		if !(hDevice)
		{
			hDevice := this.GetHandleByIndex()
		}
		if !(NvStatus := DllCall("nvml\nvmlDeviceGetFanSpeed", "Ptr", hDevice, "UInt*", &FanSpeed := 0, "CDecl"))
		{
			return FanSpeed   ; [OUT] intended operating speed of the device's fan
		}

		return this.ErrorString(NvStatus)
	}



	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	; //
	; // FUNCTION NAME: DEVICE.GetHandleByIndex
	; //
	; // Retrieves the NVML index of this device.
	; //
	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	static GetHandleByIndex(Index := 0)
	{
		if !(NvStatus := DllCall("nvml\nvmlDeviceGetHandleByIndex_v2", "UInt", Index, "Ptr*", &hDevice := 0, "CDecl"))
		{
			return hDevice   ; [OUT] handle for a particular device, based on its index
		}

		return this.ErrorString(NvStatus)
	}



	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	; //
	; // FUNCTION NAME: DEVICE.GetInforomImageVersion
	; //
	; // Retrieves the global infoROM image version. For all products with an inforom.
	; //
	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	static GetInforomImageVersion(hDevice := 0)
	{
		if !(hDevice)
		{
			hDevice := this.GetHandleByIndex()
		}
		Version := Buffer(Const.NVML_DEVICE_INFOROM_VERSION_BUFFER_SIZE, 0)
		if !(NvStatus := DllCall("nvml\nvmlDeviceGetInforomImageVersion", "Ptr", hDevice, "Ptr", Version, "UInt", Const.NVML_DEVICE_INFOROM_VERSION_BUFFER_SIZE, "CDecl"))
		{
			return StrGet(Version, "CP0")   ; [OUT] global infoROM image version
		}

		return this.ErrorString(NvStatus)
	}



	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	; //
	; // FUNCTION NAME: DEVICE.GetName
	; //
	; // Retrieves the name of this device.
	; //
	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	static GetName(hDevice := 0)
	{
		if !(hDevice)
		{
			hDevice := this.GetHandleByIndex()
		}
		DeviceName := Buffer(Const.NVML_DEVICE_NAME_V2_BUFFER_SIZE, 0)
		if !(NvStatus := DllCall("nvml\nvmlDeviceGetName", "Ptr", hDevice, "Ptr", DeviceName, "UInt", Const.NVML_DEVICE_NAME_V2_BUFFER_SIZE, "CDecl"))
		{
			return StrGet(DeviceName, "CP0")   ; [OUT] name of this device
		}

		return this.ErrorString(NvStatus)
	}



	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	; //
	; // FUNCTION NAME: DEVICE.GetMemoryInfo
	; //
	; // Retrieves the amount of used, free and total memory available on the device, in bytes.
	; //
	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	static GetMemoryInfo(hDevice := 0)
	{
		if !(hDevice)
		{
			hDevice := this.GetHandleByIndex()
		}
		MemoryInfo := Buffer(24, 0)
		if !(NvStatus := DllCall("nvml\nvmlDeviceGetMemoryInfo", "Ptr", hDevice, "Ptr", MemoryInfo, "CDecl"))
		{
			MEMORY := Map()
			MEMORY["Total"] := NumGet(MemoryInfo,  0, "UInt64")   ; [OUT] Total installed FB memory (in bytes)
			MEMORY["Free"]  := NumGet(MemoryInfo,  8, "UInt64")   ; [OUT] Unallocated FB memory (in bytes)
			MEMORY["Used"]  := NumGet(MemoryInfo, 16, "UInt64")   ; [OUT] Allocated FB memory (in bytes)
			return MEMORY
		}

		return this.ErrorString(NvStatus)
	}



	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	; //
	; // FUNCTION NAME: DEVICE.GetMinorNumber
	; //
	; // Retrieves minor number for the device.
	; // The minor number for the device is such that the Nvidia device node file for each GPU will have the form /dev/nvidia[minor number].
	; //
	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	static GetMinorNumber(hDevice := 0)
	{
		if !(hDevice)
		{
			hDevice := this.GetHandleByIndex()
		}
		if !(NvStatus := DllCall("nvml\nvmlDeviceGetMinorNumber", "Ptr", hDevice, "UInt*", &MinorNumber := 0, "CDecl"))
		{
			return MinorNumber   ; [OUT] minor number for the devic
		}

		return this.ErrorString(NvStatus)
	}



	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	; //
	; // FUNCTION NAME: DEVICE.GetPowerUsage
	; //
	; // Retrieves power usage for this GPU in milliwatts and its associated circuitry (e.g. memory)
	; //
	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	static GetPowerUsage(hDevice := 0)
	{
		if !(hDevice)
		{
			hDevice := this.GetHandleByIndex()
		}
		if !(NvStatus := DllCall("nvml\nvmlDeviceGetPowerUsage", "Ptr", hDevice, "UInt*", &PowerUsage := 0, "CDecl"))
		{
			return PowerUsage   ; [OUT] power usage (in milliwatts)
		}

		return this.ErrorString(NvStatus)
	}



	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	; //
	; // FUNCTION NAME: DEVICE.GetTemperature
	; //
	; // Retrieves the current temperature readings for the device, in degrees C.
	; //
	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	static GetTemperature(hDevice := 0)
	{
		if !(hDevice)
		{
			hDevice := this.GetHandleByIndex()
		}
		if !(NvStatus := DllCall("nvml\nvmlDeviceGetTemperature", "Ptr", hDevice, "Int", Const.NVML_TEMPERATURE_GPU, "UInt*", &Temperature := 0, "CDecl"))
		{
			return Temperature   ; [OUT] current temperature (in degrees C)
		}

		return this.ErrorString(NvStatus)
	}



	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	; //
	; // FUNCTION NAME: DEVICE.GetTotalEnergyConsumption
	; //
	; // Retrieves total energy consumption for this GPU in millijoules (mJ) since the driver was last reloaded
	; //
	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	static GetTotalEnergyConsumption(hDevice := 0)
	{
		if !(hDevice)
		{
			hDevice := this.GetHandleByIndex()
		}
		if !(NvStatus := DllCall("nvml\nvmlDeviceGetTotalEnergyConsumption", "Ptr", hDevice, "UInt64*", &EnergyConsumption := 0, "CDecl"))
		{
			return EnergyConsumption   ; [OUT] total energy (in millijoules (mJ))
		}

		return this.ErrorString(NvStatus)
	}



	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	; //
	; // FUNCTION NAME: DEVICE.GetUtilizationRates
	; //
	; // Retrieves the current utilization rates for the device's major subsystems.
	; //
	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	static GetUtilizationRates(hDevice := 0)
	{
		if !(hDevice)
		{
			hDevice := this.GetHandleByIndex()
		}
		UtilizationRates := Buffer(8, 0)
		if !(NvStatus := DllCall("nvml\nvmlDeviceGetUtilizationRates", "Ptr", hDevice, "Ptr", UtilizationRates, "CDecl"))
		{
			UTILIZATION := Map()
			UTILIZATION["GPU"]    := NumGet(UtilizationRates, 0, "UInt")   ; [OUT] percent of time over the past sample period during which one or more kernels was executing on the GPU
			UTILIZATION["MEMORY"] := NumGet(UtilizationRates, 4, "UInt")   ; [OUT] percent of time over the past sample period during which global (device) memory was being read or written
			return UTILIZATION
		}

		return this.ErrorString(NvStatus)
	}



	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	; //
	; // FUNCTION NAME: DEVICE.GetUUID
	; //
	; // Retrieves the globally unique immutable UUID associated with this device, as a 5 part hexadecimal string, that augments the immutable, board serial identifier.
	; //
	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	static GetUUID(hDevice := 0)
	{
		if !(hDevice)
		{
			hDevice := this.GetHandleByIndex()
		}
		UUID := Buffer(Const.NVML_DEVICE_UUID_V2_BUFFER_SIZE, 0)
		if !(NvStatus := DllCall("nvml\nvmlDeviceGetUUID", "Ptr", hDevice, "Ptr", UUID, "UInt", Const.NVML_DEVICE_UUID_V2_BUFFER_SIZE, "CDecl"))
		{
			return StrGet(UUID, "CP0")   ; [OUT] globally unique immutable UUID
		}

		return this.ErrorString(NvStatus)
	}

}



; ===== NVML SYSTEM FUNCTIONS =================================================================================================================================================

class SYSTEM extends NVML
{

	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	; //
	; // FUNCTION NAME: SYSTEM.GetCudaDriverVersion
	; //
	; // Retrieves the version of the CUDA driver.
	; //
	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	static GetCudaDriverVersion()
	{
		if !(NvStatus := DllCall("nvml\nvmlSystemGetCudaDriverVersion", "Int*", &CudaDriverVersion := 0))
		{
			return CudaDriverVersion   ; [OUT] version of the CUDA driver
		}

		return this.ErrorString(NvStatus)
	}



	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	; //
	; // FUNCTION NAME: SYSTEM.GetDriverVersion
	; //
	; // Retrieves the version of the system's graphics driver.
	; //
	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	static GetDriverVersion()
	{
		Version := Buffer(Const.NVML_SYSTEM_DRIVER_VERSION_BUFFER_SIZE, 0)
		if !(NvStatus := DllCall("nvml\nvmlSystemGetDriverVersion", "Ptr", Version, "UInt", Const.NVML_SYSTEM_DRIVER_VERSION_BUFFER_SIZE, "CDecl"))
		{
			return StrGet(Version, "CP0")   ; [OUT] version identifier (as an alphanumeric string)
		}

		return this.ErrorString(NvStatus)
	}



	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	; //
	; // FUNCTION NAME: SYSTEM.GetNVMLVersion
	; //
	; // Retrieves the version of the NVML library.
	; //
	; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	static GetNVMLVersion()
	{
		Version := Buffer(Const.NVML_SYSTEM_NVML_VERSION_BUFFER_SIZE, 0)
		if !(NvStatus := DllCall("nvml\nvmlSystemGetNVMLVersion", "Ptr", Version, "UInt", Const.NVML_SYSTEM_NVML_VERSION_BUFFER_SIZE, "CDecl"))
		{
			return StrGet(Version, "CP0")   ; [OUT] version of the NVML library
		}

		return this.ErrorString(NvStatus)
	}

}



; ===== NVML CONSTANTS =====================================================================================================================================================

class Const extends NVML
{
	static NVML_DEVICE_INFOROM_VERSION_BUFFER_SIZE := 16
	static NVML_DEVICE_NAME_V2_BUFFER_SIZE         := 96
	static NVML_DEVICE_UUID_V2_BUFFER_SIZE         := 96
	static NVML_SYSTEM_DRIVER_VERSION_BUFFER_SIZE  := 80
	static NVML_SYSTEM_NVML_VERSION_BUFFER_SIZE    := 80
	static NVML_TEMPERATURE_GPU                    := 0
}


; ===========================================================================================================================================================================
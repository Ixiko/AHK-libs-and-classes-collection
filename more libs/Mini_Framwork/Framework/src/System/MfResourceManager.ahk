;{ License
/* This file is part of Mini-Framework For AutoHotkey.
	* 
	* Mini-Framework is free software: you can redistribute it and/or modify
	* it under the terms of the GNU General Public License as published by
	* the Free Software Foundation, version 2 of the License.
	* 
	* Mini-Framework is distributed in the hope that it will be useful,
	* but WITHOUT ANY WARRANTY; without even the implied warranty of
	* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	* GNU General Public License for more details.
	* 
	* You should have received a copy of the GNU General Public License
	* along with Mini-Framework.  If not, see <http://www.gnu.org/licenses/>.
*/
; End:License ;}

/*!
	Class: MfResourceManager
	Class for getting resources for errors and other string to the Mini-Framwork
	Inherits: MfObject
	Extra:
	The MfResourceManager class is not intended to be use by developer but rather by the Mini-Framwork.  
	Internal Sealed Class  
*/
class MfResourceManager extends MfObject
{
	m_CoreRes := Null
;{ 	Constructor
/*
	Method: Constructor()
		Constructor for MfResourceManager

	OutputVar := new MfResourceManager()
	OutputVar := new MfResourceManager(lang)

	Constructor()
		Creates a new instance of MfResourceManager

	Constructor(lang)
		Creates a new instance of MfResourceManager setting the language Local.
	Parameters:
		lang
			the language to load the resoure file of. Defaults to en_US
	Throws:
		Throws MfNotSupportedException is class is extended/inherited. Sealed Class.
*/
	__New(lang = "en-US") {
		base.__New()
		; Throws MfNotSupportedException if MfResourceManager Sealed class is extended
		if (this.__Class != "MfResourceManager") {
			throw new MfNotSupportedException("MfResourceManager is seal class!")
		}	
		this.m_ResourceAvailable := true
		result := this.SetResDir(lang)
		If (result)
		{
			this.m_ResourceAvailable := false
			this.m_ErrorMessage := result
		}
				
		this.m_isInherited := this.__Class != "MfResourceManager"
		
	}
; 	End:Constructor ;}
;{ 	Properties
;{ ErrorMessage
		m_ErrorMessage := ""
	/*!
		Property: ErrorMessage [get]
			Gets the ErrorMessage value associated with the this instance
		Value:
			Var representing the ErrorMessage property of the instance
		Remarks:
			Readonly Property
	*/
	ErrorMessage[]
	{
		get {
			return this.m_ErrorMessage
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, "ErrorMessage")
			Throw ex
		}
	}
; End:ErrorMessage ;}
;{ ResourceFolder
	m_ResourceFolder		:= Null
/*
	Property: ResourceFolder [get]
		Gets the current resource folder for Project Title
	Value:
		Var string
	Gets:
		Gets the current resource folder for Project Title as var string.
	Throws:
		Throws MfNotSupportedException if attempt is made to set value.
*/
	ResourceFolder[]
	{
		get {
			return this.m_ResourceFolder
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.Source := A_ThisFunc
			ex.File := A_LineFile
			ex.Line := A_LineNumber
			Throw ex
		}
	}
; End:ResourceFolder ;}
;{ ResourceAvailable
		m_ResourceAvailable := false
	/*!
		Property: ResourceAvailable [get]
			Gets the ResourceAvailable value associated with the this instance
		Value:
			Var representing the ResourceAvailable property of the instance
		Remarks:
			Readonly Property
	*/
	ResourceAvailable[]
	{
		get {
			return this.m_ResourceAvailable
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, "ResourceAvailable")
			Throw ex
		}
	}
; End:ResourceAvailable ;}
; 	End:Properties ;}

;{ 	SetResDir
	/*
		Method: SetResDir(lang)
			SetResDir() Attempts to load resources file for the given language
		Parameters:
			lang
				The language to load the resourece file for
		Throws:
			Throws MfSystemException if unable to locate a valid resourec file
		Remarks:
			Internal Method
	*/
	SetResDir(lang) {
		if (MfNull.IsNull(this.m_CoreRes)) {
			sFile := MfString.Format("MfResource_Core_{0}.dll", lang)
			
			strVersion := MfString.Format("{0:i}.{1:i}", MfInfo.Version.Major, MfInfo.Version.Minor)
			
			
			; start by looking for the Super Global MfResourceFolder. Give the script the Priority
			if (!MfString.IsNullOrEmpty(MfResourceFolder))
			{
				this.m_ResourceFolder := MfString.GetValue(MfResourceFolder)
				this.CoreRes := MfString.Format("{0}\MfResource_Core_{1}.dll", this.m_ResourceFolder, lang)
				if (FileExist(this.CoreRes)) {
					return false
				}
			}
			
			; start by looking the scripts folder. Give the script the second highest Priority
			this.m_ResourceFolder := MfString.Format("{0}\Lib\Mini_Framwork\{1}\System\Resource", A_ScriptDir, strVersion)
			this.CoreRes := MfString.Format("{0}\MfResource_Core_{1}.dll", this.m_ResourceFolder, lang)
			if (FileExist(this.CoreRes)) {
				return false
			}
			
			this.m_ResourceFolder := MfString.Format("{0}\Lib\System\Resource", A_ScriptDir)
			this.CoreRes := MfString.Format("{0}\MfResource_Core_{1}.dll", this.m_ResourceFolder, lang)
			if (FileExist(this.CoreRes)) {
				return false
			}
			; start by looking the scripts folder. Give the script the highest Priority
			this.m_ResourceFolder := MfString.Format("{0}\Lib\Resource", A_ScriptDir)
			this.CoreRes := MfString.Format("{0}\MfResource_Core_{1}.dll", this.m_ResourceFolder, lang)
			if (FileExist(this.CoreRes)) {
				return false
			}
			this.m_ResourceFolder := MfString.Format("{0}\Resource", A_ScriptDir)
			this.CoreRes := MfString.Format("{0}\MfResource_Core_{1}.dll", this.m_ResourceFolder, lang)
			if (FileExist(this.CoreRes)) {
				return false
			}
			this.m_ResourceFolder := MfString.Format("{0}\Resources", A_ScriptDir)
			this.CoreRes := MfString.Format("{0}\MfResource_Core_{1}.dll", this.m_ResourceFolder, lang)
			if (FileExist(this.CoreRes)) {
				return false
			}
			this.m_ResourceFolder :=  A_ScriptDir
			this.CoreRes := MfString.Format("{0}\MfResource_Core_{1}.dll", this.m_ResourceFolder, lang)
			if (FileExist(this.CoreRes)) {
				return false
			}
			
			; A_ProgramFiles will be "Program Files" on 32 bit machine
			; A_ProgramFiles will be "Program Files" on 64 bit machine running in 64 bit mode
			; A_ProgramFiles will be "Program File(x86)" on 64Bit machine runing in 32 bint mode
			this.m_ResourceFolder := MfString.Format("{0}\AutoHotkey\Lib\Mini_Framwork\{1}\System\Resource", A_ProgramFiles, strVersion)
			this.CoreRes := MfString.Format("{0}\MfResource_Core_{1}.dll", this.m_ResourceFolder, lang)
			if (FileExist(this.CoreRes)) {
				return false
			}
			if (A_Is64bitOS)
			{
				EnvGet, PFiles64, ProgramW6432
				this.m_ResourceFolder := MfString.Format("{0}\AutoHotkey\Lib\Mini_Framwork\{1}\System\Resource", PFiles64, strVersion)
				this.CoreRes := MfString.Format("{0}\MfResource_Core_{1}.dll", this.m_ResourceFolder, lang)
				if (FileExist(this.CoreRes)) {
					return false
				}
			}
			
			
			; next look in the installed Resource path from registry
			; this path usually matches the AutoHotkey install folder
			try
			{
				; do not use Mfunc.RegRead here because Mfunc.RegRead expects a valid resource file if there is a error
				_RootKey := "HKEY_LOCAL_MACHINE"
				_SubKey := "SOFTWARE\Mini-Framework\" . strVersion
				_ValueName := "ResDir"
				InstallPath := ""
				RegRead, InstallPath, %_RootKey%, %_SubKey%, %_ValueName%
				this.m_ResourceFolder :=  InstallPath
				this.CoreRes := MfString.Format("{0}\MfResource_Core_{1}.dll", this.m_ResourceFolder, lang)
				if (FileExist(this.CoreRes)) {
					return false
				}
			}
			catch e
			{
				; do nothing
			}	
			
			; try looking any install folder for AutoHotkey reported in the registry
			try
			{
				; do not use Mfunc.RegRead here because Mfunc.RegRead expects a valid resource file if there is a error
				_RootKey := "HKEY_LOCAL_MACHINE", _SubKey := "SOFTWARE\AutoHotkey", _ValueName := "InstallDir"
				RegRead, InstallPath, %_RootKey%, %_SubKey%, %_ValueName%
				this.m_ResourceFolder :=  MfString.Format("{0}\lib\Mini_Framwork\{1}\System\Resource", InstallPath, strVersion)
				this.CoreRes := MfString.Format("{0}\MfResource_Core_{1}.dll", this.m_ResourceFolder, lang)
				if (FileExist(this.CoreRes)) {
					return false
				}
			}
			catch e
			{
				; do nothing
			}
			
			this.m_ResourceFolder := MfString.Format("{0}\AutoHotkey\Lib\Mini_Framwork\{1}\System\Resource", A_MyDocuments, strVersion)
			this.CoreRes := MfString.Format("{0}\MfResource_Core_{1}.dll", this.m_ResourceFolder, lang)
			if (FileExist(this.CoreRes)) {
				return false
			}
			
			this.m_ResourceFolder := Null
			this.CoreRes := Null
			msg := "Unable to locate core Resource File.`nTry placing the core resource file (Resource_Core_{0}.dll) in a sub-folder"
			msg .= " named Resource for the current running script.`nExpected Resource\Resource_Core_{0}.dll"
			
			return MfString.Format(msg, lang)
		}
	}
; 	End:SetResDir ;}
	
;{ 	IsValidLanguageResource
/*
	Method: IsValidLanguageResource()

	OutPutVar := instance.IsValidLanguageResource(lang)

	IsValidLanguageResource()
		Test to see if a resource file can be found for a given language at predefined locations.
	Parameters:
		lang
			The language to check for such as "en-US"
	Returns:
		Returns true if the resource file if found otherwise false.
	Remarks:
		Static Method
		Valid Resource paths are in the following locations.
		There is an option to set a Super Global in your project that takes the highest priority for the location of Mini-Framework resources.
		See MfEnvironment.ResourceFolder for details.
		{Script Folder}\Lib\Mini_Framwork\0.3\System\Resource
		{Script Folder}\Lib\System\Resource
		{Script Folder}\Lib\Resource
		{Script Folder}\Lib\Resources
		{Script Folder}
		{Program Files}\AutoHotkey\Lib\Mini_Framwork\0.3\System\Resource
		Resource Path set by Mini-Framework installer usually the same as the previous line
		{Path set by AutoHotkey installer}\lib\Mini_Framwork\0.3\System\Resource
		{My Documents}\AutoHotkey\Lib\Mini_Framwork\0.3\System\Resource
		Resource file are named in the format of MfResource_Core_en-US.dll where en-US is Substituted for the language being checked for by the lang parameter
*/
	IsValidLanguageResource(lang) {
		
		strVersion := MfString.Format("{0:i}.{1:i}", MfInfo.Version.Major, MfInfo.Version.Minor)
		; start by looking for the Super Global MfResourceFolder. Give the script the Priority
		if (!MfString.IsNullOrEmpty(MfResourceFolder))
		{
			_MfResourceFolder := MfString.GetValue(MfResourceFolder)
			res := MfString.Format("{0}\MfResource_Core_{1}.dll", _MfResourceFolder, lang)
			if (FileExist(res)) {
				return
			}
		}
		
			; start by looking the scripts folder. Give the script the second highest Priority
		res := MfString.Format("{0}\Lib\Mini_Framwork\{1}\System\Resource\MfResource_Core_{2}.dll", A_ScriptDir, strVersion, lang)
		if (FileExist(res)) {
			return true
		}
		
		res := MfString.Format("{0}\Lib\System\Resource\MfResource_Core_{1}.dll", A_ScriptDir, lang)
		if (FileExist(res)) {
			return true
		}
		res := MfString.Format("{0}\Lib\Resource\MfResource_Core_{1}.dll", A_ScriptDir, lang)
		if (FileExist(res)) {
			return true
		}
		
		res := MfString.Format("{0}\Resource\MfResource_Core_{1}.dll", A_ScriptDir, lang)
		if (FileExist(res)) {
			return true
		}
		
		res := MfString.Format("{0}\Resources\MfResource_Core_{1}.dll", A_ScriptDir, lang)
		if (FileExist(res)) {
			return true
		}
		
		res :=  MfString.Format("{0}\MfResource_Core_{1}.dll", A_ScriptDir, lang)
		if (FileExist(res)) {
			return true
		}
		
		; A_ProgramFiles will be "Program Files" on 32 bit machine
		; A_ProgramFiles will be "Program Files" on 64 bit machine running in 64 bit mode
		; A_ProgramFiles will be "Program File(x86)" on 64Bit machine runing in 32 bint mode
		res := MfString.Format("{0}\AutoHotkey\Lib\Mini_Framwork\{1}\System\Resource\MfResource_Core_{2}.dll"
				, A_ProgramFiles, strVersion, lang)
		if (FileExist(res)) {
			return true
		}
		
		if (A_Is64bitOS)
		{
			EnvGet, PFiles64, ProgramW6432
			res := MfString.Format("{0}\AutoHotkey\Lib\Mini_Framwork\{1}\System\Resource\MfResource_Core_{2}.dll", PFiles64, strVersion, lang)
			if (FileExist(res)) {
				return
			}
		}
			; next look in the installed Resource path from registry
			; this path usually matches the AutoHotkey install folder
		try
		{
				; do not use Mfunc.RegRead here because Mfunc.RegRead expects a valid resource file if there is a error
			_RootKey := "HKEY_LOCAL_MACHINE"
			_SubKey := "SOFTWARE\Mini-Framework\" . strVersion
			_ValueName := "ResDir"
			RegRead, InstallPath, %_RootKey%, %_SubKey%, %_ValueName%
			res := MfString.Format("{0}\MfResource_Core_{1}.dll", InstallPath, lang)
			if (FileExist(res)) {
				return true
			}
		}
		catch e
		{
				; do nothing
		}
		
			; try looking any install folder for AutoHotkey reported in the registry
		try
		{
				; do not use Mfunc.RegRead here because Mfunc.RegRead expects a valid resource file if there is a error
			_RootKey := "HKEY_LOCAL_MACHINE", _SubKey := "SOFTWARE\AutoHotkey", _ValueName := "InstallDir"
			RegRead, InstallPath, %_RootKey%, %_SubKey%, %_ValueName%
			ResFolder :=  MfString.Format("{0}\lib\Mini_Framwork\{1}\System\Resource", InstallPath, strVersion)
			res := MfString.Format("{0}\MfResource_Core_{1}.dll", ResFolder, lang)
			if (FileExist(res)) {
				return true
			}
		}
		catch e
		{
				; do nothing
		}
		
		res := MfString.Format("{0}\AutoHotkey\Lib\Mini_Framwork\{1}\System\Resource\MfResource_Core_{2}.dll"
				,A_MyDocuments, strVersion, lang)
		if (FileExist(res)) {
			return true
		}
		return false
	}
; 	End:IsValidLanguageResource ;}
;{ 	GetResourceString
/*
	Method: GetResourceString()

	OutputVar := GetResourceString(key, Section)

	GetResourceString(key)
		Get a resoururce string from the resource file CORE section
	Returns:
		Returns a string var containing the resource string for key or "" if key is not found.

	GetResourceString(key, Section)
		Get a resource string from the resource file at the specified Section.
	Parameters:
		key
			the key of th ini file to read from in the resource file.
		Section
			the section of the ini file to read from in the resource file.
	Returns:
		Returns a string var containing the resource string from Section with key or "" if key is not found.
	Remarks:
		Not intended for use by developers but rather by the Mini-Framework.
		Getting resource strings is done by using MfEnvironment.Instance.GetResourceString("MyKey") and
		MfEnvironment.Instance.GetResourceStringBySection("MyKey", "someSection")
*/
	GetResourceString(key, Section="CORE") {
		if (this.m_ResourceAvailable = false)
		{
			return this.m_ErrorMessage
		}
		result := ""
		_coreRes := this.CoreRes
		result := Mfunc.IniRead(_coreRes, Section, key)
		if (result = "ERROR") {
			result := MfString.Empty
		}
		return result
	}
; 	End:GetResourceString ;}
}
/*!
	End of class
*/
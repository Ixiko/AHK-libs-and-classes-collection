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

/*
	Class: MfEnvironment
        Provides information about, and means to manipulate, the current environment and platform. This class cannot be inherited.
	Inherits:
        MfResourceSingletonBase
*/
class MfEnvironment extends MfResourceSingletonBase
{
	static _instance := "" ; Static var to contain the singleton instance
	m_Rm := Null
        
;{ Constructor
    /*!
        Function: Constructor()
            Constructor new instance of MfEnvironment class
        Throws:
            Throws MfNotSupportedException is class is extended
    */
	 __New() {
        ; Throws MfNotSupportedException if MfEnvironment Sealed class is extended
        if (this.__Class != "MfEnvironment") {
            throw new MfNotSupportedException("Error! Sealed Class!")
        }
        base.__New()
        this.m_isInherited := this.__Class != "MfEnvironment"
		if ((!MfNull.IsNull(LanguagePack)) && (MfResourceManager.IsValidLanguageResource(LanguagePack))) {
			this.m_Rm := new MfResourceManager(LanguagePack)
		} else {
			this.m_Rm := new MfResourceManager() 
		}
        if (this.m_rm.ResourceAvailable = false)
        {
            this.m_NewLine := "`r`n"
            ; was unable to locate valid resource file. set a few default for fail safe
        }
    }
; End:Constructor ;}
;{ 	DestroyInstance()
/*
	Method: DestroyInstance()
		Overrides MfResourceSingletonBase.DestroyInstance()
	MfEnvironment.DestroyInstance()
	
	DestroyInstance()
		Set current instance of MfEnvironment singleton class to null.
	Remarks
		Calling MfEnvironment.Instance will create the instance again.
*/
	DestroyInstance() {
		this.Reset()
	}
; End:DestroyInstance() ;}
;{ Reset
  /*
	Method: Reset()
	
	MfEnvironment.Instance.Reset()
	
	Reset()
		Resets the current Environment Instance so the the next call it is loaded again
	Remarks
		Useful if loading a new resource file of another language.
*/
    Reset() {
        MfEnvironment._instance := ""
    }
; End:Reset ;}
;{ GetResourceString
/*
    Method: GetResourceString()
    
    MfEnvironment.Instance.GetResourceString(key)
    MfEnvironment.Instance.GetResourceString(key, arg, arg2, ..., argN)
    
    GetResourceString(key)
        Gets a resource string from the internal resource file for the specified key.
    
    GetResourceString(key, arg, arg2, ..., argN)
        Gets a resource string from the internal resource file for the specified key. and formats the resource using the value(s) in args.
    
    Parameters
        key
            The key of the resource string to retrieve
        arg
            One or more arguments to format the resource string.
    Returns
        Var Containing string formated with any arg passed in.
*/
	GetResourceString(key , args*) {
        if (this.m_Rm.ResourceAvailable = false)
		{
			return this.m_Rm.ErrorMessage
		}
        if (MfString.IsNullOrEmpty(key))
        {
            return this.m_Rm.GetResourceString("ArgumentNull_ResourceKey")
        }
        if (!args.MaxIndex()) {
            return this.m_Rm.GetResourceString(key)
        }
		strRes := this.m_Rm.GetResourceString(key)
        if (MfString.IsNullOrEmpty(strRes)) {
            return MfString.Empty
        }
        return MfString.Format(strRes,args*)
        
	}
; End:GetResourceString ;}
;{ GetResourceStringBySection
/*
    Method: GetResourceStringBySection()

    OutputVar := MfEnvironment.Instance.GetResourceStringBySection(Key, section)
    OutputVar := MfEnvironment.Instance.GetResourceStringBySection(Key, section, arg, arg2, ..., argN)
    
    GetResourceStringBySection(Key, section)
        Gets a resource string from the current resource file with a key in a section
    
    GetResourceStringBySection(Key, section, arg, arg2, ..., argN)
        Gets a resource string from the current resource file with a key in a section, with format arg(s)
    
    Parameters
        key
            The key of the resource string
        section
            Section of resource to get string value from.
        arg
            One or more arguments to format the resource string.
*/
	GetResourceStringBySection(key, section, args*) {
        if (this.m_Rm.ResourceAvailable = false)
		{
			return this.m_Rm.ErrorMessage
		}
        if (!args.MaxIndex()) {
            return this.m_Rm.GetResourceString(key, section)
        }
        strRes := this.m_Rm.GetResourceString(key, section)
        if (MfString.IsNullOrEmpty(strRes)) {
            return MfString.Empty
        }
        return MfString.Format(strRes, args*)     
	}
; End:GetResourceString ;}
;{ GetInstance
/*
	Method: GetInstance()
		Overrides MfResourceSingletonBase.GetInstance()
	
	MfEnvironment.GetInstance()
	
	GetInstance()
		Gets the instance of the Singleton for MfEnvironment
	Returns
		Returns Singleton instance for the MfEnvironment class.
	Remarks
		Protected Method.
		Use Instance to access MfEnvironment.
*/
    GetInstance() { ; Overrides base
        if (MfNull.IsNull(MfEnvironment._instance)) {
            MfEnvironment._instance := new MfEnvironment()
        }
        return MfEnvironment._instance
    }
; End:GetInstance ;}
; Sealed Class Following methods cannot be overriden ; Do Not document for this class
; VerifyIsInstance([ClassName, LineFile, LineNumber, Source])
; VerifyIsNotInstance([MethodName, LineFile, LineNumber, Source])
; Sealed Class Following methods cannot be overriden
; VerifyReadOnly()
;{ MfObject Attribute Overrides - methods not used from MfObject - Do Not document for this class
;{  AddAttribute()
/*
    Method: AddAttribute()
    AddAttribute(attrib)
        Overrides MfObject.AddAttribute Sealed Class will never have attribute
    Parameters:
        attrib
            The object instance derived from MfAttribute to add.
    Throws:
        Throws MfNotSupportedException
*/
    AddAttribute(attrib) {
        ex := new MfNotSupportedException()
        ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
        throw ex        
    }
;   End:AddAttribute() ;}
;{  GetAttribute()
/*
    Method: GetAttribute()

    OutputVar := instance.GetAttribute(index)

    GetAttribute(index)
        Overrides MfObject.GetAttribute Sealed Class will never have attribute
    Parameters:
        index
            the zero-based index. Can be MfInteger or var containing Integer number.
    Throws:
        Throws MfNotSupportedException
*/
    GetAttribute(index) {
        ex := new MfNotSupportedException()
        ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
        throw ex
    }
;   End:GetAttribute() ;}
;   GetAttributes ;}
/*
    Method: GetAttributes()

    OutputVar := instance.GetAttributes()

    GetAttributes()
        Overrides MfObject.GetAttributes Sealed Class will never have attribute
    Throws:
        Throws MfNotSupportedException
*/
    GetAttributes() {
        ex := new MfNotSupportedException()
        ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
        throw ex
    }
;   End:GetAttributes ;}
;{  GetIndexOfAttribute()
/*
    GetIndexOfAttribute(attrib)
        Overrides MfObject.GetIndexOfAttribute. Sealed Class will never have attribute
    Parameters:
        attrib
            The object instance derived from MfAttribute.
    Throws:
        Throws MfNotSupportedException
*/
    GetIndexOfAttribute(attrib) {
        ex := new MfNotSupportedException()
        ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
        throw ex
    }
;   End:GetIndexOfAttribute() ;}
;{  HasAttribute()
/*
    HasAttribute(attrib)
        Overrides MfObject.HasAttribute. Sealed Class will never have attribute
    Parameters:
        attrib
            The object instance derived from MfAttribute.
    Throws:
        Throws MfNotSupportedException
*/
    HasAttribute(attrib) {
        ex := new MfNotSupportedException()
        ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
        throw ex
    }
;   End:HasAttribute() ;}
; End:MfObject Attribute Overrides ;}
;{ Properties
;{  ResourceFolder
/*
    Property: ResourceFolder [get]
        Gets the current resource folder for Project Title
        Readonly Propery
    Returns:
    	A var of string containing the path to the current resource folder
    Remarks:
        Readonly Property
		ResourceFolder is checked for in several locations and returns the first valid found location.
        The search locations are as follows
        There is an option to set a Super Global in your project that takes the highest priority for the location of Mini-Framework resources.
        To use the Super Global option set a Global var named MfResourceFolder and set it to the location of the resources.

		The search locations are as follows
        If Super Global MfResourceFolder is not set ( default ) or not found then resources search for the first found location in the following order
        {Script Folder}\Lib\Mini_Framwork\Project-Major-Minor\System\Resource
        {Script Folder}\Lib\System\Resource
        {Script Folder}\Lib\Resource
        {Script Folder}\Lib\Resources
        {Script Folder}
        {Program Files}\AutoHotkey\Lib\Mini_Framwork\Project-Major-Minor\System\Resource
        
        Resource Path set by Project Title installer usually the same as the previous line
        {Path set by AutoHotkey installer}\lib\Mini_Framwork\Project-Major-Minor\System\Resource
        {My Documents}\AutoHotkey\Lib\Mini_Framwork\Project-Major-Minor\System\Resource
    Throws:
        Throws MfNotSupportedException if attempt is made to set value.
*/
    ResourceFolder[]
    {
        get {
            return this.m_Rm.ResourceFolder
        }
        set {
            ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
            ex.Source := A_ThisFunc
            ex.File := A_LineFile
            ex.Line := A_LineNumber
            Throw ex
        }
    }
;   End:ResourceFolder ;}
;{  TickCount
/*
    Property: TickCount [get]
        Gets the number of milliseconds elapsed since the system started

    OutputVar := MfEnvironment.Instance.TickCount

    Value:
        Var Integer
    Gets:
        Gets the number of milliseconds elapsed since the system started as var integer.
    Throws:
        Throws MfNotSupportedException if attempt is made to set value.
    Remarks:
        Read-only Property
*/
    TickCount[]
    {
        get {
            return A_TickCount
        }
        set {
            ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
            ex.Source := A_ThisFunc
            ex.File := A_LineFile
            Throw ex
        }
    }
;   End:TickCount ;}
;{  NewLine
	m_NewLine := Null
/*
    Property: NewLine [get]
    
    OutputVar := MfEnvironment.Instance.NewLine
    
    Value:
        Var String
    Gets:
        Gets var string of the new line chars for the current environment.
    Throws:
        Throws MfNotSupportedException if attempt is made to set value.
    Remarks:
        Read-only Property
*/
    NewLine[]
    {
        get {
        	if (!MfNull.IsNull(this.m_NewLine)) {
        		 return this.m_NewLine
        	}
            try {
                strRes := this.m_Rm.GetResourceString("NewLine","SYSTEM") . ""
                strCh := new MfString(strRes)
                strList := strCh.Split("|",MfStringSplitOptions.Instance.RemoveEmptyEntries)
                if (strList.Count < 1) {
                    this.m_NewLine := "`r`n"
                } else {
                    _nl := MfString.Empty
                    i := 0
                    loop, % strList.Count
                    {
                        _nl .= chr(strList.Item[i].Value)
                        i++
                    }
                    this.m_NewLine := _nl
                }
            
            } catch e {
                ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc))
                ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
                throw ex
            }
            return this.m_NewLine
        }
        set {
            ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
            ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
            Throw ex
        }
    }
;   End:NewLine ;}
;{  UserAppDataLocal
	m_UserAppDataLocal := Null
/*
    Property: UserAppDataLocal [get]
        Gets the current users Local App Data Folder
    
    OutputVar := MfEnvironment.Instance.UserAppDataLocal
    Value:
        Var String
    Gets:
        Gets var string containing the value of the User App Data Local Folder
    Throws:
        Throws MfSystemException if unable to find a valid User App Local Data Folder.
        Throws MfNotSupportedException if attempt is made to set value.
    Remarks:
        Read-only Property
        Local App Data folder is usually C:\Users\USER\AppData\Local
*/
    UserAppDataLocal[]
    {
        get {
            if (MfNull.IsNull(this.m_UserAppDataLocal)) {
                _lad := Mfunc.RegRead("HKEY_CURRENT_USER","Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders", "Local AppData")
                if (!FileExist(_lad)) {
                    exAppData := new MfSystemException(MfEnvironment.Instance.GetResourceString("Exception_UserAppDataLocal"))
                    exAppData.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
                    throw exAppData
                }
                this.m_UserAppDataLocal := _lad
            }
            return this.m_UserAppDataLocal
        }
        set {
            ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
            ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
            Throw ex
        }
    }
;   End:UserAppDataLocal ;}
;{  UserAppDataRoaming
	m_UserAppDataRoaming := Null
/*
    Property: UserAppDataRoaming [get]
        Gets the current users Roaming App Data Folder
    
    OutputVar := MfEnvironment.Instance.UserAppDataRoaming
    
    Value:
        Var String
    Gets:
        Gets var string containing the value of the User App Data Roaming Folder
    Throws:
        Throws MfSystemException if unable to find a valid User Roaming App Data Folder.
        Throws MfNotSupportedException if attempt is made to set value.
    Remarks:
        Read-only Property
        Local Appdata folder is usually C:\Users\USER\AppData\Roaming
*/
    UserAppDataRoaming[]
    {
        get {
            if (MfNull.IsNull(this.m_UserAppDataRoaming)) {
                _lad := A_AppData
                if (!FileExist(_lad)) {
                    exAppData := new MfSystemException(MfEnvironment.Instance.GetResourceString("Exception_UserAppDataRoaming"))
                    exAppData.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
                    throw exAppData
                }
                this.m_UserAppDataRoaming := _lad
            }
            return this.m_UserAppDataRoaming
        }
        set {
            ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
            ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
            Throw ex
        }
    }
;   End:UserAppDataRoaming ;}
;{ 	UserDesktop
    m_UserDesktop := Null
/*
	Property: UserDesktop [get]
		Gets the current users Desktop Folder
	Returns:
		Returns string var containing the value of the User Desktop Folder
	Throws:
		Throws MfSystemException if unable to find a valid User Desktop Folder.
		Throws MfNotSupportedException if attempt is made to set value.
	Remarks:
		Readonly Property
*/
    UserDesktop[]
    {
        get {
            if (MfNull.IsNull(this.m_UserDesktop)) {
                _lad := A_Desktop
                if (!FileExist(_lad)) {
                    exAppData := new MfSystemException(MfEnvironment.Instance.GetResourceString("Exception_UserDesktopLocal"))
                    exAppData.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
                    throw exAppData
                }
                this.m_UserDesktop := _lad
            }
            return this.m_UserDesktop
        }
        set {
            ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
            ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
            Throw ex
        }
    }
; 	End:UserDesktop ;}
;{ UserDocuments
	m_UserDocuments := Null
/*
	Property: UserDocuments [get]
		Gets the current users Document Folder
	Returns:
		Returns string var containing the value of the User Documents Folder
	Throws:
		Throws MfSystemException if unable to find a valid User Desktop Folder.
		Throws MfNotSupportedException if attempt is made to set value.
	Remarks:
		Readonly Property
*/
    UserDocuments[]
    {
        get {
            if (MfNull.IsNull(this.m_UserDocuments)) {
                _lad := A_MyDocuments
                if (!FileExist(_lad)) {
                    exAppData := new MfSystemException(MfEnvironment.Instance.GetResourceString("Exception_UserDocumentsLocal"))
                    exAppData.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
                    throw exAppData
                }
                this.m_UserDocuments := _lad
            }
            return this.m_UserDocuments
        }
        set {
            ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
            ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
            Throw ex
        }
    }
; End:UserDocuments ;}
;{ 	UserPictures
     m_UserPictures := Null
/*
	Property: UserPictures [get]
		Gets the current users Picture Folder
	Returns:
		Returns string var containing the value of the User Pictures Folder
	Throws:
		Throws MfSystemException if unable to find a valid User Desktop Folder.
		Throws MfNotSupportedException if attempt is made to set value.
	Remarks:
		Readonly Property
*/     
     UserPictures[]
    {
        get {
            if (MfNull.IsNull(this.m_UserPictures)) {
                _rVar := Mfunc.RegRead("HKEY_CURRENT_USER","Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders", "My Pictures")
                if (!FileExist(_rVar)) {
                    exAppData := new MfSystemException(MfEnvironment.Instance.GetResourceString("Exception_UserPituresLocal"))
                    exAppData.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
                    throw exAppData
                }
                this.m_UserPictures := _rVar
            }
            return this.m_UserPictures
        }
        set {
            ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
            ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
            Throw ex
        }
    }
; 	End:UserPictures ;}
;{ 	UserFavorites
    m_UserFavorites := Null
/*
	Property: UserFavorites [get]
		Gets the current users Favourites Folder
	Returns:
		Returns string var containing the value of the User Favorites Folder
	Throws:
		Throws MfSystemException if unable to find a valid User Desktop Folder.
		Throws MfNotSupportedException if attempt is made to set value.
	Remarks:
		Readonly Property
*/ 
    UserFavorites[]
    {
        get {
            if (MfNull.IsNull(this.m_UserFavorites)) {
                _rVar := Mfunc.RegRead("HKEY_CURRENT_USER","Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders", "Favorites")
                if (!FileExist(_rVar)) {
                    exAppData := new MfSystemException(MfEnvironment.Instance.GetResourceString("Exception_UserFavoritesLocal"))
                    exAppData.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
                    throw exAppData
                }
                this.m_UserFavorites := _rVar
            }
            return this.m_UserFavorites
        }
        set {
            ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
            ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
            Throw ex
        }
    }
; 	End:UserFavorites ;}
;{ 	UserMusic
    m_UserMusic := Null
/*
	Property: UserMusic [get]
		Gets the current users Music Folder
	Returns:
		Returns string var containing the value of the User Music Folder
	Throws:
		Throws MfSystemException if unable to find a valid User Desktop Folder.
		Throws MfNotSupportedException if attempt is made to set value.
	Remarks:
		Readonly Property
*/ 
    UserMusic[]
    {
        get {
            if (MfNull.IsNull(this.m_UserMusic)) {
                _rVar := Mfunc.RegRead("HKEY_CURRENT_USER","Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders", "My Music")
                if (!FileExist(_rVar)) {
                    exAppData := new MfSystemException(MfEnvironment.Instance.GetResourceString("Exception_UserMusicLocal"))
                    exAppData.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
                    throw exAppData
                }
                this.m_UserMusic := _rVar
            }
            return this.m_UserMusic
        }
        set {
            ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
            ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
            Throw ex
        }
    }
; 	End:UserMusic ;}
;{ 	UserStartMenu
    m_UserStartMenu:= Null
/*
	Property: UserStartMenu [get]
		Gets the current users Start Menu Folder
	Returns:
		Returns string var containing the value of the User Start Menu Folder
	Throws:
		Throws MfSystemException if unable to find a valid User Desktop Folder.
		Throws MfNotSupportedException if attempt is made to set value.
	Remarks:
		Readonly Property
*/ 
    UserStartMenu[]
    {
        get {
            if (MfNull.IsNull(this.m_UserStartMenu)) {
                _lad := A_StartMenu
                if (!FileExist(_lad)) {
                    exAppData := new MfSystemException(MfEnvironment.Instance.GetResourceString("Exception_UserStartMenuLocal"))
                    exAppData.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
                    throw exAppData
                }
                this.m_UserStartMenu := _lad
            }
            return this.m_UserStartMenu
        }
        set {
            ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
            ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
            Throw ex
        }
    }
; 	End:UserStartMenu ;}
;{ 	UserStartup
    m_UserStartup := Null
/*
	Property: UserStartup [get]
		Gets the current users Startup Folder
	Returns:
		Returns string var containing the value of the User Startup Folder
	Throws:
		Throws MfSystemException if unable to find a valid User Desktop Folder.
		Throws MfNotSupportedException if attempt is made to set value.
	Remarks:
		Readonly Property
*/ 
    UserStartup[]
    {
        get {
            if (MfNull.IsNull(this.m_UserStartup)) {
                _lad := A_Startup
                if (!FileExist(_lad)) {
                    exAppData := new MfSystemException(MfEnvironment.Instance.GetResourceString("Exception_UserStartupLocal"))
                    exAppData.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
                    throw exAppData
                }
                this.m_UserStartup := _lad
            }
            return this.m_UserStartup
        }
        set {
            ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
            ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
            Throw ex
        }
    }
; 	End:UserStartup ;}
;{ 	UserVideo
    m_UserVideo := Null
/*
	Property: UserVideo [get]
		Gets the current users Video Folder
	Returns:
		Returns string var containing the value of the User Video Folder
	Throws:
		Throws MfSystemException if unable to find a valid User Desktop Folder.
		Throws MfNotSupportedException if attempt is made to set value.
	Remarks:
		Readonly Property
*/ 
    UserVideo[]
    {
        get {
            if (MfNull.IsNull(this.m_UserVideo)) {
                _rVar := Mfunc.RegRead("HKEY_CURRENT_USER","Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders", "My Video")
                if (!FileExist(_rVar)) {
                    exAppData := new MfSystemException(MfEnvironment.Instance.GetResourceString("Exception_UserVideoLocal"))
                    exAppData.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
                    throw exAppData
                }
                this.m_UserVideo := _rVar
            }
            return this.m_UserVideo
        }
        set {
            ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
            ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
            Throw ex
        }
    }
; 	End:UserVideo ;}
;{ CommonDesktop
	m_CommonDesktop := Null
/*
	Property: CommonDesktop [get]
		Gets the Common Desktop Folder
	Returns:
		Returns string var containing the value of the Common Desktop Folder
	Throws:
		Throws MfSystemException if unable to find a valid User Desktop Folder.
		Throws MfNotSupportedException if attempt is made to set value.
	Remarks:
		Readonly Property
*/ 
    CommonDesktop[]
    {
        get {
            if (MfNull.IsNull(this.m_UserDesktop)) {
                _lad := A_DesktopCommon
                if (!FileExist(_lad)) {
                    exAppData := new MfSystemException(MfEnvironment.Instance.GetResourceString("Exception_CommonDesktopLocal"))
                    exAppData.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
                    throw exAppData
                }
                this.m_CommonDesktop := _lad
            }
            return this.m_CommonDesktop
        }
        set {
            ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
            ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
            Throw ex
        }
    }
; End:CommonDesktop ;}
;{ 	CommonAppData
	m_CommonAppData := Null
/*
	Property: CommonAppData [get]
		Gets the Common App Data Folder
	Returns:
		Returns string var containing the value of the Common App Data Folder
	Throws:
		Throws MfSystemException if unable to find a valid User Desktop Folder.
		Throws MfNotSupportedException if attempt is made to set value.
	Remarks:
		Readonly Property
*/ 
    CommonAppData[]
    {
        get {
            if (MfNull.IsNull(this.m_CommonAppData)) {
                _rVar := Mfunc.RegRead("HKEY_LOCAL_MACHINE","SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders", "Common AppData")
                if (!FileExist(_rVar)) {
                    exAppData := new MfSystemException(MfEnvironment.Instance.GetResourceString("Exception_CommonAppDataLocal"))
                    exAppData.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
                    throw exAppData
                }
                this.m_CommonAppData := _rVar
            }
            return this.m_CommonAppData
        }
        set {
            ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
            ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
            Throw ex
        }
    }
; 	End:CommonAppData ;}
;{ 	CommonDocuments
	m_CommonDocuments := Null
/*
	Property: CommonDocuments [get]
		Gets the Common Documents Folder
	Returns:
		Returns string var containing the value of the Common Documents Folder
	Throws:
		Throws MfSystemException if unable to find a valid User Desktop Folder.
		Throws MfNotSupportedException if attempt is made to set value.
	Remarks:
		Readonly Property
*/ 
    CommonDocuments[]
    {
        get {
            if (MfNull.IsNull(this.m_CommonDocuments)) {
                _rVar := Mfunc.RegRead("HKEY_LOCAL_MACHINE","SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders", "Common Documents")
                if (!FileExist(_rVar)) {
                    exAppData := new MfSystemException(MfEnvironment.Instance.GetResourceString("Exception_CommonDocumentsLocal"))
                    exAppData.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
                    throw exAppData
                }
                this.m_CommonDocuments := _rVar
            }
            return this.m_CommonDocuments
        }
        set {
            ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
            ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
            Throw ex
        }
    }
; 	End:CommonDocuments ;}
;{ 	CommonPictures
    m_CommonPictures := Null
/*
	Property: CommonPictures [get]
		Gets the Common Pictures Folder
	Returns:
		Returns string var containing the value of the Common Pictures Folder
	Throws:
		Throws MfSystemException if unable to find a valid User Desktop Folder.
		Throws MfNotSupportedException if attempt is made to set value.
	Remarks:
		Readonly Property
*/ 
    CommonPictures[]
    {
        get {
            if (MfNull.IsNull(this.m_CommonPictures)) {
                _rVar := Mfunc.RegRead("HKEY_LOCAL_MACHINE","SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders", "CommonPictures")
                if (!FileExist(_rVar)) {
                    exAppData := new MfSystemException(MfEnvironment.Instance.GetResourceString("Exception_CommonPicturesLocal"))
                    exAppData.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
                    throw exAppData
                }
                this.m_CommonPictures := _rVar
            }
            return this.m_CommonPictures
        }
        set {
            ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
            ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
            Throw ex
        }
    }
; 	End:CommonPictures ;}
;{ 	CommonMusic
	m_CommonMusic := Null
/*
	Property: CommonMusic [get]
		Gets the Common Music Folder
	Returns:
		Returns string var containing the value of the Common Music Folder
	Throws:
		Throws MfSystemException if unable to find a valid User Desktop Folder.
		Throws MfNotSupportedException if attempt is made to set value.
	Remarks:
		Readonly Property
*/ 
    CommonMusic[]
    {
        get {
            if (MfNull.IsNull(this.m_CommonMusic)) {
                _rVar := Mfunc.RegRead("HKEY_LOCAL_MACHINE","SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders", "CommonMusic")
                if (!FileExist(_rVar)) {
                    exAppData := new MfSystemException(MfEnvironment.Instance.GetResourceString("Exception_CommonMusicLocal"))
                    exAppData.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
                    throw exAppData
                }
                this.m_CommonMusic := _rVar
            }
            return this.m_CommonMusic
        }
        set {
            ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
            ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
            Throw ex
        }
    }
; 	End:CommonMusic ;}
;{ 	CommonStartMenu
	m_CommonStartMenu:= Null
/*
	Property: CommonStartMenu [get]
		Gets the Common Start Menu Folder
	Returns:
		Returns string var containing the value of the Common Start Menu Folder
	Throws:
		Throws MfSystemException if unable to find a valid User Desktop Folder.
		Throws MfNotSupportedException if attempt is made to set value.
	Remarks:
		Readonly Property
*/
    CommonStartMenu[]
    {
        get {
            if (MfNull.IsNull(this.m_CommonStartMenu)) {
                _lad := A_StartMenuCommon
                if (!FileExist(_lad)) {
                    exAppData := new MfSystemException(MfEnvironment.Instance.GetResourceString("Exception_CommonStartMenuLocal"))
                    exAppData.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
                    throw exAppData
                }
                this.m_CommonStartMenu := _lad
            }
            return this.m_CommonStartMenu
        }
        set {
            ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
            ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
            Throw ex
        }
    }
; 	End:CommonStartMenu ;}
;{ 	CommonStartup
    m_CommonStartup := Null
/*
	Property: CommonStartup [get]
		Gets the Common Startup Folder
	Returns:
		Returns string var containing the value of the Common Startup Folder
	Throws:
		Throws MfSystemException if unable to find a valid User Desktop Folder.
		Throws MfNotSupportedException if attempt is made to set value.
	Remarks:
		Readonly Property
*/
    CommonStartup[]
    {
        get {
            if (MfNull.IsNull(this.m_CommonStartup)) {
                _lad := A_StartupCommon
                if (!FileExist(_lad)) {
                    exAppData := new MfSystemException(MfEnvironment.Instance.GetResourceString("Exception_CommonStartUpLocal"))
                    exAppData.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
                    throw exAppData
                }
                this.m_CommonStartup := _lad
            }
            return this.m_CommonStartup
        }
        set {
            ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
            ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
            Throw ex
        }
    }
; 	End:CommonStartup ;}
;{ 	CommonVideo
    m_CommonVideo := Null
/*
	Property: CommonVideo [get]
		Gets the Common Video Folder
	Returns:
		Returns string var containing the value of the Common Video Folder
	Throws:
		Throws MfSystemException if unable to find a valid User Desktop Folder.
		Throws MfNotSupportedException if attempt is made to set value.
	Remarks:
		Readonly Property
*/
    CommonVideo[]
    {
        get {
            if (MfNull.IsNull(this.m_CommonVideo)) {
                _rVar := Mfunc.RegRead("HKEY_LOCAL_MACHINE","SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders", "CommonVideo")
                if (!FileExist(_rVar)) {
                    exAppData := new MfSystemException(MfEnvironment.Instance.GetResourceString("Exception_CommonVideoUpLocal"))
                    exAppData.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
                    throw exAppData
                }
                this.m_CommonVideo := _rVar
            }
            return this.m_CommonVideo
        }
        set {
            ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
            ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
            Throw ex
        }
    }
; 	End:CommonVideo ;}
; End:Properties ;}
}
/*!
	End of class
*/
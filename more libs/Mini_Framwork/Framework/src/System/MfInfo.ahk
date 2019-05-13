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

;{ Class comments
/*!
	Class: MfInfo
		Contains information specifice to current Mini-framwork such as version
	Inherits: MfObject
*/
;	End:Class comments ;}
Class MfInfo extends MfObject
{
/*
	Property: Version [get]
		Gets the value of the current Mini-Framwork version as instance of MfVersion
	Value:
		Version property returns and instance of MfVersion
	Remarks:
		The MfVersion returned contains the current version of the Mini-Framework.
		The Current Version can be view by calling its ToString methood.
		For Example: MsgBox % MfInfo.Version.Tostring()
		Static Read-only Property
*/
	Static m_Version := ""
	Version[]
	{
		get {
			if (MfNull.IsNull(MfInfo.m_Version)) {
				MfInfo.m_Version := new MfVersion(0, 4, 0, 5)
			}
			return MfInfo.m_Version
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
	}
	/*!
		Constructor: ()
			Initializes a new instance of the MfInfo class.
		Remarks:
			It is not necessary to construct new instance of MfInfo class
			as MfInfo class contains static properties only
		Throws:
			Throws MfNotSupportedException if class instance is created
	*/
	__New() {
		throw new MfNotSupportedException(MfString.Format(MfEnvironment.Instance.GetResourceString("NotSupportedException_Static_Class"), "MfInfo"))
	}
;{ 	GetHelpFileLocation()
/*
	Method: GetHelpFileLocation()

	OutputVar := MfInfo.GetHelpFileLocation()

	GetHelpFileLocation()
		Gets the full path to Mini-Framework help file.
	Returns:
		Returns string var of full path to help file if it exist; Otherwise empty string is returned.
	Remarks:
		Static method.
		This method will only return a value if Mini-Framework is installed via the installer.
*/
	GetHelpFileLocation() {
		retval := ""
		try
		{
			ver := MfInfo.Version
			sRegKey := MfString.Format("SOFTWARE\Mini-Framework\{0:i}.{1:i}",ver.Major, ver.Minor)
			InstLocation := Mfunc.RegRead("HKEY_LOCAL_MACHINE", sRegKey, "HelpFile")
			IfExist, %InstLocation%
				retval := InstLocation
		}
		catch e
		{
			; do nothing
		}
		return retval
	}
; 	End:GetHelpFileLocation() ;}
;{ 	GetProgInstallLocation()
/*
	Method: GetProgInstallLocation()

	OutputVar := MfInfo.GetProgInstallLocation()

	GetProgInstallLocation()
		Gets the full path to Mini-Framework help file.
	Returns:
		Returns string var of full path to install location of main program if it exist; Otherwise empty string is returned.
	Remarks:
		Static method.
		This method will only return a value if Mini-Framework is installed via the installer.
*/
	GetProgInstallLocation() {
		retval := ""
		try
		{
			ver := MfInfo.Version
			sRegKey := MfString.Format("SOFTWARE\Mini-Framework\{0:i}.{1:i}",ver.Major, ver.Minor)
			InstLocation := Mfunc.RegRead("HKEY_LOCAL_MACHINE", sRegKey, "ProgramDir")
			IfExist, %InstLocation%
				retval := InstLocation
		}
		catch e
		{
			; do nothing
		}
		return retval
	}
; 	End:GetProgInstallLocation() ;}
}
/*!
	End of class
*/
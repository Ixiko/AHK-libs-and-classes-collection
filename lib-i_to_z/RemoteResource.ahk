/* < remoteResource() > (function)

	Version: 0.81
	Author: Simon Strålberg [sumon @ Autohotkey forums, simon . stralberg @ gmail . com]
	Autohotkey version: AHK_L (Unicode, x32)

	CHANGELOG:
	v.
		- 0.81: Added URLStatus() check (returns error if URL is invalid/file does not exist)
		- 0.8: Added HASHFile check, added cleanup

	REQUIREMENTS:
		- HashFile() by Deo, http://www.autohotkey.com/forum/viewtopic.php?t=71133
		- URLStatus() is included

	LICENSE: If no license documentation exists, [http]
	Script created using Autohotkey [http]

	LINK:
		https://autohotkey.com/board/topic/74719-function-remoteresource-for-images-etc/
*/

remoteResource(Resource, URL="", Directory="", TT="Display", MD5Sum="") { ; by sumon

	; First, a few aliases/standard values:
	static BaseURL ; Remembered between calls. HOWEVER, note that the file type is not automatically appended
	if ((Resource = "Load") or (Resource = "Init") or (Resource = "URL")) ; Used for cases where you want to set a base URL, f.ex. remoteResource("Load", "https://ahknet.autohotkey.com/~sumon/img")
	{
		BaseURL := URL
		return 1
	}

	If (!Directory)
	{
		SplitPath, Resource, , , Ext ; Extension
		If (RegExMatch(Ext, "doc|docx|html|odt|rtf|txt|pdf|html|htm"))
			Type := "Docs"
		else if (RegExMatch(Ext, "ani|bmp|cur|gif|ico|jpg|jpeg|jp2|png|raw|tga|tif|tiff"))
			Type := "Media\Images"
		else if (RegExMatch(Ext, "aiff|raw|wav|flac|wma|mp3|aac|swa|mid"))
			Type := "Media\Sounds"
		else if (RegExMatch(Ext, "ini"))
			Type := "Data"
		else
			Type := "Other"

		SplitPath, A_ScriptName,,,, ScriptName ; Removes extension
		Directory := A_AppData . "\" ScriptName . "\" . Type ; Store the data systematically
		If ((URL = "GetDir") or (URL = "Dir"))
			return A_AppData . "\" ScriptName ; A simple way to only retrieve the default directory
	}

	if (!InStr(URL, "." Ext))
		URL := BaseURL . Resource

	;
	If (MD5Sum)
	{
		If (HashFile(Directory . "\" . Resource) = MD5Sum) ; Check MD5 integrity of file
			return Directory . "\" . Resource
	}
	else if FileExist(Directory . "\" . Resource)
		return Directory . "\" . Resource ; Exists, return path
	else
	{
		If (URL)
		{
			If (!(URLStatus(URL) >= 200 AND URLStatus(URL) < 300)) ; If cannot connect
			{
				If (TT = "Display")
					Traytip,, Error: %URLStatus%... ,, 1
				Return URLStatus ; Error #, mostly 404
			}
			If (TT = "Display")
				Traytip,, Downloading %Resource%... ,, 1 ; Optional
			else if (TT)
				Traytip,, %TT%,, 1

			FileCreateDir, %Directory%
			UrlDownloadToFile, %URL%, %Directory%\%Resource%

			If (TT)
				TrayTip ; Clear message

			If (MD5Sum)
			{
				If (HashFile(Directory . "\" . Resource) != MD5Sum)
				{
					MsgBox, 48, Invalid resource, Warning! The file version (MD5) of %Resource% does not seem valid.
					return ; Return nothing
				}
			}

			return Directory . "\" . Resource ; File was downloaded
		}
		return 0 ; Couldn't download either
	}
} ; Returns: 0 if could not download, 2 if HashSum is wrong on both local & online version, 404 (or error status) if file does not exist

remoteResource_Clear(Directory="", Resource="") {

	If (Directory AND (Directory != A_Temp) AND (!Resource)) ; If directory is not A_Temp or AppData\ScriptName, confirm
	{
		MsgBox, 308, WARNING!, %Directory% and all its' files is about to deleted! Are you sure?
		IfMsgBox, No
			return 0
	}

	SplitPath, A_ScriptName,,,, ScriptName ; Removes extension
	Directory := (Directory)?(Directory):(A_AppData "\" ScriptName)
	Resource := (Resource)?(Resource):("All")
	If (Resource = "All")
	{
		MsgBox Removing %Directory%
		FileRemoveDir, %Directory%, 1
	}
	else
	{
		fDir := remoteResource(Resource, "Dir") ; Retrieves the default dir (AppData\ScriptName\MediaType\res.ext)
		return fDir
		If FileExist(fDir)
			FileDelete, %fDir%
	}

}

URLStatus(URL="") { ; By PEG & gamax92, http://www.autohotkey.com/forum/viewtopic.php?p=503855#503855
	http:=ComObjCreate("WinHttp.WinHttpRequest.5.1")
	http.open("GET", url, false)s
	http.send()
	return http.Status
}
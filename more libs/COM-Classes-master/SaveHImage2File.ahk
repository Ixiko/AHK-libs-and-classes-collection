/*
Function: SaveHImage2File
saves a HICON or HBITMAP to a file

Parameters:
	HANDLE hIcon - the HICON or HBITMAP handle to save
	STR file - the path to save the file to
	[opt] UINT type - defines whether the handle is a HICON (default) or a HBITMAP. You may use the fields of the PICTYPE class for convenience.

Returns:
	BOOL success - true on success, false otherwise.

Requirements:
	CCFramework, Unknown, Picture, SequentialStream, Stream, PICTDESC, PICTYPE, STREAM_SEEK

Remarks:
	- This function is a conversion + extension from the C++ code posted <here at http://www.autohotkey.com/forum/viewtopic.php?t=72481>.

Example:
	(start code)
	#include _CCF_Error_Handler_.ahk
	#include CCFramework.ahk
	#include Unknown\Unknown.ahk
	#include Picture\Picture.ahk
	#include SequentialStream\SequentialStream.ahk
	#include Stream\Stream.ahk
	#include Constant Classes\IDI.ahk
	#include Constant Classes\PICTYPE.ahk
	#include Structure Classes\StructBase.ahk
	#include Structure Classes\PICTDESC.ahk
	#include Constant Classes\STREAM_SEEK.ahk
	#include SaveHImage2File.ahk

	hIcon := DllCall("LoadIcon", "uptr", 0, "uint", IDI.HAND, "ptr") ; load a system icon
	result := SaveHImage2File(hIcon, A_Desktop "\test.ico") ; save the icon to a file
	MsgBox % "finished: " . (result ? "succeeded. The icon was saved to " A_Desktop "\test.ico" : "failed.") ; report to user
	return
	(end code)
*/
SaveHImage2File(handle, file, type := "~icon~")
{
	if (type == "~icon~")
		type := PICTYPE.ICON

	pd := new PICTDESC()
	pd.picType := type

	if (type == PICTYPE.ICON)
	{
		pd.icon.hIcon := handle
	}
	else if (type == PICTYPE.BITMAP)
	{
		pd.bmp.hbitmap := handle
	}

	pStrm := Stream.FromHGlobal(0)
	pPict := Picture.FromPICTDESC(pd)
	cbSize := pPict.SaveAsFile(pStrm, true)

	pStrm.Seek(0, STREAM_SEEK.SET)

	hFile := FileOpen(file, "w")

	if (hFile)
	{
		dwDone := 0, dwRead := 0, dwWritten := 0
		VarSetCapacity(buf, 4096, 0)
		while (dwDone < cbSize)
		{
			if (pStrm.Read(&buf, 4096, dwRead))
			{
				dwWritten := hFile.RawWrite(&buf, dwRead)

				if (dwWritten != dwRead)
					break
				dwDone += dwRead
			}
			else
				break
		}

		hFile.Close()
		ObjRelease(pStrm)
		ObjRelease(pPict)
		return dwDone == cbSize
	}
}
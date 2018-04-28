#SingleInstance, force
#Persistent

;dm := ComObjCreate("WIA.DeviceManager")
cd := ComObjCreate("WIA.CommonDialog")
d := Object()
;d := dm.DeviceInfos[1].Connect
;val := cd.ShowAcquisitionWizard(d) ;Very good
d := cd.ShowSelectDevice(0,true,false)
i := Object()
i := cd.ShowSelectItems(d,1,65536,true, true,false)
it := Object()
it := i.Item(1)
pages := 0
Loop,3
{
	pages ++
	imgFile := Object()
	try {
		imgFile := it.Transfer("{B96B3CAE-0728-11D3-9D7B-0000F81EF32E}")
	}
	catch e
	{
		error := e.message
		if error contains no documents
			break
		else
		{
			MsgBox, 5, Feeder Error,% error
			IfMsgBox, Cancel
				break
		}
	}
	filex = %A_Desktop%\%pages%.jpg
	FileDelete, % filex
	saveFile := imgFile.SaveFile(filex)
	if  saveFile !=
		MsgBox,0,There was an error,% safeFile	
}

;imgFile := Object()
;imgFile := cd.ShowAcquireImage(0,0,65536,"{B96B3CAE-0728-11D3-9D7B-0000F81EF32E}",false,true,false)
/*
ShowAcquireImage(
	0, ;UnspecifiedDeviceType = 0,ScannerDeviceType = 1;CameraDeviceType = 2;VideoDeviceType = 3
	0, ;VideoDeviceType = 0,ColorIntent = 1,GrayscaleIntent = 2,TextIntent = 4
	65536, ;MinimizeSize = 65536,MaximizeQuality= 131072
	"{B96B3CAE-0728-11D3-9D7B-0000F81EF32E}", ;wiaFormatBMP={B96B3CAB-0728-11D3-9D7B-0000F81EF32E},wiaFormatPNG={B96B3CAF-0728-11D3-9D7B-0000F81EF32E},wiaFormatGIF={B96B3CB0-0728-11D3-9D7B-0000F81EF32E},wiaFormatJPEG={B96B3CAE-0728-11D3-9D7B-0000F81EF32E}
	false, ;Boolean value that indicates whether to always show the select device dialog box.
	true, ;Boolean value that indicates whether to use the common UI.
	false ;Boolean value that indicates whether to generate an error if the user cancels the dialog box.
)
*/
/*
FileSelectFile,output,S,%a_desktop%,Select output file,JPEG (*.jpg)
if errorlevel
	ExitApp
if output=
	ExitApp
output := output ".jpg"
saveFile := imgFile.SaveFile(output)
if saveFile !=
{
	MsgBox There was an error %saveFile%
}
*/
MsgBox Complete!
ExitApp
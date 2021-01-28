; Without rRes (example)
#include %A_ScriptDir%\..\lib\RemoteResource.ahk

path := "data\img\"
If (!FileExist(path . "appifyerFrame.png"))
{
	FileCreateDir, %path%
	Traytip,, Downloading appifyerFrame.png... ,, 1
	UrlDownloadToFile, https://ahknet.autohotkey.com/~sumon/img/appifyerFrame.png, %path%\appifyerFrame.png
}
aFrame := path . "\appifyerFrame.png"

; With rRes

aFrame := remoteResource("appifyerFrame.png", "https://ahknet.autohotkey.com/~sumon/img/appifyerFrame.png")
; VLC Media Player HTTP Functions Library.
; Developed by Richard Wells, AHK handle Specter333. - fixed by szapp
;
; Most transport functions are one way, received by VLC.  They can be
; Called using only the function name.
; Example, VLCHTTP3_Pause() will toggle between pause and play.
;
; Some of the one way functions, such as VLCHTTP3_VolumeChange(Val) or
; VLCHTTP3_PlaylistAdd(path), require a parameter.
; Example, VLCHTTP3_VolumeUp(10) sets the volume 10% higher than it was.
;
; Functions that return data, such as VLCHTTP3_CurrentVol() or
; VLCHTTP3_PlaylistTracks(), use the normal syntax.
; Example, GetTrack:=VLCHTTP3_NowPlaying() puts the name
; of the currently playing track into the variable %GetTrack%.
;
; For demo scripts see the AHK forum post,
; http://www.autohotkey.com/forum/viewtopic.php?t=69150

; Last updated April 16, 2015 (szapp)
;
; EDIT (szapp): VLCHTTP2 -> VLCHTTP3
; Compatibility with password protection
; Thanks to  MJs from http://ahkscript.org/boards/viewtopic.php?p=33845&sid=0cef6b757b875b6ca9b27bc2f83ffc69#p33845

VLCHTTP3_Start(VLC_path, plist = "") ; Initialize and open VLC Media Player.
	{
	global VLC_Host, VLC_PassWord, VLC_PassWordB64, HttpRequest, VLC_33PID
	VLC_Host:="http://127.0.0.1:8080"
	VLC_PassWord:="0000" ; ":0000" encoded in Base64 "OjAwMDA="
	VLC_PassWordB64:="OjAwMDA=" ; ":0000" encoded in Base64 "OjAwMDA="
	VLC_COMMANDLINE := VLC_path " --extraintf http --http-host  " VLC_Host  " --http-password=" VLC_PassWord " " plist
	Run, %VLC_COMMANDLINE%, , UseErrorLevel, VLC_33PID
	If ErrorLevel
		Return, ErrorLevel
	HttpRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	Return, VLC_33PID
	}
VLCHTTP3_Close() ; Closes VLC Media Player.
	{
	global VLC_33PID, HttpRequest
	WinClose, ahk_pid %VLC_33PID%
	VLC_33PID := ""
	HttpRequest := ""
	}
VLCHTTP3_Exist() ; Checks whether VLC Media Player still running.
	{
	global VLC_33PID, HttpRequest
	If !VLC_33PID
		Return, 0
	IfWinNotExist, ahk_pid %VLC_33PID%
		VLC_33PID := "", HttpRequest := ""
	Return, VLC_33PID ? 1 : 0
	}
VLCHTTP3_Pause() ; Toggles Play/Pause of currently playing media.
	{
	; cmd = http://127.0.0.1:8080/?control=pause
	cmd = status.xml?command=pl_pause
	SendRequest(cmd)
	}
VLCHTTP3_Play() ; Play from currently select playlist item.
	{
	;cmd = http://127.0.0.1:8080/?control=play
	cmd = status.xml?command=pl_play
	SendRequest(cmd)
	}
VLCHTTP3_Stop() ; Stop media playback.
	{
	;cmd = http://127.0.0.1:8080/?control=stop
	cmd = status.xml?command=pl_stop
	SendRequest(cmd)
	}
VLCHTTP3_FullScreen() ; Toggle Full Screen
	{
	cmd = status.xml?command=fullscreen
	SendRequest(cmd)
	}

VLCHTTP3_PlayFaster(Val) ; Play Faster.
	{
	cmd = status.xml?command=rate&val=%Val%
	SendRequest(cmd)
	}
VLCHTTP3_NormalSpeed() ; Resume Normal Playback Speed.
	{
	cmd = status.xml?command=rate&val=1
	SendRequest(cmd)
	}
VLCHTTP3_PlaySlower(Val) ; Play Slower.
	{
	cmd = status.xml?command=rate&val=%Val%
	SendRequest(cmd)
	}
VLCHTTP3_Rate() ; Returns Current Play Rate.
	{
	Status := VLCHTTP3_Status()
	Loop, parse, Status, `n, `r
		{
		IfInString, A_LoopField, <rate>
			Rate = %A_LoopField%
		}
	CurrentRate := UnHTM(Rate)
	Return, %CurrentRate%
	}
VLCHTTP3_SetPos(Val) ; Set media playback to the specified second.
	{
	cmd = status.xml?command=seek&val=%Val%
	SendRequest(cmd)
	}
VLCHTTP3_JumpForward(Val) ; Skip ahead in media the specified value.
	{
	cmd = status.xml?command=seek&val=`%2B%Val%
	SendRequest(cmd)
	}
VLCHTTP3_JumpBackward(Val) ; Skip back in media the specified value.
	{
	cmd = status.xml?command=seek&val=-%Val%
	SendRequest(cmd)
	}
VLCHTTP3_VolumeUp(Val) ; Volume up relative, a value of 10 is typical
	{
	;depending or your settings range is either 1-512 or 1-1024
	cmd = status.xml?command=volume&val=`%2B%Val%
	SendRequest(cmd)
	}
VLCHTTP3_VolumeDown(Val) ; Volume down relative, a value of 10 is typical
	{
	;depending or your settings range is either 1-512 or 1-1024
	cmd = status.xml?command=volume&val=-%Val%
	SendRequest(cmd)
	}
VLCHTTP3_VolumeChange(Val) ; Sets volume to val,
	{
	;depending or your settings range is either 0-512 or 0-1024
	cmd = status.xml?command=volume&val=%Val%
	SendRequest(cmd)
	}
VLCHTTP3_ToggleMute(resetvol) ; Call with - MuteStatus:=VLCHTTP3_ToggleMute(MuteStatus)
; This does not invoke the mute button on VLC but remembers the current volume then set
; the volume to 0.  When called again it restores the previous volume.
	{
	Status := VLCHTTP3_Status()
	Loop, parse, Status, `n, `r
		{
		IfInString, A_LoopField, <volume>
			Volume = %A_LoopField%
		}
	CurrentVolume := UnHTM(Volume)

	If CurrentVolume = 0
		{
		cmd = status.xml?command=volume&val=%resetvol%
		SendRequest(cmd)
		Return
		}
	cmd =  status.xml?command=volume&val=0
	SendRequest(cmd)
	Return, %CurrentVolume%
	}
VLCHTTP3_CurrentVol() ; Retrieve current volume
	{
	Status := VLCHTTP3_Status()
	Loop, parse, Status, `n, `r
		{
		IfInString, A_LoopField, <volume>
			Volume = %A_LoopField%
		}
	CurrentVolume := UnHTM(Volume)
	Return, %CurrentVolume%
	}
VLCHTTP3_NowPlayingFilePath() ; Retrieves the filepath of the current media in VLC status.
	{
		Return, VLCHTTP3_PlayListFilePathID(VLCHTTP3_CurrentPlayListID())
	}
VLCHTTP3_NowPlaying() ; Retrieves the name of the current media in VLC status.
	{
	Status := VLCHTTP3_Status()
	Loop, parse, Status, `n, `r
		{
		IfInString, A_LoopField, <title>
			NowPlaying = %A_LoopField%
		}
	StringReplace, NowPlaying, NowPlaying, <![CDATA[, , A
	StringReplace, NowPlaying, NowPlaying, ]]>, , A
	NowPlaying := UnHTM(NowPlaying)
	Return, %NowPlaying%
	}
VLCHTTP3_GetFullscreen() ; Retrieve whether fullscreen is active.
	{
	Status := VLCHTTP3_Status()
	Loop, parse, Status, `n, `r
		{
		IfInString, A_LoopField, <fullscreen>
			fullscreen = %A_LoopField%
		}
	fullscreen := UnHTM(fullscreen)
	Return, ((Format("{:L}", fullscreen) = "true") ? 1 : 0)
	}
VLCHTTP3_Status() ;Get information on current playing media.
	{
	VLCStatus = status.xml
	Status := SendRequest(VLCStatus)
	Return, Status
	}
;;;;;;;;;;;;;;;;;;;;        Playlist Functions     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
VLCHTTP3_PlayList() ; Retrieve the playlist data.
	{
	VLCPlayList = playlist.xml
	OutFile := SendRequest(VLCPlayList)
	Return, %OutFile%
	}
VLCHTTP3_PlayListNext() ;Next item in the playlist
	{
	cmd = status.xml?command=pl_next
	SendRequest(cmd)
	}
VLCHTTP3_PlayListPrevious() ;Previous item in the playlist
	{
	cmd = status.xml?command=pl_previous
	SendRequest(cmd)
	}
VLCHTTP3_PlayListClear() ; Delete all items in the playlist
	{
	cmd = status.xml?command=pl_empty
	SendRequest(cmd)
	}
VLCHTTP3_PlayListRandom() ; Toggle (On, Off) random playback order
	{
	cmd = status.xml?command=pl_random
	SendRequest(cmd)
	}
VLCHTTP3_PlayListIsRandom() ; Returns 1 if random is on, 0 if not.
	{
	Status := VLCHTTP3_Status()
	Loop, parse, Status, `n, `r
		{
		IfInString, A_LoopField, <random>
			Random = %A_LoopField%
		}
	IsRandom := UnHTM(Random)
	Return, %IsRandom%
	}
VLCHTTP3_PlayListLoop() ; Toggle loop playback
	{
	cmd = status.xml?command=pl_loop
	SendRequest(cmd)
	}
VLCHTTP3_PlayListIsLoop() ; Returns 1 is loop is on, 0 if not.
	{
	Status := VLCHTTP3_Status()
	Loop, parse, Status, `n, `r
		{
		IfInString, A_LoopField, <loop>
			Loop = %A_LoopField%
		}
	IsLoop := UnHTM(Loop)
	Return, %IsLoop%
	}
VLCHTTP3_PlayListRepeat() ; Toggle between repeat 1 or repeat all when looping.
	{
	cmd = status.xml?command=pl_repeat
	SendRequest(cmd)
	}
VLCHTTP3_PlayListIsRepeat() ; Returns 0 for repeat all or 1 for repeat current media.
	{
	Status := VLCHTTP3_Status()
	Loop, parse, Status, `n, `r
		{
		IfInString, A_LoopField, <repeat>
			Repeat = %A_LoopField%
		}
	IsRepeat := UnHTM(Repeat)
	Return, %IsRepeat%
	}
VLCHTTP3_PlaylistPlayID(id) ; Play the entry coresponding the the Playlist id number.
	{
	cmd = status.xml?command=pl_play&id=%id%
	SendRequest(cmd)
	}
VLCHTTP3_PlaylistDeleteID(id)  ; Delete the entry coresponding the the Playlist id number.
	{
	cmd = status.xml?command=pl_delete&id=%id%
	SendRequest(cmd)
	}
VLCHTTP3_PlaylistTracks() ; Retrieve the title of all media in the playlist seperated with ¥.
	{
	AllTitles =
	cmd := VLCHTTP3_PlayList()
	StringReplace, cmd, cmd, <leaf, ¥, A
	StringReplace, cmd, cmd, ]]>, , A
	StringReplace, cmd, cmd, <![CDATA[, , A
	StringSplit, Section, cmd, ¥
	Loop, %Section0%
		{
		Sect := % Section%A_Index%
		Loop, parse, Sect, `n, `r
			{
			IfInString, A_LoopField, <title>
				title = %A_LoopField%
			StringReplace, title, title, <![CDATA[, , A
			StringReplace, title, title, ]]>, , A
			title := UnHTM(title)
			If AllTitles =
				ReturnTitle = %title%
			Else, ReturnTitle = ¥%title%

			}

		AllTitles = %AllTitles%%ReturnTitle%
		}
	Return, %AllTitles%
	}
VLCHTTP3_PlaylistArtist() ; Retrieve the artist of all media in the playlist seperated with ¥.
	{
	AllArtist=
	cmd := VLCHTTP3_PlayList()
	StringReplace, cmd, cmd, <leaf, ¥, A
	StringReplace, cmd, cmd, ]]>, , A
	StringReplace, cmd, cmd, <![CDATA[, , A
	StringSplit, Section, cmd, ¥
	Loop, %Section0%
		{
		Sect := % Section%A_Index%
		Loop, parse, Sect, `n,
			{
			IfInString, A_LoopField, <Artist>
				Artist = %A_LoopField%
			Artist := UnHTM(Artist)
			If AllArtist =
				ReturnArtist = %Artist%
			Else, ReturnArtist = ¥%Artist%
			}
		AllArtist = %AllArtist%%ReturnArtist%
		}
	Return, %AllArtist%
	}
VLCHTTP3_PlayListAlbum() ; Retrieve the album of all media in the playlist seperated with ¥.
	{
	AllAlbums =
	cmd := VLCHTTP3_PlayList()
		StringReplace, cmd, cmd, <leaf, ¥, A
	StringReplace, cmd, cmd, ]]>, , A
	StringReplace, cmd, cmd, <![CDATA[, , A
	StringSplit, Section, cmd, ¥
	Loop, %Section0%
		{
		Sect := % Section%A_Index%
		Loop, parse, Sect, `n, `r
			{
			IfInString, A_LoopField, <album>
				Album = %A_LoopField%
			Album := UnHTM(Album)
			If AllAlbums =
				ReturnAlbum = %Album%
			Else, ReturnAlbum = ¥%Album%
			}
		AllAlbums = %AllAlbums%%ReturnAlbum%

		}
	Return, %AllAlbums%
	}
VLCHTTP3_PlayListFilePathID(id) ; Get filepath by playlist ID
	{
	cmd := VLCHTTP3_PlayList()
	StringReplace, cmd, cmd, <leaf, %A_Space%¥, A
	StringReplace, cmd, cmd, ]]>, , A
	StringReplace, cmd, cmd, <![CDATA[, , A
	StringSplit, Section, cmd, ¥
	Loop, %Section0%
		{
		Sect := % Section%A_Index%
		Loop, parse, Sect, `n, `r
			{
			IfInString, A_LoopField, id="%id%"
				{
				If (pos := InStr(A_LoopField, " uri=""", 1))
				{
					URI := SubStr(A_LoopField, pos+6)
					StringSplit, URI, URI, "
					URI := uriDecode(StrReplace(StrReplace(UnHTM(URI1), "file:///"), "/", "\"))
				}
				Break
				}
			}
		}
	Return, %URI%
	}
VLCHTTP3_CurrentPlayListIDTESTPURPOSE() ; Gets playlist ID of currently playing item
	{
	cmd := VLCHTTP3_PlayList()
	StringReplace, cmd, cmd, <leaf, %A_Space%¥, A
	StringReplace, cmd, cmd, ]]>, , A
	StringReplace, cmd, cmd, <![CDATA[, , A
	StringSplit, Section, cmd, ¥
	Return %cmd%
	Loop, %Section0%
		{
		Sect := % Section%A_Index%
		Return, % Sect
		Loop, parse, Sect, `n, `r
			{
			IfInString, A_LoopField, current="current"
				{
				If (pos := InStr(A_LoopField, " id=""", 1))
				{
					ID := SubStr(A_LoopField, pos+5)
					StringSplit, ID, ID, "
					ID := UnHTM(ID1)
				} Else {
					Return, %A_LoopField%
				}
				Break
				}
			}
		}
	Return, %ID%
	}
VLCHTTP3_CurrentPlayListID() ; Gets playlist ID of currently playing item
	{
	cmd := VLCHTTP3_PlayList()
	StringReplace, cmd, cmd, <leaf, %A_Space%¥, A
	StringReplace, cmd, cmd, ]]>, , A
	StringReplace, cmd, cmd, <![CDATA[, , A
	StringSplit, Section, cmd, ¥
	Loop, %Section0%
		{
		Sect := % Section%A_Index%
		Loop, parse, Sect, `n, `r
			{
			IfInString, A_LoopField, current="current"
				{
				If (pos := InStr(A_LoopField, " id=""", 1))
				{
					ID := SubStr(A_LoopField, pos+5)
					StringSplit, ID, ID, "
					ID := UnHTM(ID1)
				}
				Break
				}
			}
		}
	Return, %ID%
	}
VLCHTTP3_PlayListID() ; Retrieve the playlist ID of all media in the playlist seperated with ¥.
	{ ; Use this ID to play or delete a playist item.
	AllIDs =
	cmd := VLCHTTP3_PlayList()
		StringReplace, cmd, cmd, <leaf, ¥ µ, A
	StringReplace, cmd, cmd, ]]>, , A
	StringReplace, cmd, cmd, <![CDATA[, , A
	StringSplit, Section, cmd, ¥
	Loop, %Section0%
		{
		Sect := % Section%A_Index%
		Loop, parse, Sect, `n, `r
			{
			IfInString, A_LoopField,  µ id=
				ID = %A_LoopField%
			StringSplit, ID, ID, "
			ID := UnHTM(ID2)
			If AllIDs =
				ReturnID = %ID%
			Else, ReturnID = ¥%ID%
			}
		AllIDs = %AllIDs%%ReturnID%

		}
	Return, %AllIDs%
	}
VLCHTTP3_PlaylistAdd(path) ; Add media to playlist.
	{
	StringReplace, path, path, \, /, All
	cmd = status.xml?command=in_enqueue&input=%path%
	SendRequest(cmd)
	Return, %path%
	}
VLCHTTP3_PlaylistAddPlay(path) ; Add media to playlist and play it.
	{
	StringReplace, path, path, \, /, All
	;cmd = status.xml?command=in_play&input=%path%
	cmd = status.xml?command=in_play&input=%path%
	SendRequest(cmd)
	Return, %path%
	}

;;; Sort functions seem to be disabled in latest version.  They are broken in VLC's HTML interface too.
VLCHTTP3_PlaylistSortID(order=0) ; Sort playlist by ID or how added, order = normal, order 1 = reverse.
	{
	cmd = status.xml?command=pl_sort&id=%order%&val=0
	SendRequest(cmd)
	}
VLCHTTP3_PlaylistSortName(order=0) ; Sort playlist by name, order = normal, order 1 = reverse.
	{
	cmd = status.xml?command=pl_sort&id=%order%&val=1
	SendRequest(cmd)
	}
VLCHTTP3_PlaylistSortAuthor(order=0) ; Sort playlist by author, order = normal, order 1 = reverse.
	{
	cmd = status.xml?command=pl_sort&id=%order%&val=3
	SendRequest(cmd)
	}
VLCHTTP3_PlaylistSortRandom(order=0) ; Sort playlist random, order = normal, order 1 = reverse.
	{
	cmd = status.xml?command=pl_sort&id=%order%&val=5
	SendRequest(cmd)
	}
VLCHTTP3_PlaylistSortTrackNum(order=0) ; Sort playlist by track number, order = normal, order 1 = reverse.
	{
	cmd = status.xml?command=pl_sort&id=%order%&val=7
	SendRequest(cmd)
	}

;;;;;; Service discovery modules, untested.
VLCHTTP3_Sap() ; Toggles sap service discovery module On/Off.
	{
	cmd = status.xml?command=pl_sd&val=sap
	SendRequest(cmd)
	}
VLCHTTP3_Shoutcast() ; Toggles shoutcast service discovery module On/Off.
	{
	cmd = status.xml?command=pl_sd&val=shoutcast
	SendRequest(cmd)
	}
VLCHTTP3_Podcast() ; Toggles podcast service discovery module On/Off.
	{
	cmd = status.xml?command=pl_sd&val=podcast
	SendRequest(cmd)
	}
VLCHTTP3_Hal() ; Toggles hal service discovery module On/Off.
	{
	cmd = status.xml?command=pl_sd&val=hal
	SendRequest(cmd)
	}
VLCHTTP3_ServMod(Mod) ; Toggles a custom service discovery module On/Off.
	{
	cmd = status.xml?command=pl_sd&val=%Mod%
	SendRequest(cmd)
	}

;;;;;;;;;;;;;;;;;;;;;;      Time Functions ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
VLCHTTP3_TimeUF() ;   Returns the elapsed time (unformated in seconds) of the currently playing item.
	{
	Status := VLCHTTP3_Status()
	Loop, parse, Status, `n, `r
		{
		IfInString, A_LoopField, <time>
			time = %A_LoopField%
		}
	NowTime := UnHTM(time)
	Return, %NowTime%
	}
VLCHTTP3_Time() ;   Returns the elapsed time of the currently playing item.
	{
	NowTime := FormatSeconds(VLCHTTP3_TimeUF())
	Return, %NowTime%
	}
VLCHTTP3_LengthUF() ;   Returns the total length (unformated in seconds) of the currently playing item.
	{
	Status := VLCHTTP3_Status()
	Loop, parse, Status, `n, `r
		{
		IfInString, A_LoopField, <length>
			length = %A_LoopField%
		}
	Duration := UnHTM(length)
	Return, %Duration%
	}
VLCHTTP3_Length() ;   Returns the total length of the currently playing item.
	{
	Duration := FormatSeconds(VLCHTTP3_LengthUF())
	Return, %Duration%
	}
VLCHTTP3_RemainingUT() ;   Returns the difference between "Time" and "Length" (unformated in seconds) of the currently playing item.
	{
	Remaining := VLCHTTP3_LengthUF()-VLCHTTP3_TimeUF()
	Return, %Remaining%
	}
VLCHTTP3_Remaining() ;   Returns the difference between "Time" and "Length" of the currently playing item.
	{
	Remaining := FormatSeconds(VLCHTTP3_RemainingUT())
	Return, %Remaining%
	}
VLCHTTP3_Position() ; Returns the percent played of the currently playing item.
	{
	Status := VLCHTTP3_Status()
	Loop, parse, Status, `n, `r
		{
		IfInString, A_LoopField, <position>
			cmd = %A_LoopField%
		}
	StringReplace, cmd, cmd, <![CDATA[, , A
	StringReplace, cmd, cmd, ]]>, , A
	cmd := UnHTM(cmd)
	Return, %cmd%
	}
VLCHTTP3_State() ;Returns the state player, Playing or Stopped.
	{
	Status := VLCHTTP3_Status()
	Loop, parse, Status, `n, `r
		{
		IfInString, A_LoopField, <state>
			cmd = %A_LoopField%
		}
	;StringReplace, cmd, cmd, <![CDATA[, , A
	;StringReplace, cmd, cmd, ]]>, , A
	cmd := UnHTM(cmd)
	Return, %cmd%
	}
;;;;;;;;;;;;;;;;;;;;;;  Video Size  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
VLCHTTP3_VidSize() ;   Returns the resolution of the currently playing item.
	{
	Status := VLCHTTP3_Status()
	Loop, parse, Status, `n, `r
		{
		IfInString, A_LoopField, Resolution
		Resolution = %A_LoopField%
		}
	VidRes := UnHTM(Resolution)
	Return, %VidRes%
	}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Format time from example in manual.
FormatSeconds(NumberOfSeconds)
   {
    time = 19990101
    time += %NumberOfSeconds%, seconds
    FormatTime, mmss, %time%, mm:ss
    return NumberOfSeconds//3600 ":" mmss
   }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  SendRequest
SendRequest(cmd) {
	global VLC_Host, VLC_PassWordB64, HttpRequest
	URL := VLC_Host  "/requests/" cmd ; command
	If !HttpRequest
		Return, -111
	Try { ; Prevent error dialog, if request fails
		HttpRequest.Open("GET", URL)
		HttpRequest.SetRequestHeader("Authorization", "Basic " VLC_PassWordB64)
		HttpRequest.Send()
		Return, HttpRequest.ResponseText
	} Catch e { ; Treat e? Naah
		Return, -111
	}
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  UrlDownloadToVar by olfen  (NOT USED ANY MORE IN VLCHTTP3)
; http://www.autohotkey.com/forum/viewtopic.php?p=64230#64230
UrlDownloadToVar(URL, Proxy="", ProxyBypass="") {
AutoTrim, Off
hModule := DllCall("LoadLibrary", "str", "wininet.dll")

If (Proxy != "")
AccessType=3
Else
AccessType=1
;INTERNET_OPEN_TYPE_PRECONFIG                    0   // use registry configuration
;INTERNET_OPEN_TYPE_DIRECT                       1   // direct to net
;INTERNET_OPEN_TYPE_PROXY                        3   // via named proxy
;INTERNET_OPEN_TYPE_PRECONFIG_WITH_NO_AUTOPROXY  4   // prevent using java/script/INS

io_hInternet := DllCall("wininet\InternetOpenA"
, "str", "" ;lpszAgent
, "uint", AccessType
, "str", Proxy
, "str", ProxyBypass
, "uint", 0) ;dwFlags

iou := DllCall("wininet\InternetOpenUrlA"
, "uint", io_hInternet
, "str", url
, "str", "" ;lpszHeaders
, "uint", 0 ;dwHeadersLength
, "uint", 0x80000000 ;dwFlags: INTERNET_FLAG_RELOAD = 0x80000000 // retrieve the original item
, "uint", 0) ;dwContext

If (ErrorLevel != 0 or iou = 0) {
DllCall("FreeLibrary", "uint", hModule)
return 0
}

VarSetCapacity(buffer, 512, 0)
VarSetCapacity(NumberOfBytesRead, 4, 0)
Loop
{
  irf := DllCall("wininet\InternetReadFile", "uint", iou, "uint", &buffer, "uint", 512, "uint", &NumberOfBytesRead)
  NOBR = 0
  Loop 4  ; Build the integer by adding up its bytes. - ExtractInteger
    NOBR += *(&NumberOfBytesRead + A_Index-1) << 8*(A_Index-1)
  IfEqual, NOBR, 0, break
  ;BytesReadTotal += NOBR
  DllCall("lstrcpy", "str", buffer, "uint", &buffer)
  res = %res%%buffer%
}
StringTrimRight, res, res, 2

DllCall("wininet\InternetCloseHandle",  "uint", iou)
DllCall("wininet\InternetCloseHandle",  "uint", io_hInternet)
DllCall("FreeLibrary", "uint", hModule)
AutoTrim, on
return, res
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; UnHTM by SKAN
; http://www.autohotkey.com/forum/viewtopic.php?p=312001#312001

 UnHTM( HTM ) {   ; Remove HTML formatting / Convert to ordinary text   by SKAN 19-Nov-2009
 Static HT,C=";" ; Forum Topic: www.autohotkey.com/forum/topic51342.html  Mod: 16-Sep-2010
 IfEqual,HT,,   SetEnv,HT, % "&aacuteá&acircâ&acute´&aeligæ&agraveà&amp&aringå&atildeã&au"
 . "mlä&bdquo„&brvbar¦&bull•&ccedilç&cedil¸&cent¢&circˆ&copy©&curren¤&dagger†&dagger‡&deg"
 . "°&divide÷&eacuteé&ecircê&egraveè&ethð&eumlë&euro€&fnofƒ&frac12½&frac14¼&frac34¾&gt>&h"
 . "ellip…&iacuteí&icircî&iexcl¡&igraveì&iquest¿&iumlï&laquo«&ldquo“&lsaquo‹&lsquo‘&lt<&m"
 . "acr¯&mdash—&microµ&middot·&nbsp &ndash–&not¬&ntildeñ&oacuteó&ocircô&oeligœ&ograveò&or"
 . "dfª&ordmº&oslashø&otildeõ&oumlö&para¶&permil‰&plusmn±&pound£&quot""&raquo»&rdquo”&reg"
 . "®&rsaquo›&rsquo’&sbquo‚&scaronš&sect§&shy &sup1¹&sup2²&sup3³&szligß&thornþ&tilde˜&tim"
 . "es×&trade™&uacuteú&ucircû&ugraveù&uml¨&uumlü&yacuteý&yen¥&yumlÿ"
 $ := RegExReplace( HTM,"<[^>]+>" )               ; Remove all tags between  "<" and ">"
 Loop, Parse, $, &`;                              ; Create a list of special characters
   L := "&" A_LoopField C, R .= (!(A_Index&1)) ? ( (!InStr(R,L,1)) ? L:"" ) : ""
 StringTrimRight, R, R, 1
 Loop, Parse, R , %C%                               ; Parse Special Characters
  If F := InStr( HT, L := A_LoopField )             ; Lookup HT Data
    StringReplace, $,$, %L%%C%, % SubStr( HT,F+StrLen(L), 1 ), All
  Else If ( SubStr( L,2,1)="#" )
    StringReplace, $, $, %L%%C%, % Chr(((SubStr(L,3,1)="x") ? "0" : "" ) SubStr(L,3)), All
Return RegExReplace( $, "(^\s*|\s*$)")            ; Remove leading/trailing white spaces
}
; uriDecode by garry
; http://www.autohotkey.com/board/topic/78948-convert- -etc-in-urls/?p=501368
uriDecode(str) {
   Loop
      If RegExMatch(str, "i)(?<=%)[\da-f]{1,2}", hex)
         StringReplace, str, str, `%%hex%, % Chr("0x" . hex), All
      Else Break
   Return, %str%
}

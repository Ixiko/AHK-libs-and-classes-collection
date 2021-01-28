FindClick(ImageFile="", Options="", ByRef FoundX="", ByRef FoundY="") ; updated February 17, 2017 ... https://autohotkey.com/boards/viewtopic.php?f=6&t=18719
{
	Static Cache
	, Center, Silent, Delim, Count, CharX, CharY, CharN, Sleep, Stay, Func, dx, d, m, x, y, o, n, k, r, e, a, w, t, f
	, ImageW, ImageH, LastX1, LastY1, ImageFilePath ; (xxx Does LastX/Y use the static ability?)
 	, LastOptions, LastImageFile, MonitorInfo, DxInfo
	, GuiHWND, GuiCommand, GuiTitle
	, Error, Message, Buttons, # := "`t", $ := "`r"
	GlobalSettingsLocation = %A_LineNumber%
	;||||||||||||||||||||||||||||||||||| Misc. Global Script Settings |||||||||||||||||||||||||||||||||||
	;----------------------------------------------------------------------------------------------------
	DefaultDirs = %A_Desktop%|%A_ScriptDir%|%A_Temp%                                                        ; Pipe (|) delimited list of default directories to search if file not found in working directory
	DefaultExts = png|bmp                                                                                   ; Pipe (|) delimited list of file extensions to try appending to %ImageFile% if it is still not found in %DefaultDirs%
	GuiA = 97                                                                                               ; Gui numbers to use for gui elements
	GuiB = 98                                                                                               ; (Two guis are needed)
	Literal := """"                                                                                         ; Character that is used to surround a string with spaces in the options parameter
	UseRGB = %False%                                                                                        ; All colors will be RGB if true and BGR if false. (BGR is what is used by window spy).
	ForumURL = https://autohotkey.com/boards/viewtopic.php?f=6&t=18719                                      ; Url of forum
	LastUpdate = February 17, 2017                                                                          ; Date of last update
	;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
	If (ImageFile <> "") and (Asc(ImageFile) <> 62) {
		If (LastImageFile <> ImageFile) or (Options <> LastOptions) {
			If (Asc(Cache) = 62)
				SpecialLaunch := SubStr(Cache, 2, 1), Cache := SubStr(Cache, 3)
			If (LastImageFile <> "")
				Cache := LastImageFile A_Tab ImageFilePath A_Tab ImageW "|" ImageH "|" LastX1 "|" LastY1 "`n" Cache, LastImageFile := ""
			If (SpecialLaunch <> 3) {
				DefaultOptionsLocation := A_LineNumber
				;||||||||||||||||||||||||||||||||||||||||| Default Options ||||||||||||||||||||||||||||||||||||||||||
				; Each letter or letters is a flag that corresponds to one of the settings of the function. By default, each setting takes the value assigned in the first column below. You may change settings by including that flag in the Options parameter of the function. In this case the passed option will take the value assigned in the 2nd column below. Indicate any other value with a string immediately following the corresponding flag. Separate each flag and string pairing with a space.
				;----------------------------------------------------------------------------------------------------
				; DEFAULT                 USER DEFAULT                NAME OF OPTION
				, o := "",                o_user := "*15"           ; ImageSearch Options
				, a := "",                a_user := "m100"          ; Search Area Modifications
				, r := "",                r_user := "A"             ; Relative to Window Coords
				, x := 0,                 x_user := "Abs"           ; X Offset
				, y := 0,                 y_user := "Abs"           ; Y Offset
				, n := 1,                 n_user := 0               ; Number of Clicks (No Click)
				, e := "",                e_user := 0.85            ; Find Every Image
				, w := "",                w_user := "0,100"         ; Wait Until Image Is Found
				, dx := "",               dx_user := "StartAt=#"    ; Diagnostic Mode
				, k := "{Click}",         k_user := "{RButton}"     ; Keystroke(s)
				, Stay := False,          Stay_user := True         ; Do Not Restore Mouse
				, Count := False,         Count_user := True        ; Return Found Count
				, d := "",                d_user := "MousePos"      ; Direction of Search
				, m := "Input",           m_user := "ControlClick"  ; SendMode
				, Sleep := 20,            Sleep_user := 0           ; Sleep Between Clicks
				, t := "",                t_user := "10%"           ; Image Tracking
				, Silent := False,        Silent_user := True       ; No Dialogs
				, Center := True,         Center_user := False      ; Start at Center of Image
				, Delim := "`n",          Delim_user := A_Tab       ; Delimiter for Multiple Images
				, f := "x,y",             f_user := "x y n"         ; Format of Output String
				, Func := "",             Func_user := ""           ; Function Callout
				, CharX := "x",           CharX_user := "x"         ; Character Spaceholder for X-Coord
				, CharY := "y",           CharY_user := "y"         ; Character Spaceholder for Y-Coord
				, CharN := "n",           CharN_user := "n"         ; Character Spaceholder for Image Instance Number
				;----------------------------------------------------------------------------------------------------
				; Change or add user configuration variables as you see fit. Call these with !, e.g. !foo
				UserConfig_foo = r"Test Window" mControlClick
				UserConfig_log = dx"SaveTo=%A_Desktop%\FindClickDebug.txt"
				;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
			}
			@5 := 1, TempOptions := Options, Commands := "Center|Silent|Delim|Count|CharX|CharY|CharN|Sleep|Stay|Func|Err|dx|d|m|x|y|o|n|k|r|e|a|w|t|f"
			If SpecialLaunch and (SpecialLaunch <> 4) {
				;|||||||||||||||||||||||||||||||||||||| Description of Options ||||||||||||||||||||||||||||||||||||||
				;----------------------------------------------------------------------------------------------------
				OptionInfo =
				(
				m               SendMode for keystrokes
				What to give    [Event|Play|Input|Default|ControlClick|First letter of any of these words]
				Description     The send mode (or first letter thereof) to use for clicks, i.e. Input, Play, or Event. Specify ControlClick (or c) to use a controlclick instead of a simulated keystroke. If m is blank or the letter d (for default), the current SendMode will be used.
				--------------------------------------------------------------------------------
				x               X Offset
				What to give    An integer
				Description     This many pixels will be incremented to the click coordinates before clicking. A positive x value will click left of the image, a negative value will click to the right. This change will also show up in the string that is returned by the function and the coordinates stored in the ByRef variables.
				--------------------------------------------------------------------------------
				y               Y Offset
				What to give    An integer
				Description     This many pixels will be incremented to the click coordinates before clicking. A positive y value will click below the image, and a negative value will click above it. This change will also show up in the string that is returned by the function and the coordinates stored in the ByRef variables.
				--------------------------------------------------------------------------------
				f               Format of output string
				What to give    Template string that includes the CharX and/or CharY and/or CharN characters.
				Description     The given string represents a template into which image x-coordinate, y-coordinate, and instance number will be substituted. Each time an image is found, the CharX, CharY, and CharN characters will be replaced with these values. The final string is returned by the function. See the examples section of the documentation for an example.
				--------------------------------------------------------------------------------
				Delim           Delimiter for multiple images
				What to give    Any character or characters
				Description     If e is used and multiple images are found then each image's info is separated by this character(s) in the returned string. The format of the image info is determined by f.
				--------------------------------------------------------------------------------
				Stay            Do not restore mouse
				What to give    True or False (1 or 0)
				Description     Normally after any clicks executed by FindClick the mouse will be immediately returned to its initial location. If Stay is true then the mouse will NOT return to its original position after FindClick finishes.
				--------------------------------------------------------------------------------
				o               ImageSearch Options
				What to give    Comma-delimited string of imagesearch options.
				Description     The imagesearch options are the Optional parameters for ImageSearch, as shown in documentation. Use a comma to separate options. You may omit the asterisk (*). For example: oTransBlack,20 makes black transparent and allows 20 shades of variation.
				--------------------------------------------------------------------------------
				n               Number of clicks
				What to give    Any number
				Description     The number of times to click on each image. Indicate 0 (the default) to do no clicking whatsoever and just return the coordinates of the found image(s). In this sense, specifying just n is like saying "no clicking". Without clicks, the m, d, and k options are irrelevant, however, the x and y values will still be added to the output coordinates.
				--------------------------------------------------------------------------------
				Sleep           Sleep milliseconds
				What to give    Any number of milliseconds
				Description     Number of milliseconds to sleep between each click if n > 1 or e and multiple images found.
				--------------------------------------------------------------------------------
				k               Keystroke(s)
				What to give    Key to send (in the same format as the AutoHotkey Send command)
				Description     Indicate the keys to press (if any) when each image is found. k can include multiple keypresses and even non-mouse keys, for instance, ^{Space}. If ControlClick is in effect the format is different (see the ControlClick documentation) and a left click will be assumed if an incorrect k is given.
				--------------------------------------------------------------------------------
				r               Relative to Window Coords
				What to give    Window Title criteria, or a window HWND
				Description     The search area becomes the area of the given window instead of the entire screen area. This is useful when scanning for an element which only appears on a particular window – reducing the search area improves performance. Use of the s option in conjunction with r will apply these offsets to the window coordinates.
				--------------------------------------------------------------------------------
				e               Find Every Image
				What to give    Positive fraction between 0 and 1
				Description     If this option is nonblank then FindClick will find (and click) EVERY instance found. This means that after any successful imagesearch execution the script will queue up a new call of imagesearch which represents the screen area left unsearched by the first call. (Note that this therefore makes FindClick slower for any use in which you don't expect to find more than one image.)
				                The value of e signifies the overlap between search areas, in terms of the fraction of the image width and height. Overlap should normally be near 1 except if the image is uniform throughout, e.g. a 10x10 square image containing mostly white pixels. The t, d, and Count options all require the "find every image" ehavior as part of their execution and so using any of these other options implies e, however, you may still specify a custom value for e to change the overlap for these other behaviors.
				--------------------------------------------------------------------------------
				a               Search Area Modifications
				What to give    x[,y,w,h] OR  mn
				Description     Region within which to search for the image. Indicate either of the following: 1) A comma-delimited list in the format x,y,w,h. List items may be blank or absent to leave that value unchanged. Coordinates are relative to the window if the a option is true. For w and h, use +/- to indicate a change to the normal endpoint (depending on a, either the edge of the screen or active window). For instance, s,,-300 will search the entire screen (or window if a is specified) except for the last 300 pixels of the right side – the width of the search area has been reduced by 300. 2) The letter m and then a number to search a square region centered at the cursor position and with a width and height twice that number.
				--------------------------------------------------------------------------------
				w               Wait until image is found
				What to give    Number of milliseconds [, Number of milliseconds]
				Description     If the image is not found, the function will wait this many milliseconds for it to appear before returning. You may add a comma and then a second number which indicates the delay in milliseconds between subsequent imagesearches. For example 2000,50 means the function will look for the image every 50ms until either the image is found or 2000ms elapse, for a maximum of 40 imagesearch operations. If omitted, this delay will be the smaller of either the wait time divided by 10 or 100ms.
				--------------------------------------------------------------------------------
				t               Image Tracking
				What to give    A percent OR a number of pixels
				Description     This option is used to improve performance if an image will be found nearby where its last location. By analogy it's like tracking the course of a thrown ball. The script will first search nearby the last found position and if it is not found there then the rest of the area will be searched. Indicate a percentage to search within that percentage of the search area in each direction – for instance, the string 20`% will first search a box that begins 20`% of the distance between the starting x position and the last found x position, and likewise for all four directions. On the other hand, indicating a number will simply search a box that many pixels from the last found area before searching the rest of the s area. Indicate 0 to search EXACTLY the last found location first. If t is negative (including -0) then it will ONLY search in the region requested, and will not go on to search the rest of the screen if the image is not found there.
				--------------------------------------------------------------------------------
				Silent          No Dialogs
				What to give	True or False
				Description     Instead of displaying an error dialog when an error prevents the function from executing properly (for instance, if the image file is not found), it will silently return a blank string and set the ErrorLevel to the error message. The errors concerned should not appear during normal execution and so Silent is generally not recommended.
				--------------------------------------------------------------------------------
				Count           Return found count
				What to give    True or False
				Description     If Count is true then the function will return the number of items found instead of their coordinates. e is assumed if absent.
				--------------------------------------------------------------------------------
				dx              Diagnostic Mode
				What to give    Comma delimited list of diagnostic mode options (see below)
				Description     Will illustrate where clicks take place with an on-screen display. Currently the comma-separated options aren't really working, sorry about that!
				--------------------------------------------------------------------------------
				Center          Start at center of image
				What to give    True or False (1 or 0)
				Description     If Center is true then clicks will occur at the center of the image, i.e. its found position plus half its width and half its height. The x and y options treat this as 0, 0 – for instance, by default an x of 2 will click 2 pixels to the right of the image center. Indicate false to instead start at the top left corner of the image.
				--------------------------------------------------------------------------------
				Func            Function Callout
				What to give    The name of a function in the script
				Description     Each time an image is found, instead of clicking on the image or executing keystrokes the given function will be called. The function must accept at least two parameters: the x-coordinate of the image will be passed in the first parameter, and the y-coordinate will be passed in the second parameter. Note that any thread settings such as CoordMode that are changed within the function will carry over to FindClick when the function is done.
				--------------------------------------------------------------------------------
				d               Direction Of Search
				What to give    Left|Right|Bottom
				Description     This setting attempts to emulate the mode of pixelsearch where you can search from right to left or top to bottom – for instance, specifying Bottom will find the image closest to the bottom of the search area. However, to accomplish this the script needs to first find every image and then choose the coordinate pair that is furthest in the requested direction, making it a time-consuming process.
				)
				;||||||||||||||||||||||||||||||||||||||||||| End Settings |||||||||||||||||||||||||||||||||||||||||||
				OptionInfo := RegExReplace(OptionInfo, "(?:`n|^)\K\s+"), OptionInfo := "`r" RegExReplace(OptionInfo, "\s*-{5,}\s*", "`r"), OptionInfo := RegExReplace(OptionInfo, "[ \t]{3,}|\t+", "`t")
				If (SpecialLaunch <> 3)
					Loop, Parse, Commands, |
						OptionInfo := RegExReplace(OptionInfo, "i)`r" A_LoopField "`t[^`n]+", "$0`nDefault`t" %A_ThisFunc%(">Escape<", %A_ThisFunc%(">ShowChars<", %A_LoopField%)) "`nUser Default`t" %A_ThisFunc%(">Escape<", %A_ThisFunc%(">ShowChars<", %A_LoopField%_user)))
				If SpecialLaunch in 2,3
					Return OptionInfo
				DllCall("QueryPerformanceCounter", "Int64*", QPC)
				, TempCommands := Commands, VarSetCapacity(DxInfo, 2500) ; xxx update size
				, DxInfo := A_TickCount A_Tab QPC "`r1:Initializing function" #
				. "q:" QPC #
				. "t:Function called at " A_Hour ":" A_Min ":" A_Sec "." A_MSec "`n`nThe following values were passed as parameters to the function:`n<table>ImageFile;%ImageFile%`nOptions;%Options%</table>`n`nThe following script settings were inherited from the current thread:`n<table>Thread Name;%A_ThisLabel%`nWorking Dir;%A_WorkingDir%`nBatch Lines;%A_BatchLines%`nTitle Match Mode;%A_TitleMatchMode%</table>" #
				. "c1:ImageFile:" %A_ThisFunc%(">Escape<", ImageFile) #
				. "c2:Options:" %A_ThisFunc%(">Escape<", Options) #
				. "c3:A_ThisLabel:" A_ThisLabel #
				. "c4:A_WorkingDir:" A_WorkingDir #
				. "c5:A_BatchLines:" A_BatchLines #
				. "c6:A_TitleMatchMode:" A_TitleMatchMode #
				. "l:" A_LineNumber - 1 #
			}
			If DxInfo
				DxInfo .= $ "2:Parsing options" #
				. "t:The information passed to " A_ThisFunc "() through the options parameter (2nd param) will now be parsed into individual script settings." #
				. "q:" DllCall("QueryPerformanceCounter", "Int64*", QPC) * QPC #
				. "l:" A_LineNumber + 1
			While (@5 := RegExMatch(TempOptions, "i)(?:^|\s)(?:!(\w+)|(\+|-)?(" Commands ")(" Literal "(?:[^" Literal "]|" Literal Literal ")*" Literal "(?= |$)|[^ ]*))", @, @5 + StrLen(@))) {
				If (@1 <> "") {
					TempOptions := SubStr(TempOptions, 1, @5 + StrLen(@)) A_Space UserConfig_%@1% SubStr(TempOptions, @5 + StrLen(@))
					If DxInfo
						DxInfo .= $ "2:Loading user configuration: !" @1 #
						. "l:" DefaultOptionsLocation + 1 #
						. "q:" DllCall("QueryPerformanceCounter", "Int64*", QPC) * QPC #
						. "c1:UserConfig:" @1 #
						. "c2:Options:" %A_ThisFunc%(">Escape<", TempOptions) #
						. "t:<table>User configuration;!%UserConfig%`nOptions string after modification;%Options%`n`nUser configurations can be found below the script options near the top of the code." #
				} Else If (@4 <> "") {
					If (InStr(@4, Literal) = 1) and (@4 <> Literal) and (SubStr(@4, 0, 1) = Literal) and (@4 := SubStr(@4, 2, -1))
						StringReplace, @4, @4, %Literal%%Literal%, %Literal%, All
					%@3% := @4
				} Else
					%@3% := @2 = "+" ? True : @2 = "-" ? False : %@3%_user
				If DxInfo {
					RegExMatch(OptionInfo, "i)`r" @3 "`t\K[^`n]+", @6)
					DxInfo .= $ "3:" @3 #
					. "q:" DllCall("QueryPerformanceCounter", "Int64*", QPC) * QPC #
					. "t:<table>Option ID;" @3 "`nDescription;" (@5 = "" ? "UNKNOWN!" : @6) "`nNew value;%" @3 "%`nAssign type;" (@4 = "" ? "User default</table>`n`nUser default means that the option was indicated without a value so the value defaulted to this string" : "Custom string</table>`n`nCustom string means the user put a string after the option ID, so it now takes that value.") #
					. "l:" A_LineNumber - 2 #
					. "c1:" @3 ":" %A_ThisFunc%(">Escape<", %@3%) #
					StringReplace, TempCommands, TempCommands, |%@3%|, |
				}
			}
			If (SpecialLaunch = 4)
				Return
			If (dx <> "")
				If DxInfo {
					@ := "t:The remaining script settings take the following default values:`n`n<table>"
					, DxInfo .= $ "2:Other script settings" #
					. "q:" DllCall("QueryPerformanceCounter", "Int64*", QPC) * QPC #
					. "l:" DefaultOptionsLocation + 1 #
					Loop, Parse, TempCommands, |
						If (A_LoopField <> "")
							DxInfo .= "c" A_Index ":" A_LoopField ":" %A_ThisFunc%(">Escape<", %A_LoopField%) #
							, @ .= A_LoopField ";%" A_LoopField "%`n"
					DxInfo .= @ "</table>"
				} Else {
					Cache := ">>" Cache
					Return %A_ThisFunc%(ImageFile, Options)
				}
			LastOptions := Options, @ := LastImageFile, LastImageFile := ImageFile
			If DxInfo
				DxInfo .= $ "1:Preparing Image File" #
				. "q:" DllCall("QueryPerformanceCounter", "Int64*", QPC) * QPC #
				. "t:The image file that was specified for use with imagesearch must now be located on the hard drive, and its size must be measured." #
				. "l:" A_LineNumber + 1
			If !(((ImageFile = @) and FileExist(ImageFilePath)) or %A_ThisFunc%(">ParseCache<", ImageFile)) {
				NewImage := True, ImageFilePath := ""
				If RegExMatch(ImageFile, "i)^\*(?:0x)?([0-9A-F]{2})([0-9A-F]{2})([0-9A-F]{2})(?:\D*(\d+)\D*(\d+).*?)?$", @) {
					ImageW := @4 ? @4 : 1, ImageH := @5 ? @5 : 1, Color := UseRGB ? @1 @2 @3 : @3 @2 @1
					If DxInfo
						DxInfo .= $ "2:PixelSearch Set" #
						. "q:" DllCall("QueryPerformanceCounter", "Int64*", QPC) * QPC #
						. "t:The ImageFile parameter was recognized as a pixel color so the function will search for pixels of this color. The mechanism for this search however will remain ImageSearch.`n`n<table>Color;%Color%`nColor is RGB;%UseRGB%`nRegion Width;%ImageW%`nRegion Height;%ImageH%</table>" #
						. "l:" A_LineNumber - 2 #
						. "c1:Color:" Color #
						. "c2:UseRGB:" UseRGB #
						. "c3:ImageW:" ImageW #
						. "c4:ImageH:" ImageH
					If !FileExist(ImageFilePath := A_Temp "\" A_ThisFunc "_" Color "_" ImageW "x" ImageH ".png") {
						If DxInfo
							DxInfo .= $ "2:Building image of color #" Color #
							. "q:" DllCall("QueryPerformanceCounter", "Int64*", QPC) * QPC #
							. "c1:A_Temp:" A_Temp #
							. "l:" A_LineNumber - 2 #
							. "t:A temporary png image will be created of the color specified. This is relatively time-consuming but only need be done once as long as the png file remains in the temporary folder.`n`nWindows Temp Dir: %A_Temp%"
						VarSetCapacity(Colors, ImageW * ImageH * 7)
						Loop % ImageW * ImageH
							Colors .= "|" Color
						@6 := %A_ThisFunc%(">MakeImage<", "" A_Temp "\" A_ThisFunc "_" Color "_" ImageW "x" ImageH "|png|" ImageW "|" ImageH Colors)
						If DxInfo and (@6 > 1)
							DxInfo .= "`n`nProcess required " @6 " tries to succeed (due to a bug in either the GDI+ code or my code.)"
					}
				} Else {
					DefaultDirs := SubStr(RegExReplace(DefaultDirs "|", "\\*(?:\||^)+", Asc(ImageFile) = 92 ? "|" : "\|"), 2, -1), DefaultExts := SubStr(RegExReplace("|" DefaultExts "|", "\|\.*", "|."), 1, -2)
					If DxInfo
						DxInfo .= $ "2:ImageFile not seen before" #
						. "q:" DllCall("QueryPerformanceCounter", "Int64*", QPC) * QPC #
						. "t:Image file """ ImageFile """ has not been seen before by the function so it will now look through the default locations to find the full image path." #
						. "l:" GlobalSettingsLocation + 1 #
						. "d:2"
					Loop, Parse, DefaultDirs, |
					{
						ThisDir := A_LoopField
						If DxInfo
							DxInfo .= $ "3:" (A_Index = 1 ? "(Working Dir)" : SubStr(ThisDir, 1, -1)) #
							. "q:" DllCall("QueryPerformanceCounter", "Int64*", QPC) * QPC #
							. "t:Directory #" A_Index " is:`n`n%ThisDir%`n`n(This can be specified at the top of the script in DefaultDirs.)" #
							. "c1:ThisDir:" %A_ThisFunc%(">Escape<", ThisDir)
						Loop, Parse, DefaultExts, |
							If FileExist(ThisDir ImageFile A_LoopField) {
								If InStr(FileExist(ImageFilePath := ThisDir ImageFile A_LoopField), "D")
									ImageFilePath := ""
								Else
									Break
							} Else If DxInfo
								DxInfo .= $ "4:" ImageFile A_LoopField #
								. "q:" DllCall("QueryPerformanceCounter", "Int64*", QPC) * QPC #
								. "t:Trying file path:`n`n%ImageFilePath%`n`nFile does not exist." #
								. "c1:ImageFilePath:" %A_ThisFunc%(">Escape<", ThisDir ImageFile A_LoopField) #
								. "d:1" #
								. "l:" A_LineNumber - 6
						If (ImageFilePath <> "")
							Break
					}
					If (ImageFilePath = "") {
						Error = File Not Found
						Message = Image file "%ImageFile%" not found.
						Buttons = &Create Image,&Debug,E&xit,&Help
						If (%A_ThisFunc%(">Error<") = "Create Image")
							%A_ThisFunc%(">>" ImageFile, Options)
						Return
					} Else If DxInfo
						DxInfo .= $ "4:Image file found" #
						. "q:" DllCall("QueryPerformanceCounter", "Int64*", QPC) * QPC #
						. "t:Trying file path:`n`n%ImageFilePath%`n`nImage file found!" #
						. "c1:ImageFilePath:" %A_ThisFunc%(">Escape<", ImageFilePath) #
						. "l:" A_LineNumber - 10 #
						. "d:1"
					If !%A_ThisFunc%(">ParseCache<", ImageFilePath) {
						If DxInfo
							DxInfo .= $ "2:Image Preview - Measuring width and height" #
							. "q:" DllCall("QueryPerformanceCounter", "Int64*", QPC) * QPC #
							. "t:The image dimensions will be measured by quickly creating an AutoHotkey GUI containing the image. This is a relatively CPU-intensive step but only need be done once per session - the information is stored in the cache for future calls with the same image.`n`n<table>Image Width;%ImageW%`nImage Height;%ImageH%</table>" #
						Gui, %GuiA%:Add, Picture, Hwnd@, %ImageFilePath%
						WinGetPos, , , ImageW, ImageH, ahk_id %@%
						Gui, %GuiA%:Destroy
						If (ImageW = "") {
							Error = Image file type unsupported
							Message = Image file "%ImageFile%" appears to be of an unsupported filetype.
							Buttons = &View File,&Debug,E&xit,&Help
							If (%A_ThisFunc%(">Error<") = "View File")
								MsgBox, 262160, %A_ScriptName%: Error, Function not yet supported, sorry! ; xxx
							Return
						}
						If DxInfo
							DxInfo .= "g:Add,Edit,+ReadOnly -VScroll w" (ImageW > 20 ? ImageW * 15 : 300) "," ImageFilePath ";-E0x20 +Caption +SysMenu;Add,Picture,+Border xp" (ImageW > 20 ? "" : "+" 150 - ImageW * 7.5) " y+10 w" ImageW * 15 " h-1," ImageFilePath ";Show,NA,Preview of image" #
							. "c1:ImageW:" %A_ThisFunc%(">Escape<", ImageW) #
							. "c2:ImageH:" %A_ThisFunc%(">Escape<", ImageH) #
							. "l:" A_LineNumber - 7 #
							. "d:5"
					}
				}
			}
			If (o <> "") {
				If DxInfo
					@ := o
				o := SubStr(RegExReplace(A_Space o, "[^\w-]+", " *"), 2) A_Space
				If DxInfo and (o <> @ A_Space)
					DxInfo .= $ "2:Refining imagesearch options" #
					. "t:The ImageSearch options (""o"" option) have been modified to fit the AutoHotkey ImageSearch command's format.`n`n<table>Given;%o_original%`nNow;%o%</table>" #
					. "l:" A_LineNumber - 2 #
					. "q:" DllCall("QueryPerformanceCounter", "Int64*", QPC) * QPC #
					. "c1:o:" %A_ThisFunc%(">Escape<", SubStr(o, 1, -1)) #
					. "c2:o_original:" %A_ThisFunc%(">Escape<", @) #
			}
			If (Func <> "") {
				StringReplace, Func, Func, ()
				If !IsFunc(Func)
					MsgBox, 262160, %A_ScriptName%: Error, Function %Func%() does not exist. ;xxx
				Else
					n := 0
			}
			If (r <> "") and RegExMatch(r, "i)^0x[0-9A-F]{5,8}$") {
				r := "ahk_id " r
				If DxInfo
					DxInfo .= $ "2:Refining WinTitle option" #
					. "t:The ""r"" option (relative to window) is a hexadecimal number, so it will be interpreted as a window handle and becomes ""%r%""." #
					. "l:" A_LineNumber - 2 #
					. "q:" DllCall("QueryPerformanceCounter", "Int64*", QPC) * QPC #
					. "c1:r:" %A_ThisFunc%(">Escape<", r) #
			}
			If d
				If (InStr(d, "t") = 1) or (InStr(d, "u") = 1) {
					If DxInfo
						DxInfo .= $ "2:Ignoring d option" #
						. "t:The ""d"" (directional) option was given as ""%d%"" which will be ignored since the top image is the one that ImageSearch finds by default." #
						. "c1:d:" d #
						. "l:" A_LineNumber + 1 #
						. "q:" DllCall("QueryPerformanceCounter", "Int648", QPC) * QPC #
					d := ""
				} Else
					StringLower, d, d
			If (e = "") {
				If Count or d
					e := e_user
				Else If (t <> "")
					e := 0.99
				If DxInfo and (e <> "")
					DxInfo .= $ "2:Overlap set to " e #
					. "t:Because an option that requires every image to be found was indicated (either ""t"", ""d"", or ""Count""), and because a custom value of ""e"" was not given, it defaults to %e%." #
					. "c1:e:" e #
			}
			If (InStr(m, "c") = 1) {
				If DxInfo
					@ := k
				If k Contains RButton
					k = Right
				Else If k Not In Left,Right,Middle,L,R,M,X1,X2,WheelUp,WU,WheelDown,WD,WheelLeft,WL,WheelRight,WR
					k = Left
				If DxInfo and (@ <> k)
					DxInfo .= $ "2;Correcting k option" #
					. "t:The ""k"" (keystrokes) option was given as ""%@%"" but has been corrected to ""%k%"" because ControlClick was indicated for the ""m"" (SendMode) option, and ControlClick has a different format than the Send command." #
					. "c1:k:" k #
			}
		} Else { ; xxx fix this part
			If dx
				Cache := ">3" Cache, OptionInfo := %A_ThisFunc%(A_Space), TempCommands := Commands, DxStartMS := A_TickCount, VarSetCapacity(DxInfo, 2500)
				, DxInfo .= "1:Initializing function" #
				. "q:" DllCall("QueryPerformanceCounter", "Int64*", QPC) * QPC #
				. "t:Called at " A_Now #
				. "l:" A_LineNumber - 1
				, DxStartQPC := QPC
			If DxInfo
				DxInfo .= $ "2:Restoring previous settings" #
				. "q:" DllCall("QueryPerformanceCounter", "Int64*", QPC) * QPC #
				. "t:The passed image file and options string is the same as the last time " A_ThisFunc "() was called. The script options have been preserved as static variables and are therefore not parsed. This helps with performance in the case of multiple consecutive searches for the same image. Reload the script to avoid this behavior."
		}
		If DxInfo
			DxInfo .= $ "1:Preparing other script settings" #
			. "q:" DllCall("QueryPerformanceCounter", "Int64*", QPC) * QPC #
			. "t:If additional options were specified, " A_ThisFunc "() may need to prepare certain settings relevant to these options before performing the imagesearch." #
			. "l:" A_LineNumber
		SysGet, MonitorCount, MonitorCount
		If (MonitorCount <> SubStr(MonitorInfo, 1, InStr(MonitorInfo, "`n") - 1)) {
			MonitorInfo := MonitorCount
			Loop %MonitorCount% {
				SysGet, @, Monitor, %A_Index%
				MonitorInfo .= "`n" @Left "," @Top ";" @Right - 1 "," @Bottom - 1
			}
		}
		CoordMode, Pixel
		CoordMode, Mouse
		If (r <> "") {
			WinGetPos, Search1, Search2, Search3, Search4, %r%
			If (Search1 = "") or (Search3 <= 0) or (Search4 <= 0) {
				If (Search1 = "") {
					Error = Window Not Found
					Message = Window "%r%" was not found. ; xxx
				} Else {
					Error = Window Invisible
					Message = Window "%r%" reported a negative width and/or height to AutoHotkey, meaning that it is probably not visible on the screen.
				}
				Buttons = &Debug,E&xit,&Help
				%A_ThisFunc%(">Error<")
				Return
			} Else If DxInfo
				DxInfo .= $ "2:Window """ r """ found" #
				. "t:The ""r"" param was given as:`n" r "`n`nThis window was found at the following coordinates:`n<table>X;" Search1 "`nY;" Search2 "`nW;" Search3 "`nH;" Search4 "</table>`n`nThis is the new search area." #
				. "l:" A_LineNumber - 1 #
				. "d:2"
			Search3 += Search1 - 1, Search4 += Search2 - 1
		}
		If (a <> "") and (InStr(a, "m") <> 1) {
			If DxInfo
				@ := "The ""a"" (Search Area) parameter has been given as """ a """. It will be interpreted as follows:`n`n<table>X;1*`nY;2*`nW;3*`nH;4*</table>"
			If (r = "")
				If (MonitorCount > 1) {	
					MouseGetPos, MouseX, MouseY
					Loop, Parse, MonitorInfo, `n
						If (A_Index > 1) {
							StringSplit, Search, A_LoopField, `,;
							If (MouseX >= Search1) and (MouseY >= Search2) and (MouseX <= Search3) and (MouseY <= Search4)
								Break
						}
				} Else
					Search1 := 0, Search2 := 0, Search3 := A_ScreenWidth - 1, Search4 := A_ScreenHeight - 1
			Loop, Parse, a, |`,
				If A_LoopField is Number
				{
					Search%A_Index% := (A_LoopField >= 0 ? (A_Index & 1 ? Search1 : Search2) - (A_Index >= 3) : (A_Index & 1 ? Search3 : Search4)) + A_LoopField
					If DxInfo
						StringReplace, @, @, %A_Index%*, % "Now = " Search%A_Index%
				}
			If DxInfo
				DxInfo .= $ "2:Modifying search area" #
				. "q:" DllCall("QueryPerformanceCounter", "Int64*", QPC) * QPC #
				. "t:" RegExReplace(@, ";\K\d\*", "Unchanged") #
				. "l:" A_LineNumber - 6
			If (Search3 < Search1) or (Search4 < Search2) {
				Error = Search area is 0
				Message = The search area requested using the "a" option resulted in an area of 0 pixels, thus the search will not be conducted.
				Buttons = &Debug,E&xit,&Help
				%A_ThisFunc%(">Error<")
				Return
			}
		}
		Found := 0
		If (InStr(a, "m") <> 1) {
			SubRegions := ((a = "") and (r = "") ? SubStr(MonitorInfo, InStr(MonitorInfo, "`n") + 1) : Search1 "," Search2 ";" Search3 "," Search4) "`n"
			If (w <> "")
				SubRegionsW := SubRegions
		}
		If (t <> "") and (LastX1 <> "") and SubRegions {
			LastX2 := LastX1 + ImageW - 1, LastY2 := LastY1 + ImageH - 1
			Loop, Parse, SubRegions, `n
				If (A_LoopField <> "") {
					StringSplit, @, A_LoopField, `,;
					If (LastX1 >= @1) and (LastX2 <= @3) and (LastY1 >= @2) and (LastY2 <= @4) {
						StringReplace, t, t, -, , UseErrorLevel
						@ := ErrorLevel
						StringReplace, SubRegions, SubRegions, %A_LoopField%`n
						If InStr(t, "%")
							LastX1 += (@1 - LastX1) * SubStr(t, 1, -1) / 100, LastY1 += (@2 - LastY1) * SubStr(t, 1, -1) / 100, LastX2 += (@3 - LastX2) * SubStr(t, 1, -1) / 100, LastY2 += (@4 - LastY2) * SubStr(t, 1, -1) / 100
						Else If t Is Integer
							LastX1 -= t, LastY1 -= + t, LastX2 += t, LastY2 += t
						Else
							MsgBox, 262160, %A_ScriptName%: Error, Incorrect value of t given ; xxx
						SubRegions := LastX1 "," LastY1 ";" LastX2 "," LastY2 ";P`n" . ( @ ? "" : (LastY1 > @2 ? @1 "," @2 ";" @3 "," LastY1 ";Q`n" : "") . (LastX1 > @1 ? @1 "," LastY1 ";" LastX1 "," LastY2 ";R`n" : "") . (@3 > LastX2 ? LastX2 "," LastY1 ";" @3 "," LastY2 ";S`n" : "") . (@4 > LastY2 ? @1 "," LastY2 ";" @3 "," @4 ";T`n" : "") . SubRegions )
						Break
					}
				}
			LastX1 := LastY1 := ""
		}
		If (w <> "") {
			StringSplit, w, w, `,|-
			If (w2 = "")
				w2 := !w1 or (w1 > 1000) ? 100 : Floor(w1 / 10)
			If DxInfo
				DxInfo .= $ "2:Logging start time" #
				. "t:Since the ""w"" (wait until found) option was specified, the script stores the current time (%A_TickCount%) and will perform an ImageSearch command every %w2% milliseconds until the image is found" (w1 ? " or %w1% milliseconds elapse." : ".") #
				. "c1:w1:" w1 #
				. "c2:w2:" w2 #
				. "c3:A_TickCount:" A_TickCount #
				. "q:" DllCall("QueryperformanceCounter", "Int64*", QpC) * QPC #
				. "l:" A_LineNumber + 1 #
			If w1
				w1 += A_TickCount
		}
		If DxInfo
			DxInfo .= $ "1:Searching for image" #
			. "q:" DllCall("QueryPerformanceCounter", "Int64*", QPC) * QPC #
			. "t:The actual ImageSearch portion of the script will now begin. This is generally the most CPU-intensive portion of the script." #
			. "l:" A_LineNumber + 1
		Loop {
			If DxInfo
				@ := "" #
				. "q:" DllCall("QueryPerformanceCounter", "Int64*", QPC) * QPC #
				. "t:Searching and clicking, if applicable." #
				. "g:+.*(Performing|Found).*" #
				. "l:" A_LineNumber + 1
			If (SubRegions <> "") {
				Search := SubStr(SubRegions, 1, InStr(SubRegions, "`n") - 1), SubRegions := SubStr(SubRegions, InStr(SubRegions, "`n") + 1)
				StringSplit, Search, Search, `,;
				If Search5 in A,B
					e1 := Floor(ImageW * e)
				Else If Search5 = C
					e1 := SubRegions = "" ? 0 : Floor(ImageW * e)
				Else If Search5 in P,R
					e1 := Floor(ImageW * e)
				Else
					e1 := 0
				If Search5 in P,Q,R,S
					e2 := Floor(ImageH * e)
				Else
					e2 := 0
			} Else If (MostX <> "") { ; triggers directional search ("d" option)
				FoundXOrig := MostX, FoundYOrig := MostY, SubRegions := "`n", ErrorLevel := False
			} Else If (InStr(a, "m") = 1) and !Results {
				MouseGetPos, Search1, Search2
				If DxInfo
					@ .= $ "3:Retrieving mouse position" #
					. "q:" DllCall("QueryPerformanceCounter", "Int64*", QPC) * QPC #
					. "t:Since the ""a"" option (search area) was given as ""%a%"", the search area will become a square region " SubStr(a, 2) "*2=" SubStr(a, 2) * 2 " pixels wide around the mouse cursor.`n`nTo find this area, " A_ThisFunc " must now get the mouse position`n`n<table>X-pos;%MouseX%`nY-pos;%MouseY%</table>" #
					. "l:" A_LineNumber - 2 #
					. "d:2" #
					. "u:m" #
					. "c1:a:" a #
					. "c2:MouseX:" Search1 #
					. "c3:MouseY:" Search2 #
					. "g:Color,Red;Trans,200;Add,Picture,x10 y10 w30 h-1," A_WinDir "\Cursors\larrow.cur;Trans,150;Show,x" Search1 - 10 " y" Search2 - 10 " w37 h51 NA"
				Search3 := Search1 + SubStr(a, 2), Search4 := Search2 + SubStr(a, 2), Search1 -= SubStr(a, 2), Search2 -= SubStr(a, 2), e1 := 0, e2 := 0
			} Else
				Break ; XXX
			If (d = "") or (SubRegions <> "`n") { ; SubRegions = `n means d was selected and search is done, it's a dry run to click on the d-most option
				If DxInfo
					@5 := (Search3 - Search1 < 80 or Search4 - Search2 < 80) * 100
					, @ .= $ "3:Performing ImageSearch" #
					. "q:" DllCall("QueryPerformanceCounter", "Int64*", QPC) * QPC #
					. "t:The following line of code will execute:`n`n%Code_Orig%`n`nType of region: " (Search5 ? Search5 : "Normal") (@5 ? "`n`n(Red region is searched, blue region is for ease of visibility.)" : "") #
					. "l:" A_LineNumber + 2 #
					. "u:http://www.autohotkey.com/docs/imagesearch`no" #
					. "d:5" #
					. "c1:Code:ImageSearch, FoundX, FoundY, " Round(Search1) ", " Round(Search2) ", " Round(Search3) " + " e1 ", " Round(Search4) " + " e2 ", " o ImageFilePath #
					. "g:Color,44AADD,0000FF;Trans,80;Add,Progress,x" @5 " y" @5 " w" Search3 - Search1 + 1 " h" Search4 - Search2 + 1 " cFF9999 BackgroundFF9999,100;Show,NA x" Search1 - @5 " y" Search2 - @5 " w" Search3 - Search1 + e1 + @5 * 2 + 1 " h" Search4 - Search2 + e2 + @5 * 2 + 1
				ImageSearch, FoundXOrig, FoundYOrig, Search1, Search2, Search3 + e1, Search4 + e2, %o%%ImageFilePath%
			}
			If (ErrorLevel = 2) {
				; xxx put the variable %@% before dxinfo
				If NewImage
					Return %A_ThisFunc%(ImageFile, Options)
				Error = File Not Found
				Message = AutoHotkey was unable to use the image "%ImageFile%" for searching.
				Buttons = &View File,&Debug,E&xit,&Help
				If (%A_ThisFunc%(">Error<") = "View File")
					MsgBox, 262160, %A_ScriptName%: Error, Function not yet supported, sorry! ; xxx
				Return
			} Else If !ErrorLevel {
				If (w2 <> "")
					w2 := ""
				If DxInfo
					DxInfo .= $ "2:" (SubRegions = "`n" ? "Selecting " d "-most Image" : "Search #" A_Index " - Success") @
					. $ "3:Image Found at " FoundXOrig ", " FoundYOrig #
					. "q:" DllCall("QueryPerformanceCounter", "Int64*", QPC) * QPC #
					. "t:The image was found at the coordinates (%FoundX%, %FoundY%). These coordinates are relative to the screen." #
					. "l:" A_LineNumber - 3 #
					. "d:5" #
					. "g:Color,Blue;Trans,80;Add,Progress,-0x20000 cRed x10 y10 w30 h30,100;Add,Progress,-0x20000 cRed x" 40 + ImageW " y10 w30 h30,100;Add,Progress,-0x20000 cRed x10 y" 40 + ImageH " w30 h30,100;Add,Progress,-0x20000 cRed x" 40 + ImageW " y" 40 + ImageH " w30 h30,100;Show,NA x" FoundXOrig - 40 " y" FoundYOrig - 40 " w" 80 + ImageW " h" 80 + ImageH #
					. "c1:FoundX:" FoundXOrig #
					. "c2:FoundY:" FoundYOrig
				If (d = "") or (SubRegions = "`n") {
					If !Found
						LastX1 := FoundXOrig, LastY1 := FoundYOrig
					Found += 1, Results .= Delim f, FoundX := FoundXOrig + Center * (ImageW - 1) // 2 + Floor(x), FoundY := FoundYOrig + Center * (ImageH - 1) // 2 + Floor(y)
					StringReplace, Results, Results, %CharX%, %FoundX%, All
					StringReplace, Results, Results, %CharY%, %FoundY%, All
					StringReplace, Results, Results, %CharN%, %Found%, All
					If n {
						If DxInfo
							DxInfo .= $ "3:Performing Clicks" #
							. "q:" DllCall("QueryPerformanceCounter", "Int64*", QPC) * QPC #
							. "t:The ""n"" (number of clicks/no clicks) was not set to 0 so the script will now perform clicks on the image." #
							. "l:" A_LineNumber - 2 #
							. "u:m`nn" #
							. "g:Color,Blue;Trans,80;Add,Progress,-0x20000 cRed x10 y10 w" 29 + (ImageW + 1) // 2 " h" 29 + (ImageH + 1) // 2 ",100;Add,Progress,-0x20000 cRed x+1 yp wp+" Mod(ImageW + 1, 2) " hp,100;Add,Progress,-0x20000 cRed x10 y+1 wp-" Mod(ImageW + 1, 2) " hp+" Mod(ImageH + 1, 2) ",100;Add,Progress,-0x20000 cRed x+1 yp wp+" Mod(ImageW + 1, 2) " hp,100;Show,NA x" FoundX - 39 - (ImageW + 1) // 2 " y" FoundY - 39 - (ImageH + 1) // 2 " w" 80 + ImageW " h" 80 + ImageH
						If (Found <> 1)
							Sleep %Sleep%
						If (InStr(m, "c") = 1) {
							If (Found = 1) {
								ControlDelay := A_ControlDelay
								SetControlDelay, -1
								DetectHiddenWindows := A_DetectHiddenWindows
								DetectHiddenWindows, Off
							}
							WinGet, WinList, List
							Loop %WinList% {
								WinGetPos, @1, @2, @3, @4, % "ahk_id " WinList%A_Index%
								If (FoundX >= @1) and (FoundY >= @2) and (FoundX <= @1 + @3) and (FoundY <= @2 + @4) {
									Window := WinList%A_Index%
									WinGetPos, ClickX, ClickY, , , ahk_id %Window%
									Break
								} Else If (A_Index = WinList) {
									Error = ControlClick Error
									Message = %A_ThisFunc%() was unable to locate a window to use for a ControlClick keystroke.
									Buttons = &Debug,E&xit,&Help
									%A_ThisFunc%(">Error<")
									Return
								}
							}
						} Else {
							If (Found = 1) {
								CoordMode, Mouse
								MouseDelay := A_MouseDelay
								SetMouseDelay, -1
								MouseGetPos, MouseX, MouseY
								If DxInfo
									DxInfo .= $ "4:Saving mouse coordinates" #
									. "l:" A_LineNumber - 1 #
									. "t:Setting A_MouseDelay temporarily to -1 (fastest speed.) Also storing the current mouse coordinates.`n`n<table>Mouse X-Coordinate;%MouseX%`nMouse Y-Coordinate;%MouseY%</table>" #
									. "c1:MouseX:" MouseX #
									. "c2:MouseY:" MouseY #
									. "q:" DllCall("QueryPerformanceCounter", "Int64*", QPC) * QPC #
									. "g:Color,Red;Trans,200;Add,Picture,x10 y10 w30 h-1," A_WinDir "\Cursors\larrow.cur;Trans,150;Show,x" MouseX - 10 " y" MouseY - 10 " w37 h51 NA"
							}
							If DxInfo
								DxInfo .= $ "4:Moving mouse to " MouseX ", " MouseY #
								. "d:2" #
								. "q:" DllCall("QueryPerformanceCounter", "Int64*", QPC) * QPC #
								. "l:" A_LineNumber + 1 #
								. "c1:FoundX:" MouseX #
								. "c2:FoundY:" MouseY #
								. "t:Moving mouse to coordinates (%FoundX%, %FoundY%). Coordinates are relative to the screen." #
								. "g:Color,Green;Trans,200;Add,Picture,x10 y10 w30 h-1," A_WinDir "\Cursors\larrow.cur;Trans,150;Show,x" FoundX - 10 " y" FoundY - 10 " w37 h51 NA"
							MouseMove, FoundX, FoundY, 0
						}
						Loop % n * 2 - 1 {
							If DxInfo
								DxInfo .= $ "4:" (A_Index & 1 ? "Clicking" : "Sleeping") #
								. "t:The following line of code will execute:`n`n%Code_Orig%" #
								. (A_Index & 1 ? "g:-Performing Clicks" # : "")
								. "d:4" #
								. "l:" A_LineNumber - 14 #
								. "c1:Code:" %A_ThisFunc%(">Escape<", !(A_Index & 1) ? "Sleep, " Sleep : SubStr(m, 1, 1) = "i" ? "SendInput, " k : SubStr(m, 1, 1) = "c" ? "ControlClick, x" FoundX - ClickX " y" FoundY - ClickY ", ahk_id " Window ", , " k ", , NA" : SubStr(m, 1, 1) = "p" ? "SendPlay, " k : SubStr(m, 1, 1) = "e" ? "SendEvent, " k : "Send, " k)
							If !(A_Index & 1)
								Sleep %Sleep%
							Else If (SubStr(m, 1, 1) = "i")
								SendInput %k%
							Else If (SubStr(m, 1, 1) = "c")
								ControlClick, % "x" FoundX - ClickX " y" FoundY - ClickY, ahk_id %Window%, , %k%, , NA
							Else If (SubStr(m, 1, 1) = "p")
								SendPlay %k%
							Else If (SubStr(m, 1, 1) = "e")
								SendEvent %k%
							Else
								Send %k%
						}
					} Else If (Func <> "")
						%Func%(FoundX, FoundY)
					If d or (t <> "")
						Break
				}
				If (e <> "") {
					If (FoundXOrig + ImageW < Search3) and (FoundYOrig + ImageH < Search4)
						SubRegions := FoundXOrig + ImageW "," FoundYOrig ";" Search3 "," Search4 ";" "C`n" SubRegions
					If (FoundYOrig + ImageH < Search4)
						SubRegions := FoundXOrig "," FoundYOrig + ImageH ";" FoundXOrig + ImageW - 1 "," Search4 ";" "B`n" SubRegions
					If (FoundXOrig > Search1) and (FoundYOrig + ImageH < Search4)
						SubRegions := Search1 "," FoundYOrig + 1 ";" FoundXOrig - 1 "," Search4 ";" "A`n" SubRegions
					If DxInfo
						DxInfo .= $ "3:More regions queued" #
						. "t:Because the ""e"" or ""d"" option was indicated, " A_ThisFunc "() needs to continue searching the screen for other instances of the image.`nThe following regions remain to be searched:`n`n<table>Top Left;Bottom Right;Region Type`n" SubRegions "</table>`n`n(Each time an image is found, the remaining space must be split into up to 3 additional regions.)" #
						. "l:" A_LineNumber - 7
					If d
						If (Asc(d) = 108) { ; l (Left)
							If (MostX = "") or (FoundXOrig < MostX)
								MostX := FoundXOrig, MostY := FoundYOrig
						} Else If (Asc(d) = 114) { ; r (Right)
							If (MostX = "") or (FoundXOrig > MostX)
								MostX := FoundXOrig, MostY := FoundYOrig
						} Else If (Asc(d) = 98) or (Asc(d) = 100) { ; b (Bottom) / d (Down)
							If (MostX = "") or (FoundYOrig > MostY)
								MostX := FoundXOrig, MostY := FoundYOrig
						} Else { ; Distance from coords
							If (Dist1 = "") {
								If (Asc(d) = 109) ; m (MousePos)
									MouseGetPos, Dist1, Dist2
								Else
									StringSplit, Dist, d, |`,
								Dist1 -= Center * (ImageW - 1) // 2 + Floor(x), Dist2 -= Center * (ImageH - 1) // 2 + Floor(y)
							}
							If (MostX = "") or (Sqrt((FoundXOrig - Dist1)**2 + (FoundYOrig - Dist2)**2) < Sqrt((MostX - Dist1)**2 + (MostY - Dist2)**2))	
								MostX := FoundXOrig, MostY := FoundYOrig
						}
				} Else
					Break
			} Else If (w2 = "") or SubRegions or (w1 and (A_TickCount > w1)) {
				If DxInfo
					DxInfo .= $ "2:Search #" A_Index @
					. $ "3:Image Not Found" #
					. "t:The image was not found in the given region.`n`n" ((Results and e) or (d and MostX != "") ? SubRegions = "" ? "No more regions remain to be searched (""e"" or ""d"" option) so the script will now finish." : "Moving on to the next region:`n" SubStr(SubRegions, 1, InStr(SubRegions, "`n") - 1) : (w = "" ? "Because the ""w"" option (wait for an image to be found) was not used, the script will now finish." : "The ""w"" option was indicated as " w " and " A_ThisFunc "() has continued to search for the image. However the wait time has now expired and the script will finish.")) #
					. "g:Color,44AADD,0000FF;Trans,80;Add,Progress,x" @5 " y" @5 " w" Search3 - Search1 + 1 " h" Search4 - Search2 + 1 " cRed BackgroundRed,100;Show,NA x" Search1 - @5 " y" Search2 - @5 " w" Search3 - Search1 + e1 + @5 * 2 + 1 " h" Search4 - Search2 + e2 + @5 * 2 + 1 #
					. "d:3" #
					. "l:" A_LineNumber - 2
				If (w != "") and (Subregions = "")
					Break
			} Else If (w2 <> "") and (Results = "") {
				If DxInfo
					DxInfo .= $ "2:Search #" A_Index @
					. "`r3:Image not found, sleeping" #
					. "q:" DllCall("QueryPerformanceCounter", "Int64*", QPC) * QPC #
					. "t:The image was not found in the search region.`n`nThe ""w"" option (wait for an image to be found) was given as: %w%.`n`n<table>Total wait time;" SubStr(w, 1, InStr(w ",", ",") - 1) "`nSleep interval between searches;" (InStr(w, ",") ? SubStr(w, InStr(w, ",") + 1) "</table>" : "Not given</table>`n`nIf the sleep interval is not given then it will be assumed as either the total wait time divided by 10 or 100 milliseconds, whichever is smaller.") "`n`nSince no image has been found yet, the function now sleeps " w2 " milliseconds." #
					. "l:" A_LineNumber + 1 #
					. "c1:w:" w
				Sleep w2
				SubRegions := SubRegionsW
			}
		}
		If DxInfo {
			; show all locations found xxx
			DxInfo .= $ "1:Finishing" #
			. "q:" DllCall("QueryPerformanceCounter", "Int64*", QPC) * QPC #
			. "t:Cache contains:`n------------------------`n%TempCache%" #
			. "c1:TempCache:" %A_ThisFunc%(">Escape<", Cache) #
			. "l:" A_LineNumber
		}
		If Results and n
			If (InStr(m, "c") = 1) {
				SetControlDelay, %ControlDelay%
				DetectHiddenWindows, %DetectHiddenWindows%
			} Else {
				If !Stay
					MouseMove, MouseX, MouseY, 0
				SetMouseDelay, %MouseDelay%
				If DxInfo
					DxInfo .= $ "2:" (Stay ? "LEAVING mouse" : "Returning mouse") #
					. "t:Returning mouse to coordinates (" MouseX ", " MouseY "). Coordinates are relative to the screen." #
					. "q:" DllCall("QueryPerformanceCounter", "Int64*", QPC) * QPC #
					. "g:Color,Red;Trans,200;Add,Picture,x10 y10 w30 h-1," A_WinDir "\Cursors\larrow.cur;Trans,150;Show,x" MouseX - 10 " y" MouseY - 10 " w37 h51 NA" #
					. "l:" A_LineNumber - 3
			}
		If DxInfo
			DxInfo .= $ "2:Returned Value" #
			. "t:The function returns the following value:`n`n%Return%" #
			. "c1:Return:" %A_ThisFunc%(">Escape<", Count ? Found : Results ? SubStr(Results, StrLen(Delim) + 1) : False) #
			. "l:" A_LineNumber + 1
			, %A_ThisFunc%(">Debug:", dx)
		ErrorLevel := False
		Return Count ? Found : Results ? SubStr(Results, StrLen(Delim) + 1) : False
	}
	Else If ImageFile = >ParseCache< ;--------------------------------------------------Checks if an image file has already been used--------------------------------------------------
	{
		Loop, Parse, Cache, `n
			If InStr(A_Tab A_LoopField, A_Tab Options A_Tab) {
				StringSplit, @, A_LoopField, |%A_Tab%
				If FileExist(@2) {
					StringReplace, Cache, Cache, %A_LoopField%`n
					ImageFilePath := @2, ImageW := @3, ImageH := @4, LastX1 := @5, LastY1 := @6
					If DxInfo
						DxInfo .= $ "2:Image file already used" #
						. "q:" DllCall("QueryPerformanceCounter", "Int64*", QPC) * QPC #
						. "t:This file has been used previously by " A_ThisFunc "() and the following attributes will not have to be measured again" #
						. "l:" A_LineNumber - 2 #
						. "d:1"
						, DxInfo .= $ "3:Image width" #
						. "t:" ImageW
						, DxInfo .= $ "3:Image height" #
						. "t:" ImageH
					Return True
				}
			}
	}
	Else If ImageFile = >GuiEvent< ;--------------------------------------------------Gui event handler--------------------------------------------------
	{
		If (A_GuiControl = "ErrorLevel")
			If (A_GuiEvent = "RightClick")
				@ := A_GuiEvent ":" A_EventInfo
			Else If A_GuiEvent Not In Normal,*,K
				Return
		DetectHiddenWindows, Off
		GuiCommand := @ <> "" ? @ : A_GuiControl <> "" ? A_GuiControl : A_ThisLabel = A_ThisFunc "Menu" ? A_ThisMenu : A_GuiEvent ? A_GuiEvent : A_ThisHotkey
		If (A_Gui = GuiB) {
			GuiControlGet, @, %GuiB%:, Edit1
			If !ErrorLevel
				GuiCommand .= "`n" @
			Gui, %GuiA%:-Disabled
			Gui, %GuiB%:Destroy
		} Else If GuiTitle
			WinSetTitle, ahk_id %GuiHWND%, , % SubStr(GuiTitle, 1, InStr(GuiTitle, ":") - 1) ;% A_ThisFunc A_Space (A_Gui = GuiA ? "Debugger" : "Screenshot Creator")
	}
	Else If ImageFile = >Escape< ;--------------------------------------------------Escapes characters for diagnostic mode storage--------------------------------------------------
	{
		StringReplace, Options, Options, ``, ````, All
		StringReplace, Options, Options, %#%, ``#, All
		StringReplace, Options, Options, %$%, ``$, All
		Return Options
	} Else If (ImageFile = ">UnEscape<") { ;--------------------------------------------------Un-escapes characters for diagnostic mode display--------------------------------------------------
		Options := RegExReplace(RegExReplace(Options, "(?<!``)``#", #), "(?<!``)``\$", $)
		StringReplace, Options, Options, ````, ``, All
		Return Options
	}
	Else If ImageFile = >ShowChars< ;--------------------------------------------------Replaces non-visible characters for diagnostic mode--------------------------------------------------
	{
		If (Options = "")
			Return "[EMPTY STRING]"
		Else If (Options = False)
			Return "[0 : FALSE]"
		Else If (Options = True)
			Return "[1 : TRUE]"
		StringReplace, Options, Options, `r, [CR], All
		StringReplace, Options, Options, `n, [NL], All
		StringReplace, Options, Options, %A_Space%, [_], All
		StringReplace, Options, Options, %A_Tab%, [ » ], All
		Invisible = 0,1,2,3,4,5,6,7,8,11,12,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,127
		Loop, Parse, Invisible, `,
			StringReplace, Options, Options, % Chr(A_LoopField), [Chr%A_LoopField%], All
		Return Options
	}
	Else If ImageFile = >NewGui< ;--------------------------------------------------Assembles gui elements--------------------------------------------------
	{
		Loop, Parse, Options, `;
			If (A_Index = 1) {
				Gui, %A_LoopField%:Destroy
				Gui, %A_LoopField%:+LastFound
				ThisNum := A_LoopField, ThisHWND := WinExist()
			} Else {
				@2 := @3 := @4 := ""
				StringSplit, @, A_LoopField, `,
				If @1 in Trans,Region
					WinSet, %@1%, %@2%, ahk_id %ThisHWND%
				Else
					Gui, %ThisNum%:%@1%, %@2%, %@3%, % SubStr(A_LoopField, StrLen(@1 @2 @3) + 4)
			}
		Return ThisHWND
	}
	Else If ImageFile = >Table< ;--------------------------------------------------Forms data into a table for diagnostic mode--------------------------------------------------
	{
		If RegExMatch(Options, "is)<table>\K.*?(?=</table>)", Table)
			While (3 > Cycle := A_Index)
				Loop, Parse, Table, `n
				{
					StringSplit, @, A_LoopField, `;
					Loop %@0%
						If (Cycle = 2)
							Output .= A_Index = @0 ? @%A_Index% "`n" : SubStr(@%A_Index% "                ", 1, Max%A_Index%) "     "
						Else If (Max%A_Index% < StrLen(@%A_Index%))
							Max%A_Index% := StrLen(@%A_Index%)
				}
		StringReplace, Options, Options, <table>%Table%</table>, % SubStr(Output, 1, -1)
		Return Options
	}
	Else If ImageFile = >MakeImage< ;--------------------------------------------------Builds an image file using GDI+--------------------------------------------------
	{
		Loop, Parse, Options, |
			If (A_Index = 5)
				Break
			Else
				Param%A_Index% := A_LoopField
		StringTrimLeft, Options, Options, StrLen(Param1 Param2 Param3 Param4) + 4
		FileDelete, %Param1%.%Param2%
		If A_PtrSize
			Ptr := "UPtr", PtrA := "UPtr*", PtrSize := A_PtrSize
		Else
			Ptr := "UInt", PtrA := "UInt*", PtrSize := 4
		If !DllCall("GetModuleHandle", "str", "gdiplus")
			DllCall("LoadLibrary", "str", "gdiplus")
		sOutput := Param1 "." Param2, VarSetCapacity(si, A_PtrSize = 8 ? 24 : 16, 0), si := Chr(1), DllCall("gdiplus\GdiplusStartup", "uint*", pToken, "uint", &si, "uint", 0), DllCall("gdiplus\GdipCreateBitmapFromScan0", "int", Param3, "int", Param4, "int", 0, "int", 0x26200A, Ptr, 0, PtrA, pBitmap)
		Loop, Parse, Options, |
			DllCall("gdiplus\GdipBitmapSetPixel", Ptr, pBitmap, "int", Mod(A_Index - 1, Param3), "int", (A_Index - 1) // Param3, "int", "0xFF" SubStr("000000" A_LoopField, -5))
		DllCall("gdiplus\GdipGetImageEncodersSize", "uint*", nCount, "uint*", nSize), VarSetCapacity(ci, nSize), DllCall("gdiplus\GdipGetImageEncoders", "uint", nCount, "uint", nSize, Ptr, &ci)
		Loop, %nCount% {
			If A_PtrSize
				@ := "StrGet", sString := %@%(NumGet(ci, (idx := (48 + 7 * A_PtrSize) * (A_Index - 1)) + 32 + 3 * A_PtrSize), "UTF-16")
			Else
				idx := 76 * (A_Index - 1), Address := NumGet(ci, idx + 44), char_count := DllCall("WideCharToMultiByte", "uint", 0, "uint", 0x400, "uint", Address, "int", -1, "uint", 0, "uint", 0, "uint", 0, "uint", 0), VarSetCapacity(sString, char_count), DllCall("WideCharToMultiByte", "uint", 0, "uint", 0x400, "uint", Address, "int", -1, "str", sString, "int", char_count, "uint", 0, "uint", 0)
			If InStr(sString, "*." Param2) {
				pCodec := &ci + idx
				Break
			}
		}
		If A_IsUnicode
			DllCall("gdiplus\GdipSaveImageToFile", Ptr, pBitmap, Ptr, &sOutput, Ptr, pCodec, "uint", 0)
		Else
			nSize := DllCall("MultiByteToWideChar", "uint", 0, "uint", 0, Ptr, &sOutput, "int", -1, Ptr, 0, "int", 0), VarSetCapacity(wOutput, nSize * 2), DllCall("MultiByteToWideChar", "uint", 0, "uint", 0, Ptr, &sOutput, "int", -1, Ptr, &wOutput, "int", nSize), VarSetCapacity(wOutput, -1), VarSetCapacity(wOutput), DllCall("gdiplus\GdipSaveImageToFile", Ptr, pBitmap, Ptr, &wOutput, Ptr, pCodec, "uint", 0)
		DllCall("gdiplus\GdipDisposeImage", Ptr, pBitmap), DllCall("gdiplus\GdiplusShutdown", Ptr, pToken)
		If (hModule := DllCall("GetModuleHandle", "str", "gdiplus", Ptr))
			DllCall("FreeLibrary", Ptr, hModule)
		If !FileExist(Param1 "." Param2) {
			MsgBox, 262164, %A_ScriptName% - %A_ThisFunc%(): Trouble building file!,  %A_ThisFunc%() had intended to build an image file using GDI+ to output to the following path:`n%Param1%.%Param2%`n`nThis procedure has failed, possibly for one of the following reasons:`n1) You do not have access to the file location in question.`n2) You are using a version of windows that doesn't support the GDI+ procedures the script needs.`n3) Berban has made a silly mistake (most likely answer).`n`nIf this error recurs, please report it on the AutoHotkey forums.`n`nVisit the forums now?
			IfMsgBox YES
				Run %ForumURL%
		}
	}
	Else If ImageFile = >Error< ;--------------------------------------------------Displays & handles error dialogs--------------------------------------------------
	{
		ErrorLevel = %Error% - %Message%
		If !Silent
			If !DxInfo {
				Margins = 10
				MsgBoxWidth = 250
				ButtonWidth = 90
				ControlHeight = 24
				TextSize = 10
				Loop, Parse, Buttons, CSV
					ButtonList .= ";Add,Button,g" A_ThisFunc "Close y+" Margins " x" Margins " w" ButtonWidth " h" ControlHeight "," A_LoopField
				WinWaitClose, % "ahk_id " %A_ThisFunc%(">NewGui<", GuiB . ";+AlwaysOnTop +Label" A_ThisFunc . ";Add,Picture,Icon132 x" Margins " y" Margins ",Shell32.dll" . ButtonList . ";Font,s" TextSize . ";Add,Text,x+" Margins " y" Margins " w" MsgBoxWidth - ButtonWidth - Margins "," Message . ";Show,w" MsgBoxWidth + Margins * 2 ",Error: " Error)
				GuiCommand := RegExReplace(GuiCommand, "(?<!&)&(?!&)")
				If GuiCommand = Help
					Run, %ForumURL%
				Else If GuiCommand = Debug
					@ := LastImageFile, LastImageFile := ""
					, %A_ThisFunc%(@, LastOptions " dx")
				Return GuiCommand, ErrorLevel := Error " - " Message
			} Else
				DxInfo .= $ "2:Error - " Error #
					. "t:" Message #
					. "q:" DllCall("QueryPerformanceCounter", "Int64*", QPC) * QPC #
					. "l:" A_LineNumber - 5
				, DxInfo .= $ "1:Finishing" #
					. "q:" DllCall("QueryPerformanceCounter", "Int64*", QPC) * QPC #
					. "t:Cache contains:`n------------------------`n" %A_ThisFunc%(">ShowChars<", Cache)
				, %A_ThisFunc%(">Debug:", dx)
	}
	Else If (InStr(ImageFile, ">Debug:") = 1) ;--------------------------------------------------Debugging--------------------------------------------------
	{
		DetectHiddenWindows := A_DetectHiddenWindows, WinDelay := A_WinDelay
		DetectHiddenWindows, On
		SetWinDelay, -1
		;|||||||||||||||||||||||||||||||||||||| Debugging Gui Settings ||||||||||||||||||||||||||||||||||||||
		;----------------------------------------------------------------------------------------------------
		DebugSettingsLocation = %A_LineNumber%                                       ; Line number placeholder (do not edit)
		EditorPath = C:\Program Files (x86)\Notepad++\Notepad++.exe                  ; Path to editor utilized when you select "Go To Line" command
		EditorCommand = -n`%LineNumber`%                                             ; Format of command-line parameter to open above editor to the desired line. `%LineNumber`% is substituted by the line number. Use -goto:`%LineNumber`% for SciTE and -n`%LineNumber`% for Notepad++
		HotkeyPlay = Space                                                           ; Hotkeys
		HotkeyNext = .
		HotkeyPrev = ,
		HotkeyCompactView = ``
		ShrinkByW = 50                                                               ; Amount to shrink when in "compact view"
		ShrinkByH = 100
		TextBoxFontSize = 9                                                          ; Misc GUI element tweaks
		TextBoxFontFace = Lucida Console
		TreeViewFontSize = 10
		TreeViewFontFace = Segoe UI
		Width = 350
		ControlHeight = 30
		TextBoxHeight = 200
		TreeViewHeight = 250
		PlayingText = Playing
		ButtonWidth = 60
		Margins = 7
		PlaySpeed = .3
		ButtonFontSize = 10
		ButtonFontFace = Segoe UI
		TextBoxFontSize = 9                                                          ; Default values for certain checkbox settings
		ShowChars = %True%                                                          
		ShowGraphics = %True%
		AlwaysOnTop = %False%
		PlaySpeed = 3
		Playing = %False%
		SkipSteps = %True%
		StartAt = 1
		SaveTo =
		WrapText = %True% ; needs work
		CompactView = %False% ; needs work
		AutoClose = %False% ; needs work
		;----------------------------------------- Gui Text Elements ----------------------------------------
		; Edit the variables below to change the text of the buttons and other elements in the debugger GUI. This can be done to change the language of the interface, or to change the accelerator keys (using the "&" symbol).
		ButtonPlay = &Play
		ButtonPause = &Pause
		ButtonPrev = <
		ButtonNext = >
		MenuFile = &%A_ThisFunc%
		MenuFilePrev = &Previous Step
		MenuFileNext = &Next Step
		MenuFileStandard = Script &Menu
		MenuFileEdit = &Go to line
		MenuFileSave = &Save
		MenuFileExit = E&xit
		MenuCopy = &Clipboard
		MenuCopyStepName = Copy Step &Name
		MenuCopyStepText = Copy Step &Text
		MenuSettings = &Settings
		MenuSettingsCompactView = &Compact View
		MenuSettingsAlwaysOnTop = &Always On Top
		MenuSettingsShowGraphics = Show &Graphics
		MenuSettingsShowChars = Show &Whitespaces
		MenuSettingsWrapText = &Wrap Text
		MenuSettingsEdit = &Edit Debugger Settings
		MenuSettingsSkipSteps = Skip Unimportant Steps
		MenuSettingsAutoClose = Close When Finished ; needs work
		MenuHelp = &Help
		MenuHelpDocs = &%A_ThisFunc% Documentation
		MenuHelpDebugger = &Debugger Help
		MenuHelpWhitespaceView = &Whitespace Viewer Help
		MenuHelpAbout = &About %A_ThisFunc%
		;||||||||||||||||||||||||||||||||||||||||||| End Settings |||||||||||||||||||||||||||||||||||||||||||
		Menus =
		(
		Standard
		File:Prev,Next,Play,,Standard,,Edit,Save,Exit
		Copy:StepName,StepText,
		Settings:CompactView,AlwaysOnTop,ShowGraphics,ShowChars,WrapText,SkipSteps,AutoClose,,Edit
		Help:Docs,Debugger,WhitespaceView,About,
		Bar:File,Copy,Settings,Help
		Context:File,Copy,Settings,Help
		)
		Loop, Parse, Options, CSV
			If (A_LoopField = "Reset")
				LastImageFile := Cache := "" ;xxx
			Else If RegExMatch(A_LoopField, "^([A-Za-z0-9_#$]+)=([\s\S]*)$", @)
				%@1% := @2
			Else If (A_Index <> 1)
				MsgBox, 262160, %A_ScriptName% - %A_Thisfunc%(): Error, Poorly formatted Options param for diagnostic mode:`n%A_LoopField%
		If SaveTo {
			FileDelete, %SaveTo%
			StringReplace, DxInfo, DxInfo, `r, `r`n, All
			FileAppend, %DxInfo%, %SaveTo%
			Return DxInfo := ""
		}
		StringReplace, Menus, Menus, %A_Space%, , All
		StringReplace, Menus, Menus, %A_Tab%, , All
		MenuStandard := True, Hotkeys := "Play,Next,Prev,CompactView", Buttons := "Button1,Button2,Button3,Edit2"
		Menu, %A_ThisFunc%MenuStandard, Standard
		Loop, Parse, Menus, `n
			Loop, Parse, A_LoopField, :`,
				If (A_Index > 1) {
					Menu, %A_ThisFunc%Menu%ThisMenu%, Add, % (A_LoopField = "" ? "" : ThisMenu = "Bar" or ThisMenu = "Context" ? Menu%A_LoopField% : Menu%ThisMenu%%A_LoopField% = "" ? Button%A_LoopField% : Menu%ThisMenu%%A_LoopField%) (Hotkey%A_LoopField% = "" ? "" : A_Tab Hotkey%A_LoopField%), % Menu%A_LoopField% = "" ? A_ThisFunc "Menu" : ":" A_ThisFunc "Menu" A_LoopField
					If A_LoopField and %A_LoopField%
						Menu, %A_ThisFunc%Menu%ThisMenu%, Check, % Menu%ThisMenu%%A_LoopField% (Hotkey%A_LoopField% = "" ? "" : A_Tab Hotkey%A_LoopField%)
				} Else 
					ThisMenu := A_LoopField
		GuiHWND := %A_ThisFunc%(">NewGui<", GuiA
		. ";+Label" A_ThisFunc (AlwaysOnTop ? " +AlwaysOnTop" : "")
		. ";Font,s" ButtonFontSize "," ButtonFontFace
		. ";Menu," A_ThisFunc "MenuBar"
		. ";Add,Button,g" A_ThisFunc "Close x" Margins " y" Margins " w" ButtonWidth " h" ControlHeight "," ButtonPrev
		. ";Add,Button,g" A_ThisFunc "Close x+" Margins " yp wp hp," ButtonPlay
		. ";Add,Button,g" A_ThisFunc "Close x+" Margins " yp wp hp +Default," ButtonNext
		. ";Font,s" TreeViewFontSize "," TreeViewFontFace
		. ";Add,TreeView,g" A_ThisFunc "Close vErrorLevel +AltSubmit x" Margins " y+" Margins " w" Width " h" TreeViewHeight
		. ";Font,s" TextBoxFontSize "," TextBoxFontFace
		. ";Add,Edit,+ReadOnly " (WrapText ? "+Wrap -HScroll" : "-Wrap +HScroll") " x" Margins " y+" Margins " w" Width " h" TextBoxHeight
		. ";Add,Edit,-VScroll +ReadOnly -Wrap x" ButtonWidth * 3 + Margins * 4 " y" Margins " w" Width - (Margins + ButtonWidth) * 3 " h" ControlHeight
		. ";Default")
		If (StrLen(ImageFile) > 7) {
			StringTrimLeft, ImageFile, ImageFile, 7
			If !FileExist(ImageFile) {
				MsgBox, 262160, %A_ScriptName% - %A_ThisFunc%(): Error, Debug file "%ImageFile%" does not appear to exist.
				Return
			} Else
				FileRead, DxInfo, %ImageFile%
		} Else If (DxInfo = "") {
			MsgBox, 262160, %A_ScriptName% - %A_ThisFunc%(): Error, Improper use of the Diagnostic mode.
			Return
		} Else
			DxInfo := A_TickCount A_Tab DllCall("QueryPerformanceCounter", "Int64*", QPC) * QPC A_Tab DxInfo
		If StartAt Is Integer
			CurrentStep := StartAt
		Else
			RegExMatch(StartAt, "^(?:(?P<Occurence>\d+):)?(?P<Pattern>[\s\S]*)$", StartAt)
		Loop, Parse, DxInfo, `r, `n
			If (A_Index = 1) {
				StringSplit, @, A_LoopField, %A_Tab%
				QPC_Rate := (@1 - @3) / (@2 - @4), QPC_Final := @2
			} Else {
				Items := A_Index - 1
				Loop, Parse, A_LoopField, %A_Tab%
					If (A_Index = 1) {
						%Items%_Level := @1 := Asc(A_LoopField) = 43 ? @2 + 2 : Asc(A_LoopField) = 45 ? @2 : SubStr(A_LoopField, 1, 1), @2 := @1 - 1, %Items%_ID := TV%@1% := TV_Add(%Items%_Title := SubStr(A_LoopField, 3), TV%@2%)
						If !CurrentStep and RegExMatch(%Items%_Title, StartAtPattern) and !(--StartAtOccurence)
							CurrentStep := Items
					} Else If InStr(A_LoopField, ":") {
						@1 := SubStr(A_LoopField, 1, InStr(A_LoopField, ":") - 1), %Items%_%@1% := SubStr(A_LoopField, InStr(A_LoopField, ":") + 1)
						If @1 = g
							TV_Modify(%Items%_ID, "Bold")
					}
			}
		@ := Items + 1, %@%_q := QPC_Final, PreviousStep := 0, PlaySpeed := PlaySpeed / 20
		Gui, %GuiA%:Show, % "w" Width + Margins * 2 " h" TreeViewHeight + TextBoxHeight + ControlHeight + Margins * 4 ; move north
		Hotkey, IfWinActive, ahk_id %GuiHWND%
		Loop, Parse, Hotkeys, `,
			If (Hotkey%A_LoopField% <> "")
				Hotkey, % Hotkey%A_LoopField%, %A_ThisFunc%Close, On
		Hotkey, IfWinActive
		If Playing
			TempGuiCommand := ButtonPlay, Playing := False
		If !CurrentStep
			CurrentStep := 1
		Loop {
			If (A_Index <> 1)
				TempGuiCommand := GuiCommand
			GuiCommand := RightClick := ""
			If (TempGuiCommand = ButtonPlay) or (TempGuiCommand = ButtonPause) or (TempGuiCommand = HotkeyPlay) or (Playing and (TempGuiCommand = "ErrorLevel")) {
				Playing := !Playing
				ControlSetText, Button2, % Playing ? ButtonPause : ButtonPlay, ahk_id %GuiHWND%
				Menu, %A_ThisFunc%MenuFile, Rename, % (Playing ? ButtonPlay : ButtonPause) A_Tab HotkeyPlay, % (Playing ? ButtonPause : ButtonPlay) A_Tab HotkeyPlay
			} Else If (TempGuiCommand = MenuSettingsCompactView) or (TempGuiCommand = HotkeyCompactView) {
				If (TempGuiCommand = HotkeyCompactView)
					Menu, %A_ThisFunc%MenuSettings, % (CompactView := !CompactView) ? "Check" : "Uncheck", %MenuSettingsCompactView%%A_Tab%%HotkeyCompactView%
				Loop % n := 10 {
					GuiControl, %GuiA%:Move, ErrorLevel, % "x" Margins " y" Margins + (Margins + ControlHeight) * (n - (@ := CompactView ? A_Index : n - A_Index)) / n " w" Width - ShrinkByW * @ / n " h" TreeViewHeight - ShrinkByH * @ / n
					Gui, %GuiA%:Show, % "NA w" Width + Margins * 2 - ShrinkByW * @ / n " h" TreeViewHeight + Margins * 4 + TextBoxHeight + ControlHeight - (ShrinkByH + TextBoxHeight + Margins * 2 + ControlHeight) * @ / n
				}
				Loop, Parse, Buttons, `,
					GuiControl, %GuiA%:Move, %A_LoopField%, % CompactView ? "y-200" : "y" Margins
			} Else If (TempGuiCommand = ButtonPrev) or (TempGuiCommand = HotkeyPrev) or (TempGuiCommand = MenuFilePrev)
				CurrentStep -= CurrentStep = 1 ? 0 : 1
			Else If (TempGuiCommand = "Normal") or (TempGuiCommand = MenuFileExit) {
				Gui, %GuiA%:Destroy
				Gui, %GuiB%:Destroy
				Hotkey, IfWinActive, ahk_id %GuiHWND%
				Loop, Parse, Hotkeys, `,
					If (Hotkey%A_LoopField% <> "")
						Hotkey, % Hotkey%A_LoopField%, Off
				Hotkey, IfWinActive
				Loop, Parse, Menus, `n
					Menu, % A_ThisFunc "Menu" SubStr(A_LoopField, 1, Instr(A_LoopField ":", ":") - 1), Delete
				DetectHiddenWindows, %DetectHiddenWindows%
				SetWinDelay, %WinDelay%
				Return GuiHWND := DxInfo := ""
			} Else If (TempGuiCommand = MenuSettingsAlwaysOnTop)
				WinSet, AlwaysOnTop, % AlwaysOnTop ? "On" : "Off", ahk_id %GuiHWND%
			Else If (TempGuiCommand = MenuSettingsWrapText)
				GuiControl, % GuiA ":" (WrapText ? "+Wrap" : "-Wrap"), Edit1 ; xxx doesn't work!!
			Else If (TempGuiCommand = MenuFileNext) or (TempGuiCommand = ButtonNext) or (TempGuiCommand = HotkeyNext) or ((TempGuiCommand = "") and Playing) {
				While (CurrentStep < Items) {
					CurrentStep += 1
					If (TempGuiCommand <> "") or !Playing or (%CurrentStep%_d <> "") or !SkipSteps
						Break
				}
				If (CurrentStep = Items) and (TempGuiCommand = "") and Playing
					GuiCommand := InStr(Options, ",c,") ? "Normal" : ButtonPause
			} Else If (InStr(TempGuiCommand, A_ThisFunc "Menu") <> 1) {
				If (InStr(TempGuiCommand, "RightClick:") = 1)
					RightClick := True, TV_Modify(@ := SubStr(TempGuiCommand, 12))
				Else
					@ := TV_GetSelection()
				Loop %Items%
					If (%A_Index%_ID = @) {
						CurrentStep := A_Index
						Break
					}
			} Else If (TempGuiCommand = A_ThisFunc "MenuCopy")
				Clipboard := A_ThisMenuItem = MenuCopyStepText ? CurrentStepText : A_ThisMenuItem = MenuCopyStepName ? CurrentStep " - " %CurrentStep%_Title : %A_ThisMenuItem%_Orig_
			Else If (A_ThisMenuItem = MenuFileEdit LastLine) or (A_ThisMenuItem = MenuSettingsEdit) {
				LineNumber := A_ThisMenuItem = MenuSettingsEdit ? DebugSettingsLocation : %CurrentStep%_l
				Transform, @, Deref, %EditorCommand%
				Run, "%EditorPath%" "%A_LineFile%" %@%, , UseErrorLevel
				If ErrorLevel
					MsgBox, 262144, %A_ScriptName% - %A_ThisFunc%: Alert, Check file`n`t%A_LineFile%`nline`n`t%LineNumber%`nto find this setting.`n`n`n(Note: To have this open your editor instead of showing a message box, check line %DebugSettingsLocation% and change the variables `%EditorPath`% and `%EditorCommand`%.)
			} Else If (A_ThisMenuItem = MenuFileSave) {
				Gui, %GuiA%:+OwnDialogs
				FileSelectFile, File, S, %A_ThisFunc%-dx-%A_Now%.txt
				If !ErrorLevel {
					FileDelete, %File%
					StringReplace, @, DxInfo, `r, `r`n, All
					FileAppend, %@%, %File%
					MsgBox, 262144, %A_ScriptName% - %A_ThisFunc%: Alert, Disgnostic file saved successfully.
				}
				Gui, %GuiA%:-OwnDialogs
			} Else If (TempGuiCommand = A_ThisFunc "MenuHelp") {
				If (A_ThisMenuItem = MenuHelpWhitespaceView)
					MsgBox, 262144, Whitespace Viewer Legend, If the "Show Whitespace" option is checked in the Settings menu, the following substitutions will be made for all non-visible characters:`n`n[EMPTY STRING]`ta blank/empty string`n[0 : FALSE]`t`t0 (`%false`%)`n[1 : TRUE]`t`t1 (`%true`%)`n[CR]`t`tcarriage return (``r)`n[NL]`t`tnewline (``n)`n[_]`t`tspace (`%A_Space`%)`n[ » ]`t`ttab (`%A_Tab`%)`n[Chr1], [Chr2], etc`tASCII character #1, #2, etc (these are non-visible characters)`n`nThese substitutions are not made when copying the contents of variables using the Clipboard menu.
				Else If (A_ThisMenuItem = MenuHelpAbout)
					MsgBox, 262144, About %A_ThisFunc%, FindClick() - ImageSearch utility. Created by berban.`n`nMade with AutoHotkey. Compatible with all versions.`n`nLast updated %LastUpdate%.
				Else If (A_ThisMenuItem = MenuHelpDocs)
					Run, %ForumURL%
				Else
					MsgBox, 262160, %A_ScriptName%: Error, This menu item currently doesn't do anything. Sorry about that. ; xxx
			} Else {
				If (TempGuiCommand = A_ThisFunc "MenuSettings") {
					If (Settings = "")
						RegExMatch(Menus, "\bSettings:\K\S*", Settings)
					Loop, Parse, Settings, `,
						If (A_LoopField <> "") and (InStr(A_ThisMenuItem A_Tab, MenuSettings%A_LoopField% A_Tab) = 1) {
							Menu, %A_ThisFunc%MenuSettings, % (%A_LoopField% := !%A_LoopField%) ? "Check" : "Uncheck", %A_ThisMenuItem%
							Break
						}
				}
				GuiCommand := SubStr(A_ThisMenuItem, 1, InStr(A_ThisMenuItem A_Tab, A_Tab) - 1), PreviousStep := 0
			}
			If (CurrentStep <> PreviousStep) {
				Loop, Parse, MenuCopyItems, `,
					If (A_LoopField <> "") {
						%A_LoopField%_ := %A_LoopField%_Orig_ := ""
						Menu, %A_ThisFunc%MenuCopy, Delete, %A_LoopField%
					}
				Loop, Parse, MenuHelpItems, `,
					If (A_LoopField <> "")
						Menu, %A_ThisFunc%MenuHelp, Delete, %A_LoopField%
				MenuCopyItems := MenuHelpItems := ""
				While (%CurrentStep%_c%A_Index% <> "") {
					@ := SubStr(%CurrentStep%_c%A_Index%, 1, InStr(%CurrentStep%_c%A_Index%, ":") - 1)
					, %@%_Orig_ := %A_ThisFunc%(">UnEscape<", SubStr(%CurrentStep%_c%A_Index%, InStr(%CurrentStep%_c%A_Index%, ":") + 1))
					, %@%_ := ShowChars ? %A_ThisFunc%(">ShowChars<", %@%_Orig_) : %@%_Orig_
					, MenuCopyItems .= @ ","
					Menu, %A_ThisFunc%MenuCopy, Add, %@%, %A_ThisFunc%Menu
				}
				Loop, Parse, %CurrentStep%_u, |
					If (A_LoopField <> "") {
						Menu, %A_ThisFunc%MenuHelp, Add, %A_LoopField%, %A_ThisFunc%Menu
						MenuHelpItems .= A_LoopField ","
					}
				PreviousStep := CurrentStep, @ := 0, CurrentStepText := %CurrentStep%_t
				Transform, CurrentStepText, Deref, % CurrentStepText := RegExReplace(CurrentStepText, "%([A-Za-z0-9_#@$?]+)%", "%$1_%") ; xxx
				While InStr(CurrentStepText, "<table>")
					CurrentStepText := %A_ThisFunc%(">Table<", CurrentStepText)
				StringReplace, CurrentStepText, CurrentStepText, `n, `r`n, All
				GuiControl, %GuiA%:, Edit1, %CurrentStepText%
				If %CurrentStep%_q
					While (%@%_Level > %CurrentStep%_Level) or !%@%_q
						@ := CurrentStep + A_Index
				Menu, %A_ThisFunc%MenuFile, Rename, %MenuFileEdit%%LastLine%, ----
				Menu, %A_ThisFunc%MenuFile, Rename, ----, % MenuFileEdit LastLine := A_Space %CurrentStep%_l
				Menu, %A_ThisFunc%MenuFile, % %CurrentStep%_l ? "Enable" : "Disable", %MenuFileEdit%%LastLine%
				ControlSetText, Edit2, % "Time (ms):  " (%CurrentStep%_q ? Round((%@%_q - %CurrentStep%_q) * QPC_Rate, 3) : "") "`r`nLine No.:   " %CurrentStep%_l, ahk_id %GuiHWND%
				Gui, %GuiB%:Destroy
				If (%CurrentStep%_g <> "") and ShowGraphics {
					@ := CurrentStep, @1 := Asc(%CurrentStep%_g) = 43 ? 1 : Asc(%CurrentStep%_g) = 45 ? -1 : 0
					If @1
						While !RegExMatch(%@%_Title, "is)^" SubStr(%CurrentStep%_g, 2) "$") and @ and (@ <= Items)
							@ += @1
					If (%@%_g <> "")
						%A_ThisFunc%(">NewGui<", GuiB ";+ToolWindow -SysMenu -Caption +AlwaysOnTop +E0x20;" %@%_g)
					Else
						MsgBox, 262160, %A_ScriptName%: Error, Error with referenced graphics!!!! Fix me ben! ; xxx
				}
				TempGuiCommand := GuiCommand, TV_Modify(%CurrentStep%_ID)
			}
			If RightClick
				Menu, %A_ThisFunc%MenuContext, Show
			If (GuiCommand = "") {
				WinSetTitle, ahk_id %GuiHWND%, , % GuiTitle := A_ThisFunc " Debugger" (Playing ? " - " PlayingText : "") ": " CurrentStep " - " %CurrentStep%_Title
				WinWaitClose, %GuiTitle% ahk_id %GuiHWND%, , Playing ? ((%CurrentStep%_d ? %CurrentStep%_d : 1) * PlaySpeed) : ""
			}
		}
	} Else If (GuiHWND = "") { ;--------------------------------------------------Screenshot Builder--------------------------------------------------
		CoordMode, Mouse, Screen
		CoordMode, Pixel, Screen
		CoordMode, Menu, Screen
		;||||||||||||||||||||||||||||||||||| Screenshot Builder Settings ||||||||||||||||||||||||||||||||||||
		;----------------------------------------- General Settings -----------------------------------------
		TempFile = %A_Temp%\%A_ThisFunc%Temp.png ; Directory where a temporary imagefile will be created (ImageSearch only accepts an imagefile as input)
		NewFilePlaceHolder = NewFile             ; The filename that will populate the field if none is provided. Omit the extension unless %DefaultExts% has also been omitted
		PauseHotkey = ^+                         ; Hotkey that pauses updating of the screen magnifier, allowing you to select a screenshot region and add options
		SquareSize = 19                          ; Width and height of each magnifier color square, in pixels
		SquaresWide = 25                         ; Width in color squares of the magnifier. Also signifies the width of the region to be magnified, in pixels
		SquaresHigh = 25                         ; Same as above for height
		SquareSpacing = 2                        ; Spacing between the color squares, in pixels
		ControlHeight = 20                       ; Height of GUI elements, in pixels
		Margins = 10                             ; Spacing between gui controls, in pixels
		FontSize = 10                            ; Font size, in points
		FontFace = Segoe UI                      ; Name of the font used for textual gui elements
		SelectionColor = 0xFF0000                ; Color of the screenshot region selection rectangle
		CurRegionColor = 0x0000FF                ; Color of the box that indicates what part of the screen is currently being magnified
		CurRegionThickness = 3                   ; Thickness of this box, in pixels
		GuiX =                                   ; X-coordinate where the dialog is shown (leave blank for center of screen)
		GuiY =                                   ; Y-coordinate where the dialog is shown (leave blank for center of screen)
		DoubleTapToSelect = %True%               ; Normally, selecting a screenshot region is done by clicking & dragging. Indicating %True% here means you must instead click to begin selection and then click again to stop. Leave as %False% unless this behavior gives issues
		PromptOnOverwrite = %True%               ; If the output file already exists, it will be overwritten without asking
		RecycleOnOverwrite = %False%             ; When overwriting an output file, the existing file will be recycled instead of deleted permanently
		AutoJumpToFileName = %True%              ; Will send focus to the filename portion of the output file field upon unpause or change of file name
		InputBoxWidth = 300                      ; Width of the dialog box used for adding new options
		StartPaused = %False%                    ; Magnifier will start paused when the gui is created
		AllowOffset = %False%                    ; True to have this checkbox cleared by default
		DiagnosticMode = %True%                  ; True to have this checkbox cleared by default
		DiagnosticModeOptions = Playing=0        ; Diagnostic Mode options that will be applied when you press the test button with the diagnostic mode box checked. Analogous to appending "dx<options>" to the test options field
		CopyToClipboard = %False%                ; True to have this checkbox cleared by default
		;----------------------------------------- Gui Text Elements ----------------------------------------
		; Edit the variables below to change the text of the buttons and other elements in the image creator GUI. This can be done to change the language of the interface, or to change the accelerator keys (using the "&" symbol).
		CheckboxOffset = Allow O&ffset
		ButtonPause = &Pause ( %PauseHotkey% )
		ButtonUnPause = Un&pause (%PauseHotKey% )
		ButtonTest = &Test
		ButtonSave = &Save
		ButtonBrowse = &Browse
		ButtonOther = &Other
		ButtonCancel = &Cancel
		ButtonAddOption = &Add option...
		ButtonJumpToFileName = &I
		CheckboxCopyToClipboard = Copy code to c&lipboard
		CheckboxDiagnosticMode = &Use diagnostic mode:
		ButtonInputBoxAdd = &Add
		ButtonInputBoxCancel = &Cancel
		ButtonInputBoxHelp = &Help
		;||||||||||||||||||||||||||||||||||||||||||| End Settings |||||||||||||||||||||||||||||||||||||||||||
		CenterX := SquaresWide // 2, CenterY := SquaresHigh // 2, OffsetX := 0, OffsetY := 0, Cache := ">2" Cache, OptionInfo := SubStr(%A_ThisFunc%(A_Space), 2), WinDelay := A_WinDelay
		Loop, Parse, OptionInfo, `r
		{
			Loop, Parse, A_LoopField, `n
			{
				StringSplit, @, A_LoopField, %A_Tab%
				If (A_Index = 1)
					Item := @1, @1 := "Main"
				If (@2 <> "")
					StringReplace, @, @1, %A_Space%, , All
				OptionInfo_%Item%_%@% .= @2 = "" ? "`n`n" @1 : @2, @2 := ""
			}
			Menu, %A_ThisFunc%OptionInfo, Add, % Item A_Tab OptionInfo_%Item%_Main, %A_ThisFunc%Menu
		}
		OptionInfo := GuiTitle := "", LastPos := "x-300 y-300 w10 h10"
		Loop {
			If (FilePaths = "") {
				StringReplace, ImageFile, ImageFile, >, , UseErrorLevel
				AbsolutePath := (ErrorLevel - 1) * (ImageFile <> "")
				SplitPath, ImageFile, , @1, @2, @3, @4
				If (@2 <> "")
					@2 := "." @2
				Else If (DefaultExts <> "")
					@2 := "." SubStr(DefaultExts, 1, InStr(DefaultExts, "|") - 1)
				If (@3 = "")
					@3 := NewFilePlaceHolder
				FilePaths := "|" (@4 = "" ? "" : @1 "\" @3 @2 "|")
				If !AbsolutePath or (@4 = "")
					FilePaths .= RegExReplace(DefaultDirs, "\\?(\||$)", (@4 = "" ? "\" @1 : "") "\" @3 @2 "$1")
				While InStr(FilePaths, "\\")
					StringReplace, FilePaths, FilePaths, \\, \, All
				StringReplace, FilePaths, FilePaths, |\, |\\, All
				FilePaths := RegExReplace(FilePaths, "\\\K[^\\|]+\\\.\.\\") "|", Destination := SubStr(FilePaths, 2, InStr(FilePaths,  "|", 0, 2) - 2)
			}
			StringReplace, TempFilePaths, FilePaths, |%Destination%|, |, All
			GuiCommand := A_Index <> 1 or StartPaused ? ButtonPause : ButtonUnpause
			, LastItem := 1
			, VarSetCapacity(GuiHWND, 18000)
			, GuiHWND := GuiA . ";+AlwaysOnTop +Label" A_ThisFunc . ";Add,Progress,-0x20000 " LastPos " c" SelectionColor ",100;"
			While (SquaresHigh >= @ := A_Index)
				Loop % SquaresWide
					GuiHWND .= "Add,Progress,-0x20000 c" Color_%A_Index%_%@% " x" Margins + (SquareSize + SquareSpacing) * (A_Index - 1) " y" Margins + (SquareSize + SquareSpacing) * (@ - 1) " w" SquareSize + 1 " h" SquareSize + 1 ",100;"
			GuiHWND .= "Font,s" FontSize "," FontFace . ";Add,Text,x" Margins " y+" Margins + 4 " w" (@ := Ceil(((SquareSize + SquareSpacing) * SquaresWide - SquareSpacing - Margins * 4) / 5)) " h" ControlHeight ",Dimensions" . ";Add,Edit,+ReadOnly x+" Margins " yp-4 w" @ " hp," SquaresWide "x" SquaresHigh . ";Add,Text,x+" Margins " yp+4 w" @ " hp,Color (" (UseRGB ? "RGB" : "BGR") ")" . ";Add,Edit,+ReadOnly x+" Margins " yp-4 w" @ " hp," CurrentColor . ";Add,Text,x" Margins " y+" Margins + 4 " w" @ " hp,Mouse Pos" . ";Add,Edit,+ReadOnly x+" Margins " yp-4 w" @ " hp" . ";Add,CheckBox," (AllowOffset ? "Checked " : "") "x+" Margins " yp w" @ * 2 + Margins " hp," CheckboxOffset " (+0 +0)" . ";Add,Button,+Center g" A_ThisFunc "Close x" Margins * 5 + @ * 4 " yp-" Margins + ControlHeight " w" @ " h" ControlHeight * 2 + Margins "," ButtonPause . ";Add,GroupBox,x" Margins " y+" Margins " w" (SquareSize + SquareSpacing) * SquaresWide - SquareSpacing " h" ControlHeight * 2 + Margins * 4 "," A_ThisFunc " Options" . ";Add,Edit,xp+" Margins " yp+" Margins * 2 " w" (@ := Ceil(((SquareSize + SquareSpacing) * SquaresWide - SquareSpacing - Margins * 5) / 4)) * 3 + Margins * 2 " h" ControlHeight "," Options . ";Add,Button,g" A_ThisFunc "Close xp y+" Margins " w" @ " hp HwndGuiTitle," ButtonAddOption
			GuiHWND := %A_ThisFunc%(">NewGui<", GuiHWND . ";Add,Checkbox," (DiagnosticMode ? "+Checked " : "") "g" A_ThisFunc "Close x+" Margins " yp hp," CheckboxDiagnosticMode . ";Add,Edit," (DiagnosticMode ? "" : "+ReadOnly ") "x+" Margins " yp w" @ / 2 " hp," DiagnosticModeOptions . ";Add,Button,g" A_ThisFunc "Close x" Margins * 5 + @ * 3 " yp-" ControlHeight + Margins " w" @ " h" ControlHeight * 2 + Margins "," ButtonTest . ";Add,GroupBox,x" Margins " y+" Margins * 2 " w" (SquareSize + SquareSpacing) * SquaresWide - SquareSpacing " h" ControlHeight * 2 + Margins * 5 ",Output File" . ";Add," (AbsolutePath ? "DropDownList" : "ComboBox") ",g" A_ThisFunc "Close vErrorLevel +AltSubmit xp+" Margins " yp+" Margins * 2 " w" @ * 4 + Margins * 3 - (AbsolutePath ? 0 : Margins + ControlHeight) "," Destination "|" SubStr(TempFilePaths, 1, -1) . (AbsolutePath ? "" : ";Add,Button,g" A_ThisFunc "Close x+" Margins " yp w" ControlHeight " hp," ButtonJumpToFileName) . ";Add,Checkbox," (CopyToClipboard ? "+Checked " : "") "x" Margins * 2 " y+" Margins " hp," CheckboxCopyToClipboard . ";Add,Button,g" A_ThisFunc "Close xp+" @ * 2 + Margins * 2 " yp w" @ " hp" (AbsolutePath > 1 ? " +Disabled" : "") "," (AbsolutePath ? ButtonOther : ButtonBrowse) . ";Add,Button,+Default g" A_ThisFunc "Close x+" Margins " yp w" @ " hp," ButtonSave . ";Show,Hide w" (SquareSize + SquareSpacing) * SquaresWide - SquareSpacing + Margins * 2 " y" (GuiY = "" ? (A_ScreenHeight - Margins * 16 - ControlHeight * 4 - (SquareSize + SquareSpacing) * SquaresHigh + SquareSpacing) // 2 : GuiY " x" GuiX) "," A_ThisFunc " Screenshot Creator"), OptionsHWND := GuiTitle, GuiTitle := A_ThisFunc " Screenshot Creator:"
			Hotkey, IfWinExist, ahk_id %GuiHWND%
			Hotkey, ~LButton, %A_ThisFunc%Close, On
			Hotkey, %PauseHotkey%, %A_ThisFunc%Close, On
			Hotkey, IfWinExist
			Loop {
				TempGuiCommand := GuiCommand, GuiCommand := ""
				If (TempGuiCommand = "ErrorLevel") {
					GuiControlGet, @, %GuiA%:FocusV
					If (@ = "ErrorLevel") {
						ControlGetText, Destination, ComboBox1, ahk_id %GuiHWND%
						If AutoJumpToFileName and !AbsolutePath {
							GuiControlGet, ThisItem, %GuiA%:, ErrorLevel
							If (ThisItem < 100) and (ThisItem <> LastItem)
								GuiCommand := ButtonJumpToFileName, LastItem := ThisItem
						}
					} Else
						GuiControl, %GuiA%:Focus, ErrorLevel
				} Else If (TempGuiCommand = PauseHotkey) or (TempGuiCommand = ButtonUnpause) or (TempGuiCommand = ButtonPause) {
					If (TempGuiCommand <> ButtonPause) {
						Gui, %GuiA%:Show, % "NA h" Margins * 4 + 1 + ControlHeight * 2 + (SquareSize + SquareSpacing) * SquaresHigh - SquareSpacing
						ControlSetText, Button2, %ButtonPause%, ahk_id %GuiHWND%
						GuiControl, %GuiA%:, Edit2
						WinSet, AlwaysOnTop, On, ahk_id %GuiHWND%
						If (A_Index <> 1) {
							ControlGet, AllowOffset, Checked, , Button1, ahk_id %GuiHWND%
							If AllowOffset and (MouseX <> "") {
								MouseGetPos, MouseX2, MouseY2
								OffsetX := MouseX2 - MouseX, OffsetY := MouseY2 - MouseY
							} Else
								OffsetX := 0, OffsetY := 0
							ControlSetText, Button1, % CheckboxOffset " (" (OffsetX < 0 ? "+" : "") 0 - OffsetX ", " (OffsetY < 0 ? "+" : "") 0 - OffsetY ")", ahk_id %GuiHWND%
						}
						If !WinExist("ahk_id " BoxHWND)
							BoxHWND := %A_ThisFunc%(">NewGui<", GuiB . ";Color," CurRegionColor . ";+ToolWindow -SysMenu -Caption +AlwaysOnTop +E0x20" . ";Show,NA x-100 y-100 w" SquaresWide + CurRegionThickness * 2 " h" SquaresHigh + CurRegionThickness * 2 . ";Trans,200" . ";Region,0-0 " SquaresWide + CurRegionThickness * 2 "-0 " SquaresWide + CurRegionThickness * 2 "-" SquaresHigh + CurRegionThickness * 2 " 0-" SquaresHigh + CurRegionThickness * 2 " 0-0 " CurRegionThickness "-" CurRegionThickness " " CurRegionThickness + SquaresWide "-" CurRegionThickness " " CurRegionThickness + SquaresWide "-" CurRegionThickness + SquaresHigh " " CurRegionThickness "-" CurRegionThickness + SquaresHigh " " CurRegionThickness "-" CurRegionThickness)
						If A_PtrSize ; Start GDI+
							Ptr := "UPtr", PtrA := "UPtr*"
						Else
							Ptr := "UInt", PtrA := "UInt*"
						If !DllCall("GetModuleHandle", "str", "gdiplus", Ptr)
							DllCall("LoadLibrary", "str", "gdiplus")
						VarSetCapacity(si, A_PtrSize = 8 ? 24 : 16, 0), si := Chr(1), DllCall("gdiplus\GdiplusStartup", PtrA, pToken, Ptr, &si, Ptr, 0)
						GuiCommand := "~LButton"
						While (GuiCommand = "~LButton") {
							MouseGetPos, MouseX, MouseY
							MouseX -= OffsetX, MouseY -= OffsetY
							Gui, %GuiB%:Show, % "NA x" MouseX - CenterX - CurRegionThickness " y" MouseY - CenterY - CurRegionThickness
							chdc := DllCall("CreateCompatibleDC", Ptr, False), hdc2 := chdc ? chdc : DllCall("GetDC", Ptr, False), VarSetCapacity(bi, 40, 0), NumPut(SquaresWide, bi, 4, "uint"), NumPut(SquaresHigh, bi, 8, "uint"), NumPut(40, bi, 0, "uint"), NumPut(1, bi, 12, "ushort"), NumPut(0, bi, 16, "uInt"), NumPut(32, bi, 14, "ushort"), hbm := DllCall("CreateDIBSection", Ptr, hdc2, Ptr, &bi, "uint", 0, PtrA, False, Ptr, 0, "uint", 0, Ptr) ; Gdip_BitmapFromScreen
							If !chdc
								DllCall("ReleaseDC", Ptr, False, Ptr, hdc2)
							obm := DllCall("SelectObject", Ptr, chdc, Ptr, hbm), hhdc := DllCall("GetDC", Ptr, False), DllCall("gdi32\BitBlt", Ptr, chdc, "int", 0, "int", 0, "int", SquaresWide, "int", SquaresHigh, Ptr, hhdc, "int", MouseX - CenterX, "int", MouseY - CenterY, "uint", 0x00CC0020), DllCall("ReleaseDC", Ptr, False, Ptr, hhdc), DllCall("gdiplus\GdipCreateBitmapFromHBITMAP", Ptr, hbm, Ptr, False, PtrA, pBitmap), DllCall("SelectObject", Ptr, chdc, Ptr, obm), DllCall("DeleteObject", Ptr, hbm), DllCall("DeleteDC", Ptr, hhdc), DllCall("DeleteDC", Ptr, chdc)
							While (SquaresHigh >= @ := A_Index)
								Loop %SquaresWide% {
									SetFormat, Integer, Hex
									DllCall("gdiplus\GdipBitmapGetPixel", Ptr, pBitmap, "int", CenterX + A_Index - Floor(SquaresWide / 2) - 1, "int", CenterY + @ - Floor(SquaresHigh / 2) - 1, "uint*", Color), Color := Color & 0x00ffffff ; Gdip_GetPixel
									SetFormat, Integer, Decimal
									GuiControl, % GuiA ":+c" SubStr(Color_%A_Index%_%@% := Color, 3), % "msctls_progress32" 1 + (@ - 1) * SquaresWide + A_Index
								}
							ControlSetText, Edit3, %MouseX% `, %MouseY%, ahk_id %GuiHWND%
							DllCall("gdiplus\GdipDisposeImage", Ptr, pBitmap) ; Dispose Image
						}
						WinSet, AlwaysOnTop, Off, ahk_id %GuiHWND%
						MouseGetPos, OffsetX, OffsetY
						OffsetX -= MouseX, OffsetY -= MouseY
						DllCall("gdiplus\GdiplusShutdown", Ptr, pToken) ; Shutdown
						If (hModule := DllCall("GetModuleHandle", "str", "gdiplus", Ptr))
							DllCall("FreeLibrary", Ptr, hModule)
					} ; End GDI+
					Gui, %GuiA%:Show, % "h" Margins * 17 + 1 + ControlHeight * 5 + (SquareSize + SquareSpacing) * SquaresHigh - SquareSpacing
					ControlSetText, Button2, %ButtonUnpause%, ahk_id %GuiHWND%
					GuiCommand := GuiCommand = "Normal" ? "Normal" : !AbsolutePath and AutoJumpToFileName ? ButtonJumpToFileName : "ErrorLevel"
				} Else If (TempGuiCommand = ButtonAddOption) {
					WinGetPos, @1, @2, , @3, ahk_id %OptionsHWND%
					Menu, %A_ThisFunc%OptionInfo, Show, % @1 + 1, % @2 + @3 - 1
				} Else If (TempGuiCommand = ButtonJumpToFileName) {
					SplitPath, Destination, , @1, , @2
					ControlFocus, ComboBox1, ahk_id %GuiHWND%
					SendMessage, 0xB1, StrLen(@1) + 1, StrLen(@1 @2) + 1, Edit6, ahk_id %GuiHWND%
				} Else If (TempGuiCommand = ButtonBrowse) {
					ControlGetText, FilePaths, ComboBox1, ahk_id %GuiHWND%
					Gui, %GuiA%:+OwnDialogs
					FileSelectFile, Destination, , %FilePaths%, , % "Screenshot Files (" SubStr(RegExReplace(DefaultExts, "(?:\||^)\.?(\w+)", "*.$1;"), 1, -1) ")"
					If !ErrorLevel
						ControlSetText, Edit6, % Destination .= InStr(Destination, ".", 0, InStr("\" Destination, "\", 0, 0)) ? "" : SubStr(DefaultExts, 1, InStr(DefaultExts, "|") - 1), ahk_id %GuiHWND%
					Gui, %GuiA%:-OwnDialogs
					GuiCommand := AutoJumpToFileName ? ButtonJumpToFileName : "ErrorLevel"
				} Else If (TempGuiCommand = ButtonOther) {
					WinGetPos, GuiX, GuiY, , , ahk_id %GuiHWND%
					ImageFile := ">" ImageFile, GuiHWND := FilePaths := ""
					Break
				} Else If (TempGuiCommand = CheckboxDiagnosticMode) {
					ControlGet, DiagnosticMode, Checked, , Button5, ahk_id %GuiHWND%
					GuiControl, % GuiA ":" (DiagnosticMode ? "-" : "+") "ReadOnly", Edit5
				} Else If (TempGuiCommand = A_ThisFunc "OptionInfo") {
					@ := SubStr(A_ThisMenuItem, 1, InStr(A_ThisMenuItem, A_Tab) - 1)
					Gui, %GuiA%:+Disabled
					WinWaitClose, % "ahk_id " %A_ThisFunc%(">NewGui<", GuiB . ";+Label" A_ThisFunc " +Owner" GuiA . ";Add,Text,x" Margins " y" Margins " w" InputBoxWidth "," OptionInfo_%@%_Description "`n`nDefault:`t`t" OptionInfo_%@%_Default "`nUser Default:`t" OptionInfo_%@%_UserDefault . ";Add,Edit,xp y+" Margins " wp h" ControlHeight . ";Add,Button,g" A_ThisFunc "Close xp y+" Margins " w" (InputBoxWidth - Margins * 2) // 3 " hp," ButtonInputBoxHelp . ";Add,Button,g" A_ThisFunc "Close x+" Margins " yp wp hp," ButtonInputBoxCancel . ";Add,Button,g" A_ThisFunc "Close x+" Margins " yp wp hp +Default," ButtonInputBoxAdd . ";Show,w" InputBoxWidth + Margins * 2 ",Add Option: " @ " - " OptionInfo_%@%_Main)
					Gui, %GuiA%:-Disabled
					TempGuiCommand := GuiCommand, GuiCommand := ""
					If (InStr(TempGuiCommand, ButtonInputBoxAdd) = 1) {
						NewOption := SubStr(TempGuiCommand, InStr(TempGuiCommand, "`n") + 1)
						If InStr(NewOption, A_Space) or InStr(NewOption, Literal) {
							StringReplace, NewOption, NewOption, %Literal%, %Literal%%Literal%, All
							NewOption := Literal NewOption Literal
						}
						ControlGetText, Options, Edit4, ahk_id %GuiHWND%
						ControlSetText, Edit4, % (Options .= SubStr(A_Space Options, 0) = A_Space ? "" : A_Space) @ NewOption, ahk_id %GuiHWND%
						ControlFocus, Edit4, ahk_id %GuiHWND%
						SendMessage, 0xB1, @1 := StrLen(Options), @2 := @1 + StrLen(@ NewOption), Edit4, ahk_id %GuiHWND%
						Sleep 200
						SendMessage, 0xB1, @1 + StrLen(@), @2, Edit4, ahk_id %GuiHWND%
					} Else If (InStr(TempGuiCommand, ButtonInputBoxHelp) = 1)
						Run, %ForumURL%
					;~ GuiCommand := "ErrorLevel"
				} Else If InStr(TempGuiCommand, "LButton") {
					MouseGetPos, , , MouseWin, MouseControl1
					If (MouseWin = GuiHWND)
						If (InStr(MouseControl1, "msctls_progress32") = 1) and (MouseControl1 <> "msctls_progress321") {
							GuiControlGet, Con1, %GuiA%:Pos, %MouseControl1%
							While (!DoubleTapToSelect and GetKeyState("LButton", "P")) or (DoubleTapToSelect and (GuiCommand = "")) {
								MouseGetPos, , , MouseWin, MouseControl
								If (MouseControl <> MouseControl2) and (InStr(MouseControl, "msctls_progress32") = 1) and (MouseControl <> "msctls_progress321") {
									GuiControlGet, Con2, %GuiA%:Pos, % MouseControl2 := MouseControl
									GuiControl, %GuiA%:MoveDraw, msctls_progress321, % LastPos := "x" (Con1X < Con2X ? Con1X : Con2X) - SquareSpacing - 1 " y" (Con1Y < Con2Y ? Con1Y : Con2Y) - SquareSpacing - 1 " w" Abs(Con2X - Con1X) + SquareSize + SquareSpacing * 2 + 3 " h" Abs(Con2Y - Con1Y) + SquareSize + SquareSpacing * 2 + 3
									GuiControl, %GuiA%:, Edit1, % Round((Abs(Con2X - Con1X) + SquareSize + SquareSpacing) / (SquareSize + SquareSpacing)) "x" Round((Abs(Con2Y - Con1Y) + SquareSize + SquareSpacing) / (SquareSize + SquareSpacing))
									@1 := Round((Con2X + SquareSize - Margins + SquareSpacing) / (SquareSize + SquareSpacing)), @2 := Round((Con2Y + SquareSize - Margins + SquareSpacing) / (SquareSize + SquareSpacing))
									GuiControl, %GuiA%:, Edit2, % CurrentColor := UseRGB ? Color_%@1%_%@2% : "0x" SubStr(Color_%@1%_%@2%, 7) SubStr(Color_%@1%_%@2%, 5, 2) SubStr(Color_%@1%_%@2%, 3, 2)
								}
								Sleep 10
							}
							Con1Y := Ceil((SubStr(MouseControl1, 18) - 1) / SquaresWide), Con1X := SubStr(MouseControl1, 18) - 1 - SquaresWide * (Con1Y - 1), Con2Y := Ceil((SubStr(MouseControl2, 18) - 1) / SquaresWide), Con2X := SubStr(MouseControl2, 18) - 1 - SquaresWide * (Con2Y - 1), X1 := Con1X < Con2X ? Con1X : Con2X, Y1 := Con1Y < Con2Y ? Con1Y : Con2Y, X2 := Con1X > Con2X ? Con1X : Con2X, Y2 := Con1Y > Con2Y ? Con1Y : Con2Y, GuiCommand := ""
						} Else If (MouseControl1 = "") or (MouseControl1 = "Button3") or (MouseControl1 = "Button7") or (InStr(MouseControl1, "Static") = 1) {
							WinGetPos, WinX, WinY, , , ahk_id %GuiHWND%
							MouseGetPos, MouseX1, MouseY1
							While GetKeyState("LButton", "P") {
								MouseGetPos, MouseX2, MouseY2
								WinMove, ahk_id %GuiHWND%, , WinX + MouseX2 - MouseX1, WinY + MouseY2 - MouseY1
							}
						}
				} Else {
					If (TempGuiCommand = ButtonSave) or (TempGuiCommand = ButtonTest) {
						Gui, %GuiA%:+OwnDialogs
						If (TempGuiCommand = ButtonTest) {
							OutputFile := TempFile
							ControlGet, DiagnosticMode, Checked, , Button5, ahk_id %GuiHWND%
							ControlGetText, DiagnosticModeOptions, Edit5, ahk_id %GuiHWND%
							WinGetPos, GuiX, GuiY, , , ahk_id %GuiHWND%
						} Else
							OutputFile := Destination
						SplitPath, OutputFile, , , Extension, Name
						If (Extension <> "")
							StringTrimRight, OutputFile, OutputFile, StrLen(Extension) + 1
						If Extension Not In bmp,dib,rle,jpg,jpeg,jpe,jfif,gif,tif,tiff,png
						{
							MsgBox, 262148, %A_ScriptName%: Input Required, % "You have chosen the following file extension:`n`n" Extension "`n`nThis is not a valid screenshot filetype.`n`nPress YES to use the .png (the recommended filetype for screenshot files.)`n`nPress NO to enter a different file extension. Supported filetypes are bmp, dib, rle, jpg, jpeg, jpe, jfif, gif, tif, tiff, and png." (TempGuiCommand = ButtonTest ? "`n`nTo fix this problem while testing, replace the %TempFile% path declaration in the function code." : "")
							IfMsgBox YES
								Extension := "png"
							Else
								TempGuiCommand := GuiCommand := "ErrorLevel"
						}
						If (TempGuiCommand = ButtonSave) {
							If InStr(@ := FileExist(OutputFile "." Extension), "D") {
								MsgBox, 262160, %A_ScriptName%: Error, Please enter a file name.
								GuiCommand := "ErrorLevel"
							} Else If (@ <> "") {
								If PromptOnOverWrite {
									MsgBox, 262148, %A_ScriptName%: Input Required, File "%OutputFile%.%Extension%" already exists. Overwrite it?
									IfMsgBox No
										TempGuiCommand := GuiCommand := "ErrorLevel"
								}
								If (GuiCommand <> "ErrorLevel")
									If RecycleOnOverWrite
										FileRecycle, %OutputFile%.%Extension%
									Else
										FileDelete, %OutputFile%.%Extension%
							}
						} Else If (TempGuiCommand = ButtonTest)
							FileDelete, %OutputFile%.%Extension%
						ControlGetText, Options, Edit4, ahk_id %GuiHWND%
						ControlGet, CopyToClipboard, Checked, , Button9, ahk_id %GuiHWND%
					}
					If (GuiCommand <> "ErrorLevel") {
						Gui, %GuiA%:Destroy
						Gui, %GuiB%:Destroy
						Hotkey, IfWinExist, ahk_id %GuiHWND%
						Hotkey, ~LButton, Off
						Hotkey, %PauseHotkey%, Off
						Hotkey, IfWinExist
						SetWinDelay, %WinDelay%
					} Else
						Gui, %GuiA%:-OwnDialogs
					If (TempGuiCommand = ButtonSave) or (TempGuiCommand = ButtonTest) {
						If (X1 = "")
							X1 := 1, Y1 := 1, X2 := SquaresWide, Y2 := SquaresHigh
						VarSetCapacity(Colors, (X2 - X1 + 1) * (Y2 - Y1 + 1) * 7) ; Width := X2 - X1 + 1, Height := Y2 - Y1 + 1
						While (Y2 >= IndexY := A_Index + Y1 - 1)
							While (X2 >= IndexX := A_Index + X1 - 1)
								Colors .= "|" SubStr(Color_%IndexX%_%IndexY%, 3)
						%A_ThisFunc%(">MakeImage<", "" OutputFile "|" Extension "|" X2 - X1 + 1 "|" Y2 - Y1 + 1 Colors)
					}
					If (TempGuiCommand = ButtonTest) {
						%A_ThisFunc%(OutputFile "." Extension, Options (DiagnosticMode ? (SubStr(A_Space Options, 0) = A_Space ? "" : A_Space) "dx" DiagnosticModeOptions : ""))
						FileDelete, %OutputFile%.%Extension%
						%A_ThisFunc%(">ParseCache<", OutputFile "." Extension), LastImageFile := ""
						Break
					} Else If (GuiCommand <> "ErrorLevel") {
						GuiHWND := ""
						If (TempGuiCommand = ButtonSave) {
							FileCreateDir, % SubStr(OutputFile, 1, InStr(OutputFile, "\", 0, 0))
							Cache := Name A_Tab OutputFile "." Extension A_Tab X2 - X1 + 1 "|" Y2 - Y1 + 1 "||`n" Cache, FoundX := OutputFile "." Extension, FoundY := Options
							If CopyToClipboard {
								DefaultDirs := SubStr(RegExReplace(DefaultDirs "|", "\\*(?:\||^)+", "\|"), 3, -1), DefaultExts := SubStr(RegExReplace("|" DefaultExts "|", "\|\.*", "|."), 2, -2), OutputFile := "|" OutputFile "|"
								Loop, Parse, DefaultDirs, |
									StringReplace, OutputFile, OutputFile, |%A_LoopField%
								Loop, Parse, DefaultExts, |
									StringReplace, OutputFile, OutputFile, %A_LoopField%|
								StringReplace, OutputFile, OutputFile, |, , All
								StringReplace, Options, Options, ", "", All ;"
								Clipboard := A_ThisFunc "(""" OutputFile """" (Options = "" ? "" : ", """ Options """") ")"
							}
							Return True
						}
						Return False
					}
				}
				If (GuiCommand = "") {
					WinSetTitle, ahk_id %GuiHWND%, , % GuiTitle := A_ThisFunc " Screenshot Creator: Paused"
					WinWaitClose, %GuiTitle% ahk_id %GuiHWND%
				}
			}
		}
	} Else
		MsgBox, 262160, %A_ScriptName% - %A_ThisFunc%(): Error, The image creator is already running.`n`nPlease finish the current task before continuing.
	Return
	FindClickMenu:
	FindClickClose:
	FindClickEscape:
	Return FindClick(">GuiEvent<")
}
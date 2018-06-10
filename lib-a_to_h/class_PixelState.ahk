;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;  PixelState class
;;;;;;;;;;;;;;;;;;;;;;;;;;;

class PixelState {

    static LogFolder := "logs\PixelState"
    static LogFile := "pixelstate-main.log"
    static GameStates := ["InRealm", "InNexus", "InChar", "InBlackLoading", "InVault", "InMain", "InGreen", "InOptions"]

    ;;  run a task to check if jobs need to be ran
    BackgroundTasksMain(options=false) {

        global PixelTrack

        if ( CheckRun() == true ) {

            ;;  we use the time to identify this iterations id
            Time := A_Now

            ;;  import any supplied options
            for key, value in options {
                %key% := value
            }

            ;;  cleanup old shared bitmaps
            this.DestroyBitmap(true)

            ;;  take a new screenshot
            PixelTrack.SharedBitmap[Time] := this.GetBitmap()

            ;;;;  process actions

            ;;  get current game location
            PixelTrack.CurrentLocation := this.GetGameState(PixelTrack.SharedBitmap[Time])

            ;;  get current hp
            PixelTrack.CurrentHP := this.check.PlayerHP(PixelTrack.SharedBitmap[Time])

        }

        return true

    }

    ;;  return a bitmap of the active window
    GetBitmap(shared=false, age=0) {

        global PixelTrack
        WinGetPos, X, Y, Width, Height, A
        GameWindow := this.tools.GetGameWindow()
        ScreenMode := this.tools.GetScreenMode()

        ;;  shared bitmap requested; return if available
        Time := Round(A_Now-age)
        if ( shared == true )
            if ( PixelTrack.SharedBitmap[Time] )
                return PixelTrack.SharedBitmap[Time]

        ;;  fullscreen means we take an image of the whole screen
        if ( ScreenMode == false || ScreenMode == "fullscreen" )
            return Gdip_BitmapFromScreen(X "|" Y "|" Width "|" Height)

        ;;  steam windowed mode has an outer 16x38 border
        if ( ScreenMode == "windowed" && GameWindow == "steam" )
            return Gdip_BitmapFromScreen(Round(X+8) . "|" . Round(Y+30) . "|" . Round(Width-16) . "|" . Round(Height-38))

        ;;  flash windowed mode has an outer 16x59 border
        if ( ScreenMode == "windowed" && GameWindow == "flash" )
            return Gdip_BitmapFromScreen(Round(X+8) . "|" . Round(Y+51) . "|" . Round(Width-16) . "|" . Round(Height-59))

        ;;  would be easy to add a custom setting here in case there are special cases out there

    }

    ;;  complete image debug processing and dispose the screenshot
    DestroyBitmap(ByRef pBitmap, age=false) {

        global PixelTrack, PixelStateSharedBitmapKeep, Debug

        ;;  processing debug pixel storage
        if ( Debug == true && PixelTrack.debug[pBitmap] ) {

            ;;  add the pixels
            for index, PixelData in PixelTrack.debug[pBitmap] {

                Gdip_SetPixel(pBitmap, PixelData.x, PixelData.y, PixelData.argb)

            }

            this.SaveImage(pBitmap)
            PixelTrack.debug.RemoveAt(pBitmap)

        }

        ;;  dispose of the bitmap if provided
        if ( pBitmap != true ) {

            Gdip_DisposeImage(pBitmap)
            pBitmap := ""
            VarSetCapacity(pBitmap, 0)

        } else {

            ;;  clean up the shared bitmap
            if ( RegExMatch($age, "^([0-9]*?)$") ) {

                ;;  set the age if none provided
                if ( age == false || age < 1 ) {

                    age := ( PixelStateSharedBitmapKeep > 0 ) ? PixelStateSharedBitmapKeep : 5

                }

                MaxAge := Round(A_Now-age)
                for BitmapAge, BitmapData in PixelTrack.SharedBitmap {

                    if ( BitmapAge < MaxAge ) {

                        PixelTrack.debug.RemoveAt(BitmapData)
                        Gdip_DisposeImage(PixelTrack.SharedBitmap[BitmapAge])
                        Gdip_DisposeImage(BitmapData)
                        PixelTrack.SharedBitmap.RemoveAt(BitmapAge)

                    }

                }

            }

        }

        return true

    }

    ;;  change the specified pixel to the new color
    SetPixel(ByRef pBitmap, a, r, g, b, x, y) {

        global PixelTrack
        argb := Gdip_ToARGB(a, r, g, b)

        if ( !PixelTrack.debug[pBitmap] )
            PixelTrack.debug[pBitmap] := []

        PixelTrack.debug[pBitmap].push({"x": x, "y": y, "argb": argb})

    }

    ;;  get the pixel argb value at the specified x,y coordinates
    GetPixel(x, y, ByRef pBitmap=false) {

        global Debug

        ;;  grab the pixel
        BitmapProvided := ( pBitmap == false ) ? false : true
        if ( pBitmap == false )
            pBitmap := this.GetBitmap()

        ;;  get the argb data
        argb := Gdip_GetPixel(pBitmap, x, y)
        Gdip_FromARGB(argb, A, R, G, B)

        ;;  debugging
        if ( Debug == true )
            this.SetPixel(pBitmap, 255, 255, 255, 255, x, y)

        ;;  potential cleanup
        if ( BitmapProvided == false ) {

            this.DestroyBitmap(pBitmap)
            pBitmap := false

        }

        Return {"A": A, "R": R, "B": B, "G": G, "number": argb}

    }

    ;;  determine x,y coordinates via relative positioning and forward to GetPixel
    GetPixelByPos(xPercent, yPercent, ByRef pBitmap=false) {

        if ( pBitmap != false ) {

            Width := Gdip_GetImageWidth(pBitmap)
            Height := Gdip_GetImageHeight(pBitmap)

        } else {

            WinGetPos, X, Y, Width, Height, A

        }

        xPixel := Round(Width*xPercent)
        yPixel := Round(Height*yPercent)
        Return this.GetPixel(xPixel, yPixel, pBitmap)

    }

    ;;  determine x,y coordinates via a named entry in the PixelMap and forward to GetPixelByPos
    GetPixelByName(PixelName, ByRef pBitmap=false) {

        global PixelMap
        if ( PixelMap[PixelName] ) {

            PixelData := PixelMap[PixelName].pos

            ;;  relative positions are a float
            if ( RegExMatch(PixelData["x"], "^0\.[0-9]{1,4}$") )
                if ( RegExMatch(PixelData["y"], "^0\.[0-9]{1,4}$") )
                    return this.GetPixelByPos(PixelData["x"], PixelData["y"], pBitmap)
            ;;  absolute positions are an integer
            else if ( RegExMatch(PixelData["x"], "^[0-9]*$") )
                 if ( RegExMatch(PixelData["y"], "^[0-9]*$") )
                     return this.GetPixel(PixelData["x"], PixelData["y"], pBitmap)

            ;;  getting this far means there was an error
            return ""

        } else {
            return ""
        }

    }

    ;;  determine if a pixel is "on" or not
    GetPixelState(PixelName, ByRef pBitmap=false) {

        global PixelMap
        if ( PixelMap[PixelName] ) {

            MapData := PixelMap[PixelName]
            PixelData := this.GetPixelByName(PixelName, pBitmap)

            ;;  a pixel could be multiple colors
            for index, ARGBNumber in MapData.settings.argb {

                ARGBDiff := Round(PixelData["number"]-ARGBNumber)
                RGB := this.RGBFromARGB(ARGBNumber)
                if ARGBDiff < 0
                    ARGBDiff := Round(ARGBDiff/-1)

                RDiff := Round(PixelData["R"]-RGB["R"])
                if RDiff < 0
                    RDiff := Round(RDiff/-1)

                GDiff := Round(PixelData["G"]-RGB["G"])
                if GDiff < 0
                    GDiff := Round(GDiff/-1)

                BDiff := Round(PixelData["B"]-RGB["B"])
                if BDiff < 0
                    BDiff := Round(BDiff/-1)

                ;;  tolerance levels are set once or per index
                RGBTolerance := ( MapData.settings.RGBTolerance[index] ) ? MapData.settings.RGBTolerance[index] : MapData.settings.RGBTolerance[1]
                ARGBTolerance := ( MapData.settings.ARGBTolerance[index] ) ? MapData.settings.ARGBTolerance[index] : MapData.settings.ARGBTolerance[1]

                ;;  exact argb number match, argb number tolerance threshold, or rgb thresholds qualify
                if ( PixelData["number"] == ARGBNumber || ARGBDiff <= ARGBTolerance || (RDiff <= RGBTolerance && GDiff <= RGBTolerance && BDiff <= RGBTolerance) ) {

                    return true

                }

            }

            ;;  no matches
            return false

        } else {
            return ""
        }

    }

    ;;  return the overall state of a group of pixels
    GetPixelGroupState(PixelGroupNames, ByRef pBitmap=false) {

        global PixelGroups, PixelMap

        BitmapProvided := ( pBitmap == false ) ? false : true

        ;;  we should support multiple groups being specified, so let's convert it if it's a string
        if ( PixelGroupNames.MinIndex() == "" )
            PixelGroupNames := [PixelGroupNames]

        ;;  loop thru our groups list
        for index, PixelGroup in PixelGroupNames {

            ;;  if the named group doesn't exist then maybe it was a custom list
            if ( PixelGroups[PixelGroup] ) {

                if ( pBitmap == false )
                    pBitmap := this.GetBitmap()

                ;;  loop thru the group's members and check their values
                for PixelName, ExpectedValue in PixelGroups[PixelGroup] {

                    ;;  if the PixelName matches the name of a group, then process the group instead
                    if ( PixelGroups[PixelName] ) {

                        ;;  same comments as in the else
                        result := this.GetPixelGroupState(PixelName, pBitmap)
                        if ( result != ExpectedValue ) {

                            if ( BitmapProvided == false )
                                this.DestroyBitmap(pBitmap)

                            ;;  blank responses are sent in the event a named pixel doesn't exist
                            if ( result == "" )
                                return ""
                            else
                                return false
                        }

                    } else {

                        ;;  instant failure if any value doesn't match
                        ;;  in the near future let's support a failure option instead of just returning false every time
                        result := this.GetPixelState(PixelName, pBitmap)
                        if ( result != ExpectedValue ) {

                            if ( BitmapProvided == false )
                                this.DestroyBitmap(pBitmap)

                            ;;  blank responses are sent in the event a named pixel doesn't exist
                            if ( result == "" )
                                return ""
                            else
                                return false
                        }

                    }

                }

            ;;  {"pixelname": value, ...} maybe?
            } else {

                LoopCount := 0
                for PixelName, ExpectedValue in PixelGroup {

                    ;;  the named pixel must exist
                    LoopCount++
                    if ( PixelMap[PixelName] ) {

                        result := this.GetPixelState(PixelName, pBitmap)
                        if ( result != ExpectedValue ) {

                            if ( BitmapProvided == false )
                                this.DestroyBitmap(pBitmap)

                            ;;  blank responses are sent in the event a named pixel doesn't exist
                            if ( result == "" )
                                return ""
                            else
                                return false
                        }

                    } else {

                        if ( BitmapProvided == false )
                            this.DestroyBitmap(pBitmap)

                        return ""

                    }

                }

                ;;  did not understand the request
                if ( LoopCount == 0 )
                    return ""

            }

        }

        if ( BitmapProvided == false )
            this.DestroyBitmap(pBitmap)

        ;;  it must have passed
        return true

    }

    ;;  determine the current state of the game (which screen the user is on)
    GetGameState(ByRef pBitmap=false) {

        BitmapProvided := ( pBitmap == false ) ? false : true

        if ( pBitmap == false )
            pBitmap := this.GetBitmap()

        ;;  loop thru each state
        for index, StateName in this.GameStates {

            ;;  check the group state
            if ( this.GetPixelGroupState(StateName, pBitmap) == true ) {

                if ( BitmapProvided == false )
                    this.DestroyBitmap(pBitmap)

                return StateName

            }

        }

        if ( BitmapProvided == false )
            this.DestroyBitmap(pBitmap)

        ;;  no states were valid
        return "Unknown"

    }

    ;;  return rgb values from argb number
    RGBFromARGB(argb) {

        Gdip_FromARGB(argb, A, R, G, B)
        return {"A": A, "R": R, "G": G, "B": B}

    }

    ;;  save the in-memory bitmap to disk
    SaveImage(ByRef pBitmap) {

        global StoragePath
        NewFolder := StoragePath . "\pixelstatetmp"
        if ( !FileExist(NewFolder) ) {
            FileCreateDir, %NewFolder%
        }

        Gdip_SaveBitmapToFile(pBitmap, NewFolder . "\" . A_YYYY . "-" . A_MM . "-" . A_DD "-" . A_Hour . "-" . A_Min . "-" . A_Sec . ".jpg", 100)

    }

    Logging(location, message, level="debug") {

        global StoragePath
        LogFolder := StoragePath . "\" . this.LogFolder
        LogFile := LogFolder . "\" . this.LogFile
        if ( RegExMatch(LogFile, "^.*?\.log$") ) {

            NewFolder := LogFolder
            if ( !FileExist(NewFolder) ) {
                FileCreateDir, %NewFolder%
            }

            FileAppend, % "[" A_YYYY "-" A_MM "-" A_DD " " A_Hour ":" A_Min ":" A_Sec "] [" location "] [" level "] " message "`n", % LogFile

        }

    }

    ;;  add data to the pixel map
    PixelMapConfig(PixelName, x, y, argb=false, RGBTolerance=false, ARGBTolerance=false) {

        global PixelMap

        ;;  sanity checks
        if x is not number
            return false

        if y is not number
            return false

        if argb != false
            if argb is not number
                if argb.MinIndex() == ""
                    return false

        if ARGBTolerance != false
            if ARGBTolerance is not number
                return false

        if RGBTolerance != false
            if RGBTolerance is not number
                return false

        ;;  build the default object
        if !PixelMap[PixelName]
            PixelMap[PixelName] := {"settings": {"ARGBTolerance": [PixelMap.settings.ARGBTolerance], "RGBTolerance": [PixelMap.settings.RGBTolerance]}}

        ;;  convert argb value to array if not already
        if argb is number
            argb := [argb]

        if argb != false
            PixelMap[PixelName].settings.argb := argb

        ;;  convert argbtolerance value to array if not already
        if ARGBTolerance is number
            ARGBTolerance := [ARGBTolerance]

        if ARGBTolerance != false
            PixelMap[PixelName].settings.ARGBTolerance := ARGBTolerance

        ;;  convert rgbtolerance value to array if not already
        if RGBTolerance is number
            RGBTolerance := [RGBTolerance]

        if RGBTolerance != false
            PixelMap[PixelName].settings.RGBTolerance := RGBTolerance

        ;;  set the positional data
        PixelMap[PixelName].pos := {"x": x, "y": y}

    }

    GracefulExit(ByRef pBitmap, BitmapProvided) {

        if ( BitmapProvided == false )
            this.DestroyBitmap(pBitmap)

        return false

    }

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;  pixelstate hotkeys
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    class hotkeys {

        static ScreenCalibrationStatus := false

        ;;  toggle calibration on/off
        ScreenCalibrationRequest() {

            this.ScreenCalibrationStatus := ( this.ScreenCalibrationStatus == true ) ? false : true
            if ( this.ScreenCalibrationStatus == true ) {
                Hotkey, ~LButton, ScreenCalibrationRequest, On
            } else {
                Hotkey, ~LButton, ScreenCalibrationRequest, Off
            }

        }

    }

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;  pixelstate tools
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;
    class tools {

        ;;  get the current window state of the game
        GetScreenMode() {

            global WindowTitle
            Return ( isWindowFullScreen(WinExist(WindowTitle)) == 1 ) ? "fullscreen" : "windowed"

        }

        ;;  determine if this is flash or steam
        GetGameWindow() {
            
            global WindowTitle
            Return ( RegExMatch(WindowTitle, "^Adobe Flash Player") ) ? "flash" : "steam"

        }

        ;;  get screen positional data for the mouse location
        GetScreenPosDataByClick() {

            global JSON
            run := CheckRun()

            if ( CheckRun() == true ) {

                WinGetPos, WinX, WinY, Width, Height, A
                MouseGetPos, x, y
                pixel := PixelState.GetPixel(x, y)
                PixelObject := {"pos": {"xAbs": x, "yAbs": y, "xRel": Round(x/Width, 4), "yRel": Round(y/Height, 4)}, "pixel": pixel, "argb": Gdip_ToARGB(pixel["A"], pixel["R"], pixel["G"], pixel["B"])}
                message1 := "Absolute x,y: " . PixelObject["pos"]["xAbs"] . "," . PixelObject["pos"]["yAbs"]
                message2 := "Relative x,y: " . PixelObject["pos"]["xRel"] . "," . PixelObject["pos"]["yRel"]
                message3 := "Pixel ARGB Values: " . PixelObject["pixel"]["A"] . " " . PixelObject["pixel"]["R"] . " " . PixelObject["pixel"]["G"] . " " . PixelObject["pixel"]["B"]
                message4 := "Pixel ARGB Number: " . PixelObject["argb"] . "`n"
                PixelState.Logging("PixelState/ScreenCalibration", message1)
                PixelState.Logging("PixelState/ScreenCalibration", message2)
                PixelState.Logging("PixelState/ScreenCalibration", message3)
                PixelState.Logging("PixelState/ScreenCalibration", message4)
                MsgBox % message1 . "`n" . message2 . "`n" . message3 . "`n" . message4

            }

        }

        ;;  calculation the actual positions based on input
        ScreenShotGeneratePositions(Width, Height, Dimensions, Adjustments) {

            result := {}
            result["x"] := Round((Width*Dimensions["x"])+Adjustments["x"], 0)
            result["y"] := Round((Height*Dimensions["y"])+Adjustments["y"], 0)
            result["w"] := Round((Width*Dimensions["width"])+Adjustments["width"], 0)
            result["h"] := Round((Height*Dimensions["height"])+Adjustments["height"], 0)
            Return result

        }

        ;;  take and process a screenshot
        TakeScreenshot(mode=false, ByRef pBitmap=false, excludeFilters=false) {

            ;;  defaults
            global pToken, ScreenshotSleepTimeout, ScreenshotFilterAdjustments, ScreenshotRectangles, WatermarkPos, WatermarkTextColor, ScreenshotFolder, TimelapseFolder, DestinationFolder
            global ScreenshotImageQuality, ScreenshotImageMode, ScreenshotWaitPixelCheck, ScreenshotChatboxGrace, lastEnterKeypress, TimelapseSharedBitmap, ScreenshotNexusDisallowedLocations
            global PixelTrack, TimelapseDisallowedLocations, ScreenshotNexusDisallowedLocations, ScreenshotFilterDefaultColor

            ;;  process screenshot filters and storage
            if ( ScreenshotImageMode == "direct" ) {

                ;;  window info
                WinGetPos, X, Y, Width, Height, A
                WinGetTitle, WindowTitle, A

                ;;  screenshot mode info
                BitmapProvided := ( pBitmap == false ) ? false : true
                ScreenMode := this.GetScreenMode()
                GameWindow := this.GetGameWindow()

                ;;;;  checks for various modes

                ;;  timelapse shouldn't run in certain locations
                if ( mode == "automatic_timelapse" && TimelapseDisallowedLocations != false AND InArray(PixelTrack.CurrentLocation, TimelapseDisallowedLocations) == true )
                    return false

                ;;  timelapse can optionally use the most recent shared bitmap
                if ( mode == "automatic_timelapse" && TimelapseSharedBitmap == true && BitmapProvided == false )
                    pBitmap := PixelState.GetBitmap(true)

                ;;  create the base image in memory
                if ( pBitmap == false )
                    pBitmap := PixelState.GetBitmap()

                ;;  pixelstate - if it was triggered automatically by typing check if the chatbox is present
                if ( mode == "automatic_typing" && ScreenshotWaitPixelCheck == true AND (A_Now-lastEnterKeypress > ScreenshotChatboxGrace) )
                    if ( PixelState.GetPixelGroupState("ChatBoxUnobstructed", pBitmap) == true )
                        return PixelState.GracefulExit(pBitmap, BitmapProvided)

                if ( mode == "automatic_typing" && ScreenshotNexusDisallowedLocations != false )
                    if ( InArray(PixelTrack.CurrentLocation, ScreenshotNexusDisallowedLocations) == true )
                        return PixelState.GracefulExit(pBitmap, BitmapProvided)

                Width := Gdip_GetImageWidth(pBitmap), Height := Gdip_GetImageHeight(pBitmap)
                G := Gdip_GraphicsFromImage(pBitmap)
                Gdip_DrawImage(G, pBitmap, 0, 0, Round(Width), Round(Height), 0, 0, Width, Height)

                ;;  sleep for specified time before beginning image processing and disk activity
                if ( mode == "automatic_typing" )
                    Sleep ScreenshotSleepTimeout*1000

                ;;;;  prepare screenshot filters

                ;;  maybe the user knows better and provided their own
                if ( !Adjustments && ScreenshotFilterAdjustments ) {
                    Adjustments := ScreenshotFilterAdjustments
                }

                ;;  the default action is to do no adjustments
                if ( !Adjustments ) {
                    Adjustments := {"x": 0, "y": 0, "width": 0, "height": 0}
                }

                ;;  create the filter brush
                FilterColor := "0xff" . ScreenshotFilterDefaultColor
                filterBrush := {"default": Gdip_BrushCreateSolid(FilterColor)}

                ;;  process all active filters
                for index, Dimensions in ScreenshotRectangles {

                    ;;  check if there is a custom color provided
                    if ( Dimensions["color"] && !filterBrush[Dimensions["color"]] ) {

                        Dimensions["color"] := "0xff" . Dimensions["color"]
                        filterBrush[Dimensions["color"]] := Gdip_BrushCreateSolid(Dimensions["color"])

                    }

                    ;;  set our default color
                    if ( !Dimensions["color"] ) {
                        Dimensions["color"] := "default"
                    }

                    ;;  only run positions thru the adjustment system if they're percentage-based
                    ;;  absolutes can be passed through as-is where x,y > 1,1
                    if ( Dimensions["x"] > 1 && Dimensions["y"] > 1 ) {

                        pos := {"x": Dimensions["x"], "y": Dimensions["y"], "w": Dimensions["width"], "h": Dimensions["height"]}

                    } else {

                        pos := this.ScreenShotGeneratePositions(Width, Height, Dimensions, Adjustments)

                    }

                    Gdip_FillRectangle(G, filterBrush[Dimensions["color"]], pos["x"], pos["y"], pos["w"], pos["h"])

                }

                ;;;;  draw watermark
                WatermarkObject := ( ScreenMode == "fullscreen" ) ? WatermarkPos : {"x": Round(WatermarkPos.x-0.11,4), "y": WatermarkPos.y}
                Gdip_TextToGraphics(G, "JROTMG-AHK/Screenshot", "X" . Round(WatermarkObject["x"]*Width) . " Y" . Round(WatermarkObject["y"]*Height) . " C" . WatermarkTextColor)

                ;;;;  clean up brushes
                for index, element in filterBrush {
                    Gdip_DeleteBrush(element)
                }

                ;;;;  determine destination folder
                Type := ""

                if ( mode == "manual" ) {

                    Type := "screenshot-"
                    DestinationFolder := ScreenshotFolder . "\manual"

                }

                if ( mode == "automatic_timelapse" ) {

                    Type := "timelapse-"
                    if ( TimelapseFolder != false )
                        DestinationFolder := TimelapseFolder

                }

                if ( mode == "automatic_typing" ) {

                    Type := "nexus-"
                    DestinationFolder := ScreenshotFolder . "\nexus"

                }

                if ( !DestinationFolder )
                    DestinationFolder := ScreenshotFolder

                ;;;;  check destination folder
                if ( !FileExist(DestinationFolder) ) {

                    FileCreateDir, %DestinationFolder%

                }

                ;;;;  check year folder
                DestinationFolder := DestinationFolder . "\" . A_YYYY
                if ( !FileExist(DestinationFolder) ) {

                    FileCreateDir, %DestinationFolder%

                }

                ;;;;  check month folder
                DestinationFolder := DestinationFolder . "\" . A_MM
                if ( !FileExist(DestinationFolder) ) {

                    FileCreateDir, %DestinationFolder%

                }

                ;;;;  save file to disk
                Gdip_SaveBitmapToFile(pBitmap, DestinationFolder "\" Type . A_YYYY "-" A_MM "-" A_DD "-" A_Hour "-" A_Min "-" A_Sec ".jpg", ScreenshotImageQuality)

                ;;  cleanup
                Gdip_DeleteGraphics(G)
                if ( BitmapProvided == false )
                    Gdip_DisposeImage(pBitmap)

                VarSetCapacity(X, 0)
                VarSetCapacity(Y, 0)
                VarSetCapacity(Width, 0)
                VarSetCapacity(Height, 0)
                VarSetCapacity(BitmapProvided, 0)
                VarSetCapacity(ScreenMode, 0)
                VarSetCapacity(GameWindow, 0)
                VarSetCapacity(G, 0)
                VarSetCapacity(Adjustments, 0)
                VarSetCapacity(FilterColor, 0)
                VarSetCapacity(filterBrush, 0)
                VarSetCapacity(Dimensions, 0)
                VarSetCapacity(WatermarkObject, 0)
                VarSetCapacity(Type, 0)
                VarSetCapacity(DestinationFolder, 0)

            ;;  steam is really hard to process
            } else if ( ScreenshotImageMode == "steam" ) {

                SendInput, {F12}

            }

            return true

        }

    }

    class check {

        ;;  determine player hp and account for obstructions when possible
        PlayerHP() {

            global JSON
            pBitmap := PixelState.GetBitmap(true)
            Pixels := ["hp_0p", "hp_5p", "hp_10p", "hp_15p", "hp_20p", "hp_25p", "hp_30p", "hp_35p", "hp_40p", "hp_45p", "hp_50p", "hp_55p", "hp_60p", "hp_65p", "hp_70p", "hp_75p", "hp_80p", "hp_85p", "hp_90p", "hp_95p", "hp_100p"]
            HPIndex := false
            LowIndex := false
            ControlPixels := PixelState.GetPixelGroupState({"controlpoint75_4": true, "controlpoint75_5": true, "controlpoint75_6": true}, pBitmap)
            ObstructionCheck := false

            ;;  gather pixel data and check if we need to look for obstruction
            for PixelIndex, PixelName in Pixels {

                PixelData := PixelState.GetPixelState(PixelName, pBitmap)

                ;;  track the lowest pixel to fail
                if ( PixelData == false && LowIndex == false )
                    LowIndex := PixelIndex

                ;;  no obstruction then no concerns
                if ( PixelData == true && ControlPixels == true )
                    HPIndex := PixelIndex

                ;;  pixeldata and control pixels missing indicates an obstruction
                if ( PixelData == false && ControlPixels == false )
                    ObstructionCheck := true

                ;;  previous obstructions might mean higher pixels show up
                if ( PixelData == true && (ObstructionCheck == true || ControlPixels == false) ) {

                    ;;  lower pixels were found but a higher one was
                    ;;  obstruction is resolved
                    if ( PixelIndex > HPIndex ) {

                        ;;  reset LowIndex is this is higher
                        if ( PixelIndex >= LowIndex )
                            LowIndex := false

                        HPIndex := PixelIndex
                        ObstructionCheck := false

                    }

                }

            }

            PixelTrack.DestroyBitmap(pBitmap)

            ;;  the actual default value is the maxindex of the pixels object
            if ( LowIndex == false )
                LowIndex := Pixels.MaxIndex()

            ;;  no pixels were detected
            if ( HPIndex == false )
                ObstructionCheck := true

            ;;  no obstruction, full hp bar, or all further hp pixels are off (and convert HP to 20 increments)
            if ( ObstructionCheck == false || HPIndex == Pixels.MaxIndex() || (HPIndex != false && HPIndex <= LowIndex) )
                return Round(((HPIndex-1)/(Pixels.MaxIndex()-1))*100)  ;; -1, -1 because 11/21 is not an even 50% but 10/20 is

            ;;  at this point there is an unresolved obstruction
            ;;  report occurrences of this
            return ""

        }

    }

}
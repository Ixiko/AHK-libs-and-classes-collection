; Do not include this in the StdLib!

; The following lines compiles the Script, if the Script (not the exe or scr) is executed.

; After that, the Compiled Screensaver will be installed.

if (!A_IsCompiled)
{

  compiler_path := substr(A_AhkPath, 1, instr(A_AhkPath, "\", 0, 0)) "Compiler\"

  if (!FileExist(compiler_path "Ahk2Exe.exe"))

  {

    MsgBox, 16, Error, Ahk2Exe was not found!`nThe script will exit

    ExitApp

  }

  if (icon && !FileExist(icon))

  {

    MsgBox, 48, Warning, The specified Icon-File was not found!

    icon := ""

  }

  else if (icon)

    icon := " /icon """ icon """"

  if (bin && !FileExist(compiler_path bin))

  {

    MsgBox, 48, Warning, The specified Bin-File was not found!

    bin := ""

  }

  else if (bin)

    bin := " /bin """ compiler_path bin """"

  in := A_ScriptFullPath

  out := substr(A_ScriptFullPath, 1, p := instr(A_ScriptFullPath, "\", 0, 0)) substr(A_ScriptName, 1, instr(A_ScriptName, ".", 0, 0)) "scr"

  Process, close, % substr(A_ScriptName, 1, instr(A_ScriptName, ".", 0, 0)) "scr"

  FileDelete, % out

  RunWait, % compiler_path "Ahk2Exe.exe /in """ in """ /out """ out """" icon " " bin, % A_ScriptDir

  if (FileExist(out))

  {

    Run, % "Rundll32 desk.cpl,InstallScreenSaver " out,,, screensave_settings_pid

    OnExit, ExitScreensaveSettings

    Process, waitclose, % screensave_settings_pid

  }

  else

    MsgBox, 16, Error, Compiling failed!

  ExitApp



  ExitScreensaveSettings:

  Process, close, % screensave_settings_pid

  ExitApp

}

; The following lines are executed if the Screensaver is allready compiled
; Check the startup Parameters and run the Screensaver-Functions

argv := []
cmd_line := A_ScriptName
Loop, %0%
{
  cmd_line .= " " %A_Index%
  argv[A_Index] := %A_Index%
}

;MsgBox, 64, Screensaver Commandline, % "Screensaver Commandline:`n`n" cmd_line            ;Shows the Commandline-arguments of the current process
if (argv[1]!="/c" && instr(argv[1], "/c:")!=1)
{
  result := ScreensaverMain(argv)
  ExitApp, % result
}

; This Function will be called if the Screensaver (*.scr) starts, and dont request the Settings-Gui
ScreensaverMain(argv){

  if (argv[1]="/s" || instr(argv[1], "/s:")=1)

    return StartScreensaver()

  else if (argv[1]="/p" || instr(argv[1], "/p:")=1)

    return PreviewScreensaver(argv[2])

  else if (argv[1]="/d" || instr(argv[1], "/d:")=1)

    return DebugScreensaver()

  return 0

}

; This Function will be called if the Screensaver had to start normally.
StartScreensaver(){

  global ScreensaverWindows, MULTIMONITOR_EXPAND_AREA, MULTIMONITOR_COPY, ScreensaverMode
  ScreensaverMode := "DEFAULT"
  RegisterClass("ScreensaverProc", "DEFAULT")
  VarSetCapacity(device, 840, 0)
  VarSetCapacity(settings, 220, 0)
  NumPut(840, device, 0, "uint")
  NumPut(220, settings, 68, "ushort")
  i := 0
  displayarea := {left:0, top:0, right:0, bottom:0}
  ScreensaverWindows := []
  DllCall("ChangeDisplaySettings", "ptr", 0, "uint", 0x00000004)
  while (DllCall("EnumDisplayDevicesW", "ptr", 0, "uint", i, "ptr", &device, "uint", 0))
  {

    devicename := StrGet(&device+4, 32, "utf-16")

    if (DllCall("EnumDisplaySettingsW", "wstr", devicename, "int", -1, "ptr", &settings))

    {

      ScreensaverWindows[i] := []
      x := NumGet(settings, 76, "int")
      y := NumGet(settings, 80, "int")
      w := NumGet(settings, 172, "uint")
      h := NumGet(settings, 176, "uint")
      bpp := NumGet(settings, 168, "uint")

      if (x<displayarea.left)

        displayarea.left := x

      if (y<displayarea.top)

        displayarea.top := y

      if (x+w>displayarea.right)

        displayarea.right := x+w

      if (y+h>displayarea.bottom)

        displayarea.bottom := y+h

      displayarea.width := displayarea.right-displayarea.left

      displayarea.height := displayarea.bottom-displayarea.top

      ScreensaverWindows[i].rect := {left:x, top:y, right:x+w, bottom:y+h, width:w, height:h}

      ScreensaverWindows[i].hWnd := CreateWindow(x, y, w, h)

      if ((x=0 && y=0) || MULTIMONITOR_EXPAND_AREA || MULTIMONITOR_COPY)

      {

        ScreensaverWindows[i].hDC := DllCall("GetDC", "ptr", ScreensaverWindows[i].hWnd, "ptr")

        ScreensaverWindows[i].hRC := InitOpenGL(ScreensaverWindows[i].hDC, bpp)

      }

    }

    i ++

  }

  for i, wnd in ScreensaverWindows

  {

    if (!wnd.hRC)

      continue

    DllCall("opengl32\wglMakeCurrent", "ptr", wnd.hDC, "ptr", wnd.hRC)

    SetupViewMode(wnd.rect, displayarea)

    if (MULTIMONITOR_EXPAND_AREA)

      wnd.rect := {left:-displayarea.width/2, top:displayarea.height/2, right:displayarea.width/2, bottom:-displayarea.height/2, width:displayarea.width, height:displayarea.height}

    else

      wnd.rect := {left:-wnd.rect.width/2, top:wnd.rect.height/2, right:wnd.rect.width/2, bottom:-wnd.rect.height/2, width:wnd.rect.width, height:wnd.rect.height}

    InitScreensaver("DEFAULT", wnd.rect)

  }

  while(1)

  {

    for i, wnd in ScreensaverWindows

    {

      DllCall("opengl32\wglMakeCurrent", "ptr", wnd.hDC, "ptr", wnd.hRC)

      DrawScreensaver("DEFAULT", wnd.rect)

      DllCall("SwapBuffers", "ptr", wnd.hDC)

    }

    ScreensaverTiming()

  }

  return 1

}

; This Function will be called if a Preview is reqired from the Screensaver (e.g. in the Windows Screensaver-Settings)
PreviewScreensaver(hParent){

  global ScreensaverWindows, ScreensaverMode

  ScreensaverMode := "PREVIEW"

  RegisterClass("ScreensaverPreviewProc", "PREVIEW")

  VarSetCapacity(brect, 16, 0)

  DllCall("GetClientRect", "ptr", hParent, "ptr", &brect)

  rect := {left:0, top:0, right:(w := NumGet(brect, 8, "int")), bottom:(h := NumGet(brect, 12, "int")), width:w, height:h}

  hWnd := CreateWindow(0, 0, w, h, hParent)

  DllCall("SetParent", "ptr", hWnd, "ptr", hParent)

  hDC := DllCall("GetDC", "ptr", hWnd, "ptr")

  hRC := InitOpenGL(hDC)

  ScreensaverWindows := [{hWnd:hWnd, hDC:hDC, hRC:hRC}]

  DllCall("opengl32\wglMakeCurrent", "ptr", hDC, "ptr", hRC)

  SetupViewMode(rect, rect)

  rect := {left:-rect.width/2, top:rect.height/2, right:rect.width/2, bottom:-rect.height/2, width:rect.width, height:rect.height}

  InitScreensaver("PREVIEW", rect)

  while (WinExist("ahk_id " hParent))

  {

    DrawScreensaver("PREVIEW", rect)

    DllCall("SwapBuffers", "ptr", hDC)

    ScreensaverTiming()

  }

  DestroyScreensaver()

  return 1

}

; This function will be called if the Screensaver starts in debug-mode.
DebugScreensaver(){

  MsgBox, 20, Error, This Screensaver has no Debug-Mode`nStart this Screensaver normally?

  IfMsgBox Yes

    return StartScreensaver()

  return 0

}

RegisterClass(proc, mode="DEFAULT"){

  global HIDE_CURSOR

  classname := "AutoHotkeyScreensaver"

  VarSetCapacity(wcex, 8*A_PtrSize+16, 0)

  NumPut(8*A_PtrSize+16, wcex, 0, "uint")

  NumPut(0x23, wcex, 4, "uint")

  NumPut(RegisterCallback(proc), wcex, 8, "ptr")

  NumPut(DllCall("GetModuleHandle", "ptr", 0, "ptr"), wcex, A_PtrSize+16, "ptr")

  if (!HIDE_CURSOR || mode="PREVIEW")

    NumPut(DllCall("LoadCursor", "ptr", 0, "ptr", 32512, "ptr"), wcex, 3*A_PtrSize+16, "ptr")

  NumPut(DllCall("CreateSolidBrush", "uint", 0x000000, "ptr"), wcex, 4*A_PtrSize+16, "ptr")

  NumPut(&classname, wcex, 6*A_PtrSize+16, "ptr")

  return DllCall("RegisterClassEx", "ptr", &wcex, "ushort")

}

CreateWindow(x, y, w, h, parent=0){

  classname := "AutoHotkeyScreensaver"

  top := (parent) ? 0x8 : 0

  return DllCall("CreateWindowEx", "uint", 0x00000080 | top, "str", classname, "str", "", "uint", 0x90000000, "int", x, "int", y, "int", w, "int", h, "ptr", parent, "ptr", 0, "ptr", 0, "ptr", 0, "ptr")

}

ScreensaverProc(hWnd, msg, wParam, lParam){

  global EXIT_MESSAGES, HIDE_CURSOR

  if (msg=0x02 || msg=0x12)

    ExitApp, DestroyScreensaver()

  if (msg=0x200 && HIDE_CURSOR)

    DllCall("SetCursor", "ptr", 0)

  for i, m in EXIT_MESSAGES

  {

    if (msg = m)

      ExitApp, % DestroyScreensaver()

  }

  return DllCall("DefWindowProc", "ptr", hWnd, "uint", msg, "ptr", wParam, "ptr", lParam, "ptr")

}

ScreensaverPreviewProc(hWnd, msg, wParam, lParam){

  if (msg=0x02)

    return DestroyScreensaver()

  return DllCall("DefWindowProc", "ptr", hWnd, "uint", msg, "ptr", wParam, "ptr", lParam, "ptr")

}

DestroyScreensaver(){

  global ScreensaverWindows, ScreensaverMode

  for i, wnd in ScreensaverWindows

  {

    if (wnd.hRC)

    {

      DllCall("opengl32\wglMakeCurrent", "ptr", 0, "ptr", 0)

      DllCall("opengl32\wglDeleteContext", "ptr", hRC)

    }

    if (wnd.hDC)

      DllCall("ReleaseDC", "ptr", wnd.hWnd, "ptr", wnd.hDC)

    if (wnd.hWnd)

      DllCall("DestroyWindow", "ptr", wnd.hWnd)

    ScreensaverWindows[i] := ""

  }

  if (ScreensaverMode="DEFAULT")

    DllCall("ChangeDisplaySettings", "ptr", 0, "uint", 0)

  return 1

}

; This function initializes OpenGL on a Device-Context.
InitOpenGL(hDC, colorbits=32, accumbits=0, depthbits=16, stencilbits=0){

  DllCall("LoadLibrary", "str", "opengl32")

  VarSetCapacity(pfd, 40, 0)

  NumPut(40, pfd, 0, "ushort")

  NumPut(1, pfd, 2, "ushort")

  NumPut(0x25, pfd, 4, "uint")

  NumPut(colorbits, pfd, 9, "uchar")

  NumPut(accumbits, pfd, 18, "uchar")

  NumPut(depthbits, pfd, 23, "uchar")

  NumPut(stencilbits, pfd, 24, "uchar")

  DllCall("SetPixelFormat", "ptr", hDC, "int", DllCall("ChoosePixelFormat", "ptr", hDC, "ptr", &pfd), "ptr", &pfd)

  return DllCall("opengl32\wglCreateContext", "ptr", hDC, "ptr")

}

SetupViewMode(rect, displayarea){

  global OPENGL_PERSPECTIVE, MULTIMONITOR_EXPAND_AREA

  DllCall("opengl32\glMatrixMode", "uint", 0x1701)

  DllCall("opengl32\glLoadIdentity")

  if (!MULTIMONITOR_EXPAND_AREA)

  {

    if (!OPENGL_PERSPECTIVE)

      DllCall("opengl32\glOrtho", "double", -rect.width/2, "double", rect.width/2, "double", -rect.height/2, "double", rect.height/2, "double", -1, "double", 1)

    else

      DllCall("opengl32\glFrustum", "double", "double", -rect.width/2, "double", rect.width/2, "double", -rect.height/2, "double", rect.height/2, "double", 0.001, "double", 1000)

  }

  else

  {

    w := displayarea.width

    h := displayarea.height

    if (!OPENGL_PERSPECTIVE)

      DllCall("opengl32\glOrtho", "double", rect.left-(w/2), "double", rect.right-(w/2), "double", rect.top-(h/2), "double", rect.bottom-(h/2), "double", -1, "double", 1)

    else

      DllCall("opengl32\glFrustum", "double", rect.left-(w/2), "double", rect.right-(w/2), "double", rect.top-(h/2), "double", rect.bottom-(h/2), "double", 0.001, "double", 1000)

  }

  DllCall("opengl32\glMatrixMode", "uint", 0x1700)

  DllCall("opengl32\glLoadIdentity")

}

ScreensaverTiming(){

  static lastframe := 0, lastsleep := 0, fps := 30

  thisframe := A_TickCount

  atd := A_TickCount-lastframe

  lastframe := thisframe

  sleep := 1000 / fps - (atd - lastsleep)

  if (sleep > 0)

    sleep, % sleep

  lastsleep := (sleep > 0) ? sleep : 0

}


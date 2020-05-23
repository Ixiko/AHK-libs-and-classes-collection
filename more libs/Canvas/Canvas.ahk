#NoEnv

/*
Copyright 2012 Anthony Zhang <azhang9@gmail.com>

This file is part of Canvas-AHK. Source code is available at <https://github.com/Uberi/Canvas-AHK>.

Canvas-AHK is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

/*
TODO
----

* console output module with colors by reading the bitmap, console functions at http://msdn.microsoft.com/en-us/library/windows/desktop/ms682073(v=vs.85).aspx
* consider color transformations using http://msdn.microsoft.com/en-us/library/windows/desktop/ms533875(v=vs.85).aspx
* effects support with http://msdn.microsoft.com/en-us/library/windows/desktop/ms533971(v=vs.85).aspx
    * GpStatus WINGDIPAPI GdipDrawImageFX(GpGraphics *graphics, GpImage *image, GpRectF *source, GpMatrix *xForm, CGpEffect *effect, GpImageAttributes *imageAttributes, GpUnit srcUnit)
    * GpStatus WINGDIPAPI GdipBitmapApplyEffect(GpBitmap* bitmap, CGpEffect *effect, RECT *roi, BOOL useAuxData, VOID **auxData, INT *auxDataSize)
    * Status __stdcall GdipCreateEffect(const GUID guid, CGpEffect **effect)
* opengl backend
* ASCII backend with drawing functions here: http://free.pages.at/easyfilter/bresenham.html
* combine the draw* and fill* functions: DrawPie(Pen) and FillPie(Brush) -> Pie(Pen) and Pie(Brush)
* fold pens into brushes; allow brushes to define widths, fills, etc.
* add hatch brush, texture brush, and linear/radial gradient brush capabilities to Brush class
* use CachedBitmap for animations or faster drawing: http://msdn.microsoft.com/en-us/library/ms533975(v=vs.85).aspx
*/


;#Warn All
;#Warn LocalSameAsGlobal, Off

i := new Canvas.Surface
i.Load(A_ScriptDir . "\Earthrise.jpg")
s := new Canvas.Surface(400,400)
s.Draw(i)

f := new Canvas.Font("Georgia",18)
s.Text(new Canvas.Brush(0xFFFFFFFF),f,"Earthrise: Dawn of a new era",30,80)

Gui, +LastFound
v := new Canvas.Viewport(WinExist()).Attach(s)

p := new Canvas.Pen(0x80FF0000,10)
t := new Canvas.Pen(0xFF00FF00,1)
b := new Canvas.Brush(0xAA0000FF)

Gui, Show, w400 h400, Canvas Demo
Return

GuiClose:
ExitApp

Tab::
f.Measure("Earthrise: Dawn of a new era",W,H)
s.DrawRectangle(t,30,80,W,H)
v.Refresh()
Return

Space::
s.Clear(0xFFFFFF00)
 .Push()
 .Translate(50,50)
 .Rotate(60)
 .FillRectangle(b,0,0,50,50)
 .Pop()
 .DrawEllipse(p,70,70,100,100)
 .DrawCurve(t,[[10,10],[50,10],[10,50]],True)
 .FillPie(b,100,100,50,50,0,270)
v.Refresh()
Return


class Canvas
{
    static _ := Canvas.Initialize()

    Initialize()
    {
        this.hModule := DllCall("LoadLibrary","Str","gdiplus","UPtr")

        ;initialize the GDI+ library
        VarSetCapacity(StartupInformation,A_PtrSize + 12)
        NumPut(1,StartupInformation,0,"UInt") ;GDI+ version (version 1)
        NumPut(0,StartupInformation,4) ;debug callback (disabled)
        NumPut(0,StartupInformation,A_PtrSize + 4) ;suppress background thread (disabled)
        NumPut(0,StartupInformation,A_PtrSize + 8) ;suppress external image codecs (disabled)
        Token := 0
        this.CheckStatus(DllCall("gdiplus\GdiplusStartup","UPtr*",Token,"UPtr",&StartupInformation,"UPtr",0)
            ,"GdiplusStartup","Could not initialize GDI+ library")
        this.Token := Token
    }

    __Delete()
    {
        ;shut down the GDI+ library
        DllCall("gdiplus\GdiplusShutdown","UPtr",this.Token)
    }

    Lenient()
    {
        this.Surface.CheckStatus := this.Surface.StubCheckStatus
        this.Surface.CheckPen := this.Surface.StubCheckPen
        this.Surface.CheckBrush := this.Surface.StubCheckBrush
        this.Surface.CheckFormat := this.Surface.StubCheckFormat
        this.Surface.CheckLine := this.Surface.StubCheckLine
        this.Surface.CheckRectangle := this.Surface.StubCheckRectangle
        this.Surface.CheckSector := this.Surface.StubCheckSector
        this.Surface.CheckPoint := this.Surface.StubCheckPoint
        this.Surface.CheckPoints := this.Surface.StubCheckPoints

        this.Viewport.CheckStatus := this.Viewport.StubCheckStatus

        this.Pen.CheckStatus := this.Pen.StubCheckStatus

        this.Brush.CheckStatus := this.Brush.StubCheckStatus

        this.Font.CheckStatus := this.Font.StubCheckStatus
    }

    #Include %A_LineFile%\..\Viewport.ahk
    #Include %A_LineFile%\..\Surface.ahk
    #Include %A_LineFile%\..\Pen.ahk
    #Include %A_LineFile%\..\Brush.ahk
    #Include %A_LineFile%\..\Font.ahk
}
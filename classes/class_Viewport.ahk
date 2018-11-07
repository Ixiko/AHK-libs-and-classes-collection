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

class Viewport
{
    __New(hWindow)
    {
        this.hWindow := hWindow

        ;create a memory device context for double buffering use
        this.hMemoryDC := DllCall("CreateCompatibleDC","UPtr",0,"UPtr")
        If !this.hMemoryDC
            throw Exception("INTERNAL_ERROR",A_ThisFunc,"Could not create memory device context (error in CreateCompatibleDC)")

        ;subclass window to override WM_PAINT
        this.pCallback := RegisterCallback(this.PaintCallback,"Fast",6)
        If !DllCall("Comctl32\SetWindowSubclass"
            ,"UPtr",hWindow ;window handle
            ,"UPtr",this.pCallback ;callback pointer
            ,"UPtr",hWindow ;subclass ID
            ,"UPtr",0) ;arbitrary data to pass to this particular subclass callback and ID
            throw Exception("INTERNAL_ERROR",A_ThisFunc,"Could not subclass window (error in SetWindowSubclass)")
    }

    __Delete()
    {
        ;remove subclass of window
        If !DllCall("Comctl32\RemoveWindowSubclass","UPtr",this.hWindow,"UPtr",this.pCallback,"UPtr",this.hWindow)
            throw Exception("INTERNAL_ERROR",A_ThisFunc,"Could not remove subclass from window (error in RemoveWindowSubclass)")

        ;free paint callback
        DllCall("GlobalFree","UPtr",this.pCallback,"UPtr")
    }

    Attach(Surface)
    {
        If !DllCall("Comctl32\SetWindowSubclass"
            ,"UPtr",this.hWindow ;window handle
            ,"UPtr",this.pCallback ;callback pointer
            ,"UPtr",this.hWindow ;subclass ID
            ,"UPtr",&this) ;arbitrary data to pass to this particular subclass callback and ID
            throw Exception("INTERNAL_ERROR",A_ThisFunc,"Could not update window subclass (error in SetWindowSubclass)")
        this.Surface := Surface
        this.Width := Surface.Width
        this.Height := Surface.Height
        Return, this
    }

    Detach()
    {
        this.Surface := False
        Return, this
    }

    Refresh(X = 0,Y = 0,W = 0,H = 0)
    {
        If (X < 0 || X > this.Width)
            throw Exception("INVALID_INPUT",A_ThisFunc,"Invalid X-axis coordinate: " . X)
        If (Y < 0 || Y > this.Height)
            throw Exception("INVALID_INPUT",A_ThisFunc,"Invalid Y-axis coordinate: " . Y)
        If (W < 0 || W > this.Width)
            throw Exception("INVALID_INPUT",A_ThisFunc,"Invalid width: " . W)
        If (H < 0 || H > this.Height)
            throw Exception("INVALID_INPUT",A_ThisFunc,"Invalid height: " . W)

        If W = 0
            W := this.Width
        If H = 0
            H := this.Height

        ;flush the GDI+ drawing batch
        this.CheckStatus(DllCall("gdiplus\GdipFlush","UPtr",this.Surface.pGraphics,"UInt",1) ;FlushIntention.FlushIntentionSync
            ,"GdipFlush","Could not flush GDI+ pending rendering operations")

        ;set up rectangle structure representing area to redraw
        VarSetCapacity(Rect,16)
        NumPut(X,Rect,0,"UInt")
        NumPut(Y,Rect,4,"UInt")
        NumPut(X + W,Rect,8,"UInt")
        NumPut(Y + H,Rect,12,"UInt")

        ;trigger redrawing of the window
        If !DllCall("InvalidateRect","UPtr",this.hWindow,"UPtr",&Rect,"UInt",0)
            throw Exception("INTERNAL_ERROR",A_ThisFunc,"Could not add rectangle to update region (error in InvalidateRect)")
        If !DllCall("UpdateWindow","UPtr",this.hWindow)
            throw Exception("INTERNAL_ERROR",A_ThisFunc,"Could not update window (error in UpdateWindow)")

        Return, this
    }

    PaintCallback(Message,wParam,lParam,hWindow,pInstance)
    {
        If Message != 0xF ;WM_PAINT
            Return, DllCall("Comctl32\DefSubclassProc","UPtr",hWindow,"UInt",Message,"UPtr",wParam,"UPtr",lParam,"UPtr") ;call the next handler in the window's subclass chain

        ;prepare window for painting
        VarSetCapacity(PaintStruct,A_PtrSize + 60)
        hWindowDC := DllCall("BeginPaint","UPtr",hWindow,"UPtr",&PaintStruct,"UPtr")
        If !hWindowDC
            throw Exception("INTERNAL_ERROR",A_ThisFunc,"Could not prepare window for painting (error in BeginPaint)")

        this := Object(pInstance) ;obtain the instance

        If this.Surface ;surface attached
        {
            ;obtain dimensions of update region
            X := NumGet(PaintStruct,A_PtrSize + 4,"UInt")
            Y := NumGet(PaintStruct,A_PtrSize + 8,"UInt")
            W := NumGet(PaintStruct,A_PtrSize + 12,"UInt") - X
            H := NumGet(PaintStruct,A_PtrSize + 16,"UInt") - Y

            ;create the GDI bitmap
            hBitmap := 0
            this.CheckStatus(DllCall("gdiplus\GdipCreateHBITMAPFromBitmap","UPtr",this.Surface.pBitmap,"UPtr*",hBitmap,"UInt",0x000000)
                ,"GdipCreateHBITMAPFromBitmap","Could not convert GDI+ bitmap to GDI bitmap")

            ;select the bitmap into the memory device context
            hOriginalBitmap := DllCall("SelectObject","UPtr",this.hMemoryDC,"UPtr",hBitmap,"UPtr")
            If !hOriginalBitmap
                throw Exception("INTERNAL_ERROR",A_ThisFunc,"Could not select bitmap into memory device context (error in SelectObject)")

            ;transfer bitmap from memory device context to window device context
            If !DllCall("BitBlt","UPtr",hWindowDC,"Int",X,"Int",Y,"Int",W,"Int",H,"UPtr",this.hMemoryDC,"Int",X,"Int",Y,"UInt",0xCC0020) ;SRCCOPY
                throw Exception("INTERNAL_ERROR",A_ThisFunc,"Could not transfer bitmap data from memory device context to window device context (error in BitBlt)")

            ;deselect the bitmap from the memory device context
            If !DllCall("SelectObject","UPtr",this.hMemoryDC,"UPtr",hOriginalBitmap,"UPtr")
                throw Exception("INTERNAL_ERROR",A_ThisFunc,"Could not deselect bitmap from memory device context (error in SelectObject)")

            ;delete the bitmap
            If !DllCall("DeleteObject","UPtr",hBitmap)
                throw Exception("INTERNAL_ERROR",A_ThisFunc,"Could not delete bitmap (error in DeleteObject)")
        }

        ;finish painting window
        DllCall("EndPaint","UPtr",hWindow,"UPtr",&PaintStruct)
        Return, 0
    }

    StubCheckStatus(Result,Name,Message)
    {
        Return, this
    }

    CheckStatus(Result,Name,Message)
    {
        static StatusValues := ["Status.GenericError"
                               ,"Status.InvalidParameter"
                               ,"Status.OutOfMemory"
                               ,"Status.ObjectBusy"
                               ,"Status.InsufficientBuffer"
                               ,"Status.NotImplemented"
                               ,"Status.Win32Error"
                               ,"Status.WrongState"
                               ,"Status.Aborted"
                               ,"Status.FileNotFound"
                               ,"Status.ValueOverflow"
                               ,"Status.AccessDenied"
                               ,"Status.UnknownImageFormat"
                               ,"Status.FontFamilyNotFound"
                               ,"Status.FontStyleNotFound"
                               ,"Status.NotTrueTypeFont"
                               ,"Status.UnsupportedGdiplusVersion"
                               ,"Status.GdiplusNotInitialized"
                               ,"Status.PropertyNotFound"
                               ,"Status.PropertyNotSupported"
                               ,"Status.ProfileNotFound"]
        If Result != 0 ;Status.Ok
            throw Exception("INTERNAL_ERROR",-1,Message . " (GDI+ error " . StatusValues[Result] . " in " . Name . ")")
        Return, this
    }
}
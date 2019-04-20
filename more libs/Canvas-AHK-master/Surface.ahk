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

class Surface
{
    __New(Width = 1,Height = 1)
    {
        ObjInsert(this,"",Object())

        If Width < 1
            throw Exception("INVALID_INPUT",-1,"Invalid width: " . Width)
        If Height < 1
            throw Exception("INVALID_INPUT",-1,"Invalid height: " . Height)

        pBitmap := 0
        this.CheckStatus(DllCall("gdiplus\GdipCreateBitmapFromScan0","Int",Width,"Int",Height,"Int",0,"Int",0x26200A,"UPtr",0,"UPtr*",pBitmap) ;PixelFormat32bppARGB
            ,"GdipCreateBitmapFromScan0","Could not create bitmap")
        this.pBitmap := pBitmap

        ;create a graphics object
        pGraphics := 0
        this.CheckStatus(DllCall("gdiplus\GdipGetImageGraphicsContext","UPtr",this.pBitmap,"UPtr*",pGraphics)
            ,"GdipGetImageGraphicsContext","Could not obtain graphics object")
        this.pGraphics := pGraphics

        this.States := []

        this.Width := Width
        this.Height := Height

        this.Interpolation := "None"
        this.Smooth := "None"
        this.Compositing := "Blend"
    }

    __Get(Key)
    {
        If (Key != "" && Key != "base")
            Return, this[""][Key]
    }

    __Set(Key,Value)
    {
        static InterpolationStyles := {None:   5 ;InterpolationMode.InterpolationModeNearestNeighbor
                                      ,Linear: 6 ;InterpolationMode.InterpolationModeHighQualityBilinear
                                      ,Cubic:  7} ;InterpolationMode.InterpolationModeHighQualityBicubic
        static SmoothStyles := {None: 3 ;SmoothingMode.SmoothingModeNone
                               ,Good: 4 ;SmoothingMode.SmoothingModeAntiAlias8x4
                               ,Best: 5} ;SmoothingMode.SmoothingModeAntiAlias8x8
        static CompositingStyles := {Blend:     0 ;CompositingMode.CompositingModeSourceOver
                                    ,Overwrite: 1} ;CompositingMode.CompositingModeSourceCopy
        If (Key = "Interpolation")
        {
            If !InterpolationStyles.HasKey(Value)
                throw Exception("INVALID_INPUT",-1,"Invalid interpolation mode: " . Value)
            this.CheckStatus(DllCall("gdiplus\GdipSetInterpolationMode","UPtr",this.pGraphics,"UInt",InterpolationStyles[Value])
                ,"GdipSetInterpolationMode","Could not set interpolation mode")
        }
        Else If (Key = "Smooth")
        {
            If !SmoothStyles.HasKey(Value)
                throw Exception("INVALID_INPUT",-1,"Invalid smooth mode: " . Value)
            this.CheckStatus(DllCall("gdiplus\GdipSetSmoothingMode","UPtr",this.pGraphics,"UInt",SmoothStyles[Value])
                ,"GdipSetSmoothingMode","Could not set smooth mode")
        }
        Else If (Key = "Compositing")
        {
            If !CompositingStyles.HasKey(Value)
                throw Exception("INVALID_INPUT",-1,"Invalid compositing mode: " . Value)
            this.CheckStatus(DllCall("gdiplus\GdipSetCompositingMode","UPtr",this.pGraphics,"UInt",CompositingStyles[Value])
                ,"GdipSetCompositingMode","Could not set compositing mode")
        }
        this[""][Key] := Value
        Return, Value
    }

    __Delete()
    {
        ;delete graphics object
        Result := DllCall("gdiplus\GdipDeleteGraphics","UPtr",this.pGraphics)
        If Result != 0 ;Status.Ok
        {
            DllCall("gdiplus\GdipDisposeImage","UPtr",this.pBitmap) ;delete bitmap object
            this.CheckStatus(Result,"GdipDeleteGraphics","Could not delete graphics object")
        }

        ;delete bitmap object
        this.CheckStatus(DllCall("gdiplus\GdipDisposeImage","UPtr",this.pBitmap)
            ,"GdipDisposeImage","Could not delete bitmap pointer")
    }

    Load(Path) ;wip: document this
    {
        Attributes := FileExist(Path)
        If !Attributes ;path does not exist
            throw Exception("INVALID_INPUT",-1,"Invalid path: " . Path)
        If InStr(Attributes,"D") ;path is not a file
            throw Exception("INVALID_INPUT",-1,"Invalid file: " . Path)

        ;create bitmap and obtain dimensions
        pBitmap := 0
        this.CheckStatus(DllCall("gdiplus\GdipCreateBitmapFromFile", "WStr",Path,"UPtr*",pBitmap) ;wip: should use higher level of exception as should CreateBitmap()
            ,"GdipCreateBitmapFromFile","Could not create bitmap from file")
        Width := 0
        this.CheckStatus(DllCall("gdiplus\GdipGetImageWidth","UPtr",pBitmap,"UInt*",Width)
            ,"GdipGetImageWidth","Could not obtain image width")
        Height := 0
        this.CheckStatus(DllCall("gdiplus\GdipGetImageHeight","UPtr",pBitmap,"UInt*",Height)
            ,"GdipGetImageHeight","Could not obtain image height")

        this.pBitmap := pBitmap
        this.Width := Width
        this.Height := Height
        Return, this
    }

    Save(Path)
    {
        ;wip: implement and document this
        Return, this
    }

    Clone(Width = "",Height = "")
    {
        Copy := new this.base(this.Width,this.Height)
        ;wip: clone the bitmap contents and settings and resize it
        Return, Copy
    }

    Clear(Color = 0x00000000)
    {
        If Color Is Not Integer
            throw Exception("INVALID_INPUT",-1,"Invalid color: " . Color)
        Return, this.CheckStatus(DllCall("gdiplus\GdipGraphicsClear","UPtr",this.pGraphics,"UInt",Color)
            ,"GdipGraphicsClear","Could not clear graphics")
    }

    Text(Brush,Font,Value,X,Y,W = "",H = "")
    {
        this.CheckBrush(Brush)
        this.CheckFont(Font)

        ;determine dimensions automatically if not specified
        If (W = "")
            W := 0
        If (H = "")
            H := 0

        ;create bounding rectangle
        this.CheckRectangle(X,Y,W,H)
        VarSetCapacity(Rectangle,16)
        NumPut(X,Rectangle,0,"Float")
        NumPut(Y,Rectangle,4,"Float")
        NumPut(W,Rectangle,8,"Float")
        NumPut(H,Rectangle,12,"Float")

        Return, this.CheckStatus(DllCall("gdiplus\GdipDrawString"
            ,"UPtr",this.pGraphics ;graphics handle
            ,"WStr",Value ;string value
            ,"Int",-1 ;null terminated
            ,"UPtr",Font.hFont ;font handle
            ,"UPtr",&Rectangle ;bounding rectangle
            ,"UPtr",Font.hFormat ;string format
            ,"UPtr",Brush.pBrush) ;fill brush
            ,"GdipDrawString","Could not draw text")
    }

    GetPixel(X,Y,ByRef Color)
    {
        this.CheckPoint(X,Y)
        If (X < 0 || X > this.Width)
            throw Exception("INVALID_INPUT",-1,"Invalid X-axis coordinate: " . X)
        If (Y < 0 || Y > this.Height)
            throw Exception("INVALID_INPUT",-1,"Invalid Y-axis coordinate: " . Y)

        Return, this.CheckStatus(DllCall("gdiplus\GdipBitmapGetPixel","UPtr",this.pBitmap,"Int",X,"Int",Y,"UInt*",Color)
            ,"GdipBitmapGetPixel","Could not obtain pixel from bitmap")
    }

    SetPixel(X,Y,Color)
    {
        this.CheckPoint(X,Y)
        If (X < 0 || X > this.Width)
            throw Exception("INVALID_INPUT",-1,"Invalid X-axis coordinate: " . X)
        If (Y < 0 || Y > this.Height)
            throw Exception("INVALID_INPUT",-1,"Invalid Y-axis coordinate: " . Y)
        If Color Is Not Integer
            throw Exception("INVALID_INPUT",-1,"Invalid color: " . Color)

        Return, this.CheckStatus(DllCall("gdiplus\GdipBitmapSetPixel","UPtr",this.pBitmap,"Int",X,"Int",Y,"UInt",Color)
            ,"GdipBitmapSetPixel","Could not set bitmap pixel")
    }

    Draw(Surface,X = 0,Y = 0,W = "",H = "",SourceX = 0,SourceY = 0,SourceW = "",SourceH = "")
    {
        If !Surface.pBitmap
            throw Exception("INVALID_INPUT",-1,"Invalid surface: " . Surface)

        If (W = "")
            W := this.Width
        If (H = "")
            H := this.Height
        If (SourceW = "")
            SourceW := Surface.Width
        If (SourceH = "")
            SourceH := Surface.Height

        this.CheckRectangle(X,Y,W,H)
        this.CheckRectangle(SourceX,SourceY,SourceW,SourceH)

        Return, this.CheckStatus(DllCall("gdiplus\GdipDrawImageRectRect","UPtr",this.pGraphics,"UPtr",Surface.pBitmap
            ,"Float",X,"Float",Y,"Float",W,"Float",H
            ,"Float",SourceX,"Float",SourceY,"Float",SourceW,"Float",SourceH
            ,"Int",2,"UPtr",0,"UPtr",0,"UPtr",0) ;Unit.UnitPixel
            ,"GdipDrawImageRectRect","Could not transfer image data to surface")
    }

    DrawArc(Pen,X,Y,W,H,Start,Sweep)
    {
        this.CheckPen(Pen)
        this.CheckSector(X,Y,W,H,Start,Sweep)
        Return, this.CheckStatus(DllCall("gdiplus\GdipDrawArc","UPtr",this.pGraphics,"UPtr",Pen.pPen,"Float",X,"Float",Y,"Float",W,"Float",H,"Float",Start - 90,"Float",Sweep)
            ,"GdipDrawArc","Could not draw arc")
    }

    DrawCurve(Pen,Points,Closed = False,Tension = 1)
    {
        this.CheckPen(Pen)
        Length := this.CheckPoints(Points,PointArray)
        If Tension Not Between 0 And 1
            throw Exception("INVALID_INPUT",-1,"Invalid curve tension: " . Tension)

        If Closed
            Return, this.CheckStatus(DllCall("gdiplus\GdipDrawClosedCurve2","UPtr",this.pGraphics,"UPtr",Pen.pPen,"UPtr",&PointArray,"Int",Length,"Float",Tension)
                ,"GdipDrawClosedCurve2","Could not draw curve")
        Return, this.CheckStatus(DllCall("gdiplus\GdipDrawCurve2","UPtr",this.pGraphics,"UPtr",Pen.pPen,"UPtr",&PointArray,"Int",Length,"Float",Tension)
            ,"GdipDrawCurve2","Could not draw curve")
    }

    DrawEllipse(Pen,X,Y,W,H)
    {
        this.CheckPen(Pen)
        this.CheckRectangle(X,Y,W,H)
        Return, this.CheckStatus(DllCall("gdiplus\GdipDrawEllipse","UPtr",this.pGraphics,"UPtr",Pen.pPen,"Float",X,"Float",Y,"Float",W,"Float",H)
            ,"GdipDrawEllipse","Could not draw ellipse")
    }

    DrawPie(Pen,X,Y,W,H,Start,Sweep)
    {
        this.CheckPen(Pen)
        this.CheckSector(X,Y,W,H,Start,Sweep)
        Return, this.CheckStatus(DllCall("gdiplus\GdipDrawPie","UPtr",this.pGraphics,"UPtr",Pen.pPen,"Float",X,"Float",Y,"Float",W,"Float",H,"Float",Start - 90,"Float",Sweep)
            ,"GdipDrawPie","Could not draw pie")
    }

    DrawPolygon(Pen,Points)
    {
        this.CheckPen(Pen)
        Length := this.CheckPoints(Points,PointArray)
        Return, this.CheckStatus(DllCall("gdiplus\GdipDrawPolygon","UPtr",this.pGraphics,"UPtr",Pen.pPen,"UPtr",&PointArray,"Int",Length)
            ,"GdipDrawPolygon","Could not draw polygon")
    }

    DrawRectangle(Pen,X,Y,W,H)
    {
        this.CheckPen(Pen)
        this.CheckRectangle(X,Y,W,H)
        Return, this.CheckStatus(DllCall("gdiplus\GdipDrawRectangle","UPtr",this.pGraphics,"UPtr",Pen.pPen,"Float",X,"Float",Y,"Float",W,"Float",H)
            ,"GdipDrawRectangle","Could not draw rectangle")
    }

    FillCurve(Brush,Points)
    {
        this.CheckBrush(Brush)
        Length := this.CheckPoints(Points,PointArray)
        Return, this.CheckStatus(DllCall("gdiplus\GdipFillClosedCurve","UPtr",this.pGraphics,"UPtr",Brush.pBrush,"UPtr",&PointArray,"Int",Length)
            ,"GdipFillClosedCurve","Could not fill curve")
    }

    FillEllipse(Brush,X,Y,W,H)
    {
        this.CheckBrush(Brush)
        this.CheckRectangle(X,Y,W,H)
        Return, this.CheckStatus(DllCall("gdiplus\GdipFillEllipse","UPtr",this.pGraphics,"UPtr",Brush.pBrush,"Float",X,"Float",Y,"Float",W,"Float",H)
            ,"GdipFillEllipse","Could not fill ellipse")
    }

    FillPie(Brush,X,Y,W,H,Start,Sweep)
    {
        this.CheckBrush(Brush)
        this.CheckSector(X,Y,W,H,Start,Sweep)
        Return, this.CheckStatus(DllCall("gdiplus\GdipFillPie","UPtr",this.pGraphics,"UPtr",Brush.pBrush,"Float",X,"Float",Y,"Float",W,"Float",H,"Float",Start - 90,"Float",Sweep)
            ,"GdipFillPie","Could not fill pie")
    }

    FillPolygon(Brush,Points)
    {
        this.CheckBrush(Brush)
        Length := this.CheckPoints(Points,PointArray)
        Return, this.CheckStatus(DllCall("gdiplus\GdipFillPolygon","UPtr",this.pGraphics,"UPtr",Brush.pBrush,"UPtr",&PointArray,"Int",Length)
            ,"GdipFillPolygon","Could not fill polygon")
    }

    FillRectangle(Brush,X,Y,W,H)
    {
        this.CheckBrush(Brush)
        this.CheckRectangle(X,Y,W,H)
        Return, this.CheckStatus(DllCall("gdiplus\GdipFillRectangle","UPtr",this.pGraphics,"UPtr",Brush.pBrush,"Float",X,"Float",Y,"Float",W,"Float",H)
            ,"GdipFillRectangle","Could not fill rectangle")
    }

    Line(Pen,X1,Y1,X2,Y2)
    {
        this.CheckPen(Pen)
        this.CheckLine(X1,Y1,X2,Y2)
        Return, this.CheckStatus(DllCall("gdiplus\GdipDrawLine","UPtr",this.pGraphics,"UPtr",Pen.pPen,"Float",X1,"FLoat",Y1,"Float",X2,"Float",Y2)
            ,"GdipDrawLine","Could not draw line")
    }

    Lines(Pen,Points)
    {
        this.CheckPen(Pen)
        Length := this.CheckPoints(Points,PointArray)
        Return, this.CheckStatus(DllCall("gdiplus\GdipDrawLines","UPtr",this.pGraphics,"UPtr",Pen.pPen,"UPtr",&PointArray,"Int",Length)
            ,"GdipDrawLines","Could not draw lines")
    }

    Push()
    {
        State := 0
        this.CheckStatus(DllCall("gdiplus\GdipSaveGraphics","UPtr",this.pGraphics,"UInt*",State) ;GraphicsState
            ,"GdipSaveGraphics","Could not save graphics state")
        this.States.Insert(State)
        Return, this
    }

    Pop()
    {
        If !this.States.HasKey(1) ;stack is empty
            throw Exception("INVALID_INPUT",-1,"Invalid transformation stack entries")
        State := this.States.Remove()
        this.CheckStatus(DllCall("gdiplus\GdipRestoreGraphics","UPtr",this.pGraphics,"UInt",State) ;GraphicsState
            ,"GdipRestoreGraphics","Could not restore graphics state")
        Return, this
    }

    Translate(X,Y)
    {
        this.CheckPoint(X,Y)
        Return, this.CheckStatus(DllCall("gdiplus\GdipTranslateWorldTransform","UPtr",this.pGraphics,"Float",X,"Float",Y,"UInt",0) ;MatrixOrder.MatrixOrderPrepend
            ,"GdipTranslateWorldTransform","Could not apply translation matrix")
    }

    Rotate(Angle)
    {
        If Angle Is Not Number
            throw Exception("INVALID_INPUT",-1,"Invalid angle: " . Angle)
        Return, this.CheckStatus(DllCall("gdiplus\GdipRotateWorldTransform","UPtr",this.pGraphics,"Float",Angle,"UInt",0) ;MatrixOrder.MatrixOrderPrepend
            ,"GdipRotateWorldTransform","Could not apply rotation matrix")
    }

    Scale(X,Y)
    {
        this.CheckPoint(X,Y)
        Return, this.CheckStatus(DllCall("gdiplus\GdipScaleWorldTransform","UPtr",this.pGraphics,"Float",X,"Float",Y,"UInt",0) ;MatrixOrder.MatrixOrderPrepend
            ,"GdipScaleWorldTransform","Could not apply scale matrix")
    }

    StubCheckStatus(Result,Name,Message)
    {
        Return, this
    }

    StubCheckPen(Pen)
    {
    }

    StubCheckBrush(Brush)
    {
    }

    StubCheckFormat(Brush)
    {
    }

    StubCheckLine(X1,Y1,X2,Y2)
    {
    }

    StubCheckRectangle(X,Y,W,H)
    {
    }

    StubCheckSector(X,Y,W,H,Start,Sweep)
    {
    }

    StubCheckPoint(X,Y)
    {
    }

    StubCheckPoints(Points,ByRef PointArray)
    {
        Length := Points.MaxIndex()
        VarSetCapacity(PointArray,Length << 3)
        Offset := 0
        Loop, %Length%
        {
            Point := Points[A_Index]
            NumPut(Point[1],PointArray,Offset,"Float"), Offset += 4
            NumPut(Point[2],PointArray,Offset,"Float"), Offset += 4
        }
        Return, Length
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

    CheckPen(Pen)
    {
        If !Pen.pPen
            throw Exception("INVALID_INPUT",-2,"Invalid pen: " . Pen)
    }

    CheckBrush(Brush)
    {
        If !Brush.pBrush
            throw Exception("INVALID_INPUT",-2,"Invalid brush: " . Brush)
    }

    CheckFont(Font)
    {
        If !(Font.hFontFamily && Font.hFont && Font.hFormat)
            throw Exception("INVALID_INPUT",-2,"Invalid font: " . Font)
    }

    CheckLine(X1,Y1,X2,Y2)
    {
        If X1 Is Not Number
            throw Exception("INVALID_INPUT",-2,"Invalid X-axis coordinate 1: " . X1)
        If Y1 Is Not Number
            throw Exception("INVALID_INPUT",-2,"Invalid Y-axis coordinate 1: " . Y1)
        If X2 Is Not Number
            throw Exception("INVALID_INPUT",-2,"Invalid X-axis coordinate 2: " . X2)
        If Y2 Is Not Number
            throw Exception("INVALID_INPUT",-2,"Invalid Y-axis coordinate 2: " . Y2)
    }

    CheckRectangle(X,Y,W,H)
    {
        If X Is Not Number
            throw Exception("INVALID_INPUT",-2,"Invalid X-axis coordinate: " . X)
        If Y Is Not Number
            throw Exception("INVALID_INPUT",-2,"Invalid Y-axis coordinate: " . Y)
        If W < 0
            throw Exception("INVALID_INPUT",-2,"Invalid width: " . W)
        If H < 0
            throw Exception("INVALID_INPUT",-2,"Invalid height: " . H)
    }

    CheckSector(X,Y,W,H,Start,Sweep)
    {
        If X Is Not Number
            throw Exception("INVALID_INPUT",-2,"Invalid X-axis coordinate: " . X)
        If Y Is Not Number
            throw Exception("INVALID_INPUT",-2,"Invalid Y-axis coordinate: " . Y)
        If W < 0
            throw Exception("INVALID_INPUT",-2,"Invalid width: " . W)
        If H < 0
            throw Exception("INVALID_INPUT",-2,"Invalid height: " . H)
        If Start Is Not Number
            throw Exception("INVALID_INPUT",-2,"Invalid start angle: " . Start)
        If Sweep Is Not Number
            throw Exception("INVALID_INPUT",-2,"Invalid sweep angle: " . Sweep)
    }

    CheckPoint(X,Y)
    {
        If X Is Not Number
            throw Exception("INVALID_INPUT",-2,"Invalid X-axis coordinate: " . X)
        If Y Is Not Number
            throw Exception("INVALID_INPUT",-2,"Invalid Y-axis coordinate: " . Y)
    }

    CheckPoints(Points,ByRef PointArray)
    {
        Length := Points.MaxIndex()
        If !Length
            throw Exception("INVALID_INPUT",-2,"Invalid point set: " . Points)
        VarSetCapacity(PointArray,Length << 3)
        Offset := 0
        Loop, %Length%
        {
            Point := Points[A_Index]
            If !IsObject(Point)
                throw Exception("INVALID_INPUT",-2,"Invalid point: " . Point)
            PointX := Point[1]
            PointY := Point[2]
            If PointX Is Not Number
                throw Exception("INVALID_INPUT",-2,"Invalid X-axis coordinate: " . PointX)
            If PointY Is Not Number
                throw Exception("INVALID_INPUT",-2,"Invalid Y-axis coordinate: " . PointX)

            NumPut(PointX,PointArray,Offset,"Float"), Offset += 4
            NumPut(PointY,PointArray,Offset,"Float"), Offset += 4
        }
        Return, Length
    }
}
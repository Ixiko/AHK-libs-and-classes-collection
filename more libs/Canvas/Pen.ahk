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

class Pen
{
    __New(Color = 0xFFFFFFFF,Width = 1)
    {
        If Color Is Not Integer
            throw Exception("INVALID_INPUT",-1,"Invalid color: " . Color)
        If Width Is Not Number
            throw Exception("INVALID_INPUT",-1,"Invalid width: " . Width)

        ObjInsert(this,"",Object())

        ;create the pen
        pPen := 0
        this.CheckStatus(DllCall("gdiplus\GdipCreatePen1","UInt",Color,"Float",Width,"UInt",2,"UPtr*",pPen) ;Unit.UnitPixel
            ,"GdipCreatePen1","Could not create pen")
        this.pPen := pPen

        ;set properties
        this.Color := Color
        this.Width := Width
        this.Join := "Miter"
        this.Type := "Solid"
        this.StartCap := "Flat"
        this.EndCap := "Flat"
    }

    __Delete()
    {
        ;delete the pen
        this.CheckStatus(DllCall("gdiplus\GdipDeletePen","UPtr",this.pPen)
            ,"GdipDeletePen","Could not delete pen")
    }

    __Get(Key)
    {
        If (Key != "" && Key != "base")
            Return, this[""][Key]
    }

    __Set(Key,Value)
    {
        static JoinStyles := Object("Miter",0 ;LineJoin.LineJoinMiter
                                   ,"Bevel",1 ;LineJoin.LineJoinBevel
                                   ,"Round",2) ;LineJoin.LineJoinRound
        static TypeStyles := Object("Solid",0 ;DashStyleSolid
                                   ,"Dash",1 ;DashStyleDash
                                   ,"Dot",2 ;DashStyleDot
                                   ,"DashDot",3) ;DashStyleDashDot
        static CapStyles := Object("Flat",0 ;LineCap.LineCapFlat
                                  ,"Square",1 ;LineCap.LineCapSquare
                                  ,"Round",2 ;LineCap.LineCapRound
                                  ,"Triangle",3) ;LineCap.LineCapTriangle
        If (Key = "Color") ;set pen color
        {
            If Value Is Not Integer
                throw Exception("INVALID_INPUT",-1,"Invalid color: " . Value)
            this.CheckStatus(DllCall("gdiplus\GdipSetPenColor","UPtr",this.pPen,"UInt",Value)
                ,"GdipSetPenColor","Could not set pen color")
        }
        Else If (Key = "Width") ;set pen width
        {
            If Value Is Not Number
                throw Exception("INVALID_INPUT",-1,"Invalid width: " . Value)
            this.CheckStatus(DllCall("gdiplus\GdipSetPenWidth","UPtr",this.pPen,"Float",Value)
                ,"GdipSetPenWidth","Could not set pen width")
        }
        Else If (Key = "Join") ;set pen line join style
        {
            If !JoinStyles.HasKey(Value)
                throw Exception("INVALID_INPUT",-1,"Invalid pen join: " . Value)
            this.CheckStatus(DllCall("gdiplus\GdipSetPenLineJoin","UPtr",this.pPen,"UInt",JoinStyles[Value])
                ,"GdipSetPenLineJoin","Could not set pen join")
        }
        Else If (Key = "Type") ;set pen type
        {
            If !TypeStyles.HasKey(Value)
                throw Exception("INVALID_INPUT",-1,"Invalid pen type: " . Value)
            this.CheckStatus(DllCall("gdiplus\GdipSetPenDashStyle","UPtr",this.pPen,"UInt",TypeStyles[Value])
                ,"GdipSetPenDashStyle","Could not set pen type")
        }
        Else If (Key = "StartCap") ;set pen start cap
        {
            If !CapStyles.HasKey(Value)
                throw Exception("INVALID_INPUT",-1,"Invalid pen start cap: " . Value)
            this.CheckStatus(DllCall("gdiplus\GdipSetPenStartCap","UPtr",this.pPen,"UInt",CapStyles[Value])
                ,"GdipSetPenStartCap","Could not set pen start cap")
        }
        Else If (Key = "EndCap") ;set pen end cap
        {
            If !CapStyles.HasKey(Value)
                throw Exception("INVALID_INPUT",-1,"Invalid pen end cap: " . Value)
            this.CheckStatus(DllCall("gdiplus\GdipSetPenEndCap","UPtr",this.pPen,"UInt",CapStyles[Value])
                ,"GdipSetPenEndCap","Could not set pen end cap")
        }
        this[""][Key] := Value
        Return, Value
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
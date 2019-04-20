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

class Brush
{
    __New(Color = 0xFFFFFFFF)
    {
        If Color Is Not Integer
            throw Exception("INVALID_INPUT",-1,"Invalid color: " . Color)

        ObjInsert(this,"",Object())

        ;create the brush
        pBrush := 0
        this.CheckStatus(DllCall("gdiplus\GdipCreateSolidFill","UInt",Color,"UPtr*",pBrush)
            ,"GdipCreateSolidFill","Could not create brush")
        this.pBrush := pBrush

        this.Color := Color
    }

    __Delete()
    {
        ;delete the brush
        this.CheckStatus(DllCall("gdiplus\GdipDeleteBrush","UPtr",this.pBrush)
            ,"GdipDeleteBrush","Could not delete brush")
    }

    __Get(Key)
    {
        If (Key != "" && Key != "base")
            Return, this[""][Key]
    }

    __Set(Key,Value)
    {
        If (Key = "Color") ;set brush color
        {
            If Value Is Not Integer
                throw Exception("INVALID_INPUT",-1,"Invalid color: " . Value)
            this.CheckStatus(DllCall("gdiplus\GdipSetSolidFillColor","UPtr",this.pBrush,"UInt",Value)
                ,"GdipSetSolidFillColor","Could not set brush color")
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
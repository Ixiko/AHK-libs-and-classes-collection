/*
 * Copyright (C) 2007, 2008, 2009 Windy Hill Technology LLC
 *
 * This file is part of Poker Shortcuts.
 *
 * Poker Shortcuts is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Poker Shortcuts is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with FT Table Opener.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Project Home: http://code.google.com/p/pokershortcuts/
 */
 
 
 
; *******************************************************************************
; -------------------------------------------------------------------------------
; Color Functions
; -------------------------------------------------------------------------------
; *******************************************************************************


ColorWithinTolerance(SampleColor, TestColor, Tolerance) {

   if (SampleColor == TestColor)
      return 1
   If (Tolerance == 0)
      return (SampleColor == TestColor)

    SampleColorRed := SampleColor >> 16
    TestColorRed := TestColor >> 16
    SampleColorGreen:= SampleColor >> 8 & 0xff
    TestColorGreen := TestColor >> 8 & 0xff
    SampleColorBlue := SampleColor & 0xff
    TestColorBlue := TestColor & 0xff
    return (    ( (SampleColorRed + Tolerance >= TestColorRed)     && (SampleColorRed - Tolerance <= TestColorRed) )
        &&      ( (SampleColorGreen + Tolerance >= TestColorGreen) && (SampleColorGreen - Toleranc <= TestColorGreene) )
        &&      ( (SampleColorBlue + Tolerance >= TestColorBlue)   && (SampleColorBlue - Tolerance <= TestColorBlue) )           )
}



; return the color at screen position XY
ColorGetAtXY(X,Y)
{

   local Color

   CoordMode, Pixel, Screen
   PixelGetColor, Color, X, Y, RGB

   return Color

}
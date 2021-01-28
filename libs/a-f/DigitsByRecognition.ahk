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
; Digit Recognition Functions
; -------------------------------------------------------------------------------
; *******************************************************************************


; Thanks to Roland for this elegant framework of code!!

;Get the value of a number that is presented graphically on the screen.
;Image files of the digits 0-9 and a decimal point (10 and 11) must be available in a folder where this script is located.
;     we allow for 2 different decimal point images cuz at small resolutions the decimal point is
;     sometimes a different image depending on what digit is next to it.
;     In the small table case, if there is a "4" to the left of the decimal point,
;     then we needed a different decimal point image.
; The decimal point is pretty critical to make the image of it correctly. If it is too simple, then
;     other characters may look like a decimal point too... best to have some black area above, below and to the sides of it.
;Additionally an "alternate" set of image files can be also in that directory, in case
;  it is not known which set of images files is needed (perhaps an alternate font color).
;If the Y positions are fixed numbers, then the caller should adjust these Y values by TBAdj
;   before calling this function. (of course, if the mouse is getting the values, then they are already adjusted)
;pWinId: id of the window to check
;pStartX,Y,pEndX,Y: starting and ending x and y pixel locations to search relative to window pWinId
;pPrefix: image file name prefix
;pExt: image file type extension (e.g. bmp, jpg, png, etc)
;pShades: color range for the imagesearch command
;pAltImagesFlag: if true, include a search for alternate digit images too
;    vStack := ImageNumberRecognition(WinId,vMouseX ,vMouseY - 7,vMouseX + 100,vMouseY + 11,ImagesFontsFolder . vTableFontSize . "-stk","bmp",ColTolNumbers,1)
DigitsByImageRecognition(X, Y, W, H, Prefix, Ext, Shades, AltImagesFlag,  WinId)
{

   global
   local BatchLines, CurrentDigit, DigitArray, LastX, NumberString, DigitLocStr
   local PO, LastDigitOffsetX
   local ClientScaleFactor

   PO := 10000            ; Pixel Offset:  this is used for a trick bit of coding.
                           ; when the imagesearch function returns a pixel location, they could be negative value,
                           ; because users have multiple monitors. But the code below uses the X values below
                           ; as a "psuedo" array index. But array values can't be negative. So, I'll add a
                           ; large number (10000) to all X values, so that the array indices are always positive.



   ; save the current batch lines to restore it later
   BatchLines = %A_BatchLines%
   ; set the speed to maximum
   SetBatchLines -1



   ; convert the x,y position to a screen position
   WindowScaledPos(X, Y, ClientScaleFactor, "Screen", WinId)
   ; scale the width and height for our table size
   W := Round(W * ClientScaleFactor)
   H := Round(H * ClientScaleFactor)
   
   
   ; make sure that the table is visible at XY
   if WIndowIsOverlayedAtXY(X,Y,WinId)
      return ""
   

;outputdebug, in digits recognition  %X%   %Y%   %W%   %H%   %Prefix%  tol:%Shades%
   ; loop thru the 10 digits plus the decimal point (CurrentDigit == 10 is for decimal points)
   Loop, 11
   {
      ; set what CurrentDigit we are on...   10 means decimal point
      CurrentDigit := a_index - 1

      ; reset the starting position
      LastDigitX := X

      ; move thru the pixel space looking for each occurance of this digit (CurrentDigit)...
      ;     save all of the X positions of this digit (and we'll sort them out later)
      Loop
      {
         ; set the starting position to be one pixel to the right of the last digit found
         XStart := LastDigitX + 1


         ;msgbox x1=%X1% x2=%X2%`ny1=%Y1% y2=%Y2%`nshades=%Shades%`ndir=%Dir%\%Digit%.%Ext%

         ; we don't need to adjust the Y position by TBAdj here, because it
         ;     should be adjusted by whoever calls this function
         CoordMode,Pixel,Screen
         ImageSearch, LastDigitX,, XStart, Y, X+W, Y+H, *%Shades% %Prefix%%CurrentDigit%.%Ext%


         ; if we don't find any more of this digit, then break
         If ( errorLevel )
            break

         ; *********   for some reason the ImageSearch is sometimes returning a negative
         ; *********    value for LastDigitX, which then creates an error message on the line
         ; *********    DigitArray%LastDigitX% := CurrentDigit    below (negative array element)
         ; *********    So, for a temp fix, let's trap for LastDigitX values that are
         ; *********    out of the range of 0-800
         ;if ((LastDigitX < 1) OR (LastDigitX > 799))
         ;{
         ;   break
         ;}


         LastDigitOffsetX := LastDigitX + PO

         ; add the pixel x location of this digit to a string: DigitLocStr
         DigitLocStr := DigitLocStr "," LastDigitOffsetX

         ; save CurrentDigit that was found in a psuedo array (DigitArray), where the index is the x position
         if (CurrentDigit == 10)
            DigitArray%LastDigitOffsetX% := "."
         else
            DigitArray%LastDigitOffsetX% := CurrentDigit
      }

      ; check if we need to also check for alternate image files
      ; This is useful if the font color might change during the process of reading the table
      ;     from one color to another (e.g. when the stack size change color when it is a players turn to bet)
      if AltImagesFlag
      {
         ; set the last X position to the starting position
         LastDigitX := X

         ; move thru the pixel space looking for each occurance of this digit (CurrentDigit)...
         ;     save all of the X positions of this digit (and we'll sort them out later)
         Loop
         {
            ; set the starting position to be one pixel to the right of the last digit found
            XStart := LastDigitX + 1

            ; we don't need to adjust the Y position by TBAdj here, because it
            ;     should be adjusted by whoever calls this function
            CoordMode,Pixel,Screen
            ImageSearch, LastDigitX,, XStart, Y, X+W, Y+H, *%Shades% %Prefix%%CurrentDigit%a.%Ext%

            ; if we don't find any more of this digit, then break
            If ( errorLevel )
            {
               break
            }


            ; *********   for some reason the ImageSearch is sometimes returning a negative
            ; *********    value for LastDigitX, which then creates an error message on the line
            ; *********    DigitArray%LastDigitX% := CurrentDigit    below (negative array element)
            ; *********    So, for a temp fix, let's trap for LastDigitX values that are
            ; *********    out of the range of 0-800
            ;if ((LastDigitX < 1) OR (LastDigitX > 799))
            ;{
            ;   break
            ;}


            LastDigitOffsetX := LastDigitX + PO

            ; add the pixel x location of this digit to a string: DigitLocStr
            DigitLocStr := DigitLocStr "," LastDigitOffsetX

            ; save digit that was found in a psuedo array (DigitArray), where the index is the x position
            if (CurrentDigit == 10)
               DigitArray%LastDigitOffsetX% := "."
            else
               DigitArray%LastDigitOffsetX% := CurrentDigit
         }
      }
   }
   ; All of the x-positions of digit matches are stored in DigitLocString (seperated by commas)
   ; sort the DigitLocString, with the lowest numbers first
   ;     remove any duplicates (which could possibly happen with alternate image files in there too,
   ;           if the area being scanned were to change to the alternate font half way thru this routine)
   Sort, DigitLocStr, N D, U

   ; Get one x-position at a time (which will be the index for DigitArray), which holds the actual number value
   ;     and one at a time these numbers are concatenated together to form the number called Number
   Loop, Parse, DigitLocStr, `,
   {
      NumberString := NumberString "" DigitArray%a_loopfield%
   }


   ; reset the script speed back to it's original value
   SetBatchLines %BatchLines%
   
   ; return the NumberString we found
   return NumberString
}







/*
DigitsByPixelCountGetValue()
   Purpose: This function looks for digits by counting pixels in each column of a digit and tries to find a match for those counts
               when a column of 0 pixels is found. we search the client area xywh
   Returns:
      DigitString - the numbers found
         A for All In
         S for Sitting Out
         "" if no digits found
   Parameters:
      X - x poistion in standard client area to search for digits
      Y - y "
      W - standardized width of search area
      H - standardized height of search area
      DigitsType - e.g. Bet, Stack or Pot. This var is used to get the colors and tolerances from the global variables
      ByRef PixelCountForAllDigitsStringReturned: for test purposes... this is the long pixel count string
      WinId: window id

Notes:
      1. I was having problems with the alternate color not reading the digits correctly on FT. This is black digits on white background.
      There sometimes seems to be a black pixel in the area below the stack numbers, and this would cause one of the columns to read incorrectly.
      To fix it, I had to reduce the Height parameter that it was checking from 15 down to 12. This seems to be reliable for all table sizes.

      2. Full Tilt on small tables does not have a blank row of pixels above the stack digits if the user's name has a decender character in it.
      I had to change the software to allow for a few pixels in this row for it to be considered a blank row. I suppose this could be a problem if
      the user only has a stack size of 1, in which case the blank row at the top would be intrepreted as the stack digit with on (since it might only have 1 pixel in the row.)
      The "y" has one pixel that is right above the stack numbers, and the "g" character has 2 pixels...  so we will allow for 2 pixels in the row.
      If the user's name has more than 2 pixels in the decenders, then this code won't work at the smallest of table sizes (need a table size that puts in a blank row of pixels.)

      3. On small full tilt tables, you can't position the initial starting position too far to the left, else the software doesn't read the stack size correctly.
      I have found that just to the left of the "Sitting Out" words is about right. for some reason it picks up a number of decimal point characters if
      X is too far to the left.

      4. At the larger table sizes, Stars tables go to a stack font that is not one solid color. It has the shading of the digits.
      But it does have one dominant color, and that is what I use to do the pixel count with. The color variation seems to be at
      least 10 for the other colors. So I captured the pixel counts setting the color variation to 1.
      This should work, unless there are some computers that show the color with more variation. I know that my alternate sony
      laptop has doesn't show the colors the same as my main sony laptop. So we need some color variation in there. So I'll try setting the variation
      to about 5.
      It may be that if this doesn't work, then we'll just have to tell users that have too much color variation in their font digits,
      that they can't use the larger table sizes on stars.

      5. One good testing method is to outputdebug the Y paramater to let you know if the software is finding the blank line above the digits.
      Also, output the digitstring and alternate and pixel count strings at the end of this function.
      In the debug, you can use a mouse position to look for the digit characters.


*/
DigitSearchByPixelCount(X,Y,W,H,DigitsType, ByRef PixelCountForAllDigitsStringReturned, WinId)
{
   global                     ; we need some global vars   %CasinoName%%DigitType%PixelCountForThisDigitString
   local ColumnNum, RowNum, PixelCountInColumn, ColorRGB, DigitString, PixelCountForThisDigitString, PixelCountForAllDigitsString
   local ClientScaleFactor, FirstPixelPosition, LastPixelPosition, LastMinusFirstPixelPosition, StringPosition, Temp

   local PixelCountInColumnAlternate, DigitStringAlternate, PixelCountForThisDigitStringAlternate, PixelCountForAllDigitsStringAlternate
   local FirstPixelPositionAlternate, LastPixelPositionAlternate, LastMinusFirstPixelPositionAlternate

   local StringPosition, Temp, ClientScaleFactor
   local Xpos, TopRowFound, CheckPrimaryColorFlag, CheckAlternateColorFlag
   local DigitsColor, DigitsColorTolerance, DigitsAlternateColorAvailable, DigitsAlternateColor, DigitsAlternateColorTolerance
   local DigitsBackgroundColor, DigitsBackgroundColorTolerance, DigitsAlternateBackgroundColor, DigitsAlternateBackgroundColorTolerance
   local PixelCountInRow, ScanWidth
   local CasinoName

   if NOT (CasinoName := CasinoName(WinId,A_ThisFunc))
      return ""

   ; need to do pixel searches based on the screen, so that the window does not need to be active
   coordmode, pixel, Screen


   ; all of the following are not used in here....   I could delete some of them to help speed

   ; Digits Colors
   ; normal color of the digits
   DigitsColor := %CasinoName%%DigitsType%DigitsColor
   ; color tolerance allowed for making a match
   DigitsColorTolerance := %CasinoName%%DigitsType%DigitsColorTolerance
   ; true if there are 2 possible colors for the digits (and background colors) (else set to 0)
   DigitsAlternateColorAvailable := %CasinoName%%DigitsType%DigitsAlternateColorAvailable
   ; alternate color of the stack digits (when it is the player's turn to act)
   DigitsAlternateColor := %CasinoName%%DigitsType%DigitsAlternateColor
   ; color tolerance allowed for making a match
   DigitsAlternateColorTolerance := %CasinoName%%DigitsType%DigitsAlternateColorTolerance
   ; normal background color behind the stack digits
   DigitsBackgroundColor := %CasinoName%%DigitsType%DigitsBackgroundColor
   ; color tolerance allowed for making a match
   DigitsBackgroundColorTolerance := %CasinoName%%DigitsType%DigitsBackgroundColorTolerance
   ; alternate background color behind the stack digits (when it is the player's turn to act)
   DigitsAlternateBackgroundColor := %CasinoName%%DigitsType%DigitsAlternateBackgroundColor
   ; color tolerance allowed for making a match
   DigitsAlternateBackgroundColorTolerance := %CasinoName%%DigitsType%DigitsAlternateBackgroundColorTolerance

;outputdebug, in digit search
   ; convert the x,y position to a window position
   WindowScaledPos(X, Y, ClientScaleFactor, "Screen", WinId)
   ; scale the width and height for our table size
   W := Round(W * ClientScaleFactor)
   H := Round(H * ClientScaleFactor)


   ; make sure that the table is visible at XY
   if WIndowIsOverlayedAtXY(X,Y,WinId)
      return ""

;outputdebug, in pixelcount   %X%, %Y%, %W%, %H%, %DigitsColor%


   ;  X and Y point to a spot to the left of the digits that we want to read. We need to find the blank row of pixels
   ; above the digits, so that we have a good reference point for starting.
   ; We will scan the to the right and if we see our color of pixels, then we move up a row, and look for our color until we find a
   ; blank row without our colored pixels. We will then adjust Y to be that top row.


   ; below we are going to scan for the digit colors looking to find a blank row of pixels that don't contain our digit color (and this will be the starting row to count pixels).
   ; But the color to look for can be confusing, because on a FT table, the digit colors can be black or white, and the background for the white digits can be black.
   ; So we don't exactly know what color to search for in the FT case.
   ; So we will look at the initial scan starting position, and see if it matches the primary background color. If it does, then we will only look for the primary digits color.
   ; Else we will see if it matches the alternate background color. If it does, then we will only look for the alternate digits color.
   ; Otherwise we will check both colors to check for the digits color.
   ; In the Stars case, the stack digits of the primary and alternate do not match the background of each other, so it isn't necessary to do this extra checking, and we can look for both colors.

   ; sample the starting color, to see what the background color is
   PixelGetColor, ColorRGB,X,Y,RGB

;junko := DigitsBackgroundColor
;outputdebug, junko:%junko%    samplecolor:%ColorRGB%

   ; check if the background color exists and it matches our initial sample color, then only check the primary color
   if  ((DigitsBackgroundColor <> "") AND (ColorWithinTolerance(ColorRGB, DigitsBackgroundColor, DigitsBackgroundColorTolerance)))
   {
      CheckPrimaryColorFlag := 1
      CheckAlternateColorFlag := 0
   }
   ; else check if the alternate background color exists and it matches our initial sample color, then only check the alternate color
   else if  (DigitsAlternateColorAvailable AND (DigitsAlternateBackgroundColor <> "") AND (ColorWithinTolerance(ColorRGB, DigitsAlternateBackgroundColor, DigitsAlternateBackgroundColorTolerance)))
   {
      CheckPrimaryColorFlag := 0
      CheckAlternateColorFlag := 1
   }
   ; else check for both colors
   else
   {
      CheckPrimaryColorFlag := 1
      CheckAlternateColorFlag := 1
   }


   ; XY parameters are at the top left hand corner of the area of where to look for the digits.
   ; But we have to start scanning at the middle of the digits, and we scan upwards looking for the first blank row.
   ; So, I will adjust the Y value downward 1/2 of the height so that we will start scanning from there
   Y += Round(H/2)


;outputdebug, starting to look at row %Y%    CheckPrimaryColorFlag:%CheckPrimaryColorFlag%    CheckAlternateColorFlag:%CheckAlternateColorFlag%

   TopRowFound := 0

   ; move up at least H rows looking for the blank row
   loop, % Round(H)
   {
      Xpos := X
      PixelCountInRow := 0

      ; find the width that we should scan
      ScanWidth := Round(W*3/4)



      ; scan half of the width
      loop,% ScanWidth
      {

         ; keep moving to the right so see if one of our colored pixels is there
         Xpos += 1

         PixelGetColor, ColorRGB,Xpos,Y,RGB
;outputdebug, x:%Xpos%    Color:%ColorRGB%    CheckPrimaryColorFlag:%CheckPrimaryColorFlag%    CheckAlternateColorFlag:%CheckAlternateColorFlag%
         ; if we have either of our colors here in this row, then this is not the top row to start on (we actually allow there
         ; to be up to MaximumAllowedNumPixelsInRowToBeBlank number of pixels in the row, to allow for decender characters in the row above these digits.
         ; This is currently needed on Full Tilt when reading the stack digits, because on small tables the user's name with decenders can fall
         ; into the row right above the stack digits.)
         if (CheckPrimaryColorFlag AND (ColorWithinTolerance(ColorRGB, DigitsColor, DigitsColorTolerance)))
         {
            PixelCountInRow++
            if (PixelCountInRow > %CasinoName%MaximumAllowedNumPixelsInRowToBeBlank)
               break
         }
         if (DigitsAlternateColorAvailable AND CheckAlternateColorFlag AND (ColorWithinTolerance(ColorRGB, DigitsAlternateColor, DigitsAlternateColorTolerance)))
         {
            PixelCountInRow++
            if (PixelCountInRow > %CasinoName%MaximumAllowedNumPixelsInRowToBeBlank)
               break
         }




      }     ; end of X position scan loop


      ; if we got to the end of the row, then it must have been void of our digit colored pixels, and this must be the real top row
      if (Xpos == (X + ScanWidth))
      {
         TopRowFound := 1
         Y += 1                  ; move back down to the top row of the font
         break
      }

      ; move up one row to see if that row is void of our pixel color
      Y -= 1


   }     ; end of Y position scan loop

   ; if we didn't find a "good" top row, then return
   if NOT TopRowFound
   {
;outputdebug, Top Row Not Found   
      return ""
   }
; GOOD TEST OUTPUT...   Y is the top row of the font
;outputdebug, Top Row Found at y:%Y%    ScanWidth:%ScanWidth%    PixelCountInRow:%PixelCountInRow%


   DigitString:=""
   PixelCountForAllDigitsString := ""
   PixelCountForThisDigitString := ""

   DigitStringAlternate:=""
   PixelCountForAllDigitsStringAlternate := ""
   PixelCountForThisDigitStringAlternate := ""

   ; loop on number of columns (w)
   loop, %W%
   {
      ColumnNum:= A_Index

      ;loop on the number of rows
      PixelCountInColumn:=0
      FirstPixelPosition := 0
      LastPixelPosition := 0

      PixelCountInColumnAlternate:=0
      FirstPixelPositionAlternate := 0
      LastPixelPositionAlternate := 0

      loop, %H%
      {
         RowNum:=A_Index
         PixelGetColor, ColorRGB,X+ColumnNum-1,Y+RowNum-1,RGB

         if (ColorWithinTolerance(ColorRGB, DigitsColor, DigitsColorTolerance))
         {
            ; keep track of the first and last pixel position in the digit
            if (!FirstPixelPosition)
               FirstPixelPosition := RowNum
            LastPixelPosition := RowNum
            PixelCountInColumn++
         }
         if (ColorWithinTolerance(ColorRGB, DigitsAlternateColor, DigitsAlternateColorTolerance))
         {
            ; keep track of the first and last pixel position in the digit
            if (!FirstPixelPositionAlternate)
               FirstPixelPositionAlternate := RowNum
            LastPixelPositionAlternate := RowNum
            PixelCountInColumnAlternate++
         }

      }

      ; if this column has at least x pixels in it, then add the count to PixelCountString
      if (PixelCountInColumn >= %CasinoName%MinimumPixelCountPerColumn)
      {
         ; Save the difference between the 1st and Last pixel position (we only use the last column of this digit later)
         LastMinusFirstPixelPosition := LastPixelPosition  - FirstPixelPosition
         ; convert the count to numberic/alpha for counts bigger than 9...   10=A, 11=B, etc
         if (PixelCountInColumn > 9)
         {
            ; check to make sure the the character is not too big and creating an illegal ASCII character
;            if (PixelCountInColumn > 35)
;               PixelCountInColumn := 35
            PixelCountInColumn := chr(64 + PixelCountInColumn - 9)
         }
         ; verify that this count is a letter or number and then add this count to the PixelCountString
         if PixelCountInColumn is alnum
            PixelCountForThisDigitString .= PixelCountInColumn
;outputdebug, %PixelCountForThisDigitString%
      }
      ; else this column has 0 or 1 pixels in it (could be the end of a valid number, or just a leading 0)
      else
      {
         ; if PixelCountString!="" then we are at the end of a sequence of columns that had pixels in them
         if (PixelCountForThisDigitString != "")
         {

            if (LastMinusFirstPixelPosition > 9)
               LastMinusFirstPixelPosition := chr(64 + LastMinusFirstPixelPosition - 9)
            ; add on this Extra char to the PixelCountForThisDigitString
            if LastMinusFirstPixelPosition is alnum
               PixelCountForThisDigitString .= LastMinusFirstPixelPosition
            ; decode what this PixelCOuntString was, using global variable for what we found, and add it to the previous valid digits
            Temp := "PixelCountDigits"
            DigitString .= %Temp%%PixelCountForThisDigitString%



;outputdebug, DigitString= %DigitString%       %CasinoName%   %DigitType%  %PixelCountForThisDigitString%
            PixelCountForAllDigitsString .= PixelCountForThisDigitString . A_Space
            ; reset PixelCountForThisDigitString for finding the next digit
            PixelCountForThisDigitString := ""
         }
      }

      ; if this column has 2 or more pixels in it, then add the count to PixelCountString
      if (PixelCountInColumnAlternate >= %CasinoName%MinimumPixelCountPerColumn)
      {
         ; Save the difference between the 1st and Last pixel position (we only use the last column of this digit later)
         LastMinusFirstPixelPositionAlternate := LastPixelPositionAlternate  - FirstPixelPositionAlternate
         ; convert the count to numberic/alpha for counts bigger than 9...   10=A, 11=B, etc
         if (PixelCountInColumnAlternate > 9)
         {
            ; check to make sure the the character is not too big and creating an illegal ASCII character
;            if (PixelCountInColumnAlternate > 35)
;               PixelCountInColumnAlternate := 35
            PixelCountInColumnAlternate := chr(64 + PixelCountInColumnAlternate - 9)
         }
         ; add this count to the PixelCountString, if the new character is a number or letter
         if PixelCountInColumnAlternate is alnum
            PixelCountForThisDigitStringAlternate .= PixelCountInColumnAlternate
;outputdebug, %PixelCountForThisDigitString%
      }
      ; else this column has 0 or 1 pixels in it (could be the end of a valid number, or just a leading 0)
      else
      {
         ; if PixelCountString!="" then we are at the end of a sequence of columns that had pixels in them
         if (PixelCountForThisDigitStringAlternate != "")
         {

            if (LastMinusFirstPixelPositionAlternate > 9)
               LastMinusFirstPixelPositionAlternate := chr(64 + LastMinusFirstPixelPositionAlternate - 9)
            ; add on this Extra char to the PixelCountForThisDigitString
            if LastMinusFirstPixelPositionAlternate is alnum
               PixelCountForThisDigitStringAlternate .= LastMinusFirstPixelPositionAlternate
            ; decode what this PixelCOuntString was, using global variable for what we found, and add it to the previous valid digits
            Temp := "PixelCountDigits"
            DigitStringAlternate .= %Temp%%PixelCountForThisDigitStringAlternate%



;outputdebug, DigitString= %DigitString%       %CasinoName%   %DigitType%  %PixelCountForThisDigitString%
            PixelCountForAllDigitsStringAlternate .= PixelCountForThisDigitStringAlternate . A_Space
            ; reset PixelCountForThisDigitString for finding the next digit
            PixelCountForThisDigitStringAlternate := ""
         }


      }
   }

;outputdebug, PixelCountForAllDigitsString= %PixelCountForAllDigitsString%

   ; sometimes a comma in the string is read as a decimal point (due to commas at the larger table sizes not having solid pixel colors for the tail of the comma).
   ; If there is a decimal point more than two digits to the left of the last character,
   ; then it must be a comma rather than a dp, so loop to remove all decimal points > 2 away from the end of the string
   Loop,
   {
      StringPosition := instr(DigitString,".")    ; find the first decimal point
      if StringPosition
      {
         ; if the position is less than more than 2 away from the end (ie not a real decimal point), then erase it
         if ((strlen(DigitString) - StringPosition) > 2)
            StringReplace, DigitString, DigitString,.,,
         ; else it must be a real dp, so break
         else
            break
      }
      ; no decimal points, so exit loop
      else
         break

   }

   ; same process... remove bad decimal points in alternate string
   Loop,
   {
      StringPosition := instr(DigitStringAlternate,".")    ; find the first decimal point
      if StringPosition
      {
         ; if the position is less than more than 2 away from the end (ie not a real decimal point), then erase it
         if ((strlen(DigitStringAlternate) - StringPosition) > 2)
            StringReplace, DigitStringAlternate, DigitStringAlternate,.,,
         ; else it must be a real dp, so break
         else
            break
      }
      ; no decimal points, so exit loop
      else
         break

   }

; GOOD TEST OUTPUT
;if (DigitsType == "Stack")
;{
;outputdebug,Main   %DigitString%        %PixelCountForAllDigitsString%
;outputdebug,Alt    %DigitStringAlternate%       %PixelCountForAllDigitsStringAlternate%
;}
   ; if DigitString contains something, then it must be the valid string to return, else return the alternate
   if (DigitString)
   {
      PixelCountForAllDigitsStringReturned := PixelCountForAllDigitsString
      return DigitString
   }
   else
   {
      PixelCountForAllDigitsStringReturned := PixelCountForAllDigitsStringAlternate
      return DigitStringAlternate
   }



}


/*

; OLD VERSION without the find the top row of blank pixels


DigitSearchByPixelCount(X,Y,W,H,PixelColor,PixelColorAlternate, ColorTolerance, ByRef PixelCountForAllDigitsStringReturned,  WinId)
{
   global                     ; we need some global vars   %CasinoName%%DigitType%PixelCountForThisDigitString
   local ColumnNum, RowNum, PixelCountInColumn, ColorRGB, DigitString, PixelCountForThisDigitString, PixelCountForAllDigitsString
   local ClientScaleFactor, FirstPixelPosition, LastPixelPosition, LastMinusFirstPixelPosition, StringPosition, Temp

   local PixelCountInColumnAlternate, DigitStringAlternate, PixelCountForThisDigitStringAlternate, PixelCountForAllDigitsStringAlternate
   local FirstPixelPositionAlternate, LastPixelPositionAlternate, LastMinusFirstPixelPositionAlternate

   local StringPosition, Temp, ClientScaleFactor

   ; need to do pixel searches based on the screen, so that the window does not need to be active
   coordmode, pixel, Screen




;outputdebug, in digit search
   ; convert the x,y position to a window position
   WindowScaledPos(X, Y, ClientScaleFactor, "Screen", WinId)
   ; scale the width and height for our table size
   W := Round(W * ClientScaleFactor)
   H := Round(H * ClientScaleFactor)


;outputdebug, %X%, %Y%, %W%, %H%, %PixelColor%



   DigitString:=""
   PixelCountForAllDigitsString := ""
   PixelCountForThisDigitString := ""

   DigitStringAlternate:=""
   PixelCountForAllDigitsStringAlternate := ""
   PixelCountForThisDigitStringAlternate := ""

   ; loop on number of columns (w)
   loop, %W%
   {
      ColumnNum:= A_Index

      ;loop on the number of rows
      PixelCountInColumn:=0
      FirstPixelPosition := 0
      LastPixelPosition := 0

      PixelCountInColumnAlternate:=0
      FirstPixelPositionAlternate := 0
      LastPixelPositionAlternate := 0

      loop, %H%
      {
         RowNum:=A_Index
         PixelGetColor, ColorRGB,X+ColumnNum-1,Y+RowNum-1,RGB

         if (ColorWithinTolerance(ColorRGB, PixelColor, ColorTolerance))
         {
            ; keep track of the first and last pixel position in the digit
            if (!FirstPixelPosition)
               FirstPixelPosition := RowNum
            LastPixelPosition := RowNum
            PixelCountInColumn++
         }
         if (ColorWithinTolerance(ColorRGB, PixelColorAlternate, ColorTolerance))
         {
            ; keep track of the first and last pixel position in the digit
            if (!FirstPixelPositionAlternate)
               FirstPixelPositionAlternate := RowNum
            LastPixelPositionAlternate := RowNum
            PixelCountInColumnAlternate++
         }

      }

      ; if this column has at least x pixels in it, then add the count to PixelCountString
      if (PixelCountInColumn >= %CasinoName%MinimumPixelCountPerColumn)
      {
         ; Save the difference between the 1st and Last pixel position (we only use the last column of this digit later)
         LastMinusFirstPixelPosition := LastPixelPosition  - FirstPixelPosition
         ; convert the count to numberic/alpha for counts bigger than 9...   10=A, 11=B, etc
         if (PixelCountInColumn > 9)
         {
            ; check to make sure the the character is not too big and creating an illegal ASCII character
;            if (PixelCountInColumn > 35)
;               PixelCountInColumn := 35
            PixelCountInColumn := chr(64 + PixelCountInColumn - 9)
         }
         ; verify that this count is a letter or number and then add this count to the PixelCountString
         if PixelCountInColumn is alnum
            PixelCountForThisDigitString .= PixelCountInColumn
;outputdebug, %PixelCountForThisDigitString%
      }
      ; else this column has 0 or 1 pixels in it (could be the end of a valid number, or just a leading 0)
      else
      {
         ; if PixelCountString!="" then we are at the end of a sequence of columns that had pixels in them
         if (PixelCountForThisDigitString != "")
         {

            if (LastMinusFirstPixelPosition > 9)
               LastMinusFirstPixelPosition := chr(64 + LastMinusFirstPixelPosition - 9)
            ; add on this Extra char to the PixelCountForThisDigitString
            if LastMinusFirstPixelPosition is alnum
               PixelCountForThisDigitString .= LastMinusFirstPixelPosition
            ; decode what this PixelCOuntString was, using global variable for what we found
            Temp := "PixelCountDigits"
            DigitString .= %Temp%%PixelCountForThisDigitString%



;outputdebug, DigitString= %DigitString%       %CasinoName%   %DigitType%  %PixelCountForThisDigitString%
            PixelCountForAllDigitsString .= PixelCountForThisDigitString . A_Space
            ; reset PixelCountForThisDigitString for finding the next digit
            PixelCountForThisDigitString := ""
         }
      }

      ; if this column has 2 or more pixels in it, then add the count to PixelCountString
      if ( ((PixelCountInColumnAlternate > 1) and CasinoName == "FT") OR ((PixelCountInColumnAlternate > 0) and CasinoName == "PS") )
      {
         ; Save the difference between the 1st and Last pixel position (we only use the last column of this digit later)
         LastMinusFirstPixelPositionAlternate := LastPixelPositionAlternate  - FirstPixelPositionAlternate
         ; convert the count to numberic/alpha for counts bigger than 9...   10=A, 11=B, etc
         if (PixelCountInColumnAlternate > 9)
         {
            ; check to make sure the the character is not too big and creating an illegal ASCII character
;            if (PixelCountInColumnAlternate > 35)
;               PixelCountInColumnAlternate := 35
            PixelCountInColumnAlternate := chr(64 + PixelCountInColumnAlternate - 9)
         }
         ; add this count to the PixelCountString, if the new character is a number or letter
         if PixelCountInColumnAlternate is alnum
            PixelCountForThisDigitStringAlternate .= PixelCountInColumnAlternate
;outputdebug, %PixelCountForThisDigitString%
      }
      ; else this column has 0 or 1 pixels in it (could be the end of a valid number, or just a leading 0)
      else
      {
         ; if PixelCountString!="" then we are at the end of a sequence of columns that had pixels in them
         if (PixelCountForThisDigitStringAlternate != "")
         {

            if (LastMinusFirstPixelPositionAlternate > 9)
               LastMinusFirstPixelPositionAlternate := chr(64 + LastMinusFirstPixelPositionAlternate - 9)
            ; add on this Extra char to the PixelCountForThisDigitString
            if LastMinusFirstPixelPositionAlternate is alnum
               PixelCountForThisDigitStringAlternate .= LastMinusFirstPixelPositionAlternate
            ; decode what this PixelCOuntString was, using global variable for what we found
            Temp := "PixelCountDigits"
            DigitString .= %Temp%%PixelCountForThisDigitStringAlternate%



;outputdebug, DigitString= %DigitString%       %CasinoName%   %DigitType%  %PixelCountForThisDigitString%
            PixelCountForAllDigitsStringAlternate .= PixelCountForThisDigitStringAlternate . A_Space
            ; reset PixelCountForThisDigitString for finding the next digit
            PixelCountForThisDigitStringAlternate := ""
         }


      }
   }

;outputdebug, PixelCountForAllDigitsString= %PixelCountForAllDigitsString%

   ; sometimes a comma in the string is read as a decimal point (due to commas at the larger table sizes not having solid pixel colors for the tail of the comma).
   ; If there is a decimal point more than two digits to the left of the last character,
   ; then it must be a comma rather than a dp, so loop to remove all decimal points > 2 away from the end of the string
   Loop,
   {
      StringPosition := instr(DigitString,".")    ; find the first decimal point
      if StringPosition
      {
         ; if the position is less than more than 2 away from the end (ie not a real decimal point), then erase it
         if ((strlen(DigitString) - StringPosition) > 2)
            StringReplace, DigitString, DigitString,.,,
         ; else it must be a real dp, so break
         else
            break
      }
      ; no decimal points, so exit loop
      else
         break

   }

   ; same process... remove bad decimal points in alternate string
   Loop,
   {
      StringPosition := instr(DigitStringAlternate,".")    ; find the first decimal point
      if StringPosition
      {
         ; if the position is less than more than 2 away from the end (ie not a real decimal point), then erase it
         if ((strlen(DigitStringAlternate) - StringPosition) > 2)
            StringReplace, DigitStringAlternate, DigitStringAlternate,.,,
         ; else it must be a real dp, so break
         else
            break
      }
      ; no decimal points, so exit loop
      else
         break

   }


   if (DigitString)
   {
      PixelCountForAllDigitsStringReturned := PixelCountForAllDigitsString
      return DigitString
   }
   else
   {
      PixelCountForAllDigitsStringReturned := PixelCountForAllDigitsString
      return DigitStringAlternate
   }



}

*/


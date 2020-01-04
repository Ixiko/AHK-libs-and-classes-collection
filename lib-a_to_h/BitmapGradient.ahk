/*  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

    Disclaimer: You may use these functions "ONLY" at your own risk. 

    * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

File Name   : BitmapGradient.ahk          
Download    : http://file.autohotkey.net/goyyah/Tips-N-Tricks/Gradients/BitmapGradient.ahk

Main Title  : Include File
Sub Title   : Two Pixel Bitmap Creator (Linear Gradient)

Description :  

   Creates a Two Pixel Bitmap (Horizontal/Vertical)

   Visit http://www.autohotkey.com/forum/viewtopic.php?p=61081#61081 
   for more information on Linear Gradients.


   CreateBMPGradient(Param1,Param2,Param3,Param4)

        Param1: File name to be created
        Param2: A Valid Hex Color code for the Bottom (or) Left pixel.
        Param3: A Valid Hex Color code for the Top (or) Right pixel.
        Param4: 0 (or) 1 . Vertical=1 / Horizontal=0 
             
        Example: Gui, Add, Picture, x0 y0 w640 h480, % CreateBMP("Bg.bmp","000000","0000FF",1)
               
   BGR(RGB) : Validates the R-G-B Colorcode an returns it reversed to B-G-R.
              Required by CreateBMPGradient()

   RandomHexColor() : Returns a Random Hex Color Code.
               
   Credits:

   I owe my deepest gratitude to Laszlo & PhiLho for the contribution to the
   AHK Community with their Binary Read/Write Routines.

   * - * - * - * - * - * - * - * - * - * - * - * - * - * - * - * - * - *
   *                                                                   *
   *  Topic  : Binary file I/O with binary buffers                     *
   *  Posted @ http://www.autohotkey.com/forum/viewtopic.php?t=4604    *
   *                                                                   *
   *  by Laszlo Hars aka Laszlo            Website: http://hars.us/    *
   *                                                                   *
   * - * - * - * - * - * - * - * - * - * - * - * - * - * - * - * - * - *


   * - * - * - * - * - * - * - * - * - * - * - * - * - * - * - * - * - *
   *                                                                   *
   *  Topic  : Binary file reading and writing                         *
   *  Posted @ http://www.autohotkey.com/forum/viewtopic.php?t=7549    *
   *                                                                   *
   *  by Philippe Lhoste aka PhiLho  Website: http://Phi.Lho.free.fr   *
   *                                                                   *
   * - * - * - * - * - * - * - * - * - * - * - * - * - * - * - * - * - *

         
Author      : A.N.Suresh Kumar aka "Goyyah"
Email       : arian.suresh@gmail.com

Created     : 2006-05-15
Modified    : 2006-05-23

Version     : 1.0

Scripted in : AutoHotkey Version 1.0.44.00 , www.autohotkey.com 

*/

CreateBMPGradient(File, RGB1, RGB2, Vertical=1) { 

   If (BGR(RGB1)="" OR BGR(RGB2)="")
      Return Null 

   Hs1:="424d3e00000000000000360000002800000"
   Hs3:="001001800000000000800000000000000000000000000000000000000"

   If Vertical {
     Hs2:="0010000000200000"
     HexString:= Hs1 Hs2 Hs3 BGR(RGB1) "00" BGR(RGB2) "00"  
   }
   Else {
     Hs2:="0020000000100000"
     HexString:= Hs1 Hs2 Hs3 BGR(RGB1) BGR(RGB2) "0000"
   }

   Handle:= DllCall("CreateFile","str",file,"Uint",0x40000000
                ,"Uint",0,"UInt",0,"UInt",4,"Uint",0,"UInt",0) 

   Loop 62 { 
     StringLeft, Hex, HexString, 2         
     StringTrimLeft, HexString, HexString, 2  
     Hex = 0x%Hex%
     DllCall("WriteFile","UInt", Handle,"UChar *", Hex
     ,"UInt",1,"UInt *",UnusedVariable,"UInt",0) 
    } 
  
   DllCall("CloseHandle", "Uint", Handle)

Return File
} 

BGR(RGB) { 

  If (StrLen(RGB)<>6) 
     Return Null 

  Loop, Parse, RGB 
     If A_LoopField not in 0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F 
       Return Null

  StringMid,R,RGB,1,2
  StringMid,G,RGB,3,2
  StringMid,B,RGB,5,2

Return B G R
}

RandomHexColor(Range1=0,Range2=255) { 

 Random, _RGB1, %Range1%, %Range2% 
 Random, _RGB2, %Range1%, %Range2% 
 Random, _RGB3, %Range1%, %Range2% 

 SetFormat, Integer, Hex 
 _RGB1+=0 
 _RGB2+=0 
 _RGB3+=0 

 If StrLen(_RGB1) = 3 
    _RGB1= 0%_RGB1% 

 If StrLen(_RGB2) = 3 
    _RGB2= 0%_RGB2% 

 If StrLen(_RGB3) = 3 
    _RGB3= 0%_RGB3% 

 SetFormat, Integer, D 
 HEXString = % _RGB1 _RGB2 _RGB3 
 StringReplace, HEXString, HEXString,0x,,All 
 StringUpper, HEXString, HEXString 

Return HexString 
}
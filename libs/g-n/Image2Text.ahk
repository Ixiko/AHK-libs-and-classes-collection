FindText(x,y,w,h,err1,err0,text) {
  xywh2xywh(x-w,y-h,2*w+1,2*h+1,x,y,w,h)
  if (w<1 or h<1)
    return, 0
  bch:=A_BatchLines
  
  ;--------------------------------------
  GetBitsFromScreen(x,y,w,h,Scan0,Stride,bits)
  ;--------------------------------------
  sx:=0, sy:=0, sw:=w, sh:=h, arr:=[]
  Loop, Parse, text, |
  {
    v:=A_LoopField
    IfNotInString, v, $, Continue
    comment:="", e1:=err1, e0:=err0
    ; You Can Add Comment Text within The <>
    if RegExMatch(v,"<([^>]*)>",r)
      v:=StrReplace(v,r), comment:=Trim(r1)
    ; You can Add two fault-tolerant in the [], separated by commas
    if RegExMatch(v,"\[([^\]]*)]",r)
    {
      v:=StrReplace(v,r), r1.=","
      StringSplit, r, r1, `,
      e1:=r1, e0:=r2
    }
    StringSplit, r, v, $
    color:=r1, v:=r2
    StringSplit, r, v, .
    w1:=r1, v:=base64tobit(r2), h1:=StrLen(v)//w1
    if (r0<2 or h1<1 or w1>sw or h1>sh or StrLen(v)!=w1*h1)
      Continue
    ;--------------------------------------------
    mode:=InStr(color,"*") ? 1:0
    color:=StrReplace(color,"*") . "@"
    StringSplit, r, color, @
    color:=mode=1 ? r1 : ((r1-1)//w1)*Stride+Mod(r1-1,w1)*4
    n:=Round(r2,2)+(!r2), n:=Floor(255*3*(1-n))
    StrReplace(v,"1","",len1), len0:=StrLen(v)-len1
    VarSetCapacity(allpos, 1024*4, 0), k:=StrLen(v)*4
    VarSetCapacity(s1, k, 0), VarSetCapacity(s0, k, 0)
    ;--------------------------------------------
    if (ok:=PicFind(mode,color,n,Scan0,Stride,sx,sy,sw,sh
      ,v,s1,s0,Round(len1*e1),Round(len0*e0),w1,h1,allpos))
      or (err1=0 and err0=0
      and (ok:=PicFind(mode,color,n,Scan0,Stride,sx,sy,sw,sh
      ,v,s1,s0,Round(len1*0.05),Round(len0*0.05),w1,h1,allpos)))
    {
      Loop, % ok
        pos:=NumGet(allpos, 4*(A_Index-1), "uint")
        , rx:=(pos&0xFFFF)+x, ry:=(pos>>16)+y
        , arr.Push( [rx,ry,w1,h1,comment] )
    }
  }
  SetBatchLines, %bch%
  return, arr.MaxIndex() ? arr:0
}

PicFind(mode, color, n, Scan0, Stride, sx, sy, sw, sh , ByRef text, ByRef s1, ByRef s0 , err1, err0, w1, h1, ByRef allpos) {
  static MyFunc
  if !MyFunc
  {
    x32:="5557565383EC488B4424782B8424940000008B742470894"
    . "4242083C001894424348B44247C2B842498000000894424188"
    . "3C0018944241C8B4424740FAF44246C8D04B0894424148B842"
    . "49800000085C00F8E9F04000031ED31FF31F6892C248BAC248"
    . "800000031DB897C24048D7426008B84249400000085C07E568"
    . "B8424800000008B8C24800000008B54240401D8039C2494000"
    . "00001D9895C2408EB13669083C0018954B50083C60183C2043"
    . "9C1741C80383175EA8B9C248400000083C0018914BB83C7018"
    . "3C20439C175E48B5C2408830424018B54246C8B04240154240"
    . "439842498000000758789F839F7897C24100F4CC68944240C8"
    . "B44245C85C00F85E90100008B44241C85C00F8EDE0300008B4"
    . "4241403442460034424688B7C2418897424148B742468C7442"
    . "43000000000894424408B442474894424388D4407018B7C247"
    . "0894424448B4424208D4438018B7C24608944242C8B4424680"
    . "1F8894424288B7C243485FF0F8E560100008B442438C1E0108"
    . "944243C8B442470894424188B442440894424248DB42600000"
    . "0008B4424248B6C240C0FB6580289C72B7C242885ED891C240"
    . "FB658010FB600895C2404894424080F84D50200008B8424900"
    . "0000031DB894424208B84248C0000008944241CEB778D76008"
    . "DBC27000000003B5C24147D5A8B8424880000008B149801FA0"
    . "FB64C16020FB64416012B0C242B4424040FB614162B5424088"
    . "9CDC1FD1F31E929E989C5C1FD1F31E829E889D5C1FD1F01C13"
    . "1EA29EA01CA395424647C10836C242001787589F68DBC27000"
    . "0000083C3013B5C240C0F8444020000395C24107E8D8B8C248"
    . "40000008B049901F80FB64C06020FB65406012B0C242B54240"
    . "40FB604062B44240889CDC1FD1F31E929E989D5C1FD1F31EA2"
    . "9EA89C5C1FD1F01D131E829E801C83B4424640F8E3FFFFFFF8"
    . "36C241C010F8934FFFFFF834424180183442424048B4424183"
    . "944242C0F85CCFEFFFF83442438018B7C246C8B442438017C2"
    . "4403B4424440F8583FEFFFF8B44243083C4485B5E5F5DC2440"
    . "08B4424608B5C247C83C00169E8E80300008B4424140344246"
    . "889C78B442478C1E00289042431C085DB7E548974240489FE8"
    . "9C78B4C247885C97E338B042489F18D1C060FB651020FB6410"
    . "169D22B01000069C04B02000001C20FB6016BC07201D039C50"
    . "F9F410383C10439CB75D583C7010374246C397C247C75B88B7"
    . "424048B4424148B54241C83C00385D20F8E6F0100008B7C241"
    . "88944242489F58B4424748B7424108B5C240CC744241800000"
    . "0008944241C8D4407018B7C2470894424288B4424208D44380"
    . "1894424148B44243485C00F8EA80000008B44241CC1E010894"
    . "424108B4424708904248B4424248944240C9085DB0F84D8000"
    . "0008B8424900000008B94248C0000008B4C240C034C2468894"
    . "424088954240431C0EB318DB60000000039E87D1C8B9424880"
    . "000008B3C8201CF803F00740B836C240801782B8D74260083C"
    . "00139D80F848500000039C67ED18B9424840000008B3C8201C"
    . "F803F0174C0836C24040179B9830424018344240C048B04243"
    . "B4424140F8573FFFFFF8344241C018B7C246C8B44241C017C2"
    . "424394424280F8531FFFFFF8B442418E952FEFFFF8B7C24308"
    . "B5424180B54243C8B9C249C00000089F883C0013DFF0300008"
    . "914BB0F8F2CFEFFFF89442430E9ECFDFFFF8B7C24188B14240"
    . "B5424108B8C249C00000089F883C0013DFF0300008914B90F8"
    . "FFEFDFFFF89442418E969FFFFFF31C0E9EEFDFFFFC744240C0"
    . "000000031F6C744241000000000E9ECFBFFFF90909090"
    x64:="4157415641554154555756534883EC488BAC24000100008"
    . "B8424C80000008BBC24080100008BB424B80000004D89CC898"
    . "C24900000008994249800000029E844898424A00000004C8BA"
    . "C24E00000008944240883C001488B9C24E8000000894424148"
    . "B8424D000000029F88944240C83C001894424048B8424C0000"
    . "0000FAF8424B000000085FF8D04B08904240F8E320500004C8"
    . "9A424A80000004C8BA424D80000008D34AD000000004531C94"
    . "531D24531F64531FF4531DB0F1F800000000085ED7E454963D"
    . "3468D040E4489C84C01E2EB164963CE4883C2014183C601890"
    . "48B83C0044139C0741D803A3175E54963CF4883C2014183C70"
    . "14189448D0083C0044139C075E34101EB4183C20144038C24B"
    . "00000004439D775A64C8BA424A80000004539F74489F5410F4"
    . "DEF448B9424900000004585D20F8547020000448B4C2404458"
    . "5C90F8E73040000486304244863BC24B00000008BB424B8000"
    . "000C7442410000000004C89AC24E000000048899C24E800000"
    . "08944243848897C243048894424208B7C240C8B8424C000000"
    . "0894424188D4407018944243C4863842498000000488944242"
    . "88B4424088D4430018944240C448B4424144585C00F8E85010"
    . "0008B442418448B5C2438C1E0108944241C488B44242048034"
    . "424284D8D2C048B8424B8000000890424660F1F44000085ED4"
    . "10FB65D02410FB67501410FB67D000F84490300008B8424F80"
    . "000004531C0894424088B8424F000000089442404E98800000"
    . "04539CE7E76488B8C24E8000000428B04814401D88D5002486"
    . "3D2410FB60C148D50014898410FB604044863D2410FB614142"
    . "9D94189C929F841C1F91F29F24431C94429C94189D141C1F91"
    . "F4431CA4429CA4189C141C1F91F01D14431C84429C801C8398"
    . "424A00000007C10836C2408010F88930000000F1F440000498"
    . "3C0014439C50F8EA30200004539C74589C10F8E6CFFFFFF488"
    . "B8C24E0000000428B04814401D88D50024863D2410FB60C148"
    . "D50014898410FB604044863D2410FB6141429D94189CA29F84"
    . "1C1FA1F29F24431D14429D14189D241C1FA1F4431D24429D24"
    . "189C241C1FA1F01D14431D04429D001C83B8424A00000000F8"
    . "E02FFFFFF836C2404010F89F7FEFFFF830424014983C504418"
    . "3C3048B04243944240C0F85A9FEFFFF83442418018BBC24B00"
    . "000008B442418017C2438488B7C243048017C24203B44243C0"
    . "F8545FEFFFF8B4424104883C4485B5E5F5D415C415D415E415"
    . "FC38B8424980000008B8C24D0000000448D48014569C9E8030"
    . "00085C90F8E9F00000048638424B00000004C6314244531DB4"
    . "4897C24104489742418448BBC24D0000000448BB424C800000"
    . "04889C78B8424C80000004D01E283E801488D3485040000006"
    . "62E0F1F8400000000004585F67E394E8D04164C89D10F1F400"
    . "00FB651020FB6410169D22B01000069C04B02000001C20FB60"
    . "16BC07201D04139C10F9F41034883C1044939C875D24183C30"
    . "14901FA4539DF75B6448B7C2410448B7424188B04248B54240"
    . "483C00385D20F8E680100008B7C240C894424108B8424C0000"
    . "0008BB424B8000000894424048D44070131FF893C248BBC24F"
    . "80000008944240C8B442408448D5C30018B44241485C00F8E8"
    . "E0000008B4424048BB424B8000000448B442410C1E01089442"
    . "40885ED0F84C80000004189FA448B8C24F000000031C0EB356"
    . "60F1F8400000000004439F17D1B8B14834401C24863D241803"
    . "C1400740B4183EA0178300F1F4400004883C00139C50F8E840"
    . "000004439F889C17DCD418B5485004401C24863D241803C140"
    . "174BB4183E90179B583C6014183C0044439DE7589834424040"
    . "18BB424B00000008B442404017424103B44240C0F8548FFFFF"
    . "F8B3C2489F8E924FEFFFF9048635424108B0C240B4C241C488"
    . "BBC241001000089D083C001890C973DFF0300000F8FFCFDFFF"
    . "F89442410E9AEFDFFFF486314248B4C24084C8B94241001000"
    . "009F189D041890C9283C0013DFF0300000F8FCDFDFFFF83C60"
    . "14183C0048904244439DE0F85F7FEFFFFE969FFFFFF31C0E9A"
    . "EFDFFFF31ED4531F64531FFE95AFBFFFF9090909090909090"
    MCode(MyFunc, A_PtrSize=8 ? x64:x32)
  }
  return, DllCall(&MyFunc, "int",mode
    , "uint",color, "int",n, "ptr",Scan0, "int",Stride
    , "int",sx, "int",sy, "int",sw, "int",sh
    , "AStr",text, "ptr",&s1, "ptr",&s0
    , "int",err1, "int",err0, "int",w1, "int",h1, "ptr",&allpos)
}

xywh2xywh(x1,y1,w1,h1,ByRef x,ByRef y,ByRef w,ByRef h) {
  SysGet, zx, 76
  SysGet, zy, 77
  SysGet, zw, 78
  SysGet, zh, 79
  left:=x1, right:=x1+w1-1, up:=y1, down:=y1+h1-1
  left:=left<zx ? zx:left, right:=right>zx+zw-1 ? zx+zw-1:right
  up:=up<zy ? zy:up, down:=down>zy+zh-1 ? zy+zh-1:down
  x:=left, y:=up, w:=right-left+1, h:=down-up+1
}

GetBitsFromScreen(x,y,w,h,ByRef Scan0,ByRef Stride,ByRef bits) {
  VarSetCapacity(bits,w*h*4,0), bpp:=32
  Scan0:=&bits, Stride:=((w*bpp+31)//32)*4
  Ptr:=A_PtrSize ? "UPtr" : "UInt", PtrP:=Ptr . "*"
  win:=DllCall("GetDesktopWindow", Ptr)
  hDC:=DllCall("GetWindowDC", Ptr,win, Ptr)
  mDC:=DllCall("CreateCompatibleDC", Ptr,hDC, Ptr)
  ;-------------------------
  VarSetCapacity(bi, 40, 0), NumPut(40, bi, 0, "int")
  NumPut(w, bi, 4, "int"), NumPut(-h, bi, 8, "int")
  NumPut(1, bi, 12, "short"), NumPut(bpp, bi, 14, "short")
  ;-------------------------
  if hBM:=DllCall("CreateDIBSection", Ptr,mDC, Ptr,&bi
    , "int",0, PtrP,ppvBits, Ptr,0, "int",0, Ptr)
  {
    oBM:=DllCall("SelectObject", Ptr,mDC, Ptr,hBM, Ptr)
    DllCall("BitBlt", Ptr,mDC, "int",0, "int",0, "int",w, "int",h
      , Ptr,hDC, "int",x, "int",y, "uint",0x00CC0020|0x40000000)
    DllCall("RtlMoveMemory", Ptr,Scan0, Ptr,ppvBits, Ptr,Stride*h)
    DllCall("SelectObject", Ptr,mDC, Ptr,oBM)
    DllCall("DeleteObject", Ptr,hBM)
  }
  DllCall("DeleteDC", Ptr,mDC)
  DllCall("ReleaseDC", Ptr,win, Ptr,hDC)
}

MCode(ByRef code, hex) {
  ListLines, Off
  bch:=A_BatchLines
  
  VarSetCapacity(code, StrLen(hex)//2)
  Loop, % StrLen(hex)//2
    NumPut("0x" . SubStr(hex,2*A_Index-1,2),code,A_Index-1,"uchar")
  Ptr:=A_PtrSize ? "UPtr" : "UInt"
  DllCall("VirtualProtect", Ptr,&code, Ptr
    ,VarSetCapacity(code), "uint",0x40, Ptr . "*",0)
  SetBatchLines, %bch%
  ListLines, On
}

base64tobit(s) {
  ListLines, Off
  Chars:="0123456789+/ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    . "abcdefghijklmnopqrstuvwxyz"
  SetFormat, IntegerFast, d
  StringCaseSense, On
  Loop, Parse, Chars
  {
    i:=A_Index-1, v:=(i>>5&1) . (i>>4&1)
      . (i>>3&1) . (i>>2&1) . (i>>1&1) . (i&1)
    s:=StrReplace(s,A_LoopField,v)
  }
  StringCaseSense, Off
  s:=SubStr(s,1,InStr(s,"1",0,0)-1)
  s:=RegExReplace(s,"[^01]+")
  ListLines, On
  return, s
}

bit2base64(s) {
  ListLines, Off
  s:=RegExReplace(s,"[^01]+")
  s.=SubStr("100000",1,6-Mod(StrLen(s),6))
  s:=RegExReplace(s,".{6}","|$0")
  Chars:="0123456789+/ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    . "abcdefghijklmnopqrstuvwxyz"
  SetFormat, IntegerFast, d
  Loop, Parse, Chars
  {
    i:=A_Index-1, v:="|" . (i>>5&1) . (i>>4&1)
      . (i>>3&1) . (i>>2&1) . (i>>1&1) . (i&1)
    s:=StrReplace(s,v,A_LoopField)
  }
  ListLines, On
  return, s
}

ASCII(s) {
  if RegExMatch(s,"\$(\d+)\.([\w+/]+)",r)
  {
    s:=RegExReplace(base64tobit(r2),".{" r1 "}","$0`n")
    s:=StrReplace(StrReplace(s,"0","_"),"1","0")
  }
  else s=
  return, s
}

; You can put the text library at the beginning of the script,
; and Use Pic(Text,1) to add the text library to Pic()'s Lib,
; Use Pic("comment1|comment2|...") to get text images from Lib

Pic(comments, add_to_Lib=0) {
  static Lib:=[]
  if (add_to_Lib)
  {
    re:="<([^>]*)>[^$]+\$\d+\.[\w+/]{3,}"
    Loop, Parse, comments, |
      if RegExMatch(A_LoopField,re,r)
        Lib[Trim(r1)]:=r
    Lib[""]:=""
  }
  else
  {
    text:=""
    Loop, Parse, comments, |
      text.="|" . Lib[Trim(A_LoopField)]
    return, text
  }
}

PicN(number) {
  return, Pic(Trim(RegExReplace(number,".","$0|"),"|"))
}

FindTextOCR(nX, nY, nW, nH, err1, err0, Text, Interval=5) {
  OCR:="", Right_X:=nX+nW
  While (ok:=FindText(nX, nY, nW, nH, err1, err0, Text))
  {
    ; For multi text search, This is the number of text images found
    Loop, % ok.MaxIndex()
    {
      ; X is the X coordinates of the upper left corner
      ; and W is the width of the image have been found
      i:=A_Index, x:=ok[i].1, y:=ok[i].2
        , w:=ok[i].3, h:=ok[i].4, comment:=ok[i].5
      ; We need the leftmost X coordinates
      if (A_Index=1 or x<Left_X)
        Left_X:=x, Left_W:=w, Left_OCR:=comment
    }
    ; If the interval exceeds the set value, add "*" to the result
    OCR.=(A_Index>1 and Left_X-Last_X>Interval ? "*":"") . Left_OCR
    ; Update nX and nW for next search
    x:=Left_X+Left_W, nW:=(Right_X-x)//2, nX:=x+nW, Last_X:=x
  }
  Return, OCR
}


/***** C source code of machine code *****

int __attribute__((__stdcall__)) PicFind(
  int mode, int c, int n, unsigned char * Bmp
  , int Stride, int sx, int sy, int sw, int sh
  , char * text, int * s1, int * s0
  , int err1, int err0, int w1, int h1, int * allpos)
{
  int o, i, j, k, x, y, w, h, ok=0;
  int r, g, b, rr, gg, bb, e1, e0, len1, len0, max;
  w=sw-w1+1; h=sh-h1+1; k=sy*Stride+sx*4;
  // Generate Lookup Table
  o=len1=len0=0;
  for (y=0; y<h1; y++)
  {
    for (x=0; x<w1; x++)
    {
      j=y*Stride+x*4;
      if (text[o++]=='1')
        s1[len1++]=j;
      else
        s0[len0++]=j;
    }
  }
  max=len1>len0 ? len1 : len0;
  // Color Mode
  if (mode==0)
  {
    for (y=0; y<h; y++)
    {
      for (x=0; x<w; x++)
      {
        o=y*Stride+x*4+k; e1=err1; e0=err0;
        j=o+c; rr=Bmp[2+j]; gg=Bmp[1+j]; bb=Bmp[j];
        for (i=0; i<max; i++)
        {
          if (i<len1)
          {
            j=o+s1[i]; r=Bmp[2+j]-rr; g=Bmp[1+j]-gg; b=Bmp[j]-bb;
            if (r<0) r=-r; if (g<0) g=-g; if (b<0) b=-b;
            if (r+g+b>n && (--e1)<0) goto NoMatch1;
          }
          if (i<len0)
          {
            j=o+s0[i]; r=Bmp[2+j]-rr; g=Bmp[1+j]-gg; b=Bmp[j]-bb;
            if (r<0) r=-r; if (g<0) g=-g; if (b<0) b=-b;
            if (r+g+b<=n && (--e0)<0) goto NoMatch1;
          }
        }
        allpos[ok++]=(sy+y)<<16|(sx+x);
        if (ok>=1024) goto Return1;
        NoMatch1:
        continue;
      }
    }
    goto Return1;
  }
  // Gray Threshold Mode
  c=(c+1)*1000;
  for (y=0; y<sh; y++)
  {
    for (x=0; x<sw; x++)
    {
      o=y*Stride+x*4+k;
      Bmp[3+o]=Bmp[2+o]*299+Bmp[1+o]*587+Bmp[o]*114<c ? 1:0;
    }
  }
  k=k+3;
  for (y=0; y<h; y++)
  {
    for (x=0; x<w; x++)
    {
      o=y*Stride+x*4+k; e1=err1; e0=err0;
      for (i=0; i<max; i++)
      {
        if (i<len1 && Bmp[o+s1[i]]!=1 && (--e1)<0) goto NoMatch2;
        if (i<len0 && Bmp[o+s0[i]]!=0 && (--e0)<0) goto NoMatch2;
      }
      allpos[ok++]=(sy+y)<<16|(sx+x);
      if (ok>=1024) goto Return1;
      NoMatch2:
      continue;
    }
  }
  Return1:
  return ok;
}

*/


; Note: This function is used for combination lookup,
; for example, a 0-9 text library has been set up,
; then any ID number can be found.
; Use Pic(Text,1) and PicN(number) when using.
; Only grayscale threshold mode is currently supported.

FindText2(x,y,w,h,err1,err0,text,Interval=5) {
  xywh2xywh(x-w,y-h,2*w+1,2*h+1,x,y,w,h)
  if (w<1 or h<1)
    return, 0
  bch:=A_BatchLines
  
  ;--------------------------------------
  GetBitsFromScreen(x,y,w,h,Scan0,Stride,bits)
  ;--------------------------------------
  sx:=0, sy:=0, sw:=w, sh:=h
  arr:=[], info:=[], allw:=0, allv:=allcolor:=allcomment:=""
  if (err1=0 and err0=0)
    err1:=err0:=0.05
  Loop, Parse, text, |
  {
    v:=A_LoopField
    IfNotInString, v, $, Continue
    comment:="", e1:=err1, e0:=err0
    ; You Can Add Comment Text within The <>
    if RegExMatch(v,"<([^>]*)>",r)
      v:=StrReplace(v,r), comment:=Trim(r1)
    ; You can Add two fault-tolerant in the [], separated by commas
    if RegExMatch(v,"\[([^\]]*)]",r)
    {
      v:=StrReplace(v,r), r1.=","
      StringSplit, r, r1, `,
      e1:=r1, e0:=r2
    }
    StringSplit, r, v, $
    color:=r1, v:=r2
    if !InStr(color,"*")
      Continue
    StringSplit, r, v, .
    w1:=r1, v:=base64tobit(r2), h1:=StrLen(v)//w1
    if (r0<2 or h1<1 or w1>sw or h1>sh or StrLen(v)!=w1*h1)
      Continue
    if (allcolor="")
      allcolor:=StrReplace(color,"*")
    StrReplace(v,"1","",len1), len0:=StrLen(v)-len1
    e1:=Round(len1*e1), e0:=Round(len0*e0)
    info.Push(StrLen(allv),w1,h1,len1,len0,e1,e0)
    allv.=v, allw+=w1, allcomment.=comment
  }
  if (allv="")
  {
    SetBatchLines, %bch%
    return, 0
  }
  num:=info.MaxIndex(), VarSetCapacity(in,num*4,0)
  Loop, % num
    NumPut(info[A_Index], in, 4*(A_Index-1), "int")
  VarSetCapacity(ss, sw*sh, 0), k:=StrLen(allv)*4
  VarSetCapacity(s1, k, 0), VarSetCapacity(s0, k, 0)
  VarSetCapacity(allpos, 1024*4, 0)
  offsetX:=Interval, offsetY:=5
  if (ok:=PicFind2(allcolor,offsetX,offsetY,Scan0,Stride
    ,sx,sy,sw,sh,ss,allv,s1,s0,in,num,allpos))
  {
    Loop, % ok
      pos:=NumGet(allpos, 4*(A_Index-1), "uint")
      , rx:=(pos&0xFFFF)+x, ry:=(pos>>16)+y
      , arr.Push( [rx,ry,allw,h1,allcomment] )
  }
  SetBatchLines, %bch%
  return, arr.MaxIndex() ? arr:0
}

PicFind2(color, offsetX, offsetY , Scan0, Stride, sx, sy, sw, sh, ByRef ss, ByRef text, ByRef s1, ByRef s0, ByRef in, num, ByRef allpos) {
  static MyFunc
  if !MyFunc
  {
    x32:="5557565383EC708BBC24BC0000008BAC24B4000000C7442"
    . "4140000000085FF0F8EBD0000008B4424148B9C24B80000008"
    . "BB424B80000008B5C83048B3486895C24048B9C24B80000008"
    . "B44830885C0894424107E7789F28974240831FFC7042400000"
    . "0008B44240485C07E4C8B4C24088D1C38897C240C89F829F90"
    . "38C24AC000000EB0E8944950083C00183C20139C3741A803C0"
    . "13175EC8BBC24B00000008904B783C00183C60139C375E68B5"
    . "C2404015C24088B7C240C8304240103BC24A00000008B04243"
    . "9442410759883442414078B442414398424BC0000000F8F43F"
    . "FFFFF8B8424840000008BB42498000000C7042400000000C74"
    . "424040000000083C00169C0E803000089C38B84249C0000000"
    . "FAF8424940000008D14B08B8424A00000008BB42494000000F"
    . "7D88D04868BB424A4000000894424088B8424A0000000C1E00"
    . "285F68944240C0F8E9700000089AC24B400000089DF89D58B8"
    . "C24A000000085C97E628B8C24900000008B5C24048BB424900"
    . "00000039C24A800000001E9036C240C01EE89F68DBC2700000"
    . "0000FB651020FB6410169D22B01000069C04B02000001C20FB"
    . "6016BC07201D039C70F9F0383C10483C30139CE75D38BB424A"
    . "00000000174240483042401036C24088B0424398424A400000"
    . "00F857BFFFFFF8BAC24B40000008B9424B80000008BB424B80"
    . "000008B8424B8000000C744241C00000000C74424580000000"
    . "0C744246C000000008B52148B760C8B4004895424248B9424B"
    . "800000089F3897424208BB424B80000008B52188B761089542"
    . "4288B9424A000000089342429C239F30F4DF383E8018954241"
    . "889F38BB424B80000008944245C8B8424A40000002B4608894"
    . "424640F881F03000089AC24B400000089DD8B44241885C00F8"
    . "8D30000008B7424588B84249C000000C74424080000000001F"
    . "0C1E0108944246889F02BB4248C00000089F3BE000000000F4"
    . "9F3897424540FAFB424A0000000897424508BB4248C0000000"
    . "1C6897424608DB426000000008B54241C0354240885ED0F8EA"
    . "00000008B7424288B4C242431C0039424A80000008B5C24208"
    . "9742404EB2C908D7426003904247E1B8BB424B40000008B3C8"
    . "601D7803F00740A836C24040178248D760083C00139C574593"
    . "9C37ED58BB424B00000008B3C8601D7803F0174C483E90179B"
    . "F83442408018B442408394424187D8083442458018B9C24A00"
    . "000008B442458015C241C394424640F8D03FFFFFF8B54246C8"
    . "3C47089D05B5E5F5DC2400066908B44245C0344240883BC24B"
    . "C000000078944242C0F8EA50100008B8424B8000000C744244"
    . "007000000896C244883C020894424308B4424308B9424A0000"
    . "0008B74242C8B0029C2894424448B84248800000001F039C20"
    . "F4EC289C38944244C39F30F8C060100008B4424308B5C24608"
    . "B700C8B68088974240C8B70108974241489C68B40148944243"
    . "88B8424A40000002B460439C30F4EC3894424108B46FC8BB42"
    . "4B000000089442404C1E00201C6038424B40000008944243C8"
    . "B4424548B7C242C037C24503B442410894424040F8F8600000"
    . "085ED7E258B9C24A80000008B54241431C001FB8B0C8601D98"
    . "03901740583EA01784A83C00139C575EA8B54240C85D20F8E8"
    . "70000008B9C24A8000000896C243431C08B4C24388B6C243C0"
    . "1FBEB0983C0013944240C74658B54850001DA803A0074EC83E"
    . "90179E78B6C243490834424040103BC24A00000008B4424043"
    . "94424100F8D7AFFFFFF8344242C018B44242C3944244C0F8D4"
    . "DFFFFFF83442408018B6C24488B442408394424180F8DCCFDF"
    . "FFFE947FEFFFF8DB426000000008B74242C8B4424448344244"
    . "007834424301C8D4430FF8944242C8B442440398424BC00000"
    . "00F8F79FEFFFF8B6C24488B74246C8B4424080384249800000"
    . "08B9C24C00000000B4424688D560181FAFF0300008904B30F8"
    . "F07FEFFFF83442408018954246C8B442408394424180F8D4EF"
    . "DFFFFE9C9FDFFFF83C47031D25B89D05E5F5DC240009090"
    x64:="4157415641554154555756534883EC78488B84242801000"
    . "0488BAC2408010000898C24C00000008B8C243001000089942"
    . "4C800000044898424D00000004C898C24D80000004C8BBC241"
    . "001000085C94C8BA42418010000488BBC24200100004889042"
    . "4C7442408000000000F8EA4000000448BB424F80000004889A"
    . "C2408010000488B0424448B6808448B108B70044585ED7E5E4"
    . "489D14489D54531DB31DB9085F67E434863D5468D0C1E4489D"
    . "84C01FAEB164C63C14883C20183C1014289048783C0014139C"
    . "1741C803A3175E54D63C24883C2014183C2014389048483C00"
    . "14139C175E401F583C3014501F34139DD75AE8344240807488"
    . "304241C8B442408398424300100000F8F74FFFFFF488BAC240"
    . "80100008B8424C00000008B9C24E80000004531F68B9424000"
    . "10000448D50018B8424F00000000FAF8424E00000004569D2E"
    . "8030000448D1C988B8424F80000008B9C24E0000000F7D8448"
    . "D3C838B8424F800000031DB85D2448D2C85000000000F8E900"
    . "000004C89A424180100004889BC24200100008BB424F800000"
    . "0448BA42400010000488BBC24D800000085F67E494963C34C6"
    . "3CB4531C0488D4C07024901E90FB6110FB641FF69D22B01000"
    . "069C04B02000001C20FB641FE6BC07201D04139C2430F9F040"
    . "14983C0014883C1044439C67FCD4501EB01F34183C6014501F"
    . "B4539F475A74C8BA42418010000488BBC2420010000488B9C2"
    . "428010000488B842428010000C744240C0000000048C744245"
    . "000000000C744246C00000000448B6B0C448B73108B5B148B4"
    . "0044589F7895C2410488B9C24280100008B5B18895C24148B9"
    . "C24F800000029C34539F5891C24488B9C2428010000450F4DF"
    . "D83E8018944245C8B8424000100002B4308894424644489F84"
    . "589EF4189C50F88100300008B042485C00F88D7000000488B5"
    . "C24508B8424F00000004889BC24200100004489EF01D8C1E01"
    . "08944246889D82B8424D000000089C6B8000000000F49C631F"
    . "6894424584989F5488BB424200100000FAF8424F8000000894"
    . "4244C8B8424D000000001D8894424600F1F40008B44240C85F"
    . "F44896C2408468D0C280F8E9B000000448B542414448B44241"
    . "031C0EB254139CE7E188B14864401CA4863D2807C150000740"
    . "84183EA01782866904883C00139C77E684139C789C17ED4418"
    . "B14844401CA4863D2807C15000174C34183E80179BD4983C50"
    . "144392C247D904189FD4889F74883442450018BB424F800000"
    . "0488B4424500174240C394424640F8DFEFEFFFF8B4C246C89C"
    . "84883C4785B5E5F5D415C415D415E415FC30F1F008B44245C0"
    . "344240883BC2430010000070F8E99010000488B9C242801000"
    . "04C89642418448BA424F800000044897C24344889742420C74"
    . "4242C0700000089C64883C3204489742438897C243C4C896C2"
    . "4404989DF418B074489E229C2894424308B8424C800000001F"
    . "039C20F4EC239F0894424480F8CBD000000418B47148BBC240"
    . "0010000412B7F0449635FFC458B4F08458B6F0C894424288B4"
    . "42460458B771039F80F4EF8488B44241848C1E3024C8D14184"
    . "8035C24208B44244C448D04068B44245839F84189C37F630F1"
    . "F4400004585C97E234489F131D2418B04924401C04898807C0"
    . "50001740583E90178334883C2014139D17FE24585ED7E738B4"
    . "C242831D2EB094883C2014139D57E628B04934401C04898807"
    . "C05000074E883E90179E34183C3014501E04439DF7DA283C60"
    . "1397424487D814C8B6C2440448B7C2434448B7424388B7C243"
    . "C4C8B642418488B7424204983C50144392C240F8DEEFDFFFFE"
    . "959FEFFFF660F1F8400000000008B4424308344242C074983C"
    . "71C8D7430FF8B44242C398424300100000F8FC2FEFFFF448B7"
    . "C2434448B7424388B7C243C4C8B6C24404C8B642418488B742"
    . "420486344246C8B542408039424E8000000488B9C243801000"
    . "00B5424688D480181F9FF0300008914830F8F0DFEFFFF4983C"
    . "50144392C24894C246C0F8D61FDFFFFE9CCFDFFFF31C9E9EFF"
    . "DFFFF9090909090"
    MCode(MyFunc, A_PtrSize=8 ? x64:x32)
  }
  return, DllCall(&MyFunc, "int",color, "int",offsetX
    , "int",offsetY, "ptr",Scan0, "int",Stride
    , "int",sx, "int",sy, "int",sw, "int",sh
    , "ptr",&ss, "AStr",text, "ptr",&s1, "ptr",&s0
    , "ptr",&in, "int",num, "ptr",&allpos)
}

/***** C source code of machine code *****

int __attribute__((__stdcall__)) PicFind2(
  int c, int offsetX, int offsetY
  , unsigned char * Bmp, int Stride
  , int sx, int sy, int sw, int sh
  , char * ss, char * text, int * s1, int * s0
  , int * in, int num, int * allpos )
{
  int o, x, y, i, j, max, e1, e0, ok=0;
  int o1, x1, y1, w1, h1, sx1, sy1, len1, len0, err1, err0;
  int o2, x2, y2, w2, h2, sx2, sy2, len21, len20, err21, err20;
  // Generate Lookup Table
  for (i=0; i<num; i+=7)
  {
    o=o1=o2=in[i]; w1=in[i+1]; h1=in[i+2];
    for (y=0; y<h1; y++)
    {
      for (x=0; x<w1; x++)
      {
        j=y*sw+x;
        if (text[o++]=='1')
          s1[o1++]=j;
        else
          s0[o2++]=j;
      }
    }
  }
  // Gray Threshold Mode
  c=(c+1)*1000; o=sy*Stride+sx*4; j=Stride-4*sw; i=0;
  for (y=0; y<sh; y++, o+=j)
  {
    for (x=0; x<sw; x++, o+=4, i++)
      ss[i]=Bmp[2+o]*299+Bmp[1+o]*587+Bmp[o]*114<c ? 1:0;
  }
  // Start Lookup
  w1=in[1]; h1=in[2]; len1=in[3]; len0=in[4]; err1=in[5]; err0=in[6];
  sx1=sw-w1; sy1=sh-h1; max=len1>len0 ? len1 : len0;
  for (y=0; y<=sy1; y++)
  {
    for (x=0; x<=sx1; x++)
    {
      o=y*sw+x; e1=err1; e0=err0;
      for (j=0; j<max; j++)
      {
        if (j<len1 && ss[o+s1[j]]!=1 && (--e1)<0) goto NoMatch1;
        if (j<len0 && ss[o+s0[j]]!=0 && (--e0)<0) goto NoMatch1;
      }
      x1=x+w1-1; y1=y-offsetY; if (y1<0) y1=0;
      for (i=7; i<num; i+=7)
      {
        o2=in[i]; w2=in[i+1]; h2=in[i+2];
        len21=in[i+3]; len20=in[i+4]; err21=in[i+5]; err20=in[i+6];
        sx2=sw-w2; j=x1+offsetX; if (j<sx2) sx2=j;
        sy2=sh-h2; j=y+offsetY; if (j<sy2) sy2=j;
        for (x2=x1; x2<=sx2; x2++)
        {
          for (y2=y1; y2<=sy2; y2++)
          {
            o=y2*sw+x2; e1=err21; e0=err20;
            for (j=0; j<len21; j++)
              if (ss[o+s1[o2+j]]!=1 && (--e1)<0) goto NoMatch2;
            for (j=0; j<len20; j++)
              if (ss[o+s0[o2+j]]!=0 && (--e0)<0) goto NoMatch2;
            goto MatchOK;
            NoMatch2:
            continue;
          }
        }
        goto NoMatch1;
        MatchOK:
        x1=x2+w2-1;
      }
      allpos[ok++]=(sy+y)<<16|(sx+x);
      if (ok>=1024) goto Return1;
      NoMatch1:
      continue;
    }
  }
  Return1:
  return ok;
}

*/


;================= The End =================

;
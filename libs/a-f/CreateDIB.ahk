/*
    Crea una imágen Bitmap.
    Parámetros:
        PixelData   : Un Array con colores RGB.
        Width/Height: El producto de estos dos parámetros debe dar la cantidad de píxeles en la imágen.
        ResizeWidth : El ancho de la imágen. Si este valor es 0 la imágen no se redimensiona.
        ResizeHeight: El alto de la imágen. Si este valor es 0 la imágen no se redimensiona.
        Gradient    : Determina si la imágen tiene degradado.
    Ejemplo 1:
        PixelData := ' FFFFFF|FFFFFF|FFFFFF|FFFFFF|FFFFFF|000000|000000|000000|000000|000000|000000|FFFFFF|FFFFFF|FFFFFF|FFFFFF|FFFFFF'
                   . '|FFFFFF|FFFFFF|FFFFFF|000000|000000|FFFFFF|FFFFFF|FF0000|FF0000|FF0000|FF0000|000000|000000|FFFFFF|FFFFFF|FFFFFF'
                   . '|FFFFFF|FFFFFF|000000|FFFFFF|FFFFFF|FFFFFF|FFFFFF|FF0000|FF0000|FF0000|FF0000|FFFFFF|FFFFFF|000000|FFFFFF|FFFFFF'
                   . '|FFFFFF|000000|FFFFFF|FFFFFF|FFFFFF|FFFFFF|FF0000|FF0000|FF0000|FF0000|FF0000|FF0000|FFFFFF|FFFFFF|000000|FFFFFF'
                   . '|FFFFFF|000000|FFFFFF|FFFFFF|FFFFFF|FF0000|FF0000|FFFFFF|FFFFFF|FFFFFF|FFFFFF|FF0000|FF0000|FFFFFF|000000|FFFFFF'
                   . '|000000|FF0000|FF0000|FF0000|FF0000|FF0000|FFFFFF|FFFFFF|FFFFFF|FFFFFF|FFFFFF|FFFFFF|FF0000|FF0000|FF0000|000000'
                   . '|000000|FF0000|FFFFFF|FFFFFF|FF0000|FF0000|FFFFFF|FFFFFF|FFFFFF|FFFFFF|FFFFFF|FFFFFF|FF0000|FF0000|FF0000|000000'
                   . '|000000|FFFFFF|FFFFFF|FFFFFF|FFFFFF|FF0000|FFFFFF|FFFFFF|FFFFFF|FFFFFF|FFFFFF|FFFFFF|FF0000|FF0000|FFFFFF|000000'
                   . '|000000|FFFFFF|FFFFFF|FFFFFF|FFFFFF|FF0000|FF0000|FFFFFF|FFFFFF|FFFFFF|FFFFFF|FF0000|FF0000|FFFFFF|FFFFFF|000000'
                   . '|000000|FF0000|FFFFFF|FFFFFF|FF0000|FF0000|FF0000|FF0000|FF0000|FF0000|FF0000|FF0000|FF0000|FFFFFF|FFFFFF|000000'
                   . '|000000|FF0000|FF0000|FF0000|000000|000000|000000|000000|000000|000000|000000|000000|FF0000|FF0000|FFFFFF|000000'
                   . '|FFFFFF|000000|000000|000000|FFFFFF|FFFFFF|000000|FFFFFF|FFFFFF|000000|FFFFFF|FFFFFF|000000|000000|000000|FFFFFF'
                   . '|FFFFFF|FFFFFF|000000|FFFFFF|FFFFFF|FFFFFF|000000|FFFFFF|FFFFFF|000000|FFFFFF|FFFFFF|FFFFFF|000000|FFFFFF|FFFFFF'
                   . '|FFFFFF|FFFFFF|000000|FFFFFF|FFFFFF|FFFFFF|FFFFFF|FFFFFF|FFFFFF|FFFFFF|FFFFFF|FFFFFF|FFFFFF|000000|FFFFFF|FFFFFF'
                   . '|FFFFFF|FFFFFF|FFFFFF|000000|FFFFFF|FFFFFF|FFFFFF|FFFFFF|FFFFFF|FFFFFF|FFFFFF|FFFFFF|000000|FFFFFF|FFFFFF|FFFFFF'
                   . '|FFFFFF|FFFFFF|FFFFFF|FFFFFF|000000|000000|000000|000000|000000|000000|000000|000000|FFFFFF|FFFFFF|FFFFFF|FFFFFF'

        hBitmap   := CreateDIB(PixelData, 16, 16, 50, 50)
        Gui       := GuiCreate('+AlwaysOnTop -Sysmenu')

        Gui.AddPIC('x0 y0', 'HBITMAP:' . hBitmap)
        Gui.Show('w50 h50')
        MsgBox('ExtiApp!')
        ExitApp
    Ejemplo 2:
        hBitmap   := CreateDIB([0xFF0000, 0xFF0000, 0xFFFF00, 0xFFFF00,], 2, 2, 220, 50, TRUE)
        Gui       := GuiCreate('+AlwaysOnTop')
        Gui.AddPIC('x0 y0', 'HBITMAP:' . hBitmap)
        Gui.Show('w220 h50')
        WinWaitClose('ahk_id' . Gui.hWnd)
        ExitApp
    Ejemplo 3:
        hBitmap   := CreateDIB('0|0|0|606060|808080|606060|0|0|0', 3, 3, 220, 50, TRUE)
        Gui       := GuiCreate('+AlwaysOnTop')
        Gui.AddPIC('x0 y0', 'HBITMAP:' . hBitmap)
        Gui.Show('w220 h50')
        WinWaitClose('ahk_id' . Gui.hWnd)
        ExitApp
*/
CreateDIB(PixelData, Width := 0, Height := 0, ResizeWidth := 0, ResizeHeight := 0, Gradient := FALSE)
{
    Local BitmapBits, p, hBitmap, Size
        , Hex  := ''

    If (!IsObject(PixelData))
    {
        PixelData := StrSplit(Trim(PixelData), '|')
        Hex       := '0x'
    }

    If (!Height)
        Height := Width

    Size := Ceil((Width * 3) / 2) * 2

    VarSetCapacity(BitmapBits, Size * Height + 1, 0)
    p := &BitmapBits

    Loop (PixelData.Length())
        p := Numput(Hex . PixelData[A_Index], p, 'UInt') - (Width & 1 && Mod(A_Index * 3, Width * 3) == 0 ? 0 : 1)

    ; https://msdn.microsoft.com/en-us/library/dd183485(v=vs.85).aspx
    hBitmap := DllCall('Gdi32.dll\CreateBitmap', 'Int' , Width  ;nWidth
                                               , 'Int' , Height ;nHeight
                                               , 'UInt', 1      ;cPlanes
                                               , 'UInt', 24     ;cBitsPerPel
                                               , 'Ptr' , 0      ;lpvBits (the contents of the new bitmap is undefined)
                                               , 'Ptr')         ;ReturnType (HANDLE)

    ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms648031(v=vs.85).aspx
    hBitmap := DllCall('User32.dll\CopyImage', 'Ptr' , hBitmap      ;hImage
                                             , 'UInt', 0            ;uType     --> IMAGE_BITMAP
                                             , 'Int' , 0            ;cxDesired (same width as the original hImage)
                                             , 'Int' , 0            ;cyDesired (same height as the original hImage)
                                             , 'UInt', 0x2000 | 0x8 ;fuFlags   --> LR_CREATEDIBSECTION | LR_COPYDELETEORG
                                             , 'Ptr')               ;ReturnType (HANDLE)

    ; https://msdn.microsoft.com/en-us/library/dd162962(v=vs.85).aspx
    DllCall('Gdi32.dll\SetBitmapBits', 'Ptr' , hBitmap       ;hbmp
                                     , 'UInt', Size * Height ;cBytes
                                     , 'UPtr', &BitmapBits   ;lpBits
                                     , 'UInt')               ;ReturnType

    If (Gradient)
        ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms648031(v=vs.85).aspx
        hBitmap := DllCall('User32.dll\CopyImage', 'Ptr' , hBitmap ;hImage
                                                 , 'UInt', 0       ;uType     --> IMAGE_BITMAP
                                                 , 'Int' , 0       ;cxDesired (same width as the original hImage)
                                                 , 'Int' , 0       ;cyDesired (same width as the original hImage)
                                                 , 'UInt', 0x8     ;fuFlags   --> LR_COPYDELETEORG
                                                 , 'Ptr')          ;ReturnType (HANDLE)

    ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms648031(v=vs.85).aspx
    hBitmap := DllCall('User32.dll\CopyImage', 'Ptr' , hBitmap            ;hImage
                                             , 'UInt', 0                  ;uType     --> IMAGE_BITMAP
                                             , 'Int' , ResizeWidth        ;cxDesired
                                             , 'Int' , ResizeHeight       ;cyDesired
                                             , 'UInt', 0x2000 | 0x8 | 0x4 ;fuFlags   --> LR_CREATEDIBSECTION | LR_COPYDELETEORG | LR_COPYRETURNORG
                                             , 'Ptr')                     ;ReturnType (HANDLE)

    Return (hBitmap)
} ;Credits: By SKAN - http://ahkscript.org/boards/viewtopic.php?t=3203

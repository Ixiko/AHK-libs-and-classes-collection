#Include ..\gdiplus\ImageButton.ahk

/*
Muestra un diálogo para pedirle al usuario que seleccione una imágen o un icono.
Parámetros:
    Owner: El identificador de la ventana propietaria de este diálogo. Este valor puede ser cero.
    FileName: La ruta a una imágen o a un archivo que contenga iconos. Si el archivo no existe, se establece en shell32.dll.
    Icon: El índice del icono en el archivo. El valor por defecto es 1.
    Width: El ancho por defecto. Si este valor es una cadena vacía se deshabilita.
    Height: El alto por defecto. Si este valor es una cadena vacía se deshabilita.
    Quality: La calidad por defecto. Si este valor es una cadena vacía se deshabilita.
Return: Si tuvo éxito devuelve un objeto con las claves FileName, Icon, Widh, Height y Quality, caso contrario devuelve 0.
*/
ChooseImage(Owner := 0, FileName := "", Icon := 1, Width := "", Height := "", Quality := "") ;WIN_V+
{
    If (!FileExist(FileName) || DirExist(FileName)) ;Check if FileName is a valid File
        FileName := A_WinDir . "\System32\shell32.dll" ;If not, set to shell32.dll

    Title           := "Seleccionar imágen" ;Dlg Window Title
    ButtonStyle     := [[0, 0x7E8DB6, "Black", 0x242424, 2, 0x282828, 0x242424, 1], [5, 0x8392B8, 0x98A5C5, 0x242424, 2, 0x282828, 0x242424, 1], [5, 0x8392B8, 0xA9B5CF, 0x242424, 2, 0x282828, 0x242424, 1], [0, 0xCCCCCC, "Black", 0x4A4A4A, 2, 0x282828, 0xA7B7C9, 1], [0, 0x7E8DB6, "Black", 0x242424, 2, 0x282828, 0x404040, 2], [5, 0x8392B8, 0x98A5C5, 0x242424, 2, 0x282828, 0x242424, 1]]

    ;Create GUI
    g               := GuiCreate("-ToolWindow" . (Owner ? " +Owner" . Owner : ""), Title)
    g.BackColor     := 0x282828 ;Background color: Dark

    g.SetFont("s9 Italic q5", "Arial Black")
    oFind           := g.AddButton("x337 y4 w58 h25", "• • •") ;Find Button
        ImageButton.Create(oFind.hWnd, ButtonStyle*)

    g.SetFont("s11", "Tahoma")
    oCancel         := g.AddButton("x296 y357 w99 h29", "Cancelar")
        ImageButton.Create(oCancel.hWnd, ButtonStyle*)
    oAccept         := g.AddButton("x177 y357 w99 h29 Default", "Aceptar")
        ImageButton.Create(oAccept.hWnd, ButtonStyle*)

    g.SetFont("s8", "Segoe UI")
    oLoad           := g.AddText("x5 y356 w165 h16 cGray")
    oInfo           := g.AddText("x5 y373 w165 h16 cGray")

    g.SetFont("Normal q5 s11")
    oFile           := g.AddEdit("x5 y4 w330 h25 c0x8694B9 BackGround0x282828 -E0x200 Border ReadOnly", A_Space . FileName)

    oList           := g.AddListView("x5 y32 w391 h253 BackGround0x282828 Icon +0x00880C LV0x010840", "")
        DllCall("User32.dll\SendMessageW", "Ptr", oList.hWnd, "UInt", 0x1035, "Ptr", 0, "Int", (34 & 0xFFFF) | (22 << 16)) ;X, Y

    g.AddText("x5 y288 w391 h64 c0x8694B9 BackGroundTrans Border")

    g.AddText("x10 y294 w56 h23 c0x8694B9 BackGroundTrans", "Ancho:")
    oWidth          := g.AddEdit("x77 y294 w63 h22 cGray BackGround0x282828 -E0x200 Border ReadOnly", A_Space . Width)
    oWidthU         := g.AddButton("x142 y294 w20 h11" . (Width==""?" Disabled":""), "˄")        , ImageButton.Create(oWidthU.hWnd, ButtonStyle*)
    oWidthD         := g.AddButton("x142 y305 w20 h11" . (Width==""?" Disabled":""), "˅")        , ImageButton.Create(oWidthD.hWnd, ButtonStyle*)

    g.AddText("x10 y323 w56 h23 c0x8694B9 BackGroundTrans", "Alto:")
    oHeight         := g.AddEdit("x77 y323 w63 h22 cGray BackGround0x282828 -E0x200 Border ReadOnly", A_Space . Height)
    oHeightU        := g.AddButton("x142 y323 w20 h11" . (Height==""?" Disabled":""), "˄")        , ImageButton.Create(oHeightU.hWnd, ButtonStyle*)
    oHeightD        := g.AddButton("x142 y334 w20 h11" . (Height==""?" Disabled":""), "˅")        , ImageButton.Create(oHeightD.hWnd, ButtonStyle*)

    g.AddText("x230 y294 w56 h23 c0x8694B9 BackGroundTrans", "Calidad:")
    oQuality        := g.AddEdit("x306 y294 w63 h22 cGray BackGround0x282828 -E0x200 Border ReadOnly", A_Space . Quality)
    oQualityU       := g.AddButton("x371 y294 w20 h11" . (Quality==""?" Disabled":""), "˄")        , ImageButton.Create(oQualityU.hWnd, ButtonStyle*)
    oQualityD       := g.AddButton("x371 y305 w20 h11" . (Quality==""?" Disabled":""), "˅")        , ImageButton.Create(oQualityD.hWnd, ButtonStyle*)

    ;Some initiation data
    oTBar           := ComObjCreate("{56FDF344-FD6D-11d0-958A-006097C9A090}", "{EA1AFB91-9E28-4B86-90E9-9E9F8A5EEFAF}")
    hTBar           := Owner ? Owner : g.hWnd

    Data            := {oList: oList, oInfo: oInfo, oLoad: oLoad, oTBar: oTBar, Title: Title, g:g, oFile: oFile, oWidth: oWidth, oHeight: oHeight, oQuality: oQuality
                        , hTBar: hTBar, hIcon: 0
                        , Error: TRUE, FileName: FileName, Icon: Icon, Width: Width, Height: Height, Quality: Quality}

    ;Show and load
    g.Show("w399 h392")
    ChooseImage_Load(Data)

    ;Events
    oWidthU.OnEvent("Click", Func("ChooseImage_UpDown").Bind(Data, "Width", "Up", -1, SysGet(78))) ;Data, What?, Up or down?, Min, Max
    oWidthD.OnEvent("Click", Func("ChooseImage_UpDown").Bind(Data, "Width", "Down", -1, SysGet(78)))

    oHeightU.OnEvent("Click", Func("ChooseImage_UpDown").Bind(Data, "Height", "Up", -1, SysGet(79)))
    oHeightD.OnEvent("Click", Func("ChooseImage_UpDown").Bind(Data, "Height", "Down", -1, SysGet(79)))

    oQualityU.OnEvent("Click", Func("ChooseImage_UpDown").Bind(Data, "Quality", "Up", 1, 100))
    oQualityD.OnEvent("Click", Func("ChooseImage_UpDown").Bind(Data, "Quality", "Down", 1, 100))
    
    oFind.OnEvent("Click", Func("ChooseImage_Find").Bind(Data))
    oList.OnEvent("ItemSelect", Func("ChooseImage_ItemSelect").Bind(Data))
    oCancel.OnEvent("Click", Func("ChooseImage_Close").Bind(Data, TRUE)) ;Data, Error?
    oAccept.OnEvent("Click", Func("ChooseImage_Close").Bind(Data, FALSE))
    g.OnEvent("Close", Func("ChooseImage_Close").Bind(Data, TRUE))
    g.OnEvent("Escape", Func("ChooseImage_Close").Bind(Data, TRUE))

    ;Wait...
    WinWaitClose("ahk_id " . g.hWnd)

    ;Finish and return
    ObjRelease(oTBar)
    If (Data.hIcon)
        DllCall("User32.dll\DestroyIcon", "Ptr", Data.hIcon)
    Return (Data.Error ? FALSE : Data)
}

ChooseImage_Close(Data, Error)
{
    If (!Error && (Data.FileName == "" || Data.Icon == 0))
    {
        MsgBox("El archivo seleccionado no contiene íconos o es inválido.", Data.Title, "IconX Owner" . Data.g.hWnd)
        Return
    }
    
    Data.Error     := Error
    Data.g.Destroy()
}

ChooseImage_UpDown(Data, What, Action, Min, Max)
{
    Value                 := SubStr(Data["o" . What].Text, 2)
    Data[What]            := Action == "Up" ? (Value >= Max ? Max : Value + 1) : (Value <= Min ? Min : Value - 1)
    Data["o" . What].Text := A_Space . Data[What]
}

ChooseImage_Find(Data)
{
    Data.g.Opt("+OwnDialogs")

    If (Data.FileName == "")
        FileName    := FileSelect(3,,, "Imágenes (*.exe;*.dll;*.cpl;*.icl;*.scr;*.ocx;*.ico;*.bmp;*.ani;*.cur;*.jpg;*.tif;*.tiff;*.png;*.gif;*.jpeg)")
    Else
        FileName    := FileSelect(3, Data.FileName,, "Imágenes (*.exe;*.dll;*.cpl;*.icl;*.scr;*.ocx;*.ico;*.bmp;*.ani;*.cur;*.jpg;*.tif;*.tiff;*.png;*.gif;*.jpeg)")
    
    If (!ErrorLevel && FileName != Data.FileName)
    {
        Data.oFile.Text := A_Space . (Data.FileName := FileName)
        Data.Icon       := 1
        ChooseImage_Load(Data)
    }
}

ChooseImage_ItemSelect(Data)
{
    If (!(RowNumber := Data.oList.GetNext()))
        Data.oList.Modify(Data.Icon, "Select Focus Vis")
    Else
        Data.Icon     := RowNumber
    
    If (Data.hIcon)
        DllCall("User32.dll\DestroyIcon", "Ptr", Data.hIcon)

    Data.hIcon := DllCall("Shell32.dll\ExtractIconW", "Ptr", 0, "Str", Data.FileName, "Int", Data.Icon - 1)
    DllCall("User32.dll\SendMessage", "Ptr", Data.g.hWnd, "UInt", 0x0080, "Int", 0, "Ptr", Data.hIcon)
    DllCall("User32.dll\SendMessage", "Ptr", Data.g.hWnd, "UInt", 0x0080, "Int", 1, "Ptr", Data.hIcon)
}

ChooseImage_Load(Data)
{
    Data.oList.Opt("-Redraw")
    Data.oList.Delete()
    
    If (Data.FileName != "")
    {
        Count       := DllCall("Shell32.dll\ExtractIconW", "Ptr", 0, "Str", Data.FileName, "Int", -1)
        ImageList   := IL_Create(Count ? Count : 1, 1, 1)
        IL_Destroy(Data.oList.SetImageList(ImageList))
        
        If (Count)
        {
            Percentage := 0
            Icons      := 0

            Loop (Count)
            {
                Percentage += 100.0 / Count

                ;Ensure that it is an icon
                If (!DllCall("User32.dll\DestroyIcon", "Ptr", DllCall("Shell32.dll\ExtractIconW", "Ptr", 0, "Str", Data.FileName, "Int", A_Index - 1)))
                    Continue

                If (!(Icon := IL_Add(ImageList, Data.FileName, A_Index)))
                    Continue

                If (!Data.oList.Add("Icon" . Icon))
                    Continue

                ;Update info every 4 iterations (for performance)
                ++Icons
                If (Mod(A_Index, 4) == 0)
                {
                    Data.oLoad.Text  := "Cargado:`t" . Round(Percentage, 2) . " `%." ;Load percentage (with two decimals)
                    Data.oInfo.Text  := "Iconos:`t" . Icons . " de " . Count . "." ;Current number of icons
                }

                DllCall(NumGet(NumGet(Data.oTBar)+9*A_PtrSize), "Ptr", Data.oTBar, "Ptr", Data.hTBar, "Int64", Round(Percentage * 10), "Int64", 1000)
            }

            DllCall(NumGet(NumGet(Data.oTBar)+9*A_PtrSize), "Ptr", Data.oTBar, "Ptr", Data.hTBar, "Int64", 0, "Int64", 1000)
            Data.oList.Modify(Data.Icon := (Data.Icon > Data.oList.GetCount() ? Data.oList.GetCount() : Data.Icon), "Focus Select Vis")
        }
        
        Else If (IL_Add(ImageList, Data.FileName))
            R := Data.oList.Add("Icon" . (Data.Icon := 1) . " Focus Select Vis")

        Else
            R := 0, Data.Icon := 0
    }
    
    Data.oLoad.Text   := "Cargado:`t100 `%."
    Data.oInfo.Text   := "Iconos:`t" . Data.oList.GetCount() . " de " . (Count ? Count : (R ? 1 : 0)) . "."
    Data.g.Title      := "(" . Data.oList.GetCount() . ") " . Data.Title
    Data.oList.Opt("+Redraw")
    ChooseImage_ItemSelect(Data)
}

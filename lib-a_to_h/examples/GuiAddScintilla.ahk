#Include %A_ScriptDir%\..\..\lib-i_to_z\MCode.ahk

Gui     := GuiCreate("", "ScintillaNET")
Sci     := GuiAddScintilla(Gui, "x0 y0 w500 h350", "Test ScintillaNET Control.`nLine 2 " . Chr(128064) . ".")

Gui.Show("x0 y0 w500 h350 Center")
WinWaitClose("ahk_Id" . Gui.hWnd)
ExitApp

F1::ToolTip("Size: " . Sci.Size . "`nLength: " . Sci.Length)


; SIN TERMINAR!






/*
    Añade un control ScintillaNET al GUI especificado.
    Parámetros:
        GuiObj: El objeto GUI o el identificador de una ventana GUI.
        Options: Las opciones para este control. Estas son algunas opciones:
            xN / yN / wN / hN = Coordenadas y dimensiones del control.
            Border / E0x200   = Añade dos tipos de bordes diferentes. 
        Caption: El texto a mostrar.
    Return:
        Si tuvo éxito devuelve un objeto Control Scintilla, caso contrario devuelve 0.
    Requerimientos:
        Para crear este control, es necesario el archivo 'SciLexer.dll' en el directorio actual del Script o en el directorio 'System32'.
            Debe utilizar el archivo DLL apropiado de 32-Bits o 64-Bits. Si utiliza la versión de 64-Bits de AutoHotkey debe utilizar la DLL de 64-Bits.
        Para un buen rendimiento, algunos métodos requieren la función MCode del archivo MCode.ahk. Incluido por defecto.
    Links:
        Página principal             : https://github.com/jacobslusser/ScintillaNET
        Documentación                : https://github.com/jacobslusser/ScintillaNET/wiki | http://www.scintilla.org/ScintillaDoc.html
        Descarga (32-Bits y 64-Bits) : https://github.com/jacobslusser/ScintillaNET 
            El archivo DLL de 32-Bits lo puede encontrar en: \ScintillaNET-master\src\ScintillaNET\x86\SciLexer.dll
            El archivo DLL de 64-Bits lo puede encontrar en: \ScintillaNET-master\src\ScintillaNET\x64\SciLexer.dll
*/
GuiAddScintilla(GuiObj, Options, Caption := "")
{
    GuiHwnd := IsObject(GuiObj) ? GuiObj.hWnd : GuiObj
    If (!(GuiObj := GuiFromHwnd(GuiHwnd)))
        Return (FALSE)

    Return (New __GuiAddScintillaNET(GuiObj, Options, Caption))
}




/*
    CLASS __GuiAddScintilla
*/
Class __GuiAddScintillaNET
{
    ; ===================================================================================================================
    ; STATIC/CLASS VARIABLES
    ; ===================================================================================================================
    Static Instances           := 0    ;La cantidad de instancias de este control.
    Static hModule             := 0    ;El identificador e el módulo cargado.
    Static pUTF8Len            := 0    ;La dirección de memoria a una función para recuperar la cantidad de caracteres en una cadena codificada en UTF-8.


    ; ===================================================================================================================
    ; INSTANCE VARIABLES
    ; ===================================================================================================================
    Gui                 := 0    ;El objeto GUI, padre de este control.
    Ctrl                := 0    ;El objeto Control, de este control.
    hWnd                := 0    ;El identificador de este control.


    ; ===================================================================================================================
    ; CONSTRUCTOR
    ; ===================================================================================================================
    __New(GuiObj, Options, Caption)
    {
        ; ---------------------------------------------
        If (This.Instances == 0)
        {
            If (!(This.hModule := DllCall("Kernel32.dll\LoadLibraryW", "Str", "SciLexer.dll")))
            {
                Throw Exception("Missing file 'SciLexer.dll'.",, "LoadLibraryW, SciLexer.dll")
                ExitApp 2 ;ERROR_FILE_NOT_FOUND
            }
        }
        ; ---------------------------------------------


        ; ---------------------------------------------
        If (This.pUTF8Len == 0)
            This.pUTF8Len := MCode("2,x86:i0wkBA+2EYTSdCSDwQExwIHiwAAAAIPCgA+VwoPBAQ+20gHQD7ZR/4TSdeTCBAAxwMIEAJCQkJCQkJCQkJCQkA==,x64:D7YRhNJ0KUiDwQExwA8fAIHiwAAAAIPCgA+VwkiDwQEPttIB0A+2Uf+E0nXjw2aQMcDDkJCQkJCQkJCQkJCQkA==")
        ; ---------------------------------------------


        ; ---------------------------------------------
        This.Ctrl        := GuiObj.AddCustom("ClassScintilla " . Options)
        If (!IsObject(This.Ctrl))
            Return (FALSE)

        This.hWnd        := This.Ctrl.hWnd

        ;http://www.scintilla.org/ScintillaDoc.html#SCI_SETCODEPAGE
        DllCall("User32.dll\SendMessageW", "Ptr", This.hWnd, "UInt", 0x07F5, "Int", 65001, "Ptr", 0) ;SC_CP_UTF8

        If (Caption != "")
            This.Text    := Caption
        ; ---------------------------------------------


        ++This.Instances
    }


    ; ===================================================================================================================
    ; DESTRUCTOR
    ; ===================================================================================================================
    __Delete()
    {
        DllCall("User32.dll\DestroyWindow", "Ptr", This.hWnd)

        If (--This.Instances == 0)
        {
            DllCall("Kernel32.dll\FreeLibrary", "Ptr", This.hModule)
            This.pSciMsg := 0
        }
    }


    ; ===================================================================================================================
    ; PUBLIC METHODS
    ; ===================================================================================================================


    ; ===================================================================================================================
    ; PROPERTIES
    ; ===================================================================================================================
    /*
        Recupera o establece el texto en este control.
    */
    Text[]
    {
        Get
        {
            If (!(Size := This.Size)) ;SCI_GETLENGTH
                Return ("")

            VarSetCapacity(Buffer, Size + 1)
            DllCall("User32.dll\SendMessageW", "Ptr", This.hWnd, "UInt", 0x0886, "Int", Size + 1, "Ptr", &Buffer) ;SCI_GETTEXT

            Return (StrGet(&Buffer, "UTF-8"))
        } ;http://www.scintilla.org/ScintillaDoc.html#SCI_GETTEXT

        Set
        {
            VarSetCapacity(Buffer, StrPut(Value, "UTF-8"))
            StrPut(Value, &Buffer, "UTF-8")
            DllCall("User32.dll\SendMessageW", "Ptr", This.hWnd, "UInt", 0x0885, "Ptr", 0, "Ptr", &Buffer) ;SCI_SETTEXT
        } ;http://www.scintilla.org/ScintillaDoc.html#SCI_SETTEXT
    }

    /*
        Recupera el tamaño de todo el texto, en bytes.
    */
    Size[]
    {
        Get
        {
            Return (DllCall("User32.dll\SendMessageW", "Ptr", This.hWnd, "UInt", 0x07D6, "Ptr", 0, "Ptr", 0)) ;SCI_GETLENGTH
        } ;http://www.scintilla.org/ScintillaDoc.html#SCI_GETLENGTH
    }

    /*
        Recupera el tamaño de todo el texto, en caracteres.
        Referencia:
            http://www.daemonology.net/blog/2008-06-05-faster-utf8-strlen.html
            https://stackoverflow.com/questions/7298059/how-to-count-characters-in-a-unicode-string-in-c
        Nota:
            Realizar este proceso en AHK es excesivamente lento, es por ello que utilizamos código máquina.
        Código C++:
            int __stdcall f(char *s)
            {
                int i = 0;
                int n = 0;

                while (s[i])
                {
                    if ((s[i] & 0xC0) != 0x80)
                        ++n;
                    ++i;
                }

                return (n);
            }
        Código AHK:
            Length := 0
            Loop (Size)
                If ((NumGet(Buffer, A_Index - 1, "UChar") & 0xC0) != 0x80)
                    ++Length
    */
    Length[]
    {
        Get
        {
            If (!(Size := This.Size)) ;SCI_GETLENGTH
                Return (0)

            VarSetCapacity(Buffer, Size + 1)
            DllCall("User32.dll\SendMessageW", "Ptr", This.hWnd, "UInt", 0x0886, "Int", Size + 1, "Ptr", &Buffer) ;SCI_GETTEXT 

            Return (DllCall(This.pUTF8Len, "Ptr", &Buffer)) ;Código máquina para recuperar la cantidad de caracteres en una cadena UTF-8
        }
    }
}

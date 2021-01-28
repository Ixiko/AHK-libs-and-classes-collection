/*
Muestra un diálogo para pedirle al usuario que seleccione un icono.
Parámetros:
    Owner: El identificador de la ventana propietaria de este diálogo. Este valor puede ser cero.
    FileName: La ruta a un archivo que contenga iconos.
    Icon: El índice del icono en el archivo. El valor por defecto es 1.
Return: Si tuvo éxito devuelve un objeto con las claves FileName e Icon, caso contrario devuelve 0.
*/
ChooseIcon(Owner := 0, FileName := "", Icon := 1)
{
    VarSetCapacity(PATH, 32767 * 2, 0)
    StrPut(FileName, &PATH, StrLen(FileName) + 1, "UTF-16")

    If (DllCall("Shell32.dll\PickIconDlg", "Ptr", Owner, "Ptr", &PATH, "UInt", 32767, "IntP", --Icon))
    {
        OutputVar       := {}
        If (!InStr(OutputVar.FileName := StrGet(&PATH, "UTF-16"), ":"))
            OutputVar.FileName := StrReplace(OutputVar.FileName, "`%SystemRoot`%", A_WinDir,, 1)
        OutputVar.Icon  := Icon + 1
    }

    Return (IsObject(OutputVar) ? OutputVar : FALSE)
}
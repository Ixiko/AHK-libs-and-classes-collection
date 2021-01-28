/*
    Copia archivos y carpetas mediante la utilidad de Windows RoboCopy.
    Parámetros:
        Source : El directorio fuente.
        Fest   : El directorio destino. Si no existe se crea.
        Files  : Un array con los archivos a copiar.
        Options: Opciones para el comando RoboCopy y la función Run. Estas son algunas opciones:
            /Hide = No muestra ninguna ventana durante la operación.
        LogFile: La ruta a un archivo en el que guardar la información de la operación realizada.
    Return:
        Si tuvo éxito devuelve el identificado del proceso de RoboCopy, caso contrario devuelve 0.
    Ejemplo:
        ToolTip('Copiando...')
        Source  := A_WinDir
        Dest    := A_Desktop . '\~tmp'
        Files   := '*.exe'
        Options := '/Hide'
        LogFile := A_Temp . '\robocopylog.txt'
        PID     := RoboCopy(Source, Dest, Files, Options, LogFile)
        ToolTip()

        If (PID)
        {
            ProcessWait(PID)
            Run(LogFile,, 'Max')
        }
        Else
            MsgBox('ERROR!')
        ExitApp
*/
RoboCopy(Source, Dest, Files := '', Options := '', LogFile := '')
{
    If (!DirExist(Source) || (!DirExist(Dest) && !DirCreate(Dest)))
        Return (FALSE)

    If (DirExist(LogFile) || (FileExist(LogFile) && !FileOpen(LogFile, 'w')))
        Return (FALSE)

    Local File
    If (IsObject(Files))
    {
        Local Each, FileName, File
        For Each, FileName in Files
            File .= '"' . StrReplace(FileName, '"') . '"'
    }
    Else
        File := Files == '' ? '' : '"' . StrReplace(Files, '"') . '"'

    Local PID
    RunOpt  := InStr(Options, '/Hide') ? 'Hide' : ''
    Options := StrReplace(Options, '/Hide')
    Options := ' /UNICODE' . (LogFile == '' ? '' : ' /UNILOG:"' . LogFile . '"')
                           . (InStr(Options, '/R') ? '' : ' /R:0')

    Run(A_WinDir . '\System32\RoboCopy.exe'
                 . ' "' . Source  . '"'
                 . ' "' . Dest    . '"'
                 . ' '  . File
                 . Options
        , ''
        , RunOpt
        , PID)

    Return (PID)
}

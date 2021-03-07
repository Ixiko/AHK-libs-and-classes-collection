/*
    Ejecuta script en PowerShell.
    Parámetros:
        Script : El script a ejecutar. Pueden ser varios comandos separados por una nueva línea.
        Params : Parámetros a pasar a PowerShell.
        Options: Opciones. Especificar 'Hide' para no mostrar la ventana de PowerShell al ejecutar un comando.
    Return:
        Si tuvo éxito devuelve el identificador del proceso, caso contrario devuelve 0.
    Observaciones:
        PowerShell esta habilitado por defecto en WIN_8+.
    Cmdlets:
        https://technet.microsoft.com/en-us/library/hh849827.aspx
    Ejemplo:
        MsgBox(PowerShell('Start-Process -FilePath notepad'))
*/
PowerShell(Script, Params := '', Options := '') {
    Run('PowerShell.exe -Command &{' . Script . '} ' . Params,, Options, PID)
    Return (PID)
}

/*
    Establece el estado del botón en la barra de tareas de la ventana especificada.
    Parámetros:
        hWnd : El identificador de la ventana.
        State: El estado para el botón en la barra de tareas de esta ventana. Puede ser:
            Show / Hide                             = Muestra u oculta el botón en la barra de tareas.
            0 - 100                                 = Establece un progreso en el botón.
            Normal / Paused / Indeterminate / Error = establece un estado en el botón.
    Return:
        Si tuvo éxito devuelve 1, caso contrario devuelve 0.
    Observaciones:
        Para pasar de 'Indeterminate' a 'Normal' establecer el progreso en 0.
    Ejemplo:
        MsgBox(SetWindowProgress(WinExist('ahk_class Notepad'), 'Indeterminate'))
*/
SetWindowProgress(hWnd, State := 0)
{
    Static ITaskbar1, ITaskbar2, States

    if (State = 'Show' || State = 'Hide')
    {
        If (ITaskbar1 == '')
            ITaskbar1 := ComObjCreate('{56FDF344-FD6D-11d0-958A-006097C9A090}', '{56FDF342-FD6D-11d0-958A-006097C9A090}')

        DllCall(NumGet(NumGet(ITaskbar1), 3*A_PtrSize), 'Ptr', ITaskbar1, 'Ptr', hWnd, 'Cdecl')
        Return (!DllCall(NumGet(NumGet(TaskBar), (State = 'Show' ? 4 : 5) * A_PtrSize), 'Ptr', ITaskbar1, 'Ptr', hWnd))
    }

    If (ITaskbar2 == '')
    {
        ITaskbar2 := ComObjCreate('{56FDF344-FD6D-11d0-958A-006097C9A090}', '{EA1AFB91-9E28-4B86-90E9-9E9F8A5EEFAF}')
        States    := {0: 0, Indeterminate: 1, Normal: 2, Error: 4, Paused: 8}
    }

    If (ObjHasKey(States, State))
        Return (!DllCall(NumGet(NumGet(ITaskbar2), 10*A_PtrSize), 'Ptr', ITaskbar2, 'Ptr', hWnd, 'UInt', States[State]))
    Return (!DllCall(NumGet(NumGet(ITaskbar2), 9*A_PtrSize), 'Ptr', ITaskbar2, 'Ptr', hWnd, 'Int64', State * 10, 'Int64', 1000))
}

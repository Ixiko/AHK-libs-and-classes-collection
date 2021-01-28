/*
    Muestra el escritorio.
    Nota:
        Esto tiene el mismo efecto que hacer clic en el botón Mostrar Escritorio de la barra de tareas.
*/
ShowDesktop()
{
    ComObjCreate('shell.application').ToggleDesktop()
}

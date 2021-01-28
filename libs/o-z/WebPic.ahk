/*
    Visualiza una imagen desde internet en un control ActiveX::Shell.Explorer
    Parámetros:
        Ctrl   : El objeto del control ActiveX.
        Url    : La URL de la imágen a cargar. Puede ser de un sitio en internet o una imágen en la PC.
        W      : El ancho de la imágen. Si se deja en 0, se utiliza el ancho del control
        H      : El alto de la imágen. Si se deja en 0, se utiliza el alto del control.
        BGColor: El color de fondo.
    Return:
        Si tuvo éxito devuelve 1, caso contrario devuelve 0.
    Observaciones:
        Ver el ejemplo abajo de todo.
    Thanks: Delta Pythagorean --> https://autohotkey.com/boards/viewtopic.php?f=6&t=35199
*/
WebPic(Ctrl, Url, W := 0, H := 0, BGColor := 0xFFFFFF)
{
    If (Ctrl.Type != 'ActiveX')
        Return (FALSE)

    W  := W ? W : Ctrl.Pos.W
    H  := H ? H : Ctrl.Pos.H
    WB := Ctrl.Value

    WB.Silent := TRUE
    While (WB.Busy)
        Sleep(10)

    WB.Navigate('about:'
              . '<!DOCTYPE html>'                                                                                                       . '`n'
              .     '<html>'                                                                                                            . '`n'
              .         '<head>'                                                                                                        . '`n'
              .             '<style>'                                                                                                   . '`n'
              .                 'body'                                                                                                  . '`n'
              .                 '{'                                                                                                     . '`n'
              .                     'background-color: ' . Format('#{:X}', BGColor) . ';'                                               . '`n'
              .                 '}'                                                                                                     . '`n'
              .                 'img'                                                                                                   . '`n'
              .                 '{'                                                                                                     . '`n'
              .                     'top: 0px;'                                                                                         . '`n'
              .                     'left: 0px;'                                                                                        . '`n'
              .                 '}'                                                                                                     . '`n'
              .             '</style>'                                                                                                  . '`n'
              .         '</head>'                                                                                                       . '`n'
              .         '<body>'                                                                                                        . '`n'
              .             '<img src="' . Url . '" alt="Picture" style="width:' . W . 'px;height:' . H . 'px;" />'                     . '`n'
              .         '</body>'                                                                                                       . '`n'
              .     '</html>')

    Return (TRUE)
} ; https://autohotkey.com/boards/viewtopic.php?f=6&t=35199










; :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
; ::: EJEMPLO
; :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
/*
    Gui  := GuiCreate(), Gui.MarginX := Gui.MarginY := 0
    Ctrl := Gui.AddActiveX('x0 y0 w500 h150', 'Shell.Explorer')

    Gui.show()
    WebPic(Ctrl, 'https://autohotkey.com/assets/images/ahk-logo-no-text241x78-180.png', 460, 120)
    Return
*/

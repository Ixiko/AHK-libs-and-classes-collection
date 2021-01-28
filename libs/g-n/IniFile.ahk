/*
    Lee todas las secciones, todas las claves en la sección especificada, o el valor de la clave y sección especificada.
    Parámetros:
        FileName: El archivo INI. El archivo debe existir o la función falla y devuelve 0.
        Section : El nombre de la sección. Si este parámetro es una cadena vacía, devuelve un Array con todas las secciones.
        Key     : El nombre de la clave. Si este parámetro es una cadena vacía, devuelve un Array con todas las claves con sus respectivos valores en la sección especificada.
        Default : Si la clave especificada en el parámetro «Key» no existe, devuelve por defecto la cadena especificada en este parámetro. Por defecto es una cadena vacía.
    Return:
        Si no se especifica la sección, devuelve un Array con todas las secciones en el archivo. Si no hay secciones el Array estará vacío.
        Si se especifica solo la sección, devuelve un Array con todas las claves en la sección especificada (si no hay claves, el Array estará vacío), o cero si la sección especificada no existe.
        Si se especifica la sección y clave, devuelve el valor de la clave, o la cadena especificada en el parámetro «Default» en caso de que la clave especificada no exista.
    ErrorLevel:
        General:
            -1 = El archivo INI no existe, es un directorio o no se ha podido abrir para su lectura.
        Si se va a recuperar un Array con todas las claves, ErrorLevel se establecerá en uno de los siguientes valores:
             0 = La operación se ha realizado con éxito. El método devuelve un Array con todas las claves; si no se encontraron claves devuelve un Array vacío.
             1 = La sección especificada en el parámetro «Section» no existe. El método devuelve cero.
        Si se va a recuperar el valor de una clave, ErrorLevel se establecerá en uno de los siguientes valores:
             0 = La operación se ha realizado con éxito. El método devuelve el valor de la clave; pudiendo ser éste una cadena vacía.
             1 = La sección especificada en el parámetro «Section» no existe. El método devuelve una cadena vacía.
             2 = La clave a leer no existe. El método devuelve la cadena especificada en el parámetro «Default».
    Observaciones:
        Si el parámetro «Section» no se utiliza (es una cadena vacía), los demás parámetros no tienen ningún uso.
        Si el parámetro «Key» no se utiliza (es una cadena vacía), el parámetro «Default» no tiene ningún uso, y el parámetro «Section» no debe ser una cadena vacía.
        Cuando se recupera un Array con todas las claves, tambien incluye su respectivo valor, de la forma "key=value" (recupera la línea entera). Puede utilizar StrSplit() para recuperar la clave individual.
        Si se desea recuperar varios valores de distintas claves en la misma sección, espesifique únicamente el primer parámetro para recuperar todas las claves en una únca llamada a la función.
        Esta función, a diferencia de IniRead() incorporado, lee los valores entre comillas ("") CON las comillas incluidas; omite comentarios; entre otros comportamiendos también presentes en _IniDelete/Write().
*/
_IniRead(FileName, Section := '', Key := '', Default := '')
{
    Local f := FileOpen(FileName, 'r-wd')    ; abrimos el archivo INI para su lectura, falla si el archivo no existe
    If (!f && (ErrorLevel := -1))
        Return ''

    Local LineTxt := ''    ; almacenará el texto de la línea actual

    ; recupera un Array con todas las secciones
    If (Section == '')
    {
        Local Sections := []    ; creamos un Array en el que almacenaremos todas las secciones encontradas
        While (!f.AtEOF)    ; creamos un bucle el cual continuara hasta que se llegue al final del archivo
        {
            LineTxt := Trim(f.ReadLine())    ; recuperamos el texto en la línea y eliminamos espacios y tabulaciones al inicio y fin de la cadena
            If (StrLen(LineTxt) > 2 && SubStr(LineTxt, 1, 1) == '[' && SubStr(LineTxt, -1) == ']')
                Sections.Push(SubStr(SubStr(LineTxt, 2), 1, InStr(LineTxt, ']')-2))
        }
        Return (Sections)
    }

    Local SecFound := false    ; indica si la sección ha sido encontrada
        , Pos      := 0        ; indica la posición del primer caracter "="

    ; recupera un Array con todas las claves y sus respectivos valores en la sección especificada.
    If (Key == '')
    {
        Local Keys := []    ; creamos un Array en el que almacenaremos todas las claves encontradas
        While (!f.AtEOF)    ; creamos un bucle el cual continuara hasta que se llegue al final del archivo
        {
            LineTxt := Trim(f.ReadLine())    ; recuperamos el texto en la línea y eliminamos espacios y tabulaciones al inicio y fin de la cadena
            If (SecFound)
            {
                If (SubStr(LineTxt, 1, 3) = '###')    ; comprobamos que no sea un comentario
                    Continue
                If (SubStr(LineTxt, 1, 1) == '[' && SubStr(LineTxt, -1) == ']')    ; comprobamos que no empiece otra sección
                    Break
                If (!InStr(LineTxt, '='))    ; comprobamos que aparezca el caracter "=" que separa la clave de su valor
                    Continue
                Keys.Push(LineTxt)    ; almacenamos la línea entera
            }
            Else If (LineTxt = '[' . Section . ']')    ; primero buscamos la sección, si la encontramos establecemos "SecFound" en TRUE y en la siguiente iteración buscamos por las claves
                SecFound := true
        }
        ErrorLevel := !SecFound    ; si se encontro la sección OK, caso contrario ERROR
        Return SecFound ? Keys : false    ; si se encontró la sección devolvemos el Array «Keys», caso contrario devolvemos cero.
    }

    ; recupera el valor de la clave especificada
    Key := Trim(Key)
    While (!f.AtEOF)    ; creamos un bucle el cual continuara hasta que se llegue al final del archivo
    {
        LineTxt := Trim(f.ReadLine())    ; recuperamos el texto en la línea y eliminamos espacios y tabulaciones al inicio y fin de la cadena
        If (SecFound)
        {
            If (SubStr(LineTxt, 1, 3) = '###')    ; comprobamos que no sea un comentario
                Continue
            If (SubStr(LineTxt, 1, 1) == '[' && SubStr(LineTxt, -1) == ']')    ; comprobamos que no empiece otra sección
                Break
            If (!(Pos:=InStr(LineTxt, '=')))    ; comprobamos que aparezca el caracter "=" que separa la clave de su valor
                Continue
            If (SubStr(LineTxt, 1, Pos-1) = Key)    ; comprobamos que en la línea actual se corresponda con la clave especificada
            {
                ErrorLevel := 0    ; OK
                Return SubStr(LineTxt, Pos+1)    ; devolvemos el valor de la clave "en crudo" (no removemos las comillas "" en caso de que el valor esté encerrado entre ellas)
            }
        }
        Else If (LineTxt = '[' . Section . ']')    ; primero buscamos la sección, si la encontramos establecemos "SecFound" en TRUE y en la siguiente iteración buscamos por la clave
            SecFound := true
    }
    ErrorLevel := SecFound + 1    ; sección o clave no encontrada
    Return SecFound ? Default : ''    ; en caso de haber encontrado la sección pero no la clave, devolvemos la cadena especificada en el parámetro «Default»»
}





; =============================================================================================================================================================================================





/*
    Elimina una sección entera o una clave en el archivo INI especificado.
    Parámetros:
        FileName: El archivo INI. El archivo debe existir o la función falla y devuelve cero.
        Section : El nombre de la sección. Este parámetro no puede ser una cadena vacía o la función falla y devuelve 3.
        Key     : El nombre de la clave. Dejar una cadena vacía para eliminar la sección entera.
    Return:
        0 = Ha ocurrido un error al intentar abrir o modificar el archivo INI. Puede que el archivo no exista, que otro programa tenga habierto el archivo y no permita su edición o que no se tenga los privilegios necesarios.
        1 = La sección o clave se ha eliminado con éxito. Se ha encontrado la sección especificada.
        2 = La clave especificada no existe.
        3 = La sección especificada no existe o se ha especificado una cadena vacía.
*/
_IniDelete(FileName, Section, Key := '')
{
    If (!FileExist(FileName))    ; comprobamos si el archivo no existe. Necesario debido a que FileOpen(.., 'rw') crea el archivo si no existe
        Return (0)
    Local f := FileOpen(FileName, 'rw-wd')    ; abrimos el archivo INI para su lectura y escritura
    If (!f)
        Return 0
    If (Section == '')
        Return 3

    Local LineTxt     := ''    ; almacenará el texto de la línea actual
        , Pos         := 0
        , StartingPos := -1

    ; eliminamos la sección entera
    If (Key == '')
    {
        While (!f.AtEOF)    ; creamos un bucle el cual continuara hasta que se llegue al final del archivo
        {
            Pos     := f.Pos    ; almacenamos la posición actual, al llamar a ReadLine() la posición avanzará una línea (cuando hablamos de posición nos referimos a los bytes, siendo la posición 0 bytes el comienzo del archivo)
            LineTxt := Trim(f.ReadLine())    ; recuperamos el texto en la línea y eliminamos espacios y tabulaciones al inicio y fin de la cadena
            If (StartingPos != -1)    ; una vez encontrada la sección...
            {
                If (SubStr(LineTxt, 1, 1) == '[' && SubStr(LineTxt, -1) == ']')    ; buscamos la siguiente sección
                    Return __ini_trim__(f, StartingPos, Pos, f.Length)    ; eliminamos la sección deseada y terminamos
            }
            Else If (LineTxt = '[' . Section . ']')    ; buscamos la sección a eliminar
                StartingPos := Pos    ; guardamos la posición anterior en «StartingPos»
        }
        Return __ini_trim__(f, StartingPos, -1, f.Length)    ; si StartingPos!=-1 eliminamos la última sección y terminamos
    }

    ; eliminamos la clave especificada.
    Key := Trim(Key)
    Local Pos2 := 0
    While (!f.AtEOF)
    {
        Pos     := f.Pos
        LineTxt := Trim(f.ReadLine())
        If (StartingPos != -1)
        {
            If (SubStr(LineTxt, 1, 3) = '###')    ; omitimos comentarios
                Continue
            If (SubStr(LineTxt, 1, 1) == '[' && SubStr(LineTxt, -1) == ']')    ; si empieza otra seccion terminamos (la clave no existe)
                Return 2
            If (!(Pos2:=InStr(LineTxt, '=')))    ; comprobamos que en la línea exista "="
                Continue
            If (SubStr(LineTxt, 1, Pos2-1) = Key)   ; comparamos la clave
                Return __ini_trim__(f, Pos, f.Pos, f.Length)    ; eliminamos la clave y terminamos
        }
        Else If (LineTxt = '[' . Section . ']')
            StartingPos := Pos
    }
    Return StartingPos == -1 ? 3 : 2
}

__ini_trim__(f, start, end, len)    ; función para uso interno de _IniDelete() | IGNORAR!
{
    If (start != -1)
    {
        f.Seek(end := end == -1 ? len : end)
        local buff, bytes := VarSetCapacity(buff, len-end)
        f.RawRead(&Buff, bytes), f.Length := start
        f.RawWrite(&Buff, bytes), VarSetCapacity(Buff, 0)
    }
    Return (start == -1 ? 3 : 1)
}





; =============================================================================================================================================================================================





/*    SIN TERMINAR!
    Escribe una sección o un valor en un archivo INI.
    Parámetros:
        Value   : El valor a escribir. Puede especificar un Array con el formato ['key=value', ..] para añadir varias claves en la sección especificada con solo una llamada a esta función.
        FileName: El archivo INI. Si el archivo no existe se crea automáticamente.
        Section : El nombre de la sección. Este parámetro no debe ser una cadena vacía.
        Key     : El nombre de la clave. Este parámetro puede ser una cadena vacía. Si este parámetro no es una cadena vacía, «Value» debe ser una cadena con el valor deseado.
    Return:
        0 = Ha ocurrido un error al intentar abrir o modificar el archivo INI. Puede que otro programa tenga habierto el archivo y no permita su edición o que no se tenga los privilegios necesarios.
        1 = La sección o clave se ha escrito con éxito. 
        2 = La sección especificada es errónea; se ha especificado una cadena vacía.
    Observaciones:
        Si necesita escribir varias claves en una misma sección, considere usar un Array en el parámetro «Value» para mejorar el rendimiento y evitar repetidas llamadas a la función.
        Si llama a la función y el archivo INI no existe, será creado con la codificación de A_FileEncoding. Para nuevos archivos, se recomienda utilizar FileEncoding('UTF-16').
*/
_IniWrite(Value, FileName, Section, Key := '')
{
    If (Section == '')    ; primero comprobamos si la sección especificada es una cadena vacía
        Return 2
    Local f := FileOpen(FileName, 'rw-wd`r`n')    ; abrimos el archivo INI para su lectura y escritura; si el archivo no existe lo crea automáticamente teniendo en cuenta A_FileEncoding.
    If (!f)
        Return 0

    Local LineTxt     := ''    ; almacenará el texto de la línea actual
        , Pos1        := 0
        , Pos2        := 0
        , Pos3        := 0

    ; creamos una sección si no existe; si se especificó un Array en el parámetro “Value” añadimos las claves (con sus valores) especificadas en él.
    If (Key == '')
    {
        ExitApp    ; SIN TERMINAR
    }

    ; escribimos un valor en la sección especificada; si la sección y/o clave no existe(n) la(s) creamos.
    Value := Trim(Value), Key := Trim(Key)
    While (!f.AtEOF)
    {
        Pos1    := f.Pos
        LineTxt := Trim(f.ReadLine())
        If (Pos2)
        {
            If (SubStr(LineTxt, 1, 1) == '[' && SubStr(LineTxt, -1) == ']')
                Return __ini_put__(f, Key '=' . Value, Pos2)
            If (SubStr(LineTxt, 1, 3) = '###')
                Continue
            If (!(Pos3:=InStr(LineTxt, '=')))
                Continue
            If (SubStr(LineTxt, 1, Pos3-1) = Key)
                Return __ini_put__(f, Key . '=' . Value, Pos1, true)
        }
        Else If (LineTxt = '[' . Section . ']')
            Pos2 := f.Pos
    }
    f.Seek(f.Length-1)
    Local Char := f.ReadUChar()
    If (Char != 10 && Char != 13)    ; 10=`n  |  13=`r
        f.WriteLine()
    f.WriteLine('[' . Section . ']')
    f.WriteLine(Key . '=' . Value)
    Return 1
}

__ini_put__(f, str, pos, r := false)    ; función para uso interno de _IniWrite() | IGNORAR!
{
    Local Buff
    If (r)
        f.Seek(pos), f.ReadLine()
        , bytes := VarSetCapacity(buff, f.Length-f.Pos)
    Else
        f.Seek(pos)
        , bytes := VarSetCapacity(buff, f.Length-pos)
    f.RawRead(&Buff, bytes), f.Length := pos
    f.WriteLine(str)
    f.RawWrite(&Buff, bytes), VarSetCapacity(Buff, 0)
    Return 1
}

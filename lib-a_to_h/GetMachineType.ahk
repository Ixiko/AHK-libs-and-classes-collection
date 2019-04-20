/*
    Especifica el tipo de CPU sobre el cual se ejecuta un archivo.
    Parámetros:
        ApplicationName: La ruta completa del archivo cuyo tipo debe determinarse.
    Return:
            -2 = El archivo no existe, no es un archivo o no se a podido abrir para leer en él.
            -1 = El archivo especificado en ApplicationName es inválido.
        0x0000 = IMAGE_FILE_MACHINE_UNKNOWN
        0x01D3 = IMAGE_FILE_MACHINE_AM33
        0x8664 = IMAGE_FILE_MACHINE_AMD64     (64-Bits)
        0x01C0 = IMAGE_FILE_MACHINE_ARM
        0xAA64 = IMAGE_FILE_MACHINE_ARM64
        0x01C4 = IMAGE_FILE_MACHINE_ARMNT
        0x0EBC = IMAGE_FILE_MACHINE_EBC
        0x014C = IMAGE_FILE_MACHINE_I386      (32-Bits)
        0x0200 = IMAGE_FILE_MACHINE_IA64      (64-Bits)
        0x9041 = IMAGE_FILE_MACHINE_M32R
        0x0266 = IMAGE_FILE_MACHINE_MIPS16
        0x0366 = IMAGE_FILE_MACHINE_MIPSFPU
        0x0466 = IMAGE_FILE_MACHINE_MIPSFPU16
        0x01F0 = IMAGE_FILE_MACHINE_POWERPC
        0x01F1 = IMAGE_FILE_MACHINE_POWERPCFP
        0x0166 = IMAGE_FILE_MACHINE_R4000
        0x5032 = IMAGE_FILE_MACHINE_RISCV32
        0x5064 = IMAGE_FILE_MACHINE_RISCV64
        0x5128 = IMAGE_FILE_MACHINE_RISCV128
        0x01A2 = IMAGE_FILE_MACHINE_SH3
        0x01A3 = IMAGE_FILE_MACHINE_SH3DSP
        0x01A6 = IMAGE_FILE_MACHINE_SH4
        0x01A8 = IMAGE_FILE_MACHINE_SH5
        0x01C2 = IMAGE_FILE_MACHINE_THUMB
        0x0169 = IMAGE_FILE_MACHINE_WCEMIPSV2
    Referencias:
        Compound File Header: https://msdn.microsoft.com/en-us/library/dd941946.aspx
        PE Format           : https://msdn.microsoft.com/en-us/library/windows/desktop/ms680547(v=vs.85).aspx#file_headers
        ImageHlp Structures : https://msdn.microsoft.com/en-us/library/windows/desktop/ms680198(v=vs.85).aspx
        EXE Format          : http://www.delorie.com/djgpp/doc/exe/
    Introducción:
        En la tecnología de la información, Header (encabezado) se refiere a los datos suplementarios colocados al principio de un bloque de datos que se almacenan o se transmiten.
        En la transmisión de datos, los datos que siguen al encabezado denominan a veces la carga útil o el cuerpo.
    Ejemplo:
        MsgBox((f:=FileSelect()) . '`nMachineType: ' . (mt:=GetMachineType(f)) . ' (' . (mt=0x200||mt=0x8664?'64-Bits':mt=0x14C?'32-Bits':'???') . ')')
*/
GetMachineType(ApplicationName)
{
    Local File
    
    ; ---------------------------------------------------------------------------------------------------------------------------------------------------
    ; OPEN FILE
    ; ---------------------------------------------------------------------------------------------------------------------------------------------------
    ; Intentamos abrir el archivo para lectura
    If (!(File := FileOpen(ApplicationName, 'r')))
        Return (-2)
    ; Cuando abrimos un archivo de texto con FileOpen, AutoHotkey busca por 'BOM' (Byte Order Mark. Marca de orden de bytes)
    ;   que es un carácter Unicode que se utiliza para indicar el orden de los bytes de un fichero de texto.
    ; AutoHotkey utiliza estos primeros bytes para identificar la codificación del archivo, por lo cual, cuando encuentra tales bytes
    ;   AutoHotkey avanza la ubicación al utilizar FileOpen para no leer estos bytes no deseados (que normalmente no son parte del texto).
    ; Entonces, si File.Pos no es 0 (el inicio del archivo), quiere decir que AutoHotkey encontro la BOM, por lo que concluimos que se trata de un archivo
    ;   de texto, que no es lo que buscamos, devolvemos -1.
    ; Nota: Que File.Pos sea cero, no necesariamente quiere decir que el archivo no sea un fichero de texto, por ejemplo, un archivo con ASCII no utiliza BOM.
    ; https://es.wikipedia.org/wiki/Marca_de_orden_de_bytes
    If (File.Pos) ;Si File.Pos no es 0, quiere decir que el archivo es, probablemente, un archivo de texto con una codificación Unicode.
        Return (-1)

    ; ---------------------------------------------------------------------------------------------------------------------------------------------------
    ; HEADER SIGNATURE --> MS-DOS STUB
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms680547(v=vs.85).aspx#file_headers
    ; ---------------------------------------------------------------------------------------------------------------------------------------------------
    ; Comprobamos que el archivo sea un ejecutable (formato MS-DOS MZ).
    ; Para ello, debemos comprobar por la cadena ASCII 'MZ' al comienzo del archivo, que significa 'Mark Zbikowski', uno de los desarroladores de MS-DOS.
    ; 0x5A4D = IMAGE_DOS_SIGNATURE. Este valor hexadecimal representa la cadena 'MZ' de 2 Bytes (ASCII, 2 caracteres).
    ; Por ejemplo, podemos leer esta cadena de 2 Bytes directamente utilizando 'MsgBox(FileOpen(A_ComSpec, 'r', 'CP0').Read(2))'.
    ; Estos primeros 2 Bytes en el archivo representan la Header Signature (firma del encabezado).
    ; https://en.wikipedia.org/wiki/DOS_MZ_executable
    If (File.ReadUShort() != 0x5A4D) ;0x5A4D = 'MZ' = MS-DOS MZ = IMAGE_DOS_SIGNATURE
        Return (-1)

    ; ---------------------------------------------------------------------------------------------------------------------------------------------------
    ; IMAGE_NT_HEADERS --> PE SIGNATURE
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms680336(v=vs.85).aspx
    ; ---------------------------------------------------------------------------------------------------------------------------------------------------
    ; Ahora nos aseguramos de que el archivo sea un 'Ejecutable Portable' (PE Format Image File), esto es, buscamos la existencia de la firma PE (PE SIGNATURE).
    ; Para ello, Microsoft nos dice que en la ubicación 0x3C (60) en la HEADER SIGNATURE nos encontraremos con un valor de 4 Bytes que nos indicará la ubicación de la estructura IMAGE_NT_HEADERS.
    ; Por lo cual nos posicionaremos en la ubicación 0x3C (60), recuperamos el valor de 4 Bytes y nos desplazamos a la ubicación que nos indica este valor.
    File.Seek(0x3C)              ;Nos posicionamos en 0x3C (offset 60).
    File.Seek(File.ReadUInt())   ;Recuperamos la ubicación de la estructura IMAGE_NT_HEADERS y nos posicionamos al comienzo de ella.
    ; Una vez que estamos en el inicio de la estructura IMAGE_NT_HEADERS, nos toca leer el primer valor de 4 Bytes que nos indica la SIGNATURA (firma).
    ; Luego comprobamos que ese valor de 4 Bytes, sea igual a 0x4550, que es la cadena 'PE', que como indica Miscrosoft, es la PE SIGNATURE que estamos buscando.
    ; https://en.wikipedia.org/wiki/Portable_Executable
    If (File.ReadUInt() != 0x4550) ;IMAGE_NT_HEADERS.Signature. 0x4550 = 'PE\0\0'.
        Return (-1)
    ;Por ejemplo, podemos leer esta cadena de 4 Bytes directamente utilizando 'File := FileOpen(A_ComSpec, 'r', 'CP0'), File.Seek(60), File.Seek(File.ReadUInt()), MsgBox(File.Read(4))'.
    
    ; ---------------------------------------------------------------------------------------------------------------------------------------------------
    ; IMAGE_FILE_HEADER
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms680313(v=vs.85).aspx
    ; ---------------------------------------------------------------------------------------------------------------------------------------------------
    ; La estructura IMAGE_NT_HEADERS está conformada por el miembro Signature (4 Bytes) y las estructuras IMAGE_FILE_HEADER y IMAGE_OPTIONAL_HEADER.
    ; Por lo cual, al habernos posicionado anteriormente en el inicio de la estructura IMAGE_NT_HEADERS y haber leido el miembro de 4 Bytes 'Signature'
    ;   nos encontraríamos al comienzo de la estructura IMAGE_FILE_HEADER (cuando ejecutamos 'ReadUInt' avanzamos 4 Bytes).
    ; Ahora, estando en el inicio de la estructura IMAGE_FILE_HEADER, leeremos el miembro de 2 Bytes 'Machine'.
    ; Este valor nos indica el tipo de arquitectura de la computadora (un archivo de imagen sólo se puede ejecutar en el equipo especificado o un sistema que emula el equipo especificado).
    Return Format('0x{:04X}', File.ReadUShort()) ;IMAGE_NT_HEADERS.IMAGE_FILE_HEADER.Machine
}

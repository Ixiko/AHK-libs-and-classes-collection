; Returns True if file content contains binary zeros.
; Textfiles never contain null.
; http://www.autohotkey.com/forum/viewtopic.php?p=320069#320069
fileIsBinary(_filePath)
{
    FileGetSize, data_size, %_filePath%
    FileRead, data, %_filePath%
    return (data_size != StrLen(data))
}
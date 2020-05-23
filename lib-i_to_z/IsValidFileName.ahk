/*
Author: Tuncay
License: http://creativecommons.org/licenses/by/3.0/

Func: isValidFileName
    Test if a string is a valid file name.

Parameters:
    fileName    - Input string to test if it contains any character from
        list of forbidden characters.
    
    isLong      - If true (default) then fileName is treated as long file name.
        Otherwise it is handled as a short 8.3 filename type.

Returns:
    True if valid and false otherwise.

ErrorLevel:
    The position of first invalid character in filename. '0' if filename is 
    valid.

Remarks:
    * Naming Files, Paths, and Namespaces: 
        <http://msdn.microsoft.com/en-us/library/Aa365247>

Example:
    > MsgBox % isValidFileName(A_ScriptName)
    *Output*
    1
*/
isValidFileName(_fileName, _isLong=true)
{
    static shortForbiddenChars := ";,=,+,<,>,|,"",[,],\,/,'"
    static longForbiddenChars := "<,>,|,"",\,/,:,*,?"
    
    forbiddenChars := _isLong ? longForbiddenChars : shortForbiddenChars
    Loop, Parse, forbiddenChars, `,
    {
        pos := InStr(_fileName, A_LoopField, true)
        if (pos > 0)
        {
            break
        }
    }
    ErrorLevel := pos
    
    return (pos ? false : true)
}
/*
---------------------------------------------------------------------------
Function:
    String manipulation.
---------------------------------------------------------------------------
*/

StringM( _String, _Option, _Param1 = "", _Param2 = "" ) {
    if ( _Option = "Bloat" )
        _NewString := RegExReplace( _String, "(.)", _Param1 . "$1" . ( ( _Param2 ) ? _Param2 : _Param1) )
    else if ( _Option = "Drop" )
        _NewString := RegExReplace( _String, "i )[" . _Param1 . "]" )
    else if ( _Option = "Flip" )
        Loop, Parse, _String
            _NewString := A_LoopField . _NewString
    else if ( _Option = "Only" )
        _NewString := RegExReplace( _String, "i )[^" . _Param1 . "]" )
    else if ( _Option = "Pattern" ) {
        _Unique := RegExReplace( _String, "(.)", "$1" . Chr(10) )
        Sort, _Unique, % "U Z D" . Chr(10)
        _Unique := RegExReplace( _Unique, Chr(10) )
        Loop, Parse, _Unique
        {
            StringReplace, _String, _String, % A_LoopField,, UseErrorLevel
            _NewString .= A_LoopField . ErrorLevel 
        }
    }
    else if ( _Option = "Repeat" )
        Loop, % _Param1
            _NewString := _NewString . _String
    else if ( _Option = "Replace" )
        _NewString := RegExReplace( _String, "i )" . _Param1, _Param2 )
    else if ( _Option = "Scramble" ) {
        _NewString := RegExReplace( _String, "(.)", "$1" . Chr(10) )
        Sort, _NewString, % "Random Z D" . Chr(10)
        _NewString := RegExReplace( _NewString, Chr(10) )
    }
    else if ( _Option = "Split" ) {
        Loop % Ceil( StrLen( _String ) / _Param1 )
            _NewString := _NewString . SubStr( _String, ( A_Index * _Param1 ) - _Param1 + 1, _Param1 ) . ( ( _Param2 ) ? _Param2 : " " )
        StringTrimRight, _NewString, _NewString, 1
    }
    return _NewString
}

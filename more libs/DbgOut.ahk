/*
Name: dbgOut - Prints given String via OutputDebug and indents string according to a given prefix
Version 0.1 (20161130)
Created: 20161130
Author: hoppfrosch
Description:
  Prints the given Debug-String via command OutputDebug. 
  The string is indented according to a given prefix in the Debug-String.
  This allows a better tracing of stack depth with deep function calls.

  Supported prefixes are currently:
  * ">" - This should be used when a funtion is entered. On each usage of this Prefix the indentation level is increased
    Example:  dbgOut(">[" A_ThisFunc "()]")
  * "<" - This should be used when a funtion is exited. On each usage of this Prefix the indentation level is decreased
    Example:  dbgOut("<[" A_ThisFunc "()]")
  * "|" - This should be used for temporary indentation
*/
dbgOut(str, debug := 1) {
  static indentLvl := 0
  x1 := SubStr(str, 1, 1)
  if (x1 = "<") {
    indentLvl := indentLvl - 1
  }
  ;if (x1 = "|") {
  ;  indentLvl := indentLvl + 1
  ;}

  if (debug) {
    i := 0
    indent := ""
    while (i < indentLvl) {
      indent := indent "++"
      i := i + 1
    }  
    OutputDebug % indent str
  }
  if (x1 = ">") {
    indentLvl := indentLvl + 1
  }
  ;if (x1 = "|") {
  ;  indentLvl := indentLvl - 1
  ;}
}

;Format a cell for csv format by Rhys
;Does all the proper escaping and stuff to write a csv cell
;http://www.autohotkey.com/forum/topic27233.html

Format4CSV(F4C_String)
{
   Reformat:=False ;Assume String is OK
   IfInString, F4C_String,`n ;Check for linefeeds
      Reformat:=True ;String must be bracketed by double quotes
   IfInString, F4C_String,`r ;Check for linefeeds
      Reformat:=True
   IfInString, F4C_String,`, ;Check for commas
      Reformat:=True
   IfInString, F4C_String, `" ;Check for double quotes
   {   Reformat:=True
      StringReplace, F4C_String, F4C_String, `",`"`", All ;The original double quotes need to be double double quotes
   }
   If (Reformat)
      F4C_String=`"%F4C_String%`" ;If needed, bracket the string in double quotes
   Return, F4C_String
}

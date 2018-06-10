/*

FixURI()
Lintalist v1.2
Date: 20150815

Return: fixed text (Clip for html and md) and path (RTF and Image)

html/md (here text is the contents of Clip, returns "fixed" text with checked paths)
	OK, simply return
	 - http://
	OK, but ifExist, replace with "missing" if not found
	 - file://

	Fix to file:// and check ifExist, replace with "missing" if not found
	- "path\tofile.jpg"

image/rtf (here text is simply the path, returns "fixed" path)
	OK, but ifExist, replace with "missing" if not found
	- "[a-z]:\"
	Fix, replace with "missing" if not found
	- "path\tofile.jpg"

1.2: now used by the File plugin as well.

txt (here text is either the path or a folder for the Select option)

*/

FixURI(text,source,sourcedir="") {
	if (sourcedir = "")
		sourcedir:=A_ScriptDir "\"
	else
		sourcedir:=RTrim(sourcedir,"\") "\"

	if (source = "image") or (source = "rtf") or (source = "txt")
		{
		 If RegExMatch(text,"i)^[a-z]\:\\")
			{
			 If !FileExist(text)
				text:="[Lintalist can not find the file: " text "]"
			}
		 else
			{
			 text:=sourcedir text
			 If !FileExist(text)
				text:="[Lintalist can not find the file: " text "]"
			}
		 return text
		}
	else if (source = "html")
		{
		 Pos=1
		 While Pos:=RegExMatch(text,"i)<img[^>]+src=['""](\K[^'""]+)",A,Pos+StrLen(A1))
			{
			 A0:=A1
			 if RegExMatch(A1,"i)^https*\:") ; internet URI, leave unchanged
				continue
			 StringReplace, A1, A1, /, \, All
			 If RegExMatch(A1,"i)^[a-z]\:\\")
				{
				 If !FileExist(A1)
					A1:=""
				}
			 else If !RegExMatch(A1,"i)^file\:")
				{
				 A1:=sourcedir A1
				 StringReplace, A1, A1,/,\,All
				 If !FileExist(A1)
					A1:=""
				}
			 else If RegExMatch(A1,"i)^file\:\/\/\/")
				{
				 StringReplace, A2, A1, file:///,,All
				 A2:=sourcedir A2
				 If !FileExist(A2)
					A1:=""
				 else
					A1:=A2
				}	
			 StringReplace, A1, A1,\,/,All
			 StringReplace, text, text, %A0%, file:///%A1%
			 StringReplace, text, text, file:///file:///, file:///, All
			}

		 Return Text 
		}
	}

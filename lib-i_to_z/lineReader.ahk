;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Line reader classes
;;  Copyright (C) 2012 Adrian Hawryluk
;;
;;  This program is free software: you can redistribute it and/or modify
;;  it under the terms of the GNU General Public License as published by
;;  the Free Software Foundation, either version 3 of the License, or
;;  (at your option) any later version.
;;
;;  This program is distributed in the hope that it will be useful,
;;  but WITHOUT ANY WARRANTY; without even the implied warranty of
;;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;  GNU General Public License for more details.
;;
;;  You should have received a copy of the GNU General Public License
;;  along with this program.  If not, see <http://www.gnu.org/licenses/>.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; LINEREADER CLASSES:
;
;  The stringLineReader class is a way of buffering a stream on line 
;  boundaries.  The stream in this case is a string, however, by extending this
;  class, you can buffer any stream.
;
;  The member functions that need to be overridden are:
;
;    1. source()
;
;    2. updateBuffer(gettingLineContinuation)
;
;  source()
;
;    This is used by the diagnositicInfo() member function to state the source 
;    of the data.  It returns a string with no whitespce at the begining or end
;    of it.
;
;  updateBuffer()
;    This updated the internal member variables to the new
;    values required to get the next line.  It take one parameter,
;    gettingLineContinuation, which if true, must keep the current buffer
;    content intact by appending to it.  If false, the data upto but excluding
;    this.s_pos must be removed, this.s_pos must be set to 1 and 
;    this.contextStartsAtLine must be set to this.atLine.  In either case 
;    this.s_len must reflect the number of characters that are in the buffer.
;
;    The buffer contents is a string referenced by this.buffer.  Changing this
;    buffer's location is not a problem.
;
; USAGE:
;
;  1. Instantiate either stringLineReader() with a string to buffer as its 1st
;     parameter, or fileLineReader() with the name of the file to buffer as its
;     1st parameter.
;
;  2. When you need a line, call the GetLine() member function.  If there is a
;     line to get, it will return 1, otherwise it will return 0.  The parameters
;     startPos and endPos are to be used on the member variable buffer using 
;     string manipulations functions like instr(), substr(), RegExMatch(), etc.
;     This is done this way to minimize string copies.
;
;     The parameter gettingLineContinuation is a flag to tell the lineReader to
;     not clear the buffer, but rather append to it.  This allows for more useful
;     diagnostic information by allowing the information to persist and could 
;     potentially be used to not generate more strings then are necessary by 
;     keeping the buffered data alive.
;
;  3. Diagnostic info can be retreived using the member function 
;     diagnositicInfo().  This reports where the stream is coming from (the 
;     source), and a listing of the  currently buffered lines (the context) 
;     with a pointer showing the start and end of the lines in use.
;
;     The source, where the infomation is coming from and the context can be 
;     retrieved seperatly by the member functions source(), whatAndWhereAmI() 
;     and getContext() respectivly.
class stringLineReader
{
	atLine := 0
	startLine := 0
	s_pos := 1
	;buffer := ""
	;s_len := StrLen(this.s_pos)
	contextStartsAtLine := 1
	
	__New(buffer)
	{
		this.buffer := buffer
		this.s_len := strlen(buffer)
	}
	
	; Line is where the line is returned to.
	; Returns 1 if found more data to read.
	; Returns 0 if no more data to read.
	GetLine(byref startPos, byref endPos, gettingLineContinuation=0)
	{
		if (gettingLineContinuation)
			++this.atLine
		else
			this.startLine := ++this.atLine

		cont := gettingLineContinuation
		, newPos := -1
		while (((newPos := RegExMatch(this.buffer, "P)\n\r?|\r\n?", NL_Len, this.s_pos)) == 0 or newPos == this.s_len)
			&&  cont := this.updateBuffer(cont))
		{ ; intentionally left blank
		}
		
		if (newPos or this.s_pos <= this.s_len)
		{
			if (newPos)
			{
				; line with NL
				startPos := this.s_pos
				;  Do not include `n in the endPos.
				endPos := newPos - 1 ; -1 points at the character prior to the NL in the buffer
				this.s_pos := newPos + NL_Len
				return 1
			}
			else
			{
				; last line without terminating `n
				; no more to get, use what you have
				startPos := this.s_pos
				this.s_pos := (endPos := this.s_len) + 1
				--this.atLine
				return 1
			}
		}
		else
			; no more to get
			return 0
	}
	
	diagnositicInfo()
	{
		return this.whatAndWhereAmI() "`n`n"  this.getContext()
	}

	; override this function if you can retreive more data from somwhere else.
	;
	; If gettingLineContinuation is non-zero, append to this.buffer and 
	; update this.s_len approprately.
	; 
	; If gettingLineContinuation is zero, remove leading characters upto but 
	; excluding this.s_pos, update this.contextStartsAtLine, set this.s_pos to 
	; 1 and this.s_len to new length of buffer.
	updateBuffer(gettingLineContinuation)
	{
		return 0
	}
	
	; states the source and at what line the last line that was read from
	whatAndWhereAmI()
	{
		return this.source() (this.startLine == this.atLine ? " at line " this.atLine : " between lines " this.startLine " and " this.atLine)
	}
	
	; returns a string that shows each line that has been cached prefixed with line numbers and the
	; previous line with a -> in front of it.
	getContext()
	{
		; loop parse variable needs to be NOT a class member
		buffer := this.buffer
		oldFmt := A_FormatFloat
		
		; context is to show previous line analysed.
		atLine := this.atLine
		startLine := this.startLine
		lineCount := 0
		pos := 1
		while pos := RegExMatch(buffer, "P)\r\n?|\n\r?", len, pos) + len
			++lineCount
		
		; right justify line number
		SetFormat, FloatFast, % "0" strlen(this.contextStartsAtLine + lineCount) ".0"
		
		pos := 1
		lineNumber := this.contextStartsAtLine + 0.0

		while newPos := RegExMatch(buffer, "P)\r\n?|\n\r?", len, pos) + len
		{
			len := newPos - pos - len
			line := substr(buffer, pos, len)
			if (atLine != startLine)
				stringWithLineNumbers .=  (lineNumber = startLine ? "-\ " : lineNumber = atLine ? "-/ " : "   ") lineNumber ":  " line "`n"
			else
				stringWithLineNumbers .=  (lineNumber = atLine ? "=> " : "   ") lineNumber ":  " line "`n"
			
			++lineNumber
			pos := newPos ? newPos : pos
		}

		line := substr(buffer, pos)
		if (atLine != startLine)
			stringWithLineNumbers .=  (lineNumber = startLine ? "-\ " : lineNumber = atLine ? "-/ " : "   ") lineNumber ":  " line "`n"
		else
			stringWithLineNumbers .=  (lineNumber = atLine ? "=> " : "   ") lineNumber ":  " line "`n"
		
		; restore to old format
		SetFormat, FloatFast, %oldFmt%
		return stringWithLineNumbers
	}
	
	; Override this function to say where the class is getting its text stream from.
	source()
	{
		return "string"
	}
}

class fileLineReader extends stringLineReader
{
	__New(filename)
	{
		this.filename := filename
		this.file := FileOpen(filename, "r")
		base.__New("")
	}
	
	; override this function if you can retreive more data from somwhere else.
	;
	; If gettingLineContinuation is non-zero, append to this.buffer and 
	; update this.s_len approprately.
	; 
	; If gettingLineContinuation is zero, remove leading characters upto but 
	; excluding this.s_pos, update this.contextStartsAtLine, set this.s_pos to 
	; 1 and this.s_len to new length of buffer.
	updateBuffer(gettingLineContinuation)
	{
		static bufferSize := 4096
		if (this.file.AtEOF())
		{
			return 0
		}
		else if (gettingLineContinuation)
		{
			this.s_len := strlen(this.buffer .= this.file.Read(bufferSize))
		}
		else
		{
			this.s_len := strlen(this.buffer := substr(this.buffer, this.s_pos) this.file.Read(bufferSize))
			this.s_pos := 1
			this.contextStartsAtLine := this.atLine
		}
		return 1
	}
	
	source()
	{
		return "file '" this.filename "'"
	}
	
	__Delete()
	{
		this.file.Close()
	}
}


; Requires HL7.ahk
#Include, %A_ScriptDir%\..\HL7.ahk

; For a simple use case.  I've included in the Sample_HL7.txt file a header
; that I made up for Hackers.  Each "HAK" segment represents an individual hacker.
; I expect that the first field will have their last name and first name as
; individual components, and all their known aliases in the second field as
; individual components.

; We need the text of the HL7 file in memory in order to pass it to the parser
Fileread, HL7_Text, Sample_HL7.txt

; This is the actual command.
Parsed_HL7 := HL7.parse(HL7_Text)

; The sending application is located in a segment with the "MSH" header.  I expect
; only one segment has that header, so I'll unconditionally choose that one.
; Within that segment, it's the second field, first "repeat", first component,
; first sub-component.
Sending_Application := Parsed_HL7["MSH"][1][2][1][1][1]

; The event type code (which is normally used to identify the type of message
; being sent), is under the "EVN" header, first field.  I don't expect any
; extra repeats, components, or subcomponents, so those are all 1.
Event_Type_Code := Parsed_HL7["EVN"][1][1][1][1][1]

; We'll be appending to this variable as we go
Message_Box_Text 	:= "Sending Application: " . Sending_Application 
					. "`nEvent Type: " . Event_Type_Code 
					. "`n`nKnown Hackers:`n`n"

; Iterates through every segment received with the "HAK" header
For index, Segment in Parsed_HL7["HAK"]
{
	; The last name and first name are located in the segment's first field, first
	; repeat, first and second components (each is the first and only subcomponent
	; of that component).
	Message_Box_Text .= Segment[1][1][1][1] . ", " . Segment[1][1][2][1] . "`n"

	; The known aliases are listed as Components in the segment's second field,
	; first repeat.  There can be more than one, so we'll iterate through them.
	For ind, Component in Segment[2][1]
	{
		; The alias will always be the first subcomponent
		Message_Box_Text .= "`t""" . Component[1] . """`n"
	}

	; We'll want a trailing newline after each hacker to keep them separate in the
	; message box.
	Message_Box_Text .= "`n"
}

; This will show us a list of hackers and their known aliases if we've done our
; homework correctly.
MsgBox % Message_Box_Text

ExitApp
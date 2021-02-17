; Title:
; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=10&t=80688&sid=6915ef47556dc5a41eafa93296048c0e
; Author:
; Date:
; for:     	AHK_L

/*
DGO	:= DriveGetObj()		; Abfrage mit fehlendem Parameter (= Laufwerk C:\ (Default))

MsgBox	%	"List:`t`t"		 	DGO.List
		.	"`nCapacity:`t`t"	DGO.Capacity
		.	"`nCapacityFree:`t"	DGO.CapacityFree
		.	"`nfileSystem:`t"	DGO.FileSystem
		.	"`nLabel:`t`t"	 	DGO.Label
		.	"`nSerial:`t`t"		DGO.Serial
		.	"`nType:`t`t"		DGO.Type
		.	"`nStatus:`t`t"		DGO.Status
		.	"`nStatusCD:`t`t"	DGO.StatusCD 			; Ausgabe der Arraywerte


DGO	:= DriveGetObj("fixed")								; Abfrage verbaute(r) Geräte/Laufwerke
MsgBox % DGO.list										; Ergebnis: 'C'

DGO	:= DriveGetObj("z")									; Abfrage existentes Laufwerk
MsgBox % DGO.status										; Ergebnis: 'Ready'

DGO	:= DriveGetObj("h")									; Abfrage nicht existentes Laufwerk
MsgBox % DGO.status										; Ergebnis: 'Invalid'

DGO	:= DriveGetObj("?")									; Abfrage mit ungültigem Parameter
MsgBox % DGO.status										; Ergebnis: 'Unknown'

DGO	:= DriveGetObj("\\DESKTOP-LV8UQOU\_MyPrograms")		; Abfrage UNC/Netzwerkpfad mit Freigabe
MsgBox % DGO.status										; Ergebnis: 'Ready'

DGO	:= DriveGetObj("\\DESKTOP-LV8UQOU\")				; Abfrage UNC/Netzwerkpfad ohne Freigabe
MsgBox % DGO.status										; Ergebnis: 'Unknown'

DGO	:= DriveGetObj()									; Abfrage verfügbarer Laufwerksbuchstaben
MsgBox % DGO.ListAvailable								; Ergebnis: 'EFGHIJKLMNOPQRSTUVWXY' (wenn z.B. 'CDZ' bereits belegt ist)


DGO := DriveGetObj()									; Abfrage mit fehlendem Parameter ergibt für 'list' einen index aller angeschlossenen Laufwerke. Hier 'CDZ'
Loop, Parse,% DGO.list								 	; Anzahl Laufwerke = Anzahl Durchläufe
	{	drv		:= A_LoopField							; Laufwerksbuchstabe als Bezeichner des jeweiligen objectarray
		%drv%	:= DriveGetObj(A_LoopField)				; Erstellen des objectarray je Laufwerk
		MsgBox % c.type "`n" d.filesystem "`n" z.status ; Anzeige verschiedener properties der verschiedenen Laufwerke
	}													; Ergebnis: Laufwerk C/type:'fixed', Laufwerk D/filesystem:'extFAT', Laufwerk Z/status:'Ready'

ExitApp

*/

; ======================================================================================================================
; Funktion DriveGetObj()
; Ersatz für das AHK-eigene DriveGet/DriveSpaceFree-Kommando.
; Die Funktion erstellt ein Array mit den Schlüsseln
;	"List"
;	"ListAvailable"
;	"Capacity"
;	"CapacityFree"
;	"FileSystem"
;	"Label"
;	"Serial"
;	"Type"
;	"Status"
;	"StatusCD"
; ... und den Werten der entsprechenden Ausgabevariablen des DriveGet/DriveSpaceFree-Kommandos.
; ======================================================================================================================

DriveGetObj(var:="C:\") {									;Rückgabe von drive properties mittels AHK Standard-Kommando
	local
	if var in CDROM,REMOVABLE,FIXED,NETWORK,RAMDISK,UNKNOWN
		DriveGet, list, List ,% var
	else {	DriveGet, list, List
			listAvailable := SubStr(RegExReplace("CDEFGHIJKLMNOPQRSTUVWXYZ", "[" . list . "]"),-24) ;Retrieves the available drive letters
			StringUpper, list, list							;Kosmetik. Angleichung zur Großschreibung bei Ausgabe in MsgBox
		 }
	var := StrLen(var) = 1 ? RegExReplace(var,"\W") ":\" : var
	DriveGet, capacity, Capacity ,		% var				;Retrieves the total capacity of the specified path in megabytes.
	DriveGet, filesystem, FileSystem ,	% var				;Retrieves the type of the specified drive's file system.
	DriveGet, label, Label ,			% var				;Retrieves the volume label of the specified drive.
	DriveGet, serial, Serial ,			% var				;Retrieves the volume serial number of the specified drive.
	DriveGet, type, Type ,				% var				;Retrieves the drive type of the specified path.
	DriveGet, status, Status ,			% var				;Retrieves the status of the specified path.
	DriveGet, statusCD, StatusCD ,		% var				;Retrieves the media status of a CD or DVD drive.
	DriveSpaceFree, CapacityFree,		% var				;Retrieves the free disk space of a drive, in Megabytes.

	Return	{ List: list									; Assoziatives Array erstellen und zurückgeben
			, Available: listAvailable
			, Capacity: capacity
			, CapacityFree: CapacityFree
			, FileSystem: filesystem
			, Label: label
			, Serial: serial
			, Type: type
			, Status: status
			, StatusCD: statusCD}
	}
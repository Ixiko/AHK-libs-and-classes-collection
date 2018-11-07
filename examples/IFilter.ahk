; IFilter AutoHotkey example by qwerty12
; Credits:
; https://tlzprgmr.wordpress.com/2008/02/02/using-the-ifilter-interface-to-extract-text-from-documents/
; https://stackoverflow.com/questions/7177953/loadifilter-fails-on-all-pdfs-but-mss-filtdump-exe-doesnt
; https://forums.adobe.com/thread/1086426?start=0&tstart=0

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
AutoTrim, Off
ListLines, Off
SetBatchLines, -1
#KeyHistory 0
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

; ---
#MaxMem 4 ; Might need to be multipled by 2 and 1 added to it because sizeof(WCHAR == 2). Not sure. It works for me as it is currently.
cchBufferSize := 4 * 1024
; ---
resultstriplinebreaks := true
file := ""
searchstring := ""
; ---

CHUNK_TEXT := 1

STGM_READ := 0

IFILTER_INIT_CANON_PARAGRAPHS	:= 1,
IFILTER_INIT_HARD_LINE_BREAKS	:= 2,
IFILTER_INIT_CANON_HYPHENS	:= 4,
IFILTER_INIT_CANON_SPACES	:= 8,
IFILTER_INIT_APPLY_INDEX_ATTRIBUTES	:= 16,
IFILTER_INIT_APPLY_OTHER_ATTRIBUTES	:= 32,
IFILTER_INIT_APPLY_CRAWL_ATTRIBUTES	:= 256,
IFILTER_INIT_INDEXING_ONLY	:= 64,
IFILTER_INIT_SEARCH_LINKS	:= 128,
IFILTER_INIT_FILTER_OWNED_VALUE_OK	:= 512,
IFILTER_INIT_FILTER_AGGRESSIVE_BREAK	:= 1024,
IFILTER_INIT_DISABLE_EMBEDDED	:= 2048,
IFILTER_INIT_EMIT_FORMATTING	:= 4096

S_OK := 0
FILTER_S_LAST_TEXT := 268041
FILTER_E_NO_MORE_TEXT := -2147215615

if (!A_IsUnicode) {
	MsgBox The IFilter APIs appear to be Unicode only. Please try again with a Unicode build of AHK.
	ExitApp
}

if (!file || !searchstring) {
	MsgBox Please make sure the file to search in and the string to search for is specified in %A_ScriptFullPath%
	ExitApp
}

SplitPath, file,,, ext
VarSetCapacity(FILTERED_DATA_SOURCES, 4*A_PtrSize, 0), NumPut(&ext, FILTERED_DATA_SOURCES,, "Ptr")
VarSetCapacity(FilterClsid, 16, 0)

; Adobe workaround
if (job := DllCall("CreateJobObject", "Ptr", 0, "Str", "filterProc", "Ptr"))
	DllCall("AssignProcessToJobObject", "Ptr", job, "Ptr", DllCall("GetCurrentProcess", "Ptr"))

FilterRegistration := ComObjCreate("{9E175B8D-F52A-11D8-B9A5-505054503030}", "{c7310722-ac80-11d1-8df3-00c04fb6ef4f}")
if (DllCall(NumGet(NumGet(FilterRegistration+0)+3*A_PtrSize), "Ptr", FilterRegistration, "Ptr", 0, "Ptr", &FILTERED_DATA_SOURCES, "Ptr", 0, "Int", false, "Ptr", &FilterClsid, "Ptr", 0, "Ptr*", 0, "Ptr*", IFilter) != 0 ) ; ILoadFilter::LoadIFilter
	ExitApp
if (IsFunc("Guid_ToStr"))
	MsgBox % Guid_ToStr(FilterClsid)
ObjRelease(FilterRegistration)

if (DllCall("shlwapi\SHCreateStreamOnFile", "Str", file, "UInt", STGM_READ, "Ptr*", iStream) != 0 )
	ExitApp
PersistStream := ComObjQuery(IFilter, "{00000109-0000-0000-C000-000000000046}")
if (DllCall(NumGet(NumGet(PersistStream+0)+5*A_PtrSize), "Ptr", PersistStream, "Ptr", iStream) != 0 ) ; ::Load
	ExitApp
ObjRelease(iStream)

status := 0
if (DllCall(NumGet(NumGet(IFilter+0)+3*A_PtrSize), "Ptr", IFilter, "UInt", IFILTER_INIT_DISABLE_EMBEDDED | IFILTER_INIT_INDEXING_ONLY, "Int64", 0, "Ptr", 0, "Int64*", status) != 0 ) ; IFilter::Init
	ExitApp

VarSetCapacity(STAT_CHUNK, A_PtrSize == 8 ? 64 : 52)
VarSetCapacity(buf, (cchBufferSize * 2) + 2)
while (DllCall(NumGet(NumGet(IFilter+0)+4*A_PtrSize), "Ptr", IFilter, "Ptr", &STAT_CHUNK) == 0) { ; ::GetChunk
	if (NumGet(STAT_CHUNK, 8, "UInt") & CHUNK_TEXT) {
		while (DllCall(NumGet(NumGet(IFilter+0)+5*A_PtrSize), "Ptr", IFilter, "Int64*", (siz := cchBufferSize), "Ptr", &buf) != FILTER_E_NO_MORE_TEXT) ; ::GetText
		{
			text := StrGet(&buf,, "UTF-16")
			if (resultstriplinebreaks)
				text := StrReplace(text, "`r`n")
			if (InStr(text, searchstring)) {
				MsgBox "%searchstring%" found
				break
			}
		}
	}
}
ObjRelease(PersistStream)
ObjRelease(iFilter)
if (job)
	DllCall("CloseHandle", "Ptr", job)

ExitApp

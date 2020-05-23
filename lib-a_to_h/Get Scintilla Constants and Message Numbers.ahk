Global sci_constants
Global sci_keyboard_commands
; Global sci_msg

load_sci_constants()
{
    in_file := "C:\Users\Mark\Desktop\Misc\Notepad++\scite405\scintilla\include\Scintilla.h"
    ; sci_msg := {}
    sci_constants := {}
    FileRead, in_file_var, %in_file%
    Loop, Parse, in_file_var, `n, `r
    {
        If RegExMatch(A_LoopField, "iO)#define\s+(SCI_\w+)\s+(\d+)", match)
        {
            ; sci_msg[match.value(2)] := match.value(1)
            sci_constants[match.value(1)] := match.value(2)
        }
    }
    ;
    ; in_file := "C:\Program Files (x86)\scite405\scite\src\SciTE.h"
    ; FileRead, in_file_var, %in_file%
    ; Loop, Parse, in_file_var, `n, `r
    ; {
        ; If RegExMatch(A_LoopField, "O)#define\s+(ID\w+)\s+(\d+)", match)
        ; {
            ; ; sci_msg[match.value(2)] := match.value(1)
            ; sci_constants[match.value(1)] := match.value(2)
        ; }
    ; }
    sci_keyboard_commands := {}
    load_sci_keyboard_commands()
    Return
}

; get_constant(p_sci_msg_num, format_msg_command := True)
; {
    ; Return sci_msg[p_sci_msg_num]
; }

get_msg_num(p_sci_constant, format_msg_command := True)
{
    If Not IsObject(sci_constants)
        load_sci_constants()
    Return sci_constants[p_sci_constant]    
}

get_help(p_sci_constant)
{
    If WinExist("Scintilla Documentation - Google Chrome ahk_class Chrome_WidgetWin_1 ahk_exe chrome.exe")
        WinActivate
    Else
        RunWait, MyScripts\Utils\Web\Activate Browser.ahk
    ;
    If RegExMatch(p_sci_constant, "^SCI_\w+$")
        Run, http://www.scintilla.org/ScintillaDoc.html#%p_sci_constant%
    Else If RegExMatch(p_sci_constant, "^ID\w+$")
        Run, https://www.scintilla.org/CommandValues.html
    Else
        Run, https://www.scintilla.org
    ;
    Sleep 500
    SendInput ^+{Tab}
    Sleep 10
    SendInput ^w
    Return
}

load_sci_keyboard_commands()
{
    sci_keyboard_commands["SCI_BACKTAB"] := 2328
    sci_keyboard_commands["SCI_CANCEL"] := 2325
    sci_keyboard_commands["SCI_CHARLEFT"] := 2304
    sci_keyboard_commands["SCI_CHARLEFTEXTEND"] := 2305
    sci_keyboard_commands["SCI_CHARLEFTRECTEXTEND"] := 2428
    sci_keyboard_commands["SCI_CHARRIGHT"] := 2306
    sci_keyboard_commands["SCI_CHARRIGHTEXTEND"] := 2307
    sci_keyboard_commands["SCI_CHARRIGHTRECTEXTEND"] := 2429
    sci_keyboard_commands["SCI_DELETEBACK"] := 2326
    sci_keyboard_commands["SCI_DELETEBACKNOTLINE"] := 2344
    sci_keyboard_commands["SCI_DELLINELEFT"] := 2395
    sci_keyboard_commands["SCI_DELLINERIGHT"] := 2396
    sci_keyboard_commands["SCI_DELWORDLEFT"] := 2335
    sci_keyboard_commands["SCI_DELWORDRIGHT"] := 2336
    sci_keyboard_commands["SCI_DELWORDRIGHTEND"] := 2518
    sci_keyboard_commands["SCI_DOCUMENTEND"] := 2318
    sci_keyboard_commands["SCI_DOCUMENTENDEXTEND"] := 2319
    sci_keyboard_commands["SCI_DOCUMENTSTART"] := 2316
    sci_keyboard_commands["SCI_DOCUMENTSTARTEXTEND"] := 2317
    sci_keyboard_commands["SCI_EDITTOGGLEOVERTYPE"] := 2324
    sci_keyboard_commands["SCI_FORMFEED"] := 2330
    sci_keyboard_commands["SCI_HOME"] := 2312
    sci_keyboard_commands["SCI_HOMEDISPLAY"] := 2345
    sci_keyboard_commands["SCI_HOMEDISPLAYEXTEND"] := 2346
    sci_keyboard_commands["SCI_HOMEEXTEND"] := 2313
    sci_keyboard_commands["SCI_HOMERECTEXTEND"] := 2430
    sci_keyboard_commands["SCI_HOMEWRAP"] := 2349
    sci_keyboard_commands["SCI_HOMEWRAPEXTEND"] := 2450
    sci_keyboard_commands["SCI_LINECOPY"] := 2455
    sci_keyboard_commands["SCI_LINECUT"] := 2337
    sci_keyboard_commands["SCI_LINEDELETE"] := 2338
    sci_keyboard_commands["SCI_LINEDOWN"] := 2300
    sci_keyboard_commands["SCI_LINEDOWNEXTEND"] := 2301
    sci_keyboard_commands["SCI_LINEDOWNRECTEXTEND"] := 2426
    sci_keyboard_commands["SCI_LINEDUPLICATE"] := 2404
    sci_keyboard_commands["SCI_LINEEND"] := 2314
    sci_keyboard_commands["SCI_LINEENDDISPLAY"] := 2347
    sci_keyboard_commands["SCI_LINEENDDISPLAYEXTEND"] := 2348
    sci_keyboard_commands["SCI_LINEENDEXTEND"] := 2315
    sci_keyboard_commands["SCI_LINEENDRECTEXTEND"] := 2432
    sci_keyboard_commands["SCI_LINEENDWRAP"] := 2451
    sci_keyboard_commands["SCI_LINEENDWRAPEXTEND"] := 2452
    sci_keyboard_commands["SCI_LINEREVERSE"] := 2354
    sci_keyboard_commands["SCI_LINESCROLLDOWN"] := 2342
    sci_keyboard_commands["SCI_LINESCROLLUP"] := 2343
    sci_keyboard_commands["SCI_LINETRANSPOSE"] := 2339
    sci_keyboard_commands["SCI_LINEUP"] := 2302
    sci_keyboard_commands["SCI_LINEUPEXTEND"] := 2303
    sci_keyboard_commands["SCI_LINEUPRECTEXTEND"] := 2427
    sci_keyboard_commands["SCI_LOWERCASE"] := 2340
    sci_keyboard_commands["SCI_MOVESELECTEDLINESDOWN"] := 2621
    sci_keyboard_commands["SCI_MOVESELECTEDLINESUP"] := 2620
    sci_keyboard_commands["SCI_NEWLINE"] := 2329
    sci_keyboard_commands["SCI_PAGEDOWN"] := 2322
    sci_keyboard_commands["SCI_PAGEDOWNEXTEND"] := 2323
    sci_keyboard_commands["SCI_PAGEDOWNRECTEXTEND"] := 2434
    sci_keyboard_commands["SCI_PAGEUP"] := 2320
    sci_keyboard_commands["SCI_PAGEUPEXTEND"] := 2321
    sci_keyboard_commands["SCI_PAGEUPRECTEXTEND"] := 2433
    sci_keyboard_commands["SCI_PARADOWN"] := 2413
    sci_keyboard_commands["SCI_PARADOWNEXTEND"] := 2414
    sci_keyboard_commands["SCI_PARAUP"] := 2415
    sci_keyboard_commands["SCI_PARAUPEXTEND"] := 2416
    sci_keyboard_commands["SCI_SCROLLTOEND"] := 2629
    sci_keyboard_commands["SCI_SCROLLTOSTART"] := 2628
    sci_keyboard_commands["SCI_SELECTIONDUPLICATE"] := 2469
    sci_keyboard_commands["SCI_STUTTEREDPAGEDOWN"] := 2437
    sci_keyboard_commands["SCI_STUTTEREDPAGEDOWNEXTEND"] := 2438
    sci_keyboard_commands["SCI_STUTTEREDPAGEUP"] := 2435
    sci_keyboard_commands["SCI_STUTTEREDPAGEUPEXTEND"] := 2436
    sci_keyboard_commands["SCI_TAB"] := 2327
    sci_keyboard_commands["SCI_UPPERCASE"] := 2341
    sci_keyboard_commands["SCI_VCHOME"] := 2331
    sci_keyboard_commands["SCI_VCHOMEDISPLAY"] := 2652
    sci_keyboard_commands["SCI_VCHOMEDISPLAYEXTEND"] := 2653
    sci_keyboard_commands["SCI_VCHOMEEXTEND"] := 2332
    sci_keyboard_commands["SCI_VCHOMERECTEXTEND"] := 2431
    sci_keyboard_commands["SCI_VCHOMEWRAP"] := 2453
    sci_keyboard_commands["SCI_VCHOMEWRAPEXTEND"] := 2454
    sci_keyboard_commands["SCI_VERTICALCENTRECARET"] := 2619
    sci_keyboard_commands["SCI_WORDLEFT"] := 2308
    sci_keyboard_commands["SCI_WORDLEFTEND"] := 2439
    sci_keyboard_commands["SCI_WORDLEFTENDEXTEND"] := 2440
    sci_keyboard_commands["SCI_WORDLEFTEXTEND"] := 2309
    sci_keyboard_commands["SCI_WORDPARTLEFT"] := 2390
    sci_keyboard_commands["SCI_WORDPARTLEFTEXTEND"] := 2391
    sci_keyboard_commands["SCI_WORDPARTRIGHT"] := 2392
    sci_keyboard_commands["SCI_WORDPARTRIGHTEXTEND"] := 2393
    sci_keyboard_commands["SCI_WORDRIGHT"] := 2310
    sci_keyboard_commands["SCI_WORDRIGHTEND"] := 2441
    sci_keyboard_commands["SCI_WORDRIGHTENDEXTEND"] := 2442
    sci_keyboard_commands["SCI_WORDRIGHTEXTEND"] := 2311   
}

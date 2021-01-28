; #Include httpQuery.ahk
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

; exmpl.searchAHKforum.httpQuery.ahk
; Searches the forum for a given Phrase: in this case httpQuery
#noenv
html     := ""
URL      := "http://www.autohotkey.com/forum/search.php?mode=results"
POSTData := "search_keywords=httpQuery&search_terms=all&search_forum=-1&"
          . "search_time=0&search_fields=all&show_results=topics&return_chars=500"
          . "&sort_by=0&sort_dir=DESC"

length := httpQuery(html,URL,POSTdata)
varSetCapacity(html,-1)

Gui,Add,Edit,w600 +Wrap r25,% html
Gui,Show
Return

GuiClose:
GuiEscape:
   ExitApp

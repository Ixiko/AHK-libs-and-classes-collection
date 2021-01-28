; #Include argp.ahk
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

; This demo shows the two functions working on same options string

options = -A='33' -i /f:c:\test -time:5:10 -x /date:11:08:2009

; Example 1: argp_parse()
count := argp_parse(options, 8, n1, v1, n2, v2, n3, v3, n4, v4, n5, v5, n6, v6, n7, v7, n8, v8)
Text =
(
Options string:
%options%

Number of options in source (options):
%count%

Name of key 3 (n3):
%n3%

Value of key 3 (v3):
%v3%
)
MsgBox,, argp_parse(), %Text%

; Example 1: argp_getopt()
searchList := "s i test a"
optlist := argp_getopt(options, searchList, false, v1, v2, v3, v4)
Text =
(
Options string:
%options%

Search list:
%searchList%

Number of options in source (options):
%count%

List of all matching key names (optlist):
%optlist%

Value of key 4 from search list (v4, "a" in this example):
%v4%
)
MsgBox,, argp_getopt(), %Text%
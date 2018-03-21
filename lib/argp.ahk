/*
_______________________________________________________________________________
_______________________________________________________________________________

Title: argp - Argument Options Parser
    Parse an argument string with options and get keys and values.
_______________________________________________________________________________
_______________________________________________________________________________

License:

(C) Copyright 2009, 2010 Tuncay
    
This program is free software; you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation; either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

(see lgplv3.png)

See the file COPYING.txt and COPYING.LESSER.txt for license and copying conditions.

About: Description
    About the idea

Introduction:
    Sometimes we need to work with many optional parameters. Some of the
    parameters may be just logical flags only (true/false). If the function have
    too many such parameters, the usability is endangered. To workaround
    that disgrace, we can make one option string to the function. From now 
    on, this string contains all parameters. This is comparable to the 
    commandline.
        
    It must be parsed to find all parts. Writing such parsers could become 
    difficult and slow down the complete process. The parsing is tried to 
    be made with one regex call only (with some other non dramatic lines).
    As long as the string is keeped simple, there should be no problem. But 
    with growing complexity, with different values of subparameters, it is a 
    pain to make the difference.
    
Who needs this?:    
    This is not a parser for command line arguments of programs or scripts.
    It is similiar to Windows or Unix/Linux command line arguments, but 
    different in some ways and less powerful. This library is for those ahk 
    developers, who needs to write user defined functions with many options. 
    With the parsing of just one real function parameter, it can be avoided to 
    have a bunch of function parameters. 
    
What it can do for you:
    The source will be parsed and all found options are given over to specified
    variables. The other work parsing these generated variables is left to the 
    user. 
    
    * *Pro:* A standardized, simple and fast way of options handling.
    * *Contra:* It isn`t a well known official standard.

History:
    This library is rewritten from scratch and the old BUG or LIMITATION is
    not present anymore. Not only that. It does work in a completly another
    way. After searching the web, I found a regular expression made by 
    Richard Hauer at regexlib.com. I have modified it and now it is the 
    backbone of my functions. One deserved credit goes to him.
    
    The name of the library is changed again, from args to argp. The chosen 
    name argp is a GNU C library for parsing arguments of programs. This 
    AutoHotkey library is named like it, but there is no compatibility with
    the GNU C library. The name is an abbreviation for "ARGument Parser".
    
Links:
    * Discussion: [http://www.autohotkey.com/forum/viewtopic.php?p=310409]
    * License: [http://www.gnu.org/licenses/lgpl-3.0.html]
    * Wikipedia - LGPL: [http://en.wikipedia.org/wiki/GNU_Lesser_General_Public_License]

Date:
    2010-01-30

Revision:
    3.0
    
Status:
    Release

Credits:
    * Tuncay, [tuncay.d@gmx.de] (Author)
    * Richard Hauer [http://regexlib.com/REDetails.aspx?regexp_id=1220] (Author of original Regular Expression)
    
License:
    GNU Lesser General Public License 3.0 or higher [http://www.gnu.org/licenses/lgpl-3.0.html]
    
Category:
    String Manipulation

Type:
    Library

Tested AutoHotkey Version:
    1.0.48.05

Tested Platform:
    2000/XP

Standalone (such as no need for extern file or library):
    Yes

StdLibConform (such as use of prefix and no globals use):
    Yes

Related:
    *Other Community Solutions*
    * Parameters and switches parser by Yook: [http://www.autohotkey.com/forum/viewtopic.php?t=50885]
    * [function] Parse by majkinetor: [http://www.autohotkey.com/forum/viewtopic.php?t=49261]
    * options.ahkl - an options object for AutoHotkey_L by ahklerner: [http://www.autohotkey.com/forum/viewtopic.php?t=49430]

About: Usage
    How to use the functions

Syntax:    
    > count := argp_parse( source [, maxcount, keyname1, value1, ... keyname32, value32] )
    >
    > optlist := argp_getopt( source [, keylist, caseSense, value1, ... value32] )
    
    There are two independently working functions. They have the same regular expression
    at the core, but the functionality and interface differs. One creates variables for each
    key name and the other one returns a list with names, checking against another list of 
    possible names (either with case sense on or off and, removing dublicates).

    After calling one of the functions, the variables or the list must be parsed. This is
    left to be done by the user. For the beginner, it is recommended to use argp_getopt() and then
    check with InStr() if a name exists in resulting list (with surrounding spaces).

    No globals are created, no special objects or frameworks are needed. 
 
Installation:
    Just name the library to "argp.ahk" and put it into the standard or user library folder.
    A call of one of these functions in this library will lead to automatically include it 
    into the script at call time. The folder should reside under one of these paths:
    
    > %A_MyDocuments%\AutoHotkey\Lib\  ; User library.
    > path-to-the-currently-running-AutoHotkey.exe\Lib\  ; Standard library.
    
    Alternatively you can include this library at any position of your script with the 
    #include command:
    
    > #Include argp.ahk

Example 1:
    This is part of parsing the options parameter from hypotetical function set_clipboard().
    The code demonstrates some aspects only, and it`s not optimized.
    
    (Code)        
        ; Set default values prior to parsing argument string.        
        opt_wait_use := false
        opt_errorlevel_set := false
                
        ; Analyze the variable argument for existence of options namely "wait" and "errorlevel".
        ; Save the value of "wait" into variable wait_value.
        ; After that, a new list with option names is get and saved into variable optlist.        
        optlist := argp_getopt(argument, "wait errorlevel", false, wait_value)
                
        ; Now, parse the list and set options for programs usage.        
        If InStr(optlist, " wait ")
        {
            opt_wait_use := true
            opt_wait_value := wait_value
        }
        
        If InStr(optlist, " errorlevel ")
        {
            opt_errorlevel_set := true
        }
    (End)
    
    If the set_clipboard() function was called with following options
    
    > "-w:2"
    
    Then the following variables are set
    
    > opt_wait_use := true
    > opt_wait_value := 2
    > opt_errorlevel_set := false
    
Example 2:
    The next example shall show how to translate an usual function to argp_getopt()
    powered function. One function could look like this (very boring I know):
    
    (Code)
        display(sentence = "hello world", caseMod = 0, html = 0)
        {
            If (caseMod = 1)
                StringUpper, sentence, sentence, T
            Else If (caseMod = 2)
                StringUpper, sentence, sentence
            Else If (caseMod = 3)
                StringLower, sentence, sentence
            If ( html)
                Transform, sentence, HTML, %sentence%
            MsgBox %sentence%
        }
    (End)
    
    A call could look like this
    
    > display("hello world", 1, 1)
    
    Next code is one possible version with argp
    
    (Code)
        display(options)
        {
            ; Default values of options.
            sentence = hello world
            
            ; Parsing options.
            optlist := argp_getopt(options, "sentence caseMod html", false, sentence_value, caseMod_value)
            
            Loop, Parse, optlist, %A_Space%, %A_Space%
            {
                If ("sentence" = A_LoopField)
                    sentence := sentence_value
                Else If ("caseMod" = A_LoopField)
                {
                    If (caseMod_value = 1)
                        StringUpper, sentence, sentence, T
                    Else If (caseMod_value = 2)
                        StringUpper, sentence, sentence
                    Else If (caseMod_value = 3)
                        StringLower, sentence, sentence
                }
                Else If ("html" = A_LoopField)
                    Transform, sentence, HTML, %sentence%
            }
            
            MsgBox %sentence%
        }
    (End)
    
    Lets see how a call could look now
    
    > display("-caseMod 2 -html")
    
    What is done there? First we have changed from multiple function parameters to 
    single parameter. All the necessary default parameters are set in the function 
    body. Then the argp_getopt() is used to parse options variable. The third 
    parameter (here set to false) is for doing the parse without case sensitivity. 
    All the parameters after that, are variables for holding possible values of the 
    options. That is, because every option can have its own value. 
    
    After this process, the resulting optlist variable holds the found names of options 
    (given are the three "sentence caseMod html"). As a next step, this optlist 
    variable must be parsed manually for checking which options are found actually and 
    doing the right actions. In this example, a Loop, Parse command is chosen. There 
    are other possibilities like multiple InStr() checks.
    
About: Specification
    Argument string format

Basic structure:
    Any option must begin either with a hypghen "-" or slash "/", to be 
    recognized as an option. It doesn`t matter which of the two is used. 
    The following character or word until next option or space is the key 
    name of that option. In example:    
    
    > -a -b
    and
    > -a-b
    
    would be resolved to these keys
    
    > a
    > b
    
    Although space is not required, you can write without it.
    
    Normally parts in string that are not recognized as options should be ignored. In 
    such a case, the resulting variable and value is allways empty. 

Values added to keys:
    Every option can have its own assigned value. The value can be delimited
    from its key name with a space " ", a double colon ":" or an equality sign "=".
    If it is enclosed in quotes, then no delimiter is needed. The value is read until 
    one space is found (or another option starts). In example:
    
    > -a test1 -b
    
    would be resolved to these keys
    
    > a
    > b
    
    Where "a" holds the value "test1".
    
    Normally spaces around a value are lost. The value can be optionally enclosed
    between a pair of single or double quotes. That way spaces inside the quotes
    are saved. 
    
    > -a:'foo -bar ' -B -c hello world
    
    would be resolved to these keys
    
    > a
    > B
    > c
    
    Where a holds the value "foo -bar " and c the value "hello".
    
    If a value contains one of these characters -, /, :, =, ' or ", then it is best 
    to enclose the whole value between quotes (single or double).

Dublicate keys:
    argp_parse() and argp_getopt() treat duplicate definitions of option names in 
    different ways. argp_parse() sees every key separately. And argp_getopt() sees
    the first definition only. This is important if they have values. In example:
    
    > -a:foo -a:bar -A
    
    would argp_getopt() resolve to
    
    > a
    > A
    
    where a would holds the value "foo" and A would have an empty value.
    In contrast argp_parse() resolves to
    
    > a
    > a
    > A
    
    first a holds "foo" and second a holds "bar". Again, the last A have an
    empty value.
    
Key naming:
    These characters in key name are allowed: a-z, A-Z, 0-9, _, ., ?, ! and @. Some
    examples:
    
    > -a
    > -test
    > /test.example
    > /?
    > -64
    > -@section
    
The one special value without key name:    
    There is one exception in argp_parse() function only. Any string before
    first option is treated as a special value without a key name. That value 
    is parsed like any other value. In example:
    
    > hello -a    
    
    would be resolved to these keys
    
    > a
    
    The key "a" does have an empty value and the first special value "hello" 
    is saved in ErrorLevel. This is supported by argp_parse() function exclusively.
*/


/*
Func: argp_parse
    Get optional keys and values as separate variables.
    
Syntax:
    > count := argp_parse( args [, maxcount, n1, v1, ... n32, v32] )

Parameters:
    args            - *Variable* [string] input: Source String variable with options to parse. See above 
                        at "Specification", which is a description about the format.
    maxcount        - *Optional* [integer] input:  Specifies how many options to get. Anything 
                        below '1' or above '32' defaults to '32'.
    n1-n32          - *Variable Optional* [string] output: Stores the key name of option into variable.
                        Variable n1 would hold first found name of option (i.e. "A").
    v1-v32          - *Variable Optional* [string] output: Stores the value of an option into variable.
                        Variable v1 would hold value of first found option (i.e. "33").

Returns:
    Number of retrieved options, or '0' otherwise.

Remarks:
    maxcount can be set to an integer value between 1 and 32. That restricts the number
    of options to extract from source string. In example, if specified to 8, then the 
    first 8 options are seen and the rest is ignored. This is an optimization. Maximum
     possible of 6 options to parse is faster than to parse 26 options. Plus, there are 
    special optimizations to 8, 16 and 32, so they are faster in execution against values
    near to them. These values (8, 16, 32) are highly recommended.

ErrorLevel:
    ErrorLevel is set to the first special value without key name. Otherwise it is empty.
    With following example:
    
    > get -i
    
    it would hold "get". With next example
    
    > -i get
    
    ErrorLevel would be empty.
    
Examples:
    (Code)
        options = -A='33' -i /f:c:\test -time:5:10 -x /date:11:08:2009
        count := argp_parse(options, 8, n1, v1, n2, v2, n3, v3, n4, v4, n5, v5, n6, v6, n7, v7, n8, v8)
        Text =
        (
        Number of options in source (options):
        %count%
        
        Name of key 3 (n3):
        %n3%
        
        Value of key 3 (v3):
        %v3%
        )
        MsgBox %Text%
    (End)
    
    *Output:*
    
    (Code)
        Number of options in source (options):
        6
        
        Name of key 3 (n3):
        f
        
        Value of key 3 (v3):
        c:\test
    (End)
*/
argp_parse(ByRef _args, _maxcount=32, ByRef _n1="", ByRef _v1="", ByRef _n2="", ByRef _v2="", ByRef _n3="", ByRef _v3="", ByRef _n4="", ByRef _v4="", ByRef _n5="", ByRef _v5="", ByRef _n6="", ByRef _v6="", ByRef _n7="", ByRef _v7="", ByRef _n8="", ByRef _v8="", ByRef _n9="", ByRef _v9="", ByRef _n10="", ByRef _v10="", ByRef _n11="", ByRef _v11="", ByRef _n12="", ByRef _v12="", ByRef _n13="", ByRef _v13="", ByRef _n14="", ByRef _v14="", ByRef _n15="", ByRef _v15="", ByRef _n16="", ByRef _v16="", ByRef _n17="", ByRef _v17="", ByRef _n18="", ByRef _v18="", ByRef _n19="", ByRef _v19="", ByRef _n20="", ByRef _v20="", ByRef _n21="", ByRef _v21="", ByRef _n22="", ByRef _v22="", ByRef _n23="", ByRef _v23="", ByRef _n24="", ByRef _v24="", ByRef _n25="", ByRef _v25="", ByRef _n26="", ByRef _v26="", ByRef _n27="", ByRef _v27="", ByRef _n28="", ByRef _v28="", ByRef _n29="", ByRef _v29="", ByRef _n30="", ByRef _v30="", ByRef _n31="", ByRef _v31="", ByRef _n32="", ByRef _v32="")
{
    If (_maxcount<1||_maxcount>32)
        _maxcount:=32
    If (_maxcount=32) ; Optimization to avoid Loop.
        _n1:="",_n2:="",_n3:="",_n4:="",_n5:="",_n6:="",_n7:="",_n8:="",_n9:="",_n10:="",_n11:="",_n12:="",_n13:="",_n14:="",_n15:="",_n16:="",_n17:="",_n18:="",_n19:="",_n20:="",_n21:="",_n22:="",_n23:="",_n24:="",_n25:="",_n26:="",_n27:="",_n28:="",_n29:="",_n30:="",_n31:="",_n32:="",regex := "JSs`a)(?:('(?:(?P<v>.+?)')(?=.*?)|""(?:(?P<v>.+?)"")(?=.*?)|\s*(?P<v>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n1>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v1>.+?)')(?=.*?)|""(?:(?P<v1>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v1>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n2>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v2>.+?)')(?=.*?)|""(?:(?P<v2>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v2>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n3>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v3>.+?)')(?=.*?)|""(?:(?P<v3>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v3>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n4>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v4>.+?)')(?=.*?)|""(?:(?P<v4>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v4>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n5>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v5>.+?)')(?=.*?)|""(?:(?P<v5>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v5>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n6>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v6>.+?)')(?=.*?)|""(?:(?P<v6>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v6>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n7>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v7>.+?)')(?=.*?)|""(?:(?P<v7>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v7>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n8>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v8>.+?)')(?=.*?)|""(?:(?P<v8>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v8>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n9>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v9>.+?)')(?=.*?)|""(?:(?P<v9>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v9>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n10>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v10>.+?)')(?=.*?)|""(?:(?P<v10>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v10>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n11>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v11>.+?)')(?=.*?)|""(?:(?P<v11>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v11>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n12>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v12>.+?)')(?=.*?)|""(?:(?P<v12>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v12>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n13>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v13>.+?)')(?=.*?)|""(?:(?P<v13>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v13>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n14>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v14>.+?)')(?=.*?)|""(?:(?P<v14>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v14>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n15>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v15>.+?)')(?=.*?)|""(?:(?P<v15>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v15>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n16>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v16>.+?)')(?=.*?)|""(?:(?P<v16>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v16>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n17>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v17>.+?)')(?=.*?)|""(?:(?P<v17>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v17>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n18>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v18>.+?)')(?=.*?)|""(?:(?P<v18>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v18>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n19>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v19>.+?)')(?=.*?)|""(?:(?P<v19>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v19>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n20>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v20>.+?)')(?=.*?)|""(?:(?P<v20>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v20>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n21>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v21>.+?)')(?=.*?)|""(?:(?P<v21>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v21>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n22>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v22>.+?)')(?=.*?)|""(?:(?P<v22>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v22>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n23>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v23>.+?)')(?=.*?)|""(?:(?P<v23>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v23>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n24>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v24>.+?)')(?=.*?)|""(?:(?P<v24>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v24>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n24>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v25>.+?)')(?=.*?)|""(?:(?P<v25>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v25>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n24>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v26>.+?)')(?=.*?)|""(?:(?P<v26>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v26>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n24>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v27>.+?)')(?=.*?)|""(?:(?P<v27>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v27>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n24>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v28>.+?)')(?=.*?)|""(?:(?P<v28>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v28>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n24>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v29>.+?)')(?=.*?)|""(?:(?P<v29>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v29>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n24>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v30>.+?)')(?=.*?)|""(?:(?P<v30>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v30>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n24>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v31>.+?)')(?=.*?)|""(?:(?P<v31>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v31>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n24>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v32>.+?)')(?=.*?)|""(?:(?P<v32>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v32>[^-/\s]*)\s*))?"
    Else If (_maxcount=16) ; Optimization to avoid Loop.
        _n1:="",_n2:="",_n3:="",_n4:="",_n5:="",_n6:="",_n7:="",_n8:="",_n9:="",_n10:="",_n11:="",_n12:="",_n13:="",_n14:="",_n15:="",_n16:="",regex := "JSs`a)(?:('(?:(?P<v>.+?)')(?=.*?)|""(?:(?P<v>.+?)"")(?=.*?)|\s*(?P<v>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n1>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v1>.+?)')(?=.*?)|""(?:(?P<v1>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v1>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n2>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v2>.+?)')(?=.*?)|""(?:(?P<v2>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v2>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n3>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v3>.+?)')(?=.*?)|""(?:(?P<v3>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v3>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n4>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v4>.+?)')(?=.*?)|""(?:(?P<v4>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v4>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n5>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v5>.+?)')(?=.*?)|""(?:(?P<v5>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v5>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n6>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v6>.+?)')(?=.*?)|""(?:(?P<v6>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v6>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n7>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v7>.+?)')(?=.*?)|""(?:(?P<v7>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v7>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n8>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v8>.+?)')(?=.*?)|""(?:(?P<v8>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v8>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n9>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v9>.+?)')(?=.*?)|""(?:(?P<v9>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v9>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n10>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v10>.+?)')(?=.*?)|""(?:(?P<v10>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v10>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n11>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v11>.+?)')(?=.*?)|""(?:(?P<v11>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v11>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n12>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v12>.+?)')(?=.*?)|""(?:(?P<v12>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v12>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n13>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v13>.+?)')(?=.*?)|""(?:(?P<v13>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v13>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n14>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v14>.+?)')(?=.*?)|""(?:(?P<v14>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v14>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n15>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v15>.+?)')(?=.*?)|""(?:(?P<v15>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v15>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n16>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v16>.+?)')(?=.*?)|""(?:(?P<v16>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v16>[^-/\s]*)\s*))?"
    Else If (_maxcount=8) ; Optimization to avoid Loop.
        _n1:="",_n2:="",_n3:="",_n4:="",_n5:="",_n6:="",_n7:="",_n8:="",regex := "JSs`a)(?:('(?:(?P<v>.+?)')(?=.*?)|""(?:(?P<v>.+?)"")(?=.*?)|\s*(?P<v>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n1>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v1>.+?)')(?=.*?)|""(?:(?P<v1>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v1>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n2>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v2>.+?)')(?=.*?)|""(?:(?P<v2>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v2>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n3>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v3>.+?)')(?=.*?)|""(?:(?P<v3>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v3>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n4>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v4>.+?)')(?=.*?)|""(?:(?P<v4>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v4>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n5>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v5>.+?)')(?=.*?)|""(?:(?P<v5>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v5>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n6>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v6>.+?)')(?=.*?)|""(?:(?P<v6>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v6>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n7>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v7>.+?)')(?=.*?)|""(?:(?P<v7>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v7>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n8>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v8>.+?)')(?=.*?)|""(?:(?P<v8>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v8>[^-/\s]*)\s*))?"
    Else
    {
        If (_maxcount>8)
            VarSetCapacity(regex,4624) 
        regex:="JSs`a)(?:('(?:(?P<v>.+?)')(?=.*?)|""(?:(?P<v>.+?)"")(?=.*?)|\s*(?P<v>[^-/\s]*)\s*))?"
        Loop,%_maxcount%
            _n%A_Index%:="",regex.="(?:(?:.*?\s*)[-/](?P<n" . A_Index . ">[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v" . A_Index . ">.+?)')(?=.*?)|""(?:(?P<v" . A_Index . ">.+?)"")(?=.*?)|[\s'""]?\s*(?P<v" . A_Index . ">[^-/\s]*)\s*))?"
    }
    RegExMatch(_args,regex,_),ErrorLevel:=_v
    If (_n%_maxcount%!="") ; Possible shortcut to avoid checking for each variable.
        Return _maxcount
    Else
    {
        count:=0
        Loop,%_maxcount%
            If (_n%A_Index%!="")
                count:=A_Index
    }
    Return count
}


/*
Func: argp_getopt
    Check for known keys and get list of them and all values as separate variables.

Syntax:
    > optlist := argp_getopt( source [, keylist, caseSense, value1, ... value32] )

Parameters:
    args            - *Variable* [string] input: Source String variable with options to parse. See above 
                        at "Specification", which is a description about the format.
    keyList         - *Optional* [string] input: A space separated list of option names. Every key 
                        in options source string args will be in returning optlist. All values are
                        written to output variables from number 1 to 32. The third item in this list
                        relates to third output variable.
                        If the keylist is empty "", then all existing key names are get.
    case            - *Optional* [flag] input: Case sensitivity of names checking; sensitiv at 
                        default (true or 1) leads to let "a" as a different option as "A".
    1-32            - *Variable Optional* [string] output: Stores the value of option into variable.
                        Variable number 1 would hold value (i.e. "33") of first defined option (i.e. "A").

Returns:
    Get a space separated list of matching names. This means, all not found option names 
    are filtered out from keyList. Duplicate names are not found and first one is used 
    instead. (In example: "A file A c i", these are the names of 4 options.) 
    
    If keyList is empty, then all options found in source is returned. Order of corresponding
    values (specified variables 1-32) reflects the order in source. But if keyList is a non 
    empty list, then all options specified in this list are returned.

Remarks:
    Other than argp_parse(), this function awaits a list of option names in keyList. That
    keylist is compared against all found option names from source. All matching keys are
    copied to resulting return list. 
    
    The returning list have spaces around also (at begin of list and end of). That allows 
    checking for existency of keys with 
    
    > InStr(keylist, " A ")
    
    Any existing value corresponding to the key name is copied to output variable ranging 
    from 1 to 32. In example second options value belongs to second variable, even if there
    is no value. In that case, the value is an empty string (blank value).

ErrorLevel:
    ErrorLevel is set to the number of matching option names. Duplicates are not counted. 
    If nothing is found, it is set to '0'. It is not the count of resulting keylist, but the
    count of keys in source string args.

Examples:
    (Code)
        options = -A='33' -i /f:c:\test -time:5:10 -x /date:11:08:2009
        optlist := argp_getopt(options, "s i test a", false, v1, v2, v3, v4)
        Text =
        (
        Number of options in source (options):
        %count%
        
        List of all matching key names (optlist):
        %optlist%
        
        Value of key 4 (v4):
        %v4%
        )
        MsgBox %Text%
    (End)
    
    *Output:*
    
    (Code)
        Number of options in source (options):
        6
        
        List of all matching key names (optlist):
         a i 
        
        Value of key 4 (v4):
        33
    (End)
*/
argp_getopt(ByRef _args, _keylist="", _case=true, ByRef _1="", ByRef _2="", ByRef _3="", ByRef _4="", ByRef _5="", ByRef _6="", ByRef _7="", ByRef _8="", ByRef _9="", ByRef _10="", ByRef _11="", ByRef _12="", ByRef _13="", ByRef _14="", ByRef _15="", ByRef _16="", ByRef _17="", ByRef _18="", ByRef _19="", ByRef _20="", ByRef _21="", ByRef _22="", ByRef _23="", ByRef _24="", ByRef _25="", ByRef _26="", ByRef _27="", ByRef _28="", ByRef _29="", ByRef _30="", ByRef _31="", ByRef _32="")
{
    CaseSense:=A_StringCaseSense
    StringCaseSense,Off
    _1:="",_2:="",_3:="",_4:="",_5:="",_6:="",_7:="",_8:="",_9:="",_10:="",_11:="",_12:="",_13:="",_14:="",_15:="",_16:="",_17:="",_18:="",_19:="",_20:="",_21:="",_22:="",_23:="",_24:="",_25:="",_26:="",_27:="",_28:="",_29:="",_30:="",_31:="",_32:="",RegExMatch(_args,"JSs`a)(?:(?:.*?\s*)[-/](?P<n1>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v1>.+?)')(?=.*?)|""(?:(?P<v1>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v1>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n2>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v2>.+?)')(?=.*?)|""(?:(?P<v2>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v2>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n3>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v3>.+?)')(?=.*?)|""(?:(?P<v3>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v3>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n4>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v4>.+?)')(?=.*?)|""(?:(?P<v4>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v4>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n5>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v5>.+?)')(?=.*?)|""(?:(?P<v5>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v5>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n6>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v6>.+?)')(?=.*?)|""(?:(?P<v6>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v6>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n7>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v7>.+?)')(?=.*?)|""(?:(?P<v7>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v7>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n8>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v8>.+?)')(?=.*?)|""(?:(?P<v8>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v8>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n9>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v9>.+?)')(?=.*?)|""(?:(?P<v9>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v9>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n10>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v10>.+?)')(?=.*?)|""(?:(?P<v10>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v10>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n11>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v11>.+?)')(?=.*?)|""(?:(?P<v11>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v11>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n12>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v12>.+?)')(?=.*?)|""(?:(?P<v12>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v12>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n13>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v13>.+?)')(?=.*?)|""(?:(?P<v13>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v13>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n14>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v14>.+?)')(?=.*?)|""(?:(?P<v14>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v14>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n15>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v15>.+?)')(?=.*?)|""(?:(?P<v15>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v15>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n16>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v16>.+?)')(?=.*?)|""(?:(?P<v16>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v16>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n17>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v17>.+?)')(?=.*?)|""(?:(?P<v17>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v17>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n18>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v18>.+?)')(?=.*?)|""(?:(?P<v18>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v18>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n19>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v19>.+?)')(?=.*?)|""(?:(?P<v19>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v19>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n20>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v20>.+?)')(?=.*?)|""(?:(?P<v20>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v20>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n21>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v21>.+?)')(?=.*?)|""(?:(?P<v21>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v21>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n22>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v22>.+?)')(?=.*?)|""(?:(?P<v22>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v22>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n23>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v23>.+?)')(?=.*?)|""(?:(?P<v23>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v23>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n24>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v24>.+?)')(?=.*?)|""(?:(?P<v24>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v24>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n24>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v25>.+?)')(?=.*?)|""(?:(?P<v25>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v25>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n24>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v26>.+?)')(?=.*?)|""(?:(?P<v26>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v26>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n24>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v27>.+?)')(?=.*?)|""(?:(?P<v27>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v27>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n24>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v28>.+?)')(?=.*?)|""(?:(?P<v28>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v28>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n24>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v29>.+?)')(?=.*?)|""(?:(?P<v29>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v29>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n24>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v30>.+?)')(?=.*?)|""(?:(?P<v30>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v30>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n24>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v31>.+?)')(?=.*?)|""(?:(?P<v31>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v31>[^-/\s]*)\s*))?(?:(?:.*?\s*)[-/](?P<n24>[a-zA-Z0-9_?!@.]+)(?:[:=]\s*)?(\s*'(?:(?P<v32>.+?)')(?=.*?)|""(?:(?P<v32>.+?)"")(?=.*?)|[\s'""]?\s*(?P<v32>[^-/\s]*)\s*))?",_) ; 32 elements.
    ; At keys, one space is needed for checking.
    count:=0,keys:=" ",i:=0
    Loop,32 ; 32 corresponding to the maximum possible number of matching elements.
        If (_n%A_Index%!="")
            count:=A_Index
    
    If (_keylist="")
    {
        Loop,%count%
        {
            n:=_n%A_Index%
            If (!InStr(keys," " . n . " ",_case))
                _%A_Index%:=_v%A_Index%,keys.=_n . A_Space
        }
    }
    Else If (_case)
    {
        Loop,%count%
        {
            i:=A_Index,n:=_n%A_Index%
            Loop,Parse,_keylist,%A_Space%,%A_Space%
                If (n==A_LoopField&&!InStr(keys," " . A_LoopField . " ",true))
                {
                    _%A_Index%:=_v%i%,keys.=A_LoopField . A_Space
                    Break
                }
                Else If (!InStr(keys," " . A_LoopField . " ",false))
                    _%A_Index%:=""
        }
    }
    Else ; Uses = instead of == and false instead of true in InStr() and case
         ; takes the correct case version from source.
    {
        Loop,%count%
        {
            i:=A_Index,n:=_n%A_Index%
            Loop,Parse,_keylist,%A_Space%,%A_Space%
                If (n=A_LoopField&&!InStr(keys," " . A_LoopField . " ",false))
                {
                    _%A_Index%:=_v%i%,keys.=n . A_Space ; n is case from source.
                    Break
                }
                Else If (!InStr(keys," " . A_LoopField . " ",false))
                    _%A_Index%:=""
        }
    }
    StringCaseSense,%CaseSense%
    ErrorLevel:=count ; Number of matching elements.
    Return keys
}

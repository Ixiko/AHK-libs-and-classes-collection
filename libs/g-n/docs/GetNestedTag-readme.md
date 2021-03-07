# GetNestedTag() - v1

**Introduction**

Function (parser) to retrieve the contents of a (nested) HTML-tag, say a DIV.

This is useful if you have a HTML file/or variable and you want to extract a block of data,
for example the CONTENT or MAIN div or a UL that is used for a menu. By default it will
get the first occurrence of a tag, so if you want to use it to get more than one tag you will have
to use a loop, for example if you wanted to get all Paragraph &lt;p&gt; tags from the HTML data. (See example 5)

### Parameters

**GetNestedTag(data,tag[,occurence=1])**

|Parameter|Description|
|---------|-----------|
|Data     |Html code as variable, you can read a file into a variable using FileRead, <http://www.autohotkey.com/docs/commands/FileRead.htm>|
|Tag      |(Nested)tag to retrieve from html data. It will retrieve the first occurrence by default.|
|Occurence|By default it retrieves the first occurence of the Tag, you can use occurrence to retrieve the second, third etc. To get all occurrences of a tag use a loop as shown in example 5 below.|

## Code Examples

In the examples below a variable &#8216;get&#8217; is used just to make it a little easier to pass on
the tag to get to the function. If you want to pass on the tag directly in the function call you need
to use "" to escape the quotes (if they are present), which depends on how the HTML is written,
so it could be any of these:

   ```autohotkey
   GetNestedTag(html,"<div id=""content"">")
   GetNestedTag(html,"<div id='content'>")
   GetNestedTag(html,"<div id=content>")
   ```

It only works correctly with properly formatted html.


   ```autohotkey
   #Include GetNestedTag.ahk ; Not required if you place GetNestedTag.ahk in your library

   Gosub, GetHtml

   ; Example 1 - get DIV header
   ; Pretty simple as it is not a nested DIV
   get=<div id="header">
   MsgBox,,Example 1 - get DIV header, % GetNestedTag(html,get)

   ; Result:
   ; <div id="header"><!-- start header -->
   ; <h1>GetNestedTag(data,tag)</h1>
   ; <!-- /end header --></div>

   ; Example 2 - get content
   ; More complex as it is a nested DIV
   get=<div id="content">
   MsgBox,,Example 2 - get DIV content, % GetNestedTag(html,get)

   ; Result:
   ; <div id="content"><!-- start content -->
   ; .... all lines in between ...
   ; <!-- /end content --></div>     

   ; Example 3a - get table data
   ; Nested TABLE
   get=<table id="data">
   MsgBox,,Example 3a - get table data, % GetNestedTag(html,get)

   ; Example 3b - get table subdata
   get=<table id="subdata">
   MsgBox,,Example 3b - get table subdata, % GetNestedTag(html,get)

   ; Example 4a - get UL menu
   ; Nested UL, 3 levels
   get=<ul id="menu">
   MsgBox,,Example 4a - get UL Menu, % GetNestedTag(html,get)

   ; Example 4b - get the first UL
   get=<ul>
   MsgBox,,Example 4 - get UL, % GetNestedTag(html,get)

   ; Example 5 - get all paragraphs
   Loop
     {
      tag:=GetNestedTag(html,"<p",A_Index)
      If (tag = "")
        Break
      MsgBox,,Example 5 - get P (%A_Index%/5), % tag
     }

   ExitApp

    GetHtml:
    html=
    (
    <!DOCTYPE html>
    <html lang="en-us">
    <head>
    <title>Example HTML</title>
    </head>
    <body>
    <div id="wrapper"><!-- start wrapper -->
     <div id="header"><!-- start header -->
      <h1>GetNestedTag(data,tag)</h1>
     <!-- /end header --></div>
     <div id="navigation"><!-- start navigation -->
      <ul id="menu">
       <li>Menu option 1</li>
       <li>Menu option 2
        <ul class="submenu">
         <li>Submenu 2.1</li>
         <li>Submenu 2.2
          <ul><!-- ul1 -->
           <li>Submenu 2.2.1</li>
           <li>Submenu 2.2.2</li>
           <li>Submenu 2.2.3</li>
           <li>Submenu 2.2.4</li>
          </ul>
         </li>
         <li>Submenu 2.3</li>
         <li>Submenu 2.4</li>
        </ul>
       </li>
       <li>Menu option 3</li>
       <li>Menu option 4</li>
       <li>Menu option 5    
        <ul class="submenu">
         <li>Submenu 5.1</li>
         <li>Submenu 5.2</li>
        </ul>
       </li>
       <li>Menu option 6</li>
      </ul>
     </div><!-- /end navigation -->

       <div id="leftcolumn"><!-- start leftcol -->
        <ol>
         <li>Scripting</li>
         <li>Hotkeys</li>
         <li>Automation</li>
        </ol>
       <!-- /end leftcol --></div>

       <div id="content"><!-- start content -->

       <div class="intro"><p>AutoHotkey is a free, open-source utility for Windows. With it, you can:</p></div>

       <div style="clear:both;"></div>

       <ul><!-- ul2 -->
       <li>Automate almost anything by sending keystrokes and mouse clicks.</li>
       <li>Create hotkeys for keyboard, joystick, and mouse.</li>
       <li>Expand abbreviations as you type them.</li>
       <li>Create custom data-entry forms, user interfaces, and menu bars.</li>
       <li>Remap keys and buttons on your keyboard, joystick, and mouse.</li>
       <li>Respond to signals from hand-held remote controls via the WinLIRC client script.</li>
       <li>Run existing AutoIt v2 scripts and enhance them with new capabilities.</li>
       </ul>

       <p>Getting started might be easier than you think. Check out the quick-start tutorial.</p>

       <div style="clear:both;"></div>

       <p>Here is a nice table with some data:</p>

       <table id="data">
         <tr>
           <th>1</th>
           <th>2</th>
         </tr>
         <tr>
           <td>
           <table id="subdata">
            <tr>
             <td>3a</td>
             <td>3b</td>
            </tr>
           </table>
           </td>
           <td>4</td>
         </tr>
         <tr>
           <td>5</td>
           <td>6</td>
         </tr>
       </table>

       <p>Nothing more to report in content.</p>

       <!-- /end content --></div>
       <div id="rightcolumn"><!-- start rightcol -->
        <ol>
         <li>Automation</li>
         <li>Hotkeys</li>
         <li>Scripting</li>
        </ol>
       <!-- /end rightcol --></div>

      <div id="footer">
       <p><a href='http://www.autohotkey.com/'>http://www.autohotkey.com/</a></p>
      </div>
    <!-- /end wrapper --></div>
    </body>
    </html>
    )
   Return
   ```

Source: <https://github.com/hi5/GetNestedTag/>
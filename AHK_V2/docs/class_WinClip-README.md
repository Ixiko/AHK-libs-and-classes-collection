### credits where it's due: [WinClip - AHKv2 Compatibility](https://www.autohotkey.com/boards/viewtopic.php?f=6&t=29314&sid=1490accee0fbb2301d2bc74cde64dcd2#p137839) 
og is written in [AutoHotkey_L v1](https://www.autohotkey.com/download/)
<br>
<br>
this project converted it to [AutoHotkey_H v2 alpha](https://hotkeyit.github.io/v2)<br>
download:
https://github.com/HotKeyIt/ahkdll-v2-release/archive/master.zip<br>
I run `.ah2` with: `ahkdll-v2-release-master\x64w_MT\AutoHotkey.exe`
<br>
<br>
<br>
#### folder `imgSrc to HTML Format\`: answers Stack Overflow:<br>
[Modifying a clipboard content to be treated as HTML](https://stackoverflow.com/questions/40439917/modifying-a-clipboard-content-to-be-treated-as-html)

tested here: https://html5-editor.net/

what you get after pasting HTML Format in WYSIWYG editor:<br>
- from hightlight ctrl+c:<br>
`<p><img src="https://cdn.sstatic.net/Img/teams/teams-illo-free-sidebar-promo.svg?v=47faa659a05e" alt="" width="139" height="114" /></p>`

- from ahk: src -> HTML Format (<kbd>ctrl</kbd>+<kbd>shift</kbd>+<kbd>v</kbd>)<br>
`<p><img src="https://cdn.sstatic.net/Img/teams/teams-illo-free-sidebar-promo.svg?v=47faa659a05e" /></p>`<br>
we only have the src in our clipboard, no size information

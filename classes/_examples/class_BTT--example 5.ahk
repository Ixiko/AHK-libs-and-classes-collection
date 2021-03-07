#SingleInstance Force
SetBatchLines, -1

Text=
(
使用模板可以轻松创建自己的风格。
欢迎分享，带张截图！！！

Use template to easily create your own style.
Please share your custom style and include a screenshot.
It will help a lot of people.
)

; 照着模板改参数就可以创建自己的风格了。建好后可以添加到 btt() 函数里，就可以变内置风格了。
; You can put your own style in btt() function, then you can use your own style in anywhere.
; All supported parameters are listed below. All parameters can be omitted.
; Please share your custom style and include a screenshot. It will help a lot of people.
; Attention:
; Color => ARGB => Alpha Red Green Blue => 0x ff aa bb cc => 0xffaabbcc
OwnStyle := {Border:20
					, Rounded:30
					, Margin:30
					, BorderColor:0xffaabbcc                         ; ARGB
					, TextColor:0xff112233                           ; ARGB
					, BackgroundColor:0xff778899                     ; ARGB
					, BackgroundColorLinearGradientStart:0xffF4CFC9  ; ARGB
					, BackgroundColorLinearGradientEnd:0xff8DA5D3    ; ARGB
					, BackgroundColorLinearGradientDirection:1       ; 1 = Horizontal   2 = Oblique   3 = Vertical
					, Font:"Font Name"                               ; If omitted, ToolTip's Font will be used.
					, FontSize:12
					, FontRender:5                                   ; 0-5 (recommended value is 5)
					, FontStyle:"Regular Bold Italic BoldItalic UnderlineStrikeout"}

btt(Text,,,,OwnStyle)
Sleep,10000
ExitApp
#singleinstance force
;#include Subtitle.ahk
;#include <Gdip_All>

pToken := Gdip_Startup()
; Don't forget to initalize gdi+

Subtitle("Welcome to the demo", "t3000 xCenter yCenter w70% h50% cD25141 r20", "jCenter fVerdana s72 cFFFFFF Bold")
; 1. Text to Display
; 2. Background parameters.
; 3. Text parameters


howto := "
(
   Press Escape to exit.

   All the following will set x to 200 pixels.
   ""x200""
   ""x: 200""
   ""left: 200""
   {""x"":""200""}
   {""left"":200}

   Background field
   x, left - Set x coordinate
   y, top - Set y coordinate
   w, width - Set width, leave blank or 0 to autosize.
   h, height - Set height, leave blank or 0 to autosize.
   r, radius - Set radius of rounded corners.
   c, color - Set color. FFFFFF is white. DDFFFFFF is transparent white.
   p, padding - Set padding inside the box. (% of A_ScreenHeight)

   Text field
   x, left - Set x coordinate (% of box width)
   y, top - Set y coordinate (% of box height)
   w, width - Set width (% of box width)
   h, height - Set height (% of box height)
   m, margin - Set margin of text (% of box width)
   f, font - Set font. If font name has a space, use object notation.
   s, size - Set font size. (% of A_ScreenHeight)
   c, color - Set font color.
   b, bold - Bold Text (Write 'Bold' in string, or set its value to true in object notation.)
   i, italic - Italicize Text.
   u, underline - Underline Text.
   j, justify - Justify Text. (Left = 0, Center = 1, Right = 2)
   q, quality - Set Rendering Hint. (0-5, 4 is Anti-Alias recommended, 5 is cleartype and will cause issues with autosizing.)
   n, noWrap - Disable text wrapping. Just write NoWrap, or set it to 'yes'/1/true in object notation.
   z, condensed - Set condensed font. Will condense text if exceeds screen width. Use 1 to use 'Arial Narrow'
)"




Subtitle("3", "t1000 x80% y66% c0x00000000", "jCenter fVerdana s36 cFFFFFF Bold")
Sleep 1000
Subtitle("2", "t1000 x80% y66% c0x00000000", "jCenter fVerdana s36 cFFFFFF Bold")
Sleep 1000
Subtitle("1", "t1000 x80% y66% c0x00000000", "jCenter fVerdana s36 cFFFFFF Bold")
Sleep 1000
Subtitle("0", "t10 x80% y66% c0x00000000", "jCenter fVerdana s36 cFFFFFF Bold")


Subtitle("Let's change some colors.", "t2500 x7.8% y13.9% w50% h33% cE5E1DE r20", "fVerdana s36 c396786 Bold")
Sleep 2500
Subtitle("Invert", "t2500 x7.8% y13.9% w50% h33% c396786 r20", "fVerdana s36 cE5E1DE Bold")
Sleep 2500
Subtitle("Blue", "t2000 x7.8% y13.9% w50% h33% cE5E1DE r20", "fVerdana s72 c396786 Bold")
Sleep 2000
Subtitle("Red", "t2000 x7.8% y13.9% w50% h33% cE5E1DE r20", "fVerdana s72 cE46358 Bold")
Sleep 2000
Subtitle("Yellow", "t2000 x7.8% y13.9% w50% h33% cE5E1DE r20", "fVerdana s72 cDEAF58 Bold")
Sleep 2000
Subtitle("Orange?", "t2000 x7.8% y13.9% w50% h33% cE5E1DE r20", "fVerdana s72 cDF7B39 Bold")
Sleep 2000

Subtitle("x at 500 pixels", "t2000 x500 y13.9% w50% h33% cE5E1DE r20", "fVerdana s36 cDF7B39 Bold")
Sleep 2000
Subtitle("y at 500 pixels", "t2000 x500 y500 w50% h33% cE5E1DE r20", "fVerdana s36 cDF7B39 Bold")
Sleep 2000
Subtitle("width at 500 pixels", "t2000 x500 y500 w500 h33% cE5E1DE r20", "fVerdana s36 cDF7B39 Bold")
Sleep 2000
Subtitle("height at 500 pixels", "t2000 x500 y500 w500 h500 cE5E1DE r20", "fVerdana s36 cDF7B39 Bold")
Sleep 2000
Subtitle("Double Roundness `nto radius 40", "t2000 x500 y500 w500 h500 cE5E1DE r40", "fVerdana s36 cDF7B39 Bold")
Sleep 2000
Subtitle("Double Roundness `nto radius 80", "t2000 x500 y500 w500 h500 cE5E1DE r80", "fVerdana s36 cDF7B39 Bold")
Sleep 2000
Subtitle("Justify Text`nto Center", "t2000 x500 y500 w500 h500 cE5E1DE r80", "jCenter fVerdana s36 cDF7B39 Bold")
Sleep 2000
Subtitle("Double Roundness `nto radius 160", "t2000 x500 y500 w500 h500 cE5E1DE r160", "jCenter fVerdana s36 cDF7B39 Bold")
Sleep 2000
Subtitle("Double Roundness `nto radius 320", "t2000 x500 y500 w500 h500 cE5E1DE r320", "jCenter fVerdana s36 cDF7B39 Bold")
Sleep 2000
Subtitle("Oops, the radius `ncan't exceed `nhalf of the`nsmallest side.", "t2000 x500 y500 w500 h500 cE5E1DE r320", "jCenter fVerdana s36 cDF7B39 Bold")
Sleep 2000
Subtitle("Circle!`nradius: 250", "t2000 x500 y500 w500 h500 cE5E1DE r250", "jCenter fVerdana s36 cDF7B39 Bold")
Sleep 2000

Subtitle("x at 50%", "t2000 x50% y500 w500 h500 cE5E1DE r250", "jCenter fVerdana s36 cDF7B39 Bold")
Sleep 2000
Subtitle("y at 50%", "t2000 x50% y50% w500 h500 cE5E1DE r250", "jCenter fVerdana s36 cDF7B39 Bold")
Sleep 2000
Subtitle("Hmm... `nset x: center and `ny:center instead.", "t2000 x50% y50% w500 h500 cE5E1DE r250", "jCenter fVerdana s36 cDF7B39 Bold Italic")
Sleep 2000
Subtitle("There.", "t2000 xCenter yCenter w500 h500 cE5E1DE r250", "jCenter fVerdana s36 cDF7B39 Bold Italic")
Sleep 2000
Subtitle("Remove All Formatting.", "t2000")
Sleep 2000
Subtitle("Add 10% padding to the background field.`n(10% of A_ScreenHeight)", "t2000 p10%")
Sleep 2000
Subtitle("Justify Right.`n1`n2`n3", "t2000 p10%", "jRight")
Sleep 2000
Subtitle("Justify Center.`n1`n2`n3", "t2000 p10%", "jCenter")
Sleep 2000
Subtitle("Remove padding from the background field.`nAdd Margin to the text field (15% of Box Width)", "t2000 p10%", "jCenter m15%")
Sleep 2000
Subtitle("The margin will change because width and height are not set, and therefore will AutoSize to fix text.`n(15% of Box Width)", "t4000 p10%", "jCenter m15%")
Sleep 4000
Subtitle("The margin will change because width and height are not set, and therefore `nwill AutoSize to fix text.`n(15% of Box Width)", "t3000 p10%", "jCenter m15%")
Sleep 3000
Subtitle("The margin will change because width and height `nare not set, and therefore `nwill AutoSize to fix text.`n(15% of Box Width)", "t2000 p10%", "jCenter m15%")
Sleep 2000
Subtitle("Font: Segoe UI", "t3500 p10%", "jCenter m15% fSegoe UI")
Sleep 3500
Subtitle("Oops! That failed due to the space in Segoe UI", "t3500 p10%", "jCenter m15% fSegoe UI")
Sleep 3500

q:=Chr(34) ;quote character
Subtitle("Convert to object notation.`njCenter m15% fSegoe UI`n{" q "j" q ":" q "Center" q ", " q "margin" q ":" q "15%" q ", " q "font" q ":" q "Segoe UI" q "}", "t10000 p10%", {"j":"Center","margin":"15%","font":"Segoe UI"})
Sleep 10000
Subtitle("Set x coordinate of text to 100 pixels", "t2000 p10%", {"x":100, "j":"Center", "margin":"15%", "font":"Segoe UI", "color":"37C8AB"})
Sleep 2000
Subtitle("Set x coordinate of text to 200 pixels", "t2000 p10%", {"x":200, "j":"Center", "margin":"15%", "font":"Segoe UI", "color":"37C8AB"})
Sleep 2000
Subtitle("Set x coordinate of text to 300 pixels", "t2000 p10%", {"x":300, "j":"Center", "margin":"15%", "font":"Segoe UI", "color":"37C8AB"})
Sleep 2000
Subtitle("Setting width of text to 336 pixels...", "t2000 p10%", {"x":300, "justify":"Center", "margin":"15%", "font":"Segoe UI", "color":"37C8AB"})
Sleep 2000
Subtitle("Setting width of text to 336 pixels...", "t2000 p10%", {"x":300, "w":336, "justify":"Center", "margin":"15%", "font":"Segoe UI", "color":"37C8AB"})
Sleep 2000
Subtitle("Cut Off.", "t2000 p10%", {"x":300, "w":336, "justify":"Center", "margin":"15%", "font":"Segoe UI", "color":"37C8AB"})
Sleep 2000
Subtitle(howto, "x7.8% y13.9% cE5E1DE r20", "m50 fVerdana s18 c396786")

Esc:: ExitApp
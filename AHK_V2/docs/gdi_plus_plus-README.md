The `old_gdip_stuff` folder contains the old `gdip_all.ahk` and examples released by `mmikeww` (guest3456 on AHK forums).

I've also included the `gdip_all.ahk` created by `robodesign`, with many more GDI+ functions and a few more examples.

I have transcribed both these versions for AHK v2 beta.1, so I can't take credit for anything here.  Those parts is not my original work.

========================================================================

As for my lib, I have to give special thanks to several individuals whose work has helped me understand GDI/+ to a level where I was able to make my lib what it is now:

* [mention]tic[/mention] for the original [c]gdip.ahk[/c]
* [mention]Rseding91[/mention] for the original Unicode rewrite of tic's lib
* [mention]robodesign[/mention] who answered MANY of my questions about the concepts behind GDI+.  And for his work on his version of [c]Gdip_all.ahk[/c]
* [mention]guest3456[/mention] (mmikeww?) for the AHK v2 a108 rewrite [c]Gdip_all.ahk[/c] and examples.  I learned a lot from those.
I know a few others participated in this original project like [color=#00BFFF]just me[/color], and [mention]isahound[/mention]
* Thanks to [mention]GeekDude[/mention] for his work on [c]gdi.ahk[/c].  I referenced this old lib a lot and I will continue to do so.
* I have to thank [mention]just me[/mention] again for teaching me about structure byte alignment (way back when) which has got me to the point where I can understand much more of docs.microsoft.com documentation.
* And as always thanks to @lexikos for AHK v2, and for taking the time to answer some of my (occasionally malformed) questions.

========================================================================

Ok, I'll improve the documentation over time.  I just wanted to post this along with the old stuff to finally get it out there.

Just edit the pic_viewer.ahk to point to a pic of your choice (the bigger the better to get the full effect of how fast this is), and run the script.

Then resize the window, and see how smooth it is ;)

I'm working at understanding GDI more so I can implement regions, shapes, brushes, pens, etc.

Sorry for the short (and uninformative) intro.  Most of my efforts have been spent learning GDI.

Complete documentation, as well as more thorough credits, are in order and will happen.

If you want to drop me a line on AHK forums and let me know i missed someone who deserves credit, please do.
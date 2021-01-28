# #OpenCV 2.4 for AutoHotkey
![Preview](https://i.imgur.com/AXHuWvE.png)

# #How to use
```AutoHotkey
; Create OpenCV instance.
cv := new OpenCV()	
pImg := cv.LoadImage("2.png") ; Load IPL type image
cv.ShowImage("Preview", pImg) ; Display input image inside window
```
For general OpenCV capabilities check out the official OpenCV documentation:
> [OpenCV 2.4.13.6 documentation](https://docs.opencv.org/2.4.13.6/)

`Note:` Not all methods are translated to this AHK library.

# #Credits

[AutoIT Community](https://www.autoitscript.com/forum/topic/160732-opencv-udf/)
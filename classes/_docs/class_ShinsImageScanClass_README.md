# ShinsImageScanClass

ShinsImageScanClass is an AutoHotKey class designed for user freindliness and performance in mind, capable of searching for images and pixels extremely fast and also with background window support it's versatile and lightweight, with no additional dependancies. It also supports 32 and 64 bit.

# Youtube simple overview and examples

[![Video](https://img.youtube.com/vi/wIdcF6KUHIE/default.jpg)](https://www.youtube.com/watch?v=wIdcF6KUHIE)

## Functions
```ruby
#Image....................Find an image; Returns 1 on success and updates returnX and returnY variables; 0 otherwise
Image(image, variance=0, ByRef returnX=0, ByRef returnY=0, centerResults=1)

#ImageRegion..............Find an image in a specified region; Returns 1 on success and updates returnX and returnY variables; 0 otherwise
ImageRegion(image, x1, y1, w, h, variance=0, ByRef returnX=0, ByRef returnY=0, centerResults=1)

#ImageCount...............Find the amount of images; Returns count of images
ImageCount(image, variance=0)

#ImageCountRegion.........Find the amount of images in a specified region; Returns the count of images inside the region
ImageCountRegion(image, x1, y1, w, h, variance=0)

#ImageClosestToPoint......Finds the closest image to a given position; Returns 1 on success and updates returnX and returnY variables; 0 otherwise
ImageClosestToPoint(image, pointX, pointY, variance=0, byref returnX=0, byref returnY=0, centerResults=1, maxRadius=9999)

#ImageArray...............Finds all images; Returns 1 on success and updates the array variable to contain all image positions; 0 otherwise
ImageArray(image, byref array, variance=0, centerResults=1)

#ImageArrayRegion.........Finds all images in a specified region; Returns 1 on success and updates the array variable to contain all image positions; 0 otherwise
ImageArrayRegion(image, byref array, x1, y1, w, h, variance=0, centerResults=1)

#Pixel....................Find a pixel; Returns 1 on success and updates returnX and returnY variables; 0 otherwise
Pixel(color, variance=0, ByRef returnX=0, ByRef returnY=0)

#PixelRegion..............Find a pixel in a specified region; Returns 1 on success and updates returnX and returnY variables; 0 otherwise
PixelRegion(color, x1, y1, w, h, variance=0, byref returnX=0, byref returnY=0)

#PixelCount...............Finds the count of pixels; Returns the count of pixels
PixelCount(color, variance=0)

#PixelCountRegion.........Finds the count of pixels in a specified region; Returns the count of pixels in that region
PixelCountRegion(color, x1, y1, w, h, variance=0)

#PixelCountRadius.........Finds the count of pixels in a specified radius; Returns the count of pixels in that radius
PixelCountRadius(color, pointX, pointY, radius, variance=0)

#PixelPosition............Checks a pixel at a specified position; Returns 1 on color match; 0 otherwise
PixelPosition(color, pointX, pointY, variance=0)

#GetPixel.................Gets the pixel at a specified position; Returns pixel color on success; 0 otherwise
GetPixel(x, y)

#SaveImage................Save the current pixel buffer to a png image;
SaveImage(name)
```

## Notes

* Only for AHK_L, V2 is not supported

* When searching for images, using source files without transparency will generally be faster
* Searching for all images such as ImageCount() etc. will take significantly longer when using color variance; when possible try to avoid using color variance if speed is a concern

* I've only tested on my end and can confirm it works for me using 32/64 bit ahk L on windows 10
* if it doesn't work for you let me know, I may be able to help, or may not just depends.

#include <Gdip_All>

imageSearchc(byRef out1,byRef out2,x1,y1,x2,y2,image,vari=0,trans="",direction=5,debug=0){
    static ptok:=gdip_startup()
    imageB:=gdip_createBitmapFromFile(image)
    scrn:=gdip_bitmapfromscreen(x1 . "|" . y1 . "|" . x2 - x1 . "|" . y2 - y1)
    if(debug)
        gdip_saveBitmapToFile(scrn,a_now . ".png")
    errorlev:=gdip_imageSearch(scrn,imageB,tempxy,0,0,0,0,vari,trans,direction)
    gdip_disposeImage(scrn)
    gdip_disposeImage(imageB)

    if(errorlev){
        out:=strSplit(tempxy,"`,")
        out1:=out[1] + x1
        out2:=out[2] + y1
        return % errorlev
    }
    return 0
}
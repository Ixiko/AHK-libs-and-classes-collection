#Include %A_ScriptDir%\..\windows.ahk

BitmapDecoder := Windows.Graphics.Imaging.BitmapDecoder
BitmapEncoder := Windows.Graphics.Imaging.BitmapEncoder
SoftwareBitmap := Windows.Graphics.Imaging.SoftwareBitmap
StorageFile := Windows.Storage.StorageFile
FaceDetector := Windows.Media.FaceAnalysis.FaceDetector

maxheight := 2000
fd := FaceDetector.CreateAsync().await()
sbpf := FaceDetector.GetSupportedBitmapPixelFormats()
pic := A_ScriptDir '\lena.png'
fl := StorageFile.GetFileFromPathAsync(pic).await()
stream := fl.OpenAsync('ReadWrite').await()
bd := BitmapDecoder.CreateAsync(stream).await()
frame := bd.GetFrameAsync(0).await()
width := frame.PixelWidth
height := frame.PixelHeight
if height > maxheight {
    be := BitmapEncoder.CreateForTranscodingAsync(stream, bd).await()
    be.BitmapTransform.ScaledWidth := Floor(maxheight/height*width)
    be.BitmapTransform.ScaledHeight := maxheight
    sb := bd.GetSoftwareBitmapAsync(frame.BitmapPixelFormat, 0, be.BitmapTransform, 0, 0).await()
} else
    sb := bd.GetSoftwareBitmapAsync().await()
fbpf := frame.BitmapPixelFormat
if !sbpf.IndexOf(fbpf, &t)
    sb := SoftwareBitmap.Convert(sb, 'Gray8')
dfls := fd.DetectFacesAsync(sb).await()

for bx in dfls {
	bx := bx.FaceBox
    MsgBox 'x:' bx.X ' y:' bx.Y ' w:' bx.Width ' h:' bx.Height
}
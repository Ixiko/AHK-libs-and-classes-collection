
BMPWidth(ByRef bmpdata) {
  return NumGet(bmpdata, 18, "UInt")
}

BMPHeight(ByRef bmpdata) {
  return NumGet(bmpdata, 22 "UInt")
}

BMPBpp(ByRef bmpdata) {
  return NumGet(bmpdata, 28, "UShort")
}

; load bitmap and do some basic sanity checking
BMPLoad(fname, ByRef bmpdata) {
  FileRead, bmpdata, %fname%
  bytes := VarSetCapacity(bmpdata)
  ; check magick number
  if (NumGet(bmpdata, 0, "UShort") != 0x4D42) {
    return "bad bmp file format"
  }
  ; check expected file size in header
  if (NumGet(bmpdata, 2, "UInt") != VarSetCapacity(bmpdata)) {
    return "file size in header doesn't match actual file size"
  }
  ; check bits per pixel is something we can handle (24 or 32)
  bpp := BMPBpp(bmpdata)
  if (bpp != 24 && bpp != 32) {
    return "only 24 and 32 bit bitmaps are supported at the moment"
  }
  ; check compression
  if (NumGet(bmpdata, 30, "UInt") != 0) {
    return "only uncompressed (compression=0 for 'BI_RGB') is supported"
  }
  ; check height is positive (can't handle negative heights at the moment)
  if (BMPHeight(bmpdata) < 0) {
    return "negative height"
  }
  ; all passed, return empty string for success
  return ""
}

BMPGetPixel(ByRef bmpdata, x, y) {
  bpp := BMPBpp(bmpdata)
  width := BMPWidth(bmpdata)
  height := BMPHeight(bmpdata)
  stride := (bpp*width + 7)//8 ; number of bytes needed to encode the pixel data
  stride := (stride + 3) // 4 * 4 ; round up to the next multiple of 4 bytes
  headersize := 54 ; standard header is 54 bytes when there is no palette
  pixelbytes := bpp//8
  rowoffs := (height-1-y)*stride
  pixoffs := x*pixelbytes
  ; bytes are BB GG RR XX, but when read into a UInt on a little-endian machine
  ; it turns into 0xXXRRGGBB, where least significant bits is the blue value.
  xRGB := NumGet(bmpdata, headersize+rowoffs+pixoffs, "UInt") ; read 4 bytes which may include junk
  return (xRGB & 0xFFFFFF) ; discard the high byte
}

BMPTransform(ByRef bmpdata, ByRef output, transpc=-1) {
  height := BMPHeight(bmpdata)
  width := BMPWidth(bmpdata)
  colorlist := ""
  runcount := 0
  ; count the number of occurrences of each color, and build a list of all colors that appear
  Loop, %height% {
    y := A_Index - 1
    lastcolor := -1
    lastcount := 0
    Loop, %width% {
      x := A_Index - 1
      pixrgb := BMPGetPixel(bmpdata, x, y)
      if (n%pixrgb%) {
        n%pixrgb% += 1
      }
      else { ; first occurrence of this color
        if (pixrgb != transpc) {
          colorlist .= pixrgb . "|"
        }
        n%pixrgb% := 1
        r%pixrgb% := ""
      }
      
      if (pixrgb == lastcolor) { ; continue existing RLE
        lastcount++
      }
      else {
        if (lastcount > 0) { ; end of RLE
          if (lastcolor != transpc) {
            runstart := x - lastcount
            r%lastcolor% .= runstart . " " . y . " " . lastcount . "|"
            runcount++
          }
        }
        lastcolor := pixrgb
        lastcount := 1
      }
    }
    if (lastcolor != transpc) {
      runstart := width - lastcount
      r%lastcolor% .= runstart . " " . y . " " . lastcount . "|"
      runcount++
    }
  }

  StringTrimRight, colorlist, colorlist, 1 ; chop off trailing pipe character
  
  ; build a newline-delimited list of colors with their respective counts
  ncolorlist := ""
  Loop, Parse, colorlist, |
  {
    Random, r4, 1000, 9999 ; random four-digit number
    ncolorlist .= n%A_LoopField% . r4 . " " . A_LoopField . "`n"
  }
  StringTrimRight, ncolorlist, ncolorlist, 1 ; chop off trailing newline
  
  ; sort the list of colors from rarest to most common.  equally common colors are in random order
  Sort, ncolorlist, N
 
  VarSetCapacity(output, 5 + runcount*6) ; 5 'header' bytes and each run consumes 6 bytes
  outbyte := 0
  NumPut(1, output, outbyte++, "UChar") ; magic number 1
  NumPut(width, output, outbyte++, "UChar") ; width
  NumPut(height, output, outbyte++, "UChar") ; height
  NumPut(runcount, output, outbyte, "UShort") ; number of runs (little endian format)
  outbyte += 2

  Loop, Parse, ncolorlist, `n
  {
    StringSplit, part, A_LoopField, %A_Space% ; part1 is the count (not used), part2 is the color
    
    ; output the runs for pixels matching the color
    matchcolor := part2
    StringTrimRight, r%matchcolor%, r%matchcolor%, 1 ; chop off trailing pipe character
    Loop, Parse, r%matchcolor%, |
    {
      StringSplit, xyc, A_LoopField, %A_Space%
      NumPut((matchcolor >> 16) & 255, output, outbyte++, "UChar") ; red
      NumPut((matchcolor >> 8) & 255, output, outbyte++, "UChar") ; green
      NumPut(matchcolor & 255, output, outbyte++, "UChar") ; blue
      NumPut(xyc1, output, outbyte++, "UChar") ; x coordinate of run start
      NumPut(xyc2, output, outbyte++, "UChar") ; y coordinate of run start
      NumPut(xyc3, output, outbyte++, "UChar") ; run length
    }
  }
  return outbyte ; should be 5+runcount*6
}

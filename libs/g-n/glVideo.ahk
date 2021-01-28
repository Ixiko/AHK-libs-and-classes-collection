glLoadVideo(texid, filename){

  static streamtypeVIDEO := asc("v") | (asc("i")<<8) | (asc("d")<<16) | (asc("s")<<24) ; "vids" as four-character-code (uint)

  static streamtypeAUDIO := asc("a") | (asc("u")<<8) | (asc("d")<<16) | (asc("s")<<24) ; "auds" as four-character-code (uint)

  if (!texid+0)

    return 0

  glDeleteVideo(texid)

  result := 0

  DllCall("LoadLibrary", "str", "avifil32")

  DllCall("LoadLibrary", "str", "msvfw32")

  DllCall("LoadLibrary", "str", "winmm")

  DllCall("avifil32\AVIFileInit")

  if (DllCall("avifil32\AVIFileOpenW", "ptr*", pAviFile, "str", filename, "uint", 0, "ptr", 0)!=0)

    return 0

  if (DllCall("avifil32\AVIFileGetStream", "ptr", pAviFile, "ptr*", pVideoStream, "uint", streamtypeVIDEO, "int", 0, "ptr", 0)!=0)

  {

    DllCall("avifil32\AVIFileRelease", "ptr", pAviFile)

    return 0

  }

  VarSetCapacity(streaminfo, 204, 0)

  DllCall("avifil32\AVIStreamInfoW", "ptr", pVideoStream, "ptr", &streaminfo, "int", 204)

  width := NumGet(streaminfo, 60, "int")-NumGet(streaminfo, 52, "int")

  height := NumGet(streaminfo, 64, "int")-NumGet(streaminfo, 56, "int")

  length := NumGet(streaminfo, 32, "uint")

  timing := DllCall("avifil32\AVIStreamSampleToTime", "ptr", pVideoStream, "int", length)/length

  if (!(pFrames := DllCall("avifil32\AVIStreamGetFrameOpen", "ptr", pVideoStream, "ptr", 1, "ptr")))

  {

    DllCall("avifil32\AVIStreamRelease", "ptr", pVideoStream)

    DllCall("avifil32\AVIFileRelease", "ptr", pAviFile)

    return 0

  }

  DllCall("avifil32\AVIFileGetStream", "ptr", pAviFile, "ptr*", pAudioStream, "uint", streamtypeAUDIO, "int", 0, "ptr", 0)

  _glVideo(texid, {file:pAviFile, width:width, height:height, pos:0, length:length, start:0, timing:timing, videostream:pVideoStream, frames:pFrames, audiostream:pAudioStream})

  DllCall("opengl32\glBindTexture", "uint", 0x0DE1, "uint", texid)

  DllCall("opengl32\glTexParameteri", "uint", 0x0DE1, "uint", 0x2801, "uint", 0x2601)

  DllCall("opengl32\glTexParameteri", "uint", 0x0DE1, "uint", 0x2800, "uint", 0x2601)

  DllCall("opengl32\glTexImage2D", "uint", 0x0DE1, "int", 0, "int", 4, "int", 512, "int", 512, "int", 0, "uint", 0x80E1, "uint", 0x1401, "ptr", 0)

  return texid

}

glDeleteVideo(texid){

  if (!texid+0)

    return 0

  if (!(vid := _glVideo(texid)))

    return 1

  glVideoDeleteAudio(texid)

  DllCall("avifil32\AVIStreamGetFrameClose", "ptr", vid.frames)

  DllCall("avifil32\AVIStreamRelease", "ptr", vid.videostream)

  DllCall("avifil32\AVIStreamRelease", "ptr", vid.audiostream)

    DllCall("avifil32\AVIFileRelease", "ptr", vid.file)

  DllCall("opengl32\glBindTexture", "uint", 0x0DE1, "uint", texid)

  DllCall("opengl32\glTexImage2D", "uint", 0x0DE1, "int", 0, "int", 4, "int", 512, "int", 512, "int", 0, "uint", 0x80E1, "uint", 0x1401, "ptr", 0)

  _glVideo(texid, 0, 1)

  return 1

}

glCleanupVideos(){

  for, i, vid in _glVideo(0)

    glDeleteVideo(i)

}

glVideoGrabFrame(texid, frame){

  static init := 0, hDC, hDD, hBitmap, data

  if (!init)

  {

    DllCall("LoadLibrary", "str", "msvfw32")

    hDC := DllCall("CreateCompatibleDC", "ptr", 0, "ptr")

    hDD := DllCall("msvfw32\DrawDibOpen", "ptr")

    VarSetCapacity(bminfo, 40, 0)

    NumPut(40, bminfo, 0, "uint")

    NumPut(512, bminfo, 4, "uint")

    NumPut(512, bminfo, 8, "uint")

    NumPut(1, bminfo, 12, "ushort")

    NumPut(24, bminfo, 14, "ushort")

    hBitmap := DllCall("CreateDIBSection", "ptr", hDC, "ptr", &bminfo, "uint", 0, "ptr*", data, "ptr", 0, "uint", 0, "ptr")

    DllCall("DeleteObject", "ptr", DllCall("SelectObject", "ptr", hDC, "ptr", hBitmap, "ptr"))

    init := 1

  }

  if (!(vid := _glVideo(texid)))

    return 0

  if (frame>vid.length)

    return 0

  w := vid.width

  h := vid.height

  if (!(lpbi := DllCall("avifil32\AVIStreamGetFrame", "ptr", vid.frames, "int", frame, "ptr")))

    return 0

  bits := lpbi+NumGet(lpbi+0, 0, "uint")+NumGet(lpbi+0, 32, "uint")*4

  if (!DllCall("msvfw32\DrawDibDraw", "ptr", hDD, "ptr", hDC, "int", 0, "int", 0, "int", 512, "int", 512, "ptr", lpbi, "ptr", bits, "int", 0, "int", 0, "int", w, "int", h, "uint", 0))

    return 0

  DllCall("opengl32\glBindTexture", "uint", 0x0DE1, "uint", texid)

  DllCall("opengl32\glTexImage2D", "uint", 0x0DE1, "int", 0, "int", 3, "int", 512, "int", 512, "int", 0, "uint", 0x80E0, "uint", 0x1401, "ptr", data)

  return texid

}

glVideoGrab(texid, time){

  if (!(vid := _glVideo(texid)))

    return 0

  return glVideoGrabFrame(texid, round(time/vid.timing))

}

glVideoGrabAudioPos(texid){

  if (!(vid := _glVideo(texid)))

    return 0

  if ((pos := glVideoGetAudioPos(texid))=-1)

    return 0

  return glVideoGrabFrame(texid, round(pos*vid.length))

}

glVideoPlayAudio(texid, volume=1.0){

  if (!(vid := _glVideo(texid)) || !vid.audiostream)

    return 0

  VarSetCapacity(streaminfo, 204, 0)

  DllCall("avifil32\AVIStreamInfoW", "ptr", vid.audiostream, "ptr", &streaminfo, "int", 204)

  start := NumGet(streaminfo, 28, "uint")

  length := NumGet(streaminfo, 32, "uint")

  samplesize := NumGet(streaminfo, 48, "uint")

  VarSetCapacity(bformatsize, 4, 0)

  if (DllCall("avifil32\AVIStreamReadFormat", "ptr", vid.audiostream, "int", start, "ptr", 0, "ptr", &bformatsize)!=0)

    return 0

  formatsize := NumGet(bformatsize, 0, "int")

  VarSetCapacity(bformat, formatsize, 0)

  if (DllCall("avifil32\AVIStreamReadFormat", "ptr", vid.audiostream, "int", start, "ptr", &bformat, "ptr", &bformatsize)!=0)

    return 0

  VarSetCapacity(bstreamsize, 4, 0)

  if (DllCall("avifil32\AVIStreamRead", "ptr", vid.audiostream, "int", start, "int", length, "ptr", 0, "int", 0, "ptr", &bstreamsize, "ptr", 0)!=0)

    return 0

  streamsize := NumGet(bstreamsize, 0, "int")

  VarSetCapacity(bstream, streamsize, 0)

  hAudioData := DllCall("GlobalAlloc", "uint", 0x2020, "ptr", streamsize, "ptr")

  if (DllCall("avifil32\AVIStreamRead", "ptr", vid.audiostream, "int", start, "int", length, "ptr", hAudioData, "int", streamsize, "ptr", 0, "ptr", 0)!=0)

    return 0

  if (DllCall("winmm\waveOutOpen", "ptr*", pWave, "int", -1, "ptr", &bformat, "ptr", 0, "ptr", 0, "uint", 0)!=0)

    return 0

  vid.wave := pWave

  vid.audiodatasize := streamsize

  vid.audiodata := hAudioData

  vid.audiosamplesize := samplesize

  vid.audiolength := length

  vid.audiostart := start

  _glVideo(texid, vid)

  glVideoVolume(texid, volume)

  VarSetCapacity(bwavehdr, 4*A_PtrSize+16, 0)

  NumPut(hAudioData, bwavehdr, 0, "ptr")

  NumPut(streamsize, bwavehdr, A_PtrSize, "uint")

  DllCall("winmm\waveOutPrepareHeader", "ptr", pWave, "ptr", &bwavehdr, "uint", 4*A_PtrSize+16)

  DllCall("winmm\waveOutWrite", "ptr", pWave, "ptr", &bwavehdr, "uint", 4*A_PtrSize+16)

  return texid

}

glVideoGetAudioPos(texid){

  if (!(vid := _glVideo(texid)) || !vid.wave)

    return 0

  VarSetCapacity(btime, 16, 0)

  NumPut(4, btime, 0, "uint")

  if (DllCall("winmm\waveOutGetPosition", "ptr", vid.wave, "ptr", &btime, "uint", 16)!=0)

    return -1

  return (vid.audiostart*vid.audiosamplesize+NumGet(btime, 4, "uint"))/vid.audiodatasize

}

glVideoDeleteAudio(texid){

  if (!(vid := _glVideo(texid)) || !vid.wave)

    return 0

  DllCall("winmm\waveOutReset", "ptr", vid.wave)

  r := (DllCall("winmm\waveOutClose", "ptr", vid.wave)=0) ? 1 : 0

  DllCall("GlobalFree", "ptr", vid.audiodata)

  return r

}

glVideoVolume(texid, volume){

  if (!(vid := _glVideo(texid)) || !vid.wave)

    return 0

  if (volume<0)

    volume := 0

  else if (volume>1)

    volume := 1

  return (DllCall("winmm\waveOutSetVolume", "ptr", vid.wave, "uint", volume*65535)=0) ? 1 : 0

}

_glVideo(texid, set=0, del=0){

  static vid := []

  if (!texid+0)

    return vid

  if (isobject(set))

    return vid[texid] := set

  if (del)

    vid.remove(texid)

  return vid[texid]

}
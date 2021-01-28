#include <DirectX\headers\_dsound.h>
;#include <GUI>

global IDirectSound, IDirectSoundBuffer

loadWAV(file_, formatcheck = True) 
{ 		
	file := FileOpen(file_, "r")
	VarSetCapacity(data, file.Length)
	file.RawRead(data, file.Length)
	file.close()
	
	loop, % file.Length
		{
			if strget(&data + A_index, 3, "CP0") = "fmt" 
				{
					index := A_index + 8
					break
				}	
		}	
		
	if not index
		return "File format must be .wav (PCM)"
	
	VarSetCapacity(wav, sizeof(WAVEFORMATEX))
	dllcall("RtlMoveMemory", ptr, &wav, ptr, &data + index, int, sizeof(WAVEFORMATEX))	
	WAVEFORMATEX[] := &wav		
	
	if 	WAVEFORMATEX.wFormatTag = 1
		WAVEFORMATEX.wFormatTag := WAVE_FORMAT_PCM	
	else 
		if formatcheck 
			return "WAV file must be on PCM format"	
		
	loop, % file.Length
		{
			if strget(&data + A_index, 4,"CP0") = "data" 
				{
					index := A_index
					break
				}	
		}
		
	data_size := numget(&data + index + 4, "int")	
	VarSetCapacity(wave_data, data_size)
	dllcall("RtlMoveMemory", ptr, &wave_data, ptr, &data + index + 8, int, data_size)		
		
	zeromem(DSBUFFERDESC)
	DSBUFFERDESC.dwSize := sizeof(DSBUFFERDESC)
	DSBUFFERDESC.dwFlags :=  DSBCAPS_CTRLDEFAULT  | DSBCAPS_LOCSOFTWARE | DSBCAPS_STICKYFOCUS | DSBCAPS_GLOBALFOCUS 
	DSBUFFERDESC.dwBufferBytes := data_size
	DSBUFFERDESC.lpwfxFormat := WAVEFORMATEX[] 
				  
	VarSetCapacity(psndbuff, 4)
	r := dllcall(IDirectSound.CreateSoundBuffer, uint, IDirectSound.p, uint, DSBUFFERDESC[], uint, &psndbuff, uint, 0, uint)
	if r		
		return r  " CreateSoundBuffer " dsound.result[r . ""]
	
	VarSetCapacity(plock, 4)
	VarSetCapacity(pLocksize, 4)
	sndbuff := new ComInterfaceWrapper(dsound.IDirectSoundBuffer, &psndbuff) 
	r := dllcall(sndbuff.Lock, uint, sndbuff.p, uint, 0, uint, data_size, uint, &plock
							 , uint, &plocksize, uint, 0, uint, 0, uint, DSBLOCK_ENTIREBUFFER, uint)
	if r		
		return r  " Lock " dsound.result[r . ""]
	
	dllcall("RtlMoveMemory", ptr, numget(&plock, "ptr"), ptr, &wave_data, int, data_size)
	
	VarSetCapacity(lock2, 4)
	r := dllcall(sndbuff.UnLock, uint, sndbuff.p, uint, numget(&plock, "ptr")
							   , int, data_size, uint, 0, uint, 0, uint)
	if r		
		return r  " Unlock " dsound.result[r . ""]
	
	wav := ""
	wave_data := ""
	zeromem(DSBUFFERDESC)
	
	return sndbuff			
}	

LoadRAWSoundData(byref PMEM, file_)
{
	critical
	zeromem(WAV_FILE_HEADER)
	
	file := FileOpen(file_, "r")	
	file.RawRead(WAV_FILE_HEADER[], WAV_FILE_HEADER.size())	
	
	;PMEM := DllCall("GlobalAlloc", "uint", 0x0040, "uint", WAV_FILE_HEADER.Subchunk2Size, ptr)
	PMEM := dllcall("VirtualAlloc", uint, 0, uint, WAV_FILE_HEADER.Subchunk2Size, Int, 0x00001000 ;| 0x00002000
								  , uint, (PAGE_READWRITE := 0x04) )
	
	file.RawRead(PMEM+0, WAV_FILE_HEADER.Subchunk2Size)	
	
	file.close()
	
	return WAV_FILE_HEADER.Subchunk2Size
}	

dumpSndBuffer(pSndBuff, locksize, file)
{
	critical
	r := dllcall(IDirectSoundBuffer.GetFormat, uint, pSndBuff, uint, 0, uint, 0, "uint*", size, uint)
	;print("GetBufferSize " r "-" dsound.result[r . ""] "size: "  size "`n")
	
	varsetcapacity(wave_format, size)
	r := dllcall(IDirectSoundBuffer.GetFormat, uint, pSndBuff, uint, &wave_format, uint, size, "uint*", writen, uint)
	;print("GetBufferFormat " r "-" dsound.result[r . ""] "`n")
	
	WAVEFORMATEX[] := &wave_format	
			
	r := dllcall(IDirectSoundBuffer.Lock, uint, pSndBuff, uint, 0, uint, locksize, "uint*", plock
							            , "uint*", plocksize, uint, 0, uint, 0, uint, DSBLOCK_ENTIREBUFFER, uint)
	;print("Lock " r "-" dsound.result[r . ""] "`n")
		
	zeromem(WAV_FILE_HEADER)
	WAV_FILE_HEADER.ChunkID := 1179011410
	WAV_FILE_HEADER.ChunkSize := plocksize + WAV_FILE_HEADER.size() - 8
	WAV_FILE_HEADER.Format := 1163280727
	WAV_FILE_HEADER.Subchunk1ID := 544501094
	WAV_FILE_HEADER.Subchunk1Size := 16
	WAV_FILE_HEADER.AudioFormat := 1
	WAV_FILE_HEADER.NumChannels := WAVEFORMATEX.nChannels
	WAV_FILE_HEADER.SampleRate := WAVEFORMATEX.nSamplesPerSec
	WAV_FILE_HEADER.ByteRate := WAVEFORMATEX.nAvgBytesPerSec
	WAV_FILE_HEADER.BlockAlign := WAVEFORMATEX.nBlockAlign
	WAV_FILE_HEADER.BitsPerSample := WAVEFORMATEX.wBitsPerSample      
	WAV_FILE_HEADER.Subchunk2ID := 1635017060
	WAV_FILE_HEADER.Subchunk2Size := plocksize
			
	f := FileOpen(file, "w")
	f.RawWrite(WAV_FILE_HEADER[], WAV_FILE_HEADER.size())
	f.RawWrite(plock+0, plocksize)
	f.close()	
	
	r := dllcall(IDirectSoundBuffer.UnLock, uint, pSndBuff, uint, plock
							              , int, data_size, uint, 0, uint, 0, uint)
	print("dump UnLock " r "-" dsound.result[r . ""] "`n")
}	

getDirectSound(hwin = "")
{	
	if not hwin {
		h_win := A_scripthwnd ;ui_GetHidenWindowHandle()
		} else h_win := hwin			
	
		
	h_dsound := dllcall("LoadLibrary", "str", "dsound.dll")
	pdirectsoundcreate := dllcall("GetProcAddress", "int", h_dsound, "astr", "DirectSoundCreate")	
	if not h_dsound or not pdirectsoundcreate
		return "Failed to load or get the entrypoint(dsound.dll) " A_lasterror

	VarSetCapacity(psound, 4)
	r := dllcall(pdirectsoundcreate, uint, 0, uint, &psound, uint, 0, Uint) 
	if r
		return "Failed to create the IDirectSound interface " r  " - " dsound.result[r . ""]
	
	else IDirectSound := new ComInterfaceWrapper(dsound.IDirectSound, &psound)
		
	r :=  dllcall(IDirectSound.SetCooperativeLevel, uint, IDirectSound.p, uint, h_win, uint, DSSCL_PRIORITY, uint)	
	if r
		return "Failed to set the DirectSound cooperative level " r  " - " dsound.result[r . ""]
	
	zeromem(DSBUFFERDESC)	
	DSBUFFERDESC.dwSize := sizeof(DSBUFFERDESC)
	DSBUFFERDESC.dwFlags := DSBCAPS_PRIMARYBUFFER 
	DSBUFFERDESC.dwBufferBytes := 0 
	DSBUFFERDESC.lpwfxFormat := 0 	
	
	VarSetCapacity(psndbuff, 4)
	r := dllcall(IDirectSound.CreateSoundBuffer, uint, IDirectSound.p, uint, DSBUFFERDESC[], uint, &psndbuff, uint, 0, uint)
	if r
		return "Failed to create the IDirectSoundBuffer interface " r  " - " dsound.result[r . ""]
	
	else IDirectSoundBuffer := new ComInterfaceWrapper(dsound.IDirectSoundBuffer, &psndbuff) 	
		
	return "Succeeded to create the DirectSound interfaces"
}
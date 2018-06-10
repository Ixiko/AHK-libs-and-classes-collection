#include <DirectX\headers\dsound.h>

dsound.result[2147942487 . ""] := "DSERR_INVALIDPARAMS"
dsound.result[0 . ""] := "DSERR_OK"

global WAVE_FORMAT_ADPCM := 0x0002
global WAVE_FORMAT_PCM := 0x0001
global WAVEFORMATEX := Struct("WORD wFormatTag, WORD nChannels, DWORD nSamplesPerSec, DWORD nAvgBytesPerSec, WORD nBlockAlign,"
			                     . "WORD wBitsPerSample, WORD cbSize") 
global DSBUFFERDESC := Struct("DWORD dwSize; DWORD dwFlags; DWORD dwBufferBytes; DWORD dwReserved; ptr lpwfxFormat")
global DSBCAPS := Struct("DWORD dwSize, DWORD dwFlags, DWORD dwBufferBytes, DWORD dwUnlockTransferRate, DWORD dwPlayCpuOverhead")

global WAV_FILE_HEADER := 
(
"
DWORD ChunkID;
DWORD ChunkSize;
DWORD Format;
DWORD Subchunk1ID;
DWORD Subchunk1Size;
WORD AudioFormat;
WORD NumChannels;
DWORD SampleRate;
DWORD ByteRate;
WORD BlockAlign;
WORD BitsPerSample;        
DWORD Subchunk2ID;
DWORD Subchunk2Size;
"
)
global WAV_FILE_HEADER := Struct(WAV_FILE_HEADER)
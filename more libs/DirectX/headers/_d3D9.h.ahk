#include <DirectX\Headers\d3D9.h>
#include <DirectX\Headers\d3DTypes.h>

d3D9.result[0 . ""] := "D3DERR_OK"

D3DPRESENT_PARAMETERS :=
(
"
  UINT                BackBufferWidth;
  UINT                BackBufferHeight;
  int                 BackBufferFormat;
  UINT                BackBufferCount;
  int                 MultiSampleType;
  DWORD               MultiSampleQuality;
  int                 SwapEffect;
  HWND                hDeviceWindow;
  BOOL                Windowed;
  BOOL                EnableAutoDepthStencil;
  int                 AutoDepthStencilFormat;
  DWORD               Flags;
  UINT                FullScreen_RefreshRateInHz;
  UINT                PresentationInterval;
" 
)

global D3DPRESENT_PARAMETERS := Struct(D3DPRESENT_PARAMETERS)
global D3DLOCKED_RECT := Struct("INT Pitch; uint pBits;")



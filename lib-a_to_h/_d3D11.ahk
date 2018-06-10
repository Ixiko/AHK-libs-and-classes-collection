#include <DirectX\Headers\d3D11.h>

global D3D11_USAGE_DYNAMIC  := 2

D3D11_BUFFER_DESC :=
(
"
  UINT        ByteWidth;
  UINT        Usage;
  UINT        BindFlags;
  UINT        CPUAccessFlags;
  UINT        MiscFlags;
  UINT        StructureByteStride;
"
)

D3D11_SUBRESOURCE_DATA :=
(
"
  ptr        pSysMem;
  UINT       SysMemPitch;
  UINT       SysMemSlicePitch;
"
)

D3D11_BUFFEREX_SRV :=
(
"
  UINT FirstElement;
  UINT NumElements;
  UINT Flags;
"
)

D3D11_SHADER_RESOURCE_VIEW_DESC :=
(
"
  int                     Format;
  int                     ViewDimension;
  D3D11_BUFFEREX_SRV      BufferEx;  
"  
)

D3D11_BUFFER_UAV :=
(
" 
  UINT FirstElement;
  UINT NumElements;
  UINT Flags;
"
)

D3D11_UNORDERED_ACCESS_VIEW_DESC :=
(
"
  int                   Format;
  int                   ViewDimension;
  D3D11_BUFFER_UAV      Buffer;
"
)

global D3D11_BUFFER_DESC := Struct(D3D11_BUFFER_DESC)
global D3D11_SUBRESOURCE_DATA := Struct(D3D11_SUBRESOURCE_DATA)
global D3D11_SHADER_RESOURCE_VIEW_DESC := Struct(D3D11_SHADER_RESOURCE_VIEW_DESC)
global D3D11_BUFFEREX_SRV := Struct(D3D11_BUFFEREX_SRV)
global D3D11_UNORDERED_ACCESS_VIEW_DESC := Struct(D3D11_UNORDERED_ACCESS_VIEW_DESC)
global D3D11_BUFFER_UAV := Struct(D3D11_BUFFER_UAV)

#include <DirectX\Headers\_d3D11>
#include <DirectX\Headers\d3DX9>

global IDirect3DDevice11, ID3D11DeviceContext, ID3D11Buffer, ID3D11ComputeShader

getDirect3D11()
{
	static D3D_DRIVER_TYPE_HARDWARE := 1 
	static D3D_FEATURE_LEVEL_10_1 := 0xa100
	
	static feature_levels := {"0x9100" : "D3D_FEATURE_LEVEL_9_1"
    , "37376" : "D3D_FEATURE_LEVEL_9_2"
    , "37632" : "D3D_FEATURE_LEVEL_9_3"
    , "40960" : "D3D_FEATURE_LEVEL_10_0"
    , "41216" : "D3D_FEATURE_LEVEL_10_1"
    , "45056" : "D3D_FEATURE_LEVEL_11_0"
    , "45312" : "D3D_FEATURE_LEVEL_11_1"}

	dllcall("GetModuleHandle", str, "D3D11.dll") ?: dllcall("LoadLibraryW", str, "D3D11.dll")
	
	r := dllcall("D3D11.dll\D3D11CreateDevice"
	, uint, 0
	, uint, D3D_DRIVER_TYPE_HARDWARE
	, uint, 0
	, uint, 0
	, uint, 0
	, uint, 0
	, uint, D3D11_SDK_VERSION
	, "uint*", pD3D11
	, "uint*", feature_level
	, "uint*", pD3D11_DC)
			
	if r 
		return "Failed to create the Direct3D11 device"			
	else {
	IDirect3DDevice11 := new ComInterfaceWrapper(D3D11.ID3D11Device, pD3D11, True)
	ID3D11DeviceContext := new ComInterfaceWrapper(D3D11.ID3D11DeviceContext, pD3D11_DC, True)	
	IDirect3DDevice11.level := feature_levels[feature_level . ""] 
	}
	
	r := createBuffer11(pBuffer, 16) 
	if r 
		return "Failed to create the ID3D11Buffer interface"	
	else ID3D11Buffer := new ComInterfaceWrapper(D3D11.ID3D11Buffer, pBuffer, True)		
	
	shaderCode := "[numthreads(32, 24, 1)]`n"
	. "void CSMain( uint3 dispatchThreadID : SV_DispatchThreadID )`n"
	. "{return;}"	
    r := compileShader11(pShader, IDirect3DDevice11.p, shaderCode, "CSMain")
	if r	
		return "Failed to create the ID3D11ComputeShader interface`n" r
	else ID3D11ComputeShader := new ComInterfaceWrapper(D3D11.ID3D11ComputeShader, pShader, True)
	
	return "Succeded to creat the Direct3D11 device with feature level " IDirect3DDevice11.level 
}	

createBuffer11(byref pBuffer, size, pData = 0, stride = 4, STAGING = False)
{
	static D3D11_BIND_UNORDERED_ACCESS := 0x80
	static D3D11_BIND_SHADER_RESOURCE := 0x08
	static D3D11_RESOURCE_MISC_BUFFER_STRUCTURED := 0x40
	static D3D11_CPU_ACCESS_READ := 0x20000	
	static D3D11_USAGE_STAGING := 3
			
	D3D11_BUFFER_DESC.ByteWidth := size
	D3D11_BUFFER_DESC.StructureByteStride := stride
	D3D11_BUFFER_DESC.Usage := STAGING ? D3D11_USAGE_STAGING : 0
	D3D11_BUFFER_DESC.CPUAccessFlags := STAGING ? D3D11_CPU_ACCESS_READ : 0 
	D3D11_BUFFER_DESC.BindFlags := STAGING ? 0 : D3D11_BIND_UNORDERED_ACCESS | D3D11_BIND_SHADER_RESOURCE  
	D3D11_BUFFER_DESC.MiscFlags := STAGING ? 0 : D3D11_RESOURCE_MISC_BUFFER_STRUCTURED        
	D3D11_SUBRESOURCE_DATA.pSysMem := pData		
			
	return dllcall(IDirect3DDevice11.CreateBuffer, uint, IDirect3DDevice11.p, uint, D3D11_BUFFER_DESC[]
	, uint, (pData > 0) & True ? D3D11_SUBRESOURCE_DATA[] : 0, "uint*", pBuffer, uint) 
}	

compileShaderFromFile11(byref pShader, pDevice, file, entrypoint = "main", pTarget  = "cs_4_1")
{
	hdll := dllcall("GetModuleHandle", "str", "D3DCompiler_47.dll")
	hdll ?: hdll := dllcall("LoadLibraryW", "str", "D3DCompiler_47.dll")
	D3DCompileFromFile := dllcall("GetProcAddress", uint, hdll, astr, "D3DCompileFromFile") 
	
	r := dllcall(D3DCompileFromFile
	, str, file
	, uint, 0
	, uint, 0
	, astr, entrypoint
	, astr, pTarget 
	, uint, 0
	, uint, 0
	, "uint*", pShader
	, "uint*", pError
	, uint)	
	
	use := r ? pError : pShader
	
	if not ID3DXBuffer
		ID3DXBuffer := new ComInterfaceWrapper(D3DX9Mesh.ID3DXBuffer, use, True)
	else ID3DXBuffer.p := use
		
		
	_ptr := dllcall(ID3DXBuffer.GetBufferPointer, uint, ID3DXBuffer.p)	
	size := dllcall(ID3DXBuffer.GetBufferSize, uint, ID3DXBuffer.p)		
	
	if r 
	{
		rr := strget(_ptr+0, size, "CP0")
		ID3DXBuffer.__release()
		return rr
	}	
		
	else
	{
		r := dllcall(IDirect3DDevice11.CreateComputeShader, uint, pDevice, uint, _ptr, uint, size, uint, 0, "uint*", pShader)
		ID3DXBuffer.__release()
		return r 
	}	
}

compileShader11(byref pShader, pDevice, ShaderCode, entrypoint = "main", pTarget  = "cs_4_1")
{
	hdll := dllcall("GetModuleHandle", "str", "D3DCompiler_47.dll")
	hdll ?: hdll := dllcall("LoadLibraryW", "str", "D3DCompiler_47.dll")
	D3DCompile := dllcall("GetProcAddress", uint, hdll, astr, "D3DCompile") 
	
	r := dllcall(D3DCompile
	, astr, ShaderCode
	, uint, strlen(ShaderCode) 
	, uint, 0
	, uint, 0
	, uint, 0
	, astr, entrypoint
	, astr, pTarget 
	, uint, 0
	, uint, 0
	, "uint*", pShader
	, "uint*", pError
	, uint)	
	
	use := r ? pError : pShader
		
	if not ID3DXBuffer
		ID3DXBuffer := new ComInterfaceWrapper(D3DX9Mesh.ID3DXBuffer, use, True)
	else ID3DXBuffer.p := use			
		
	_ptr := dllcall(ID3DXBuffer.GetBufferPointer, uint, ID3DXBuffer.p)	
	size := dllcall(ID3DXBuffer.GetBufferSize, uint, ID3DXBuffer.p)		
	
	if r 
	{
		rr := strget(_ptr+0, size, "CP0")
		ID3DXBuffer.__release()
		return rr
	}	
		
	else
	{
		r := dllcall(IDirect3DDevice11.CreateComputeShader, uint, pDevice, uint, _ptr, uint, size, uint, 0, "uint*", pShader)
		ID3DXBuffer.__release()
		return r 
	}	
}	
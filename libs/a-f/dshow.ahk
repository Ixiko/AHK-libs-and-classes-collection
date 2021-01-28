#include <DirectX\headers\_dshow>

global IGraphBuilder, IVideoWindow
getDirectShow()
{
	pIGraphBuilder := ComObjCreate(dshow.CLSID_FilterGraph, dshow.IID_IGraphBuilder)
	if not pIGraphBuilder
		return "Failed to create the IGraphBuilder interface"
	IGraphBuilder := new ComInterfaceWrapper(dshow.IGraphBuilder, pIGraphBuilder, True)	
	
	GUID_FromString(idd_VideoWindow, dshow.IID_IVideoWindow)
	r := dllcall(IGraphBuilder.QueryInterface, uint, pIGraphBuilder, uint, &idd_VideoWindow, "uint*", pVidwin)
	if r 
		return "Failed to create the IVideoWindow interface"
	IVideoWindow := new ComInterfaceWrapper(dshow.IVideoWindow, pVidwin, True)	
	
	return "Succedeed to create the DirectShow interfaces"
}	
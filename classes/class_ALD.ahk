class ALD
{
	static NamespaceURI := "ald://package/schema/2012"

	#include class_ALD.DefinitionGenerator.ahk
	#include class_ALD.PackageGenerator.ahk
	#include class_ALD.Connection.ahk
}
#include %A_ScriptDir%\..\lib-i_to_z\Zip.ahk
#include %A_ScriptDir%\..\lib-a_to_h\HttpRequest.ahk
#include %A_ScriptDir%\..\lib-a_to_h\Base64.ahk
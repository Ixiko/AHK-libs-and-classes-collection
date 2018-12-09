/*
class: EDataFlow
an enumeration class containing constants that indicate the direction in which audio data flows between an audio endpoint device and an application.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lpgl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/EDataFlow)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/dd370828)

Requirements:
	AutoHotkey - AHK v2 alpha
	OS - Windows Vista / Windows Server 2008 or higher
*/
class EDataFlow
{
	/*
	Field: eRender
	Audio rendering stream. Audio data flows from the application to the audio endpoint device, which renders the stream.
	*/
	static eRender := 0

	/*
	Field: eCapture
	Audio capture stream. Audio data flows from the audio endpoint device that captures the stream, to the application.
	*/
	static eCapture := 1

	/*
	Field: eAll
	Audio rendering or capture stream. Audio data can flow either from the application to the audio endpoint device, or from the audio endpoint device to the application.
	*/
	static eAll := 2

	/*
	Field: EDataFlow_enum_count
	The number of members in the EDataFlow enumeration (not counting the EDataFlow_enum_count member).
	*/
	static EDataFlow_enum_count := 3
}
/*
class: ERole
an enumeration class containing constants that indicate the role that the system has assigned to an audio endpoint device.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lpgl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/ERole)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/dd370842)

Requirements:
	AutoHotkey - AHK v2 alpha
	OS - Windows Vista / Windows Server 2008 or higher
*/
class ERole
{
	/*
	Field: eConsole
	Games, system notification sounds, and voice commands.
	*/
	static eConsole := 0

	/*
	Field: eMultimedia
	Music, movies, narration, and live music recording.
	*/
	static eMultimedia := 1

	/*
	Field: eCommunications
	Voice communications (talking to another person).
	*/
	static eCommunications := 2

	/*
	Field: ERole_enum_count
	The number of members in the ERole enumeration (not counting the ERole_enum_count member).
	*/
	static ERole_enum_count := 3
}
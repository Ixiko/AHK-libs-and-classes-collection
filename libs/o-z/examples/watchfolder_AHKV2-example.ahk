hotkey 'esc', (*) => exitapp()

#include watch_folder.ahk
watch_folder_until_exit(
	dir,
	dwNotifyFilter,
	callback,
	bWatchSubtree := true ) {
	; Watches the folder dir until the program exists.
	; See watch_folder for parameter description.
	; You should avoid calling exitapp from the callback function.
	stop_func := watch_folder(dir, dwNotifyFilter, callback, bWatchSubtree)
	
	onexit 'try_stop'
	
	try_stop(*) {
		local e
		try
			%stop_func%()
		catch e
			msgbox 'Failed to stop watching folder:`n' . dir
	}
}

FILE_NOTIFY_CHANGE_FILE_NAME	:= 0x1
FILE_NOTIFY_CHANGE_DIR_NAME		:= 0x2
FILE_NOTIFY_CHANGE_ATTRIBUTES	:= 0x4
FILE_NOTIFY_CHANGE_SIZE			:= 0x8

filter := FILE_NOTIFY_CHANGE_FILE_NAME
		| FILE_NOTIFY_CHANGE_DIR_NAME
		| FILE_NOTIFY_CHANGE_ATTRIBUTES
		| FILE_NOTIFY_CHANGE_SIZE

watch_folder_until_exit a_scriptdir, filter, ( result )
	=> msgbox(
		result.Name . '`n'
	.  	["Added", "Removed", "Modified", "Renamed, old name", "Renamed, new name"][ result.EventType ] ; taken from teadrinker.
	)
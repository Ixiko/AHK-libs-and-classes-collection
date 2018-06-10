#NoEnv 
#persistent  
#notrayicon  
#KeyHistory 0
ListLines Off
SetBatchLines, -1

#include <ahkhook\ahkhook>
#include <DirectX\Lib\lib>
#include <DirectX\lib\FileHooks>

global g_globals := parseConfig()
config := "AHK Injector remote settings:`n"
for k, v in g_globals.config
	config .= A_tab k ": " v "`n"
logErr(g_globals.config.error_log "|100")
logerr(config)
;logerr(A_workingdir)
;logerr("CommandLine:`n" dllcall("GetCommandLine", str))
if g_globals.config.mods or g_globals.config.saves or g_globals.config["/saves"] or g_globals.config["saves/"] 
	initFileHooks(g_globals.config.mods)



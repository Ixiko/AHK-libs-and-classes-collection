Class PowerPlanManager
{
	SetBalancedPlan()
	{
		VarSetCapacity(guid,szguid := 16)
		VarSetCapacity(desc, szdesc := 1024)
		Dllcall("powrprof.dll\PowerEnumerate", "ptr", 0, "ptr", 0, "ptr", 0, "uint", 16, "uint", PlanIndex, "ptr", &guid, "uint*", 16)
		r := Dllcall("powrprof.dll\PowerSetActiveScheme", "ptr", 0, "ptr", &guid)
		if r
			Msgbox % "PowerSetActiveScheme error: " r
		r2 := Dllcall("powrprof.dll\PowerReadFriendlyName", "ptr", 0, "ptr", &guid, "ptr", 0, "ptr", 0, "str", desc, "uint*", 1024)
		UI.ShowText("Power Plan - Balanced", 2000)
	}
	
	SetHighPerformancePlan()
	{
		Run powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c, , Hide
		UI.ShowText("Power Plan - High Performance", 2000)
	}
			
	SetPowerSaverPlan()
	{
		Run powercfg -setactive a1841308-3541-4fab-bc81-f71556f20b4a, , Hide
		UI.ShowText("Power Plan - Power Saver", 2000)
	}
	
}

;;;; Power Scheme GUID 381b4222-f694-41f0-9685-ff5bb260df2e  (Balanced)
;;;; Power Scheme GUID 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c  (High performance)
;;;; Power Scheme GUID a1841308-3541-4fab-bc81-f71556f20b4a  (Power saver)
;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;  PixelState Map
;;;;;;;;;;;;;;;;;;;;;;;;;
PixelMap := {"settings": {}}
PixelMap.settings.ARGBTolerance := 135000
PixelMap.settings.RGBTolerance := 10

;;  The PixelState configuration tool can be used to rapidly configure named pixels
;;  PixelState.PixelMapConfig(PixelName, x, y[, argb=false, RGBTolerance=false, ARGBTolerance=false])
;;;;  PixelName must be unique
;;;;  x,y can be Absolute or Relative positions (this config utilizes relative positions by default)
;;;;  argb can be false, an integer, or an array of integers (argb values)
;;;;  RGBTolerance allows pixel RGB values to be approximately +/- this value
;;;;  ARGBTolerance allows ARGB value to be +/- this value (150000 is a small number here)

;;  hp bar positions
PixelState.PixelMapConfig("hp_100p", 0.9835, 0.4250, [4292883508, 4292817715, 4292555314])
PixelState.PixelMapConfig("hp_95p", 0.9726, 0.4250, [4292883508, 4292817715, 4292555314])
PixelState.PixelMapConfig("hp_90p", 0.9618, 0.4250, [4292883508, 4292817715, 4292555314])
PixelState.PixelMapConfig("hp_85p", 0.9508, 0.4250, [4292883508, 4292817715, 4292555314])
PixelState.PixelMapConfig("hp_80p", 0.9400, 0.4250, [4292883508, 4292817715, 4292555314])
PixelState.PixelMapConfig("hp_75p", 0.9291, 0.4250, [4292883508, 4292817715, 4292555314])
PixelState.PixelMapConfig("hp_70p", 0.9181, 0.4250, [4292883508, 4292817715, 4292555314])
PixelState.PixelMapConfig("hp_65p", 0.9072, 0.4250, [4292883508, 4292817715, 4292555314])
PixelState.PixelMapConfig("hp_60p", 0.8965, 0.4250, [4292883508, 4292817715, 4292555314])
PixelState.PixelMapConfig("hp_55p", 0.8854, 0.4250, [4292883508, 4292817715, 4292555314])
PixelState.PixelMapConfig("hp_50p", 0.8748, 0.4250, [4292883508, 4292817715, 4292555314])
PixelState.PixelMapConfig("hp_45p", 0.8636, 0.4250, [4292883508, 4292817715, 4292555314])
PixelState.PixelMapConfig("hp_40p", 0.8527, 0.4250, [4292883508, 4292817715, 4292555314])
PixelState.PixelMapConfig("hp_35p", 0.8418, 0.4250, [4292883508, 4292817715, 4292555314])
PixelState.PixelMapConfig("hp_30p", 0.8309, 0.4250, [4292883508, 4292817715, 4292555314])
PixelState.PixelMapConfig("hp_25p", 0.8204, 0.4250, [4292883508, 4292817715, 4292555314])
PixelState.PixelMapConfig("hp_20p", 0.8091, 0.4250, [4292883508, 4292817715, 4292555314])
PixelState.PixelMapConfig("hp_15p", 0.7982, 0.4250, [4292883508, 4292817715, 4292555314])
PixelState.PixelMapConfig("hp_10p", 0.7873, 0.4250, [4292883508, 4292817715, 4292555314])
PixelState.PixelMapConfig("hp_5p", 0.7764, 0.4250, [4292883508, 4292817715, 4292555314])
PixelState.PixelMapConfig("hp_0p", 0.7660, 0.4250, [4292883508, 4292817715, 4292555314])

;;
;;  control points
;;  static points that are typically present

;;  chat box top line
PixelState.PixelMapConfig("chatbox_top1", 0.000, 0.9667, 4294967295)
PixelState.PixelMapConfig("chatbox_top2", 0.125, 0.9667, 4294967295)
PixelState.PixelMapConfig("chatbox_top3", 0.250, 0.9667, 4294967295)
PixelState.PixelMapConfig("chatbox_top4", 0.375, 0.9667, 4294967295)

;;  chat box bottom line
PixelState.PixelMapConfig("chatbox_bottom1", 0.000, 0.9963, 4294967295)
PixelState.PixelMapConfig("chatbox_bottom2", 0.125, 0.9963, 4294967295)
PixelState.PixelMapConfig("chatbox_bottom3", 0.250, 0.9963, 4294967295)
PixelState.PixelMapConfig("chatbox_bottom4", 0.375, 0.9963, 4294967295)

;;  chat box l/r sides
PixelState.PixelMapConfig("chatbox_side1", 0.0000, 0.9731, 4294967295)
PixelState.PixelMapConfig("chatbox_side2", 0.7474, 0.9731, 4294967295)

;;  chat box often obstructed pixels
PixelState.PixelMapConfig("chatbox_top6", 0.700, 0.9667, 4294967295)

;;  vertical black border separating the game from right column
PixelState.PixelMapConfig("controlpoint75_1", 0.7495, 0.050, 4278190081, 15)
PixelState.PixelMapConfig("controlpoint75_2", 0.7495, 0.200, 4278190081, 15)
PixelState.PixelMapConfig("controlpoint75_3", 0.7495, 0.300, 4278190081, 15)
PixelState.PixelMapConfig("controlpoint75_4", 0.7495, 0.400, 4278190081, 15)
PixelState.PixelMapConfig("controlpoint75_5", 0.7495, 0.500, 4278190081, 15)
PixelState.PixelMapConfig("controlpoint75_6", 0.7495, 0.600, 4278190081, 15)
PixelState.PixelMapConfig("controlpoint75_7", 0.7495, 0.700, 4278190081, 15)
PixelState.PixelMapConfig("controlpoint75_8", 0.7495, 0.800, 4278190081, 15)
PixelState.PixelMapConfig("controlpoint75_9", 0.7495, 0.900, 4278190081, 15)
PixelState.PixelMapConfig("controlpoint75_10", 0.7495, 0.950, 4278190081, 15)

;;
;;  ui sprites
;;  pixels for various ui elements

;;  account gold icon
PixelState.PixelMapConfig("account_gold1", 0.7099, 0.0333, [4292141824, 4292010240])
PixelState.PixelMapConfig("account_gold2", 0.7193, 0.0417, [4291483904, 4293194496])

;;  account star icon
PixelState.PixelMapConfig("account_star1", 0.0536, 0.0185, [4287207389, 4281355482, 4290782764, 4294349341, 4294967040, 4294967295])
PixelState.PixelMapConfig("account_star2", 0.0474, 0.0278, [4287207389, 4281355482, 4290782764, 4294349341, 4294967040, 4294967295])
PixelState.PixelMapConfig("account_star3", 0.0600, 0.0259, [4287207389, 4281355482, 4290782764, 4294349341, 4294967040, 4294967295])
PixelState.PixelMapConfig("account_star4", 0.0484, 0.0389, [4287207389, 4281355482, 4290782764, 4294349341, 4294967040, 4294967295])
PixelState.PixelMapConfig("account_star5", 0.0589, 0.0388, [4287207389, 4281355482, 4290782764, 4294349341, 4294967040, 4294967295])

PixelState.PixelMapConfig("account_star6", 0.0601, 0.035, [4278912771, 4282335039], 40)
PixelState.PixelMapConfig("account_star7", 0.0536, 0.0389, [4278912771, 4282335039], 40)

;;  minimap zoon icons
PixelState.PixelMapConfig("minimap_top1", 0.9771, 0.0287, [4286545791, 4294967295])
PixelState.PixelMapConfig("minimap_top2", 0.9818, 0.0287, [4286545791, 4294967295])
PixelState.PixelMapConfig("minimap_top3", 0.9802, 0.0241, [4286545791, 4294967295])

PixelState.PixelMapConfig("minimap_bottom1", 0.9755, 0.0426, [4286545791, 4294967295])
PixelState.PixelMapConfig("minimap_bottom2", 0.9818, 0.0444, [4286545791, 4294967295])
PixelState.PixelMapConfig("minimap_bottom3", 0.9844, 0.0398, [4286545791, 4294967295])

;;  nexus ui icon
PixelState.PixelMapConfig("uinexusicon_1", 0.9667, 0.3426, [4294704123, 4294629250], 20)
PixelState.PixelMapConfig("uinexusicon_2", 0.9745, 0.3380, [4294704123, 4294629250], 20)
PixelState.PixelMapConfig("uinexusicon_3", 0.9823, 0.3435, [4293783021, 4294629250], 20)
PixelState.PixelMapConfig("uinexusicon_4", 0.9661, 0.3600, [4293783021, 4293708667], 20)
PixelState.PixelMapConfig("uinexusicon_5", 0.9839, 0.3600, [4293783021, 4293708667], 20)
PixelState.PixelMapConfig("uinexusicon_6", 0.9745, 0.3528, 4278650631)

;;  options ui icon
PixelState.PixelMapConfig("uioptionsicon_1", 0.9656, 0.3444, [4294704123, 4293577080], 20)
PixelState.PixelMapConfig("uioptionsicon_2", 0.9714, 0.3389, [4294704123, 4293773945], 20)
PixelState.PixelMapConfig("uioptionsicon_3", 0.9719, 0.3472, [4294704123, 4294563458], 20)
PixelState.PixelMapConfig("uioptionsicon_4", 0.9745, 0.3491, [4294704123, 4294498435], 20)
PixelState.PixelMapConfig("uioptionsicon_5", 0.9776, 0.3537, [4294440951, 4294431874], 20)
PixelState.PixelMapConfig("uioptionsicon_6", 0.9781, 0.3600, [4293914607, 4293840252], 20)
PixelState.PixelMapConfig("uioptionsicon_7", 0.9828, 0.3537, [4294440951, 4294431872], 20)

;;  options menu control pixels
PixelState.PixelMapConfig("optionsmenu_top1", 0.0219, 0.1315, [4294967295, 4294952960, 4289967027])
PixelState.PixelMapConfig("optionsmenu_top2", 0.1745, 0.1306, [4294967295, 4294952960, 4289967027])
PixelState.PixelMapConfig("optionsmenu_top3", 0.5260, 0.1287, [4294967295, 4294952960, 4289967027])
PixelState.PixelMapConfig("optionsmenu_top4", 0.7146, 0.1306, [4294967295, 4294952960, 4289967027])
PixelState.PixelMapConfig("optionsmenu_top5", 0.8318, 0.1417, [4294967295, 4294952960, 4289967027])

PixelState.PixelMapConfig("optionsmenu_middle1", 0.010, 0.166, 4284374622)
PixelState.PixelMapConfig("optionsmenu_middle2", 0.040, 0.166, 4284374622)
PixelState.PixelMapConfig("optionsmenu_middle3", 0.060, 0.166, 4284374622)
PixelState.PixelMapConfig("optionsmenu_middle4", 0.090, 0.166, 4284374622)

PixelState.PixelMapConfig("optionsmenu_bottom1", 0.0161, 0.8981, 4283716692)
PixelState.PixelMapConfig("optionsmenu_bottom2", 0.6813, 0.8907, 4283716692)
PixelState.PixelMapConfig("optionsmenu_bottom3", 0.0307, 0.9213, [4294967295, 4294892420])
PixelState.PixelMapConfig("optionsmenu_bottom4", 0.5052, 0.8981, [4294967295, 4294892420])
PixelState.PixelMapConfig("optionsmenu_bottom5", 0.8542, 0.9259, [4294967295, 4294892420])

;;  home/main screen volume icon
PixelState.PixelMapConfig("home_volume1", 0.0073, 0.0231, 4294835709)
PixelState.PixelMapConfig("home_volume2", 0.0073, 0.0296, 4294835709)
PixelState.PixelMapConfig("home_volume3", 0.0177, 0.0130, 4294835709)
PixelState.PixelMapConfig("home_volume4", 0.0167, 0.0296, 4294835709)

;;  black loading screen
PixelState.PixelMapConfig("loadingscreen_1", 0.0100, 0.0100, 4278190080)
PixelState.PixelMapConfig("loadingscreen_2", 0.1891, 0.2546, 4278190080)
PixelState.PixelMapConfig("loadingscreen_3", 0.6370, 0.1806, 4278190080)
PixelState.PixelMapConfig("loadingscreen_4", 0.8031, 0.3500, 4278190080)
PixelState.PixelMapConfig("loadingscreen_5", 0.1609, 0.8204, 4278190080)
PixelState.PixelMapConfig("loadingscreen_6", 0.8672, 0.8824, 4278190080)
PixelState.PixelMapConfig("loadingscreen_7", 0.9849, 0.0935, 4278190080)

;;  character screen control pixels
PixelState.PixelMapConfig("charscreen_1", 0.2000, 0.1756, 4283716692)
PixelState.PixelMapConfig("charscreen_2", 0.6000, 0.1756, 4283716692)
PixelState.PixelMapConfig("charscreen_3", 0.9000, 0.1756, 4283716692)
PixelState.PixelMapConfig("charscreen_4", 0.5828, 0.3074, 4283716692)
PixelState.PixelMapConfig("charscreen_5", 0.5828, 0.5000, 4283716692)
PixelState.PixelMapConfig("charscreen_6", 0.5826, 0.8296, 4283716692)
PixelState.PixelMapConfig("charscreen_7", 0.3580, 0.9176, [4294967295, 4294892420, 4282992969], 20)
PixelState.PixelMapConfig("charscreen_8", 0.5130, 0.9204, [4294967295, 4294892420])

;;  loading bar control points
PixelState.PixelMapConfig("loadingbar_1", 0.0130, 0.8870, 4283716692)
PixelState.PixelMapConfig("loadingbar_2", 0.3547, 0.8824, 4283716692)
PixelState.PixelMapConfig("loadingbar_3", 0.8620, 0.8824, 4283716692)
PixelState.PixelMapConfig("loadingbar_4", 0.0240, 0.9500, 4283716692)
PixelState.PixelMapConfig("loadingbar_5", 0.4219, 0.9481, 4283716692)
PixelState.PixelMapConfig("loadingbar_6", 0.9724, 0.9509, 4283716692)

PixelState.PixelMapConfig("mainscreen_1", 0.3284, 0.2147, [4292092682, 4292092938])
PixelState.PixelMapConfig("mainscreen_2", 0.4681, 0.1850, [4294042723, 4294042979])
PixelState.PixelMapConfig("mainscreen_3", 0.6642, 0.2398, 4285333504, 20)
PixelState.PixelMapConfig("mainscreen_4", 0.8762, 0.3260, [4283963411, 4283373586], 20)
PixelState.PixelMapConfig("mainscreen_5", 0.4069, 0.6120, [4279632896, 4279830017, 4279698688])
PixelState.PixelMapConfig("mainscreen_6", 0.1446, 0.2884, [4288285960, 4288225568])

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;  PixelState Groups
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PixelGroups := {}

;;  hp full bar check (debugging)
PixelGroups.HPBarFull := {"hp_100p": true, "hp_95p": true, "hp_90p": true, "hp_85p": true, "hp_80p": true, "hp_75p": true, "hp_70p": true, "hp_65p": true, "hp_60p": true, "hp_55p": true, "hp_50p": true, "hp_45p": true, "hp_40p": true, "hp_35p": true, "hp_30p": true, "hp_25p": true, "hp_20p": true, "hp_15p": true, "hp_10p": true, "hp_5p": true, "hp_0p": true}

;;  in-game control state
PixelGroups.controlpoint75 := {"controlpoint75_1": true, "controlpoint75_2": true, "controlpoint75_3": true, "controlpoint75_4": true, "controlpoint75_5": true, "controlpoint75_6": true, "controlpoint75_7": true, "controlpoint75_8": true, "controlpoint75_9": true, "controlpoint75_10": true}

;;  various realm ui states
PixelGroups.AccountGold := {"account_gold1": true, "account_gold2": true}
PixelGroups.AccountStar := {"account_star1": true, "account_star2": true, "account_star3": true, "account_star4": true, "account_star5": true, "account_star6": true, "account_star7": true}
PixelGroups.MinimapZoom := {"minimap_top1": true, "minimap_top2": true, "minimap_top3": true, "minimap_bottom1": true, "minimap_bottom2": true, "minimap_bottom3": true}
PixelGroups.UINexusButton := {"uinexusicon_1": true, "uinexusicon_2": true, "uinexusicon_3": true, "uinexusicon_4": true, "uinexusicon_5": true, "uinexusicon_6": true}
PixelGroups.UIOptionsButton := {"uioptionsicon_1": true, "uioptionsicon_2": true, "uioptionsicon_3": true, "uioptionsicon_4": true, "uioptionsicon_5": true, "uioptionsicon_6": true, "uioptionsicon_7": true}
PixelGroups.ChatBox := {"chatbox_top1": true, "chatbox_top2": true, "chatbox_top3": true, "chatbox_top4": true, "chatbox_bottom1": true, "chatbox_bottom2": true, "chatbox_bottom3": true, "chatbox_bottom4": true, "chatbox_side1": true}
PixelGroups.ChatBoxUnobstructed := {"chatbox_top1": true, "chatbox_top2": true, "chatbox_bottom1": true, "chatbox_bottom2": true, "chatbox_side1": true}
PixelGroups.HomeVolume := {"home_volume1": true, "home_volume2": true, "home_volume3": true, "home_volume4": true}
PixelGroups.CharScreenControl := {"charscreen_1": true, "charscreen_2": true, "charscreen_3": true, "charscreen_4": true, "charscreen_5": true, "charscreen_6": true, "charscreen_7": true, "charscreen_8": true}
PixelGroups.MainScreenControl := {"mainscreen_1": true, "mainscreen_2": true, "mainscreen_3": true, "mainscreen_4": true, "mainscreen_5": true, "mainscreen_6": true}
PixelGroups.LoadingBar := {"loadingbar_1": true, "loadingbar_2": true, "loadingbar_3": true, "loadingbar_4": true, "loadingbar_5": true, "loadingbar_6": true}

;;  game screens
PixelGroups.InOptions := {"optionsmenu_top1": true, "optionsmenu_top2": true, "optionsmenu_top3": true, "optionsmenu_top4": true, "optionsmenu_top5": true, "optionsmenu_middle1": true, "optionsmenu_middle2": true, "optionsmenu_middle3": true, "optionsmenu_middle4": true, "optionsmenu_bottom1": true, "optionsmenu_bottom2": true, "optionsmenu_bottom3": true, "optionsmenu_bottom4": true, "optionsmenu_bottom5": true}
PixelGroups.InNexus := {"MinimapZoom": true, "AccountGold": true, "AccountStar": true, "UIOptionsButton": true}
PixelGroups.InVault := {"MinimapZoom": true, "AccountGold": true, "AccountStar": true, "UINexusButton": true}
PixelGroups.InRealm := {"AccountStar": false, "AccountGold": true, "MinimapZoom": true, "UINexusButton": true}
PixelGroups.InBlackLoading := {"loadingscreen_1": true, "loadingscreen_2": true, "loadingscreen_3": true, "loadingscreen_4": true, "loadingscreen_5": true, "loadingscreen_6": true, "loadingscreen_7": true}
PixelGroups.InChar := {"HomeVolume": true, "CharScreenControl": true, "LoadingBar": true}
PixelGroups.InMain := {"HomeVolume": true, "MainScreenControl": true, "LoadingBar": true}
PixelGroups.InGreen := {"HomeVolume": true, "MainScreenControl": false, "CharScreenControl": false, "LoadingBar": true}

;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  PixelTrack Object
;;;;;;;;;;;;;;;;;;;;;;;;;;
PixelTrack := {"debug": {}, "CurrentLocation": "Init", "LowHPBeep": false, "Jobs": {}, "SharedBitmap": {}}

;;;;;;;;;;;;;;;;;;;;;;;
;;  BackgroundTasks
;;;;;;;;;;;;;;;;;;;;;;;
SetTimer, PixelStateBackgroundTasks, % Round(PixelStateTasksFrequency*1000)


return

#include %A_ScriptDir%\..\class_pixelstate.ahk

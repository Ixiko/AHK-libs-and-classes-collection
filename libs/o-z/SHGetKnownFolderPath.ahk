; Title:   	SHGetKnownFolderPath()
; Link:   	autohotkey.com/boards/viewtopic.php?f=6&t=75602
; Author:	SKAN
; Date:   	06.05.2020
; for:     	AHK_L

/*
     FOLDERID_Downloads := "{374DE290-123F-4565-9164-39C4925E467B}"
     MsgBox % SHGetKnownFolderPath(FOLDERID_Downloads)

     FOLDERID_AccountPictures         := "{008ca0b1-55b4-4c56-b8a8-4de4b299d3be}" ; Windows  8
     FOLDERID_AddNewPrograms          := "{de61d971-5ebc-4f02-a3a9-6c82895e5c04}"
     FOLDERID_AdminTools              := "{724EF170-A42D-4FEF-9F26-B60E846FBA4F}"
     FOLDERID_AppDataDesktop          := "{B2C5E279-7ADD-439F-B28C-C41FE1BBF672}" ; Windows  10, version 1709
     FOLDERID_AppDataDocuments        := "{7BE16610-1F7F-44AC-BFF0-83E15F2FFCA1}" ; Windows  10, version 1709
     FOLDERID_AppDataFavorites        := "{7CFBEFBC-DE1F-45AA-B843-A542AC536CC9}" ; Windows  10, version 1709
     FOLDERID_AppDataProgramData      := "{559D40A3-A036-40FA-AF61-84CB430A4D34}" ; Windows  10, version 1709
     FOLDERID_ApplicationShortcuts    := "{A3918781-E5F2-4890-B3D9-A7E54332328C}" ; Windows  8
     FOLDERID_AppsFolder              := "{1e87508d-89c2-42f0-8a7e-645a0f50ca58}" ; Windows  8
     FOLDERID_AppUpdates              := "{a305ce99-f527-492b-8b1a-7e76fa98d6e4}"
     FOLDERID_CameraRoll              := "{AB5FB87B-7CE2-4F83-915D-550846C9537B}" ; Windows  8.1
     FOLDERID_CDBurning               := "{9E52AB10-F80D-49DF-ACB8-4330F5687855}"
     FOLDERID_ChangeRemovePrograms    := "{df7266ac-9274-4867-8d55-3bd661de872d}"
     FOLDERID_CommonAdminTools        := "{D0384E7D-BAC3-4797-8F14-CBA229B392B5}"
     FOLDERID_CommonOEMLinks          := "{C1BAE2D0-10DF-4334-BEDD-7AA20B227A9D}"
     FOLDERID_CommonPrograms          := "{0139D44E-6AFE-49F2-8690-3DAFCAE6FFB8}"
     FOLDERID_CommonStartMenu         := "{A4115719-D62E-491D-AA7C-E74B8BE3B067}"
     FOLDERID_CommonStartup           := "{82A5EA35-D9CD-47C5-9629-E15D2F714E6E}"
     FOLDERID_CommonTemplates         := "{B94237E7-57AC-4347-9151-B08C6C32D1F7}"
     FOLDERID_ComputerFolder          := "{0AC0837C-BBF8-452A-850D-79D08E667CA7}"
     FOLDERID_ConflictFolder          := "{4bfefb45-347d-4006-a5be-ac0cb0567192}" ; Windows  Vista
     FOLDERID_ConnectionsFolder       := "{6F0CD92B-2E97-45D1-88FF-B0D186B8DEDD}"
     FOLDERID_Contacts                := "{56784854-C6CB-462b-8169-88E350ACB882}" ; Windows  Vista
     FOLDERID_ControlPanelFolder      := "{82A74AEB-AEB4-465C-A014-D097EE346D63}"
     FOLDERID_Cookies                 := "{2B0F765D-C0E9-4171-908E-08A611B84FF6}"
     FOLDERID_Desktop                 := "{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}"
     FOLDERID_DeviceMetadataStore     := "{5CE4A5E9-E4EB-479D-B89F-130C02886155}" ; Windows  7
     FOLDERID_Documents               := "{FDD39AD0-238F-46AF-ADB4-6C85480369C7}"
     FOLDERID_DocumentsLibrary        := "{7B0DB17D-9CD2-4A93-9733-46CC89022E7C}" ; Windows  7
     FOLDERID_Downloads               := "{374DE290-123F-4565-9164-39C4925E467B}"
     FOLDERID_Favorites               := "{1777F761-68AD-4D8A-87BD-30B759FA33DD}"
     FOLDERID_Fonts                   := "{FD228CB7-AE11-4AE3-864C-16F3910AB8FE}"
     FOLDERID_Games                   := "{CAC52C1A-B53D-4edc-92D7-6B2E8AC19434}"
     FOLDERID_GameTasks               := "{054FAE61-4DD8-4787-80B6-090220C4B700}" ; Windows  Vista
     FOLDERID_History                 := "{D9DC8A3B-B784-432E-A781-5A1130A75963}"
     FOLDERID_HomeGroup               := "{52528A6B-B9E3-4ADD-B60D-588C2DBA842D}" ; Windows  7
     FOLDERID_HomeGroupCurrentUser    := "{9B74B6A3-0DFD-4f11-9E78-5F7800F2E772}" ; Windows  8
     FOLDERID_ImplicitAppShortcuts    := "{BCB5256F-79F6-4CEE-B725-DC34E402FD46}" ; Windows  7
     FOLDERID_InternetCache           := "{352481E8-33BE-4251-BA85-6007CAEDCF9D}"
     FOLDERID_InternetFolder          := "{4D9F7874-4E0C-4904-967B-40B0D20C3E4B}"
     FOLDERID_Libraries               := "{1B3EA5DC-B587-4786-B4EF-BD1DC332AEAE}" ; Windows  7
     FOLDERID_Links                   := "{bfb9d5e0-c6a9-404c-b2b2-ae6db6af4968}"
     FOLDERID_LocalAppData            := "{F1B32785-6FBA-4FCF-9D55-7B8E7F157091}"
     FOLDERID_LocalAppDataLow         := "{A520A1A4-1780-4FF6-BD18-167343C5AF16}"
     FOLDERID_LocalizedResourcesDir   := "{2A00375E-224C-49DE-B8D1-440DF7EF3DDC}"
     FOLDERID_Music                   := "{4BD8D571-6D19-48D3-BE97-422220080E43}"
     FOLDERID_MusicLibrary            := "{2112AB0A-C86A-4FFE-A368-0DE96E47012E}" ; Windows  7
     FOLDERID_NetHood                 := "{C5ABBF53-E17F-4121-8900-86626FC2C973}"
     FOLDERID_NetworkFolder           := "{D20BEEC4-5CA8-4905-AE3B-BF251EA09B53}"
     FOLDERID_Objects3D               := "{31C0DD25-9439-4F12-BF41-7FF4EDA38722}" ; Windows  10, version 1703
     FOLDERID_OriginalImages          := "{2C36C0AA-5812-4b87-BFD0-4CD0DFB19B39}" ; Windows  Vista
     FOLDERID_PhotoAlbums             := "{69D2CF90-FC33-4FB7-9A0C-EBB0F0FCB43C}" ; Windows  Vista
     FOLDERID_PicturesLibrary         := "{A990AE9F-A03B-4E80-94BC-9912D7504104}" ; Windows  7
     FOLDERID_Pictures                := "{33E28130-4E1E-4676-835A-98395C3BC3BB}"
     FOLDERID_Playlists               := "{DE92C1C7-837F-4F69-A3BB-86E631204A23}"
     FOLDERID_PrintersFolder          := "{76FC4E2D-D6AD-4519-A663-37BD56068185}"
     FOLDERID_PrintHood               := "{9274BD8D-CFD1-41C3-B35E-B13F55A758F4}"
     FOLDERID_Profile                 := "{5E6C858F-0E22-4760-9AFE-EA3317B67173}"
     FOLDERID_ProgramData             := "{62AB5D82-FDC1-4DC3-A9DD-070D1D495D97}"
     FOLDERID_ProgramFiles            := "{905e63b6-c1bf-494e-b29c-65b732d3d21a}"
     FOLDERID_ProgramFilesX64         := "{6D809377-6AF0-444b-8957-A3773F02200E}"
     FOLDERID_ProgramFilesX86         := "{7C5A40EF-A0FB-4BFC-874A-C0F2E0B9FA8E}"
     FOLDERID_ProgramFilesCommon      := "{F7F1ED05-9F6D-47A2-AAAE-29D317C6F066}"
     FOLDERID_ProgramFilesCommonX64   := "{6365D5A7-0F0D-45E5-87F6-0DA56B6A4F7D}"
     FOLDERID_ProgramFilesCommonX86   := "{DE974D24-D9C6-4D3E-BF91-F4455120B917}"
     FOLDERID_Programs                := "{A77F5D77-2E2B-44C3-A6A2-ABA601054A51}"
     FOLDERID_Public                  := "{DFDF76A2-C82A-4D63-906A-5644AC457385}"
     FOLDERID_PublicDesktop           := "{C4AA340D-F20F-4863-AFEF-F87EF2E6BA25}"
     FOLDERID_PublicDocuments         := "{ED4824AF-DCE4-45A8-81E2-FC7965083634}"
     FOLDERID_PublicDownloads         := "{3D644C9B-1FB8-4f30-9B45-F670235F79C0}" ; Windows  Vista
     FOLDERID_PublicGameTasks         := "{DEBF2536-E1A8-4c59-B6A2-414586476AEA}" ; Windows  Vista
     FOLDERID_PublicLibraries         := "{48DAF80B-E6CF-4F4E-B800-0E69D84EE384}" ; Windows  7
     FOLDERID_PublicMusic             := "{3214FAB5-9757-4298-BB61-92A9DEAA44FF}"
     FOLDERID_PublicPictures          := "{B6EBFB86-6907-413C-9AF7-4FC2ABF07CC5}"
     FOLDERID_PublicRingtones         := "{E555AB60-153B-4D17-9F04-A5FE99FC15EC}" ; Windows  7
     FOLDERID_PublicUserTiles         := "{0482af6c-08f1-4c34-8c90-e17ec98b1e17}" ; Windows  8
     FOLDERID_PublicVideos            := "{2400183A-6185-49FB-A2D8-4A392A602BA3}"
     FOLDERID_QuickLaunch             := "{52a4f021-7b75-48a9-9f6b-4b87a210bc8f}"
     FOLDERID_Recent                  := "{AE50C081-EBD2-438A-8655-8A092E34987A}"
     FOLDERID_RecordedTV              := "{1A6FDBA2-F42D-4358-A798-B74D745926C5}" ; Windows  7
     FOLDERID_RecycleBinFolder        := "{B7534046-3ECB-4C18-BE4E-64CD4CB7D6AC}"
     FOLDERID_ResourceDir             := "{8AD10C31-2ADB-4296-A8F7-E4701232C972}"
     FOLDERID_Ringtones               := "{C870044B-F49E-4126-A9C3-B52A1FF411E8}" ; Windows  7
     FOLDERID_RoamingAppData          := "{3EB685DB-65F9-4CF6-A03A-E3EF65729F3D}"
     FOLDERID_RoamedTileImages        := "{AAA8D5A5-F1D6-4259-BAA8-78E7EF60835E}" ; Windows  8
     FOLDERID_RoamingTiles            := "{00BCFC5A-ED94-4e48-96A1-3F6217F21990}" ; Windows  8
     FOLDERID_SampleMusic             := "{B250C668-F57D-4EE1-A63C-290EE7D1AA1F}"
     FOLDERID_SamplePictures          := "{C4900540-2379-4C75-844B-64E6FAF8716B}"
     FOLDERID_SamplePlaylists         := "{15CA69B3-30EE-49C1-ACE1-6B5EC372AFB5}" ; Windows  Vista
     FOLDERID_SampleVideos            := "{859EAD94-2E85-48AD-A71A-0969CB56A6CD}"
     FOLDERID_SavedGames              := "{4C5C32FF-BB9D-43b0-B5B4-2D72E54EAAA4}" ; Windows  Vista
     FOLDERID_SavedPictures           := "{3B193882-D3AD-4eab-965A-69829D1FB59F}"
     FOLDERID_SavedPicturesLibrary    := "{E25B5812-BE88-4bd9-94B0-29233477B6C3}"
     FOLDERID_SavedSearches           := "{7d1d3a04-debb-4115-95cf-2f29da2920da}"
     FOLDERID_Screenshots             := "{b7bede81-df94-4682-a7d8-57a52620b86f}" ; Windows  8
     FOLDERID_SEARCH_CSC              := "{ee32e446-31ca-4aba-814f-a5ebd2fd6d5e}"
     FOLDERID_SearchHistory           := "{0D4C3DB6-03A3-462F-A0E6-08924C41B5D4}" ; Windows  8.1
     FOLDERID_SearchHome              := "{190337d1-b8ca-4121-a639-6d472d16972a}"
     FOLDERID_SEARCH_MAPI             := "{98ec0e18-2098-4d44-8644-66979315a281}"
     FOLDERID_SearchTemplates         := "{7E636BFE-DFA9-4D5E-B456-D7B39851D8A9}" ; Windows  8.1
     FOLDERID_SendTo                  := "{8983036C-27C0-404B-8F08-102D10DCFD74}"
     FOLDERID_SidebarDefaultParts     := "{7B396E54-9EC5-4300-BE0A-2482EBAE1A26}"
     FOLDERID_SidebarParts            := "{A75D362E-50FC-4fb7-AC2C-A8BEAA314493}"
     FOLDERID_SkyDrive                := "{A52BBA46-E9E1-435f-B3D9-28DAA648C0F6}" ; Windows  8.1
     FOLDERID_SkyDriveCameraRoll      := "{767E6811-49CB-4273-87C2-20F355E1085B}" ; Windows  8.1
     FOLDERID_SkyDriveDocuments       := "{24D89E24-2F19-4534-9DDE-6A6671FBB8FE}" ; Windows  8.1
     FOLDERID_SkyDrivePictures        := "{339719B5-8C47-4894-94C2-D8F77ADD44A6}" ; Windows  8.1
     FOLDERID_StartMenu               := "{625B53C3-AB48-4EC1-BA1F-A1EF4146FC19}"
     FOLDERID_Startup                 := "{B97D20BB-F46A-4C97-BA10-5E3608430854}"
     FOLDERID_SyncManagerFolder       := "{43668BF8-C14E-49B2-97C9-747784D784B7}" ; Windows  Vista
     FOLDERID_SyncResultsFolder       := "{289a9a43-be44-4057-a41b-587a76d7e7f9}" ; Windows  Vista
     FOLDERID_SyncSetupFolder         := "{0F214138-B1D3-4a90-BBA9-27CBC0C5389A}" ; Windows  Vista
     FOLDERID_System                  := "{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}"
     FOLDERID_SystemX86               := "{D65231B0-B2F1-4857-A4CE-A8E7C6EA7D27}"
     FOLDERID_Templates               := "{A63293E8-664E-48DB-A079-DF759E0509F7}"
     FOLDERID_TreeProperties          := "{9E3995AB-1F9C-4F13-B827-48B24B6C7174}" ; Windows  7
     FOLDERID_UserProfiles            := "{0762D272-C50A-4BB0-A382-697DCD729B80}"
     FOLDERID_UserProgramFiles        := "{5CD7AEE2-2219-4A67-B85D-6C9CE15660CB}" ; Windows  7
     FOLDERID_UserProgramFilesCommon  := "{BCBD3057-CA5C-4622-B42D-BC56DB0AE516}" ; Windows  7
     FOLDERID_UsersFiles              := "{f3ce0f7c-4901-4acc-8648-d5d44b04ef8f}"
     FOLDERID_UsersLibraries          := "{A302545D-DEFF-464b-ABE8-61C8648D939B}" ; Windows  7
     FOLDERID_Videos                  := "{18989B1D-99B5-455B-841C-AB7C74E4DDFC}"
     FOLDERID_VideosLibrary           := "{491E922F-5643-4AF4-A7EB-4E7A138D8174}" ; Windows  7
     FOLDERID_Windows                 := "{F38BF404-1D43-42F2-9305-67DE0B28FC23}"

*/

/*  EXAMPLE: Caution: The following code will un-block all files in downloads folder

     #NoEnv
     #SingleInstance, Force
     SetWorkingDir % SHGetKnownFolderPath("{374DE290-123F-4565-9164-39C4925E467B}") ; FOLDERID_Downloads
     RunWait, % "powershell.exe (Get-Item * -Stream ""Zone.Identifier"" -ErrorAction SilentlyContinue"
              . " | ForEach {Unblock-File $_.FileName})",, Hide
     SoundBeep

*/

SHGetKnownFolderPath(FOLDERID, KF_FLAG:=0) {                  ;   By SKAN on D356 @ tiny.cc/t-75602
Local CLSID, pPath:=""                                        ; Thanks teadrinker @ tiny.cc/p286094
Return Format("{4:}", VarSetCapacity(CLSID, 16, 0)
     , DllCall("ole32\CLSIDFromString", "Str",FOLDERID, "Ptr",&CLSID)
     , DllCall("shell32\SHGetKnownFolderPath", "Ptr",&CLSID, "UInt",KF_FLAG, "Ptr",0, "PtrP",pPath)
     , StrGet(pPath, "utf-16")
     , DllCall("ole32\CoTaskMemFree", "Ptr",pPath))
}
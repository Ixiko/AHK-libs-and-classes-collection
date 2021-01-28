/*		DESCRIPTION

		Link: 			https://autohotkey.com/boards/viewtopic.php?f=6&t=4732
		Author:		jNizM
		Date:			30.09.2014
		Version:		AHK_L v1
		

*/

/*		EXAMPLE(s)

		GUID_1 := CreateGUID()
		GUID_2 := CreateGUID()
		MsgBox % IsEqualGUID(GUID_1, GUID_2) ; ==> 0
		MsgBox % IsEqualGUID(GUID_1, GUID_1) ; ==> 1
		
		
		MsgBox % CreateUUID() ; ==> xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
		
		GUID_1 := CreateUUID()
		GUID_2 := CreateUUID()
		MsgBox % UuidEqual(GUID_1, GUID_2) ; ==> 0
		MsgBox % UuidEqual(GUID_1, GUID_1) ; ==> 1


		 ; user clicked the Delete Profile button
		_DeleteProfile(){
		id := this.CurrentProfile.id
		if (id = 1 || id = 2)
		return
		pp := this.CurrentProfile.ParentProfile
		if pp != 0
		newprofile := pp
		else
		newprofile := 2
		this._DeleteChildProfiles(id)
		this.__DeleteProfile(id)
		this.UpdateProfileToolbox()
		this.ChangeProfile(newprofile)
		}
		; Actually deletes a profile
		__DeleteProfile(id){
		; Remove profile's entry from ProfileTree
		profile := this.Profiles[id]
		treenode := this.ProfileTree[profile.ParentProfile]
		for k, v in treenode {
		if (v == id){
		treenode.Remove(k)	; Use Remove, so indexes shuffle down.
		; If array is empty, remove from tree
		if (!treenode.length())
		this.ProfileTree.Delete(profile.ParentProfile)	; Sparse array - use Delete instead of Remove
		break
		}
		}
		; Terminate profile input thread
		this._SetProfileInputThreadState(profile.id,0)
		; Kill profile object
		this.profiles.Delete(profile.id)
		}
		; Recursively deletes child profiles
		_DeleteChildProfiles(id){
		for i, profile in this.Profiles{
		if (profile.ParentProfile = id){
		this._DeleteChildProfiles(profile.id)
		this.__DeleteProfile(profile.id)
		}
		}
		}

*/


CreateGUID() {
VarSetCapacity(pguid, 16, 0)
if !(DllCall("ole32.dll\CoCreateGuid", "ptr", &pguid)) {
size := VarSetCapacity(sguid, (38 << !!A_IsUnicode) + 1, 0)
if (DllCall("ole32.dll\StringFromGUID2", "ptr", &pguid, "ptr", &sguid, "int", size))
return StrGet(&sguid)
}
return ""
}

CreateGUID_Ansi() {
VarSetCapacity(pguid, 16)
if !(DllCall("ole32.dll\CoCreateGuid", "ptr", &pguid)) {
VarSetCapacity(sguid, 38 * 2 + 1)
if (DllCall("ole32.dll\StringFromGUID2", "ptr", &pguid, "ptr", &sguid, "int", 38 + 1))
return StrGet(&sguid, "UTF-16")
}
return ""
}

CreateUUID() {
VarSetCapacity(puuid, 16, 0)
if !(DllCall("rpcrt4.dll\UuidCreate", "ptr", &puuid))
if !(DllCall("rpcrt4.dll\UuidToString", "ptr", &puuid, "uint*", suuid))
return StrGet(suuid), DllCall("rpcrt4.dll\RpcStringFree", "uint*", suuid)
return ""
}

IsEqualGUID(guid1, guid2) {
return DllCall("ole32\IsEqualGUID", "ptr", &guid1, "ptr", &guid2)
}

UuidEqual(uuid1, uuid2) {
return DllCall("rpcrt4.dll\UuidEqual", "ptr", &uuid1, "ptr", &uuid2, "ptr", &RPC_S_OK)
}
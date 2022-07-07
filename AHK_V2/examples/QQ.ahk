#Include '..\XCGUI.ahk'
DllCall('LoadLibrary', 'str', '..\' (A_PtrSize * 8) 'bit\xcgui.dll')
XC.InitXCGUI()
bRes := XC.LoadResource('resource.res')
hWindow := {base: CXWindow.Prototype, ptr: XC.LoadLayout('main.xml')}
hTree := {base: CXTree.Prototype, ptr: XC.GetObjectByName('tree')}
hTree.EnableConnectLine(false, false)
({base: CXScrollView.Prototype, ptr: hTree.Ptr}).ShowSBarH(false)
hTree.SetIndentation(0)
hTree.SetItemHeightDefault(28, 54)
hTree.SetItemTemplateXML('xml-template\Tree_Item_friend.xml')
hTree.SetItemTemplateXMLSel('xml-template\Tree_Item_friend_sel.xml')
pTemplate_group := XTemp.Load(XC.listItemTemp_type.tree, 'xml-template\Tree_Item_group.xml')
hVip := CXImage.LoadFile('image\SuperVIP_LIGHT.png', false)
hQzone := CXImage.LoadFile('image\QQZone.png', false)
hAvatarSmall := CXImage.LoadFile("image\avatar_small.png", false)
hAvatarLarge := CXImage.LoadFile("image\avatar_large.png", false)
hExpand := CXImage.LoadFile("image\expand.png", false)
hExpandNo := CXImage.LoadFile("image\expandno.png", false)
hExpandNo.EnableAutoDestroy(false)
hExpand.EnableAutoDestroy(false)

hAdapter := CXAdapterTree()
hTree.BindAdapter(hAdapter)
hAdapter.AddColumn("name1")
hAdapter.AddColumn("name2")
hAdapter.AddColumn("name3")
hAdapter.AddColumn("name4")
hAdapter.AddColumn("name5")
hAdapter.AddColumn("name6")

nGroupID := 0
nItemID := 0
loop 3 {
	iGroup := A_Index - 1
	text := "好友分组-" iGroup
	nGroupID := hAdapter.InsertItemText(text, XC.ID.ROOT, XC.ID.LAST)
	hTree.SetItemHeight(nGroupID, 26, 26)
	loop 5 {
		i := A_Index - 1
		text := "我的好友-" i
		nItemID := hAdapter.InsertItemText(text, nGroupID, XC.ID.LAST)
		hAdapter.SetItemTextEx(nItemID, "name2", "我的个性签签名")
		hAdapter.SetItemImageEx(nItemID, "name5", hVip)
		hAdapter.SetItemImageEx(nItemID, "name6", hQZone)
		hAdapter.SetItemImageEx(nItemID, "name3", hAvatarSmall)
		hAdapter.SetItemImageEx(nItemID, "name4", hAvatarLarge)
	}
}
hTree.RegEventC(XC.eleEvents.TREE_TEMP_CREATE, CallbackCreate(OnTemplateCreate))
hTree.RegEventC(XC.eleEvents.TREE_TEMP_CREATE_END, CallbackCreate(OnTreeTemplateCreateEnd))
hWindow.AdjustLayout()
hWindow.ShowWindow(5)
XC.RunXCGUI()
XC.ExitXCGUI()

OnTemplateCreate(pItem, pbHandled) {
	it := {base: XC.tree_item_i.Prototype, ptr: pItem}
	if (hTree.GetFirstChildItem(it.nID) != XC.ID.ERROR) {
		if (pTemplate_group) {
			it.hTemp := pTemplate_group
		}
	}
}
OnTreeTemplateCreateEnd(pItem, pbHandled) {
	it := {base: XC.tree_item_i.Prototype, ptr: pItem}
	hButtonExpand := {base: CXButton.Prototype, ptr: hTree.GetTemplateObject(it.nID, 1)}
	if (hButtonExpand && XC.IsHELE(hButtonExpand)) {
		if (hExpandNo)
		{
			hButtonExpand.AddBkImage(XC.button_state.leave, hExpandNo)
			hButtonExpand.AddBkImage(XC.button_state.stay, hExpandNo)
			hButtonExpand.AddBkImage(XC.button_state.down, hExpandNo)
		}
		if (hExpand)
			hButtonExpand.AddBkImage(XC.button_state.check, hExpand)

		hButtonExpand.EnableBkTransparent(TRUE)
		hButtonExpand.SetStyle(XC.STYLE.button_default)
		hButtonExpand.EnableFocus(FALSE)
	}
}
; Menu module
class Menu extends Menu.__base__
{
	
	static __ := [] ;Instances

	__New(kwargs) {
		ObjInsert(this, "_", [])
		this._.Insert("__items__", [])

		this.name := IsObject(kwargs) ? kwargs.Remove("name") : kwargs
		for k, v in kwargs
			if k in % "standard,color,icon,tip,click,mainwindow,default_action"
				this[k] := v
	}

	__Delete() {
		try {
			Menu, % this.name, Color ; check if Menu exists, fix this??
			this.del()
			Menu, % this.name, Delete
		}
		Menu.__.Remove(this.name)
		OutputDebug, % "Menu[CLASS]: " . this.name . " released."
	}

	__Set(k, v, p*) {
		if (k = "name") {
			if this._.HasKey("name")
				return
			Menu[v] := &this
			this._.Insert("name",  v) ;avoid crash
			if (v = "Tray")
				this.standard := 1
			else Loop, 2
				Menu, % v, % (A_Index == 1 ? "Standard" : "NoStandard")

		} else if (k = "default") {
			Menu, % this.name, Default
			    , % v ? (IsObject(v) ? v.name : v) : ""
		
		} else if (k = "color") {
			obj := IsObject(v)
			Menu, % this.name, Color
			    , % obj ? v.value : SubStr(v, 1, InStr(v, ",")-1)
			    , % obj ? v.single : SubStr(v, InStr(v, ",")+1)
			if obj
				v := v.value . "," . v.single 

		} else if (k = "standard") {
			if !v
				this.__items__.Remove(this.standard, this.standard+9)
			else Loop, 10
				new Menu.item_standard(this)
			v := this.standard
		}

		else if k in % "icon,tip,click,mainwindow"
		{
			if (this.name != "Tray")
				return
			if (k = "icon") {
				icon := IsObject(v) ? [] : StrSplit(v, ",", " `t")
				for a, b in ["filename", "icon_no", "freeze"] {
					if !IsObject(v)
						break
					icon.Insert(v.HasKey(b) ? v.Remove(b) : ["*", 1, 1][a])
				}
				return this.set_icon(icon*)
			
			} else if (k = "mainwindow") {
				if !A_IsCompiled
					return
				Menu, Tray, % (v ? "" : "No") . "MainWindow"
			
			} else Menu, Tray, % k, % v
		}

		else if (k = "__items__") {
			if this._.HasKey(k)
				return
		
		} else if this.item(k)
			return this.del(this.item(k))

		return this._[k] := v
	}

	class __Get extends Menu.__property__
	{

		__(k, p*) {
			if this._.HasKey(k)
				return this._[k, p*]
			
			else return this.item(k)
		}

		icon(p*) {
			if !this._.HasKey("icon")
				return false
			icon := {}
			for k, v in StrSplit(this._.icon, ",", " `t")
				icon[["filename", "icon_no", "freeze"][k]] := v
			return p.MinIndex() ? icon[p[1]] : icon
		}

		standard() {
			for item in this
				pos := A_Index
			until (std := item.type = "standard")
			return std ? pos : false
		}

		__items__(p*) {
			return this._.__items__[p*]
		}
	}

	add(item*) {
		res := []
		if !item.MinIndex()
			item := [""]
		for k, v in item
			i := new Menu.item_custom(this, v)
			, res.Insert(i.name, i)
		return item.MaxIndex() == 1 ? res.Remove(i.name) : res
	}

	del(item:="") {
		if item {
			if !IsObject(item)
				item := this.item(item)
			if (item.type == "separator")
				this.set_itempos(item)
			else if (item.type == "standard")
				this.standard := false
			else this.__items__.Remove(item.pos)
			item := ""
		} else {
			this._.__items__.Remove(1, this.len())
			Menu, % this.name, DeleteAll ; cleanup, remove 'separators'
		}
	}

	ins(p1:=0, p2:=0) {
		item := this.add((mi:=IsObject(p1)) ? p1 : "")
		this.item(this.len()).pos := mi ? p2 : p1
		return item
	}

	len() {
		return (len:=this.__items__.MaxIndex()) != "" ? len : 0
	}

	item(arg) {
		if this.__items__.HasKey(arg)
			return this.__items__[arg]
		else for k, v in this.__items__
			idx := (v.name = arg ? k : 0)
		until idx
		return idx ? (this.__items__)[idx] : 0
	}

	show(x:="", y:="", coordmode:="") {
		if coordmode in % "S,R,W,C,Screen,Relative,Window,Client"
			if (x != "" || y != "")
				CoordMode, Menu, % {S:"Screen"
				                  , R:"Relative"
				                  , W:"Window"
				                  , C:"Client"}[SubStr(coordmode, 1, 1)]
		Menu, % this.name, Show, % x, % y
	}

	set_icon(filename:="*", icon_no:=1, freeze:=1) {
		if (this.name != "Tray")
			return
		Menu, Tray, Icon, % filename, % icon_no, % freeze
		this._.icon := filename . "," . icon_no . "," . freeze
	}

	set_itempos(item, pos:=false) {
		items := this.__items__
		if pos
			items.Insert(pos, items.Remove(item.pos))
		else items.Remove(item.pos)

		for i in this
			if (i.type == "submenu")
				Menu, % this.name, Add, % i.name, MENU_ITEMLABEL

		Menu, % this.name, DeleteAll
		Menu, % this.name, NoStandard

		for k, v in items {
			if (!pos && v == item)
				continue
			if (v.type == "standard") {
				if (k == this.standard)
					Menu, % this.name, Standard
				continue
			}
			Menu, % this.name, Add
			    , % v.name
			    , % v.type != "separator" ? "MENU_ITEMLABEL" : ""

			for a, b in v._
				if a in % "action,icon,check,enable,default"
					items[k][a] := b
		}
	}

	class item_custom
	{

		__New(mn, kwargs) {
			mn.__items__.Insert(this)
			ObjInsert(this, "_", [])
			ObjInsert(this._, "menu", mn.name)

			this.name := IsObject(kwargs)
			             ? (kwargs.HasKey("name") ? kwargs.Remove("name") : "")
			             : kwargs
			
			if !kwargs.HasKey("action")
				kwargs.action := (da:=mn.default_action) ? da : ""
			for a, b in kwargs
				if a in % "action,icon,enable,check,default"
					this[a] := b
		}

		__Delete() {
			if (this.type == "normal")
				Menu, % this.menu.name, Delete, % this.name
		}

		__Set(k, v, p*) {
			mn := this.menu

			if (k = "name") {
				if (this._.HasKey("name")) {
					if (v = this.name)
						return
					Menu, % mn.name, Rename, % this.name, % v
					if (v == "") {
						for a, b in ["action", "icon", "check", "enable", "default"]
							if this._.HasKey(b)
								this._.Remove(b)
					}
				
				} else Menu, % mn.name, Add, % v, % (v != "") ? "MENU_ITEMLABEL" : ""
			
			} else if (k = "action") {
				sub := ((str:=SubStr(v, 1, 1)==":") || (v.base == Menu))
				       ? (str ? v : ":" . v.name)
				       : false
				Menu, % mn.name, Add, % this.name, % sub ? v:=sub : "MENU_ITEMLABEL"
				if IsObject(v) && IsFunc(v)
					v := v.Name . "()"
				else if (v == "")
					v := this.name
			
			} else if (k = "icon") {
				icon := IsObject(v) ? [] : StrSplit(v, ",", " `t")
				for a, b in ["filename", "icon_no", "icon_width"] {
					if !IsObject(v)
						break
					icon.Insert(v.Remove(b))
				}
				return this.set_icon(icon*)
			}

			else if k in % "check,enable"
			{
				cmd := {check: {1: "Check", 0: "Uncheck", 2: "ToggleCheck"}
				      , enable: {1: "Enable", 0: "Disable", 2: "ToggleEnable"}}[k, v]
				Menu, % mn.name, % cmd, % this.name
			}

			else if (k = "default") {
				mn.default := v ? this.name : false
			
			} else if (k = "pos") {
				if (this.type == "standard")
				|| !(v >= 0 && v <= mn.len())
				|| (this.pos == v)
					return
				if (std:=mn.standard) {
					if (v > this.pos && v >= std && v < (std+9))
					|| (v < this.pos && v > std && v <= (std+9))
						return
				}
				return mn.set_itempos(this, v)
			}

			return this._[k] := v
		}

		class __Get extends Menu.__property__
		{

			__(k, p*) {
				if this._.HasKey(k)
					return this._[k, p*]
			}

			menu() {
				return Object(Menu.__[this._.menu])
			}

			action() {
				RegExMatch(this._.action, "O)^(.*)(:|\(\))$", m)
				return m ? {":":m.1, "()":Func(m.1)}[m.2] : this._.action
			}

			pos() {
				for i in this.menu
					pos := A_Index
				until (match := i == this)
				return match ? pos : 0
			}

			type() {
				type := (this.base != Menu.item_standard)
				        ? (this.name == "")
				          ? "separator"
				          : (SubStr(this.action, 1, 1) == ":")
				            ? "submenu"
				            : "normal"
				        : "standard"
				return type
			}
		}

		set_icon(filename, icon_no:=1, icon_width:="") {
			Menu, % this.menu.name, Icon
			    , % this.name
			    , % filename
			    , % icon_no
			    , % icon_width
			return this._.icon := filename . "," . icon_no . "," . icon_width
		}

		on_event() {
			cmd := this.action
			lbl := IsLabel(cmd), fn := IsFunc(cmd), obj := IsObject(cmd)
			
			if (lbl && (!fn || (fn && !obj)))
				SetTimer, % cmd, -1
			else if (fn && (!lbl || (lbl && obj)))
				return (cmd).(this)
			return
		}
	}

	class item_standard extends Menu.item_custom
	{

		__New(mn) {
			mn.__items__.Insert(this)
			ObjInsert(this, "_", {menu: mn.name})

			if !(this.pos-mn.standard)
				Menu, % mn.name, Standard
		}

		__Delete() {
			Menu, % this.menu.name, NoStandard
		}

		__Set(k, v, p*) {
			return false
		}
	}

	_NewEnum() {
		return {base: {Next:Menu.enum_item_next}
		      , enum: this.__items__._NewEnum()}
	}

	enum_item_next(ByRef k, ByRef v:="") {
		return this.enum.Next(i, k)
	}

	__handler__() {
		return
		MENU_ITEMLABEL:
		MENU_ITEMLABELTIMER:
		if (A_ThisLabel == "MENU_ITEMLABELTIMER")
			Menu.this_item().on_event()
		else SetTimer, MENU_ITEMLABELTIMER, -1
		return
	}

	fromstring(src) {
		/*
		Do not initialize 'xpr' as class static initializer(s) will not be
		able to access the variable's content when calling this function.
		*/
		static xpr
		
		if (this != Menu) ;Object must be the 'class' object, restrict
			return
		;XPath[1.0] expression(s) that allow case-insensitive node selection
		if !xpr
			xpr := ["*[translate(name(), 'MENU', 'menu')='menu']"
			    ,   "*[translate(name(), 'ITEM', 'item')='item' or "
			    .   "translate(name(), 'STANDARD', 'standard')='standard']"
			    ,   "@*[translate(name(), 'NAME', 'name')='name']"
			    ,   "@*[translate(name(), 'GLOBAL_ACTION', 'global_action')='global_action']"]
		
		x := ComObjCreate("MSXML2.DOMDocument" . (A_OsVersion~="^WIN_(VISTA|7|8)$" ? ".6.0" : ""))
		x.setProperty("SelectionLanguage", "XPath")
		x.async := false

		;Load XML source
		if (SubStr(src, 1, 1) == "<") && (SubStr(src, 0) == ">")
			x.loadXML(src)
		else if ((f:=FileExist(src)) && !InStr(f, "D"))
			x.load(src)
		else throw Exception("Invalid XML source.", -1)

		global_action := (ga:=x.documentElement.selectSingleNode(xpr.4))
		              ? ga.value
		              : false

		m := [] , mn := []
		
		;for mnode in x.selectNodes("//" xpr.1 "[" xpr.3 "]") {
		Loop, % (_:=x.selectNodes("//" xpr.1 "[" xpr.3 "]")).length {
			mnode := _.item(A_Index-1)
			mp := [] , len := A_Index
			;for att in mnode.attributes
			Loop, % (_att:=mnode.attributes).length
				att := _att.item(A_Index-1)
				, mp[att.name] := att.value

			if (global_action && !mp.HasKey("default_action"))
				mp.default_action := global_action
			
			m[mp.name] := {node: mnode, menu: new Menu(mp)}
		}

		for k, v in m {
			
			;for inode in v.node.selectNodes(xpr.2) {
			Loop, % (_:=v.node.selectNodes(xpr.2)).length {
				inode := _.item(A_Index-1)
				if (inode.nodeName = "Standard") {
					v.menu.standard := true
					continue
				}
				
				mi := (att:=inode.attributes).length ? [] : ""
				;for ip in att
				Loop, % att.length
					ip := att.item(A_Index-1)
					, mi[ip.name] := ip.value
				
				v.menu.add(mi)
			}
			
			mn[name:=k] := v.Remove("menu")
		}
		return len>1 ? mn : mn.Remove(name)
	}
	
	class __base__
	{

		__Set(k, v, p*) {
			if !ObjHasKey(this, "__")
				ObjInsert(this, "__", [])
			
			return IsObject(Object(v))
			       ? this.__[k] := v
			       : false
		}

		this_menu() {
			return Object(Menu.__[A_ThisMenu])
		}

		this_item() {
			return Menu.this_menu().item(A_ThisMenuItemPos)
		}
	}

	class __property__
	{
		__Call(target, name, params*) {
			if name not in % "base,__Class"
			{
				return ObjHasKey(this, name)
				       ? this[name].(target, params*)
				       : this.__.(target, name, params*)
			}
		}
	}
}

Menu(kwargs) {
	if (SubStr(kwargs, 1, 1) == "<") && (SubStr(kwargs, 0) == ">")
		return Menu.fromstring(kwargs)
	return new Menu(kwargs)
}
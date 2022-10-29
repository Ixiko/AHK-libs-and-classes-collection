/*
    Library: menu
    Author: neovis
    Link: https://github.com/neovis22/menu
*/

menu(menuItems, callback="") {
    return new __Menu__(menuItems, callback)
}

class __Menu__ {
    
    static _selectedItem
    
    _groups := []
    
    __new(menuItems, callback="") {
        static id := 0
        this.name := "menu_" ++ id
        this.callback := callback
        
        for i, item in menuItems {
            if (item.menu) {
                submenu := menu(item.menu, callback)
                sub := ":" submenu.name
                this[a_index] := submenu ; 레퍼런스 카운트 유지 (서브메뉴의 소멸방지)
            } else {
                sub := Func("_menuEventHandler").bind(&this, item)
            }
            
            if (item.hasKey("group")) {
                this._groups[item.group, a_index] := item
                opts := " Radio"
            } else {
                opts := ""
            }
            
            Menu % this.name, Add, -, % sub, % item.options opts
            
            if (item.checked)
                this.check(a_index "&")
            if (item.disabled)
                this.disable(a_index "&")
            if (item.color != "")
                this.setColor(a_index "&", item.color)
            if (item.icon.file)
                this.setIcon(a_index "&", item.icon.file, item.icon.number, item.icon.width)
            if (item.default)
                this.default := a_index "&"
            
            this.rename(a_index "&", item.name)
        }
    }
    
    __delete() {
        Menu % this.name, DeleteAll
    }
    
    delete(itemName) {
        Menu % this.name, Delete, % itemName
    }
    
    rename(itemName, newName="") {
        Menu % this.name, Rename, % itemName, % newName
    }
    
    check(itemName) {
        Menu % this.name, Check, % itemName
    }
    
    uncheck(itemName) {
        Menu % this.name, Uncheck, % itemName
    }
    
    toggleCheck(itemName) {
        Menu % this.name, ToggleCheck, % itemName
    }
    
    enable(itemName) {
        Menu % this.name, Enable, % itemName
    }
    
    disable(itemName) {
        Menu % this.name, Disable, % itemName
    }
    
    toggleEnable(itemName) {
        Menu % this.name, ToggleEnable, % itemName
    }
    
    setColor(itemName, color="", applyToSubmenus="") {
        Menu % this.name, Color, % itemName, % color, % applyToSubmenus ? "" : "Single"
    }
    
    setIcon(itemName, fileName, iconNumber="", iconWidth="") {
        Menu % this.name, Icon, % itemName, % fileName, % iconNumber, % iconWidth
    }
    
    noIcon(itemName) {
        Menu % this.name, NoIcon, % itemName
    }
    
    show(x="", y="") {
        __Menu__._selectedItem := ""
        Menu % this.name, Show, % x, % y
        return __Menu__._selectedItem
    }
    
    default[] {
        get {
            return this._default
        }
        set {
            Menu % this.name, Default, % value
            return this._default := value
        }
    }
    
    handle[] {
        get {
            return MenuGetHandle(this.name)
        }
        set {
            return value
        }
    }
}

_menuEventHandler(menu, item, name, index, menuName) {
    __Menu__._selectedItem := item
    menu := Object(menu)
    if (item.hasKey("group")) {
        for i, v in menu._groups[item.group] {
            if (i == index) {
                v.checked := true
                menu.check(i "&")
            } else {
                v.checked := false
                menu.uncheck(i "&")
            }
        }
    } else if (item.hasKey("checked")) {
        item.checked := !item.checked
        menu.toggleCheck(index "&")
    }
    if (menu.callback) {
        func := IsObject(menu.callback) ? menu.callback : Func(menu.callback)
        func.call(item, index, menu)
    }
    if (item.callback) {
        func := IsObject(item.callback) ? item.callback : Func(item.callback)
        func.call(item, index, menu)
    }
}
/*
 *  Author: Gerrard Lukacs
 */

/* This include script facilitates adding multi-item options to menus.
 * To use, create your MenuEnumOption instances, and have their items' labels
 * point to a block of code which contains the following:
 *     MenuEnumOption.options[A_ThisLabel].setVariable(A_ThisLabel)
 * You may also include additional processing in the label block; note that
 * the state of the controlled variable is updated after the call.
 */

class MenuEnumItem
{
    name := ""
    label := ""
    
    __New(name, label)
    {
        this.name := name
        this.label := label
    }
    
    add(menuName)
    {
        ; Add the item to the 'menuName' menu.
        Menu % menuName, Add, % this.name, % this.label
    }
    
    remove(menuName)
    {
        ; Remove the item from the 'menuName' menu.
        Menu % menuName, Delete, % this.name
    }
    
    setChecked(menuName, checked)
    {
        ; Check/uncheck the item in the 'menuName' menu.
        if (checked)
            Menu % menuName, Check, % this.name
        else
            Menu % menuName, Uncheck, % this.name
    }
    
}

class MenuEnumOption
{
    ; A dictionary mapping from labels of all MenuEnumItems to the
    ; corresponding MenuEnumOption instances.
    static options := {}
    
    menu := ""
    variableName := ""
    itemsList := 0 ; MenuEnumItems in the order they appear in the menu.
    itemsMap := 0 ; A dictionary from item labels to MenuEnumItem instances.
    
    menuItemsExist := false
    
    __New(menuName, variableName, enumItems, addImmediately=true)
    {
        /* Construct a new MenuEnumOption.
         * 
         * menuName - The name of the menu this option will reside in.
         * variableName - The name of the variable this option controls.
         * enumItems - A list of MenuEnumItems representing the choices this
         *             option allows. Menu items will appear in the same order
         *             they appear in this list.
         * addImmediately - If true, immediately create the menu items for
         *                  this option. True by default.
         */
        
        this.menu := menuName
        this.variableName := variableName
        this.itemsList := enumItems
        
        this.itemsMap := {}
        for _, item in enumItems
        {
            this.itemsMap[item.label] := item
            MenuEnumOption.options[item.label] := this
        }
        
        if (addImmediately)
            this.add()
    }
    
    getVariable()
    {
        ; Get the value of the variable this option controls.
        variableName := this.variableName
        return (%variableName%)
    }
    
    setVariable(itemLabel)
    {
        ; Set the value of the variable this option controls to the
        ; MenuEnumItem corresponding to itemLabel. This automatically
        ; checks/unchecks the menu items, if they exist.
        
        variableName := this.variableName
        oldItem := %variableName%
        %variableName% := this.itemsMap[itemLabel]
        
        if (this.menuItemsExist)
        {
            oldItem.setChecked(this.menu, false)
            %variableName%.setChecked(this.menu, true)
        }
    }
    
    add()
    {
        ; Add the option's items to its menu.
        for _, item in this.itemsList
            item.add(this.menu)
        this.getVariable().setChecked(this.menu, true)
        this.menuItemsExist := true
    }
    
    remove()
    {
        ; Remove the option's items from its menu.
        for _, item in this.itemsList
            item.remove(this.menu)
        this.menuItemsExist := false
    }
}

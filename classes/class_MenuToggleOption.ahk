/*
 *  Author: Gerrard Lukacs
 */

/* This include script facilitates adding toggleable options to menus.
 * To use, create your MenuToggleOption instances, and have their labels point
 * to a block of code which contains the following:
 *     MenuToggleOption.options[A_ThisLabel].toggleVariable()
 * You may also include additional processing in the label block; note that
 * the state of the controlled variable is updated after the call.
 */

class MenuToggleOption
{
    ; A dictionary mapping from labels to the corresponding MenuToggleOption instances.
    static options := {}
    
    menu := ""
    item := ""
    label := ""
    variableName := ""
    
    menuItemExists := false
    
    __New(menuName, itemName, labelName, variableName, addImmediately=true)
    {
        /* Construct a new MenuToggleOption.
         * 
         * menuName - The name of the menu this option will reside in.
         * itemName - The name of the menu item to represent this option.
         * labelName - The name of the label the menu item triggers.
         * variableName - The name of the variable this option controls.
         * addImmediately - If true, immediately create the menu item for this
         *                  option. True by default.
         */
        
        this.menu := menuName
        this.item := itemName
        this.label := labelName
        this.variableName := variableName
        
        MenuToggleOption.options[this.label] := this
        
        if (addImmediately)
            this.add()
    }
    
    getVariable()
    {
        ; Get the value of the variable this option controls.
        variableName := this.variableName
        return (%variableName%)
    }
    
    setVariable(value)
    {
        ; Set the value of the variable this option controls to 'value'.
        ; This automatically checks/unchecks the menu item, if it exists.
        
        variableName := this.variableName
        %variableName% := value
        
        if (this.menuItemExists)
        {
            if (value)
                Menu % this.menu, Check, % this.item
            else
                Menu % this.menu, Uncheck, % this.item
        }
    }
    
    toggleVariable()
    {
        ; Toggle the variable this option controls, and return its resulting value.
        ; This automatically checks/unchecks the menu item, if it exists.
        
        variableName := this.variableName
        %variableName% := !%variableName%
        
        if (this.menuItemExists)
            Menu % this.menu, ToggleCheck, % this.item
        
        return (%variableName%)
    }
    
    add()
    {
        ; Add the option to its menu.
        Menu % this.menu, Add, % this.item, % this.label
        if (this.getVariable())
            Menu % this.menu, Check, % this.item
        this.menuItemExists := true
    }
    
    remove()
    {
        ; Remove the option from its menu.
        Menu % this.menu, Delete, % this.item
        this.menuItemExists := false
    }
    
    setEnabled(enabled)
    {
        ; Enable/disable the menu item, if it exists
        if (this.menuItemExists)
        {
            if (enabled)
                Menu % this.menu, Enable, % this.item
            else
                Menu % this.menu, Disable, % this.item
        }
    }
    
}

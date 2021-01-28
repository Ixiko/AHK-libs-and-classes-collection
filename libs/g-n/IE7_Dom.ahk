
IE7_Get(title,url="http") ;returns DOM window handle
{
;~    title is required and is not case sensitive
;~    url is optional and since . exists in all url schemas it will allow un entered url to default to first found
;~  loop thru open windows for a match
   Loop, %   COM_Invoke(psw := COM_Invoke(psh := COM_CreateObject("Shell.Application"), "Windows"), "Count")
   {
      If ( InStr(tabname:=COM_Invoke(pwb:=COM_Invoke(psw, "Item", A_Index-1), "LocationName"),title,0)) && (InStr(taburl:=COM_Invoke(pwb:=COM_Invoke(psw, "Item", A_Index-1), "LocationURL"),url,0) ) {
         pwb:=COM_Invoke(psw, "Item", A_Index-1)
         doc:=COM_Invoke(pwb, "Document")
         parentWindow:=COM_Invoke(doc, "parentWindow")
   COM_Release(doc),COM_Release(taburl),COM_Release(tabname), COM_Release(pwb)
         Break
      }
   }
   COM_Release(psw), COM_Release(psh) ; release the objects each loop itineration
   if parentWindow is integer
   {
      return parentWindow
   }
   else{
      Return error   
   }
}

;~ Navigate the given window
IE7_Navigate(parentWindow,url) ; begins navigation process and holds execution till page has loaded fully returns DOM window handle 
{
;~    parent windw is a Dom window object
   if parentWindow is integer
   {   
      COM_Invoke(parentWindow, "Navigate",url) ;execute the navigation   
      IE7_readyState(parentWindow) ;Holds till document onload event is ready
      Return parentWindow
   }
   else{
      Return error   
   }
}


IE7_ExecuteJS(parentWindow, JS_to_Inject, VarNames_to_Return="") ;execute some js on a tab returns comma delimited list of vars if specified
{
   if parentWindow is integer
   {
      If JS_to_Inject
         COM_Invoke(parentWindow, "execScript","xxxxx=Math.random();" . JS_to_Inject)
      If VarNames_to_Return {
         StringSplit, Vars_, VarNames_to_Return, `,
         Loop, %Vars_0%
         Ret .= COM_Invoke(parentWindow,Vars_%A_Index%) . ","
         COM_Release(Ret)         
         StringTrimRight, Ret, Ret, 1
         Return Ret
      }
         Else
         Return 0
      }
   Else
      Return error
}
IE7_readyState(parentWindow) ;pauses till there is no loading activity returns DOM window handle
{
   
   
   if parentWindow is integer
   {
      doc:=COM_Invoke(parentWindow, "Document")
      
;~    MsgBox % COM_Invoke(parentWindow, "Document")   
      loop 120{ ;limit to 60 seconds
         Sleep, 500
         rdy:=IE7_ExecuteJS(parentWindow, "var rdy=document.readyState","rdy") ; best method
         If (rdy = "complete") ;Better to use the document readystate more consistent page load results
            break
         }
      COM_Release(doc)
      Return 0
   }
   else
      Return error   
   
}
IE7_Quit(parentWindow) ;Close a DOM window handle
{
   COM_Invoke(parentWindow, "execScript","window.opener='top';window.close();")
}

IE7_New(url) ;only if at least one IE window already exists return parentWindow js accessable object returns DOM window handle
{
   run http://Google.com
   winwait,Google
   pwb1:=IE7_Get("Google","http")
   pwb1:=IE7_Navigate(pwb1,url)
   return pwb1 ; object handle
}


IE7_Click_Text(parentWindow,innerHTML) ; searches a tags and clicks first text it finds to match returns error if not found will also trigger readystate
{
   js=
   (
      var links=document.links;
      var count=links.length;
   )
   
   count1 := IE7_ExecuteJS(parentWindow, js, "count")
   loop, % count1
   {
   
      js=
      (
         var text=document.links(%A_Index%-1).innerHTML;
      )
      text1 := IE7_ExecuteJS(parentWindow, js, "text")
      IfNotInString,text1,%innerHTML%
      Continue ;skip the rest and go to next loop
      js=
      (
         document.links(%A_Index%-1).click();
      )
      IE7_ExecuteJS(parentWindow, js)      
      Break
   }
IE7_readyState(parentWindow) ; wait for page change to finish
Return
}



IE7_Button_click(parentWindow,value) ;Searches input tags for type button then compares the value with the sought text if found clicks returns error if not found will also trigger readystate
{
   button_click=
   (
   var i=0;
   while (i<document.all.length)
   {
      var tag=document.all(i).tagName;
      if (tag.toLowerCase()=='input')
      {
         var typ=document.all(i).type
         if (typ.toLowerCase()=='button' || typ.toLowerCase()=='submit' || typ.toLowerCase()=='reset')
         {
            var myVal=document.all(i).value
            var theVal='%value%'
            if (myVal.toLowerCase()==theVal.toLowerCase())
            {
               document.all(i).click(); //click the button
               tag=undefined
               typ=undefined
               break; // end the loop
            }
         }
      }
      i=i+1;
   }

)
IE7_ExecuteJS(parentWindow, button_click)
IE7_readyState(parentWindow) ; wait for page change to finish
Return
}

;~ IE7_Get_DOM(parentWindow,ID,val="innerHTML",method="ID" )
;~ parentWindow assigned by IE7_Get(title,url="http") and must be an integer that represents a dom window handle
;~ ID will be an element id, index of all
IE7_Get_DOM(parentWindow,ID1) ;gets DOM object by ID Tag and returns string or error
{
   get_=
   (
   if (isNaN("%ID1%")){ // determins if an index or id is entered
         var tag=document.all("%ID1%").tagName
         var i=1;
      }else{ // must be an index
         var tag=document.all(%ID1%).tagName
         var i=2;
      }
   var tag1=tag.toLowerCase()
   
   

   switch(tag1)
      {
      case "input":
        var t=1;
        break;   
      case "textarea":
        var t=1;
        break;   
      case "select":
        var t=1;
        break;
      default:
        var t=2;
      }
   if(i==1 && t==1)
      var myVal=document.all("%ID1%").value;
   else if(i==2 && t==1)
      var myVal=document.all(%ID1%).value;
   else if(i==1 && t==2)
      var myVal=document.all("%ID1%").innerHTML;
   else if(i==2 && t==2)
      var myVal=document.all(%ID1%).innerHTML;
      
        var t=0;
        var i=0;
        var tag1=0;
        var tag=0;
   )
   myVal:=IE7_ExecuteJS(parentWindow, get_,"myVal")
   IE7_ExecuteJS(parentWindow, "var myVal='undefined';")
   Return myVal
}

IE7_Set_DOM(parentWindow,ID1,val="innerHTML") ;gets DOM object by ID Tag and returns string or error
{
   set_=
   (
   if (isNaN("%ID1%")){ // determins if an index or id is entered
         var tag=document.all("%ID1%").tagName
         var i=1;
      }else{ // must be an index
         var tag=document.all(%ID1%).tagName
         var i=2;
      }
   var tag1=tag.toLowerCase()
   
   

   switch(tag1)
      {
      case "input":
        var t=1;
        break;   
      case "textarea":
        var t=1;
        break;   
      case "select":
        var t=1;
        break;
      default:
        var t=2;
      }
   if(i==1 && t==1)
      document.all("%ID1%").value='%val%';
   else if(i==2 && t==1)
      document.all(%ID1%).value='%val%';
   else if(i==1 && t==2)
      document.all("%ID1%").innerHTML='%val%';
   else if(i==2 && t==2)
      document.all(%ID1%).innerHTML='%val%';
        var t=0;
        var i=0;
        var tag1=0;
        var tag=0;
   )
   IE7_ExecuteJS(parentWindow, set_)
   Return
}
; Physikengine PHY
; coded by IsNull
; date 2009/2010
/***************************************************
PHY_INIT(n = 1000)

n = count of max objects
****************************************************
*/
PHY_INIT(w,h,n = 1000){
global
	PHY_VER						:= 0.3
	PHY_MAX_WITH				:= w
	PHY_MAX_HEIGHT				:= h
	PHY_MAX_OBJECTS				:= n
	PHY_OBJECT_COUNT_static		:= 0
	PHY_OBJECT_COUNT_dynamic	:= 0
	PHY_VARIABLE_TYPE			:= "UInt"
	
	PHY_OBJECT_TYPE_LIST		:= "static,dynamic"
	PHY_EVENT_LIST				:= "PHY_COLLISION"
	
	VarSetCapacity(PHY_static_obj,PHY_MAX_OBJECTS*4,0)			;reserve some memory (UInt)
	VarSetCapacity(PHY_dynamic_obj,PHY_MAX_OBJECTS*4,0)			;reserve some memory (UInt)
	VarSetCapacity(PHY_COLLISION_MAP,PHY_MAX_OBJECTS,0)			;this is  a bool
	VarSetCapacity(PHY_COLLISION_MAP_INTERN,PHY_MAX_OBJECTS,0)	;this is  a bool
	VarSetCapacity(PHY_OBJECT_EVENT,PHY_MAX_OBJECTS,0)			;this is  a bool
	SetTimer, BLOCKWORLD_SYS_PHY_VEC, 30
	;SetTimer, BLOCKWORLD_SYS_PHY_GVY, 40
	return, 1
}
/***************************************************
defines for each PYH object the contact zones
****************************************************
*/
PHY_OBJECT_ADD(LISTTYPE,OBJECT_ID, x,  y,  w,  h,xvec=0,yvec=0,colfact=1,r=0){
global 	
	IF((PHY_MAX_OBJECTS =< PHY_OBJECT_COUNT_static) OR (PHY_MAX_OBJECTS =< PHY_OBJECT_COUNT_dynamic)){
		msgbox,64,PHY ERROR, PHY is out of Memory. Pleas init PHY with more possible Objects! 
		return, 0
	}

	If(!PHY_OBJECT_TYPE_CHECK(LISTTYPE)){
      msgbox,16,Blockworld Error, A unknown PHY_OBJECT_TYPE was specificed! 
      return, 0
    }
	
	;NumPut(Number, VarOrAddress [, Offset = 0, Type = "UInt"]) 
	IF(LISTTYPE = "static"){
		NumPut(OBJECT_ID,PHY_static_obj,PHY_OBJECT_COUNT_static * 4,"Uint")
		++PHY_OBJECT_COUNT_static
	}else if(LISTTYPE = "dynamic"){
		NumPut(OBJECT_ID,PHY_dynamic_obj,PHY_OBJECT_COUNT_dynamic * 4,"Uint")
		++PHY_OBJECT_COUNT_dynamic
	}else{
		return, 0
	}
	;msgbox PHY_QUAD_CREATE(%OBJECT_ID%, %x%,  %y%,  %w%,  %h%, %xvec%, %yvec%,%colfact%,%r%) 
	PHY_QUAD_CREATE(OBJECT_ID, x,  y,  w,  h, xvec, yvec,colfact,r)
} ;***************************************************


/***************************************************
PHY_OBJECT_REMOVE(OBJECT_ID,type)
___________________________________________________
Deletes a PHY Object
If type is empty, the object will be searched in
both Lists and removed.
This may cost a lot more performance.
****************************************************
*/
PHY_OBJECT_REMOVE(OBJECT_ID,_type = ""){
global
local PHY_static_obj_TMP, PHY_dynamic_obj_TMP, THIS_OBJECT, PHY_OBJECT_COUNT_dynamic_TMP, PHY_OBJECT_COUNT_static_TMP
	
	_type := _type = 0 ? "dynamic" : _type
	
	
	PHY_OBJECT_UPDATE(OBJECT_ID, 0,  0,  0,  0,0,0)	;clean the space from this object
	
	PHY_EVENT_LISTENER_REMOVE(OBJECT_ID)      		; dont handle anymore effects
	
	;We need 2 temporary lists
	VarSetCapacity(PHY_static_obj_TMP,PHY_MAX_OBJECTS*4,0)			;reserve some memory
	VarSetCapacity(PHY_dynamic_obj_TMP,PHY_MAX_OBJECTS*4,0)
	PHY_OBJECT_COUNT_static_TMP		:= 0
	PHY_OBJECT_COUNT_dynamic_TMP	:= 0


	
	;We have to delete it from PHY_**_obj List
	If((_type = "") or (_type = "dynamic")){
		;-----------------------------------------------------------------------------------------------------
		Loop, % PHY_OBJECT_COUNT_dynamic
		{
			THIS_OBJECT	:= NumGet(PHY_dynamic_obj,(a_index -1) * 4,"Uint")
			If(OBJECT_ID != THIS_OBJECT){	;we add only to the new list if its not the one to be removed
				NumPut(THIS_OBJECT,PHY_dynamic_obj_TMP,PHY_OBJECT_COUNT_dynamic_TMP * 4,"Uint")
				++PHY_OBJECT_COUNT_dynamic_TMP
			}
		}
		;Now we have a new List, and a updated counter
		PHY_OBJECT_COUNT_dynamic	:= PHY_OBJECT_COUNT_dynamic_TMP	; UPDATE the obj Counter
		DllCall("RtlMoveMemory","UInt",&PHY_dynamic_obj,"UInt",&PHY_dynamic_obj_TMP,"UInt",PHY_MAX_OBJECTS * 4)
		;------------------------------------------------------------------------------------------------------
	}
	If((_type = "") or (_type = "static")){
		;-----------------------------------------------------------------------------------------------------
		Loop, % PHY_OBJECT_COUNT_static
		{
			THIS_OBJECT	:= NumGet(PHY_static_obj,(a_index -1) * 4,"Uint")
			If(OBJECT_ID != THIS_OBJECT){	;we add only to the new list if its not the one to be removed
				NumPut(THIS_OBJECT,PHY_static_obj_TMP,PHY_OBJECT_COUNT_static_TMP * 4,"Uint")
				++PHY_OBJECT_COUNT_static_TMP
			}
		}
		;Now we have a new List, and a updated counter
		PHY_OBJECT_COUNT_static	:= PHY_OBJECT_COUNT_static_TMP	; UPDATE the obj Counter
		DllCall("RtlMoveMemory","UInt",&PHY_static_obj,"UInt",&PHY_static_obj_TMP,"UInt",PHY_MAX_OBJECTS * 4)
		;------------------------------------------------------------------------------------------------------
	}
}



/***************************************************
updates a PYH object (the contact zones,positions..)
****************************************************
*/
PHY_OBJECT_UPDATE(OBJECT_ID, x="",  y="",  w="",  h="",xvec="",yvec="",colfact="",r=""){
global 	
	If(x != ""){
		sNumPut(x, PHY_QUAD%OBJECT_ID%,0,"Int")				;x
	}
	If(y != ""){
		sNumPut(y, PHY_QUAD%OBJECT_ID%,4,"Int")				; y
	}
	If(w != ""){
		sNumPut(w, PHY_QUAD%OBJECT_ID%,8,"Uint")			; w
	}
	If(h != ""){
		sNumPut(h, PHY_QUAD%OBJECT_ID%,12,"Uint")			; h
	}
	
	IF(!SYS_PHY_CONTROLLIST_IS(OBJECT_ID)){    				; While PHY correct a object, no vector chacnes are allowed.
		If(xvec != ""){
			sNumPut(xvec, PHY_QUAD%OBJECT_ID%,16,"Int")		; x vector
		}
		If(yvec != ""){
			sNumPut(yvec, PHY_QUAD%OBJECT_ID%,20,"Int")		; y vector
		}
	}	
	If(colfact != ""){
		sNumPut(colfact, PHY_QUAD%OBJECT_ID%,24,"float")	; collision factor 
	}
	If(r != ""){
		sNumPut(r, PHY_QUAD%OBJECT_ID%,28,"Int")			; rotation
	}
		
	return, 1

} ;***************************************************


/*******************************************************
We use numget to only get 4Bytes - so no bufferoverflows 
will be produced.
********************************************************
*/
PHY_QUAD_CREATE(byref OBJECTID, x=0,  y=0,  w=0,  h=0,xvec=0,yvec=0,colfact=1,r=0){
global
	VarSetCapacity(PHY_QUAD%OBJECTID%,4*8,0)		; 32 bytes
	
	sNumPut(x, PHY_QUAD%OBJECTID%,0,"Int")			; x
	sNumPut(y, PHY_QUAD%OBJECTID%,4,"Int")			; y
	sNumPut(w, PHY_QUAD%OBJECTID%,8,"Uint")			; with
	sNumPut(h, PHY_QUAD%OBJECTID%,12,"Uint")		; height

	sNumPut(xvec, PHY_QUAD%OBJECTID%,16,"Int")			; xvec int because can be negative 
	sNumPut(yvec, PHY_QUAD%OBJECTID%,20,"Int")			; yvec
	sNumPut(colfact, PHY_QUAD%OBJECTID%,24,"float")		; xvec int because can be negative 
	sNumPut(r, PHY_QUAD%OBJECTID%,28,"Int")				; rotation
	
	return, 1
} ;****************************************************

/*********************************************************
PHY_EXECUTE_VECTORS()
__________________________________________________________
Looks up the existing Vectors and calc new pos
----------------------------------------------------------
We need only the dynamic objects - only these can be
moved around.
**********************************************************
*/
PHY_EXECUTE_VECTORS(){
global
local x,y, obj1
	Loop, % PHY_OBJECT_COUNT_dynamic
	{
		obj1 	:= NumGet(PHY_dynamic_obj,(a_index -1) * 4,"Uint")
		x		:= ""
		y 		:= ""
		
		xvec 	:= NumGet(PHY_QUAD%obj1%,16,"Int")	
		yvec 	:= NumGet(PHY_QUAD%obj1%,20,"Int")
		
		IF(!xvec and !yvec){
			Continue
		}
		;Note: This works also with negative numbers:
		; 99 = 100 + (-1)
		If(xvec != 0){	; If we have a x vector
			x 		:= NumGet(PHY_QUAD%obj1%,0,"Uint") + xvec
		}
	
		If(yvec != 0){ ; If we have a x vectoor
			y 		:= NumGet(PHY_QUAD%obj1%,4,"Uint") + yvec
		}
	
		;If we are out of the screen, we remove the objects from PHY
		PHY_OUT_OF_WORLD_D	:= 300 
		;------------------------------------------------------------
		If((x > (PHY_MAX_WITH + PHY_OUT_OF_WORLD_D)) or (y > (PHY_MAX_HEIGHT + PHY_OUT_OF_WORLD_D))){
			BLOCKWORLD_DELETE_OBJECT(obj1,"dynamic")
		}
		If(((x < (-1 * PHY_OUT_OF_WORLD_D)) and (x != "")) or ((y < (-1 * PHY_OUT_OF_WORLD_D))and (y != ""))){
			BLOCKWORLD_DELETE_OBJECT(obj1,"dynamic")
		}
		;------------------------------------------------------------
		
		PHY_OBJECT_UPDATE(obj1, x,  y)						; update the Object positions if needet
		BLOCKWORLD_QUADPOSINFORMATION_UPDATE(obj1, x,  y)	; BLOCKWORLD COPY same here
	}
}

/*********************************************************
PHY_COLLISION(byref dynamic_obj, byref static_obj)
__________________________________________________________

Parameters: 	Expected are arrays
----------------------------------------------------------
we test only dynamic objects against static objects
and maby dynamic objects against each other
**********************************************************
*/
PHY_COLLISION_LIST(){
global
local OBJECT_COLLIDATON_LIST,x1,y1,w1,h1,x2,y2,w2,h2,obj1,obj2

	;PHY_EXECUTE_VECTORS()		;Compute the new x/y positions of moving objects

	;see http://www.gamedev.net/reference/articles/article735.asp
	VarSetCapacity(PHY_COLLISION_MAP_INTERN,PHY_MAX_OBJECTS,0)	;delete intern map
	Loop, % PHY_OBJECT_COUNT_dynamic
	{
		obj1 	:= NumGet(PHY_dynamic_obj,(a_index -1) * 4,PHY_VARIABLE_TYPE)
		;--------------------------------------------------
		x1 	:= NumGet(PHY_QUAD%obj1%,0,"Int")	
		y1 	:= NumGet(PHY_QUAD%obj1%,4,"Int")
		w1 	:= NumGet(PHY_QUAD%obj1%,8,"UInt")	
		h1 	:= NumGet(PHY_QUAD%obj1%,12,"Uint")
		
		f1	:= NumGet(PHY_QUAD%obj1%,24,"float")
		
		;ToolTip, %f1%
		;msgbox x%x1% y%y1% w%w1% h%h1% f%f1%
		
		col_with1		:= w1 * f1
		col_height1		:= h1 * f1
		col_x_offset1 	:= (w1-col_with1)/2
		col_y_offset1	:= (h1-col_height1)/2
		
		Left1	:= x1 + col_x_offset1
		Right1	:= Left1 + col_with1
		Top1	:= y1 + col_y_offset1
		bottom1 := Top1 + col_height1
		;--------------------------------------------------
		;for each dynamic object collision with each static
		Loop, % PHY_OBJECT_COUNT_static
		{
			obj2 	:= NumGet(PHY_static_obj,(a_index -1) * 4,PHY_VARIABLE_TYPE)
			
			If(obj1 = obj2){
				Continue
			}
			;--------------------------------------------------
			x2 	:= NumGet(PHY_QUAD%obj2%,0,"Int")
			y2 	:= NumGet(PHY_QUAD%obj2%,4,"Int")
			w2 	:= NumGet(PHY_QUAD%obj2%,8,"Uint")
			h2 	:= NumGet(PHY_QUAD%obj2%,12,"Uint")
			f2	:= NumGet(PHY_QUAD%obj2%,24,"float")
			col_with2		:= w2 * f2
			col_height2		:= h2 * f2
			col_x_offset2 	:= (w2-col_with2)/2
			col_y_offset2	:= (h2-col_height2)/2
			
			Left2	:= x2 + col_x_offset2
			Right2	:= Left2 + col_with2
			Top2	:= y2 + col_y_offset2
			bottom2 := Top2 + col_height2			
			;--------------------------------------------------
			COLLISION := true
			if (bottom1 < top2) 
				COLLISION := false
			if (top1 > bottom2)
				COLLISION := false
			if (right1 < left2)
				COLLISION := false
			if (left1 > right2)
				COLLISION := false
			IF(COLLISION){
				;If we are here, the objects collide!
				OBJECT_COLLIDATON_LIST .= obj1 "|" obj2 ","	
				NumPut(1, PHY_COLLISION_MAP_INTERN, (obj1-1),"Char")
				NumPut(1, PHY_COLLISION_MAP_INTERN, (obj2-1),"Char")
			}
		}
		;For each dynamic object with each dynamic object
		Loop, % PHY_OBJECT_COUNT_dynamic
		{
			obj3 	:= NumGet(PHY_dynamic_obj,(a_index -1) * 4,PHY_VARIABLE_TYPE)
			If(obj1 = obj3){
				Continue
			}
			;--------------------------------------------------
			x3 	:= NumGet(PHY_QUAD%obj3%,0,PHY_VARIABLE_TYPE)
			y3 	:= NumGet(PHY_QUAD%obj3%,4,PHY_VARIABLE_TYPE)
			w3 	:= NumGet(PHY_QUAD%obj3%,8,PHY_VARIABLE_TYPE)
			h3 	:= NumGet(PHY_QUAD%obj3%,12,PHY_VARIABLE_TYPE)
			
			col_with3		:= w3 * 0.80
			col_height3		:= h3 * 0.80
			col_x_offset3 	:= (w3-col_with3)/2
			col_y_offset3	:= (h3-col_height3)/2
			
			Left3	:= x3 + col_x_offset3
			Right3	:= Left3 + col_with3
			Top3	:= y3 + col_y_offset3
			bottom3 := Top3 + col_height3			
			;--------------------------------------------------
			COLLISION := true
			if (bottom1 < top3) 
				COLLISION := false
			if (top1 > bottom3)
				COLLISION := false
			if (right1 < left3)
				COLLISION := false
			if (left1 > right3)
				COLLISION := false
			IF(COLLISION){
				;If we are here, the objects collide!
				OBJECT_COLLIDATON_LIST .= obj1 "|" obj3 ","	
				NumPut(1, PHY_COLLISION_MAP_INTERN, (obj1-1),"Char")
				NumPut(1, PHY_COLLISION_MAP_INTERN, (obj3-1),"Char")
			}
		}
	}
	;So we are done here, but first we have to copy the Intern Map over the public one:
	DllCall("RtlMoveMemory","UInt",&PHY_COLLISION_MAP,"UInt",&PHY_COLLISION_MAP_INTERN,"UInt",PHY_MAX_OBJECTS)
	return, % OBJECT_COLLIDATON_LIST
} ;*******************************************************


PHY_GRAVITY_SET(g=4){
global
	Loop, % PHY_OBJECT_COUNT_dynamic
	{
		obj1	:= NumGet(PHY_dynamic_obj,(a_index -1) * 4,"Uint")
		If(!NumGet(PHY_QUAD%obj1%,20,"Int")){
			PHY_OBJECT_UPDATE(obj1, "",  "",  "",  "","",g)
		}
	}
}


PHY_GET_OBJECT_COLLISION(OBJECT_ID){
global
	return,NumGet(PHY_COLLISION_MAP,(OBJECT_ID-1),"Char")
}

/***************************************************
Check if OBJECT_TYPE is a valid type
****************************************************
*/
PHY_OBJECT_TYPE_CHECK(OBJECT_TYPE){
global PHY_OBJECT_TYPE_LIST

If OBJECT_TYPE in %PHY_OBJECT_TYPE_LIST%
	return, 1
else
	return, 0
} ;*******************************************************

/*********************************************************************************************
Add a object to the event listener
object_id					The Object
callback_function			Functionname wich will be called
events						Events to listen to.
**********************************************************************************************
*/
PHY_EVENT_LISTENER_ADD(object_id,callback_function,event){
global
	If event not in %PHY_EVENT_LIST%
		return, 0
	NumPut(1,PHY_OBJECT_EVENT,(object_id -1),"char")					; true - we have a event
	PHY_COLLISION_LISTENER_%object_id%_CALL 	:= callback_function	; Define Callback function
	PHY_COLLISION_LISTENER_%object_id%_EVENTS 	:= event
	return, 1
} ;*******************************************************************************************

/*********************************************************************************************
PHY_EVENT_LISTENER_EXEC(object_list,eventtype)
object_list					Commaseparated List of 
callback_function			Functionname wich will be called
events						Events to listen to.
**********************************************************************************************
*/
PHY_EVENT_LISTENER_EXEC(object_one,event,object_two=""){
global
local sList,call_back
	
	If(!NumGET(PHY_OBJECT_EVENT,(object_one -1),"char")){
		return, 0	
	}
	sList := PHY_COLLISION_LISTENER_%object_one%_EVENTS
	If event in %sList%
	{
		call_back	:=	PHY_COLLISION_LISTENER_%object_one%_CALL
		%call_back%(object_one,event,object_two) 			;for example: OBJ_EVENT("collision",{with}"object33")
	}
	return, 1
} ;*******************************************************************************************

/*********************************************************************************************
remove a object from the event listener
object_id					The Object
callback_function			Functionname wich will be called
events						Events to listen to.
**********************************************************************************************
*/
PHY_EVENT_LISTENER_REMOVE(object_id){
global
	NEW_LIST	:= ""
	Loop, parse, PHY_COLLISION_LISTENER, `,
	{
		If((a_loopfield != object_id) AND (a_loopfield != "")){
			NEW_LIST .= a_loopfield
		}
	}
	NumPut(0,PHY_OBJECT_EVENT,(object_id -1),"char")
	PHY_COLLISION_LISTENER_%object_id%_CALL 	:= ""
	PHY_COLLISION_LISTENER_%object_id%_EVENTS 	:= ""
	return,1
} ;*******************************************************************************************

;###########################################################
;	Predefined Event Handler
;############################################################
PHY_EVENT_CORRECT_POSITION(SYS_PHY_OBJ1,EVENT,SYS_PHY_OBJ2){
global
         IF(SYS_PHY_CONTROLLIST_IS(SYS_PHY_OBJ2)){
            SYS_PHY_CONTROLLIST_ADD(SYS_PHY_OBJ2)
         }
         ;Dynamic Object [we have to query this first later]
         IF(!SYS_PHY_CONTROLLIST_IS(SYS_PHY_OBJ1)){     ;For the first turn here
            SYS_PHY_CONTROLLIST_ADD(SYS_PHY_OBJ1)
            ;All actions are blocked for this objects - we posite them now good:
            ;change action direction for once
            SYS_PHY_xvec 	:= NumGet(PHY_QUAD%SYS_PHY_OBJ1%,16,"Int")	
            SYS_PHY_yvec 	:= NumGet(PHY_QUAD%SYS_PHY_OBJ1%,20,"Int")
            
            ;Here is some locic needed.. but for now, we change simply the directions
            ; 0 * -1 = 0
            ; -1* -1 = 1
            ;1 * -1 = -1
            sNumPut(SYS_PHY_xvec * -1, PHY_QUAD%SYS_PHY_OBJ1%,16,"Int")				;x vector
            sNumPut(SYS_PHY_yvec * -1, PHY_QUAD%SYS_PHY_OBJ1%,20,"Int")				;y vector
        }    
return, 1
}
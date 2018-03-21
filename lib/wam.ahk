;;;;;;;;;;;;;;;;;;;;;;;
;;IUIAnimationManager;; 
;;;;;;;;;;;;;;;;;;;;;;;
class IUIAnimationManager extends IUnknown
{
  __new(){
		this.__:=ComObjCreate("{4C1FC63A-695C-47E8-A339-1A194BE3D0B8}","{9169896C-AC8D-4e7d-94E5-67FA4DC2F2E8}"),this._v:=NumGet(this.__+0)
	}

	; Creates a new animation variable.
	; The initial value of an animation variable is specified when the variable is created. After an animation variable is created, its value cannot be changed directly; it must be updated through the animation manager.
	; An animation variable is typically created to represent each visual characteristic that is to be animated. For example, an application might create two animation variables for the X and Y coordinates of an object that can move freely within a window.
	CreateAnimationVariable(initialValue){
		WAM_hr(DllCall(vt(this.__,3),"ptr",this.__
			,"double",initialValue
			,"ptr*",variable
			,"uint"),"CreateAnimationVariable")
		return new IUIAnimationVariable(variable)
	}

	; Creates and schedules a single-transition storyboard.
	; This method schedules a new storyboard by creating the storyboard, applying the specified transition to the specified variable, and then scheduling the storyboard.
	; Example creates a storyboard for a specified transition and animation variable. http://msdn.microsoft.com/en-us/library/windows/desktop/dd371728%28v=vs.85%29.aspx
	ScheduleTransition(variable,transition,timeNow){ ; IUIAnimationVariable , IUIAnimationTransition
		return WAM_hr(DllCall(vt(this.__,4),"ptr",this.__
			,"ptr",IsObject(variable)?variable.__:variable
			,"ptr",IsObject(transition)?transition.__:transition
			,"double",timeNow
			,"uint"),"ScheduleTransition")
	}

	; Creates a new storyboard.
	; Storyboards can specify complex coordinated updates to many animation variables. These updates happen in sequence or in parallel, and they are guaranteed to remain synchronized within the storyboard. A storyboard is created, populated with transitions on animation variables, and then scheduled. 
	CreateStoryboard(){
		WAM_hr(DllCall(vt(this.__,5),"ptr",this.__
			,"ptr*",storyboard
			,"uint"),"CreateStoryboard")
		return new IUIAnimationStoryboard(storyboard)
	}

	; Finishes all active storyboards within the specified time interval.
	; Calling FinishAllStoryboards ensures that all active storyboards finish within the specified completion deadline. If a storyboard is scheduled to play past the deadline, it is compressed. A storyboard is considered active if its status is UI_ANIMATION_STORYBOARD_PLAYING or UI_ANIMATION_STORYBOARD_SCHEDULED.
	FinishAllStoryboards(completionDeadline){ ; UI_ANIMATION_SECONDS
		return WAM_hr(DllCall(vt(this.__,6),"ptr",this.__
			,"double",completionDeadline
			,"uint"),"FinishAllStoryboards")
	}

	; Abandons all active storyboards.
	; Calling this method is equivalent to calling the IUIAnimationStoryboard::Abandon method for each active storyboard. A storyboard is considered active if its status is UI_ANIMATION_STORYBOARD_PLAYING or UI_ANIMATION_STORYBOARD_SCHEDULED.
	AbandonAllStoryboards(){
		return WAM_hr(DllCall(vt(this.__,7),"ptr",this.__,"uint"),"AbandonAllStoryboards")
	}

	; Updates the values of all animation variables.
	; Calling this method advances the animation manager to timeNow, changing statuses of storyboards as necessary and updating any animation variables to appropriate interpolated values. If the animation manager is paused, no storyboards or variables are updated. If the animation mode is UI_ANIMATION_MODE_DISABLED, all scheduled storyboards finish playing immediately. If the values of any variables change during this call, the value of updateResult is UI_ANIMATION_UPDATE_VARIABLES_CHANGED; otherwise, it is UI_ANIMATION_UPDATE_NO_CHANGE. 
	; Example updates the animation manager with the current time. http://msdn.microsoft.com/en-us/library/windows/desktop/dd371755%28v=vs.85%29.aspx
	Update(timeNow){ ; UI_ANIMATION_SECONDS
		WAM_hr(DllCall(vt(this.__,8),"ptr",this.__
			,"double",timeNow
			,"int*",updateResult
			,"uint"),"Update")
		return updateResult
	}

	; A tag is a pairing of an integer identifier (id) with a COM object (object). An application can use tags to identify animation variables and storyboards. NULL is a valid object component of a tag; therefore, the object parameter can be NULL.
	; Tags are not necessarily unique; this method returns UI_E_AMBIGUOUS_MATCH if more than one animation variable exists with the specified tag.

	; Gets the animation variable with the specified tag.
	GetVariableFromTag(object,id){
		WAM_hr(DllCall(vt(this.__,9),"ptr",this.__
			,"ptr",IsObject(object)?object.__:object
			,"uint",id
			,"ptr*",variable
			,"uint"),"GetVariableFromTag")
		return new IUIAnimationVariable(variable)
	}

	; Gets the storyboard with the specified tag.
	GetStoryboardFromTag(object,id){
		WAM_hr(DllCall(vt(this.__,10),"ptr",this.__
			,"ptr",IsObject(object)?object.__:object
			,"uint",id
			,"ptr*",storyboard
			,"uint"),"GetStoryboardFromTag")
		return new IUIAnimationStoryboard(storyboard)
	}

	; Gets the status of the animation manager.
	GetStatus(){
		WAM_hr(DllCall(vt(this.__,11),"ptr",this.__
			,"int*",status
			,"uint"),"GetStatus")
		return status
	}

	; Sets the animation mode.
	; This method is used to enable or disable animation globally. While animation is disabled, all storyboards finish immediately when they are scheduled. The default mode is UI_ANIMATION_MODE_SYSTEM_DEFAULT, which lets Windows decide when to enable or disable animation in the application.
	SetAnimationMode(mode){ ; UI_ANIMATION_MODE
		return WAM_hr(DllCall(vt(this.__,12),"ptr",this.__
			,"int",mode
			,"uint"),"SetAnimationMode")
	}

	; Pauses all animations.
	Pause(){
		return WAM_hr(DllCall(vt(this.__,13),"ptr",this.__,"uint"),"Pause")
	}

	; Resumes all animations.
	; When an animation manager is resumed, and at least one animation is currently scheduled or playing, its status is set to UI_ANIMATION_MANAGER_BUSY.
	Resume(){
		return WAM_hr(DllCall(vt(this.__,14),"ptr",this.__,"uint"),"Resume")
	}

	; Specifies a handler for animation manager status updates.
	; Passing NULL for the handler parameter causes Windows Animation to release its reference to any handler object that you passed in earlier. This technique can be essential for breaking reference cycles without having to call the IUIAnimationManager::Shutdown method.
	SetManagerEventHandler(handler){ ; IUIAnimationManagerEventHandler
		return WAM_hr(DllCall(vt(this.__,15),"ptr",this.__
			,"ptr",IsObject(handler)?handler.__:handler
			,"uint"),"SetManagerEventHandler")
	}

	; Setting a priority comparison handler with this method enables the application to indicate when scheduling conflicts can be resolved by canceling storyboards.
	; A scheduled storyboard can be canceled only if it has not started playing and the priority comparison object registered with this method returns S_OK. Canceled storyboards are completely removed from the schedule.
	; Passing NULL for the comparison parameter causes Windows Animation to release its reference to any priority comparison handler object you passed in earlier. This technique can be essential for breaking reference cycles without having to call the IUIAnimationManager::Shutdown method.

	; Sets the priority comparison handler to be called to determine whether a scheduled storyboard can be canceled.
	SetCancelPriorityComparison(comparison){ ; IUIAnimationPriorityComparison
		return WAM_hr(DllCall(vt(this.__,16),"ptr",this.__
			,"ptr",IsObject(comparison)?comparison.__:comparison
			,"uint"),"SetCancelPriorityComparison")
	}

	; Sets the priority comparison handler to be called to determine whether a scheduled storyboard can be trimmed.
	SetTrimPriorityComparison(comparison){ ; IUIAnimationPriorityComparison
		return WAM_hr(DllCall(vt(this.__,17),"ptr",this.__
			,"ptr",IsObject(comparison)?comparison.__:comparison
			,"uint"),"SetTrimPriorityComparison")
	}

	; Sets the priority comparison handler to be called to determine whether a scheduled storyboard can be compressed.
	SetCompressPriorityComparison(comparison){ ; IUIAnimationPriorityComparison
		return WAM_hr(DllCall(vt(this.__,18),"ptr",this.__
			,"ptr",IsObject(comparison)?comparison.__:comparison
			,"uint"),"SetCompressPriorityComparison")
	}

	; Sets the priority comparison handler to be called to determine whether a scheduled storyboard can be concluded.
	SetConcludePriorityComparison(comparison){ ; IUIAnimationPriorityComparison
		return WAM_hr(DllCall(vt(this.__,19),"ptr",this.__
			,"ptr",IsObject(comparison)?comparison.__:comparison
			,"uint"),"SetConcludePriorityComparison")
	}

	; Sets the default acceptable animation delay. This is the length of time that may pass before storyboards begin.
	SetDefaultLongestAcceptableDelay(delay){ ; UI_ANIMATION_SECONDS , UI_ANIMATION_SECONDS_EVENTUALLY (-1) to indicate that any finite delay is acceptable
		return WAM_hr(DllCall(vt(this.__,20),"ptr",this.__
			,"double",delay
			,"uint"),"SetDefaultLongestAcceptableDelay")
	}

	; Shuts down the animation manager and all its associated objects.
	; Calling this method directs the animation manager, and all the objects it created, to release all their pointers to other objects. After IUIAnimationManager::Shutdown has been called, no other methods may be called on the animation manager or any objects that it created. An application can call this method to clean up if there is any possibility that the application has introduced a reference cycle that includes some animation objects.
	Shutdown(){
		return WAM_hr(DllCall(vt(this.__,21),"ptr",this.__,"uint"),"Shutdown")
	}
}
;;;;;;;;;;;;;;;;;;;;;;;;
;;IUIAnimationVariable;;
;;;;;;;;;;;;;;;;;;;;;;;;
class IUIAnimationVariable extends IUnknown
{

	; Gets the current value of the animation variable.
	; The results can be affected by the lower and upper bounds determined by IUIAnimationVariable::SetLowerBound and IUIAnimationVariable::SetUpperBound, respectively.
	GetValue(){
		WAM_hr(DllCall(vt(this.__,3),"ptr",this.__
			,"double*",value
			,"uint"),"GetValue")
		return value
	}

	; The result can be affected by the lower and upper bounds determined by IUIAnimationVariable::SetLowerBound and IUIAnimationVariable::SetUpperBound, respectively.

	; Gets the final value of the animation variable. This is the value after all currently scheduled animations have completed.
	GetFinalValue(){
		WAM_hr(DllCall(vt(this.__,4),"ptr",this.__
			,"double*",finalValue
			,"uint"),"GetFinalValue")
		return finalValue
	}

	; Gets the previous value of the animation variable. This is the value of the animation variable before the most recent update.
	GetPreviousValue(){
		WAM_hr(DllCall(vt(this.__,5),"ptr",this.__
			,"double*",previousValue
			,"uint"),"GetPreviousValue")
		return previousValue
	}

	; To specify the rounding mode to be used when converting the value, use the IUIAnimationVariable::SetRoundingMode method.

	; Gets the current value of the animation variable as an integer.
	GetIntegerValue(){
		WAM_hr(DllCall(vt(this.__,6),"ptr",this.__
			,"int*",value
			,"uint"),"GetIntegerValue")
		return value
	}

	; Gets the final value of the animation variable as an integer. This is the value after all currently scheduled animations have completed.
	GetFinalIntegerValue(){
		WAM_hr(DllCall(vt(this.__,7),"ptr",this.__
			,"int*",finalValue
			,"uint"),"GetFinalIntegerValue")
		return finalValue
	}

	; Gets the previous value of the animation variable as an integer. This is the value of the animation variable before the most recent update.
	GetPreviousIntegerValue(){
		WAM_hr(DllCall(vt(this.__,8),"ptr",this.__
			,"int*",previousValue
			,"uint"),"GetPreviousIntegerValue")
		return previousValue
	}

	; Gets the storyboard that is currently animating the animation variable.
	GetCurrentStoryboard(){
		WAM_hr(DllCall(vt(this.__,9),"ptr",this.__
			,"ptr*",storyboard
			,"uint"),"GetCurrentStoryboard")
		return new IUIAnimationStoryboard(storyboard)
	}

	; Sets the lower bound (floor) for the animation variable. The value of the animation variable should not fall below the specified value.
	; An animation variable's rounding mode determines how a floating-point value is converted to an integer. The default mode for each variable is UI_ANIMATION_ROUNDING_NEAREST.
	SetLowerBound(bound){
		return WAM_hr(DllCall(vt(this.__,10),"ptr",this.__
			,"double",bound
			,"uint"),"SetLowerBound")
	}

	; Sets an upper bound (ceiling) for the animation variable. The value of the animation variable should not rise above the specified value.
	SetUpperBound(bound){
		return WAM_hr(DllCall(vt(this.__,11),"ptr",this.__
			,"double",bound
			,"uint"),"SetUpperBound")
	}

	; Specifies the rounding mode for the animation variable.
	SetRoundingMode(mode){ ; UI_ANIMATION_ROUNDING_MODE
		return WAM_hr(DllCall(vt(this.__,12),"ptr",this.__
			,"int",mode
			,"uint"),"SetRoundingMode")
	}

	; Sets the tag for an animation variable.
	; A tag is a pairing of an integer identifier (id) with a COM object (object); it can be used by an application to identify an animation variable. Because NULL is a valid object component of a tag, the object parameter can be NULL.
	SetTag(object,id){
		return WAM_hr(DllCall(vt(this.__,13),"ptr",this.__
			,"ptr",IsObject(object)?object.__:object
			,"uint",id
			,"uint"),"SetTag")
	}

	; Gets the tag for an animation variable.
	GetTag(){
		WAM_hr(DllCall(vt(this.__,14),"ptr",this.__
			,"ptr*",object
			,"uint*",id
			,"uint"),"GetTag")
		return [object,id] ; not completed
	}

	; Passing NULL for the handler parameter causes Windows Animation to release its reference to any handler object you passed in earlier. This technique can be essential for breaking reference cycles without having to call the IUIAnimationManager::Shutdown method.
	
	; Specifies a variable change handler. This handler is notified of changes to the value of the animation variable.
	SetVariableChangeHandler(handler){ ; IUIAnimationVariableIntegerChangeHandler
		return WAM_hr(DllCall(vt(this.__,15),"ptr",this.__
			,"ptr",handler
			,"uint"),"SetVariableChangeHandler")
	}

	; Specifies an integer variable change handler. This handler is notified of changes to the integer value of the animation variable.
	; IUIAnimationVariableIntegerChangeHandler::OnIntegerValueChanged is called only if the rounded value has changed since the last update.
	SetVariableIntegerChangeHandler(handler){ ; IUIAnimationVariableIntegerChangeHandler
		return WAM_hr(DllCall(vt(this.__,16),"ptr",this.__
			,"ptr",handler
			,"uint"),"SetVariableIntegerChangeHandler")
	}
}
;;;;;;;;;;;;;;;;;;;;;;;;;;
;;IUIAnimationStoryboard;;
;;;;;;;;;;;;;;;;;;;;;;;;;;
class IUIAnimationStoryboard extends IUnknown
{

	; Adds a transition to the storyboard.
	; The AddTransition method applies the specified transition to the specified variable in the storyboard. If this is the first transition applied to this variable in this storyboard, the transition begins at the start of the storyboard. Otherwise, the transition is appended to the transition that was most recently added to the variable.
	AddTransition(variable,transition){ ; IUIAnimationVariable , IUIAnimationTransition
		return WAM_hr(DllCall(vt(this.__,3),"ptr",this.__
			,"ptr",IsObject(variable)?variable.__:variable
			,"ptr",IsObject(transition)?transition.__:transition
			,"uint"),"AddTransition")
	}

	; Adds a keyframe at the specified offset from an existing keyframe.
	; A keyframe represents a moment in time within a storyboard and can be used to specify the start and end times of transitions. Because keyframes can be added at the ends of transitions, their offsets from the start of the storyboard may not be known until the storyboard is playing.
	; Example adds a keyframe at a fixed offset of 0.3 seconds from the keyframe at the start of the storyboard. http://msdn.microsoft.com/en-us/library/windows/desktop/dd371784
	AddKeyframeAtOffset(existingKeyframe,offset){
		WAM_hr(DllCall(vt(this.__,4),"ptr",this.__
			,"int",existingKeyframe
			,"double",offset
			,"int*",keyframe
			,"uint"),"AddKeyframeAtOffset")
		return keyframe
	}

	; Adds a keyframe at the end of the specified transition.
	AddKeyframeAfterTransition(transition){
		WAM_hr(DllCall(vt(this.__,5),"ptr",this.__
			,"ptr",IsObject(transition)?transition.__:transition
			,"int*",keyframe
			,"uint"),"AddKeyframeAfterTransition")
		return keyframe
	}

	; Transitions must be added in the order in which they will be played. A transition may begin playing before the preceding transition in the storyboard has finished, in which case the initial value and velocity seen by the new transition is determined by the state of the preceding one. A transition should not begin before the start of the preceding transition.
	; A keyframe represents a moment in time within a storyboard and can be used to specify the start and end times of transitions. Because keyframes can be added at the ends of transitions, their offsets from the start of the storyboard may not be known until the storyboard is playing.

	; Adds a transition that starts at the specified keyframe.
	AddTransitionAtKeyframe(variable,transition,startKeyframe){
		return WAM_hr(DllCall(vt(this.__,6),"ptr",this.__
			,"ptr",IsObject(variable)?variable.__:variable
			,"ptr",IsObject(transition)?transition.__:transition
			,"int",startKeyframe
			,"uint"),"AddTransitionAtKeyframe")
	}

	; Adds a transition between two keyframes.
	; This method applies the specified transition to the specified variable in the storyboard, with the transition starting and ending at the specified keyframes. If the transition was created with a duration parameter specified, that duration is overwritten with the duration of time between the start and end keyframes. Otherwise, Windows Animation speeds up or slows down the transition as necessary.
	AddTransitionBetweenKeyframes(variable,transition,startKeyframe,endKeyframe){
		return WAM_hr(DllCall(vt(this.__,7),"ptr",this.__
			,"ptr",IsObject(variable)?variable.__:variable
			,"ptr",IsObject(transition)?transition.__:transition
			,"int",startKeyframe
			,"int",endKeyframe
			,"uint"),"AddTransitionBetweenKeyframes")
	}

	; Creates a loop between two specified keyframes.
	RepeatBetweenKeyframes(startKeyframe,endKeyframe,repetitionCount=-1){ ; UI_ANIMATION_REPEAT_INDEFINITELY (-1) to repeat the loop indefinitely
		return WAM_hr(DllCall(vt(this.__,8),"ptr",this.__
			,"uint",startKeyframe
			,"uint",endKeyframe
			,"int",repetitionCount
			,"uint"),"RepeatBetweenKeyframes")
	}

	; Directs the storyboard to hold the specified animation variable at its final value until the storyboard ends.
	; When a storyboard is playing, it has exclusive access to any variables it animates unless the storyboard is trimmed by a higher priority storyboard. Typically, this exclusive access is released when the last transition in the storyboard for that variable finishes playing. Applications can call this method to maintain exclusive access to the animation variable and hold the variable, at the final value of the last transition, until the end of the storyboard.
	HoldVariable(variable){
		return WAM_hr(DllCall(vt(this.__,9),"ptr",this.__
			,"ptr",IsObject(variable)?variable.__:variable
			,"uint"),"HoldVariable")
	}

	; Sets the longest acceptable delay before the scheduled storyboard begins.
	; For a storyboard to be successfully scheduled, it must begin before the longest acceptable delay has elapsed. This delay is determined in the following order: the delay value set by calling this method, the delay value set by calling the IUIAnimationManager::SetDefaultLongestAcceptableDelay method, or 0.0 if neither of these methods has been called.
	SetLongestAcceptableDelay(delay){ ; UI_ANIMATION_SECONDS_EVENTUALLY (-1) to indicate that any finite delay is acceptable
		return WAM_hr(DllCall(vt(this.__,10),"ptr",this.__
			,"double",delay
			,"uint"),"SetLongestAcceptableDelay")
	}

	; Directs the storyboard to schedule itself for play.
	Schedule(timeNow){
		WAM_hr(DllCall(vt(this.__,11),"ptr",this.__
			,"double",timeNow
			,"int*",schedulingResult
			,"uint"),"Schedule")
		return schedulingResult ; UI_ANIMATION_SCHEDULING_RESULT
	}

	; Completes the current iteration of a keyframe loop that is in progress (where the loop is set to UI_ANIMATION_REPEAT_INDEFINITELY), terminates the loop, and continues with the storyboard. 
	; This method specifies that any subsequent keyframe loops that have a repetition count of UI_ANIMATION_REPEAT_INDEFINITELY (-1) will be skipped while the remainder of the storyboard is played. 
	; An iteration of a keyframe loop that is in progress will be completed before the remainder of the storyboard plays.
	; If this method is called at the end of a keyframe loop iteration, the loop is terminated and the loop value is set to the starting loop value.
	Conclude(){
		return WAM_hr(DllCall(vt(this.__,12),"ptr",this.__,"uint"),"Conclude")
	}

	; Finishes the storyboard within the specified time, compressing the storyboard if necessary.
	; This method has no effect on storyboard events. Events continue to be raised as expected while the storyboard plays.
	Finish(completionDeadline){
		return WAM_hr(DllCall(vt(this.__,13),"ptr",this.__
			,"double",completionDeadline
			,"uint"),"Finish")
	}

	; Terminates the storyboard, releases all related animation variables, and removes the storyboard from the schedule.
	; This method can be called before or after the storyboard starts playing. This method does not trigger any storyboard events.
	Abandon(){
		return WAM_hr(DllCall(vt(this.__,14),"ptr",this.__,"uint"),"Abandon")
	}

	; A tag is a pairing of an integer identifier (id) with a COM object (object); it can be used by an application to identify a storyboard.

	; Sets the tag for the storyboard.
	SetTag(object,id){
		return WAM_hr(DllCall(vt(this.__,15),"ptr",this.__
			,"ptr",IsObject(object)?object.__:object
			,"uint",id
			,"uint"),"SetTag")
	}

	; Gets the tag for a storyboard.
	; The parameters are optional so that the method can return both portions of the tag, or just the identifier or object portion.
	GetTag(){
		WAM_hr(DllCall(vt(this.__,16),"ptr",this.__
			,"ptr*",object
			,"uint*",id
			,"uint"),"GetTag")
		return [object,id]
	}

	; Gets the status of the storyboard.
	; Unless this method is called from a handler for OnStoryboardStatusChanged events, the only values it returns are UI_ANIMATION_STORYBOARD_BUILDING, UI_ANIMATION_STORYBOARD_SCHEDULED, UI_ANIMATION_STORYBOARD_PLAYING, and UI_ANIMATION_STORYBOARD_READY.
	GetStatus(){
		WAM_hr(DllCall(vt(this.__,17),"ptr",this.__
			,"int*",status
			,"uint"),"GetStatus")
		return status
	}

	; Gets the time that has elapsed since the storyboard started playing.
	GetElapsedTime(){
		WAM_hr(DllCall(vt(this.__,18),"ptr",this.__
			,"double*",elapsedTime
			,"uint"),"GetElapsedTime")
		return elapsedTime
	}

	; Specifies a handler for storyboard events.
	; Passing NULL for the handler parameter causes Windows Animation to release its reference to any handler object you passed in earlier. This technique can be essential for breaking reference cycles without having to call the IUIAnimationManager::Shutdown method.
	SetStoryboardEventHandler(handler){ ; IUIAnimationStoryboardEventHandler
		return WAM_hr(DllCall(vt(this.__,19),"ptr",this.__
			,"ptr",IsObject(handler)?handler.__:handler
			,"uint"),"SetStoryboardEventHandler")
	}
}
;;;;;;;;;;;;;;;;;;;;;;;;;;
;;IUIAnimationTransition;;
;;;;;;;;;;;;;;;;;;;;;;;;;;
class IUIAnimationTransition extends IUnknown
{

	; Sets the initial value for the transition.
	; This method should not be called after the transition has been added to a storyboard.
	SetInitialValue(value){
		return WAM_hr(DllCall(vt(this.__,3),"ptr",this.__,"double",value,"uint"),"SetInitialValue")
	}

	; Sets the initial velocity for the transition.
	; This method should not be called after the transition has been added to a storyboard.
	SetInitialVelocity(velocity){
		return WAM_hr(DllCall(vt(this.__,4),"ptr",this.__,"double",velocity,"uint"),"SetInitialVelocity")
	}

	; Determines whether a transition's duration is currently known.
	; This method should not be called when the storyboard to which the transition has been added is scheduled or playing.
	IsDurationKnown(){
		return WAM_hr(DllCall(vt(this.__,5),"ptr",this.__,"uint"),"IsDurationKnown")
	}

	; Gets the duration of the transition.
	; An application should typically call the IUIAnimationTransition::IsDurationKnown method before calling this method. This method should not be called when the storyboard to which the transition has been added is scheduled or playing.
	; Example shows how to get the duration of a transition. http://msdn.microsoft.com/en-us/library/windows/desktop/dd371951%28v=vs.85%29.aspx
	GetDuration(){
		WAM_hr(DllCall(vt(this.__,6),"ptr",this.__,"double*",duration,"uint"),"GetDuration")
		return duration
	}
}
;;;;;;;;;;;;;;;;;;;;;
;;IUIAnimationTimer;;
;;;;;;;;;;;;;;;;;;;;;
class IUIAnimationTimer extends IUnknown
{
	__new(){
		this.__:=ComObjCreate("{BFCD4A0C-06B6-4384-B768-0DAA792C380E}","{6B0EFAD1-A053-41d6-9085-33A689144665}"),this._v:=NumGet(this.__+0)
	}

	; Passing NULL for the updateHandler parameter causes Windows Animation to release its reference to any handler object you passed in earlier. This technique can be essential for breaking reference cycles without having to call the IUIAnimationManager::Shutdown method.

	; Specifies a timer update handler.
	; The timer update handler receives time updates (ticks) from the timer. The timer indicates an update by calling the IUIAnimationTimerUpdateHandler::OnUpdate method on the specified handler.
	SetTimerUpdateHandler(updateHandler,idleBehavior){ ; IUIAnimationTimerUpdateHandler , UI_ANIMATION_IDLE_BEHAVIOR
		return WAM_hr(DllCall(vt(this.__,3),"ptr",this.__
			,"ptr",IsObject(updateHandler)?updateHandler.__:updateHandler
			,"int",idleBehavior
			,"uint"),"SetTimerUpdateHandler")
	}

	; Specifies a timer event handler.
	; Timing events include the OnPreUpdate, OnPostUpdate, and OnRenderingTooSlow methods of the IUIAnimationTimerEventHandler interface.
	SetTimerEventHandler(handler){ ; IUIAnimationTimerEventHandler
		return WAM_hr(DllCall(vt(this.__,4),"ptr",this.__
			,"ptr",IsObject(handler)?handler.__:handler
			,"uint"),"SetTimerEventHandler")
	}

	; Enables the animation timer.
	Enable(){
		return WAM_hr(DllCall(vt(this.__,5),"ptr",this.__,"uint"),"Enable")
	}

	; Disables the animation timer.
	Disable(){
		return WAM_hr(DllCall(vt(this.__,6),"ptr",this.__,"uint"),"Disable")
	}

	; Determines whether the timer is currently enabled.
	IsEnabled(){
		return WAM_hr(DllCall(vt(this.__,7),"ptr",this.__,"uint"),"IsEnabled")
	}

	; Gets the current time.
	;This method can be used in both the application-driven and timer-driven configurations to retrieve the system time in UI_ANIMATION_SECONDS, the units used throughout the Windows Animation API.
	GetTime(){
		WAM_hr(DllCall(vt(this.__,8),"ptr",this.__
			,"double*",seconds
			,"uint"),"GetTime")
		return seconds
	}

	; Sets the frame rate below which the timer notifies the application that rendering is too slow.
	; If the rendering frame rate for an animation falls below the specified frame rate, an IUIAnimationTimerEventHandler::OnRenderingTooSlow event is raised.
	SetFrameRateThreshold(framesPerSecond){
		return WAM_hr(DllCall(vt(this.__,9),"ptr",this.__
			,"uint",framesPerSecond
			,"uint"),"SetFrameRateThreshold")
	}
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;IUIAnimationTransitionLibrary;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
class IUIAnimationTransitionLibrary extends IUnknown
{
	__new(){
		this.__:=ComObjCreate("{1D6322AD-AA85-4EF5-A828-86D71067D145}","{CA5A14B1-D24F-48b8-8FE4-C78169BA954E}"),this._v:=NumGet(this.__+0)
	}

	; Creates an instantaneous transition.
	; During an instantaneous transition, the value of the animation variable changes instantly from its current value to a specified final value. The duration of this transition is always zero.
	CreateInstantaneousTransition(finalValue){
		WAM_hr(DllCall(vt(this.__,3),"ptr",this.__
			,"double",finalValue
			,"ptr*",transition
			,"uint"),"CreateInstantaneousTransition")
		return new IUIAnimationTransition(transition)
	}

	; Creates a constant transition.
	; During a constant transition, the value of an animation variable remains at the initial value over the duration of the transition.
	CreateConstantTransition(duration){
		WAM_hr(DllCall(vt(this.__,4),"ptr",this.__
			,"double",duration
			,"ptr*",transition
			,"uint"),"CreateConstantTransition")
		return new IUIAnimationTransition(transition)
	}

	; Creates a discrete transition.
	; During a discrete transition, the animation variable remains at the initial value for a specified delay time, then switches instantaneously to a specified final value and remains at that value for a given hold time.
	CreateDiscreteTransition(delay,finalValue,hold){
		WAM_hr(DllCall(vt(this.__,5),"ptr",this.__
			,"double",delay
			,"double",finalValue
			,"double",hold
			,"ptr*",transition
			,"uint"),"CreateDiscreteTransition")
		return new IUIAnimationTransition(transition)
	}

	; Creates a linear transition.
	; During a linear transition, the value of the animation variable transitions linearly from its initial value to a specified final value.
	CreateLinearTransition(duration,finalValue){
		WAM_hr(DllCall(vt(this.__,6),"ptr",this.__
			,"double",duration
			,"double",finalValue
			,"ptr*",transition
			,"uint"),"CreateLinearTransition")
		return new IUIAnimationTransition(transition)
	}

	; Creates a linear-speed transition.
	; During a linear-speed transition, the value of the animation variable changes at a specified rate. The duration of the transition is determined by the difference between the initial value and the specified final value.
	CreateLinearTransitionFromSpeed(speed,finalValue){
		WAM_hr(DllCall(vt(this.__,7),"ptr",this.__
			,"double",speed
			,"double",finalValue
			,"ptr*",transition
			,"uint"),"CreateLinearTransitionFromSpeed")
		return new IUIAnimationTransition(transition)
	}

	; Creates a sinusoidal-velocity transition, with an amplitude determined by the initial velocity.
	; The value of the animation variable oscillates around the initial value over the entire duration of a sinusoidal-range transition. The amplitude of the oscillation is determined by the velocity when the transition begins.
	CreateSinusoidalTransitionFromVelocity(duration,period){
		WAM_hr(DllCall(vt(this.__,8),"ptr",this.__
			,"double",duration
			,"double",period
			,"ptr*",transition
			,"uint"),"CreateSinusoidalTransitionFromVelocity")
		return new IUIAnimationTransition(transition)
	}

	; Creates a sinusoidal-range transition, with a specified range of oscillation.
	; The value of the animation variable fluctuates between the specified minimum and maximum values over the entire duration of a sinusodial-range transition. The slope parameter is used to disambiguate between the two possible sine waves specified by the other parameters.
	CreateSinusoidalTransitionFromRange(duration,minimumValue,maximumValue,period,slope){
		WAM_hr(DllCall(vt(this.__,9),"ptr",this.__
			,"double",duration
			,"double",minimumValue
			,"double",maximumValue
			,"double",period
			,"double",slope
			,"ptr*",transition
			,"uint"),"CreateSinusoidalTransitionFromRange")
		return new IUIAnimationTransition(transition)
	}

	; Creates an accelerate-decelerate transition.
	; During an accelerate-decelerate transition, the animation variable speeds up and then slows down over the duration of the transition, ending at a specified value. You can control how quickly the variable accelerates and decelerates independently, by specifying different acceleration and deceleration ratios.
	; When the initial velocity is zero, the acceleration ratio is the fraction of the duration that the variable will spend accelerating; likewise with the deceleration ratio. If the initial velocity is nonzero, it is the fraction of the time between the velocity reaching zero and the end of transition. The acceleration ratio and the deceleration ratio should sum to a maximum of 1.0. 
	CreateAccelerateDecelerateTransition(duration,finalValue,accelerationRatio,decelerationRatio){
		WAM_hr(DllCall(vt(this.__,10),"ptr",this.__
			,"double",duration
			,"double",finalValue
			,"double",accelerationRatio
			,"double",decelerationRatio
			,"ptr*",transition
			,"uint"),"CreateAccelerateDecelerateTransition")
		return new IUIAnimationTransition(transition)
	}

	; Creates a reversal transition.
	; A reversal transition smoothly changes direction over the specified duration. The final value will be the same as the initial value and the final velocity will be the negative of the initial velocity.
	CreateReversalTransition(duration){
		WAM_hr(DllCall(vt(this.__,11),"ptr",this.__
			,"double",duration
			,"ptr*",transition
			,"uint"),"CreateReversalTransition")
		return new IUIAnimationTransition(transition)
	}

	; Creates a cubic transition.
	; During a cubic transition, the value of the animation variable changes from its initial value to a specified final value over the duration of the transition, ending at a specified velocity.
	CreateCubicTransition(duration,finalValue,finalVelocity){
		WAM_hr(DllCall(vt(this.__,12),"ptr",this.__
			,"double",duration
			,"double",finalValue
			,"double",finalVelocity
			,"ptr*",transition
			,"uint"),"CreateCubicTransition")
		return new IUIAnimationTransition(transition)
	}

	; Creates a smooth-stop transition.
	; A smooth-stop transition slows down as it approaches the specified final value, and reaches it with a velocity of zero. The duration of the transition is determined by the initial velocity, the difference between the initial and final values, and the specified maximum duration. If there is no solution consisting of a single parabolic arc, this method creates a cubic transition.
	CreateSmoothStopTransition(maximumDuration,finalValue){
		WAM_hr(DllCall(vt(this.__,13),"ptr",this.__
			,"double",maximumDuration
			,"double",finalValue
			,"ptr*",transition
			,"uint"),"CreateSmoothStopTransition")
		return new IUIAnimationTransition(transition)
	}

	; Creates a parabolic-acceleration transition.
	; During a parabolic-acceleration transition, the value of the animation variable changes from the initial value to the final value ending at the specified velocity. You can control how quickly the variable reaches the final value by specifying the rate of acceleration.
	CreateParabolicTransitionFromAcceleration(finalValue,finalVelocity,acceleration){
		WAM_hr(DllCall(vt(this.__,14),"ptr",this.__
			,"double",finalValue
			,"double",finalVelocity
			,"double",acceleration
			,"ptr*",transition
			,"uint"),"CreateParabolicTransitionFromAcceleration")
		return new IUIAnimationTransition(transition)
	}
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;IUIAnimationInterpolator;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
class IUIAnimationInterpolator extends IUnknown
{

	; Windows Animation always calls the SetInitialValueAndVelocity method to set the initial value and velocity before calling GetDuration, so a custom interpolator need not check whether the initial value and velocity have been set.
	; Windows Animation can call SetInitialValueAndVelocity multiple times with different parameters. Interpolators can cache internal state to improve performance, but they must update this cached state each time SetInitialValueAndVelocity is called and ensure that the results of subsequent calls to GetDuration reflect the updated state.

	; Sets the initial value and velocity at the start of the transition.
	SetInitialValueAndVelocity(initialValue,initialVelocity){
		return WAM_hr(DllCall(vt(this.__,3),"ptr",this.__
			,"double",initialValue
			,"double",initialVelocity
			,"uint"),"SetInitialValueAndVelocity")
	}

	; Sets the duration of the transition.
	; Windows Animation calls this method only after calling the GetDependencies method, and only if that call returns UI_ANIMATION_DEPENDENCY_DURATION as one of its durationDependencies flags.
	; Typically, an interpolator with a duration dependency will have a duration parameter in its associated creation method of IUIAnimationTransitionFactory. The interpolator should store its duration when first initialized and overwrite it when SetDuration is called.
	SetDuration(duration){
		return WAM_hr(DllCall(vt(this.__,4),"ptr",this.__
			,"double",duration
			,"uint"),"SetDuration")
	}

	; Gets the duration of a transition.
	GetDuration(){
		WAM_hr(DllCall(vt(this.__,5),"ptr",this.__
			,"double*",duration
			,"uint"),"GetDuration")
		return duration
	}

	; Gets the final value at the end of the transition.
	GetFinalValue(){
		WAM_hr(DllCall(vt(this.__,6),"ptr",this.__
			,"double*",value
			,"uint"),"GetFinalValue")
		return value
	}

	; Interpolates the value of an animation variable at the specified offset.
	InterpolateValue(offset){
		WAM_hr(DllCall(vt(this.__,7),"ptr",this.__
			,"double",offset
			,"double*",value
			,"uint"),"InterpolateValue")
		return value
	}

	; Interpolates the velocity, or rate of change, at the specified offset.
	InterpolateVelocity(offset){
		WAM_hr(DllCall(vt(this.__,8),"ptr",this.__
			,"double",offset
			,"double*",velocity
			,"uint"),"InterpolateVelocity")
		return velocity
	}

	; Gets the aspects of the interpolator that depend on the initial value or velocity passed to SetInitialValueAndVelocity, or that depend on the duration passed to SetDuration.
/*
	This method is called to identify which aspects of the custom interpolator are affected by certain inputs: value, velocity, and duration. For each of these inputs, the interpolator returns either of the following:
    The bitwise-OR of any members of UI_ANIMATION_DEPENDENCIES that apply.
    UI_ANIMATION_DEPENDENCY_NONE if nothing depends on the input.
	For example, consider an interpolator (1) that accepts a final value as a parameter, (2) that always comes to a gradual stop at that final value, and (3) whose duration is determined by the difference between the final and initial values. The interpolator should return UI_ANIMATION_DEPENDENCY_INTERMEDIATE_VALUES|UI_ANIMATION_DURATION for initialValueDependencies. It should not return UI_ANIMATION_DEPENDENCY_FINAL_VALUE because this is set when the interpolator is created and is not affected by the initial value. Likewise it should not return UI_ANIMATION_DEPENDENCY_FINAL_VELOCITY because the slope of the curve is defined to always be zero when it reaches the final value.
	It is important that an interpolator return correct set of flags. If a flag is not present for an output, Windows Animation assumes that the corresponding parameter does not affect that aspect of the interpolator's results. For example, if the custom interpolator does not include UI_ANIMATION_DEPENDENCY_FINAL_VALUE for initialVelocityDependencies, Windows Animation may call SetInitialValueAndVelocity with an arbitrary velocity parameter, then call GetFinalValue to determine the final value. The interpolator's implementation of GetFinalValue must return the same result no matter what velocity parameter has been passed to SetInitialValueAndVelocity because the interpolator has claimed that the transition's final value does not depend on the initial velocity.
	Note  If the flags returned for durationDependencies do not include UI_ANIMATION_DEPENDENCY_DURATION, SetDuration will never be called on the interpolator.
*/
	GetDependencies(){
		WAM_hr(DllCall(vt(this.__,9),"ptr",this.__
			,"int*",initialValueDependencies
			,"int*",initialVelocityDependencies
			,"int*",durationDependencies
			,"uint"),"GetDependencies")
		return [initialValueDependencies,initialVelocityDependencies,durationDependencies]
	}
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;IUIAnimationTransitionFactory;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
class IUIAnimationTransitionFactory extends IUnknown
{
	__new(){
		this.__:=ComObjCreate("{4C1FC63A-695C-47E8-A339-1A194BE3D0B8}","{9169896C-AC8D-4e7d-94E5-67FA4DC2F2E8}"),this._v:=NumGet(this.__+0)
	}

	; Creates a transition from a custom interpolator.
	CreateTransition(interpolator){
		WAM_hr(DllCall(this.vt(3),"ptr",this.__
			,"ptr",IsObject(interpolator)?interpolator.__:interpolator
			,"ptr*",transition
			,"uint"),"CreateTransition")
		return new IUIAnimationTransition(transition)
	}
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;IUIAnimationPriorityComparison;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
class IUIAnimationPriorityComparison extends IUnknown
{
  iid := "{83FA9B74-5F86-4618-BC6A-A2FAC19B3F44}"

	; Determines whether a new storyboard has priority over a scheduled storyboard.
	; More Important Remarks, http://msdn.microsoft.com/en-us/library/windows/desktop/dd371759%28v=vs.85%29.aspx
	HasPriority(scheduledStoryboard,newStoryboard,priorityEffect){
		return WAM_hr(DllCall(this.vt(3),"ptr",this.__
			,"ptr",IsObject(scheduledStoryboard)?scheduledStoryboard.__:scheduledStoryboard
			,"ptr",IsObject(newStoryboard)?newStoryboard.__:newStoryboard
			,"int",priorityEffect
			,"uint"),"HasPriority")
	}
}
;;;;;;;;;;;;;;;;;;;;;
;;Wrapped Functions;;
;;;;;;;;;;;;;;;;;;;;;
; Create Animation Transition
CreateTransition(interpolator){
	static pFactory:=ComObjCreate("{8A9B1CDD-FCD7-419c-8B44-42FD17DB1887}","{FCD91E03-3E3B-45ad-BBB1-6DFC8153743D}")
	WAM_hr(DllCall(vt(pFactory,3),"ptr",pFactory,"ptr",IsObject(interpolator)?interpolator.__:interpolator,"ptr*",transition,"uint"),"CreateTransition")
	return new IUIAnimationTransition(transition)
}
;;;;;;;;;;;;;;;
;;EventHandle;;
;;;;;;;;;;;;;;;
WAM_event(ptr,type,p*){
	static _t:={ManagerEvent:1,VariableChange:1,VariableIntegerChange:1,StoryboardEvent:2,TimerUpdate:3,TimerClientEvent:1,TimerEvent:3}
		,_d:=RegisterCallback("_Default_Handler","F")
	if InStr(type,"/")=1
		type:=SubStr(type,2),index:=3
	else index:=0
	if !_t.haskey(type){
		msgbox %type% is not supported.
		return
	}
	VarSetCapacity(ptr,(_t[type]+3)*A_PtrSize)
	NumPut(&ptr+A_PtrSize,ptr)
	if index
		loop % _t[type]+3
			NumPut(IsFunc(p[A_Index])?RegisterCallback(p[A_Index],"F"):_d,ptr,A_PtrSize*A_Index)
	else{
		NumPut(_d,ptr,A_PtrSize*1),NumPut(_d,ptr,A_PtrSize*2),NumPut(_d,ptr,A_PtrSize*3)
		loop % _t[type]
			NumPut(IsFunc(p[A_Index])?RegisterCallback(p[A_Index],"F"):_d,ptr,A_PtrSize*(A_Index+3))
	}
	return &ptr
}
_Default_Handler(p*){
	return 0 ; 0x80004002 for querinterface?
}
/*	Sample handle function
	; ManagerEvent
	OnManagerStatusChanged(newStatus,previousStatus){
		return 0
	}
	; VariableChange
	OnValueChanged(storyboard,variable,newValue,previousValue){
		return 0
	}
	; VariableIntegerChange
	OnIntegerValueChanged(storyboard,variable,newValue,previousValue){
		return 0
	}
	; StoryboardEvent
	OnManagerStatusChanged(newStatus,previousStatus){
		return 0
	}
	; TimerUpdate
	OnUpdate(timeNow,result){ ; [out] result 
		return 0
	}
	SetTimerClientEventHandler(handler){
		return 0
	}
	ClearTimerClientEventHandler(){
		return 0
	}
	; TimerClientEvent
	OnTimerClientStatusChanged(newStatus,previousStatus){
		return 0
	}
	; TimerEvent
	OnPreUpdate(){
		return 0
	}
	OnPostUpdate(){
		return 0
	}
	OnRenderingTooSlow(framesPerSecond){
		return 0
	}
*/
WAM_Constant(type){
	static init:=1,_:=[]
	if init{
		init:=0
		 _["UI_ANIMATION_SECONDS_EVENTUALLY"]:= -1 
		,_["UI_ANIMATION_KEYFRAME_STORYBOARD_START"]:= ( UI_ANIMATION_KEYFRAME  
		,_["UI_ANIMATION_REPEAT_INDEFINITELY"]:= -1 
		,_["UI_ANIMATION_UPDATE_NO_CHANGE"]:=0
		,_["UI_ANIMATION_UPDATE_VARIABLES_CHANGED"]:=1
		,_["UI_ANIMATION_MANAGER_IDLE"]:=0
		,_["UI_ANIMATION_MANAGER_BUSY"]:=1
		,_["UI_ANIMATION_MODE_DISABLED"]:=0
		,_["UI_ANIMATION_MODE_SYSTEM_DEFAULT"]:=1
		 _["UI_ANIMATION_MODE_ENABLED"]:=2
		,_["UI_ANIMATION_ROUNDING_NEAREST"]:=0
		,_["UI_ANIMATION_ROUNDING_FLOOR"]:=1
		,_["UI_ANIMATION_ROUNDING_CEILING"]:=2
		,_["UI_ANIMATION_STORYBOARD_BUILDING"]:=0
		,_["UI_ANIMATION_STORYBOARD_SCHEDULED"]:=1
		,_["UI_ANIMATION_STORYBOARD_CANCELLED"]:=2
		,_["UI_ANIMATION_STORYBOARD_PLAYING"]:=3
		,_["UI_ANIMATION_STORYBOARD_TRUNCATED"]:=4
		,_["UI_ANIMATION_STORYBOARD_FINISHED"]:=5
		 _["UI_ANIMATION_STORYBOARD_READY"]:=6
		,_["UI_ANIMATION_STORYBOARD_INSUFFICIENT_PRIORITY"]:=7
		,_["UI_ANIMATION_SCHEDULING_UNEXPECTED_FAILURE"]:=0
		,_["UI_ANIMATION_SCHEDULING_INSUFFICIENT_PRIORITY"]:=1
		,_["UI_ANIMATION_SCHEDULING_ALREADY_SCHEDULED"]:=2
		,_["UI_ANIMATION_SCHEDULING_SUCCEEDED"]:=3
		,_["UI_ANIMATION_SCHEDULING_DEFERRED"]:=4
		,_["UI_ANIMATION_PRIORITY_EFFECT_FAILURE"]:=0
		,_["UI_ANIMATION_PRIORITY_EFFECT_DELAY"]:=1
		,_["UI_ANIMATION_SLOPE_INCREASING"]:=0
		 _["UI_ANIMATION_SLOPE_DECREASING"]:=1
		,_["UI_ANIMATION_DEPENDENCY_NONE"]:=0
		,_["UI_ANIMATION_DEPENDENCY_INTERMEDIATE_VALUES"]:=0x1
		,_["UI_ANIMATION_DEPENDENCY_FINAL_VALUE"]:=0x2
		,_["UI_ANIMATION_DEPENDENCY_FINAL_VELOCITY"]:=0x4
		,_["UI_ANIMATION_DEPENDENCY_DURATION"]:=0x8
		,_["UI_ANIMATION_IDLE_BEHAVIOR_CONTINUE"]:=0
		,_["UI_ANIMATION_IDLE_BEHAVIOR_DISABLE"]:=1
		,_["UI_ANIMATION_TIMER_CLIENT_IDLE"]:=0
		,_["UI_ANIMATION_TIMER_CLIENT_BUSY"]:=1
	}
	return _[type]
}
WAM_hr(a,ByRef b){
	static init:=1,err:=[]
	if init{
		init:=0
		 err[0x802A0001]:="UI_E_CREATE_FAILED"
		,err[0x802A0002]:="UI_E_SHUTDOWN_CALLED"
		,err[0x802A0003]:="UI_E_ILLEGAL_REENTRANCY"
		,err[0x802A0004]:="UI_E_OBJECT_SEALED"
		,err[0x802A0005]:="UI_E_VALUE_NOT_SET"
		,err[0x802A0006]:="UI_E_VALUE_NOT_DETERMINED"
		,err[0x802A0007]:="UI_E_INVALID_OUTPUT"
		,err[0x802A0008]:="UI_E_BOOLEAN_EXPECTED"
		,err[0x802A0009]:="UI_E_DIFFERENT_OWNER"
		,err[0x802A000A]:="UI_E_AMBIGUOUS_MATCH"
		,err[0x802A000B]:="UI_E_FP_OVERFLOW"
		,err[0x802A000C]:="UI_E_WRONG_THREAD"
		,err[0x802A0101]:="UI_E_STORYBOARD_ACTIVE"
		,err[0x802A0102]:="UI_E_STORYBOARD_NOT_PLAYING"
		,err[0x802A0103]:="UI_E_START_KEYFRAME_AFTER_END"
		,err[0x802A0104]:="UI_E_END_KEYFRAME_NOT_DETERMINED"
		,err[0x802A0105]:="UI_E_LOOPS_OVERLAP"
		,err[0x802A0106]:="UI_E_TRANSITION_ALREADY_USED"
		,err[0x802A0107]:="UI_E_TRANSITION_NOT_IN_STORYBOARD"
		,err[0x802A0108]:="UI_E_TRANSITION_ECLIPSED"
		,err[0x802A0109]:="UI_E_TIME_BEFORE_LAST_UPDATE"
		,err[0x802A010A]:="UI_E_TIMER_CLIENT_ALREADY_CONNECTED"
	}
	if a && (a&=0xFFFFFFFF)
		msgbox, % b " : " (err.haskey(a)?err[a]:_error(a,b))
	return a
}

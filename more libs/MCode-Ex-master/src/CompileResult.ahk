class CompileResult {
	__New() {
		this.segments		:= []
		this.references	:= {}
	}
	
	__Delete() {
		for each, segment in this.segments {
			segment._delete()
		}
		for each, reference in this.references {
			reference._delete()
		}
	}
	
	getReferences() {
		return this.references
	}
	
	getSegements() {
		return this.segments
	} 
	
	getFunctions()  {
		funcs := []
		for each, reference in this.getReferences() {
			if reference.isFunc() {
				funcs.push(reference)
			}
		}
		return funcs
	}
	
	addSegment(type, data:="", containedReferences := "", relocations := "") {
		segmentClass := this.Segment
		segment := new segmentClass(type, data, containedReferences, relocations)
		this.segments.push(segment)
		return segment
	}
	
	addReference(name, extern := false,  function := false) {
		if this.references.hasKey(name)
			throw exception("duplicate reference error: " . name, -1)
		referenceClass := this.Reference
		reference := new referenceClass(name, extern, function)
		this.references[name] := reference
		return reference
	}
	
	setReferencePosition(reference, segment, position) {
		if !isObject(reference){
			if !this.references.hasKey(reference)
				throw exception("invalid reference", -1)
			else
				reference := this.references[reference]
		}
		reference.setData(segment, position)
		segment.addContainedReference(reference, position)
	}
	
	addRelocation(reference, segment, position) {
		if !isObject(reference){
			if !this.references.hasKey(reference)
				throw exception("invalid reference", -1)
			else
				reference := this.references[reference]
		}
		reference.addMention(segment, position)
		segment.addRelocation(reference, position)
	}
	
	class Segment {
		static types := {_TEXT:1, CONST:1, _DATA:1, _BSS:1}
		
		__New(type, data := "", containedReferences := "", relocations := "") {
			if (!type || !this.types[type]) {
				throw exception("unsupported segment type : """ . type . """")
			}
			if (!data) { 
				data := new Binary()
			}
			if (!containedReferences ) {
				containedReferences  := {}
			}
			if (!relocations) {
				relocations := []
			}
			this.type					:= type
			this.data					:= data
			this.containedReferences 	:= containedReferences 
			this.relocations			:= relocations
		}
		
		getData() {
			return this.data
		}
		
		getContainedReferences() {
			return this.containedReferences
		}
		
		getRelocations() {
			return this.relocations
		}
		
		addContainedReference(reference, position) {
			this.containedReferences[reference.getName()] := reference
		}
		
		addRelocation(reference, position) {
			this.relocations.push({reference:reference, position:position})
		}
		
		_delete() {
			this.relocations := ""
			this.containedReferences := ""
		}
	}
	
	class Reference {
		__New(name, extern := false,  function := false) {
			this.name			:= name
			this.mentions		:= []
			this.extern		:= extern
			this.function		:= function
		}
		
		getName() {
			return this.name
		}
		
		getData() {
			if this.hasKey("segment")
				return {segment:this.segment, position:this.position}
		}
		
		isFunction() {
			return this.function
		}
		
		isFunc() {
			return this.function
		}
		
		setData(segment, position) {
			this.segment  := segment
			this.position := position
		}
		
		addMention(segment, position) {
			this.mentions.push({segment:segment, position:position})
		}
		
		setFunction(functionFlag := true) {
			this.function := functionFlag
		}
		
		_Delete() {
			this.segment	:= ""
			this.mentions	:= ""
		}
	}
	
}
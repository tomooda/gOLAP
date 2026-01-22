Extension { #name : 'GolapNodeEvaluator' }

{ #category : '*Golap-Project' }
GolapNodeEvaluator >> asJSON [

	^ { (self tag -> self subtag) } asOrderedDictionary
]

{ #category : '*Golap-Project' }
GolapNodeEvaluator class >> fromJSON: aDictionary [

	self allSubclassesDo: [ :subclass |
		subclass isAbstract not ifTrue: [
			(subclass fromJSON: aDictionary) ifNotNil: [ :evaluator |
				^ evaluator ] ] ].
	^ nil
]

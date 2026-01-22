Extension { #name : 'GolapEdgeEvaluator' }

{ #category : '*Golap-Project' }
GolapEdgeEvaluator >> asJSON [

	^ { (self tag -> self subtag) } asOrderedDictionary
]

{ #category : '*Golap-Project' }
GolapEdgeEvaluator class >> fromJSON: aDictionary [

	self allSubclassesDo: [ :subclass |
		subclass isAbstract not ifTrue: [
			(subclass fromJSON: aDictionary) ifNotNil: [ :evaluator |
				^ evaluator ] ] ].
	^ nil
]

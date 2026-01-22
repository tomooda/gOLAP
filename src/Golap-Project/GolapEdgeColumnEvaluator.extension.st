Extension { #name : 'GolapEdgeColumnEvaluator' }

{ #category : '*Golap-Project' }
GolapEdgeColumnEvaluator class >> fromJSON: aDictionary [

	^ aDictionary
		  at: self tag
		  ifPresent: [ :column | self column: column ]
		  ifAbsent: [ nil ]
]

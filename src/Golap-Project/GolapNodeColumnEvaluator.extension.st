Extension { #name : 'GolapNodeColumnEvaluator' }

{ #category : '*Golap-Project' }
GolapNodeColumnEvaluator class >> fromJSON: aDictionary [

	^ aDictionary
		  at: self tag
		  ifPresent: [ :column | self column: column ]
		  ifAbsent: [ nil ]
]

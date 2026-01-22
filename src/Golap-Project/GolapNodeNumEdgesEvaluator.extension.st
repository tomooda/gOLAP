Extension { #name : 'GolapNodeNumEdgesEvaluator' }

{ #category : '*Golap-Project' }
GolapNodeNumEdgesEvaluator class >> fromJSON: aDictionary [

	^ aDictionary at: self tag ifPresent: [ self new ] ifAbsent: [ nil ]
]

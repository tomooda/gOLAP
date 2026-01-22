Extension { #name : 'GolapNodeAggregationEvaluator' }

{ #category : '*Golap-Project' }
GolapNodeAggregationEvaluator class >> fromJSON: aDictionary [

	^ aDictionary
		  at: self tag
		  ifPresent: [ :subtag |
			  subtag = self subtag
				  ifTrue: [ self new ]
				  ifFalse: [ nil ] ]
		  ifAbsent: [ nil ]
]

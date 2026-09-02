Extension { #name : 'GolapEdgeColumnEvaluator' }

{ #category : '*Golap-Project' }
GolapEdgeColumnEvaluator >> asJSON [

	^ super asJSON
		  at: 'column' put: column;
		  yourself
]

{ #category : '*Golap-Project' }
GolapEdgeColumnEvaluator class >> fromJSON: aDictionary [

	^ aDictionary
		  at: self tag
		  ifPresent: [ :column |
				  (self column: column)
					  fromJSON: aDictionary;
					  yourself ]
		  ifAbsent: [ nil ]
]

{ #category : '*Golap-Project' }
GolapEdgeColumnEvaluator >> fromJSON: aDictionary [

	super fromJSON: aDictionary.
	aDictionary at: 'column' ifPresent: [ :string | column := string ]
]

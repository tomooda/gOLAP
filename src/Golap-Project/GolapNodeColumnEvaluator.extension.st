Extension { #name : 'GolapNodeColumnEvaluator' }

{ #category : '*Golap-Project' }
GolapNodeColumnEvaluator >> asJSON [

	^ super asJSON
		  at: 'column' put: column;
		  yourself
]

{ #category : '*Golap-Project' }
GolapNodeColumnEvaluator class >> fromJSON: aDictionary [

	^ aDictionary
		  at: self tag
		  ifPresent: [ :column |
				  (self column: column)
					  fromJSON: aDictionary;
					  yourself ]
		  ifAbsent: [ nil ]
]

{ #category : '*Golap-Project' }
GolapNodeColumnEvaluator >> fromJSON: aDictionary [

	super fromJSON: aDictionary.
	aDictionary at: 'column' ifPresent: [ :string | column := string ]
]

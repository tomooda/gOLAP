Extension { #name : 'GolapNodeEvaluator' }

{ #category : '*Golap-Project' }
GolapNodeEvaluator >> asJSON [

	^ {
		  (self tag -> self subtag).
		  ('min' -> min).
		  ('max' -> max).
		  ('lower-threshold' -> lowerThreshold).
		  ('upper-threshold' -> upperThreshold) } asOrderedDictionary
]

{ #category : '*Golap-Project' }
GolapNodeEvaluator class >> fromJSON: aDictionary [

	self allSubclassesDo: [ :subclass |
			subclass isAbstract not ifTrue: [
				(subclass fromJSON: aDictionary) ifNotNil: [ :evaluator |
					^ evaluator ] ] ].
	^ nil
]

{ #category : '*Golap-Project' }
GolapNodeEvaluator >> fromJSON: aDictionary [

	aDictionary
		at: 'min' ifPresent: [ :num | min := num ];
		at: 'max' ifPresent: [ :num | max := num ];
		at: 'lower-threshold' ifPresent: [ :num | lowerThreshold := num ];
		at: 'upper-threshold' ifPresent: [ :num | upperThreshold := num ]
]

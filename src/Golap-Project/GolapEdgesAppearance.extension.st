Extension { #name : 'GolapEdgesAppearance' }

{ #category : '*Golap-Project' }
GolapEdgesAppearance >> asJSON [

	| json |
	json := Dictionary new.
	json at: 'friend' put: friendNumberField number.
	edgeEvaluatorList selectedItem ifNotNil: [ :edgeEvaluator | json at: 'edge-evaluator' put: edgeEvaluator asJSON ].
	nodeEvaluatorList selectedItem ifNotNil: [ :nodeEvaluator | json at: 'node-evaluator' put: nodeEvaluator asJSON ].
	^ json
]

{ #category : '*Golap-Project' }
GolapEdgesAppearance >> fromJSON: aDictionary [

	aDictionary
		at: 'friend' ifPresent: [ :int | friendNumberField number: int ];
		at: 'edge-evaluator' ifPresent: [ :dict | self edgeEvaluator: (GolapEdgeEvaluator fromJSON: dict) ];
		at: 'node-evaluator' ifPresent: [ :dict | self nodeEvaluator: (GolapNodeEvaluator fromJSON: dict) ]
]

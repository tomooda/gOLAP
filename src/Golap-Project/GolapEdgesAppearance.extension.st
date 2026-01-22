Extension { #name : 'GolapEdgesAppearance' }

{ #category : '*Golap-Project' }
GolapEdgesAppearance >> asJSON [

	| json |
	json := Dictionary new.
	edgeEvaluatorList selectedItem ifNotNil: [ :edgeEvaluator |
		json at: 'edge-evaluator' put: edgeEvaluator asJSON ].
	nodeEvaluatorList selectedItem ifNotNil: [ :nodeEvaluator |
		json at: 'node-evaluator' put: nodeEvaluator asJSON ].
	^ json
]

{ #category : '*Golap-Project' }
GolapEdgesAppearance >> fromJSON: aDictionary [

	aDictionary
		at: 'edge-evaluator'
		ifPresent: [ :dict |
			self edgeEvaluator: (GolapEdgeEvaluator fromJSON: dict) ];
		at: 'node-evaluator'
		ifPresent: [ :dict |
			self nodeEvaluator: (GolapNodeEvaluator fromJSON: dict) ]
]

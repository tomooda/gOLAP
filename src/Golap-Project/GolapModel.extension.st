Extension { #name : 'GolapModel' }

{ #category : '*Golap-Project' }
GolapModel >> asJSON [

	| json |
	json := OrderedDictionary new.
	baseGraph toJSON: json.
	^ json
		  at: 'nodeEvaluators' put: (nodeEvaluators collect: #asJSON);
		  at: 'nodeEvaluatorIndex' put: (nodeEvaluators indexOf: nodeEvaluator ifAbsent: [ 1 ]);
		  at: 'nodeAggregators' put: (nodeAggregators collect: #asJSON);
		  at: 'edgeEvaluators' put: (edgeEvaluators collect: #asJSON);
		  at: 'edgeEvaluatorIndex' put: (edgeEvaluators indexOf: edgeEvaluator ifAbsent: [ 1 ]);
		  at: 'edgeAggregators' put: (edgeAggregators collect: #asJSON);
		  at: 'referenceNodes' put: referenceNodes asArray;
		  at: 'friend' put: friend;
		  at: 'merge' put: merge asJSON;
		  at: 'polishers' put: (polishers collect: #asJSON);
		  yourself
]

{ #category : '*Golap-Project' }
GolapModel class >> fromJSON: aDictionary [

	^ self new
		  fromJSON: aDictionary;
		  yourself
]

{ #category : '*Golap-Project' }
GolapModel >> fromJSON: aDictionary [

	aDictionary
		at: 'nodeEvaluators' ifPresent: [ :array | nodeEvaluators := array collect: [ :dict | GolapNodeEvaluator fromJSON: dict ] ];
		at: 'nodeEvaluatorIndex' ifPresent: [ :int | nodeEvaluator := nodeEvaluators at: int ];
		at: 'nodeAggregators' ifPresent: [ :array | nodeAggregators := array collect: [ :json | GolapDataAggregator fromJSON: json ] ];
		at: 'edgeEvaluators' ifPresent: [ :array | edgeEvaluators := array collect: [ :dict | GolapEdgeEvaluator fromJSON: dict ] ];
		at: 'edgeEvaluatorIndex' ifPresent: [ :int | edgeEvaluator := edgeEvaluators at: int ];
		at: 'edgeAggregators' ifPresent: [ :array | edgeAggregators := array collect: [ :json | GolapDataAggregator fromJSON: json ] ];
		at: 'friend' ifPresent: [ :numOrNil | friend := numOrNil ];
		at: 'merge' ifPresent: [ :json | merge fromJSON: json ];
		at: 'polishers'
		ifPresent: [ :array | polishers := (array collect: [ :json | GolapPolisher fromJSON: json ]) asOrderedCollection ].
	baseGraph := GolapBaseGraph fromJSON: aDictionary.
	self updateNodesAndEdges
]

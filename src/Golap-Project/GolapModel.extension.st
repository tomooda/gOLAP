Extension { #name : 'GolapModel' }

{ #category : '*Golap-Project' }
GolapModel >> asJSON [

	| json |
	json := OrderedDictionary new.
	baseGraph toJSON: json.
	^ json
		  at: 'nodeEvaluator' put: nodeEvaluator asJSON;
		  at: 'nodeAggregators' put: (nodeAggregators collect: #asJSON);
		  at: 'edgeEvaluator' put: edgeEvaluator asJSON;
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
		at: 'nodeEvaluator'
		ifPresent: [ :json |
			nodeEvaluator := GolapNodeEvaluator fromJSON: json ];
		at: 'nodeAggregators' ifPresent: [ :array |
				nodeAggregators := array collect: [ :json |
						                   GolapDataAggregator fromJSON: json ] ];
		at: 'edgeEvaluator'
		ifPresent: [ :json |
			edgeEvaluator := GolapEdgeEvaluator fromJSON: json ];
		at: 'edgeAggregators' ifPresent: [ :array |
				edgeAggregators := array collect: [ :json |
						                   GolapDataAggregator fromJSON: json ] ];
		at: 'friend' ifPresent: [ :numOrNil | friend := numOrNil ];
		at: 'merge' ifPresent: [ :json | merge fromJSON: json ];
		at: 'polishers' ifPresent: [ :array |
				polishers := (array collect: [ :json |
						              GolapPolisher fromJSON: json ])
					             asOrderedCollection ].
	baseGraph := GolapBaseGraph fromJSON: aDictionary.
	self updateNodesAndEdges
]

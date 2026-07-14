Extension { #name : 'GolapModel' }

{ #category : '*Golap-Project' }
GolapModel >> asJSON [

	| json |
	json := OrderedDictionary new.
	baseGraph toJSON: json.
	polisher toJSON: json.
	^ json
		  at: 'nodeEvaluator' put: nodeEvaluator asJSON;
		  at: 'nodeAggregators' put: (nodeAggregators collect: #asJSON);
		  at: 'edgeEvaluator' put: edgeEvaluator asJSON;
		  at: 'edgeAggregators' put: (edgeAggregators collect: #asJSON);
		  at: 'referenceNodes' put: referenceNodes asArray;
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
						                   GolapDataAggregator fromJSON: json ] ].
	baseGraph := GolapBaseGraph fromJSON: aDictionary.
	polisher := GolapPolisher fromJSON: aDictionary.
	self updateNodesAndEdges
]

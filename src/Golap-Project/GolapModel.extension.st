Extension { #name : 'GolapModel' }

{ #category : '*Golap-Project' }
GolapModel >> asJSON [

	| originalNodes originalEdges |
	originalEdges := IdentitySet new: nodes size.
	(originalNodes := self originalNodes) do: [ :node |
		originalEdges addAll: node edges ].
	^ OrderedDictionary new
		  at: 'nodes' put: (originalNodes values asArray collect: #asJSON);
		  at: 'nodeEvaluator' put: nodeEvaluator asJSON;
		  at: 'nodeAggregators' put: (nodeAggregators collect: #asJSON);
		  at: 'edges' put: (originalEdges asArray collect: [ :edge |
						   {
							   ('node1' -> edge node1 id).
							   ('node2' -> edge node2 id).
							   ('data' -> edge data) } asOrderedDictionary ]);
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
		at: 'nodes' ifPresent: [ :array |
				nodes := (array collect: [ :json |
							          | node |
							          node := GolapNode fromJSON: json.
							          node id -> node ]) asDictionary ];
		at: 'nodeEvaluator'
		ifPresent: [ :json |
			nodeEvaluator := GolapNodeEvaluator fromJSON: json ];
		at: 'nodeAggregators' ifPresent: [ :array |
				nodeAggregators := array collect: [ :json |
						                   GolapDataAggregator fromJSON: json ] ];
		at: 'edges' ifPresent: [ :dict |
				dict do: [ :edgeJson |
							| node1 node2 data |
							node1 := edgeJson at: 'node1'.
							node2 := edgeJson at: 'node2'.
							data := edgeJson at: 'data'.
							(nodes at: node1)
								createEdgeTo: (nodes at: node2)
								data: (DataSeries withKeys: data keys values: data values) ] ];
		at: 'edgeEvaluator'
		ifPresent: [ :json |
			edgeEvaluator := GolapEdgeEvaluator fromJSON: json ];
		at: 'edgeAggregators' ifPresent: [ :array |
				edgeAggregators := array collect: [ :json |
						                   GolapDataAggregator fromJSON: json ] ].
	friendsRank := 5.
	friendsEdges := nil.
	positivePolishEdges := IdentitySet new.
	negativePolishEdges := IdentitySet new.
	mergedNodes := IdentityDictionary new.
	self flushEdgeRanks
]

Class {
	#name : 'GolapModel',
	#superclass : 'Model',
	#instVars : [
		'edgeEvaluator',
		'friendsEdges',
		'friendsRank',
		'positivePolishEdges',
		'negativePolishEdges',
		'edgeAggregators',
		'mergedNodes',
		'nodeAggregators',
		'nodeEvaluator',
		'nodes',
		'edgeRanks'
	],
	#category : 'Golap-Models-Graph',
	#package : 'Golap-Models',
	#tag : 'Graph'
}

{ #category : 'storage' }
GolapModel class >> chooseCoocurrenceDataDo: aBlock [
	^ (UIManager default
		chooseExistingFileReference: 'Select a coocurrence file'
		extensions: #('csv')
		path: self coocurrenceDataDirectory) ifNotNil: aBlock
]

{ #category : 'storage' }
GolapModel class >> chooseItemsDataDo: aBlock [
	^ (UIManager default
		chooseExistingFileReference: 'Select an items file'
		extensions: #('csv')
		path: self itemsDataDirectory) ifNotNil: aBlock
]

{ #category : 'storage' }
GolapModel class >> coocurrenceDataDirectory [
	^ self localDirectory
]

{ #category : 'instance creation' }
GolapModel class >> fromJSON: aDictionary [

	^ self new
		  fromJSON: aDictionary;
		  yourself
]

{ #category : 'instance creation' }
GolapModel class >> fromServerDataframe: aDataFrame [

	^ self new
		  readServerDataframe: aDataFrame;
		  yourself
]

{ #category : 'storage' }
GolapModel class >> itemsDataDirectory [
	^ self localDirectory
]

{ #category : 'storage' }
GolapModel class >> localDirectory [
	^ (FileLocator documents / 'gOLAP') ensureCreateDirectory
]

{ #category : 'defaults' }
GolapModel class >> stringColumns [
	^ #('node1' 'node2' 'node1n' 'node2n') asSet
]

{ #category : 'arithmetics' }
GolapModel >> - aGolapModel [

	^ self copy diff: aGolapModel
]

{ #category : 'polishing' }
GolapModel >> addNegativePolishEdge: aGolapEdge [
	^ negativePolishEdges add: aGolapEdge
]

{ #category : 'polishing' }
GolapModel >> addPositivePolishEdge: aGolapEdge [
	^ positivePolishEdges add: aGolapEdge
]

{ #category : 'algorithms-articulation points' }
GolapModel >> articulationNodesInEdges: aCollectionOfGolapEdge [

	^ Array streamContents: [ :stream |
		  self
			  articulationNodesInEdges: aCollectionOfGolapEdge
			  do: [ :node | stream nextPut: node ] ]
]

{ #category : 'algorithms-articulation points' }
GolapModel >> articulationNodesInEdges: aCollectionOfGolapEdge do: aBlock [

	| finder |
	finder := GolapArticulationPointFinder new
		          edges: aCollectionOfGolapEdge;
		          yourself.
	finder articulationPoints do: aBlock
]

{ #category : 'snapshot' }
GolapModel >> asJSON [

	| originalNodes originalEdges nodeJsons |
	originalEdges := IdentitySet new: nodes size.
	nodeJsons := OrderedCollection new: nodes size.
	(originalNodes := self originalNodes) do: [ :node |
		originalEdges addAll: node edges ].
	^ OrderedDictionary new
		  at: 'nodes'
		  put: (originalNodes values asArray collect: [ :node |
					   {
						   ('id' -> node id).
						   ('name' -> node name).
						   ('data' -> node data) } asOrderedDictionary ]);
		  at: 'nodeEvaluator' put: nodeEvaluator asJSON;
		  at: 'nodeAggregators' put: (nodeAggregators collect: #asJSON);
		  at: 'edges' put: (originalEdges asArray collect: [ :edge |
					   {
						   ('node1' -> edge node1 id).
						   ('node2' -> edge node2 id).
						   ('data' -> edge data) } asOrderedDictionary ]);
		  at: 'edgeEvaluator' put: edgeEvaluator asJSON;
		  at: 'edgeAggregators' put: (edgeAggregators collect: #asJSON);
		  yourself
]

{ #category : 'enumerating' }
GolapModel >> bindingEdgesDo: aBlock [

	self friendsEdges do: [ :edge |
		(negativePolishEdges includes: edge) ifFalse: [ aBlock value: edge ] ].
	positivePolishEdges do: aBlock
]

{ #category : 'private' }
GolapModel >> computeFriendsEdges: anInteger [

	| edges |
	edges := IdentitySet new.
	self nodesDo: [ :node |
		node edgesDo: [ :edge |
			(self rankAtEdge: edge) <= anInteger ifTrue: [ edges add: edge ] ] ].
	^ edges asArray
]

{ #category : 'private' }
GolapModel >> createMergedNodeFrom: aCollectionOfGolapNode named: aString [

	^ aCollectionOfGolapNode
		  ifNotEmpty: [
			  | oldData newData |
			  oldData := aCollectionOfGolapNode collect: #data.
			  newData := DataSeries newFrom:
				             (nodeAggregators collect: [ :aggregation |
					              aggregation value: oldData ]).
			  newData name: aString.
			  GolapMergedNode
				  on: (DataSeries
						   withKeys: newData keys
						   values: newData values
						   name: aString)
				  name: aString ]
		  ifEmpty: [ nil ]
]

{ #category : 'accessing-node' }
GolapModel >> createNode: aDataSeries name: aString [

	^ GolapNode on: aDataSeries name: aString
]

{ #category : 'arithmetics' }
GolapModel >> diff: aGolapModel [

	| doneEdges |
	doneEdges := IdentitySet new: 1024.
	aGolapModel nodesDo: [ :node |
		nodes
			at: node id
			ifPresent: [ :myNode | myNode diff: node ]
			ifAbsentPut: [ (GolapNode on: node data name: node name) negated ] ].

	aGolapModel nodesDo: [ :node |
		node edgesDo: [ :edge |
			(doneEdges includes: edge) ifFalse: [
				| myNode1 myNode2 |
				doneEdges add: edge.
				myNode1 := nodes at: edge node1 id.
				myNode2 := nodes at: edge node2 id.
				(myNode1 edgeTo: myNode2 ifAbsent: [ nil ])
					ifNotNil: [ :myEdge | myEdge diff: edge ]
					ifNil: [ (myNode1 createEdgeTo: myNode2 data: edge data) negated ] ] ] ]
]

{ #category : 'accessing' }
GolapModel >> edgeAggregators [

	^ edgeAggregators
]

{ #category : 'accessing' }
GolapModel >> edgeAggregators: aCollectionOfGolapDataAggregator [

	edgeAggregators := aCollectionOfGolapDataAggregator
]

{ #category : 'accessing' }
GolapModel >> edgeBetween: data1 and: data2 ifAbsent: errorBlock [
	^ self
		edgeBetween: data1
		and: data2
		ifPresent: [ :edge | edge ]
		ifAbsent: errorBlock
]

{ #category : 'accessing' }
GolapModel >> edgeBetween: data1 and: data2 ifPresent: aBlock [
	^ self
		edgeBetween: data1
		and: data2
		ifPresent: aBlock
		ifAbsent: [  ]
]

{ #category : 'accessing' }
GolapModel >> edgeBetween: data1 and: data2 ifPresent: aBlock ifAbsent: errorBlock [

	| node1 node2 edge |
	node1 := self nodeAt: data1 ifAbsent: [ ^ errorBlock value ].
	node2 := self nodeAt: data2 ifAbsent: [ ^ errorBlock value ].
	edge := node1 edgeTo: node2 ifAbsent: [ ^ errorBlock value ].
	^ aBlock value: edge
]

{ #category : 'accessing' }
GolapModel >> edgeEvaluator [

	^ edgeEvaluator graph: self
]

{ #category : 'accessing' }
GolapModel >> edgeEvaluator: aGolapEdgeEvaluator [

	edgeEvaluator := aGolapEdgeEvaluator
]

{ #category : 'enumerating' }
GolapModel >> edgesDo: aBlock [

	| done |
	done := IdentitySet new: nodes size.
	self nodesDo: [ :node |
			node edgesDo: [ :edge |
					(done includes: edge) ifFalse: [
							done add: edge.
							aBlock value: edge ] ] ]
]

{ #category : 'private' }
GolapModel >> flushEdgeRanks [

	edgeRanks removeAll
]

{ #category : 'accessing' }
GolapModel >> flushFriendsEdges [

	friendsEdges := nil
]

{ #category : 'visualizing-labels' }
GolapModel >> font [
	^ TextStyle defaultFont
]

{ #category : 'accessing' }
GolapModel >> friendsEdges [
	^ self friendsEdges: self friendsRank
]

{ #category : 'accessing' }
GolapModel >> friendsEdges: anInteger [

	| num |
	anInteger ifNil: [
		friendsEdges := nil.
		friendsRank := nil.
		^ Array new ].
	num := anInteger asInteger max: 1.
	friendsRank ~= num ifTrue: [ friendsEdges := nil ].
	^ friendsEdges ifNil: [
		  friendsRank := num.
		  friendsEdges := self computeFriendsEdges: friendsRank ]
]

{ #category : 'accessing' }
GolapModel >> friendsRank [
	^ friendsRank
]

{ #category : 'snapshot' }
GolapModel >> fromJSON: aDictionary [

	aDictionary
		at: 'nodes' ifPresent: [ :nodesJson |
			nodes := (nodesJson collect: [ :nodeJson |
					          | data id name |
					          data := nodeJson at: 'data'.
					          id := nodeJson at: 'id'.
					          name := nodeJson at: 'name'.
					          id -> (GolapNode
							           on:
								           (DataSeries
									            withKeys: data keys
									            values: data values
									            name: id)
							           name: name) ]) asDictionary ];
		at: 'nodeEvaluator'
		ifPresent: [ :json |
			nodeEvaluator := GolapNodeEvaluator fromJSON: json ];
		at: 'nodeAggregators' ifPresent: [ :jsonArray |
			nodeAggregators := jsonArray collect: [ :json |
					                   GolapDataAggregator fromJSON: json ] ];
		at: 'edges' ifPresent: [ :edgesJson |
			edgesJson do: [ :edgeJson |
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
		at: 'edgeAggregators' ifPresent: [ :jsonArray |
			edgeAggregators := jsonArray collect: [ :json |
					                   GolapDataAggregator fromJSON: json ] ].
	friendsRank := 5.
	friendsEdges := nil.
	positivePolishEdges := IdentitySet new.
	negativePolishEdges := IdentitySet new.
	mergedNodes := IdentityDictionary new.
	self flushEdgeRanks
]

{ #category : 'accessing' }
GolapModel >> hiddenEdgeBetween: data1 and: data2 ifAbsent: errorBlock [
	^ self
		hiddenEdgeBetween: data1
		and: data2
		ifPresent: [ :edge | edge ]
		ifAbsent: errorBlock
]

{ #category : 'accessing' }
GolapModel >> hiddenEdgeBetween: data1 and: data2 ifPresent: aBlock [
	^ self
		hiddenEdgeBetween: data1
		and: data2
		ifPresent: aBlock
		ifAbsent: [  ]
]

{ #category : 'accessing' }
GolapModel >> hiddenEdgeBetween: data1 and: data2 ifPresent: aBlock ifAbsent: errorBlock [

	| node1 node2 edge |
	node1 := self nodeAt: data1 ifAbsent: [ ^ errorBlock value ].
	node2 := self nodeAt: data2 ifAbsent: [ ^ errorBlock value ].
	edge := node1 hiddenEdgeTo: node2 ifAbsent: [ ^ errorBlock value ].
	^ aBlock value: edge
]

{ #category : 'initialization' }
GolapModel >> initialize [

	super initialize.
	friendsRank := 5.
	positivePolishEdges := IdentitySet new.
	negativePolishEdges := IdentitySet new.
	mergedNodes := IdentityDictionary new.
	edgeRanks := IdentityDictionary new
]

{ #category : 'accessing' }
GolapModel >> maxEdgeValue [

	| maxValue maxEdge |
	maxValue := Float negativeInfinity.
	maxEdge := nil.
	self edgesDo: [ :edge |
			| value |
			value := self valueAtEdge: edge.
			maxValue < value ifTrue: [
					maxValue := value.
					maxEdge := edge ] ].
	^ maxEdge ifNotNil: [ maxValue ] ifNil: [ 1.0 ]
]

{ #category : 'accessing' }
GolapModel >> maxNodeValue [

	| maxValue maxNode |
	maxValue := Float negativeInfinity.
	maxNode := nil.
	self nodesDo: [ :node |
		| value |
		value := self valueAtNode: node.
		maxValue < value ifTrue: [
			maxValue := value.
			maxNode := node ] ].
	^ maxNode ifNotNil: [ maxValue ] ifNil: [ 1.0 ]
]

{ #category : 'accessing-node' }
GolapModel >> mergeNodes: aCollectionOfGolapNode named: aString [

	aCollectionOfGolapNode ifNotEmpty: [
		| newNode oldEdgesByPeers oldEdges |
		newNode := self
			           createMergedNodeFrom: aCollectionOfGolapNode
			           named: aString.
		oldEdgesByPeers := IdentityDictionary new.
		oldEdges := OrderedCollection new:
			            aCollectionOfGolapNode size
			            * aCollectionOfGolapNode size.
		aCollectionOfGolapNode do: [ :node |
			node edges copy do: [ :edge |
				| peer |
				peer := edge peerOf: node.
				(aCollectionOfGolapNode includes: peer) ifFalse: [
					(oldEdgesByPeers at: peer ifAbsentPut: [ OrderedCollection new ])
						add: edge ].
				oldEdges add: edge.
				edge remove ].
			self nodes removeKey: node id ].
		oldEdgesByPeers keysAndValuesDo: [ :peer :edges |
			newNode
				createEdgeTo: peer
				data:
					(DataSeries newFrom: (edgeAggregators collect: [ :aggregator |
							  aggregator value: (edges collect: #data) ])) ].
		newNode
			x: ((aCollectionOfGolapNode collect: #x thenSelect: #notNil)
					 ifEmpty: [ nil ]
					 ifNotEmpty: #average);
			y: ((aCollectionOfGolapNode collect: #y thenSelect: #notNil)
					 ifEmpty: [ nil ]
					 ifNotEmpty: #average);
			oldEdges: oldEdges asArray;
			oldNodes:
				(aCollectionOfGolapNode asArray sorted:
						 self nodeEvaluator descending).
		self nodes at: aString put: newNode.
		self flushEdgeRanks.
		friendsEdges := nil.
		self friendsEdges: self friendsRank.
		^ newNode ]
]

{ #category : 'accessing' }
GolapModel >> minEdgeValue [

	| minValue minEdge |
	minValue := Float infinity.
	minEdge := nil.
	self edgesDo: [ :edge |
			| value |
			value := self valueAtEdge: edge.
			value < minValue ifTrue: [
					minValue := value.
					minEdge := edge ] ].
	^ minEdge ifNotNil: [ minValue ] ifNil: [ 0.0 ]
]

{ #category : 'accessing' }
GolapModel >> minNodeValue [

	| minValue minNode |
	minValue := Float infinity.
	minNode := nil.
	self nodesDo: [ :node |
		| value |
		value := self valueAtNode: node.
		value < minValue ifTrue: [
			minValue := value.
			minNode := node ] ].
	^ minNode ifNotNil: [ minValue ] ifNil: [ 0.0 ]
]

{ #category : 'polishing' }
GolapModel >> negativePolishEdgesDo: aBlock [
	negativePolishEdges do: aBlock
]

{ #category : 'accessing' }
GolapModel >> nodeAggregators [

	^ nodeAggregators
]

{ #category : 'accessing' }
GolapModel >> nodeAggregators: aCollectionOfGolapDataAggregator [

	nodeAggregators := aCollectionOfGolapDataAggregator
]

{ #category : 'accessing-node' }
GolapModel >> nodeAt: anInteger [
	^ self nodes at: anInteger
]

{ #category : 'accessing-node' }
GolapModel >> nodeAt: anInteger ifAbsent: errorBlock [
	^ self nodes at: anInteger ifAbsent: errorBlock
]

{ #category : 'accessing' }
GolapModel >> nodeEvaluator [

	^ nodeEvaluator graph: self
]

{ #category : 'accessing' }
GolapModel >> nodeEvaluator: aGolapNodeEvaluator [

	nodeEvaluator := aGolapNodeEvaluator
]

{ #category : 'accessing' }
GolapModel >> nodeListWithKeyword: aString [

	| list column |
	list := DataFrame new: 0 @ 3.
	self nodesDo: [ :node :id |
		| name |
		name := node name.
		(aString isEmpty or: [ (name findString: aString) > 0 ]) ifTrue: [
			list
				addRow: (DataSeries newFrom: {
							 name.
							 (self valueAtNode: node).
							 id })
				named: id printString ] ].
	column := nodeEvaluator name.
	list columnNames: {
			'product'.
			column.
			'id' }.
	list sortDescendingBy: column.
	^ list
]

{ #category : 'accessing-node' }
GolapModel >> nodes [

	^ nodes ifNil: [
		  nodes := Dictionary new.
		  friendsEdges := nil.
		  self flushEdgeRanks.
		  nodes ]
]

{ #category : 'enumerating' }
GolapModel >> nodesDo: aBlock [

	self nodes keys do: [ :id |
		aBlock cull: (nodes at: id) cull: id ]
]

{ #category : 'private' }
GolapModel >> originalNodes [

	| newNodes nextPutNode newEdges |
	newNodes := Dictionary new: nodes size.
	nextPutNode := [ :node |
	               node isMergedNode
		               ifTrue: [ node oldNodes do: nextPutNode ]
		               ifFalse: [ newNodes at: node id put: node copy ] ].
	nodes valuesDo: nextPutNode.
	newEdges := IdentityDictionary new: 1024.
	newNodes valuesDo: [ :node |
		node edgesDo: [ :edge |
			(edge node1 isMergedNode or: [ edge node2 isMergedNode ]) ifFalse: [
				newEdges at: edge ifAbsentPut: [
					edge copy
						node1: (newNodes at: edge node1 id);
						node2: (newNodes at: edge node2 id);
						yourself ] ] ] ].
	newNodes valuesDo: [ :node |
		node edges: (node edges
				 collect: [ :edge | newEdges at: edge ifAbsent: [ nil ] ]
				 thenSelect: #notNil) ].
	^ newNodes
]

{ #category : 'polishing' }
GolapModel >> polishAddAbove: aNumber1 removeBelow: aNumber2 minDenominator: anInteger [

	| changed hop2peers edges |
	changed := false.
	hop2peers := IdentityDictionary new.
	edges := IdentitySet new.
	self nodesDo: [ :v1 |
			| peers |
			peers := hop2peers at: v1 put: IdentityDictionary new.
			v1 edgesAndNodeDo: [ :e1 :v2 |
					edges add: e1.
					v2 edgesAndNodeDo: [ :e2 :v3 |
							v1 id < v3 id ifTrue: [
								peers at: v3 put: (peers at: v3 ifAbsent: [ 0 ]) + 1 ] ] ] ].
	hop2peers keysAndValuesDo: [ :v1 :peersAndDups |
			peersAndDups keysAndValuesDo: [ :v2 :dups |
					(v1 hasPeerNode: v2) ifFalse: [
							| denominator |
							denominator := v1 numberOfEdges + v2 numberOfEdges - dups.
							denominator > anInteger ifTrue: [
									dups asFloat
									/ (v1 numberOfEdges + v2 numberOfEdges - dups) asFloat
									> aNumber1 ifTrue: [
											changed := true.
											(self removeNegativePolishEdgeBetween: v1 and: v2) ifNil: [
													| newEdge |
													newEdge := GolapEdge on: nil between: v1 and: v2.
													v1 addPositivePolishEdge: newEdge.
													v2 addPositivePolishEdge: newEdge.
													self addPositivePolishEdge: newEdge ] ] ] ] ] ].
	edges do: [ :edge |
			| v1 v2 peersAndDups |
			edge node1 id <= edge node2 id
				ifTrue: [
						v1 := edge node1.
						v2 := edge node2 ]
				ifFalse: [
						v1 := edge node2.
						v2 := edge node1 ].
			peersAndDups := hop2peers at: v1.
			((peersAndDups includesKey: v2) and: [
					 | dups denominator |
					 dups := peersAndDups at: v2.
					 denominator := v1 numberOfEdges + v2 numberOfEdges - dups.
					 denominator > anInteger and: [
							 dups asFloat
							 / (v1 numberOfEdges + v2 numberOfEdges - dups) asFloat
							 < aNumber2 ] ]) ifTrue: [
					changed := true.
					(self removePositivePolishEdgeBetween: v1 and: v2) ifNil: [
							v1 addNegativePolishEdge: edge.
							v2 addNegativePolishEdge: edge.
							self addNegativePolishEdge: edge ] ] ].
	friendsEdges := nil.
	self flushEdgeRanks.
	^ changed
]

{ #category : 'polishing' }
GolapModel >> positivePolishEdgesDo: aBlock [
	positivePolishEdges do: aBlock
]

{ #category : 'copying' }
GolapModel >> postCopy [

	super postCopy.
	nodeEvaluator := nodeEvaluator ifNotNil: #copy.
	edgeEvaluator := edgeEvaluator ifNotNil: #copy.
	nodeAggregators := nodeAggregators ifNotNil: #copy.
	edgeAggregators := edgeAggregators ifNotNil: #copy.
	nodes := self originalNodes.
	positivePolishEdges := IdentitySet new.
	negativePolishEdges := IdentitySet new.
	mergedNodes := IdentityDictionary new.
	friendsEdges := nil.
	self flushEdgeRanks
]

{ #category : 'accessing' }
GolapModel >> rankAtEdge: aGolapEdge [

	^ edgeRanks at: aGolapEdge ifAbsentPut: [ aGolapEdge rankIn: self ]
]

{ #category : 'private' }
GolapModel >> readEdgeDataframe: edgeDataframe idColumn: aString and: anotherString [

	edgeDataframe do: [ :row |
		| node1 node2 |
		node1 := row
			         at: aString
			         ifPresent: [ :id |
			         nodes at: id asString ifAbsent: [ nil ] ].
		node2 := row
			         at: anotherString
			         ifPresent: [ :id |
			         nodes at: id asString ifAbsent: [ nil ] ].
		(node1 notNil and: [ node2 notNil and: [ node1 ~~ node2 ] ])
			ifTrue: [ node1 createEdgeTo: node2 data: row ] ]
]

{ #category : 'private' }
GolapModel >> readNodeDataframe: nodeDataframe idColumn: aString nameColumn: anotherString [

	| newNodes |
	newNodes := Dictionary new: nodeDataframe size.
	nodeDataframe withIndexDo: [ :row :index |
		| id name |
		id := (row at: aString ifAbsent: [ index ]) asString.
		name := (row at: anotherString ifAbsent: [ id ]) asString.
		row name: id.
		newNodes at: id ifAbsentPut: (self createNode: row name: name) ].
	nodes := newNodes.
	friendsEdges := nil.
	self flushEdgeRanks
]

{ #category : 'private' }
GolapModel >> readServerDataframe: aDataFrame [

	| newNodes |
	aDataFrame columnNames: (aDataFrame columnNames collect: [ :string |
			 (string includes: $%)
				 ifTrue: [ string copyFrom: 1 to: (string indexOf: $%) - 1 ]
				 ifFalse: [ string ] ]).
	nodeEvaluator := GolapNodeColumnEvaluator column: 'frequency'.
	edgeEvaluator := GolapEdgeColumnEvaluator column: 'jaccard'.
	nodeAggregators := { (GolapSumDataAggregator column: 'frequency') }.
	edgeAggregators := {
		                   (GolapSumDataAggregator column: 'frequency').
		                   (GolapSumDataAggregator column: 'total').
		                   (GolapWeightedAverageDataAggregator
			                    column: 'supoort'
			                    weightColumn: 'frequency').
		                   (GolapWeightedAverageDataAggregator
			                    column: 'jaccard'
			                    weightColumn: 'frequency').
		                   (GolapWeightedAverageDataAggregator
			                    column: 'lift'
			                    weightColumn: 'frequency').
		                   (GolapWeightedAverageDataAggregator
			                    column: 'PMI'
			                    weightColumn: 'frequency') }.
	newNodes := Dictionary new.
	aDataFrame do: [ :data |
		| id1 id2 node1 node2 |
		id1 := data at: 'node1'.
		id2 := data at: 'node2'.
		node1 := newNodes at: id1 ifAbsentPut: [
			         self
				         createNode: (DataSeries
						          withKeys: { 'frequency' }
						          values: { (data at: 'frequency1') }
						          name: id1)
				         name: (data at: 'node1n') ].
		id2 ifNotNil: [
			node2 := newNodes at: id2 ifAbsentPut: [
				         self
					         createNode: (DataSeries
							          withKeys: { 'frequency' }
							          values: { (data at: 'frequency2') }
							          name: id2)
					         name: (data at: 'node2n') ].
			(data at: 'effective' ifAbsent: [ 1 ]) > 0
				ifTrue: [ node1 createEdgeTo: node2 data: data ]
				ifFalse: [ node1 createHiddenEdgeTo: node2 data: data ] ] ].
	nodes := newNodes.
	friendsEdges := nil.
	self flushEdgeRanks
]

{ #category : 'polishing' }
GolapModel >> removeNegativePolishEdge: aGolapEdge [
	^ negativePolishEdges remove: aGolapEdge ifAbsent: [ nil ]
]

{ #category : 'polishing' }
GolapModel >> removeNegativePolishEdgeBetween: aGolapNode1 and: aGolapNode2 [

	^ (aGolapNode1 negativePolishEdgeWith: aGolapNode2) ifNotNil: [ :edge |
		  aGolapNode1 removeNegativePolishEdge: edge.
		  aGolapNode2 removeNegativePolishEdge: edge.
		  self removeNegativePolishEdge: edge.
		  edge ]
]

{ #category : 'polishing' }
GolapModel >> removePositivePolishEdge: aGolapEdge [
	^ positivePolishEdges remove: aGolapEdge ifAbsent: [ nil ]
]

{ #category : 'polishing' }
GolapModel >> removePositivePolishEdgeBetween: aGolapNode1 and: aGolapNode2 [

	self positivePolishEdgesDo: [ :edge |
		((aGolapNode1 == edge node1 and: [ aGolapNode2 == edge node2 ]) or: [
			 aGolapNode1 == edge node2 and: [ aGolapNode2 == edge node1 ] ])
			ifTrue: [
				aGolapNode1 removePositivePolishEdge: edge.
				aGolapNode2 removePositivePolishEdge: edge.
				self removePositivePolishEdge: edge.
				^ edge ] ].
	^ nil
]

{ #category : 'polishing' }
GolapModel >> repeat: anInteger1 polishAddAbove: aNumber1 removeBelow: aNumber2 minDenominator: anInteger2 [
	self resetPolish.
	anInteger1
		timesRepeat: [ (self
				polishAddAbove: aNumber1
				removeBelow: aNumber2
				minDenominator: anInteger2)
				ifFalse: [ ^ self ] ]
]

{ #category : 'accessing-node' }
GolapModel >> resetMerges [

	| newNodes nextPutNode newEdges |
	newNodes := Dictionary new: nodes size.
	nextPutNode := [ :node |
	               node isMergedNode
		               ifTrue: [ node oldNodes do: nextPutNode ]
		               ifFalse: [ newNodes at: node id put: node copy ] ].
	nodes valuesDo: nextPutNode.
	newEdges := IdentityDictionary new: 1024.
	newNodes valuesDo: [ :node |
		node edgesDo: [ :edge |
			(edge node1 isMergedNode or: [ edge node2 isMergedNode ]) ifFalse: [
				newEdges at: edge ifAbsentPut: [
					edge copy
						node1: (newNodes at: edge node1 id);
						node2: (newNodes at: edge node2 id);
						yourself ] ] ] ].
	newNodes valuesDo: [ :node |
		node edges: (node edges
				 collect: [ :edge | newEdges at: edge ifAbsent: [ nil ] ]
				 thenSelect: #notNil) ].
	nodes := newNodes.
	mergedNodes := IdentityDictionary new.
	friendsEdges := nil.
	self flushEdgeRanks
]

{ #category : 'accessing-node' }
GolapModel >> resetNodes [

	self resetMerges.
	self resetPolish
]

{ #category : 'polishing' }
GolapModel >> resetPolish [

	self nodesDo: [ :v | v resetPolish ].
	positivePolishEdges := IdentitySet new.
	negativePolishEdges := IdentitySet new.
	friendsEdges := nil.
	self flushEdgeRanks
]

{ #category : 'accessing-node' }
GolapModel >> unmergeNode: aGolapNode [

	aGolapNode isMergedNode ifFalse: [ ^ self ].
	aGolapNode oldNodesDo: [ :node | self nodes at: node id put: node ].
	aGolapNode oldEdgesDo: [ :edge |
		(edge node1 hasEdge: edge) ifFalse: [ edge node1 addEdge: edge ].
		(edge node2 hasEdge: edge) ifFalse: [ edge node2 addEdge: edge ] ].
	aGolapNode edgesAndNodeDo: [ :edge :peer | peer removeEdge: edge ].
	self nodes removeKey: aGolapNode id.
	^ aGolapNode
]

{ #category : 'accessing' }
GolapModel >> valueAtEdge: aGolapEdge [

	^ edgeEvaluator value: aGolapEdge graph: self
]

{ #category : 'accessing' }
GolapModel >> valueAtNode: aGolapNode [

	^ nodeEvaluator value: aGolapNode graph: self
]

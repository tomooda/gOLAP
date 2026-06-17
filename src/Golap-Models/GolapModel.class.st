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
		'edgeRanks',
		'referenceNodes',
		'baseGraph',
		'merge'
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

{ #category : 'accessing-reference nodes' }
GolapModel >> addReferenceNode: aGolapNode [

	referenceNodes addLast: aGolapNode id
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
							   name: aString asString)
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
			self nodes
				at: node id
				ifPresent: [ :myNode | myNode diff: node ]
				ifAbsentPut: [ (GolapNode on: node data name: node name) negated ] ].

	aGolapModel nodesDo: [ :node |
			node edgesDo: [ :edge |
					(doneEdges includes: edge) ifFalse: [
							| myNode1 myNode2 |
							doneEdges add: edge.
							myNode1 := self nodes at: edge node1 id.
							myNode2 := self nodes at: edge node2 id.
							(myNode1 edgeTo: myNode2 ifAbsent: [ nil ])
								ifNotNil: [ :myEdge | myEdge diff: edge ]
								ifNil: [
								(myNode1 createEdgeTo: myNode2 data: edge data) negated ] ] ] ]
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
	done := IdentitySet new: self nodes size.
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

{ #category : 'accessing-reference nodes' }
GolapModel >> indexAtReferenceNode: aGolapNode [

	^ referenceNodes indexOf: aGolapNode id
]

{ #category : 'initialization' }
GolapModel >> initialize [

	super initialize.
	baseGraph := GolapBaseGraph new.
	merge := GolapNodeMerge new.
	friendsRank := 5.
	positivePolishEdges := IdentitySet new.
	negativePolishEdges := IdentitySet new.
	mergedNodes := IdentityDictionary new.
	edgeRanks := IdentityDictionary new.
	referenceNodes := OrderedCollection new
]

{ #category : 'accessing-reference nodes' }
GolapModel >> isReferenceEdge: aGolapEdge [

	^ (referenceNodes includes: aGolapEdge node1 id) or: [
		  referenceNodes includes: aGolapEdge node2 id ]
]

{ #category : 'accessing-reference nodes' }
GolapModel >> isReferenceNode: aGolapNode [

	^ referenceNodes includes: aGolapNode id
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

{ #category : 'accessing' }
GolapModel >> merge [

	^ merge
]

{ #category : 'accessing-node' }
GolapModel >> mergeNodes: aCollectionOfGolapNode named: aString [

	merge merge: (aCollectionOfGolapNode collect: #id) into: aString.
	self updateNodesAndEdges.
	^ nodes at: aString ifAbsent: [ nil ]
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
GolapModel >> nodeAt: aString [
	^ self nodes at: aString
]

{ #category : 'accessing-node' }
GolapModel >> nodeAt: aString ifAbsent: errorBlock [
	^ self nodes at: aString ifAbsent: errorBlock
]

{ #category : 'accessing-node' }
GolapModel >> nodeAt: aString ifPresent: aBlock [

	^ self nodes at: aString ifPresent: aBlock
]

{ #category : 'accessing-node' }
GolapModel >> nodeAt: aString ifPresent: aBlock ifAbsent: errorBlock [

	^ self nodes at: aString ifPresent: aBlock ifAbsent: errorBlock
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
			  self updateNodesAndEdges.
			  nodes ]
]

{ #category : 'enumerating' }
GolapModel >> nodesDo: aBlock [

	self nodes keys do: [ :id |
		aBlock cull: (nodes at: id) cull: id ]
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
					(v1 canHavePositivePolishEdge: v2) ifFalse: [
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
	self updateNodesAndEdges.
	positivePolishEdges := IdentitySet new.
	negativePolishEdges := IdentitySet new.
	mergedNodes := IdentityDictionary new
]

{ #category : 'accessing' }
GolapModel >> rankAtEdge: aGolapEdge [

	^ edgeRanks at: aGolapEdge ifAbsentPut: [ aGolapEdge rankIn: self ]
]

{ #category : 'private' }
GolapModel >> readEdgeDataframe: edgeDataframe idColumn: aString and: anotherString [

	baseGraph
		readEdgeDataframe: edgeDataframe
		idColumn: aString
		and: anotherString.
	self updateNodesAndEdges
]

{ #category : 'private' }
GolapModel >> readNodeDataframe: nodeDataframe idColumn: aString nameColumn: anotherString [

	baseGraph
		readNodeDataframe: nodeDataframe
		idColumn: aString
		nameColumn: anotherString.
	self updateNodesAndEdges
]

{ #category : 'private' }
GolapModel >> readServerDataframe: aDataFrame [

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
	baseGraph readServerDataframe: aDataFrame.
	self updateNodesAndEdges
]

{ #category : 'accessing-reference nodes' }
GolapModel >> referenceNodes [

	^ referenceNodes
]

{ #category : 'accessing-reference nodes' }
GolapModel >> referenceNodesSize [

	^ referenceNodes size
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

{ #category : 'accessing-reference nodes' }
GolapModel >> removeReferenceNode: aGolapNode [

	referenceNodes remove: aGolapNode id ifAbsent: [ ]
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

	merge unmergeAll.
	self updateNodesAndEdges
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
GolapModel >> setMerges: anOrderedCollectionOfAssociations [

	merge unmergeAll.
	anOrderedCollectionOfAssociations do: [ :assoc |
		merge merge: assoc value into: assoc key ].
	self updateNodesAndEdges
]

{ #category : 'accessing-node' }
GolapModel >> unmergeNode: aGolapNode [

	merge unmerge: aGolapNode id.
	self updateNodesAndEdges.
	^ aGolapNode
]

{ #category : 'updating' }
GolapModel >> updateFriends [

	friendsEdges := nil.
	self flushEdgeRanks
]

{ #category : 'updating' }
GolapModel >> updateNodesAndEdges [

	| baseNodes newRoots newNodes newRootEdges |
	baseNodes := Dictionary new: baseGraph numberOfNodes.
	newRoots := Set new.
	baseGraph nodesDo: [ :baseNode |
			baseNodes at: baseNode id put: baseNode.
			merge rootsAt: baseNode id do: [ :id | newRoots add: id ] ].
	newNodes := Dictionary new.
	newRoots do: [ :root |
			((merge leavesAt: root) collect: [ :leaf | baseNodes at: leaf ])
				ifNotEmpty: [ :leafBaseNodes |
						newNodes at: root put: (leafBaseNodes size = 1
								 ifTrue: [ leafBaseNodes first asGolapNode ]
								 ifFalse: [
										 | newData |
										 newData := DataSeries newFrom:
											            (nodeAggregators collect: [ :aggregation |
												             aggregation value:
													             (leafBaseNodes collect: #data) ]).
										 newData name: root asString.
										 GolapMergedNode
											 on: newData
											 name: root asString
											 ids: (leafBaseNodes collect: [ :n | n id asString ]) ]) ] ].
	newRootEdges := Dictionary new.
	baseGraph edgesDo: [ :baseEdge |
			merge rootsAt: baseEdge node1 do: [ :root1 |
					merge rootsAt: baseEdge node2 do: [ :root2 |
							root1 = root2 ifFalse: [
									(newRootEdges
										 at: (root1 < root2
												  ifTrue: [ Array with: root1 with: root2 ]
												  ifFalse: [ Array with: root2 with: root1 ])
										 ifAbsentPut: [ OrderedCollection new ]) add: baseEdge data ] ] ] ].
	newRootEdges keysAndValuesDo: [ :rootPair :dataArray |
			newNodes at: rootPair first ifPresent: [ :node1 |
					newNodes at: rootPair second ifPresent: [ :node2 |
							(dataArray size = 1 and: [
								 (dataArray first at: 'effective' ifAbsent: [ 1 ]) <= 0 ])
								ifTrue: [
								node1 createHiddenEdgeTo: node2 data: dataArray first ]
								ifFalse: [
										node1 createEdgeTo: node2 data: (dataArray size = 1
												 ifTrue: [ dataArray first ]
												 ifFalse: [
														 DataSeries newFrom:
															 (edgeAggregators collect: [ :aggregator |
																  aggregator value: dataArray ]) ]) ] ] ] ].
	nodes := newNodes.
	self updateFriends
]

{ #category : 'accessing' }
GolapModel >> valueAtEdge: aGolapEdge [

	^ edgeEvaluator value: aGolapEdge graph: self
]

{ #category : 'accessing' }
GolapModel >> valueAtNode: aGolapNode [

	^ nodeEvaluator value: aGolapNode graph: self
]

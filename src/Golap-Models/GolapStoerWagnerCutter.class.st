Class {
	#name : 'GolapStoerWagnerCutter',
	#superclass : 'Object',
	#instVars : [
		'root',
		'mp'
	],
	#category : 'Golap-Models-Analysis',
	#package : 'Golap-Models',
	#tag : 'Analysis'
}

{ #category : 'examples' }
GolapStoerWagnerCutter class >> example [

	| n es result solver |
	n := 8.
	es := {
		      { 'node1'. 'node2'. 2 }.
		      { 'node2'. 'node3'. 3 }.
		      { 'node3'. 'node4'. 4 }.
		      { 'node1'. 'node5'. 3 }.
		      { 'node2'. 'node5'. 2 }.
		      { 'node2'. 'node6'. 2 }.
		      { 'node3'. 'node7'. 2 }.
		      { 'node4'. 'node7'. 2 }.
		      { 'node4'. 'node8'. 2 }.
		      { 'node5'. 'node6'. 3 }.
		      { 'node6'. 'node7'. 1 }.
		      { 'node7'. 'node8'. 3 } }.

	solver := self new.
	result := solver globalMinimumCut: es.
	self assert: (result collect: #third) sum = 4.
	result inspect
]

{ #category : 'operations' }
GolapStoerWagnerCutter >> bestClusterByGlobalMinimumCut: anArrayOfEdges [

	| minCutWeight graph merged node0 clusters bestCluster |
	anArrayOfEdges ifEmpty: [ ^ Array new ].
	graph := self graphFromEdges: anArrayOfEdges.
	node0 := graph keys anyOne.
	bestCluster := self clusterOf: node0 in: graph.
	bestCluster size < graph size ifTrue: [ ^ bestCluster ].
	clusters := (graph keys collect: [ :node | node -> (OrderedCollection with: node) ]) asDictionary.
	bestCluster := (clusters at: node0) asArray.
	minCutWeight := Float infinity.
	merged := Set new: graph size.
	[
		| order contractedNode survivorNode cutWeight |
		order := self maximumAdjacencyOrder: graph startingAt: node0 excluding: merged.
		contractedNode := order at: order size ifAbsent: [ ^ bestCluster ].
		cutWeight := 0.
		graph at: contractedNode ifPresent: [ :neighbors | neighbors valuesDo: [ :weight | cutWeight := cutWeight + weight ] ].
		cutWeight < minCutWeight ifTrue: [
				minCutWeight := cutWeight.
				bestCluster := (clusters at: contractedNode) asArray ].
		survivorNode := order at: order size - 1 ifAbsent: [ ^ bestCluster ].
		merged add: contractedNode.
		(clusters at: survivorNode) addAll: (clusters at: contractedNode).
		self contract: contractedNode into: survivorNode in: graph ] repeat
]

{ #category : 'private' }
GolapStoerWagnerCutter >> clusterOf: node0 in: graph [

	| cluster agenda |
	cluster := Set new: graph size.
	agenda := OrderedCollection with: node0.
	[ agenda notEmpty ] whileTrue: [
			| node |
			node := agenda removeLast.
			cluster add: node.
			graph at: node ifPresent: [ :neighbors |
					neighbors keysDo: [ :neighbor |
						((cluster includes: neighbor) or: [ agenda includes: neighbor ]) ifFalse: [ agenda addLast: neighbor ] ] ] ].
	^ cluster
]

{ #category : 'private' }
GolapStoerWagnerCutter >> contract: contractedNode into: survivorNode in: graph [

	graph at: contractedNode ifPresent: [ :neighborsDict |
			neighborsDict keysAndValuesDo: [ :neighborNode :weight |
					neighborNode ~= survivorNode ifTrue: [
							| neighborsOfSurvivorNode neighborsOfNeighborNode |
							neighborsOfSurvivorNode := graph at: survivorNode.
							neighborsOfNeighborNode := graph at: neighborNode.
							(neighborsOfSurvivorNode includesKey: neighborNode)
								ifTrue: [
										neighborsOfSurvivorNode at: neighborNode put: (neighborsOfSurvivorNode at: neighborNode) + weight.
										neighborsOfNeighborNode at: survivorNode put: (neighborsOfNeighborNode at: survivorNode) + weight ]
								ifFalse: [
										neighborsOfSurvivorNode at: neighborNode put: weight.
										neighborsOfNeighborNode at: survivorNode put: weight ] ].
					(graph at: neighborNode) removeKey: contractedNode ] ].
	graph removeKey: contractedNode
]

{ #category : 'private' }
GolapStoerWagnerCutter >> createAdjacentHeap: graph startingAt: node0 excluding: mergedNodes [

	| adjacentWeights |
	adjacentWeights := OrderedCollection new.
	graph keysDo: [ :node |
			((mergedNodes includes: node) not and: [ node ~= node0 ]) ifTrue: [
				adjacentWeights add: node -> ((graph at: node0) at: node ifAbsent: [ 0 ]) negated ] ].
	^ GolapBinaryHeapNode withAll: adjacentWeights
]

{ #category : 'operations' }
GolapStoerWagnerCutter >> globalMinimumCut: anArrayOfTriple [

	| cluster |
	cluster := (self bestClusterByGlobalMinimumCut: anArrayOfTriple) asSet.
	^ anArrayOfTriple select: [ :triple | (cluster includes: triple first) xor: (cluster includes: triple second) ]
]

{ #category : 'private' }
GolapStoerWagnerCutter >> graphFromEdges: anArrayOfTriple [

	| graph |
	graph := IdentityDictionary new.
	anArrayOfTriple do: [ :edge |
			(graph at: edge first ifAbsentPut: [ IdentityDictionary new ]) at: edge second put: edge third.
			(graph at: edge second ifAbsentPut: [ IdentityDictionary new ]) at: edge first put: edge third ].
	^ graph
]

{ #category : 'private' }
GolapStoerWagnerCutter >> maximumAdjacencyOrder: graph startingAt: node0 excluding: mergedNodes [

	| done heap order nodeMap |
	done := Set new: graph size.
	done add: node0.
	heap := self createAdjacentHeap: graph startingAt: node0 excluding: mergedNodes.
	order := OrderedCollection new.
	nodeMap := heap ifNotNil: #nodes.
	[ heap isNil ] whileFalse: [
			| id |
			id := heap id.
			heap := heap pop.
			graph at: id ifPresent: [ :neighbors |
					neighbors keysAndValuesDo: [ :neighborNode :weight |
							(done includes: neighborNode) ifFalse: [
								nodeMap at: neighborNode ifPresent: [ :node | node updatePriorityWith: [ :priority | priority - weight ] ] ] ] ].
			done add: id.
			order add: id ].
	^ order
]

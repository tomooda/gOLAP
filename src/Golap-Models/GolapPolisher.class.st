Class {
	#name : 'GolapPolisher',
	#superclass : 'Object',
	#instVars : [
		'burrEdgeKeys',
		'fillerEdgeKeys'
	],
	#category : 'Golap-Models-Analysis',
	#package : 'Golap-Models',
	#tag : 'Analysis'
}

{ #category : 'operations' }
GolapPolisher >> applyTo: aGolapModel [

	burrEdgeKeys do: [ :edgeKey |
		aGolapModel edgeAt: edgeKey ifPresent: [ :edge | edge remove ] ].
	fillerEdgeKeys do: [ :edgeKey |
			| node1 node2 edge |
			node1 := aGolapModel nodeAt: edgeKey first ifAbsent: [ nil ].
			node2 := aGolapModel nodeAt: edgeKey second ifAbsent: [ nil ].
			(node1 notNil and: [
				 node2 notNil and: [ (node1 edgeTo: node2) isNil ] ]) ifTrue: [
					edge := GolapEdge on: nil between: node1 and: node2.
					edge attach ] ]
]

{ #category : 'enumerating' }
GolapPolisher >> atNode: aGolapNode edgeKeysAndNodeIdsDo: aBlock [

	aGolapNode edgesAndNodeDo: [ :edge :peer |
			| edgeKey |
			edgeKey := edge key.
			(burrEdgeKeys includes: edgeKey) ifFalse: [
				aBlock value: edgeKey value: peer id ] ].
	fillerEdgeKeys do: [ :edgeKey |
			edgeKey first = aGolapNode id ifTrue: [
				aBlock value: edgeKey value: edgeKey second ].
			edgeKey second = aGolapNode id ifTrue: [
				aBlock value: edgeKey value: edgeKey first ] ]
]

{ #category : 'enumerating' }
GolapPolisher >> atNode: aGolapNode edgesAndNodesDo: aBlock [

	aGolapNode edgesAndNodeDo: [ :edge :peer |
		(burrEdgeKeys includes: edge) ifFalse: [
			aBlock value: edge value: peer ] ].
	fillerEdgeKeys do: [ :edge |
			(edge peerOf: aGolapNode) ifNotNil: [ :peer |
				aBlock value: edge value: peer ] ]
]

{ #category : 'enumerating' }
GolapPolisher >> fillerEdgeKeysDo: aBlock [

	fillerEdgeKeys do: aBlock
]

{ #category : 'operations' }
GolapPolisher >> fit: aGolapModel fillerThreshold: fillerThreshold burrThreshold: burrThreshold minClusterSize: minClusterSize [

	| hop2peers edgeKeys newFillerEdgesKeys newBurrEdgeKeys |
	hop2peers := Dictionary new.
	edgeKeys := Set new.
	newFillerEdgesKeys := Set new.
	newBurrEdgeKeys := Set new.
	aGolapModel nodesDo: [ :v1 |
			| peers |
			peers := hop2peers at: v1 id put: Dictionary new.
			self atNode: v1 edgeKeysAndNodeIdsDo: [ :key1 :id2 |
					edgeKeys add: key1.
					self
						atNode: (aGolapModel nodeAt: id2)
						edgeKeysAndNodeIdsDo: [ :key2 :id3 |
								v1 id < id3 ifTrue: [
									peers at: id3 put: (peers at: id3 ifAbsent: [ 0 ]) + 1 ] ] ] ].
	hop2peers keysAndValuesDo: [ :id1 :peerIdsAndDups |
			| node1 |
			node1 := aGolapModel nodeAt: id1.
			peerIdsAndDups keysAndValuesDo: [ :id2 :dups |
					| node2 |
					node2 := aGolapModel nodeAt: id2.
					(id1 ~~ id2 and: [ (self node: node1 hasEdgeTo: node2) not ])
						ifTrue: [
								| v1NumEdges v2NumEdges denominator |
								v1NumEdges := self numberOfEdgesAtNode: node1.
								v2NumEdges := self numberOfEdgesAtNode: node2.
								denominator := v1NumEdges + v2NumEdges - dups.
								denominator > minClusterSize ifTrue: [
										dups asFloat / (v1NumEdges + v2NumEdges - dups) asFloat
										> fillerThreshold ifTrue: [
											newFillerEdgesKeys add:
												(GolapEdge keyFrom: id1 and: id2) ] ] ] ] ].
	edgeKeys do: [ :edgeKey |
			| id1 id2 peersAndDups |
			id1 := edgeKey first.
			id2 := edgeKey second.
			peersAndDups := hop2peers at: id1.
			((peersAndDups includesKey: id2) and: [
					 | v1NumEdges v2NumEdges dups denominator |
					 v1NumEdges := self numberOfEdgesAtNode:
						               (aGolapModel nodeAt: id1).
					 v2NumEdges := self numberOfEdgesAtNode:
						               (aGolapModel nodeAt: id2).
					 dups := peersAndDups at: id2.
					 denominator := v1NumEdges + v2NumEdges - dups.
					 denominator > minClusterSize and: [
							 dups asFloat / (v1NumEdges + v2NumEdges - dups) asFloat
							 < burrThreshold ] ]) ifTrue: [ newBurrEdgeKeys add: edgeKey ] ].
	newFillerEdgesKeys removeAllSuchThat: [ :edgeKey |
		(newBurrEdgeKeys remove: edgeKey ifAbsent: [ nil ]) notNil ].
	newFillerEdgesKeys do: [ :edgeKey |
		burrEdgeKeys
			remove: edgeKey
			ifAbsent: [ fillerEdgeKeys add: edgeKey ] ].
	newBurrEdgeKeys do: [ :edgeKey |
		fillerEdgeKeys
			remove: edgeKey
			ifAbsent: [ burrEdgeKeys add: edgeKey ] ].
	^ newFillerEdgesKeys notEmpty or: [ newBurrEdgeKeys notEmpty ]
]

{ #category : 'operations' }
GolapPolisher >> fitToConverge: aGolapModel fillerThreshold: fillerThreshold burrThreshold: burrThreshold minClusterSize: minClusterSize [

	[
		self
			fit: aGolapModel
			fillerThreshold: fillerThreshold
			burrThreshold: burrThreshold
			minClusterSize: minClusterSize ] whileTrue
]

{ #category : 'initialization' }
GolapPolisher >> initialize [

	burrEdgeKeys := Set new.
	fillerEdgeKeys := Set new
]

{ #category : 'testing' }
GolapPolisher >> isBurrEdge: aGolapEdge [

	^ burrEdgeKeys includes: aGolapEdge key
]

{ #category : 'testing' }
GolapPolisher >> isFillerEdge: aGolapEdge [

	^ fillerEdgeKeys includes: aGolapEdge key
]

{ #category : 'testing' }
GolapPolisher >> node: aGolapNode1 hasEdgeTo: aGolapNode2 [

	(fillerEdgeKeys anySatisfy: [ :edgeKey |
			 (edgeKey includes: aGolapNode1 id) and: [
				 edgeKey includes: aGolapNode2 id ] ]) ifTrue: [ ^ true ].
	(aGolapNode1 edgeTo: aGolapNode2) ifNotNil: [ :edge |
		^ (burrEdgeKeys includes: edge key) not ].
	^ false
]

{ #category : 'accessing' }
GolapPolisher >> numberOfEdgesAtNode: aGolapNode [

	| numEdges |
	numEdges := aGolapNode numberOfEdges.
	fillerEdgeKeys do: [ :edgeKey |
		(edgeKey includes: aGolapNode id) ifTrue: [
			numEdges := numEdges + 1 ] ].
	burrEdgeKeys do: [ :edgeKey |
		(edgeKey includes: aGolapNode id) ifTrue: [
			numEdges := numEdges - 1 ] ].
	^ numEdges
]

{ #category : 'copying' }
GolapPolisher >> postCopy [

	super postCopy.
	burrEdgeKeys := burrEdgeKeys copy.
	fillerEdgeKeys := fillerEdgeKeys copy
]

{ #category : 'accessing' }
GolapPolisher >> reset [

	burrEdgeKeys removeAll.
	fillerEdgeKeys removeAll
]

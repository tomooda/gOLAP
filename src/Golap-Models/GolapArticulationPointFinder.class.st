Class {
	#name : 'GolapArticulationPointFinder',
	#superclass : 'Object',
	#instVars : [
		'edges',
		'order',
		'orders',
		'lows',
		'articulationPointsAndOrders'
	],
	#category : 'Golap-Models-Graph',
	#package : 'Golap-Models',
	#tag : 'Graph'
}

{ #category : 'examples' }
GolapArticulationPointFinder class >> example [

	| graph a b c d e f g h i edges finder |
	graph := GolapModel new.
	a := graph createNode: ({  } asDataSeries name: 'A') name: 'A'.
	b := graph createNode: ({  } asDataSeries name: 'B') name: 'B'.
	c := graph createNode: ({  } asDataSeries name: 'C') name: 'C'.
	d := graph createNode: ({  } asDataSeries name: 'D') name: 'D'.
	e := graph createNode: ({  } asDataSeries name: 'E') name: 'E'.
	f := graph createNode: ({  } asDataSeries name: 'F') name: 'F'.
	g := graph createNode: ({  } asDataSeries name: 'G') name: 'G'.
	h := graph createNode: ({  } asDataSeries name: 'H') name: 'H'.
	i := graph createNode: ({  } asDataSeries name: 'I') name: 'I'.
	edges := Array streamContents: [ :stream |
			         stream nextPut:
				         (a createEdgeTo: b data: {  } asDataSeries).
			         stream nextPut:
				         (a createEdgeTo: c data: {  } asDataSeries).
			         stream nextPut:
				         (c createEdgeTo: b data: {  } asDataSeries).
			         stream nextPut:
				         (b createEdgeTo: d data: {  } asDataSeries).
			         stream nextPut:
				         (d createEdgeTo: e data: {  } asDataSeries).
			         stream nextPut:
				         (d createEdgeTo: f data: {  } asDataSeries).
			         stream nextPut:
				         (b createEdgeTo: g data: {  } asDataSeries).
			         stream nextPut:
				         (g createEdgeTo: h data: {  } asDataSeries).
			         stream nextPut:
				         (h createEdgeTo: i data: {  } asDataSeries) ].
	finder := GolapArticulationPointFinder new
		          edges: edges;
		          yourself.
	^ finder articulationPoints inspect
]

{ #category : 'accessing' }
GolapArticulationPointFinder >> articulationPoints [

	^ self ensureArticulationPointsAndOrders keys asArray
]

{ #category : 'enumerating' }
GolapArticulationPointFinder >> articulationPointsAndIslandsDo: aBlock [

	self ensureArticulationPointsAndOrders keysAndValuesDo: [ :node :dict |
		aBlock value: node value: dict keys asArray ]
]

{ #category : 'enumerating' }
GolapArticulationPointFinder >> articulationPointsDo: aBlock [

	self ensureArticulationPointsAndOrders keysDo: aBlock
]

{ #category : 'accessing' }
GolapArticulationPointFinder >> edges: aCollectionOfGolapEdge [

	edges := aCollectionOfGolapEdge asIdentitySet
]

{ #category : 'private' }
GolapArticulationPointFinder >> ensureArticulationPointsAndOrders [

	^ articulationPointsAndOrders ifNil: [
			  | done |
			  order := 0.
			  articulationPointsAndOrders := IdentityDictionary new.
			  edges ifNil: [ ^ IdentityDictionary new ].
			  done := IdentitySet new.
			  edges ifEmpty: [ ^ articulationPointsAndOrders ].
			  edges do: [ :edge |
					  (done includes: edge node1) ifFalse: [
							  orders := IdentityDictionary new.
							  lows := IdentityDictionary new.
							  self searchNode: edge node1 parent: nil.
							  done addAll: orders keys ].
					  (done includes: edge node2) ifFalse: [
							  orders := IdentityDictionary new.
							  lows := IdentityDictionary new.
							  self searchNode: edge node2 parent: nil.
							  done addAll: orders keys ] ].
			  articulationPointsAndOrders := IdentityDictionary newFrom:
				                                 (articulationPointsAndOrders
					                                  associations collect: [ :assoc |
					                                  assoc key
					                                  -> assoc value keys asArray ]) ]
]

{ #category : 'enumerating' }
GolapArticulationPointFinder >> from: aGolapNode peersDo: aBlock [

	aGolapNode edgesAndNodeDo: [ :edge :peer |
		(edges includes: edge) ifTrue: [ aBlock value: peer ] ]
]

{ #category : 'initialization' }
GolapArticulationPointFinder >> initialize [

	super initialize.
	order := 0.
	orders := IdentityDictionary new.
	lows := IdentityDictionary new.
	articulationPointsAndOrders := nil
]

{ #category : 'private' }
GolapArticulationPointFinder >> searchNode: aGolapNode parent: parentNode [

	| numChildren |
	order := order + 1.
	orders at: aGolapNode put: order.
	lows at: aGolapNode put: order.
	numChildren := 0.
	self from: aGolapNode peersDo: [ :peerNode |
			peerNode ~~ parentNode ifTrue: [
					orders
						at: peerNode
						ifPresent: [
								lows
									at: aGolapNode
									put: ((lows at: aGolapNode) min: (orders at: peerNode)) ]
						ifAbsent: [
								numChildren := numChildren + 1.
								self searchNode: peerNode parent: aGolapNode.
								lows
									at: aGolapNode
									put: ((lows at: aGolapNode) min: (lows at: peerNode)).
								(parentNode notNil and: [
									 (lows at: peerNode) >= (orders at: aGolapNode) ]) ifTrue: [
									articulationPointsAndOrders
										at: aGolapNode
										ifAbsentPut: [ orders ] ] ] ] ].
	(parentNode isNil and: [ numChildren > 1 ]) ifTrue: [
		articulationPointsAndOrders at: aGolapNode ifAbsentPut: [ orders ] ]
]

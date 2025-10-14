Class {
	#name : 'GolapOverviewGridLayouter',
	#superclass : 'Object',
	#instVars : [
		'matrix',
		'edges',
		'nodeX',
		'nodeY'
	],
	#category : 'Golap-Visualization-Overview',
	#package : 'Golap-Visualization',
	#tag : 'Overview'
}

{ #category : 'operations' }
GolapOverviewGridLayouter class >> layoutNodes: aCollectionOfGolapNode edges: aCollectionOfGolapEdge limit: anInteger [

	^ self new
		  layoutNodes: aCollectionOfGolapNode
		  edges: aCollectionOfGolapEdge
		  limit: anInteger
]

{ #category : 'accessing' }
GolapOverviewGridLayouter >> bestNodeToSwapWith: aGolapNode withIndexDo: aBlock [

	| bestGain x y bestX bestY |
	bestGain := -1.
	x := nodeX at: aGolapNode.
	y := nodeY at: aGolapNode.
	self matrixWithIndexDo: [ :nodeOrNil :x1 :y1 |
			| gain |
			gain := self
				        gainBySwappingX: x
				        y: y
				        andX: x1
				        y: y1.
			bestGain < gain ifTrue: [
					bestGain := gain.
					bestX := x1.
					bestY := y1 ] ].
	(bestX notNil and: [ bestY notNil ]) ifTrue: [
		aBlock
			value: ((matrix at: bestX) at: bestY)
			value: bestX
			value: bestY ]
]

{ #category : 'operations' }
GolapOverviewGridLayouter >> createMatrixFromNodes: aCollectionOfGolapNode [

	matrix := aCollectionOfGolapNode
		          ifNotEmpty: [
				          | nodes n squareN numDummies dummyStep |
				          nodes := OrderedCollection withAll:
					                   (aCollectionOfGolapNode sorted: #id ascending).
				          n := nodes size sqrt ceiling + 1.
				          squareN := n squared.
				          numDummies := squareN - nodes size.
				          dummyStep := nodes size asFloat
				                       / (numDummies asFloat + 1.0).
				          numDummies to: 1 by: -1 do: [ :dummyIndex |
					          nodes
						          add: nil
						          beforeIndex: (dummyIndex * dummyStep) floor + 1 ].
				          (1 to: squareN by: n) collect: [ :baseIndex |
					          nodes copyFrom: baseIndex to: baseIndex + n - 1 ] ]
		          ifEmpty: [ Array new ].
	nodeX := IdentityDictionary new: aCollectionOfGolapNode size.
	nodeY := IdentityDictionary new: aCollectionOfGolapNode size.
	self matrixWithIndexDo: [ :nodeOrNil :x :y |
			nodeOrNil ifNotNil: [
					nodeX at: nodeOrNil put: x.
					nodeY at: nodeOrNil put: y ] ]
]

{ #category : 'accessing' }
GolapOverviewGridLayouter >> edges [

	^ edges
]

{ #category : 'accessing' }
GolapOverviewGridLayouter >> edges: aCollectionOfGolapEdge [

	edges := IdentitySet withAll: aCollectionOfGolapEdge
]

{ #category : 'accessing' }
GolapOverviewGridLayouter >> gainBySwappingX: x1 y: y1 andX: x2 y: y2 [

	| gain |
	gain := 0.
	((matrix at: x1) at: y1) ifNotNil: [ :node1 |
			node1 edgesAndNodeDo: [ :edge :peer |
					(edges includes: edge) ifTrue: [
							nodeX at: peer ifPresent: [ :peerX |
									nodeY at: peer ifPresent: [ :peerY |
											gain := gain + (x1 - peerX) squared + (y1 - peerY) squared
											        - (x2 - peerX) squared - (y2 - peerY) squared ] ] ] ] ].
	((matrix at: x2) at: y2) ifNotNil: [ :node2 |
			node2 edgesAndNodeDo: [ :edge :peer |
					(edges includes: edge) ifTrue: [
							nodeX at: peer ifPresent: [ :peerX |
									nodeY at: peer ifPresent: [ :peerY |
											gain := gain - (x1 - peerX) squared - (y1 - peerY) squared
											        + (x2 - peerX) squared + (y2 - peerY) squared ] ] ] ] ].
	^ gain
]

{ #category : 'operations' }
GolapOverviewGridLayouter >> improve [

	| done worstNode |
	done := IdentitySet new.
	[
		worstNode := self worstNodeExcept: done.
		worstNode notNil ] whileTrue: [
			(self improve: worstNode) ifTrue: [ ^ true ].
			done add: worstNode ].
	^ false
]

{ #category : 'operations' }
GolapOverviewGridLayouter >> improve: aGolapNode [

	self bestNodeToSwapWith: aGolapNode withIndexDo: [ :bestNode :x :y |
			self swapNode: aGolapNode withX: x y: y.
			^ true ].
	^ false
]

{ #category : 'operations' }
GolapOverviewGridLayouter >> improveEvery [

	edges do: [ :edge |
			(nodeX includesKey: edge node1) ifTrue: [ self improve: edge node1 ].
			(nodeX includesKey: edge node2) ifTrue: [ self improve: edge node2 ] ]
]

{ #category : 'operations' }
GolapOverviewGridLayouter >> layoutNodes: aCollectionOfGolapNode edges: aCollectionOfGolapEdge limit: anInteger [

	| count positions |
	SpProgressDialog new
		title: 'グラフ再配置中…';
		informUserDuring: [ :progress |
				count := 0.
				self edges: aCollectionOfGolapEdge.
				self createMatrixFromNodes: aCollectionOfGolapNode.
				progress
					progressPercent: 25.
				self improveEvery.
				progress
					progressPercent: 50.
				self improveEvery.
				progress
					progressPercent: 75.
				[ self improve and: [ (count := count + 1) < anInteger ] ]
					whileTrue: [
							| percent |
							percent := 75 + (count * 100.0 / anInteger asFloat).
							progress
								label: percent floor asString;
								progressPercent: percent ].
				progress
					label: '完了';
					progressPercent: 100.
				positions := IdentityDictionary new: aCollectionOfGolapNode size.
				aCollectionOfGolapNode do: [ :node |
						nodeX at: node ifPresent: [ :x |
								| yOffset |
								yOffset := x odd
									           ifTrue: [ 0.1 ]
									           ifFalse: [ -0.1 ].
								nodeY at: node ifPresent: [ :y |
										positions at: node put: x asFloat + (y odd
												 ifTrue: [ 0.1 ]
												 ifFalse: [ -0.1 ]) @ (y asFloat + yOffset) ] ] ] ].
	^ positions
]

{ #category : 'enumerating' }
GolapOverviewGridLayouter >> matrixWithIndexDo: aBlock [

	matrix withIndexDo: [ :array :x |
			array withIndexDo: [ :nodeOrNil :y |
				aBlock value: nodeOrNil value: x value: y ] ]
]

{ #category : 'accessing' }
GolapOverviewGridLayouter >> penaltyAtX: x y: y [

	| penalty |
	penalty := 0.
	((matrix at: x) at: y) ifNotNil: [ :node |
			| numEdges |
			numEdges := 0.
			node edgesAndNodeDo: [ :edge :peer |
					(edges includes: edge) ifTrue: [
							numEdges := numEdges + 1.
							nodeX at: peer ifPresent: [ :peerX |
									nodeY at: peer ifPresent: [ :peerY |
										penalty := penalty + (x - peerX) squared
										           + (y - peerY) squared ] ] ] ].
			numEdges > 0 ifTrue: [
				penalty := penalty asFloat / numEdges asFloat ] ].
	^ penalty
]

{ #category : 'accessing' }
GolapOverviewGridLayouter >> swapNode: node1 withX: x2 y: y2 [

	| node2 x1 y1 |
	node2 := (matrix at: x2) at: y2.
	x1 := nodeX at: node1.
	y1 := nodeY at: node1.
	(matrix at: x2) at: y2 put: node1.
	nodeX at: node1 put: x2.
	nodeY at: node1 put: y2.
	(matrix at: x1) at: y1 put: node2.
	nodeX at: node2 put: x1.
	nodeY at: node2 put: y1
]

{ #category : 'accessing' }
GolapOverviewGridLayouter >> worstNodeExcept: anIdentitySetOfGolapNode [

	| worstPenalty worstNode |
	worstPenalty := -1.
	self matrixWithIndexDo: [ :nodeOrNil :x :y |
			(anIdentitySetOfGolapNode includes: nodeOrNil) ifFalse: [
					| penalty |
					penalty := self penaltyAtX: x y: y.
					worstPenalty < penalty ifTrue: [
							worstPenalty := penalty.
							worstNode := nodeOrNil ] ] ].
	^ worstNode
]

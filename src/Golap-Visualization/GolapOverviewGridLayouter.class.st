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
GolapOverviewGridLayouter class >> layoutNodes: aCollectionOfGolapNode edges: aCollectionOfGolapEdge [

	^ self new
		  layoutNodes: aCollectionOfGolapNode
		  edges: aCollectionOfGolapEdge
]

{ #category : 'accessing' }
GolapOverviewGridLayouter >> bestNodeToSwapWith: aGolapNode withIndexDo: aBlock [

	| bestGain x y bestX bestY |
	bestGain := 0.
	x := nodeX at: aGolapNode.
	y := nodeY at: aGolapNode.
	self matrixWithIndexDo: [ :nodeOrNil :x1 :y1 |
			aGolapNode ~~ nodeOrNil ifTrue: [
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
					value: bestY ] ]
]

{ #category : 'operations' }
GolapOverviewGridLayouter >> createMatrixFromNodes: aCollectionOfGolapNode [

	matrix := aCollectionOfGolapNode
		          ifNotEmpty: [
				          | nodes n squareN numDummies dummyStep |
				          nodes := OrderedCollection withAll:
					                   (aCollectionOfGolapNode sorted: #id ascending).
				          n := (nodes size sqrt * 1.4) ceiling.
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
GolapOverviewGridLayouter >> improve: aGolapNode [

	self bestNodeToSwapWith: aGolapNode withIndexDo: [ :bestNode :x :y |
			self swapNode: aGolapNode withX: x y: y.
			^ true ].
	^ false
]

{ #category : 'operations' }
GolapOverviewGridLayouter >> improveEveryNodeFrom: aCollectionOfGolapNode interim: aBlock [

	| mod |
	mod := aCollectionOfGolapNode size // 20 + 1.
	aCollectionOfGolapNode withIndexDo: [ :node :index |
			self improve: node.
			index \\ mod = 0 ifTrue: [
				aBlock value: index asFloat / aCollectionOfGolapNode size asFloat ] ]
]

{ #category : 'operations' }
GolapOverviewGridLayouter >> layoutNodes: aCollectionOfGolapNode edges: aCollectionOfGolapEdge [

	| positions reps |
	SpProgressDialog new
		title: 'グラフ再配置中…';
		informUserDuring: [ :progress |
				reps := 10.
				self edges: aCollectionOfGolapEdge.
				self createMatrixFromNodes: aCollectionOfGolapNode.
				0 to: reps - 1 do: [ :rep |
							self
								improveEveryNodeFrom: aCollectionOfGolapNode
								interim: [ :v |
										progress progressPercent:
												v / reps asFloat + (rep asFloat / reps asFloat) * 100.0 ] ].
				progress
					label: '完了';
					progressPercent: 100.
				positions := Dictionary new: aCollectionOfGolapNode size.
				aCollectionOfGolapNode do: [ :node |
						nodeX at: node ifPresent: [ :x |
								| yOffset |
								yOffset := x odd
									           ifTrue: [ 0.1 ]
									           ifFalse: [ -0.1 ].
								nodeY at: node ifPresent: [ :y |
										positions at: node id put: x asFloat + (y odd
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

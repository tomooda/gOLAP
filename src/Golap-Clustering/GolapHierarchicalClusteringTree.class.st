Class {
	#name : 'GolapHierarchicalClusteringTree',
	#superclass : 'Object',
	#instVars : [
		'parent',
		'score'
	],
	#category : 'Golap-Clustering-Core',
	#package : 'Golap-Clustering',
	#tag : 'Core'
}

{ #category : 'instance creation' }
GolapHierarchicalClusteringTree class >> friendsClusterFrom: aGolapModel depth: anInteger [

	| done edges rank trees |
	edges := OrderedCollection new.
	done := IdentitySet new: aGolapModel graphNodes size.
	aGolapModel graphNodesDo: [ :node |
		done add: node.
		node basicEdgesAndNodesDo: [ :edge :peer |
			(done includes: peer) ifFalse: [
				edges add: edge -> (aGolapModel valueAtEdge: edge) ] ] ].
	edges := edges sorted: #value.
	rank := 1.
	trees := aGolapModel graphNodes asArray collect: [ :node |
		         GolapHierarchicalClusteringLeaf
			         node: node
			         score: (aGolapModel valueAtNode: node) ].
	anInteger timesRepeat: [  ]
]

{ #category : 'accessing' }
GolapHierarchicalClusteringTree >> allLeaves [

	^ Array streamContents: [ :stream |
		  self leavesDo: [ :leaf | stream nextPut: leaf ] ]
]

{ #category : 'converting' }
GolapHierarchicalClusteringTree >> asArray [

	^ self graphNodes
]

{ #category : 'enumerating' }
GolapHierarchicalClusteringTree >> childrenDo: aBlock [

	^ self subclassResponsibility
]

{ #category : 'accessing' }
GolapHierarchicalClusteringTree >> depth [

	| depth node |
	depth := 1.
	node := parent.
	[ node notNil ] whileTrue: [
		node := node parent.
		depth := depth + 1 ].
	^ depth
]

{ #category : 'accessing' }
GolapHierarchicalClusteringTree >> graphNodes [

	^ Array streamContents: [ :stream |
		  self graphNodesDo: [ :node | stream nextPut: node ] ]
]

{ #category : 'enumerating' }
GolapHierarchicalClusteringTree >> graphNodesDo: aBlock [

	self leavesDo: [ :leaf | leaf graphNode ifNotNil: aBlock ]
]

{ #category : 'testing' }
GolapHierarchicalClusteringTree >> hasChild: aTree [

	^ self subclassResponsibility
]

{ #category : 'testing' }
GolapHierarchicalClusteringTree >> ifEmpty: aFullBlockClosure [

	self isEmpty ifTrue: aFullBlockClosure
]

{ #category : 'controlling' }
GolapHierarchicalClusteringTree >> ifNode: aBlock [
]

{ #category : 'testing' }
GolapHierarchicalClusteringTree >> isLeaf [

	^ false
]

{ #category : 'testing' }
GolapHierarchicalClusteringTree >> isNode [

	^ false
]

{ #category : 'enumerating' }
GolapHierarchicalClusteringTree >> leavesDo: aBlock [

	^ self subclassResponsibility
]

{ #category : 'enumerating' }
GolapHierarchicalClusteringTree >> leavesWithIndexDo: aBlock [

	| index |
	index := 0.
	self leavesDo: [ :leaf |
		aBlock cull: leaf cull: (index := index + 1) ]
]

{ #category : 'accessing' }
GolapHierarchicalClusteringTree >> maxDepth [

	^ self allLeaves
		  ifNotEmpty: [ :leaves | (leaves collect: #depth) max ]
		  ifEmpty: [ 0 ]
]

{ #category : 'enumerating' }
GolapHierarchicalClusteringTree >> nodesDo: aBlock [

	^ self subclassResponsibility
]

{ #category : 'accessing' }
GolapHierarchicalClusteringTree >> oneGraphNode [

	^ self oneLeaf ifNotNil: #graphNode
]

{ #category : 'accessing' }
GolapHierarchicalClusteringTree >> oneLeaf [

	^ self subclassResponsibility
]

{ #category : 'visualization' }
GolapHierarchicalClusteringTree >> openSunburst [

	| markers photoOffset sunburstBuilder bezierBuilder |
	markers := OrderedCollection new.
	self graphNodesDo: [ :node |
		node markers do: [ :color |
			(markers includes: color) ifFalse: [ markers add: color ] ] ].
	photoOffset := markers size * 10 + 20.
	sunburstBuilder := RSSunburstBuilder new.
	sunburstBuilder
		sliceColor: [ :slice |
			slice model isLeaf
				ifTrue: [ Color lightGray ]
				ifFalse: [ Color transparent ] ];
		explore: self using: #trees;
		build.
	sunburstBuilder shapes do: [ :shape |
		shape model isLeaf ifTrue: [
			| radius |
			shape model graphNode photoimage ifNotNil: [ :photoimage |
				sunburstBuilder canvas addShape: ((RSBitmap newFrom: photoimage)
						 position: (shape centroid:
									  shape externalRadius - shape innerRadius / 2 + photoOffset);
						 extent: (shape externalRadius
							  * ((shape alphaAngle - shape betaAngle) abs / 90.0 * 3.14)
								  min: shape externalRadius - shape innerRadius) asPoint
								 yourself) ].
			radius := shape externalRadius + 1.
			markers do: [ :color |
				(shape model graphNode hasMarker: color)
					ifTrue: [
						sunburstBuilder canvas addShape: (shape copy
								 innerRadius: radius;
								 externalRadius: (radius := radius + 10);
								 color: color) ]
					ifFalse: [ radius := radius + 10 ] ] ] ].
	sunburstBuilder canvas @ RSCanvasController.
	sunburstBuilder shapes @ GolapNodeInteraction.
	bezierBuilder := RSLineBuilder sunburstBezier.
	bezierBuilder
		capRound;
		canvas: sunburstBuilder canvas.
	(bezierBuilder connectFrom: #parent)
		do: [ :bezier |
			bezier
				width: (100.0 * bezier model value score / self score) abs;
				color: (bezier model value score >= 0
						 ifTrue: [ Color black ]
						 ifFalse: [ Color red ]) ];
		@ GolapChartInteraction.
	sunburstBuilder canvas open maximize.
	^ sunburstBuilder
]

{ #category : 'accessing' }
GolapHierarchicalClusteringTree >> parent [

	^ parent
]

{ #category : 'accessing' }
GolapHierarchicalClusteringTree >> parent: aGolapHierarchicalClusteringNode [

	parent := aGolapHierarchicalClusteringNode
]

{ #category : 'private' }
GolapHierarchicalClusteringTree >> removeAllBut: aCollectionOfGolapNode [

	^ self subclassResponsibility
]

{ #category : 'accessing' }
GolapHierarchicalClusteringTree >> score [

	^ score
]

{ #category : 'accessing' }
GolapHierarchicalClusteringTree >> score: aNumber [

	score := aNumber
]

{ #category : 'accessing' }
GolapHierarchicalClusteringTree >> size [

	^ self subclassResponsibility
]

{ #category : 'accessing' }
GolapHierarchicalClusteringTree >> trees [

	^ self subclassResponsibility
]

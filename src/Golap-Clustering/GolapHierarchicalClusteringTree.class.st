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
	done := IdentitySet new: aGolapModel nodes size.
	aGolapModel nodesDo: [ :node |
		done add: node.
		node basicEdgesAndNodesDo: [ :edge :peer |
			(done includes: peer) ifFalse: [
				edges add: edge -> (aGolapModel valueAtEdge: edge) ] ] ].
	edges := edges sorted: #value.
	rank := 1.
	trees := aGolapModel nodes asArray collect: [ :node |
		         GolapHierarchicalClusteringLeaf
			         node: node
			         score: (aGolapModel valueAtNode: node) ].
	anInteger timesRepeat: [  ]
]

{ #category : 'controlling' }
GolapHierarchicalClusteringTree >> ifNode: aBlock [
]

{ #category : 'testing' }
GolapHierarchicalClusteringTree >> includesNode: aGolapNode [

	self leavesDo: [ :leaf |
		leaf node == aGolapNode ifTrue: [ ^ true ] ].
	^ false
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

{ #category : 'accessing' }
GolapHierarchicalClusteringTree >> nodes [

	^ Array streamContents: [ :stream |
		  self nodesDo: [ :node | stream nextPut: node ] ]
]

{ #category : 'enumerating' }
GolapHierarchicalClusteringTree >> nodesDo: aBlock [

	self leavesDo: [ :leaf | leaf node ifNotNil: aBlock ]
]

{ #category : 'accessing' }
GolapHierarchicalClusteringTree >> oneNode [

	^ self subclassResponsibility
]

{ #category : 'visualization' }
GolapHierarchicalClusteringTree >> openSunburst [

	| markers photoOffset sunburstBuilder bezierBuilder |
	markers := OrderedCollection new.
	self nodesDo: [ :node |
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
			shape model node photoimage ifNotNil: [ :photoimage |
				sunburstBuilder canvas addShape: ((RSBitmap newFrom: photoimage)
						 position: (shape centroid:
									  shape externalRadius - shape innerRadius / 2 + photoOffset);
						 extent: (shape externalRadius
							  * ((shape alphaAngle - shape betaAngle) abs / 90.0 * 3.14)
								  min: shape externalRadius - shape innerRadius) asPoint
								 yourself) ].
			radius := shape externalRadius + 1.
			markers do: [ :color |
				(shape model node hasMarker: color)
					ifTrue: [
						sunburstBuilder canvas addShape: (shape copy
								 innerRadius: radius;
								 externalRadius: (radius := radius + 10);
								 color: color) ]
					ifFalse: [ radius := radius + 10 ] ] ] ].
	sunburstBuilder canvas @ RSCanvasController.
	sunburstBuilder shapes @ GolapDandelionNodeInteraction.
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
		@ GolapDandelionChartInteraction.
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

{ #category : 'accessing' }
GolapHierarchicalClusteringTree >> score [

	^ score
]

{ #category : 'accessing' }
GolapHierarchicalClusteringTree >> score: aNumber [

	score := aNumber
]

{ #category : 'accessing' }
GolapHierarchicalClusteringTree >> trees [

	^ self subclassResponsibility
]

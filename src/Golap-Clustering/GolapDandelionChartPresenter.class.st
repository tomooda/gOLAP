Class {
	#name : #GolapDandelionChartPresenter,
	#superclass : #SpRoassalPresenter,
	#instVars : [
		'golap',
		'tree'
	],
	#category : #'Golap-Clustering'
}

{ #category : #'accessing-colors' }
GolapDandelionChartPresenter >> colorForVertex: aGolapVertex [

	^ golap colorForVertex: aGolapVertex
]

{ #category : #accessing }
GolapDandelionChartPresenter >> golap: aGolap [

	golap := aGolap.
	self golapChanged
]

{ #category : #accessing }
GolapDandelionChartPresenter >> golapChanged [

	self updateTree
]

{ #category : #initialization }
GolapDandelionChartPresenter >> initializeWindow: aSpWindowPresenter [

	super initializeWindow: aSpWindowPresenter.
	aSpWindowPresenter title: 'Dandelion Chart'
]

{ #category : #operations }
GolapDandelionChartPresenter >> toggleSelection: aGolapVertex [

	golap toggleSelection: aGolapVertex.
	self updateVertex: aGolapVertex
]

{ #category : #accessing }
GolapDandelionChartPresenter >> tree: aGolapHierarchicalClusteringTree [

	tree := aGolapHierarchicalClusteringTree.
	self treeChanged
]

{ #category : #accessing }
GolapDandelionChartPresenter >> treeChanged [

	self updateCanvas
]

{ #category : #updating }
GolapDandelionChartPresenter >> updateCanvas [

	| markers photoOffset sunburstBuilder bezierBuilder |
	markers := OrderedCollection new.
	tree verticesDo: [ :vertex |
		vertex markers do: [ :c |
			(markers includes: color) ifFalse: [ markers add: c ] ] ].
	photoOffset := markers size * 10 + 20.
	sunburstBuilder := RSSunburstBuilder new.
	sunburstBuilder
		container: self canvas;
		sliceColor: [ :slice |
			slice model isLeaf
				ifTrue: [ self colorForVertex: slice model vertex ]
				ifFalse: [ Color transparent ] ];
		explore: tree using: #trees;
		build.
	sunburstBuilder shapes do: [ :shape |
		shape model isLeaf ifTrue: [
			| radius |
			shape model vertex photoimage ifNotNil: [ :photoimage |
				sunburstBuilder canvas addShape: ((RSBitmap newFrom: photoimage)
						 position: (shape centroid:
									  shape externalRadius - shape innerRadius / 2 + photoOffset);
						 extent: (shape externalRadius
							  * ((shape alphaAngle - shape betaAngle) abs / 90.0 * 3.14)
								  min: shape externalRadius - shape innerRadius) asPoint
								 yourself) ].
			radius := shape externalRadius + 1.
			markers do: [ :c |
				(shape model vertex hasMarker: c)
					ifTrue: [
						sunburstBuilder canvas addShape: (shape copy
								 innerRadius: radius;
								 externalRadius: (radius := radius + 10);
								 color: c) ]
					ifFalse: [ radius := radius + 10 ] ] ] ].
	sunburstBuilder canvas @ RSCanvasController.
	sunburstBuilder shapes @ (GolapDandelionNodeInteraction on: self).
	bezierBuilder := RSLineBuilder sunburstBezier.
	bezierBuilder
		capRound;
		canvas: sunburstBuilder canvas.
	(bezierBuilder connectFrom: #parent)
		do: [ :bezier |
			bezier
				width: (100.0 * bezier model value score / tree score) abs;
				color: (bezier model value score >= 0
						 ifTrue: [ Color black ]
						 ifFalse: [ Color red ]) ];
		@ GolapDandelionEdgeInteraction.
	self canvas zoomToFit.
	self refresh
]

{ #category : #updating }
GolapDandelionChartPresenter >> updateTree [

	self tree: ((GolapHierarchicalClustering on: golap model)
			 rank: 2;
			 rank: 4;
			 rank: 8;
			 rank: 16;
			 rank: 32;
			 rank: 64;
			 rank: 128;
			 rank: 256;
			 tree)
]

{ #category : #updating }
GolapDandelionChartPresenter >> updateVertex: aGolapVertex [

	self canvas shapes do: [ :shape |
		((shape model respondsTo: #vertex) and: [
			 shape model vertex == aGolapVertex ]) ifTrue: [
			shape color: (self colorForVertex: aGolapVertex) ] ]
]

{ #category : #updating }
GolapDandelionChartPresenter >> zoomToFit [

	self canvas zoomToFit.
	self refresh
]

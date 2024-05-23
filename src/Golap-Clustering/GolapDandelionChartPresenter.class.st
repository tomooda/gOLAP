Class {
	#name : 'GolapDandelionChartPresenter',
	#superclass : 'SpRoassalPresenter',
	#instVars : [
		'golap',
		'tree'
	],
	#category : 'Golap-Clustering-Dandelion',
	#package : 'Golap-Clustering',
	#tag : 'Dandelion'
}

{ #category : 'accessing-colors' }
GolapDandelionChartPresenter >> colorForNode: aGolapNode [

	^ golap colorForNode: aGolapNode
]

{ #category : 'accessing' }
GolapDandelionChartPresenter >> golap [

	^ golap
]

{ #category : 'accessing' }
GolapDandelionChartPresenter >> golap: aGolap [

	golap := aGolap.
	golap announcer
		when: GolapModelUpdated send: #updateTree to: self;
		when: GolapViewUpdated send: #updateNode to: self.
	self golapChanged
]

{ #category : 'accessing' }
GolapDandelionChartPresenter >> golapChanged [

	golap model ifNotNil: [ self updateTree ]
]

{ #category : 'initialization' }
GolapDandelionChartPresenter >> initializeWindow: aSpWindowPresenter [

	super initializeWindow: aSpWindowPresenter.
	aSpWindowPresenter title: 'Dandelion Chart'
]

{ #category : 'operations' }
GolapDandelionChartPresenter >> toggleSelection: aGolapNode [

	golap toggleSelection: aGolapNode.
	self updateNode: aGolapNode
]

{ #category : 'operations' }
GolapDandelionChartPresenter >> toggleSelectionsAll: aCollectionOfGolapNode [

	(aCollectionOfGolapNode anySatisfy: [ :node |
		 (golap includesSelection: node) not ])
		ifTrue: [ golap selectAll: aCollectionOfGolapNode ]
		ifFalse: [ golap unselectAll: aCollectionOfGolapNode ].
	self updateNode
]

{ #category : 'accessing' }
GolapDandelionChartPresenter >> tree: aGolapHierarchicalClusteringTree [

	tree := aGolapHierarchicalClusteringTree.
	self treeChanged
]

{ #category : 'accessing' }
GolapDandelionChartPresenter >> treeChanged [

	self updateCanvas
]

{ #category : 'updating' }
GolapDandelionChartPresenter >> updateCanvas [

	| markers sunburstBuilder bezierBuilder |
	markers := golap allMarkerColors.
	sunburstBuilder := RSSunburstBuilder new.
	self canvas shapes do: #remove.
	sunburstBuilder
		container: self canvas;
		sliceColor: [ :slice |
			slice model isLeaf
				ifTrue: [ self colorForNode: slice model graphNode ]
				ifFalse: [ Color transparent ] ];
		explore: tree using: #trees;
		build.
	sunburstBuilder shapes do: [ :shape |
		shape model isLeaf ifTrue: [
			| radius |
			radius := shape externalRadius + 1.
			markers do: [ :c |
				sunburstBuilder canvas addShape: (shape copy
						 innerRadius: radius;
						 externalRadius: (radius := radius + 10);
						 color: ((shape model graphNode hasMarker: c)
								  ifTrue: [ c ]
								  ifFalse: [ Color transparent ]);
						 model: {
								 #marker.
								 shape model graphNode.
								 c }) ] ] ].
	sunburstBuilder canvas @ (GolapDandelionCanvasController on: self).
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
		@ (GolapDandelionEdgeInteraction on: self).
	self zoomToFit
]

{ #category : 'updating' }
GolapDandelionChartPresenter >> updateNode [

	self canvas shapes do: [ :shape |
		(shape model respondsTo: #graphNode) ifTrue: [
			shape color: (self colorForNode: shape model graphNode) ].
		(shape model isArray and: [ shape model first = #marker ]) ifTrue: [
			| v c |
			v := shape model second.
			c := shape model third.
			shape color: ((v hasMarker: c)
					 ifTrue: [ c ]
					 ifFalse: [ Color transparent ]) ] ].
	self canvas signalUpdate
]

{ #category : 'updating' }
GolapDandelionChartPresenter >> updateNode: aGolapNode [

	self canvas shapes do: [ :shape |
		((shape model respondsTo: #graphNode) and: [
			 shape model graphNode == aGolapNode ]) ifTrue: [
			shape color: (self colorForNode: aGolapNode) ].
		(shape model isArray and: [
			 shape model first = #marker and: [
				 shape model second == aGolapNode ] ]) ifTrue: [
			| c |
			c := shape model third.
			shape color: ((aGolapNode hasMarker: c)
					 ifTrue: [ c ]
					 ifFalse: [ Color transparent ]) ] ].
	self canvas signalUpdate
]

{ #category : 'updating' }
GolapDandelionChartPresenter >> updatePhotoimage: shape [

	shape model graphNode photoimage ifNotNil: [ :photoimage |
		(shape schildren contains: [ :child | child model = #photoimage ])
			ifFalse: [
				shape canvas addShape: ((RSBitmap newFrom: photoimage)
						 model: #photoimage;
						 position:
							 (shape centroid: shape externalRadius - shape innerRadius / 2
									  + (golap allMarkerColors size * 10 + 20));
						 extent: (shape externalRadius
							  * ((shape alphaAngle - shape betaAngle) abs / 90.0 * 3.14)
								  min: shape externalRadius - shape innerRadius) asPoint;
						 yourself) ] ]
]

{ #category : 'updating' }
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

{ #category : 'updating' }
GolapDandelionChartPresenter >> zoomToFit [

	self canvas
		zoomToFit;
		signalUpdate
]

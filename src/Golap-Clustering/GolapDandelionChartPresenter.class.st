Class {
	#name : 'GolapDandelionChartPresenter',
	#superclass : 'GolapHierarchicalClusteringPresenter',
	#category : 'Golap-Clustering-Dandelion',
	#package : 'Golap-Clustering',
	#tag : 'Dandelion'
}

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
						 externalRadius: (radius := radius + self markerWidth);
						 color: ((shape model graphNode hasMarker: c)
								  ifTrue: [ c ]
								  ifFalse: [ Color transparent ]);
						 model:
							 (self markerModelForNode: shape model graphNode color: c)) ] ] ].
	sunburstBuilder shapes @ (GolapNodeInteraction on: self).
	bezierBuilder := RSLineBuilder sunburstBezier.
	bezierBuilder
		capRound;
		canvas: sunburstBuilder canvas.
	(bezierBuilder connectFrom: #parent)
		do: [ :bezier |
			bezier
				width: (self edgeWidthForScore: bezier model value score) ceiling;
				color: (self edgeColorForScore: bezier model value score) ];
		@ (GolapEdgeInteraction on: self).
	self zoomToFit
]

{ #category : 'accessing' }
GolapDandelionChartPresenter >> windowTitle [

	^ 'Dandelion Chart'
]

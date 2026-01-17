Class {
	#name : 'GolapDandelionChartPresenter',
	#superclass : 'GolapHierarchicalClusteringPresenter',
	#category : 'Golap-Visualization-Dandellion',
	#package : 'Golap-Visualization',
	#tag : 'Dandellion'
}

{ #category : 'updating' }
GolapDandelionChartPresenter >> updateCanvas [

	self isDisplayed ifTrue: [
			| colorMarkers sunburstBuilder bezierBuilder |
			colorMarkers := golap colorMarkers.
			sunburstBuilder := RSSunburstBuilder new.
			self canvas shapes copy do: #remove.
			sunburstBuilder
				container: self canvas;
				sliceColor: [ :slice |
						slice model isLeaf
							ifTrue: [
								self colorForNode: (golap model nodeAt: slice model id) ]
							ifFalse: [ Color transparent ] ];
				explore: tree using: #trees;
				build.
			sunburstBuilder shapes do: [ :shape |
					shape model isLeaf ifTrue: [
							| radius |
							radius := shape externalRadius + 1.
							colorMarkers do: [ :marker |
									| c |
									c := marker color.
									sunburstBuilder canvas addShape: (shape copy
											 innerRadius: radius;
											 externalRadius: (radius := radius + self markerWidth);
											 color: ((marker includesNodeId: shape model id)
													  ifTrue: [ c ]
													  ifFalse: [ Color transparent ]);
											 model: (self
													  markerModelForNode:
														  (golap model nodeAt: shape model id)
													  marker: marker)) ] ] ].
			sunburstBuilder shapes @ (GolapNodeInteraction on: self).
			bezierBuilder := RSLineBuilder sunburstBezier.
			bezierBuilder
				capRound;
				canvas: sunburstBuilder canvas.
			(bezierBuilder connectFrom: #parent)
				do: [ :bezier |
						bezier
							width:
								(self edgeWidthForScore: bezier model value score) ceiling;
							color: (self edgeColorForScore: bezier model value score) ];
				@ (GolapEdgeInteraction on: self).
			self zoomToFit ]
]

{ #category : 'accessing' }
GolapDandelionChartPresenter >> windowTitle [

	^ 'Dandelion Chart'
]

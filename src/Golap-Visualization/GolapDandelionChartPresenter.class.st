Class {
	#name : 'GolapDandelionChartPresenter',
	#superclass : 'GolapHierarchicalClusteringPresenter',
	#category : 'Golap-Visualization-Dandellion',
	#package : 'Golap-Visualization',
	#tag : 'Dandellion'
}

{ #category : 'instance creation' }
GolapDandelionChartPresenter >> fromJSON: aDictionary [

	super fromJSON: aDictionary.
	self updateTree
]

{ #category : 'updating' }
GolapDandelionChartPresenter >> updateCanvas [

	self isDisplayed ifTrue: [
			lock critical: [
					| colorMarkers sunburstBuilder bezierBuilder |
					self ensureTree.
					colorMarkers := golap colorMarkers.
					sunburstBuilder := RSSunburstBuilder new.
					self canvas shapes copy do: #remove.
					SpProgressDialog new
						title: '描画中…';
						informUserDuring: [ :progress |
								| due sofar |
								due := tree numberOfNodesAndLeaves.
								sofar := 0.
								sunburstBuilder
									container: self canvas;
									sliceColor: [ :slice |
											slice model isLeaf
												ifTrue: [
													self colorForNode: (golap model nodeAt: slice model id) ]
												ifFalse: [ Color transparent ] ];
									explore: tree using: [ :t |
											sofar := sofar + 100.
											progress progressPercent: sofar // (due + 1).
											t trees ];
									build ].
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
					self zoomToFit ] ]
]

{ #category : 'accessing' }
GolapDandelionChartPresenter >> windowTitle [

	^ 'Dandelion Chart'
]

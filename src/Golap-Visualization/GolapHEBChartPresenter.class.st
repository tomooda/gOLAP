Class {
	#name : 'GolapHEBChartPresenter',
	#superclass : 'GolapHierarchicalClusteringPresenter',
	#category : 'Golap-Visualization-HEB',
	#package : 'Golap-Visualization',
	#tag : 'HEB'
}

{ #category : 'instance creation' }
GolapHEBChartPresenter >> fromJSON: aDictionary [

	super fromJSON: aDictionary.
	self updateTree
]

{ #category : 'updating' }
GolapHEBChartPresenter >> updateCanvas [

	self isDisplayed ifTrue: [
			lock critical: [
					|  arcWidth colorMarkers hebBuilder modelMap |
					self updateTree.
					arcWidth := golap model nodes size.
					colorMarkers := golap colorMarkers.
					hebBuilder := RSHierarchicalEdgeBundleBuilder new.
					hebBuilder constantWidthStrategy
						centerWidth: arcWidth;
						arcWidth: arcWidth.
					self canvas shapes copy do: #remove.
					modelMap := IdentityDictionary new.
					GolapProgressDialog new
						title: '描画中…';
						informUserDuring: [ :progress |
								| due sofar |
								due := tree numberOfNodesAndLeaves.
								sofar := 0.
								hebBuilder
									container: self canvas;
									sliceColor: [ :slice |
											slice model isLeaf
												ifTrue: [
														modelMap at: slice model id put: slice model.
														self colorForNode: (golap model nodeAt: slice model id) ]
												ifFalse: [ Color transparent ] ];
									explore: tree using: [ :t |
											sofar := sofar + 100.
											progress progressPercent: sofar // (due + 1).
											t trees ];
									build.
								self golapModelDo: [ :golapModel |
										golapModel edgesDo: [ :edge |
												(golapModel normalizedValueAtEdge: edge) ifNotNil: [ :edgeValue |
														(golap colorForEdge: edge) ifNotNil: [ :color |
																modelMap at: edge node1 id ifPresent: [ :node1 |
																		modelMap at: edge node2 id ifPresent: [ :node2 |
																				hebBuilder addEdgeBetween: node1 and: node2 do: [ :bspline |
																						bspline
																							model: edge;
																							width: edgeValue * 50 + 1;
																							color: (color alpha: 0.2);
																							capRound ] ] ] ] ] ] ].
								self canvas shapes do: [ :shape |
										((shape model isKindOf: GolapHierarchicalClusteringTree) and: [ shape model isLeaf ]) ifTrue: [
												| color position gap label |
												color := self colorForNode: (golap model nodeAt: shape model id).
												position := shape centroid: arcWidth * 0.5 + 4.
												gap := shape externalRadius * (shape alphaAngle - shape betaAngle) abs * Float pi / 180.0.
												label := RSLabel new text: (golap model nodeAt: shape model id) name.
												label
													position: label width / 2.0 @ 0;
													color: shape color;
													scaleBy: gap / label height;
													position: position + (position * (label width * 0.5 / position r));
													rotateByRadians: position theta + (Float pi / 2.0) \\ Float pi - (Float pi / 2.0).
												self canvas addShape: label ].
										(shape model isKindOf: GolapEdge) ifTrue: [
												((golap includesSelection: shape model node1) or: [ golap includesSelection: shape model node2 ]) ifTrue: [
														shape
															color: (shape color alpha: 1.0);
															pushFront ] ] ] ].
					self zoomToFit ] ]
]

{ #category : 'updating' }
GolapHEBChartPresenter >> updateTree [

	self golapModelDo: [ :golapModel |
			| ids |
			ids := (Array streamContents: [ :stream |
					        golapModel edgesDo: [ :edge |
							        (golapModel normalizedValueAtEdge: edge) ifNotNil: [
									        stream
										        nextPut: edge node1 id;
										        nextPut: edge node2 id ] ] ]) asSet.
			self tree: (((GolapHierarchicalClustering on: golapModel)
					  rank: 2;
					  rank: 4;
					  rank: 8;
					  tree) removeAllBut: ids) ]
]

{ #category : 'accessing' }
GolapHEBChartPresenter >> windowTitle [

	^ 'Hierarchical Edge Bundle'
]

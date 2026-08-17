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
					| colorMarkers hebBuilder modelMap |
					self updateTree.
					colorMarkers := golap colorMarkers.
					hebBuilder := RSHierarchicalEdgeBundleBuilder new.
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
																							width: edgeValue * 50 + 1;
																							color: (color alpha: 0.2);
																							capRound ] ] ] ] ] ] ] ].
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

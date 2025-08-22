Class {
	#name : 'GolapClusteredHeatmapPresenter',
	#superclass : 'GolapHierarchicalClusteringPresenter',
	#instVars : [
		'currentTree',
		'grid',
		'showsSingletonClustersCheckbox',
		'rankSlider',
		'rankLabel'
	],
	#category : 'Golap-Clustering-Heatmap',
	#package : 'Golap-Clustering',
	#tag : 'Heatmap'
}

{ #category : 'accessing' }
GolapClusteredHeatmapPresenter >> availableRanks [

	^ #( 2 4 8 16 32 64 128 256 )
]

{ #category : 'menus' }
GolapClusteredHeatmapPresenter >> cellMenuFor: aRSShape [

	^ self newMenu addGroup: [ :group |
			  group
				  addItem: [ :item |
						  | node |
						  node := aRSShape model second.
						  item
							  name: node name;
							  subMenu: (self menuForNode: node) ];
				  addItem: [ :item |
						  | node |
						  node := aRSShape model third.
						  item
							  name: node name;
							  subMenu: (self menuForNode: node) ] ]
]

{ #category : 'layout' }
GolapClusteredHeatmapPresenter >> defaultLayout [

	^ SpBoxLayout newVertical
		  add: (SpBoxLayout newHorizontal
				   add: showsSingletonClustersCheckbox expand: false;
				   add: ' クラスタランク';
				   add: rankSlider expand: false;
				   add: rankLabel expand: false;
				   yourself)
		  expand: false;
		  add: roassal;
		  yourself
]

{ #category : 'accessing' }
GolapClusteredHeatmapPresenter >> golapModelDo: aBlock [

	golap model ifNotNil: aBlock
]

{ #category : 'accessing' }
GolapClusteredHeatmapPresenter >> grid [

	^ grid ifNil: [ grid := RSLabel defaultFont height * 2 ]
]

{ #category : 'initialization' }
GolapClusteredHeatmapPresenter >> initializePresenters [

	super initializePresenters.
	showsSingletonClustersCheckbox := self newCheckBox
		                                  label: '単独クラスタも表示';
		                                  state: true;
		                                  whenChangedDo: [
			                                  self
				                                  showsSingletonClustersChanged ];
		                                  yourself.
	rankSlider := self newSlider
		              min: 1;
		              max: self availableRanks size;
		              quantum: 1;
		              value: 1;
		              whenValueChangedDo: [ self rankChanged ];
		              yourself.
	rankLabel := self newLabel
		             label: self rank printString;
		             yourself
]

{ #category : 'menus' }
GolapClusteredHeatmapPresenter >> menuForNode: aGolapNode [

	^ golap globalImageMenu: aGolapNode
]

{ #category : 'accessing' }
GolapClusteredHeatmapPresenter >> rank [

	^ self availableRanks at: rankSlider value
]

{ #category : 'updating' }
GolapClusteredHeatmapPresenter >> rankChanged [

	self
		updateRankLabel;
		updateCanvas
]

{ #category : 'updating' }
GolapClusteredHeatmapPresenter >> showsSingletonClustersChanged [

	self updateCanvas
]

{ #category : 'accessing' }
GolapClusteredHeatmapPresenter >> tree: aGolapHierarchicalClusteringTree [

	currentTree := aGolapHierarchicalClusteringTree.
	super tree: aGolapHierarchicalClusteringTree
]

{ #category : 'updating' }
GolapClusteredHeatmapPresenter >> updateCanvas [

	self canvas shapes copy do: #remove.
	self canvas color: Color black.
	self golapModelDo: [ :golapModel |
			| nodes rightBound minValue maxValue valueScale cells |
			nodes := self visibleNodes.
			rightBound := nodes size + 0.5 * self grid.
			minValue := golapModel minEdgeValue.
			maxValue := golapModel maxEdgeValue.
			minValue := minValue - (maxValue - minValue / 10.0).
			valueScale := 1.0 / (maxValue - minValue).
			cells := (Array streamContents: [ :stream |
					          nodes doWithIndex: [ :rowNode :rowIndex |
							          | rowLabel |
							          rowLabel := RSLabel new
								                      model: #rowLabel;
								                      text: rowNode name;
								                      color: Color lightGray.
							          rowLabel position:
								          rightBound + self grid + (rowLabel width * 0.5)
								          @ (rowIndex * self grid).
							          self canvas add: rowLabel.
							          nodes doWithIndex: [ :columnNode :columnIndex |
									          (columnNode edgeTo: rowNode ifAbsent: [ nil ])
										          ifNotNil: [ :edge |
												          | value |
												          value := (golapModel valueAtEdge: edge)
												                   - minValue * valueScale.
												          stream nextPut: (RSBox new
														           extent: self grid asPoint;
														           color: (Color gray: value);
														           position:
															           columnIndex * self grid
															           @ (rowIndex * self grid);
														           model: {
																           edge.
																           columnNode.
																           rowNode };
														           yourself) ] ] ] ]) asGroup.
			cells @ (GolapHeatmapCellInteraction new
				 presenter: self;
				 shapeBuilder: [ :triple |
						 | edge columnNode rowNode shapes |
						 edge := triple first.
						 columnNode := triple second.
						 rowNode := triple third.
						 shapes := Array streamContents: [ :stream |
									           columnNode photoimage ifNotNil: [ :form |
											           stream nextPut: (RSBitmap new form: form) ].
									           stream nextPut:
											           (RSLabel new text: columnNode name).
									           stream nextPut: (RSLabel new text: '&').
									           stream nextPut: (RSLabel new text: rowNode name).
									           rowNode photoimage ifNotNil: [ :form |
											           stream nextPut: (RSBitmap new form: form) ].
									           stream nextPut: (RSLabel new text:
													            'value: '
													            , (golapModel valueAtEdge: edge) printString) ].
						 RSVerticalLineLayout new
							 alignCenter;
							 on: shapes.
						 shapes := shapes asShape.
						 {
							 (RSBox new
								  extent: shapes encompassingRectangle extent + (10 @ 10);
								  color: (Color gray: 0.9);
								  position: shapes encompassingRectangle center).
							 shapes } asShape ]).
			self canvas addAll: cells ].
	self updateNode.
	self zoomToFit
]

{ #category : 'updating' }
GolapClusteredHeatmapPresenter >> updateNode [

	| rightBound |
	rightBound := 0.
	self canvas shapes copy do: [ :shape |
			shape model = #selection ifTrue: [ shape remove ].
			shape model = #rowLabel ifTrue: [
					rightBound := shape encompassingRectangle right + self grid max:
						              rightBound ] ].
	self golapModelDo: [ :golapModel |
			currentTree notNil ifTrue: [
					| nodes origin corner startIndex |
					nodes := self visibleNodes.
					origin := 0.0.
					corner := (nodes size + 1 * self grid) asFloat.
					rightBound := rightBound max: corner.
					startIndex := nil.
					(nodes copyWith: nil) doWithIndex: [ :node :index |
							(node notNil and: [ golap includesSelection: node ])
								ifTrue: [ startIndex ifNil: [ startIndex := index ] ]
								ifFalse: [
										startIndex ifNotNil: [
												| s e |
												s := startIndex - 0.5 * self grid.
												e := index - 0.5 * self grid.
												self canvas
													add: (RSLine new
															 model: #selection;
															 color: Color white;
															 width: 0.5;
															 startPoint: s @ origin;
															 endPoint: s @ corner);
													add: (RSLine new
															 model: #selection;
															 color: Color white;
															 width: 0.5;
															 startPoint: s @ corner;
															 endPoint: e @ corner);
													add: (RSLine new
															 model: #selection;
															 color: Color white;
															 width: 0.5;
															 startPoint: e @ corner;
															 endPoint: e @ origin);
													add: (RSLine new
															 model: #selection;
															 color: Color white;
															 width: 0.5;
															 startPoint: e @ origin;
															 endPoint: s @ origin).
												self canvas
													add: (RSLine new
															 model: #selection;
															 color: Color white;
															 width: 0.5;
															 startPoint: origin @ s;
															 endPoint: rightBound @ s);
													add: (RSLine new
															 model: #selection;
															 color: Color white;
															 width: 0.5;
															 startPoint: rightBound @ s;
															 endPoint: rightBound @ e);
													add: (RSLine new
															 model: #selection;
															 color: Color white;
															 width: 0.5;
															 startPoint: rightBound @ e;
															 endPoint: origin @ e);
													add: (RSLine new
															 model: #selection;
															 color: Color white;
															 width: 0.5;
															 startPoint: origin @ e;
															 endPoint: origin @ s).
												startIndex := nil ] ] ] ] ].
	self canvas signalUpdate
]

{ #category : 'updating' }
GolapClusteredHeatmapPresenter >> updateRankLabel [

	rankLabel label: self rank printString
]

{ #category : 'accessing' }
GolapClusteredHeatmapPresenter >> visibleNodes [

	^ showsSingletonClustersCheckbox state = true
		  ifTrue: [ currentTree graphNodes ]
		  ifFalse: [
				  Array streamContents: [ :stream |
						  currentTree childrenDo: [ :treeNode |
							  treeNode graphNodesDo: [ :graphNode |
								  stream nextPut: graphNode ] ] ] ]
]

{ #category : 'accessing' }
GolapClusteredHeatmapPresenter >> windowTitle [

	^ 'Heatmap'
]

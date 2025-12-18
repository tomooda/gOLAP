Class {
	#name : 'GolapClusteredHeatmapPresenter',
	#superclass : 'GolapHierarchicalClusteringPresenter',
	#instVars : [
		'currentTree',
		'grid',
		'showsClusterMeansCheckBox',
		'rankSlider',
		'rankLabel',
		'showsSingletonClustersCheckBox',
		'showsClusterBoundariesCheckBox',
		'evaluatorDropList'
	],
	#category : 'Golap-Visualization-Heatmap',
	#package : 'Golap-Visualization',
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

{ #category : 'private' }
GolapClusteredHeatmapPresenter >> computeClusterMeans [

	| means clusterNodes |
	clusterNodes := tree treesAtRank: self rank.
	means := Dictionary new: clusterNodes size squared.
	self golapModelDo: [ :golapModel |
		1 to: clusterNodes size do: [ :rowIndex |
			| rowCluster rowNodes |
			rowCluster := clusterNodes at: rowIndex.
			rowNodes := rowCluster graphNodes.
			1 to: clusterNodes size do: [ :columnIndex |
				| columnCluster columnNodes n mean |
				columnCluster := clusterNodes at: columnIndex.
				columnNodes := columnCluster graphNodes.
				n := rowNodes size * columnNodes size.
				mean := n = 0
					        ifTrue: [ nil ]
					        ifFalse: [
						        | sum |
						        sum := 0.
						        rowNodes do: [ :rowNode |
							        columnNodes do: [ :columnNode |
								        sum := sum
								               +
								               (self
									                valueAtRowNode: rowNode
									                columnNode: columnNode) ] ].
						        sum asFloat / n asFloat ].
				means
					at: {
							rowCluster.
							columnCluster }
					put: mean ] ] ].
	^ means
]

{ #category : 'layout' }
GolapClusteredHeatmapPresenter >> defaultLayout [

	^ SpBoxLayout newVertical
		  add: (SpBoxLayout newHorizontal
				   vAlignEnd;
				   add: showsSingletonClustersCheckBox expand: false;
				   add: showsClusterBoundariesCheckBox expand: false;
				   add: showsClusterMeansCheckBox expand: false;
				   add: ' クラスタランク' expand: false;
				   add: rankSlider width: 200;
				   add: rankLabel expand: false;
				   add: evaluatorDropList expand: false;
				   yourself)
		  expand: false;
		  add: roassal;
		  yourself
]

{ #category : 'accessing' }
GolapClusteredHeatmapPresenter >> evaluator [

	^ evaluatorDropList selectedItem
		  ifNotNil: #value
		  ifNil: [ golap edgeEvaluator ]
]

{ #category : 'updating' }
GolapClusteredHeatmapPresenter >> evaluatorChanged [

	self updateCanvas
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
	showsSingletonClustersCheckBox := self newCheckBox
		                                  label: '単独クラスタも表示する';
		                                  state: true;
		                                  whenChangedDo: [
			                                  self
				                                  showsSingletonClustersChanged ];
		                                  yourself.
	showsClusterBoundariesCheckBox := self newCheckBox
		                                  label: 'クラスタ境界を表示する';
		                                  state: false;
		                                  whenChangedDo: [
			                                  self
				                                  showsClusterBoundariesChanged ];
		                                  yourself.

	showsClusterMeansCheckBox := self newCheckBox
		                             label: 'クラスタ平均を表示する';
		                             state: false;
		                             whenChangedDo: [
			                             self showsClusterMeansChanged ];
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
		             yourself.
	evaluatorDropList := self newDropList
		                     display: [ :item | item key ];
		                     whenSelectedItemChangedDo: [
			                     self evaluatorChanged ];
		                     yourself
]

{ #category : 'private' }
GolapClusteredHeatmapPresenter >> maxValue [

	golap model ifNotNil: [ :model |
		self evaluator ifNotNil: [ :evaluator |
			(self evaluator isKindOf: GolapEdgeEvaluator) ifTrue: [
				| maxValue |
				maxValue := Float negativeInfinity.
				golap model edgesDo: [ :edge |
					| value |
					value := evaluator value: edge graph: model.
					value >= maxValue ifTrue: [ maxValue := value ] ].
				^ maxValue ].
			(self evaluator isKindOf: GolapNodeEvaluator) ifTrue: [
				| maxValue |
				maxValue := Float negativeInfinity.
				golap model nodesDo: [ :node |
					| value |
					value := evaluator value: node graph: model.
					value >= maxValue ifTrue: [ maxValue := value ] ].
				^ maxValue ] ] ].
	^ 1.0
]

{ #category : 'menus' }
GolapClusteredHeatmapPresenter >> menuForNode: aGolapNode [

	^ golap globalImageMenu: aGolapNode
]

{ #category : 'private' }
GolapClusteredHeatmapPresenter >> minValue [

	golap model ifNotNil: [ :model |
		self evaluator ifNotNil: [ :evaluator |
			(self evaluator isKindOf: GolapEdgeEvaluator) ifTrue: [
				| minValue |
				minValue := Float infinity.
				golap model edgesDo: [ :edge |
					| value |
					value := evaluator value: edge graph: model.
					value <= minValue ifTrue: [ minValue := value ] ].
				^ minValue ].
			(self evaluator isKindOf: GolapNodeEvaluator) ifTrue: [
				| minValue |
				minValue := Float infinity.
				golap model nodesDo: [ :node |
					| value |
					value := evaluator value: node graph: model.
					value <= minValue ifTrue: [ minValue := value ] ].
				^ minValue ] ] ].
	^ 0.0
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
GolapClusteredHeatmapPresenter >> showsClusterBoundariesChanged [

	self updateCanvas
]

{ #category : 'updating' }
GolapClusteredHeatmapPresenter >> showsClusterMeansChanged [

	self updateCanvas
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
		| rowLabelInteraction leaves clusterMeans rightBound minValue maxValue valueScale cells |
		self updateEvaluatorDropList.
		rowLabelInteraction := GolapHeatmapRowLabelInteraction new
			                       presenter: self;
			                       golapModel: golapModel;
			                       yourself.
		leaves := self visibleLeaves.
		clusterMeans := showsClusterMeansCheckBox state = true
			                ifTrue: [ self computeClusterMeans ]
			                ifFalse: [  ].
		rightBound := leaves size + 0.5 * self grid.
		minValue := self minValue.
		maxValue := self maxValue.
		minValue := minValue - (maxValue - minValue / 10.0).
		valueScale := (maxValue - minValue) abs > 1.0e-8
			              ifTrue: [ 1.0 / (maxValue - minValue) ]
			              ifFalse: [ 0.0 ].
		cells := (Array streamContents: [ :stream |
			          leaves doWithIndex: [ :rowLeaf :rowIndex |
				          | rowNode rowLabel |
				          rowNode := rowLeaf graphNode.
				          rowLabel := RSLabel new
					                      text: rowNode name;
					                      color: Color lightGray.
				          rowLabel := {
					                      (RSBox new
						                       extent: rowLabel extent;
						                       color: Color transparent).
					                      rowLabel } asShapeFor: {
						                      #rowLabel.
						                      rowNode }.
				          rowLabel position:
					          rightBound + self grid + (rowLabel width * 0.5)
					          @ (rowIndex * self grid).
				          rowLabel @ rowLabelInteraction.
				          self canvas add: rowLabel.
				          leaves doWithIndex: [ :columnLeaf :columnIndex |
					          | columnNode value |
					          columnNode := columnLeaf graphNode.
					          value := clusterMeans
						                   ifNotNil: [
							                   clusterMeans at: {
									                   (rowLeaf parentAtRank: self rank).
									                   (columnLeaf parentAtRank: self rank) } ]
						                   ifNil: [
						                   self
							                   valueAtRowNode: rowNode
							                   columnNode: columnNode ].
					          value ifNotNil: [
						          value := value - minValue * valueScale
							                   min: 1.0
							                   max: 0.0.
						          stream nextPut: (RSBox new
								           extent: self grid asPoint;
								           color: (Color gray: value);
								           position:
									           columnIndex * self grid @ (rowIndex * self grid);
								           model: {
										           (columnNode edgeTo: rowNode ifAbsent: [ nil ]).
										           columnNode.
										           rowNode };
								           yourself) ] ] ] ]) asGroup.
		cells @ (GolapHeatmapCellInteraction new
			 presenter: self;
			 golapModel: golapModel;
			 yourself).
		self canvas addAll: cells.
		showsClusterBoundariesCheckBox state = true ifTrue: [
			(leaves collect: [ :leaf | leaf parentAtRank: self rank ])
				ifNotEmpty: [ :clusters |
					| rect |
					rect := cells asGroup encompassingRectangle.
					1 to: clusters size - 1 do: [ :index |
						(clusters at: index) ~= (clusters at: index + 1) ifTrue: [
							| p |
							p := index + 0.5 * self grid.
							self canvas add: (RSLine new
									 startPoint: rect left @ p;
									 endPoint: rect right @ p;
									 color: Color red;
									 width: 2;
									 yourself).
							(self evaluator isKindOf: GolapEdgeEvaluator) ifTrue: [
								self canvas add: (RSLine new
										 startPoint: p @ rect top;
										 endPoint: p @ rect bottom;
										 color: Color red;
										 width: 2;
										 yourself) ] ] ] ] ] ].
	self updateNode.
	self zoomToFit
]

{ #category : 'updating' }
GolapClusteredHeatmapPresenter >> updateEvaluatorDropList [

	| selection items |
	selection := evaluatorDropList selectedItem.
	items := Array streamContents: [ :stream |
		         golap ifNotNil: [
			         stream nextPut: '---アイテム---' -> golap nodeEvaluator.
			         golap nodeEvaluators do: [ :evaluator |
				         stream nextPut: evaluator name -> evaluator ].
			         stream nextPut: '--- 関連 ----' -> golap edgeEvaluator.
			         golap edgeEvaluators do: [ :evaluator |
				         stream nextPut: evaluator name -> evaluator ] ] ].
	evaluatorDropList items: items.
	(items includes: selection) ifTrue: [
		evaluatorDropList selectItem: selection ]
]

{ #category : 'updating' }
GolapClusteredHeatmapPresenter >> updateNode [

	| rightBound |
	rightBound := 0.
	self canvas shapes copy do: [ :shape |
			shape model = #selection ifTrue: [ shape remove ].
			(shape model isArray and: [ shape model first = #rowLabel ])
				ifTrue: [
						rightBound := shape encompassingRectangle right + self grid
							              max: rightBound ] ].
	self golapModelDo: [ :golapModel |
			currentTree notNil ifTrue: [
					| nodes origin corner startIndex |
					nodes := self visibleLeaves collect: #graphNode.
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

{ #category : 'private' }
GolapClusteredHeatmapPresenter >> valueAtRowNode: aGolapNode1 columnNode: aGolapNode2 [

	| evaluator model |
	evaluator := self evaluator.
	model := golap model.
	model ifNil: [ ^ 0.0 ].
	(evaluator isKindOf: GolapNodeEvaluator) ifTrue: [
		^ evaluator value: aGolapNode1 graph: model ].
	(evaluator isKindOf: GolapEdgeEvaluator) ifTrue: [
		^ (aGolapNode1 edgeTo: aGolapNode2 ifAbsent: [ nil ])
			  ifNotNil: [ :edge | evaluator value: edge graph: model ]
			  ifNil: [ 0.0 ] ].
	^ 0.0
]

{ #category : 'accessing' }
GolapClusteredHeatmapPresenter >> visibleLeaves [

	^ showsSingletonClustersCheckBox state = true
		  ifTrue: [ currentTree leaves ]
		  ifFalse: [
				  Array streamContents: [ :stream |
						  currentTree atRank: self rank do: [ :treeNode |
								  treeNode size > 1 ifTrue: [
									  treeNode leavesDo: [ :leafNode | stream nextPut: leafNode ] ] ] ] ]
]

{ #category : 'accessing' }
GolapClusteredHeatmapPresenter >> windowTitle [

	^ 'Heatmap'
]

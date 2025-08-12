Class {
	#name : 'GolapClusteredHeatmapPresenter',
	#superclass : 'GolapHierarchicalClusteringPresenter',
	#category : 'Golap-Clustering-Heatmap',
	#package : 'Golap-Clustering',
	#tag : 'Heatmap'
}

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

{ #category : 'accessing' }
GolapClusteredHeatmapPresenter >> golapModelDo: aBlock [

	golap model ifNotNil: aBlock
]

{ #category : 'accessing' }
GolapClusteredHeatmapPresenter >> grid [

	^ 10
]

{ #category : 'menus' }
GolapClusteredHeatmapPresenter >> menuForNode: aGolapNode [

	^ golap globalImageMenu: aGolapNode
]

{ #category : 'updating' }
GolapClusteredHeatmapPresenter >> updateCanvas [

	self canvas clear.
	self canvas color: Color black.
	self golapModelDo: [ :golapModel |
			| nodes minValue maxValue valueScale cells |
			nodes := tree graphNodes.
			minValue := golapModel minEdgeValue.
			maxValue := golapModel maxEdgeValue.
			minValue := minValue - (maxValue - minValue / 10.0).
			valueScale := 1.0 / (maxValue - minValue).
			cells := (Array streamContents: [ :stream |
					          nodes doWithIndex: [ :columnNode :columnIndex |
							          (golap includesSelection: columnNode) ifTrue: [
									          self canvas add: (RSBox new
											           border: (RSBorder new color: Color lightGray);
											           color: Color transparent;
											           origin: columnIndex - 0.5 * self grid @ 0
											           corner:
												           columnIndex + 0.5 * self grid
												           @ (nodes size * self grid)) ].
							          nodes doWithIndex: [ :rowNode :rowIndex |
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

	self canvas shapes copy do: [ :shape |
		shape model = #selection ifTrue: [ shape remove ] ].
	self golapModelDo: [ :golapModel |
			| nodes |
			nodes := tree graphNodes.
			nodes doWithIndex: [ :columnNode :columnIndex |
					(golap includesSelection: columnNode) ifTrue: [
							self canvas add: (RSBox new
									 model: #selection;
									 border: (RSBorder new color: Color gray);
									 color: Color transparent;
									 origin: columnIndex - 0.5 * self grid @ 0
									 corner:
										 columnIndex + 0.5 * self grid
										 @ (nodes size + 1 * self grid)) ].
					nodes doWithIndex: [ :rowNode :rowIndex |
							(golap includesSelection: rowNode) ifTrue: [
									self canvas add: (RSBox new
											 model: #selection;
											 border: (RSBorder new color: Color gray);
											 color: Color transparent;
											 origin: 0 @ (rowIndex - 0.5 * self grid)
											 corner:
												 nodes size + 1 * self grid @ (rowIndex + 0.5 * self grid)) ] ] ] ].
	self canvas signalUpdate
]

{ #category : 'accessing' }
GolapClusteredHeatmapPresenter >> windowTitle [

	^ 'Heatmap'
]

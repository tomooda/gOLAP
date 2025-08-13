Class {
	#name : 'GolapClusteredHeatmapPresenter',
	#superclass : 'GolapHierarchicalClusteringPresenter',
	#instVars : [
		'grid'
	],
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

	^ grid ifNil: [ grid := RSLabel defaultFont height * 2 ]
]

{ #category : 'menus' }
GolapClusteredHeatmapPresenter >> menuForNode: aGolapNode [

	^ golap globalImageMenu: aGolapNode
]

{ #category : 'updating' }
GolapClusteredHeatmapPresenter >> updateCanvas [

	self canvas shapes copy do: #remove.
	self canvas color: Color black.
	self golapModelDo: [ :golapModel |
			| nodes rightBound minValue maxValue valueScale cells |
			nodes := tree graphNodes.
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
			tree notNil ifTrue: [
					| nodes origin corner startIndex |
					nodes := tree graphNodes.
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

{ #category : 'accessing' }
GolapClusteredHeatmapPresenter >> windowTitle [

	^ 'Heatmap'
]

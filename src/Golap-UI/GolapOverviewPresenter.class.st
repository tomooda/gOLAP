Class {
	#name : 'GolapOverviewPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'roassal',
		'scale',
		'offset',
		'golap',
		'visibleEdgeMaxValue',
		'visibleEdgeMinValue',
		'reallyVisibleEdges',
		'reallyVisibleNodes',
		'freqScale',
		'lineScale',
		'nodes',
		'labelNodes'
	],
	#category : 'Golap-UI-Overview',
	#package : 'Golap-UI',
	#tag : 'Overview'
}

{ #category : 'accessing' }
GolapOverviewPresenter >> camera [

	^ self canvas camera
]

{ #category : 'accessing' }
GolapOverviewPresenter >> cameraScale [

	^ self camera scale
]

{ #category : 'accessing' }
GolapOverviewPresenter >> cameraScale: aNumber [

	self camera scale: aNumber
]

{ #category : 'accessing' }
GolapOverviewPresenter >> canvas [

	^ roassal canvas
]

{ #category : 'layout' }
GolapOverviewPresenter >> defaultLayout [

	^ SpBoxLayout newVertical
		  add: roassal expand: true;
		  yourself
]

{ #category : 'private' }
GolapOverviewPresenter >> edgeVectorOf: aGolapNode [

	| v |
	v := 0 @ 0.
	aGolapNode asPoint ifNotNil: [ :p0 |
			aGolapNode edgesAndNodeDo: [ :edge :node |
					(reallyVisibleEdges includes: edge) ifTrue: [
						node asPoint ifNotNil: [ :p1 | v := v + (p0 - p1) normal ] ] ] ].
	^ v normal
]

{ #category : 'accessing' }
GolapOverviewPresenter >> golap: aGolap [
	golap := aGolap.
	self golapChanged
]

{ #category : 'updating' }
GolapOverviewPresenter >> golapChanged [

	
]

{ #category : 'enumerating' }
GolapOverviewPresenter >> golapDo: aBlock [

	^ golap ifNotNil: aBlock
]

{ #category : 'enumerating' }
GolapOverviewPresenter >> golapModelDo: aBlock [

	^ golap ifNotNil: [ golap model ifNotNil: aBlock ]
]

{ #category : 'initialization' }
GolapOverviewPresenter >> initialize [

	super initialize.
	scale := 1.0.
	offset := 0.0 @ 0.0.
	labelNodes := Array new
]

{ #category : 'initialization' }
GolapOverviewPresenter >> initializePresenters [

	super initializePresenters.
	roassal := self newRoassal
		           canvas: RSCanvas new @ self newCanvasController;
		           yourself
]

{ #category : 'operations' }
GolapOverviewPresenter >> move: aPoint [

	self offset: aPoint / scale + offset.
	self updateNodePositions.
	self canvas signalUpdate
]

{ #category : 'instance creation' }
GolapOverviewPresenter >> newCanvasController [

	^ GolapOverviewController new
		  presenter: self;
		  yourself
]

{ #category : 'instance creation' }
GolapOverviewPresenter >> newLabelForEdge: aGolapEdge [

	^ self golapModelDo: [ :golapModel |
			  ((golap includesSelection: aGolapEdge node1) or: [
				   golap includesSelection: aGolapEdge node2 ])
				  ifTrue: [
						  | string label |
						  string := String streamContents: [ :stream |
								            stream nextPutAll:
									            (golap simpleStringFor:
										             (golapModel valueAtEdge: aGolapEdge)).
								            golap selectedFrontDimension ifNotNil: [
										            :frontModel |
										            golap selectedBaseDimension ifNotNil: [
												            :baseModel |
												            stream
													            nextPutAll: '=';
													            nextPutAll: ((frontModel
															              edgeBetween: aGolapEdge node1 id
															              and: aGolapEdge node2 id
															              ifAbsent: [
																	              frontModel
																		              hiddenEdgeBetween: aGolapEdge node1 id
																		              and: aGolapEdge node2 id
																		              ifAbsent: [ nil ] ])
															             ifNotNil: [ :e |
																             golap simpleStringFor:
																		             (frontModel valueAtEdge: e) ]
															             ifNil: [ '0' ]);
													            nextPutAll: '-';
													            nextPutAll: ((baseModel
															              edgeBetween: aGolapEdge node1 id
															              and: aGolapEdge node2 id
															              ifAbsent: [
																	              baseModel
																		              hiddenEdgeBetween: aGolapEdge node1 id
																		              and: aGolapEdge node2 id
																		              ifAbsent: [ nil ] ])
															             ifNotNil: [ :e |
																             golap simpleStringFor:
																		             (baseModel valueAtEdge: e) ]
															             ifNil: [ '0' ]);
													            space ] ] ].
						  label := RSLabel new
							           text: string;
							           color: Color black.
						  {
							  (RSBox new
								   extent: label extent + 4 asPoint;
								   color: Color white;
								   borderColor: Color black;
								   borderWidth: 1;
								   yourself).
							  label } asShape ]
				  ifFalse: [ nil ] ]
]

{ #category : 'instance creation' }
GolapOverviewPresenter >> newShapeForEdge: aGolapEdge [

	self golapModelDo: [ :golapModel |
			(golap colorForEdge: aGolapEdge) ifNotNil: [ :color |
					| fromShape toShape v line |
					fromShape := nodes at: aGolapEdge node1 ifAbsent: [ ^ nil ].
					toShape := nodes at: aGolapEdge node2 ifAbsent: [ ^ nil ].
					v := golapModel valueAtEdge: aGolapEdge.
					(v notNil and: [ v asFloat isFinite ]) ifFalse: [ ^ nil ].
					line := RSLine new
						        withCenteredAttachPoint;
						        from: fromShape;
						        to: toShape;
						        width: v asFloat abs * lineScale + 2.0;
						        color: color.
					(self newLabelForEdge: aGolapEdge) ifNotNil: [ :label |
							line
								when: RSExtentChangedEvent
								do: [ label position: line position ]
								for: line.
							label position: line position.
							self canvas add: label ].
					^ line ] ].
	^ nil
]

{ #category : 'instance creation' }
GolapOverviewPresenter >> newShapeForNode: aGolapNode [

	self golapModelDo: [ :golapModel |
			| shapes markersAndNodes |
			shapes := RSGroup new.
			markersAndNodes := Array streamContents: [ :stream |
					                   golap markersAndNodesDo: [ :color :vs |
						                   color ifNotNil: [
							                   stream nextPut: color -> vs asIdentitySet ] ] ].
			(golap colorForNode: aGolapNode) ifNotNil: [ :color |
					| r shape |
					r := ((golapModel valueAtNode: aGolapNode) abs + 0.1) log
					     - 1.0 log * freqScale max: 10.
					shape := RSCircle new
						         extent: r asPoint;
						         color: color.
					self canvas addNode: shape.
					nodes at: aGolapNode put: shape.
					shapes add: shape.
					markersAndNodes do: [ :colorAndVs |
							(colorAndVs value includes: aGolapNode) ifTrue: [
									shape := RSEllipse new
										         extent: shape extent + 4 asPoint;
										         borderWidth: 4;
										         borderColor: colorAndVs key;
										         color: Color transparent;
										         yourself.
									shapes add: shape ] ].
					((labelNodes includes: aGolapNode) or: [
						 golap includesSelection: aGolapNode ]) ifTrue: [
							| label |
							label := RSLabel new
								         text: aGolapNode name;
								         color: color;
								         yourself.

							label position: (self edgeVectorOf: aGolapNode) negated
								* (shape extent y + label extent y * 0.5 + 4).
							(golap includesSelection: aGolapNode) ifTrue: [
									shapes add: (RSBox new
											 extent: label extent + 4 asPoint;
											 position: label position;
											 color: Color white;
											 borderColor: Color gray;
											 borderWidth: 1;
											 yourself) ].
							shapes add: label ] ].
			^ shapes asShapeFor: aGolapNode ].
	^ nil
]

{ #category : 'accessing' }
GolapOverviewPresenter >> offset [

	^ offset
]

{ #category : 'accessing' }
GolapOverviewPresenter >> offset: aPoint [

	offset := aPoint
]

{ #category : 'enumerating' }
GolapOverviewPresenter >> reallyVisibleNodesDo: aBlock [

	golap ifNotNil: [
			golap renderer ifNotNil: [ :renderer |
					renderer updateVisibleEdgeThresholds.
					renderer reallyVisibleNodes do: aBlock ] ]
]

{ #category : 'rendering' }
GolapOverviewPresenter >> renderEdgesIn: aRSCanvas [

	reallyVisibleEdges do: [ :edge |
			(self newShapeForEdge: edge) ifNotNil: [ :line |
					aRSCanvas
						add: line;
						addLine: line.
					line pushBack ] ]
]

{ #category : 'rendering' }
GolapOverviewPresenter >> renderNodesIn: aRSCanvas [

	| interaction |
	interaction := GolapOverviewNodeInteraction new
		               presenter: self;
		               yourself.
	nodes := IdentityDictionary new: reallyVisibleNodes size.
	reallyVisibleNodes do: [ :node |
			node asPoint ifNotNil: [ :p |
					(self newShapeForNode: node) ifNotNil: [ :shape |
							shape position: p + offset * scale.
							shape @ interaction.
							self canvas add: shape ] ] ]
]

{ #category : 'accessing' }
GolapOverviewPresenter >> scale [

	^ scale
]

{ #category : 'accessing' }
GolapOverviewPresenter >> scale: aNumber [

	scale := aNumber
]

{ #category : 'accessing' }
GolapOverviewPresenter >> scale: aNumber at: aPoint [

	| oldFocus newFocus |
	oldFocus := aPoint / scale.
	self scale: aNumber.
	newFocus := aPoint / scale.
	self offset: offset - oldFocus + newFocus
]

{ #category : 'updating' }
GolapOverviewPresenter >> updateCanvas [

	self updateVisibility.
	self
		updateFreqScale;
		updateLineScale;
		updateLabelNodes.
	self canvas shapes copy do: #remove.
	self canvas color: Color white.
	self
		renderNodesIn: self canvas;
		renderEdgesIn: self canvas.
	self canvas signalUpdate
]

{ #category : 'updating' }
GolapOverviewPresenter >> updateFreqScale [

	self golapModelDo: [ :golapModel |
			freqScale := 30.0 / ((golap nodes collect: [ :node |
				               ((golapModel valueAtNode: node) abs + 0.1) log
				               - 1.0 log ]) ifEmpty: [ 1 ] ifNotEmpty: #max) ]
]

{ #category : 'updating' }
GolapOverviewPresenter >> updateLabelNodes [

	| numLabels sortedNodes |
	numLabels := (50.0 ** golap numLabels) truncated.
	sortedNodes := (SortedCollection new: numLabels + 1) sortBlock:
		               #value descending.
	self golapModelDo: [ :golapModel |
			reallyVisibleNodes do: [ :node |
					sortedNodes add: node -> (golapModel valueAtNode: node).
					sortedNodes size > numLabels ifTrue: [ sortedNodes removeLast ] ] ].
	labelNodes := (sortedNodes collect: #key) asIdentitySet
]

{ #category : 'updating' }
GolapOverviewPresenter >> updateLineScale [

	| edgeScale maxValue |
	edgeScale := golap edgeScale.
	edgeScale < 1.0e-6 ifTrue: [ ^ self ].
	reallyVisibleEdges ifEmpty: [ ^ self ].
	maxValue := (reallyVisibleEdges
		             collect: [ :e |
		             (golap model valueAtEdge: e) ifNotNil: #abs ]
		             thenSelect: [ :v |
		             v notNil and: [ v isNaN not and: [ v isInfinite not ] ] ])
		            ifEmpty: [ 0 ]
		            ifNotEmpty: #max.
	lineScale := maxValue >= 1.0e-8
		             ifTrue: [ 5.0 / maxValue * edgeScale ]
		             ifFalse: [ 2.0 ].
]

{ #category : 'updating' }
GolapOverviewPresenter >> updateNodePositions [

	self canvas shapes do: [ :shape |
			(shape model isKindOf: GolapNode) ifTrue: [
				shape position: shape model asPoint + offset * scale ] ]
]

{ #category : 'updating' }
GolapOverviewPresenter >> updateTree [

	self updateCanvas
]

{ #category : 'updating' }
GolapOverviewPresenter >> updateVisibility [

	self golapModelDo: [ :model |
		| min max minFreq connectedNodes |
		min := 0.0.
		max := 0.0.
		minFreq := golap minFrequency.
		model ifNotNil: [
			| d |
			d := (golap visibleEdges
				      collect: [ :edge | model valueAtEdge: edge ]
				      thenSelect: [ :value |
				      value notNil and: [ value isNaN not ] ]) asArray
				     asSortedCollection.
			d ifNotEmpty: [
				min := d at:
					       (d size - 1 * golap visibleEdgeMinPercentile value)
						       rounded + 1.
				max := d at:
					       (d size - 1 * golap visibleEdgeMaxPercentile value)
						       rounded + 1 ] ].
		visibleEdgeMaxValue := max.
		visibleEdgeMinValue := min.
		golap visibleEdgeMinPercentile label:
			'min ' , visibleEdgeMinValue printString.
		golap visibleEdgeMaxPercentile label:
			'max ' , visibleEdgeMaxValue printString.
		reallyVisibleEdges := golap visibleEdges select: [ :edge |
			                      (edge node1 notNil and: [
				                       edge node1 x notNil and: [
					                       edge node2 y notNil and: [
						                       edge node2 notNil and: [
							                       edge node2 x notNil and: [
								                       edge node2 y notNil and: [
									                       (model valueAtNode: edge node1)
									                       >= minFreq and:
										                       (model valueAtNode: edge node2)
										                       > minFreq ] ] ] ] ] ]) and: [
				                      (model valueAtEdge: edge)
					                      ifNil: [ true ]
					                      ifNotNil: [ :v |
					                      v
						                      between: visibleEdgeMinValue
						                      and: visibleEdgeMaxValue ] ] ].
		connectedNodes := IdentitySet new: reallyVisibleEdges size.
		reallyVisibleEdges do: [ :edge |
			connectedNodes
				add: edge node1;
				add: edge node2 ].
		reallyVisibleNodes := Array streamContents: [ :stream |
			                      golap showsConnectedNodes ifTrue: [
				                      stream nextPutAll: connectedNodes ].
			                      self nodesDo: [ :v |
				                      (connectedNodes includes: v) ifFalse: [
					                      v isIsolated
						                      ifTrue: [
						                      golap showsIsolatedNodes ifTrue: [
							                      stream nextPut: v ] ]
						                      ifFalse: [
						                      golap showsHiddenConnectionNodes ifTrue: [
							                      stream nextPut: v ] ] ] ] ] ]
]

{ #category : 'operations' }
GolapOverviewPresenter >> zoomInAt: aPoint [

	self scale: self scale * 1.1 at: aPoint.
	self updateNodePositions.
	self canvas signalUpdate
]

{ #category : 'operations' }
GolapOverviewPresenter >> zoomOutAt: aPoint [

	self scale: self scale / 1.1 at: aPoint.
	self updateNodePositions.
	self canvas signalUpdate
]

{ #category : 'operations' }
GolapOverviewPresenter >> zoomToFit [

	| rect ext |
	rect := (Array streamContents: [ :stream |
			         reallyVisibleNodes do: [ :node |
				         node asPoint ifNotNil: [ :point | stream nextPut: point ] ] ])
		        ifEmpty: [ ^ self ]
		        ifNotEmpty: [ :points | Rectangle encompassing: points ].
	roassal withAdapterDo: [ :a | a widgetDo: [ :w | ext := w extent ] ].
	self scale: (ext x / rect width min: ext y / rect height) * 0.9.
	self offset: rect floatCenter negated.
	self updateNodePositions.
	self canvas signalUpdate
]

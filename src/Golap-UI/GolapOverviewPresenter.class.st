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
		'nodes'
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

{ #category : 'accessing' }
GolapOverviewPresenter >> golap: aGolap [
	golap := aGolap.
	self golapChanged
]

{ #category : 'updating' }
GolapOverviewPresenter >> golapChanged [

	
]

{ #category : 'enumerating' }
GolapOverviewPresenter >> golapModelDo: aBlock [

	^ golap ifNotNil: [ golap model ifNotNil: aBlock ]
]

{ #category : 'initialization' }
GolapOverviewPresenter >> initialize [

	super initialize.
	scale := 1.0.
	offset := 0.0 @ 0.0
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
					^ line ] ].
	^ nil
]

{ #category : 'instance creation' }
GolapOverviewPresenter >> newShapeForNode: aGolapNode [

	self golapModelDo: [ :golapModel |
			| shapes |
			shapes := RSGroup new.
			(golap colorForNode: aGolapNode) ifNotNil: [ :color |
					| r circle label |
					r := ((golapModel valueAtNode: aGolapNode) abs + 0.1) log
					     - 1.0 log * freqScale max: 10.
					circle := RSCircle new
						          extent: r asPoint;
						          color: color.
					self canvas addNode: circle.
					nodes at: aGolapNode put: circle.
					shapes add: circle.
					label := RSLabel new
						         text: aGolapNode name;
						         color: color;
						         yourself.
					label position: 0 @ (circle extent y + label extent y * 0.5 + 10).
					shapes add: label ].
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
						addLine: line ] ]
]

{ #category : 'rendering' }
GolapOverviewPresenter >> renderNodesIn: aRSCanvas [

	nodes := IdentityDictionary new: reallyVisibleNodes size.
	reallyVisibleNodes do: [ :node |
			node asPoint ifNotNil: [ :p |
					(self newShapeForNode: node) ifNotNil: [ :shape |
							shape position: p + offset * scale.
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
		updateLineScale.
	self canvas shapes copy do: #remove.
	self canvas color: Color white.
	self
		renderNodesIn: self canvas;
		renderEdgesIn: self canvas.
	self zoomToFit
]

{ #category : 'updating' }
GolapOverviewPresenter >> updateFreqScale [

	self golapModelDo: [ :golapModel |
			freqScale := 30.0 / ((golap nodes collect: [ :node |
				               ((golapModel valueAtNode: node) abs + 0.1) log
				               - 1.0 log ]) ifEmpty: [ 1 ] ifNotEmpty: #max) ]
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

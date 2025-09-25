Class {
	#name : 'GolapOverviewPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'roassal',
		'scale',
		'offset',
		'golap'
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
GolapOverviewPresenter >> newLabelFor: aGolapNode [

	^ RSLabel new
		  text: aGolapNode name;
		  yourself
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

	self canvas shapes copy do: #remove.
	self canvas color: Color white.
	golap ifNotNil: [
			golap renderer ifNotNil: [ :renderer |
					renderer updateVisibleEdgeThresholds.
					renderer reallyVisibleNodes ifNotNil: [ :nodes |
							nodes do: [ :node |
									node asPoint ifNotNil: [ :p |
											| shape |
											shape := self newLabelFor: node.
											shape
												model: node;
												color: Color black;
												position: p + offset * scale.
											self canvas add: shape ] ] ] ].
			self zoomToFit ]
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
			         self reallyVisibleNodesDo: [ :node |
				         node asPoint ifNotNil: [ :point | stream nextPut: point ] ] ])
		        ifEmpty: [ ^ self ]
		        ifNotEmpty: [ :points | Rectangle encompassing: points ].
	roassal withAdapterDo: [ :a | a widgetDo: [ :w | ext := w extent ] ].
	self scale: (ext x / rect width min: ext y / rect height) * 0.9.
	self offset: rect floatCenter negated.
	self updateNodePositions.
	self canvas signalUpdate
]

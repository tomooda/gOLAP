Class {
	#name : 'GolapOverviewPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'roassal',
		'scale',
		'golap'
	],
	#category : 'Golap-UI-Overview',
	#package : 'Golap-UI',
	#tag : 'Overview'
}

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

{ #category : 'defaults' }
GolapOverviewPresenter >> defaultScale [

	^ 1.0
]

{ #category : 'accessing' }
GolapOverviewPresenter >> golap: aGolap [
	golap := aGolap.
	self golapChanged
]

{ #category : 'updating' }
GolapOverviewPresenter >> golapChanged [

	self updateCanvas
]

{ #category : 'enumerating' }
GolapOverviewPresenter >> golapModelDo: aBlock [

	^ golap ifNotNil: [ golap model ifNotNil: aBlock ]
]

{ #category : 'initialization' }
GolapOverviewPresenter >> initialize [

	scale := self defaultScale.
	super initialize
]

{ #category : 'initialization' }
GolapOverviewPresenter >> initializePresenters [

	super initializePresenters.
	roassal := self newRoassal
		           canvas: RSCanvas new @ GolapOverviewController;
		           yourself
]

{ #category : 'instance creation' }
GolapOverviewPresenter >> newLabelFor: aGolapNode [

	^ RSLabel new
		  text: aGolapNode name;
		  yourself
]

{ #category : 'updating' }
GolapOverviewPresenter >> updateCanvas [

	self canvas shapes copy do: #remove.
	self canvas color: Color white.
	golap ifNotNil: [
			golap renderer ifNotNil: [ :renderer |
					| bounds offset scale |
					renderer updateVisibleEdgeThresholds.
					bounds := renderer fullBoundsWithMargin: 200 @ 50.
					extent := bounds extent.
					offset := bounds origin negated.
					scale := renderer scale.
					renderer reallyVisibleNodes ifNotNil: [ :nodes |
							nodes do: [ :node |
									node asPoint ifNotNil: [ :p |
											| shape |
											shape := self newLabelFor: node.
											shape
												color: Color black;
												position: p * scale + offset.
											self canvas add: shape ] ] ] ].
			self zoomToFit ]
]

{ #category : 'updating' }
GolapOverviewPresenter >> updateTree [

	self updateCanvas
]

{ #category : 'operations' }
GolapOverviewPresenter >> zoomToFit [

	self canvas
		zoomToFit;
		signalUpdate
]

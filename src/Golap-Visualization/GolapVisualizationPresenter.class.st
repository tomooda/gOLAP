Class {
	#name : 'GolapVisualizationPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'roassal',
		'golap',
		'lock'
	],
	#category : 'Golap-Visualization-Abstract',
	#package : 'Golap-Visualization',
	#tag : 'Abstract'
}

{ #category : 'testing' }
GolapVisualizationPresenter class >> isAbstract [

	^ self == GolapVisualizationPresenter
]

{ #category : 'accessing' }
GolapVisualizationPresenter >> camera [

	^ self canvas camera
]

{ #category : 'accessing' }
GolapVisualizationPresenter >> canvas [

	^ roassal canvas
]

{ #category : 'accessing' }
GolapVisualizationPresenter >> colorForEdge: aGolapEdge [

	^ golap colorForEdge: aGolapEdge
]

{ #category : 'accessing-colors' }
GolapVisualizationPresenter >> colorForNode: aGolapNode [

	^ ((aGolapNode isKindOf: GolapNode)
		   ifTrue: [ aGolapNode ]
		   ifFalse: [ golap model nodeAt: aGolapNode ifAbsent: [ nil ] ]) ifNotNil: [ :node | golap colorForNode: node ]
]

{ #category : 'controlling' }
GolapVisualizationPresenter >> critical: aBlock [

	^ lock critical: aBlock
]

{ #category : 'layout' }
GolapVisualizationPresenter >> defaultLayout [

	^ SpBoxLayout newVertical
		  add: roassal;
		  yourself
]

{ #category : 'accessing' }
GolapVisualizationPresenter >> golap [

	^ golap
]

{ #category : 'accessing' }
GolapVisualizationPresenter >> golap: aGolap [

	golap := aGolap.
	self golapChanged
]

{ #category : 'updating' }
GolapVisualizationPresenter >> golapChanged [

	^ self subclassResponsibility
]

{ #category : 'enumerating' }
GolapVisualizationPresenter >> golapDo: aBlock [

	^ golap ifNotNil: aBlock
]

{ #category : 'accessing' }
GolapVisualizationPresenter >> golapModelDo: aBlock [

	^ (golap ifNotNil: #model) ifNotNil: aBlock
]

{ #category : 'initialization' }
GolapVisualizationPresenter >> initialize [

	super initialize.
	lock := Mutex new
]

{ #category : 'initialization' }
GolapVisualizationPresenter >> initializePresenters [

	super initializePresenters.
	roassal := self newRoassal
		           canvas: RSCanvas new;
		           yourself
]

{ #category : 'instance creation' }
GolapVisualizationPresenter >> newPinShape [

	^ {
		  (RSPolygon new
			   points: {
					   (-7 @ -12).
					   (7 @ -12).
					   (0 @ 0) };
			   color: Color red;
			   yourself).
		  (RSCircle new
			   extent: 16 @ 16;
			   position: 0 @ -16;
			   color: Color red;
			   yourself).
		  (RSCircle new
			   extent: 6 @ 6;
			   position: 0 @ -16;
			   color: Color white;
			   yourself) } asShape
]

{ #category : 'testing' }
GolapVisualizationPresenter >> showsNode: aGolapNode [

	^ self subclassResponsibility
]

{ #category : 'testing' }
GolapVisualizationPresenter >> showsPhotoimages [

	^ golap showsPhotoimages
]

{ #category : 'operations' }
GolapVisualizationPresenter >> toggleSelection: aGolapNode [

	golap toggleSelection: aGolapNode
]

{ #category : 'operations' }
GolapVisualizationPresenter >> toggleSelectionsAll: aCollectionOfGolapNode [

	(aCollectionOfGolapNode anySatisfy: [ :node |
		 (golap includesSelection: node) not ])
		ifTrue: [ golap selectAll: aCollectionOfGolapNode ]
		ifFalse: [ golap unselectAll: aCollectionOfGolapNode ]
]

{ #category : 'updating' }
GolapVisualizationPresenter >> updateCanvas [

	^ self subclassResponsibility
]

{ #category : 'updating' }
GolapVisualizationPresenter >> zoomToFit [

	self isDisplayed ifTrue: [
			self critical: [
					self canvas camera privExtent: roassal extent.
					self canvas camera zoomToFit: roassal extent.
					self canvas signalUpdate ] ]
]

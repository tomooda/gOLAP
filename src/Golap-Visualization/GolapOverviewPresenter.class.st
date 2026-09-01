Class {
	#name : 'GolapOverviewPresenter',
	#superclass : 'GolapVisualizationPresenter',
	#instVars : [
		'scale',
		'offset'
	],
	#category : 'Golap-Visualization-Overview',
	#package : 'Golap-Visualization',
	#tag : 'Overview'
}

{ #category : 'testing' }
GolapOverviewPresenter class >> isAbstract [

	^ self = GolapOverviewPresenter
]

{ #category : 'accessing' }
GolapOverviewPresenter >> cameraScale [

	^ self camera scale
]

{ #category : 'accessing' }
GolapOverviewPresenter >> cameraScale: aNumber [

	self camera scale: aNumber
]

{ #category : 'initialization' }
GolapOverviewPresenter >> defaultOffset [

	^ 0.0 @ 0.0
]

{ #category : 'initialization' }
GolapOverviewPresenter >> defaultScale [

	^ 100.0
]

{ #category : 'operations' }
GolapOverviewPresenter >> doZoomToFit [

	^ self subclassResponsibility
]

{ #category : 'initialization' }
GolapOverviewPresenter >> initialize [

	super initialize.
	scale := self defaultScale.
	offset := self defaultOffset
]

{ #category : 'initialization' }
GolapOverviewPresenter >> initializePresenters [

	super initializePresenters.
	roassal canvas @ self newCanvasController
]

{ #category : 'operations' }
GolapOverviewPresenter >> move: aPoint [

	self offset: aPoint / scale + offset.
	self scaleAndOffsetChanged
]

{ #category : 'instance creation' }
GolapOverviewPresenter >> newCanvasController [

	^ GolapOverviewController new
		  presenter: self;
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
GolapOverviewPresenter >> scaleAndOffsetChanged [

	^ self subclassResponsibility
]

{ #category : 'operations' }
GolapOverviewPresenter >> zoomInAt: aPoint [

	self scale: self scale * 1.1 at: aPoint.
	self scaleAndOffsetChanged
]

{ #category : 'operations' }
GolapOverviewPresenter >> zoomOutAt: aPoint [

	self scale: self scale / 1.1 at: aPoint.
	self scaleAndOffsetChanged
]

{ #category : 'operations' }
GolapOverviewPresenter >> zoomToFit [

	self isDisplayed ifTrue: [ self doZoomToFit ]
]

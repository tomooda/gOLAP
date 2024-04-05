Class {
	#name : #GolapDandelionCanvasController,
	#superclass : #RSCanvasController,
	#instVars : [
		'presenter'
	],
	#category : #'Golap-Clustering-Dandelion'
}

{ #category : #'instance creation' }
GolapDandelionCanvasController class >> on: aGolapDandelionChartPresenter [

	^ self new
		  presenter: aGolapDandelionChartPresenter;
		  yourself
]

{ #category : #hooks }
GolapDandelionCanvasController >> clicked: event [
]

{ #category : #hooks }
GolapDandelionCanvasController >> onShape: aShape [

	super onShape: aShape.
	aShape
		when: RSMouseLeftClick send: #clicked: to: self;
		when: RSMouseRightClick send: #rightClicked: to: self
]

{ #category : #accessing }
GolapDandelionCanvasController >> presenter: aGolapDandelionChartPresenter [

	presenter := aGolapDandelionChartPresenter
]

{ #category : #hooks }
GolapDandelionCanvasController >> rightClicked: event [

	(presenter golap globalImageMenu: nil) openWithSpecAt:
		(presenter withAdapterDo: [ :a |
			 a widgetDo: [ :w | w activeHand position ] ])
]

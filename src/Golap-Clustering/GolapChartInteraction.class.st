Class {
	#name : 'GolapChartInteraction',
	#superclass : 'RSPopup',
	#instVars : [
		'presenter'
	],
	#category : 'Golap-Clustering-Core',
	#package : 'Golap-Clustering',
	#tag : 'Core'
}

{ #category : 'instance creation' }
GolapChartInteraction class >> on: aGolapDandelionChartPresenter [

	^ self new
		  presenter: aGolapDandelionChartPresenter;
		  yourself
]

{ #category : 'hooks' }
GolapChartInteraction >> clicked: evt [

	evt signalUpdate
]

{ #category : 'hooks' }
GolapChartInteraction >> onShape: aShape [

	super onShape: aShape.
	aShape
		when: RSMouseLeftClick send: #clicked: to: self;
		when: RSMouseRightClick send: #rightClicked: to: self
]

{ #category : 'accessing' }
GolapChartInteraction >> presenter: aGolapDandelionChartPresenter [

	presenter := aGolapDandelionChartPresenter
]

{ #category : 'hooks' }
GolapChartInteraction >> rightClicked: evt [

	
]

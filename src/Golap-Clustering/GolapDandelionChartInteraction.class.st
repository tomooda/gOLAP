Class {
	#name : 'GolapDandelionChartInteraction',
	#superclass : 'RSPopup',
	#instVars : [
		'presenter'
	],
	#category : 'Golap-Clustering-Dandelion',
	#package : 'Golap-Clustering',
	#tag : 'Dandelion'
}

{ #category : 'instance creation' }
GolapDandelionChartInteraction class >> on: aGolapDandelionChartPresenter [

	^ self new
		  presenter: aGolapDandelionChartPresenter;
		  yourself
]

{ #category : 'hooks' }
GolapDandelionChartInteraction >> clicked: evt [

	evt signalUpdate
]

{ #category : 'hooks' }
GolapDandelionChartInteraction >> onShape: aShape [

	super onShape: aShape.
	aShape
		when: RSMouseLeftClick send: #clicked: to: self;
		when: RSMouseRightClick send: #rightClicked: to: self
]

{ #category : 'accessing' }
GolapDandelionChartInteraction >> presenter: aGolapDandelionChartPresenter [

	presenter := aGolapDandelionChartPresenter
]

{ #category : 'hooks' }
GolapDandelionChartInteraction >> rightClicked: evt [

	
]

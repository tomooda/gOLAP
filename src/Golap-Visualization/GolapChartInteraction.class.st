Class {
	#name : 'GolapChartInteraction',
	#superclass : 'RSPopup',
	#instVars : [
		'presenter'
	],
	#category : 'Golap-Visualization-Clustering',
	#package : 'Golap-Visualization',
	#tag : 'Clustering'
}

{ #category : 'instance creation' }
GolapChartInteraction class >> on: aGolapDandelionChartPresenter [

	^ self new
		  presenter: aGolapDandelionChartPresenter;
		  yourself
]

{ #category : 'hooks' }
GolapChartInteraction >> clicked: evt [

	
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

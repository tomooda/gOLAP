Class {
	#name : 'GolapClusteringChartInteraction',
	#superclass : 'RSPopup',
	#instVars : [
		'presenter'
	],
	#category : 'Golap-Visualization-Clustering',
	#package : 'Golap-Visualization',
	#tag : 'Clustering'
}

{ #category : 'instance creation' }
GolapClusteringChartInteraction class >> on: aGolapDandelionChartPresenter [

	^ self new
		  presenter: aGolapDandelionChartPresenter;
		  yourself
]

{ #category : 'hooks' }
GolapClusteringChartInteraction >> clicked: evt [

	
]

{ #category : 'hooks' }
GolapClusteringChartInteraction >> onShape: aShape [

	super onShape: aShape.
	aShape
		when: RSMouseLeftClick send: #clicked: to: self;
		when: RSMouseRightClick send: #rightClicked: to: self
]

{ #category : 'accessing' }
GolapClusteringChartInteraction >> presenter: aGolapDandelionChartPresenter [

	presenter := aGolapDandelionChartPresenter
]

{ #category : 'hooks' }
GolapClusteringChartInteraction >> rightClicked: evt [

	
]

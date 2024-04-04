Class {
	#name : #GolapDandelionChartInteraction,
	#superclass : #RSPopup,
	#instVars : [
		'clickAction',
		'presenter'
	],
	#category : #'Golap-Clustering'
}

{ #category : #'instance creation' }
GolapDandelionChartInteraction class >> on: aGolapDandelionChartPresenter [

	^ self new
		  presenter: aGolapDandelionChartPresenter;
		  yourself
]

{ #category : #hooks }
GolapDandelionChartInteraction >> clicked: evt [

	evt signalUpdate
]

{ #category : #hooks }
GolapDandelionChartInteraction >> onShape: aShape [

	super onShape: aShape.
	aShape when: RSMouseClick send: #clicked: to: self
]

{ #category : #accessing }
GolapDandelionChartInteraction >> presenter: aGolapDandelionChartPresenter [

	presenter := aGolapDandelionChartPresenter
]

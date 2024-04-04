Class {
	#name : #GolapDandelionEdgeInteraction,
	#superclass : #GolapDandelionChartInteraction,
	#category : #'Golap-Clustering'
}

{ #category : #hooks }
GolapDandelionEdgeInteraction >> clicked: evt [

	evt shape model value ifNode: [ :node | node openSunburst ].
	evt signalUpdate
]

{ #category : #hooks }
GolapDandelionEdgeInteraction >> createPopupFor: aShape event: event [

	| popupShape |
	popupShape := shapeBuilder shapeFor: aShape model value.
	popupShape isFixed: true.
	event canvas addShape: popupShape.
	^ popupShape
]

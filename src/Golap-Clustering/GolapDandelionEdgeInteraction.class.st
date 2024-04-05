Class {
	#name : #GolapDandelionEdgeInteraction,
	#superclass : #GolapDandelionChartInteraction,
	#category : #'Golap-Clustering-Dandelion'
}

{ #category : #hooks }
GolapDandelionEdgeInteraction >> clicked: evt [
	"evt shape model value ifNode: [ :node | node openSunburst ]."

	presenter toggleSelectionsAll: evt shape model value vertices
]

{ #category : #hooks }
GolapDandelionEdgeInteraction >> createPopupFor: aShape event: event [

	| popupShape |
	popupShape := shapeBuilder shapeFor: aShape model value.
	popupShape isFixed: true.
	event canvas addShape: popupShape.
	^ popupShape
]

{ #category : #hooks }
GolapDandelionEdgeInteraction >> rightClicked: event [

	(presenter golap globalImageMenu: nil) openWithSpecAt:
		(presenter withAdapterDo: [ :a |
			 a widgetDo: [ :w | w activeHand position ] ])
]

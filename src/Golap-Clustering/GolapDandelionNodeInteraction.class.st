Class {
	#name : #GolapDandelionNodeInteraction,
	#superclass : #GolapDandelionChartInteraction,
	#category : #'Golap-Clustering-Dandelion'
}

{ #category : #hooks }
GolapDandelionNodeInteraction >> activePopupWith: event [

	event shape model isLeaf ifTrue: [ super activePopupWith: event ]
]

{ #category : #hooks }
GolapDandelionNodeInteraction >> clicked: event [

	(event shape model respondsTo: #vertex) ifTrue: [
		presenter toggleSelection: event shape model vertex ]
]

{ #category : #hooks }
GolapDandelionNodeInteraction >> createPopupFor: aShape event: event [

	^ aShape model vertex photoimage
		  ifNotNil: [ :photoimage |
			  | imageShape labelShape popupShape |
			  imageShape := RSBitmap newFrom: photoimage.
			  labelShape := shapeBuilder shapeFor: aShape model vertex name.
			  imageShape translateBottomLeftTo: 0 @ 0.
			  labelShape translateTopLeftTo: 0 @ 0.
			  popupShape := RSComposite new
				                shapes: {
						                imageShape.
						                labelShape };
				                yourself.
			  popupShape isFixed: true.
			  event canvas addShape: popupShape.
			  popupShape ]
		  ifNil: [ super createPopupFor: aShape event: event ]
]

{ #category : #hooks }
GolapDandelionNodeInteraction >> rightClicked: event [

	(event shape model respondsTo: #vertex) ifTrue: [
		(presenter golap globalImageMenu: event shape model vertex)
			openWithSpecAt: (presenter withAdapterDo: [ :a |
					 a widgetDo: [ :w | w activeHand position ] ]) ]
]

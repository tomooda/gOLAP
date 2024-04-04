Class {
	#name : #GolapDandelionNodeInteraction,
	#superclass : #GolapDandelionChartInteraction,
	#category : #'Golap-Clustering'
}

{ #category : #hooks }
GolapDandelionNodeInteraction >> activePopupWith: event [

	event shape model isLeaf ifTrue: [ super activePopupWith: event ]
]

{ #category : #hooks }
GolapDandelionNodeInteraction >> clicked: event [

	presenter toggleSelection: event shape model vertex
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

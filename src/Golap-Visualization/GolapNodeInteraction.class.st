Class {
	#name : 'GolapNodeInteraction',
	#superclass : 'GolapChartInteraction',
	#category : 'Golap-Visualization-Clustering',
	#package : 'Golap-Visualization',
	#tag : 'Clustering'
}

{ #category : 'hooks' }
GolapNodeInteraction >> activePopupWith: event [

	event shape model isLeaf ifTrue: [ super activePopupWith: event ]
]

{ #category : 'hooks' }
GolapNodeInteraction >> clicked: event [

	(event shape model respondsTo: #graphNode) ifTrue: [
		presenter toggleSelection: event shape model graphNode ]
]

{ #category : 'hooks' }
GolapNodeInteraction >> createPopupFor: aShape event: event [

	^ aShape model graphNode photoimage
		  ifNotNil: [ :photoimage |
			  | imageShape labelShape popupShape |
			  imageShape := RSBitmap newFrom: photoimage.
			  labelShape := shapeBuilder shapeFor: aShape model graphNode name.
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

{ #category : 'hooks' }
GolapNodeInteraction >> rightClicked: event [

	(event shape model respondsTo: #graphNode) ifTrue: [
		(presenter golap globalImageMenu: event shape model graphNode)
			openWithSpecAt: (presenter withAdapterDo: [ :a |
					 a widgetDo: [ :w | w activeHand position ] ]) ]
]

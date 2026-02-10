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

	(event shape model respondsTo: #id) ifTrue: [
			presenter toggleSelection:
				(presenter golap model nodeAt: event shape model id) ]
]

{ #category : 'hooks' }
GolapNodeInteraction >> createPopupFor: aShape event: event [

	| popupShape |
	presenter showsPhotoimages ifTrue: [
			(presenter golap model nodeAt: aShape model id) photoimage
				ifNotNil: [ :photoimage |
						| imageShape labelShape |
						imageShape := RSBitmap newFrom: photoimage.
						labelShape := shapeBuilder shapeFor:
							              (presenter golap model nodeAt: aShape model id)
								              name.
						imageShape translateBottomLeftTo: 0 @ 0.
						labelShape translateTopLeftTo: 0 @ 0.
						popupShape := RSComposite new
							              shapes: {
									              imageShape.
									              labelShape };
							              yourself.
						popupShape isFixed: true.
						event canvas addShape: popupShape.
						^ popupShape ] ].
	popupShape := shapeBuilder shapeFor:
		              (presenter golap model nodeAt: aShape model id) name.
	popupShape isFixed: true.
	event canvas addShape: popupShape.
	^ popupShape
]

{ #category : 'hooks' }
GolapNodeInteraction >> rightClicked: event [

	(event shape model respondsTo: #id) ifTrue: [
		(presenter golap globalImageMenu:
			 (presenter golap model nodeAt: event shape model id))
			openWithSpecAt: (presenter withAdapterDo: [ :a |
					 a widgetDo: [ :w | w activeHand position ] ]) ]
]

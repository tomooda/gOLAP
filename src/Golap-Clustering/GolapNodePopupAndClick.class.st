Class {
	#name : #GolapNodePopupAndClick,
	#superclass : #RSPopup,
	#instVars : [
		'clickAction'
	],
	#category : #'Golap-Clustering'
}

{ #category : #accessing }
GolapNodePopupAndClick >> clickAction [

	^ clickAction ifNil: [ clickAction := self defaultClickAction ]
]

{ #category : #accessing }
GolapNodePopupAndClick >> clickAction: aBlock [

	clickAction := aBlock
]

{ #category : #hooks }
GolapNodePopupAndClick >> clicked: evt [

	self clickAction cull: evt shape.
	evt signalUpdate
]

{ #category : #hooks }
GolapNodePopupAndClick >> createPopupFor: aShape event: event [

	| popupShape |
	popupShape := shapeBuilder shapeFor: aShape model value.
	popupShape isFixed: true.
	event canvas addShape: popupShape.
	^ popupShape
]

{ #category : #defaults }
GolapNodePopupAndClick >> defaultClickAction [

	^ [ :shape | shape model value ifNode: [ :node | node openSunburst ] ]
]

{ #category : #hooks }
GolapNodePopupAndClick >> onShape: aShape [

	super onShape: aShape.
	aShape when: RSMouseClick send: #clicked: to: self
]

Class {
	#name : #GolapPopupAndClick,
	#superclass : #RSPopup,
	#instVars : [
		'clickAction'
	],
	#category : #'Golap-Clustering'
}

{ #category : #accessing }
GolapPopupAndClick >> clickAction [

	^ clickAction ifNil: [ clickAction := self defaultClickAction ]
]

{ #category : #accessing }
GolapPopupAndClick >> clickAction: aBlock [

	clickAction := aBlock
]

{ #category : #hooks }
GolapPopupAndClick >> clicked: evt [

	self clickAction cull: evt shape.
	evt signalUpdate
]

{ #category : #defaults }
GolapPopupAndClick >> defaultClickAction [

	^ [ :shape | shape model ifNode: [ :node | node openSunburst ] ]
]

{ #category : #hooks }
GolapPopupAndClick >> onShape: aShape [

	super onShape: aShape.
	aShape when: RSMouseClick send: #clicked: to: self
]

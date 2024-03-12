Class {
	#name : #GolapLeafPopup,
	#superclass : #RSPopup,
	#category : #'Golap-Clustering'
}

{ #category : #hooks }
GolapLeafPopup >> activePopupWith: event [

	event shape model isLeaf ifTrue: [ super activePopupWith: event ]
]

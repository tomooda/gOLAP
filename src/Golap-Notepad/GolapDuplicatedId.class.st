Class {
	#name : 'GolapDuplicatedId',
	#superclass : 'Error',
	#instVars : [
		'oldClip',
		'newClip',
		'collection'
	],
	#category : 'Golap-Notepad-Clip',
	#package : 'Golap-Notepad',
	#tag : 'Clip'
}

{ #category : 'instance creation' }
GolapDuplicatedId class >> signalWith: aGolapClip with: anotherGolapClip in: aGolapClipCollection [

	^ self new
		  oldClip: anotherGolapClip;
		  newClip: aGolapClip;
		  collection: aGolapClipCollection;
		  signal
]

{ #category : 'accessing' }
GolapDuplicatedId >> collection [

	^ collection
]

{ #category : 'accessing' }
GolapDuplicatedId >> collection: anObject [

	collection := anObject
]

{ #category : 'accessing' }
GolapDuplicatedId >> newClip [

	^ newClip
]

{ #category : 'accessing' }
GolapDuplicatedId >> newClip: anObject [

	newClip := anObject
]

{ #category : 'accessing' }
GolapDuplicatedId >> oldClip [

	^ oldClip
]

{ #category : 'accessing' }
GolapDuplicatedId >> oldClip: anObject [

	oldClip := anObject
]

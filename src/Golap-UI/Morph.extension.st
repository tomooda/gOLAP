Extension { #name : 'Morph' }

{ #category : '*Golap-UI' }
Morph >> handleMouseWheel: anEvent [

	"System level event handling."

	anEvent wasHandled ifTrue: [ ^ self ].
	(self handlesMouseWheel: anEvent) ifTrue: [ 
		anEvent wasHandled: true.
		self mouseWheel: anEvent ].
	^ self eventHandler ifNotNil: [ :handler | 
		  handler mouseWheel: anEvent fromMorph: self ]
]

{ #category : '*Golap-UI' }
Morph >> handlesMouseWheel: anEvent [
	^ false
]

{ #category : '*Golap-UI' }
Morph >> mouseWheel: anEvent [
	| code keyEvent |
	code := (anEvent isUp
		ifTrue: [ Character arrowUp ]
		ifFalse: [ Character arrowDown ]) asInteger.
	keyEvent := KeyboardEvent new
		setType: #keystroke
			buttons: 0
			position: anEvent position
			keyValue: code
			charCode: code
			hand: anEvent hand
			stamp: anEvent timeStamp;
		yourself.
	self dispatchKeystrokeForEvent: keyEvent
]

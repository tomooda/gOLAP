Extension { #name : 'PanelMorph' }

{ #category : '*Golap-UI' }
PanelMorph >> handlesMouseWheel: anEvent [
	^ true
]

{ #category : '*Golap-UI' }
PanelMorph >> mouseWheel: anEvent [
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

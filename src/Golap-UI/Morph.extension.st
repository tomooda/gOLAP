Extension { #name : 'Morph' }

{ #category : '*Golap-UI' }
Morph >> bounds: newBounds [

	| oldExtent newExtent |
	oldExtent := self extent.
	newExtent := newBounds extent rounded.
	(oldExtent dotProduct: oldExtent) <= (newExtent dotProduct: newExtent)
		ifTrue: [ "We're growing. First move then resize."
				self
					position: newBounds topLeft rounded;
					extent: newExtent ]
		ifFalse: [ "We're shrinking. First resize then move."
				self
					extent: newExtent;
					position: newBounds topLeft rounded ]
]

{ #category : '*Golap-UI' }
Morph >> extent: aPoint [
	|newExtent|
	newExtent := aPoint rounded.
	(bounds extent closeTo: newExtent) ifTrue: [^ self].
	self changed.
	bounds := (bounds topLeft extent: newExtent).
	self layoutChanged.
	self changed
]

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

{ #category : '*Golap-UI' }
Morph >> position: aPoint [
	"Change the position of this morph and and all of its
	submorphs. "

	| delta box |
	delta := aPoint rounded - bounds topLeft.
	(delta x = 0 and: [ delta y = 0 ]) ifTrue: [ ^ self ].
	"Null change"
	box := self fullBounds.
	(delta dotProduct: delta) > 100
		ifTrue: [ "e.g., more than 10 pixels moved"
				self invalidRect: box.
				self invalidRect: (box translateBy: delta) ]
		ifFalse: [ self invalidRect: (box merge: (box translateBy: delta)) ].
	self privateFullMoveBy: delta.
	owner ifNotNil: [ owner layoutChanged ]
]

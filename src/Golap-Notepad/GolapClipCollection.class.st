Class {
	#name : 'GolapClipCollection',
	#superclass : 'HashedCollection',
	#category : 'Golap-Notepad-Clip',
	#package : 'Golap-Notepad',
	#tag : 'Clip'
}

{ #category : 'instance creation' }
GolapClipCollection class >> newFrom: aCollection [

	| newCollection |
	newCollection := self new: aCollection size.
	newCollection addAll: aCollection.
	^ newCollection
]

{ #category : 'adding' }
GolapClipCollection >> add: aGolapClip [
	"Include newObject as one of the receiver's elements, but only if
	not already present. Answer newObject."

	| index |
	index := self scanFor: aGolapClip id.
	(array at: index)
		ifNil: [ self atNewIndex: index put: aGolapClip ]
		ifNotNil: [ :clip | GolapDuplicatedId signalWith: aGolapClip with: clip in: self ].
	^ aGolapClip
]

{ #category : 'accessing' }
GolapClipCollection >> at: aString [

	^ self at: aString ifPresent: #yourself ifAbsent: [ KeyNotFound signalFor: aString in: self ]
]

{ #category : 'accessing' }
GolapClipCollection >> at: aString ifAbsent: absentBlock [

	^ self at: aString ifPresent: #yourself ifAbsent: absentBlock
]

{ #category : 'accessing' }
GolapClipCollection >> at: aString ifPresent: presentBlock [

	^ self at: aString ifPresent: presentBlock ifAbsent: [ nil ]
]

{ #category : 'accessing' }
GolapClipCollection >> at: aString ifPresent: presentBlock ifAbsent: absentBlock [

	^ (array at: (self findElementOrNil: aString)) ifNotNil: presentBlock ifNil: absentBlock
]

{ #category : 'enumerating' }
GolapClipCollection >> do: aBlock [

	tally = 0 ifTrue: [ ^ self ].
	1 to: array size do: [ :index |
			| each |
			(each := array at: index) ifNotNil: [ aBlock value: each enclosedElement ] ]
]

{ #category : 'private' }
GolapClipCollection >> fixCollisionsFrom: start [
	"The element at start has been removed and replaced by nil.
	This method moves forward from there, relocating any entries
	that had been placed below due to collisions with this one"

	| element index |
	index := start.
	[ (element := array at: (index := index \\ array size + 1)) == nil ] whileFalse: [
			| newIndex |
			(newIndex := self scanFor: element id) = index ifFalse: [ array swap: index with: newIndex ] ]
]

{ #category : 'testing' }
GolapClipCollection >> includesKey: aString [

	^ (array at: (self findElementOrNil: aString)) notNil
]

{ #category : 'private' }
GolapClipCollection >> noCheckAdd: aGolapClip [
	"This method should be deprecated"

	array at: (self findElementOrNil: aGolapClip id) put: aGolapClip.
	tally := tally + 1
]

{ #category : 'private' }
GolapClipCollection >> noCheckNoGrowFillFrom: anArray [
	"Add the elements of anArray except nils to me assuming that I don't contain any of them, they are unique and I have more free space than they require."

	1 to: anArray size do: [ :index |
	(anArray at: index) ifNotNil: [ :clip | array at: (self scanForEmptySlotFor: clip id) put: clip ] ]
]

{ #category : 'removing' }
GolapClipCollection >> remove: oldObject ifAbsent: aBlock [

	| index |
	index := self findElementOrNil: oldObject id.
	(array at: index) ifNil: [ ^ aBlock value ].
	array at: index put: nil.
	tally := tally - 1.
	self fixCollisionsFrom: index.
	^ oldObject
]

{ #category : 'removing' }
GolapClipCollection >> removeKey: aString ifAbsent: aBlock [

	| index old |
	index := self findElementOrNil: aString.
	(old := array at: index) ifNil: [ ^ aBlock value ].
	array at: index put: nil.
	tally := tally - 1.
	self fixCollisionsFrom: index.
	^ old
]

{ #category : 'accessing' }
GolapClipCollection >> rename: aString to: anotherString [

	^ self
		  at: aString
		  ifPresent: [ :clip |
				  clip id: anotherString.
				  self rehash.
				  clip ]
		  ifAbsent: [ nil ]
]

{ #category : 'private' }
GolapClipCollection >> scanFor: anObject [
	"Scan the key array for the first slot containing either a nil (indicating an empty slot) or an element that matches anObject. Answer the index of that slot or raise an error if no slot is found. This method will be overridden in various subclasses that have different interpretations for matching elements."

	| index start |
	index := start := anObject hash \\ array size + 1.
	[
		| element |
		((element := array at: index) == nil or: [ element id = anObject ]) ifTrue: [ ^ index ].
		(index := index \\ array size + 1) = start ] whileFalse.
	self errorNoFreeSpace
]

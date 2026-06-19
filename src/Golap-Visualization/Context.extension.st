Extension { #name : 'Context' }

{ #category : '*Golap-Visualization' }
Context >> senderSelectors [

	^ Array streamContents: [ :stream |
			  | context |
			  context := self sender.
			  [ context notNil ] whileTrue: [
					  stream nextPut: context selector.
					  context := context sender ] ]
]

{ #category : '*Golap-Visualization' }
Context >> senderSelectorsIncludes: aSymbol [

	| context |
	context := self sender.
	[ context notNil ] whileTrue: [
			context selector = aSymbol ifTrue: [ ^ true ].
			context := context sender ].
	^ false
]

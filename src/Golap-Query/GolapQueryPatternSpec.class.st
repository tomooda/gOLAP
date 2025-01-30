Class {
	#name : 'GolapQueryPatternSpec',
	#superclass : 'GolapQueryPredicateSpec',
	#instVars : [
		'pattern',
		'regex'
	],
	#category : 'Golap-Query-AST',
	#package : 'Golap-Query',
	#tag : 'AST'
}

{ #category : 'examples' }
GolapQueryPatternSpec class >> exampleSubmatchABC [
	<script: 'GolapQueryPatternSpec exampleSubmatchABC inspect'>
	^ GolapQueryPatternSpec fromString: ' *ABC* '
]

{ #category : 'instance creation' }
GolapQueryPatternSpec class >> fromJSON: aJSONObject [
	^ self new
		pattern: (aJSONObject at: 'pattern');
		yourself
]

{ #category : 'instance creation' }
GolapQueryPatternSpec class >> fromString: aString ifError: errorBlock [
	^ self with: aString
]

{ #category : 'instance creation' }
GolapQueryPatternSpec class >> with: aString [
	^ self new
		pattern: aString;
		yourself
]

{ #category : 'comparing' }
GolapQueryPatternSpec >> = anObject [
	^ super = anObject and: [ pattern = anObject pattern ]
]

{ #category : 'converting' }
GolapQueryPatternSpec >> asJSON [
	^ super asJSON
		at: 'pattern' put: pattern;
		yourself
]

{ #category : 'enumerating' }
GolapQueryPatternSpec >> bareLiteralsDo: aBlock [
	guard
		ifNil: [ self hasWildcard
				ifFalse: [ aBlock cull: self ] ]
]

{ #category : 'private' }
GolapQueryPatternSpec >> flushRegex [
	regex := nil
]

{ #category : 'enumerating' }
GolapQueryPatternSpec >> guardedLiteralsDo: aBlock [
	guard
		ifNotNil: [ self hasWildcard
				ifFalse: [ aBlock cull: self ] ]
]

{ #category : 'testing' }
GolapQueryPatternSpec >> hasWildcard [
	^ (pattern includes: $*) or: [ pattern includes: $? ]
]

{ #category : 'comparing' }
GolapQueryPatternSpec >> hash [
	^ super hash bitXor: pattern hash
]

{ #category : 'accessing' }
GolapQueryPatternSpec >> pattern [
	^ pattern
]

{ #category : 'accessing' }
GolapQueryPatternSpec >> pattern: aString [
	pattern := aString asString.
	self flushRegex
]

{ #category : 'printing' }
GolapQueryPatternSpec >> printBareQueryWith: aString on: aStream [
	self hasWildcard
		ifTrue: [ aStream
				nextPutAll: 'like(';
				nextPutAll: aString;
				nextPut: $,;
				nextPutAll: pattern golapQuoted;
				nextPut: $) ]
		ifFalse: [ aStream
				nextPutAll: 'isin(';
				nextPutAll: aString;
				nextPut: $,;
				nextPutAll: pattern golapQuoted;
				nextPut: $) ]
]

{ #category : 'printing' }
GolapQueryPatternSpec >> printSpecOn: aStream [
	aStream nextPutAll: pattern.
	guard
		ifNotNil: [ aStream nextPut: $(.
			guard printSpecOn: aStream.
			aStream nextPut: $) ]
]

{ #category : 'enumerating' }
GolapQueryPatternSpec >> rangesDo: aBlock [
	
]

{ #category : 'private' }
GolapQueryPatternSpec >> regex [
	^ regex
		ifNil: [ regex := (((#('\' '.' '[' ']' '(' ')' '!' '+' '|')
				inject: pattern
				into: [ :p :special | p copyReplaceAll: special with: '\' , special ])
				copyReplaceAll: '*'
				with: '.*') copyReplaceAll: '?' with: '[ -~]+') asRegex ]
]

{ #category : 'accessing' }
GolapQueryPatternSpec >> value: aStringOrNumber [
	^ self hasWildcard
		ifTrue: [ self regex matches: aStringOrNumber asString ]
		ifFalse: [ pattern = aStringOrNumber asString ]
]

{ #category : 'enumerating' }
GolapQueryPatternSpec >> wildcardsDo: aBlock [
	self hasWildcard
		ifTrue: [ aBlock cull: self ]
]

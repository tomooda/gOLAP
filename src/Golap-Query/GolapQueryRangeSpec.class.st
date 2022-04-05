Class {
	#name : #GolapQueryRangeSpec,
	#superclass : #GolapQueryPredicateSpec,
	#instVars : [
		'start',
		'end'
	],
	#category : #'Golap-Query'
}

{ #category : #examples }
GolapQueryRangeSpec class >> exampleAtoZ [
	<script: 'GolapQueryRangeSpec exampleAtoZ inspect'>
	^ GolapQueryRangeSpec fromString: 'A...Z'
]

{ #category : #'instance creation' }
GolapQueryRangeSpec class >> from: aString1 to: aString2 [
	^ self new
		start: aString1;
		end: aString2;
		yourself
]

{ #category : #'instance creation' }
GolapQueryRangeSpec class >> fromJSON: aJSONObject [
	^ self new
		start: (aJSONObject at: 'start');
		end: (aJSONObject at: 'end');
		yourself
]

{ #category : #'instance creation' }
GolapQueryRangeSpec class >> fromString: aString ifError: errorBlock [
	| args |
	args := aString substrings: '...'.
	args size = 2
		ifFalse: [ ^ errorBlock cull: 'Should be in the form of ''<start>...<end>''.' ].
	^ self from: args first to: args second
]

{ #category : #comparing }
GolapQueryRangeSpec >> = anObject [
	^ super = anObject
		and: [ start = anObject start and: [ end = anObject end ] ]
]

{ #category : #converting }
GolapQueryRangeSpec >> asJSON [
	^ super asJSON
		at: 'start' put: start;
		at: 'end' put: end;
		yourself
]

{ #category : #enumerating }
GolapQueryRangeSpec >> bareLiteralsDo: aBlock [
	
]

{ #category : #accessing }
GolapQueryRangeSpec >> end [
	^ end
]

{ #category : #accessing }
GolapQueryRangeSpec >> end: aString [
	end := aString asString
]

{ #category : #enumerating }
GolapQueryRangeSpec >> guardedLiteralsDo: aBlock [
	
]

{ #category : #comparing }
GolapQueryRangeSpec >> hash [
	^ (super hash bitXor: start hash) bitXor: end hash
]

{ #category : #printing }
GolapQueryRangeSpec >> printBareQueryWith: aString on: aStream [
	aStream
		nextPutAll: 'range(';
		nextPutAll: aString;
		nextPut: $,;
		nextPutAll: start golapQuoted;
		nextPut: $,;
		nextPutAll: end golapQuoted;
		nextPut: $)
]

{ #category : #printing }
GolapQueryRangeSpec >> printSpecOn: aStream [
	aStream
		nextPutAll: start;
		nextPutAll: '...';
		nextPutAll: end.
	guard
		ifNotNil: [ aStream nextPut: $(.
			guard printSpecOn: aStream.
			aStream nextPut: $) ]
]

{ #category : #enumerating }
GolapQueryRangeSpec >> rangesDo: aBlock [
	aBlock cull: self
]

{ #category : #accessing }
GolapQueryRangeSpec >> start [
	^ start
]

{ #category : #accessing }
GolapQueryRangeSpec >> start: aString [
	start := aString asString
]

{ #category : #accessing }
GolapQueryRangeSpec >> value: aStringOrNumber [
	| str |
	str := aStringOrNumber asString.
	^ start <= str and: [ str <= end ]
]

{ #category : #enumerating }
GolapQueryRangeSpec >> wildcardsDo: aBlock [
	
]

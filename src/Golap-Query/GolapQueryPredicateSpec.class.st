Class {
	#name : 'GolapQueryPredicateSpec',
	#superclass : 'GolapAbstractQuerySpec',
	#instVars : [
		'guard',
		'warnings',
		'errors'
	],
	#category : 'Golap-Query-AST',
	#package : 'Golap-Query',
	#tag : 'AST'
}

{ #category : 'instance creation' }
GolapQueryPredicateSpec class >> fromJSON: aDictionary [
	aDictionary
		at: 'pattern'
		ifPresent: [ ^ GolapQueryPatternSpec fromJSON: aDictionary ].
	aDictionary
		at: 'start'
		ifPresent: [ ^ GolapQueryRangeSpec fromJSON: aDictionary ].
	^ self shouldNotImplement
]

{ #category : 'instance creation' }
GolapQueryPredicateSpec class >> fromString: aString ifError: errorBlock [
	(aString includesSubstring: '...')
		ifTrue: [ ^ GolapQueryRangeSpec fromString: aString ifError: errorBlock ].
	^ GolapQueryPatternSpec fromString: aString ifError: errorBlock
]

{ #category : 'comparing' }
GolapQueryPredicateSpec >> = anObject [
	^ self class = anObject class and: [ guard = anObject guard ]
]

{ #category : 'converting' }
GolapQueryPredicateSpec >> asJSON [
	^ Dictionary new
		at: 'guard' put: (guard ifNotNil: #asJSON);
		yourself
]

{ #category : 'enumerating' }
GolapQueryPredicateSpec >> bareLiteralsDo: aBlock [
	^ self subclassResponsibility
]

{ #category : 'operations' }
GolapQueryPredicateSpec >> clearWarningsAndErrors [
	warnings removeAll.
	errors removeAll
]

{ #category : 'accessing' }
GolapQueryPredicateSpec >> color [
	self hasError
		ifTrue: [ ^ Color red darker ].
	self hasWarning
		ifTrue: [ ^ Color yellow muchDarker ].
	^ Color black
]

{ #category : 'accessing' }
GolapQueryPredicateSpec >> guard [
	^ guard
]

{ #category : 'accessing' }
GolapQueryPredicateSpec >> guard: aGolapClauseOrNil [
	guard := aGolapClauseOrNil
]

{ #category : 'accessing' }
GolapQueryPredicateSpec >> guardField [
	^ guard ifNotNil: #field
]

{ #category : 'enumerating' }
GolapQueryPredicateSpec >> guardedLiteralsDo: aBlock [
	^ self subclassResponsibility
]

{ #category : 'enumerating' }
GolapQueryPredicateSpec >> guardedPredicatesDo: aBlock [
	guard ifNotNil: [ aBlock cull: self ]
]

{ #category : 'testing' }
GolapQueryPredicateSpec >> hasError [
	^ errors notEmpty
]

{ #category : 'testing' }
GolapQueryPredicateSpec >> hasGuard [
	^ guard notNil
]

{ #category : 'testing' }
GolapQueryPredicateSpec >> hasWarning [
	^ warnings notEmpty
]

{ #category : 'comparing' }
GolapQueryPredicateSpec >> hash [
	^ self class hash bitXor: guard hash
]

{ #category : 'initialization' }
GolapQueryPredicateSpec >> initialize [
	super initialize.
	warnings := OrderedCollection new.
	errors := OrderedCollection new
]

{ #category : 'testing' }
GolapQueryPredicateSpec >> isPredicateSpec [
	^ true
]

{ #category : 'testing' }
GolapQueryPredicateSpec >> isSubClause [
	^ false
]

{ #category : 'printing' }
GolapQueryPredicateSpec >> printBareQueryWith: aString on: aStream [
	^ self subclassResponsibility
]

{ #category : 'printing' }
GolapQueryPredicateSpec >> printQueryOn: aStream [
	self printQueryWith: '<field name>' on: aStream
]

{ #category : 'printing' }
GolapQueryPredicateSpec >> printQueryWith: aString on: aStream [
	guard ifNotNil: [ aStream nextPutAll: 'and(' ].
	self printBareQueryWith: aString on: aStream.
	guard
		ifNotNil: [ aStream nextPutAll: ',not('.
			guard printQueryOn: aStream.
			aStream nextPutAll: '))' ]
]

{ #category : 'accessing' }
GolapQueryPredicateSpec >> queryWith: aFieldNameString [
	^ String
		streamContents: [ :stream | self printQueryWith: aFieldNameString on: stream ]
]

{ #category : 'enumerating' }
GolapQueryPredicateSpec >> rangesDo: aBlock [
	^ self subclassResponsibility
]

{ #category : 'accessing' }
GolapQueryPredicateSpec >> value: aStringOrNumber [
	^ self subclassResponsibility
]

{ #category : 'enumerating' }
GolapQueryPredicateSpec >> wildcardsDo: aBlock [
	^ self subclassResponsibility
]

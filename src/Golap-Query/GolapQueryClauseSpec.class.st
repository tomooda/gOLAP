Class {
	#name : #GolapQueryClauseSpec,
	#superclass : #GolapAbstractQuerySpec,
	#instVars : [
		'field',
		'predicates',
		'isNegative'
	],
	#category : #'Golap-Query'
}

{ #category : #'instance creation' }
GolapQueryClauseSpec class >> clauseSpecClassFor: aJSONObject [
	^ (aJSONObject includesKey: 'itemFilter')
		ifTrue: [ GolapQueryTransactionClauseSpec ]
		ifFalse: [ GolapQueryItemClauseSpec ]
]

{ #category : #'instance creation' }
GolapQueryClauseSpec class >> fromJSON: aJSONObject [
	^ (self clauseSpecClassFor: aJSONObject) new
		field: (aJSONObject at: 'field');
		predicates:
			((aJSONObject at: 'predicates')
				collect: [ :obj | GolapQueryPredicateSpec fromJSON: obj ]);
		isNegative: (aJSONObject at: 'isNegative');
		yourself
]

{ #category : #'instance creation' }
GolapQueryClauseSpec class >> fromString: aString ifError: errorBlock [
	| index field |
	index := aString indexOf: $:.
	index > 0
		ifTrue: [ field := aString copyFrom: 1 to: index - 1 ]
		ifFalse: [ field := aString.
			index := aString size ].
	field ifEmpty: [ ^ errorBlock cull: 'Missing field name.' ].
	^ self
		on: field trim
		withAll:
			(((aString copyFrom: index + 1 to: aString size) substrings: ',')
				collect: [ :predicate | 
					predicate trim
						ifNotEmpty: [ :pred | 
							GolapQueryPredicateSpec
								fromString: pred
								ifError: [ :msg | ^ errorBlock cull: msg ] ] ])
]

{ #category : #'instance creation' }
GolapQueryClauseSpec class >> on: aFieldNameString [
	^ self new
		field: aFieldNameString;
		yourself
]

{ #category : #'instance creation' }
GolapQueryClauseSpec class >> on: aFieldNameString withAll: aCollectionOfGolapQueryPredicateSpec [
	| clause |
	clause := self on: aFieldNameString.
	aCollectionOfGolapQueryPredicateSpec
		do: [ :predicate | clause addPredicate: predicate ].
	^ clause
]

{ #category : #comparing }
GolapQueryClauseSpec >> = anObject [
	^ self class = anObject class
		and: [ field = anObject field
				and: [ predicates = anObject predicates
						and: [ self isNegative = anObject isNegative ] ] ]
]

{ #category : #adding }
GolapQueryClauseSpec >> addPredicate: aGolapQueryPredicateSpec [
	^ predicates add: aGolapQueryPredicateSpec
]

{ #category : #converting }
GolapQueryClauseSpec >> asJSON [
	^ Dictionary new
		at: 'field' put: field;
		at: 'predicates' put: (predicates collect: #asJSON);
		at: 'isNegative' put: isNegative;
		yourself
]

{ #category : #enumerating }
GolapQueryClauseSpec >> bareLiteralsDo: aBlock [
	predicates do: [ :predicate | predicate bareLiteralsDo: aBlock ]
]

{ #category : #operations }
GolapQueryClauseSpec >> clearWarningsAndErrors [
	predicates do: [ :spec | spec clearWarningsAndErrors ]
]

{ #category : #accessing }
GolapQueryClauseSpec >> field [
	^ field
]

{ #category : #accessing }
GolapQueryClauseSpec >> field: aString [
	field := aString asString
]

{ #category : #enumerating }
GolapQueryClauseSpec >> guardedLiteralsDo: aBlock [
	predicates do: [ :predicate | predicate guardedLiteralsDo: aBlock ]
]

{ #category : #enumerating }
GolapQueryClauseSpec >> guardedPredicatesDo: aBlock [
	predicates do: [ :spec | spec guardedPredicatesDo: aBlock ]
]

{ #category : #testing }
GolapQueryClauseSpec >> hasItemFilter [
	^ false
]

{ #category : #testing }
GolapQueryClauseSpec >> hasPredicates [
	^ predicates notEmpty
]

{ #category : #comparing }
GolapQueryClauseSpec >> hash [
	^ ((self class hash bitXor: field hash) bitXor: predicates hash)
		bitXor: isNegative
]

{ #category : #initialization }
GolapQueryClauseSpec >> initialize [
	super initialize.
	predicates := OrderedCollection new
]

{ #category : #testing }
GolapQueryClauseSpec >> isClauseSpec [
	^ true
]

{ #category : #testing }
GolapQueryClauseSpec >> isItemClause [
	^ false
]

{ #category : #accessing }
GolapQueryClauseSpec >> isNegative [
	^ isNegative = true
]

{ #category : #accessing }
GolapQueryClauseSpec >> isNegative: aBoolean [
	isNegative := aBoolean = true
]

{ #category : #testing }
GolapQueryClauseSpec >> isTransactionClause [
	^ false
]

{ #category : #enumerating }
GolapQueryClauseSpec >> itemClausesDo: aBlock [
]

{ #category : #accessing }
GolapQueryClauseSpec >> predicates [
	^ predicates
]

{ #category : #accessing }
GolapQueryClauseSpec >> predicates: aCollectionOfGolapQueryPredicateSpec [
	predicates := aCollectionOfGolapQueryPredicateSpec
		asOrderedCollection
]

{ #category : #printing }
GolapQueryClauseSpec >> printQueryOn: aStream [
	| subqueries |
	predicates ifEmpty: [ ^ self ].
	self isNegative
		ifTrue: [ aStream nextPutAll: 'not(' ].
	subqueries := Array
		streamContents: [ :queryStream | 
			(Array
				streamContents: [ :literals | 
					self
						bareLiteralsDo: [ :predicate | literals nextPut: predicate pattern golapQuoted ] ])
				ifNotEmpty: [ :bareLiterals | 
					queryStream
						nextPut:
							(String
								streamContents: [ :isinStream | 
									isinStream
										nextPutAll: 'isin(';
										nextPutAll: field.
									bareLiterals
										do: [ :literal | 
											isinStream
												nextPut: $,;
												nextPutAll: literal ].
									isinStream nextPut: $) ]) ].
			self
				guardedLiteralsDo: [ :predicate | queryStream nextPut: (predicate queryWith: field) ].
			self
				wildcardsDo: [ :predicate | queryStream nextPut: (predicate queryWith: field) ].
			self
				rangesDo: [ :predicate | queryStream nextPut: (predicate queryWith: field) ] ].
	subqueries size >= 2
		ifTrue: [ aStream nextPutAll: 'or(' ].
	subqueries
		do: [ :subquery | aStream nextPutAll: subquery ]
		separatedBy: [ aStream nextPut: $, ].
	subqueries size >= 2
		ifTrue: [ aStream nextPut: $) ].
	self isNegative
		ifTrue: [ aStream nextPut: $) ]
]

{ #category : #printing }
GolapQueryClauseSpec >> printSpecOn: aStream [
	self isNegative
		ifTrue: [ aStream nextPut: $- ].
	aStream
		nextPutAll: field;
		nextPutAll: ' : '.
	predicates
		do: [ :spec | spec printSpecOn: aStream ]
		separatedBy: [ aStream nextPutAll: ', ' ]
]

{ #category : #enumerating }
GolapQueryClauseSpec >> rangesDo: aBlock [
	predicates do: [ :predicate | predicate rangesDo: aBlock ]
]

{ #category : #adding }
GolapQueryClauseSpec >> removeAllNonSubClausePredicates [
	predicates := predicates select: #isSubClause
]

{ #category : #adding }
GolapQueryClauseSpec >> removeAllPredicates [
	predicates removeAll
]

{ #category : #adding }
GolapQueryClauseSpec >> removeAllSubClausePredicates [
	predicates := predicates reject: #isSubClause
]

{ #category : #adding }
GolapQueryClauseSpec >> removePredicate: aGolapQueryPredicateSpec ifAbsent: errorBlock [
	^ predicates
		remove: aGolapQueryPredicateSpec
		ifAbsent: errorBlock
]

{ #category : #accessing }
GolapQueryClauseSpec >> toggleNegative [
	self isNegative: self isNegative not
]

{ #category : #enumerating }
GolapQueryClauseSpec >> transactionClausesDo: aBlock [
]

{ #category : #accessing }
GolapQueryClauseSpec >> value: aStringOrNumber [
	^ predicates isEmpty
		or: [ predicates
				anySatisfy: [ :predicate | predicate value: aStringOrNumber ] ]
]

{ #category : #enumerating }
GolapQueryClauseSpec >> wildcardsDo: aBlock [
	predicates do: [ :predicate | predicate wildcardsDo: aBlock ]
]
